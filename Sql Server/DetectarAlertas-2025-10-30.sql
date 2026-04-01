
GO
/****** Object:  StoredProcedure [dbo].[DetectarAlertas]    Script Date: 10/30/2025 11:10:13 a. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

ALTER PROCEDURE [dbo].[DetectarAlertas]
    @fecha_analisis DATE
AS
BEGIN
    SET NOCOUNT ON;


	    -- Declaración de variables
    DECLARE @done INT = 0;
    DECLARE @v_id_metrica INT;
    DECLARE @v_tipologia VARCHAR(100);
    DECLARE @v_metrica VARCHAR(100);
	DECLARE @v_umbral VARCHAR(100);
    DECLARE @v_operador VARCHAR(20);
    DECLARE @v_valor DECIMAL(18,2);
    
    DECLARE @v_entidad_ref VARCHAR(100);
    DECLARE @umbral_desc VARCHAR(255);
    
    -- Cursor
    DECLARE cur_alertas CURSOR LOCAL STATIC FOR
	SELECT 
		m.id_metrica,
		t.nombre AS tipologia,
		m.nombre AS metrica,
		m.umbral,
		m.operador,
		m.valor
	FROM  metrica m,
		  tipologia t
	WHERE m.id_tipologia = t.id_tipologia
	  AND m.estatus = 'Activo'
		ORDER BY m.id_metrica;
    
    OPEN cur_alertas;

    WHILE 1 = 1
    BEGIN
        FETCH NEXT FROM cur_alertas INTO 
            @v_id_metrica, 
            @v_tipologia, 
            @v_metrica,
			@v_umbral,
            @v_operador, 
            @v_valor;
            
        IF @@FETCH_STATUS <> 0 BREAK;

        -- 1. ALERTAS: 
		--    Tipologia : Pagos Directos a Beneficiarios Distintos al Asegurado
        --    Metrica   : Frecuencia de Pagos a Beneficiarios Distintos
		--    Umbral    : Más de 3 veces en un mes
		IF @v_id_metrica = 1
        BEGIN
			WITH TransaccionesPorMes AS (
				SELECT c.cod_cliente,
						e.no_poliza,
						rt.no_reclamo,
						(SELECT m.prima 
						   FROM emipomae m 
						  WHERE m.no_poliza = e.no_poliza 
						    AND m.cod_contratante = c.cod_cliente
						) AS PrimaSuscrita,
						SUM(rt.monto) AS TransaccionesPagadas,
						STUFF((SELECT  ',' + CONCAT(LTRIM(RTRIM(rt2.transaccion)), '')
								  FROM rectrmae rt2, recrcmae rc2, emipomae e2
								 WHERE rc2.no_reclamo = rt2.no_reclamo
								   AND e2.no_poliza = rc2.no_poliza
								   AND rt2.cod_tipotran = '004'
								   AND rt2.actualizado = 1
								   AND rt2.anular_nt IS NULL
								   AND YEAR(rt2.fecha) = YEAR(GETDATE())
								   AND MONTH(rt2.fecha) = MONTH(GETDATE())
								   AND rt2.fecha >= '2025-01-01'
								   AND e2.no_poliza = e.no_poliza
								   AND rt2.no_reclamo = rt.no_reclamo
								FOR XML PATH('')
								), 1, 1, '') AS numerotransaciones,
					  COUNT(*) AS TransaccionesPorMes
				FROM cliclien c,
				emipomae e,
				recrcmae rc,
				rectrmae rt
				WHERE
				c.cod_cliente = e.cod_contratante
				AND e.no_poliza = rc.no_poliza
				AND rc.no_reclamo = rt.no_reclamo
				AND rt.cod_tipotran = '004'
				AND rt.actualizado = 1
				AND rt.anular_nt IS NULL
				AND YEAR(rt.fecha) = YEAR(GETDATE())
				AND MONTH(rt.fecha) = MONTH(GETDATE())
				AND rt.fecha >= '2025-01-01'
				AND NOT EXISTS (
				  SELECT t.transacciones FROM alertasdetalle t
				   WHERE t.id_metrica = @v_id_metrica
					AND t.cod_cliente = c.cod_cliente
					AND t.no_poliza =   e.no_poliza
					AND t.transacciones = rt.transaccion
				)
				GROUP BY c.cod_cliente, e.no_poliza, rt.no_reclamo
				HAVING COUNT(*) > @v_valor
			)


			INSERT INTO alertas (cod_cliente, no_poliza, transacciones, estatus, fecha, id_metrica,concepto)
			SELECT
				t.cod_cliente,
				t.no_poliza,
				t.numerotransaciones,
				'Por Revisión' AS estatus,
				@fecha_analisis,
				@v_id_metrica,
				'Transacciones'
				FROM TransaccionesPorMes t;

			INSERT INTO alertasdetalle (id_metrica, cod_cliente, no_poliza, transacciones, fecha)
			SELECT 
				t.id_metrica,
				t.cod_cliente, 
				t.no_poliza, 
				LTRIM(RTRIM(value)) as transacciones,  -- Elimina espacios en blanco
				t.fecha 
			FROM alertas t
			CROSS APPLY STRING_SPLIT(t.transacciones, ',')
			WHERE LTRIM(RTRIM(value)) != ''  -- Excluye valores vacíos
			  AND t.id_metrica = @v_id_metrica
				
        END
        

        -- 2. ALERTAS: 
		--    Tipologia : Pagos Directos a Beneficiarios Distintos al Asegurado
        --    Metrica   : Monto Pagado vs. Monto Asegurado
		--    Umbral    : Excede el monto asegurado por más del 10%
		ELSE IF @v_id_metrica = 2
        BEGIN    
            SET @v_valor = 1 + (@v_valor / 100);		
	        WITH Transaccionesexcedente AS (
				SELECT c.cod_cliente,
					   e.no_poliza,
					   e.suma_asegurada as suma_asegurada,
					   SUM(rt.monto) AS total_transacciones_pago,
					   ROUND((SUM(rt.monto) / e.suma_asegurada) * 100, 2) AS porcentaje_exceso,
					   ROUND(SUM(rt.monto) - (e.suma_asegurada * @v_valor), 2) AS exceso_sobre_110_porciento,
					   'Suma asegurada: ' + CAST(e.suma_asegurada AS VARCHAR(20)) + 
					   ', Total transacciones de pago: ' + CAST(SUM(rt.monto) AS VARCHAR(20)) + 
					   ', Exceso sobre 110%: ' + CAST(ROUND(SUM(rt.monto) - (e.suma_asegurada * @v_valor), 2) AS VARCHAR(20)) AS descripcion,
					   'Por Revisión' AS estatus,
					   CONVERT(varchar, GETDATE(), 23) AS fecha,
					   STUFF((
						   SELECT ',' +  LTRIM(RTRIM(rt2.transaccion)) + ''
						   FROM rectrmae rt2, recrcmae rc2
						   WHERE rc2.no_reclamo   = rt2.no_reclamo
							 AND rc2.no_poliza    = e.no_poliza
							 AND rt2.cod_tipotran = '004'
							 AND rt2.actualizado  = 1
							 AND rt2.anular_nt IS NULL
							 AND rt2.fecha >= '2025-01-01'
							 AND NOT EXISTS (
								 SELECT t.transacciones FROM alertasdetalle t
								 WHERE t.id_metrica = @v_id_metrica
								   AND t.cod_cliente = c.cod_cliente
								   AND t.no_poliza = e.no_poliza
								   AND t.transacciones = rt2.transaccion
								   
							 )
						   FOR XML PATH('')
					   ), 1, 1, '') AS numerotransaciones
				FROM emipomae e, cliclien c, recrcmae rc, rectrmae rt
				WHERE e.cod_contratante = c.cod_cliente
				  AND e.no_poliza = rc.no_poliza
				  AND rc.no_reclamo = rt.no_reclamo
				  AND rt.cod_tipotran = '004'
				  AND rt.actualizado = 1
				  AND rt.anular_nt IS NULL
				  AND e.suma_asegurada > 0  -- Evitar división por cero
				  AND rt.fecha >= '2025-01-01'
				  AND NOT EXISTS (
					  SELECT t.transacciones FROM alertasdetalle t
					  WHERE t.id_metrica = @v_id_metrica
						AND t.cod_cliente = c.cod_cliente
						AND t.no_poliza = e.no_poliza
						AND t.transacciones = rt.transaccion
				  )
				GROUP BY c.cod_cliente, e.no_poliza, e.suma_asegurada
				HAVING SUM(rt.monto) > (e.suma_asegurada * @v_valor)
           )

		   	INSERT INTO alertas (cod_cliente, no_poliza, transacciones, estatus, fecha, id_metrica,concepto)
			SELECT t.cod_cliente,t.no_poliza,t.numerotransaciones,t.estatus,@fecha_analisis,@v_id_metrica,'Transacciones' FROM Transaccionesexcedente t;

			INSERT INTO alertasdetalle (id_metrica, cod_cliente, no_poliza, transacciones, fecha)
			SELECT t.id_metrica,t.cod_cliente,t.no_poliza, 
				LTRIM(RTRIM(value)) as transacciones,  -- Elimina espacios en blanco
				t.fecha 
			FROM alertas t
			CROSS APPLY STRING_SPLIT(t.transacciones, ',')
			WHERE LTRIM(RTRIM(value)) != ''  -- Excluye valores vacíos
			AND t.id_metrica = @v_id_metrica
        END
		
        -- 3. ALERTAS: 
		--    Tipologia : Pagos Directos a Beneficiarios Distintos al Asegurado
        --    Metrica   : Monto Pagado vs. Prima Suscrita
		--    Umbral    : Más de 10 veces la prima suscrita
		ELSE IF @v_id_metrica = 3
        BEGIN 
            SET @v_valor = 1 + (@v_valor / 100);	 		
			WITH Transaccionesexcedenteprima AS (
				SELECT  e.no_poliza,
						c.cod_cliente,
						e.prima,
						SUM(rt.monto) AS total_pagos,
						(e.prima * @v_valor) AS prima_110_porciento,
						CASE 
							WHEN SUM(rt.monto) > (e.prima * @v_valor) THEN 'EXCEDE'
							ELSE 'NO EXCEDE'
						END AS validacion,
						ROUND(((SUM(rt.monto) / e.prima) * 100), 2) AS porcentaje_pagado,
						'Prima: ' + CAST(e.prima AS VARCHAR(20)) + 
						', Total pagos: ' + CAST(SUM(rt.monto) AS VARCHAR(20)) + 
						', EXCEDE' AS descripcion,
						'Por Revisión' AS estatus,
						CONVERT(varchar, GETDATE(), 23) AS fecha,
						@v_id_metrica AS id_metrica,
						STUFF((
							SELECT ',' +  LTRIM(RTRIM(rt2.transaccion)) + ''
							FROM rectrmae rt2, recrcmae rc2, emipouni eu2
							WHERE rc2.no_reclamo = rt2.no_reclamo
							  AND rc2.no_poliza = e.no_poliza
							  AND eu2.no_poliza = e.no_poliza
							  AND eu2.no_unidad = rc2.no_unidad
							  AND rt2.cod_tipotran = '004'
							  AND rt2.actualizado = 1
							  AND rt2.anular_nt IS NULL
							  AND rt2.fecha >= '2025-01-01'
							  AND NOT EXISTS (
								  SELECT t.transacciones FROM alertasdetalle t
								  WHERE t.id_metrica = @v_id_metrica
									AND t.cod_cliente = c.cod_cliente
									AND t.no_poliza = e.no_poliza
									AND t.transacciones = rt2.transaccion
							  )
							FOR XML PATH('')
						), 1, 1, '') AS numerotransaciones
				FROM emipomae e, cliclien c, emipouni eu, recrcmae rc, rectrmae rt
				WHERE 
					e.cod_contratante = c.cod_cliente
					AND e.no_poliza = eu.no_poliza
					AND e.no_poliza = rc.no_poliza 
					AND eu.no_unidad = rc.no_unidad
					AND rc.no_reclamo = rt.no_reclamo
					AND rt.cod_tipotran = '004'
					AND rt.actualizado = 1
					AND rt.anular_nt IS NULL
					AND rt.fecha >= '2025-01-01'
					AND e.prima > 0  -- Evitar división por cero
					AND NOT EXISTS (
					  SELECT t.transacciones FROM alertasdetalle t
					   WHERE t.id_metrica = @v_id_metrica
						AND t.cod_cliente = c.cod_cliente
						AND t.no_poliza = e.no_poliza
						AND t.transacciones = rt.transaccion
					)
				GROUP BY 
					e.no_poliza,
					c.cod_cliente,
					e.prima
				HAVING SUM(rt.monto) > (e.prima * @v_valor)

			)

			INSERT INTO alertas (cod_cliente, no_poliza, transacciones, estatus, fecha, id_metrica,concepto)
			SELECT t.cod_cliente,t.no_poliza,t.numerotransaciones,t.estatus,@fecha_analisis,@v_id_metrica,'Transacciones' FROM Transaccionesexcedenteprima t;

			INSERT INTO alertasdetalle (id_metrica, cod_cliente, no_poliza, transacciones, fecha)
			SELECT 
				t.id_metrica,
				t.cod_cliente, 
				t.no_poliza, 
				LTRIM(RTRIM(value)) as transacciones,  -- Elimina espacios en blanco
				t.fecha 
			FROM alertas t
			CROSS APPLY STRING_SPLIT(t.transacciones, ',')
			WHERE LTRIM(RTRIM(value)) != ''  -- Excluye valores vacíos
			  AND t.id_metrica = @v_id_metrica
        END

        -- 4. ALERTAS: 
		--    Tipologia : Beneficiarios Recurrentes
        --    Metrica   : Frecuencia de Pagos Recurrentes
		--    Umbral    : Más de 5 pagos en un trimestre
		ELSE IF @v_id_metrica = 4
        BEGIN      
			WITH TransaccionesPago AS (
				-- Obtener transacciones de pago válidas
			SELECT c.cod_cliente,
				   e.no_poliza,
				   e.prima as suma_asegurada,
				   COUNT(*) AS cantidad_pagos,
				   SUM(rt.monto) AS total_transacciones_pago,
				   CONVERT(varchar, GETDATE(), 23) AS fecha,
				   STUFF((
					   SELECT ',' +  LTRIM(RTRIM(rt2.transaccion)) + ''
					   FROM rectrmae rt2, recrcmae rc2
					   WHERE rc2.no_reclamo = rt2.no_reclamo
						 AND rc2.no_poliza = e.no_poliza
						 AND rt2.cod_tipotran = '004'
						 AND rt2.actualizado = 1
						 AND rt2.anular_nt IS NULL
						 AND rt2.monto > 0
						 AND rt2.fecha >= '2025-01-01'
						 AND YEAR(rt2.fecha) = YEAR(rt.fecha)
						 AND CASE 
							 WHEN MONTH(rt2.fecha) BETWEEN 1 AND 3 THEN 'Enero - Marzo'
							 WHEN MONTH(rt2.fecha) BETWEEN 4 AND 6 THEN 'Abril - Junio'
							 WHEN MONTH(rt2.fecha) BETWEEN 7 AND 9 THEN 'Julio - Septiembre'
							 WHEN MONTH(rt2.fecha) BETWEEN 10 AND 12 THEN 'Octubre - Diciembre'
						 END = CASE 
							 WHEN MONTH(rt.fecha) BETWEEN 1 AND 3 THEN 'Enero - Marzo'
							 WHEN MONTH(rt.fecha) BETWEEN 4 AND 6 THEN 'Abril - Junio'
							 WHEN MONTH(rt.fecha) BETWEEN 7 AND 9 THEN 'Julio - Septiembre'
							 WHEN MONTH(rt.fecha) BETWEEN 10 AND 12 THEN 'Octubre - Diciembre'
						 END
						 AND NOT EXISTS (
							 SELECT t.transacciones FROM alertasdetalle t
							 WHERE t.id_metrica = @v_id_metrica
							   AND t.cod_cliente = c.cod_cliente
							   AND t.no_poliza = e.no_poliza
							   AND t.transacciones = rt2.transaccion
						 )
					   FOR XML PATH('')
				   ), 1, 1, '') AS numerotransaciones,
				   -- Crear trimestre basado en fecha
				   YEAR(rt.fecha) AS año,
				   CASE 
					   WHEN MONTH(rt.fecha) BETWEEN 1 AND 3 THEN 'Enero - Marzo'
					   WHEN MONTH(rt.fecha) BETWEEN 4 AND 6 THEN 'Abril - Junio'
					   WHEN MONTH(rt.fecha) BETWEEN 7 AND 9 THEN 'Julio - Septiembre'
					   WHEN MONTH(rt.fecha) BETWEEN 10 AND 12 THEN 'Octubre - Diciembre'
				   END AS trimestre
			FROM emipomae e, cliclien c, recrcmae rc, rectrmae rt
			WHERE e.cod_contratante = c.cod_cliente
			  AND e.no_poliza = rc.no_poliza
			  AND rc.no_reclamo = rt.no_reclamo
			  AND rt.cod_tipotran = '004'
			  AND rt.actualizado = 1
			  AND rt.anular_nt IS NULL
			  AND e.prima > 0  -- Evitar división por cero
			  AND rt.monto > 0
			  AND rt.fecha >= '2025-01-01'
			  AND NOT EXISTS (
				  SELECT t.transacciones FROM alertasdetalle t
				  WHERE t.id_metrica = @v_id_metrica
					AND t.cod_cliente = c.cod_cliente
					AND t.no_poliza = e.no_poliza
					AND t.transacciones = rt.transaccion
			  )
			GROUP BY c.cod_cliente, e.no_poliza, e.prima, rt.fecha
			HAVING COUNT(*) > @v_valor
			)


			INSERT INTO alertas (cod_cliente, no_poliza, transacciones, estatus, fecha, id_metrica,concepto)
			SELECT t.cod_cliente,t.no_poliza,t.numerotransaciones,'Por Revisión',@fecha_analisis,@v_id_metrica,'Transacciones' FROM TransaccionesPago t;

			INSERT INTO alertasdetalle (id_metrica, cod_cliente, no_poliza, transacciones, fecha)
			SELECT 
				t.id_metrica,
				t.cod_cliente, 
				t.no_poliza, 
				LTRIM(RTRIM(value)) as transacciones,  -- Elimina espacios en blanco
				t.fecha 
			FROM alertas t
			CROSS APPLY STRING_SPLIT(t.transacciones, ',')
			WHERE LTRIM(RTRIM(value)) != ''  -- Excluye valores vacíos
			  AND t.id_metrica = @v_id_metrica
        END

        -- 5. ALERTAS: 
		--    Tipologia : Beneficiarios Recurrentes
        --    Metrica   : Intervalo de Tiempo entre Pagos
		--    Umbral    : Menor a 15 días
		ELSE IF @v_id_metrica = 5
        BEGIN      
			WITH TransaccionesPago AS (
				-- Obtener todas las transacciones de pago válidas con fecha anterior y siguiente
				SELECT c.cod_cliente,
					   e.no_poliza,
					   rt.no_reclamo,
					   (SELECT m.prima FROM emipomae m WHERE m.no_poliza = e.no_poliza AND m.cod_contratante = c.cod_cliente) AS PrimaSuscrita,
					   SUM(rt.monto) AS TransaccionesPagadas,
					   STUFF((
						   SELECT  ',' + LTRIM(RTRIM(rt2.transaccion)) + ''
						   FROM rectrmae rt2, recrcmae rc2
						   WHERE rc2.no_reclamo = rt2.no_reclamo
							 AND rc2.no_poliza = e.no_poliza
							 AND rt2.no_reclamo = rt.no_reclamo
							 AND rt2.fecha = rt.fecha
							 AND rt2.cod_tipotran = '004'
							 AND rt2.actualizado = 1
							 AND rt2.anular_nt IS NULL
							 AND rt2.fecha >= '2025-01-01'
							 AND NOT EXISTS (
								 SELECT t.transacciones FROM alertasdetalle t
								 WHERE t.id_metrica = @v_id_metrica
								   AND t.cod_cliente = c.cod_cliente
								   AND t.no_poliza = e.no_poliza
								   AND t.transacciones = rt2.transaccion
							 )
						   FOR XML PATH('')
					   ), 1, 1, '') AS numerotransaciones,
					   LAG(rt.fecha) OVER (
						   PARTITION BY c.cod_cliente, e.no_poliza, rt.no_reclamo
						   ORDER BY rt.fecha
					   ) as fecha_pago_anterior,
					   DATEDIFF(DAY, 
						   LAG(rt.fecha) OVER (
							   PARTITION BY c.cod_cliente, e.no_poliza, rt.no_reclamo
							   ORDER BY rt.fecha
						   ), 
						   rt.fecha
					   ) as dias_entre_pagos
				FROM cliclien c,
					 emipomae e,
					 recrcmae rc,
					 rectrmae rt
				WHERE c.cod_cliente = e.cod_contratante
				  AND e.no_poliza = rc.no_poliza
				  AND rc.no_reclamo = rt.no_reclamo
				  AND rt.cod_tipotran = '004'
				  AND rt.actualizado = 1
				  AND rt.anular_nt IS NULL
				  AND rt.fecha >= '2025-01-01'
				  AND NOT EXISTS (
					  SELECT t.transacciones FROM alertasdetalle t
					  WHERE t.id_metrica = @v_id_metrica
						AND t.cod_cliente = c.cod_cliente
						AND t.no_poliza = e.no_poliza
						AND t.transacciones = rt.transaccion
				  )
				GROUP BY c.cod_cliente, e.no_poliza, rt.no_reclamo, rt.fecha
				HAVING SUM(rt.monto) > 0
			),
			TransaccionesConIntervalo AS (
				-- Calcular intervalos entre transacciones
				SELECT * FROM TransaccionesPago WHERE dias_entre_pagos < @v_valor
			)


				INSERT INTO alertas (cod_cliente, no_poliza, transacciones, estatus, fecha, id_metrica,concepto)
				SELECT t.cod_cliente,t.no_poliza,t.numerotransaciones,'Por Revisión',@fecha_analisis,@v_id_metrica,'Transacciones' FROM TransaccionesConIntervalo t;

				INSERT INTO alertasdetalle (id_metrica, cod_cliente, no_poliza, transacciones, fecha)
				SELECT 
					t.id_metrica,
					t.cod_cliente, 
					t.no_poliza, 
					LTRIM(RTRIM(value)) as transacciones,  -- Elimina espacios en blanco
					t.fecha 
				FROM alertas t
				CROSS APPLY STRING_SPLIT(t.transacciones, ',')
				WHERE LTRIM(RTRIM(value)) != ''  -- Excluye valores vacíos
				  AND t.id_metrica = @v_id_metrica


        END

        -- 6. ALERTAS: 
		--    Tipologia : Montos Pagados
        --    Metrica   : Distribución de Montos Pagados
		--    Umbral    : Percentil superior al 95%
		ELSE IF @v_id_metrica = 6
        BEGIN      
			 WITH Percentil AS (
					SELECT emi.cod_contratante as cod_cliente,emi.no_poliza,rec.no_reclamo,est.MontoPercentil, SUM(trx.monto) as monto
					  FROM recrcmae rec,
						   rectrmae trx,
						   emipomae emi,
						   Tbl_EstadisticasReclamos est
					WHERE trx.no_reclamo = rec.no_reclamo
					  AND emi.no_poliza = rec.no_poliza
					  AND emi.cod_ramo = est.CodRamo
					  AND est.activo = 1
					  AND trx.cod_tipotran IN ('004','005','006','007')
					  AND trx.actualizado = 1
					  AND trx.fecha >= '2025-01-01'
					  AND NOT EXISTS (
							SELECT t.transacciones FROM alertasdetalle t
							 WHERE t.id_metrica = @v_id_metrica
							   AND t.cod_cliente = emi.cod_contratante
							   AND t.no_poliza = emi.no_poliza
							   AND t.transacciones = rec.no_reclamo

					        )
					GROUP BY emi.cod_contratante,emi.no_poliza,rec.no_reclamo,est.MontoPercentil
				    HAVING SUM(trx.monto) > est.MontoPercentil
			),
			PercentilDetalle AS (
					SELECT cod_cliente,no_poliza,
					    	STUFF((
							SELECT ',' + LTRIM(RTRIM(p2.no_reclamo))
					FROM Percentil p2
					WHERE p2.no_poliza = p1.no_poliza
					FOR XML PATH('')
					), 1, 1, '') AS no_reclamo
					FROM Percentil p1
					GROUP BY cod_cliente,no_poliza

			),
			  PercentilFinal AS (
					SELECT cod_cliente,no_poliza,no_reclamo
					  FROM PercentilDetalle c

			)


			INSERT INTO alertas (cod_cliente, no_poliza, transacciones, estatus, fecha, id_metrica,concepto)
			SELECT cod_cliente,no_poliza,no_reclamo,'Por Revisión',@fecha_analisis,@v_id_metrica,'Reclamos' FROM PercentilFinal;


			INSERT INTO alertasdetalle (id_metrica, cod_cliente, no_poliza, transacciones, fecha)
			SELECT t.id_metrica,t.cod_cliente,t.no_poliza,
			LTRIM(RTRIM(value)) as transacciones,  -- Elimina espacios en blanco
			t.fecha
			FROM alertas t
			CROSS APPLY STRING_SPLIT(t.transacciones, ',')
			WHERE LTRIM(RTRIM(value)) != ''  -- Excluye valores vacíos
			AND t.id_metrica = @v_id_metrica              
        END

        -- 7. ALERTAS: 
		--    Tipologia : Montos Pagados
        --    Metrica   : Valores Atípicos
		--    Umbral    : Más de 2 desviaciones estándar
		ELSE IF @v_id_metrica = 7
        BEGIN      
			 WITH Percentil AS (
					SELECT emi.cod_contratante as cod_cliente,emi.no_poliza,rec.no_reclamo,est.DesviacionEstandard, SUM(trx.monto) as monto
					FROM recrcmae rec,
						 rectrmae trx,
						 emipomae emi,
						 Tbl_EstadisticasReclamos est
					WHERE trx.no_reclamo = rec.no_reclamo
					  AND emi.no_poliza = rec.no_poliza
					  AND emi.cod_ramo = est.CodRamo
					  AND est.activo = 1
					  AND trx.cod_tipotran IN ('004','005','006','007')
					  AND trx.actualizado = 1
					  AND trx.fecha >= '2025-01-01'
					  AND NOT EXISTS (
							SELECT t.transacciones FROM alertasdetalle t
							 WHERE t.id_metrica = @v_id_metrica
							   AND t.cod_cliente = emi.cod_contratante
							   AND t.no_poliza = emi.no_poliza
							   AND t.transacciones = rec.no_reclamo

					        )
					GROUP BY emi.cod_contratante,emi.no_poliza,rec.no_reclamo,est.DesviacionEstandard
				    HAVING SUM(trx.monto) > est.DesviacionEstandard
			),
			PercentilDetalle AS (
					SELECT cod_cliente,no_poliza,
					    	STUFF((
							SELECT ',' + LTRIM(RTRIM(p2.no_reclamo))
					FROM Percentil p2
					WHERE p2.no_poliza = p1.no_poliza
					FOR XML PATH('')
					), 1, 1, '') AS no_reclamo
					FROM Percentil p1
					GROUP BY cod_cliente,no_poliza

			),
			  PercentilFinal AS (
					SELECT cod_cliente,no_poliza,no_reclamo
					  FROM PercentilDetalle c

			)


			INSERT INTO alertas (cod_cliente, no_poliza, transacciones, estatus, fecha, id_metrica,concepto)
			SELECT cod_cliente,no_poliza,no_reclamo,'Por Revisión',@fecha_analisis,@v_id_metrica,'Reclamos' FROM PercentilFinal;


			INSERT INTO alertasdetalle (id_metrica, cod_cliente, no_poliza, transacciones, fecha)
			SELECT t.id_metrica,t.cod_cliente,t.no_poliza,
			LTRIM(RTRIM(value)) as transacciones,  -- Elimina espacios en blanco
			t.fecha
			FROM alertas t
			CROSS APPLY STRING_SPLIT(t.transacciones, ',')
			WHERE LTRIM(RTRIM(value)) != ''  -- Excluye valores vacíos
			AND t.id_metrica = @v_id_metrica              
        END

        -- 8. ALERTAS: 
		--    Tipologia : Montos Pagados
        --    Metrica   : Relación entre Monto Pagado y Prima Suscrita
		--    Umbral    : Más de 15 veces la prima suscrita
		ELSE IF @v_id_metrica = 8
        BEGIN      
			WITH TransaccionesPrima AS (
				SELECT c.cod_cliente,
					   e.no_poliza,
					   e.prima AS PrimaSuscrita,
					   STUFF((
						   SELECT ',' +  LTRIM(RTRIM(rt2.transaccion)) + ''
						   FROM rectrmae rt2, recrcmae rc2
						   WHERE rc2.no_reclamo = rt2.no_reclamo
							 AND rc2.no_poliza = e.no_poliza
							 AND rt2.cod_tipotran = '004'
							 AND rt2.actualizado = 1
							 AND rt2.anular_nt IS NULL
							 AND rt2.fecha >= '2025-01-01'
							 AND NOT EXISTS (
								 SELECT t.transacciones FROM alertasdetalle t
								 WHERE t.id_metrica = @v_id_metrica
								   AND t.cod_cliente = c.cod_cliente
								   AND t.no_poliza = e.no_poliza
								   AND t.transacciones = rt2.transaccion
							 )
						   FOR XML PATH('')
					   ), 1, 1, '') AS numerotransaciones,
					   SUM(rt.monto) AS SumatoriaTransacciones,
					   (e.prima * @v_valor) AS LimitePermitido,
					   CASE 
						   WHEN SUM(rt.monto) > (e.prima * @v_valor) THEN 'SUPERA LIMITE'
						   ELSE 'DENTRO DEL LIMITE'
					   END AS Validacion
				FROM cliclien c, emipomae e, recrcmae rc, rectrmae rt
				WHERE c.cod_cliente = e.cod_contratante
				  AND e.no_poliza = rc.no_poliza
				  AND rc.no_reclamo = rt.no_reclamo
				  AND rt.cod_tipotran = '004'
				  AND rt.actualizado = 1
				  AND rt.anular_nt IS NULL
				  AND rt.fecha >= '2025-01-01'
				  AND NOT EXISTS (
					  SELECT t.transacciones FROM alertasdetalle t
					  WHERE t.id_metrica = @v_id_metrica
						AND t.cod_cliente = c.cod_cliente
						AND t.no_poliza = e.no_poliza
						AND t.transacciones = rt.transaccion
				  )
				GROUP BY 
					c.cod_cliente,
					e.no_poliza,
					e.prima
				HAVING SUM(rt.monto) > (e.prima * @v_valor)
			)

				INSERT INTO alertas (cod_cliente, no_poliza, transacciones, estatus, fecha, id_metrica,concepto)
				SELECT t.cod_cliente,t.no_poliza,t.numerotransaciones,'Por Revisión',@fecha_analisis,@v_id_metrica,'Transacciones' FROM TransaccionesPrima t;

				INSERT INTO alertasdetalle (id_metrica, cod_cliente, no_poliza, transacciones, fecha)
				SELECT t.id_metrica,t.cod_cliente,t.no_poliza, 
					LTRIM(RTRIM(value)) as transacciones,  -- Elimina espacios en blanco
					t.fecha 
				FROM alertas t
				CROSS APPLY STRING_SPLIT(t.transacciones, ',')
				WHERE LTRIM(RTRIM(value)) != ''  -- Excluye valores vacíos
				  AND t.id_metrica = @v_id_metrica
        END

        -- 9. ALERTAS: 
		--    Tipologia : Pérdidas Totales
        --    Metrica   : Frecuencia de Pérdidas Totales
		--    Umbral    : Más de 3 pérdidas totales en un año
		ELSE IF @v_id_metrica = 9
        BEGIN      
			WITH PerdidaTotal AS (
				SELECT 
					c.cod_cliente,
					--r.no_reclamo,r.
					--r.fecha_siniestro,
					STUFF((
						SELECT ',' +  LTRIM(RTRIM(r2.no_poliza)) + ''
						FROM recrcmae r2, emipomae e2
						WHERE e2.no_poliza = r2.no_poliza
						  AND e2.cod_contratante = c.cod_cliente
						  AND r2.perd_total = 1
						  AND r2.fecha_siniestro IS NOT NULL
						  AND YEAR(r2.fecha_siniestro) = YEAR(r.fecha_siniestro)
						  AND NOT EXISTS (
							  SELECT t.transacciones FROM alertasdetalle t
							  WHERE t.id_metrica = @v_id_metrica
								AND t.cod_cliente = c.cod_cliente
								AND t.no_poliza = YEAR(r2.fecha_siniestro)
								AND t.transacciones = e2.no_poliza
						  )
						FOR XML PATH('')
					), 1, 1, '') AS numeroPolizas,
					YEAR(r.fecha_siniestro) as ano_siniestro,
					COUNT(r.perd_total) AS TotalPerdidas
				FROM cliclien c, emipomae e, recrcmae r
				WHERE c.cod_cliente = e.cod_contratante
				  AND e.no_poliza = r.no_poliza
				  AND r.perd_total = 1  -- Solo reclamos marcados como pérdida total
				  AND r.fecha_siniestro IS NOT NULL
				  AND r.fecha_siniestro >= '2025-01-01'
				  AND NOT EXISTS (
					  SELECT t.transacciones FROM alertasdetalle t
					  WHERE t.id_metrica = @v_id_metrica
						AND t.cod_cliente = c.cod_cliente
						AND t.no_poliza = YEAR(r.fecha_siniestro)
						AND t.transacciones = e.no_poliza
				  )
				GROUP BY c.cod_cliente, YEAR(r.fecha_siniestro)
				HAVING COUNT(r.perd_total) > @v_valor
			)


			INSERT INTO alertas (cod_cliente, no_poliza, transacciones, estatus, fecha, id_metrica,concepto)
			SELECT t.cod_cliente,t.ano_siniestro,t.numeroPolizas,'Por Revisión',@fecha_analisis,@v_id_metrica,'Polizas' FROM PerdidaTotal t;

			INSERT INTO alertasdetalle (id_metrica, cod_cliente, no_poliza, transacciones, fecha)
			SELECT t.id_metrica,t.cod_cliente,t.no_poliza, 
				LTRIM(RTRIM(value)) as transacciones,  -- Elimina espacios en blanco
				t.fecha 
			FROM alertas t
			CROSS APPLY STRING_SPLIT(t.transacciones, ',')
			WHERE LTRIM(RTRIM(value)) != ''  -- Excluye valores vacíos
				AND t.id_metrica = @v_id_metrica
        END

        -- 10. ALERTAS: 
		--    Tipologia : Pérdidas Totales
        --    Metrica   : Monto de Pérdida Total vs. Monto Asegurado
		--    Umbral    : Excede el monto asegurado por más del 15%
		ELSE IF @v_id_metrica = 10
        BEGIN      
			 SET @v_valor = 1 + (@v_valor / 100);	

			WITH PerdidaTotalAsegurada AS (
				SELECT 
					c.cod_cliente,
					r.no_poliza,
					m.perdida,
					e.suma_asegurada AS suma_asegurada,
					r.fecha_siniestro,
					STUFF((
						SELECT ',' +  LTRIM(RTRIM(r2.no_poliza)) + ''
						FROM recrcmae r2, emipomae e2
						WHERE e2.no_poliza = r2.no_poliza
						  AND e2.cod_contratante = c.cod_cliente
						  AND r2.perd_total = 1
						  AND r2.fecha_siniestro IS NOT NULL
						  AND YEAR(r2.fecha_siniestro) = YEAR(r.fecha_siniestro)
						  AND NOT EXISTS (
							  SELECT t.transacciones FROM alertasdetalle t
							  WHERE t.id_metrica = @v_id_metrica
								AND t.cod_cliente = c.cod_cliente
								AND t.no_poliza = YEAR(r2.fecha_siniestro)
								AND t.transacciones = e2.no_poliza
						  )
						FOR XML PATH('')
					), 1, 1, '') AS numeroPolizas,
					YEAR(r.fecha_siniestro) as ano_siniestro,
					COUNT(r.perd_total) AS TotalPerdidas
				FROM cliclien c, emipomae e, recrcmae r, recperdida m
				WHERE c.cod_cliente = e.cod_contratante
				  AND e.no_poliza = r.no_poliza
				  AND r.no_reclamo = m.no_reclamo
				  AND r.no_poliza = m.no_poliza
				  AND r.perd_total = 1  -- Solo reclamos marcados como pérdida total
				  AND r.fecha_siniestro IS NOT NULL
				  AND r.fecha_siniestro >= '2025-01-01'
				  AND e.suma_asegurada > 0
				  AND m.perdida > 0
				  AND m.perdida > (e.suma_asegurada * @v_valor)
				  AND NOT EXISTS (
					  SELECT t.transacciones FROM alertasdetalle t
					  WHERE t.id_metrica = @v_id_metrica
						AND t.cod_cliente = c.cod_cliente
						AND t.no_poliza = r.no_poliza
						AND t.transacciones = e.no_poliza
				  )
				GROUP BY c.cod_cliente,r.no_poliza,m.perdida,e.suma_asegurada,r.fecha_siniestro
			)


			INSERT INTO alertas (cod_cliente, no_poliza, transacciones, estatus, fecha, id_metrica,concepto)
			SELECT t.cod_cliente,t.no_poliza,t.numeroPolizas,'Por Revisión',@fecha_analisis,@v_id_metrica,'Polizas' FROM PerdidaTotalAsegurada t;

			INSERT INTO alertasdetalle (id_metrica, cod_cliente, no_poliza, transacciones, fecha)
			SELECT t.id_metrica,t.cod_cliente,t.no_poliza, 
				LTRIM(RTRIM(value)) as transacciones,  -- Elimina espacios en blanco
				t.fecha 
			FROM alertas t
			CROSS APPLY STRING_SPLIT(t.transacciones, ',')
			WHERE LTRIM(RTRIM(value)) != ''  -- Excluye valores vacíos
				AND t.id_metrica = @v_id_metrica
        END

        -- 11. ALERTAS: 
		--    Tipologia : Pérdidas Totales
        --    Metrica   : Monto de Pérdida Total vs. Prima Suscrita
		--    Umbral    : Más de 20 veces la prima suscrita
        BEGIN      
			WITH PerdidaTotalPrima AS (
				SELECT 
					c.cod_cliente,
					r.no_poliza,
					m.perdida,
					e.prima,
					r.fecha_siniestro,
					STUFF((
						SELECT ',' +  LTRIM(RTRIM(r2.no_poliza)) + ''
						FROM recrcmae r2, emipomae e2
						WHERE e2.no_poliza = r2.no_poliza
						  AND e2.cod_contratante = c.cod_cliente
						  AND r2.perd_total = 1
						  AND r2.fecha_siniestro IS NOT NULL
						  AND YEAR(r2.fecha_siniestro) = YEAR(r.fecha_siniestro)
						  AND NOT EXISTS (
							  SELECT t.transacciones FROM alertasdetalle t
							  WHERE t.id_metrica = @v_id_metrica
								AND t.cod_cliente = c.cod_cliente
								AND t.no_poliza = YEAR(r2.fecha_siniestro)
								AND t.transacciones = e2.no_poliza
						  )
						FOR XML PATH('')
					), 1, 1, '') AS numeroPolizas,
					YEAR(r.fecha_siniestro) as ano_siniestro,
					COUNT(r.perd_total) AS TotalPerdidas
				FROM cliclien c, emipomae e, recrcmae r, recperdida m
				WHERE c.cod_cliente = e.cod_contratante
				  AND e.no_poliza = r.no_poliza
				  AND r.no_reclamo = m.no_reclamo
				  AND r.no_poliza = m.no_poliza
				  AND r.perd_total = 1  -- Solo reclamos marcados como pérdida total
				  AND r.fecha_siniestro IS NOT NULL
				  AND r.fecha_siniestro >= '2025-01-01'
				  AND e.prima > 0
				  AND m.perdida > 0
			      AND m.perdida > (e.prima * @v_valor)
				  AND NOT EXISTS (
					  SELECT t.transacciones FROM alertasdetalle t
					  WHERE t.id_metrica = @v_id_metrica
						AND t.cod_cliente = c.cod_cliente
						AND t.no_poliza = r.no_poliza
						AND t.transacciones = e.no_poliza
				  )
				GROUP BY c.cod_cliente,r.no_poliza,m.perdida,e.prima,r.fecha_siniestro
			)


			INSERT INTO alertas (cod_cliente, no_poliza, transacciones, estatus, fecha, id_metrica,concepto)
			SELECT t.cod_cliente,t.no_poliza,t.numeroPolizas,'Por Revisión',@fecha_analisis,@v_id_metrica,'Polizas' FROM PerdidaTotalPrima t;

			INSERT INTO alertasdetalle (id_metrica, cod_cliente, no_poliza, transacciones, fecha)
			SELECT t.id_metrica,t.cod_cliente,t.no_poliza, 
				LTRIM(RTRIM(value)) as transacciones,  -- Elimina espacios en blanco
				t.fecha 
			FROM alertas t
			CROSS APPLY STRING_SPLIT(t.transacciones, ',')
			WHERE LTRIM(RTRIM(value)) != ''  -- Excluye valores vacíos
				AND t.id_metrica = @v_id_metrica
        END

    END;

    CLOSE cur_alertas;
    DEALLOCATE cur_alertas;


    -- Mostrar resultados
	 SELECT a.id,
		 m.id_metrica,
		t.nombre AS tipologia,
		m.nombre AS metrica,
		m.umbral,
		a.cod_cliente,
		a.no_poliza,
		a.concepto,
		a.transacciones,
		a.estatus,
		a.fecha
	FROM alertas a, 
		 metrica m,
		 tipologia t
	WHERE a.id_metrica = m.id_metrica
	   AND m.id_tipologia = t.id_tipologia
	   AND a.fecha = @fecha_analisis
	 ORDER BY m.id_metrica;

END;