-- Procedimiento para consultar pólizas con descuento de pronto pago
-- Creado    : 05/08/2009 - Autor: Roberto Silvera
-- SIS v.2.0 - DEIVID, S.A.

drop procedure sp_pro858;
create procedure "informix".sp_pro858(a_periodo char(7))
returning 	char(20), 	
			char(255), 	
			date,		
			dec(16,2),  
			char(3),
			char(7),
			dec(16,2),
			date,
			date;

define	v_nombre		char(255);
define	v_no_doc		char(20);
define	v_no_poliza		char(10);
define	v_grupo			char(5);
define	v_cod_formapag	char(3);
define	v_cod_ramo		char(3);
define	v_prima_bruta	dec(16,2);
define	v_prima_modu	dec(16,2);
define	v_saldo_endp	dec(16,2);
define  v_saldo_end		dec(16,2);
define	v_saldo_doc		dec(16,2);
define	v_saldo			dec(16,2);
define	v_zona_libre	smallint;
define  v_existe_end	smallint;
define	v_flag_flota	smallint;
define	v_flag_modu		smallint;
define	v_cant_pag		smallint;
define	v_fecha			smallint;
define 	v_soda			smallint;
define	v_fecha_susc	date;
define	v_v_inicial		date;
define	v_fech_ult		date;
define	v_v_final		date;

BEGIN
	FOREACH
		SELECT e.no_poliza,
			   e.cod_ramo,
			   e.prima_bruta,
			   e.cod_formapag,
			   e.fecha_suscripcion,
			   e.no_documento,
			   c.nombre,
			   e.cod_grupo,
			   e.vigencia_inic,
			   e.vigencia_final
		  INTO v_no_poliza,
			   v_cod_ramo,
			   v_prima_bruta,
			   v_cod_formapag,
			   v_fecha_susc,
			   v_no_doc,
			   v_nombre,
			   v_grupo,
			   v_v_inicial,
			   v_v_final
		  FROM emipomae e, cliclien c
		 WHERE e.cod_contratante = c.cod_cliente
		   AND e.cod_ramo not in ("004", "008", "016", "018", "019", "020")
		   AND e.prima_bruta > 100
		   AND e.estatus_poliza = 1
		   AND e.actualizado = 1
		   AND e.serie > 2008
				--AND e.periodo = a_periodo

		LET v_existe_end 	= 0;
		LET v_zona_libre 	= 0;
		LET v_soda			= 0;

			--VERIFICA SI ES UNA FLOTA
		LET v_flag_flota = 0;

		SELECT COUNT(*)
		  INTO v_flag_flota
		  FROM emipouni
		 WHERE emipouni.no_poliza =  v_no_poliza;

		IF v_flag_flota > 1 THEN
			CONTINUE FOREACH;
		END IF

		--VERIFICA SI YA SE LE HIZO EL DESCUENTO A LA PÓLIZA
		SELECT count(*)
		  INTO v_existe_end
		  FROM endedmae
		 WHERE no_poliza = v_no_poliza
		   AND cod_endomov = "024";

		IF v_existe_end > 0 THEN
			CONTINUE FOREACH;
		END IF

		--VERIFICA SI LA POLIZA TIENE DESCUENTO POR MODIFCACION DE UNIDAD EN POLIZAS VIGENTES(2)
		SELECT d.prima_bruta  
		  INTO v_saldo_endp
		  FROM endedmae d, emipomae e
		 WHERE d.no_poliza = e.no_poliza
		   AND d.no_poliza = v_no_poliza
		   AND d.no_endoso = "00000"
		   AND e.estatus_poliza = 1
		   AND e.actualizado = 1;

		LET v_flag_modu = 0;

		FOREACH
			SELECT e.prima_bruta
			  INTO v_saldo_end
			  FROM endedmae d, emipomae e
			 WHERE e.no_poliza = e.no_poliza
			   AND e.no_documento = v_no_doc
			   AND e.no_endoso = "00000"
			   AND e.estatus_poliza = 1
			   AND e.actualizado = 1

			FOREACH
				SELECT d.prima_bruta
				  INTO v_prima_modu
				  FROM endedmae d, emipomae e
				 WHERE d.no_poliza = e.no_poliza
				   AND d.no_documento = v_no_doc
				   AND d.cod_endomov = "006"
				   AND e.estatus_poliza = 1
				   AND e.actualizado = 1

				IF v_grupo <> "00967" THEN --GRUPO FELIX B MADURO
					IF v_prima_modu < 0 THEN
						IF ABS(v_prima_modu) <= (ROUND((v_saldo_end * 0.05),2) + 0.02) 
						OR ABS(v_prima_modu) >= (ROUND((v_saldo_end * 0.05),2) - 0.02)
						OR ABS(v_prima_modu) = ROUND((v_saldo_end * 0.05),2) THEN
							LET v_flag_modu = 1;
							EXIT FOREACH;
						END IF
					END IF
				ELSE
					IF v_prima_modu < 0 THEN
						IF ABS(v_prima_modu) <= (ROUND((v_saldo_end * 0.07),2) + 0.02) 
						OR ABS(v_prima_modu) >= (ROUND((v_saldo_end * 0.07),2) - 0.02)
						OR ABS(v_prima_modu) = ROUND((v_saldo_end * 0.07),2) THEN
							LET v_flag_modu = 1;
							EXIT FOREACH;
						END IF
					END IF
				END IF

				IF v_flag_modu = 1 THEN
					LET v_flag_modu = 1;
					EXIT FOREACH;
				END IF
			END FOREACH
		END FOREACH
		
		IF v_flag_modu = 1 THEN
			CONTINUE FOREACH;
		END IF

			--VERIFICA SI SON POLIZAS SODA
			LET v_soda = sp_pro861(v_no_poliza);

			IF v_soda = 1 THEN
				CONTINUE FOREACH;
			END IF

			--UNIDADES CON MANZANA EN ZONA LIBRE NO APLICAN
			LET v_zona_libre = sp_pro857(v_no_poliza);

			IF v_zona_libre = 1 THEN
				CONTINUE FOREACH;
			END IF

			{--VERIFICA EL SALDO DE LA PÓLIZA
			LET v_saldo = sp_cob115c("", "",v_no_doc,"");

			IF v_saldo <= 0 THEN
				CONTINUE FOREACH;
			END IF}

			--FORMA DE PAGO ELECTRONICA
			IF v_cod_formapag = "003" OR v_cod_formapag = "005" THEN

				--No. PAGOS REALIZADOS
				LET v_cant_pag = 0;

				SELECT COUNT(*)
				  INTO v_cant_pag
				  FROM cobredet d, cobremae m, emipomae e
				 WHERE d.actualizado  = 1
					AND d.cod_compania = '001'
					AND d.no_poliza    =  v_no_poliza
					AND d.tipo_mov     IN ('P','N')
					AND d.no_remesa    = m.no_remesa
					AND m.tipo_remesa  IN ('A', 'M', 'C')
					AND d.no_poliza = e.no_poliza 
					AND m.fecha >= e.vigencia_inic ;

				IF v_cant_pag > 2 THEN

					IF v_grupo <> "00967" THEN --GRUPO FELIX B MADURO

						IF v_saldo = ROUND((v_saldo_endp * 0.05),2) THEN --EL SALDO TIENE QUE SER EL 5% DE LA PRIMA
							RETURN v_no_doc,
									v_nombre,
									v_fecha_susc,
									v_saldo_end,
									v_cod_formapag,
									a_periodo,
									v_saldo,
									v_v_inicial,
									v_v_final
									WITH RESUME;
						END IF
					ELSE
						IF v_saldo = ROUND((v_saldo_endp * 0.07),2) THEN
							RETURN v_no_doc,
									v_nombre,
									v_fecha_susc,
									v_saldo_end,
									v_cod_formapag,
									a_periodo,
									v_saldo,
									v_v_inicial,
									v_v_final
									WITH RESUME;
						END IF
					END IF
				END IF
			ELSE

				IF v_grupo <> "00967" THEN --GRUPO FELIX B MADURO

					IF v_saldo = ROUND((v_saldo_endp * 0.05),2) THEN --EL SALDO TIENE QUE SER EL 5% DE LA PRIMA

						--FECHA DE ULTIMO PAGO
						SELECT MAX(m.fecha)
						  INTO v_fech_ult
						  FROM cobredet d,
							   cobremae m
						 WHERE d.actualizado  = 1
							AND d.cod_compania = '001'
							AND d.no_poliza    =  v_no_poliza
							AND d.tipo_mov     IN ('P','N')
							AND d.no_remesa    = m.no_remesa
							AND m.tipo_remesa  IN ('A', 'M', 'C');

						--POLIZAS MENOS DE 30 DIAS
						IF (v_fech_ult - v_fecha_susc) <= 30 THEN
							RETURN v_no_doc,
								v_nombre,
								v_fecha_susc,
								v_saldo_end,
								v_cod_formapag,
								a_periodo,
								v_saldo,
								v_v_inicial,
								v_v_final
								WITH RESUME;
						END IF

					END IF

				ELSE

					IF v_saldo = ROUND((v_saldo_endp * 0.07),2) THEN

						--FECHA DE ULTIMO PAGO
						SELECT MAX(m.fecha)
						  INTO v_fech_ult
						  FROM cobredet d,
							   cobremae m
						 WHERE d.actualizado  = 1
							AND d.cod_compania = '001'
							AND d.no_poliza    =  v_no_poliza
							AND d.tipo_mov     IN ('P','N')
							AND d.no_remesa    = m.no_remesa
							AND m.tipo_remesa  IN ('A', 'M', 'C');

						--POLIZAS MENOS DE 30 DIAS
						IF (v_fech_ult - v_fecha_susc) <= 30 THEN
							RETURN v_no_doc,
								v_nombre,
								v_fecha_susc,
								v_saldo_end,
								v_cod_formapag,
								a_periodo,
								v_saldo,
								v_v_inicial,
								v_v_final
								WITH RESUME;
						END IF

					END IF

				END IF

			END IF

END FOREACH
END

END PROCEDURE
