-- Procedimiento que Actualiza el Endoso

-- Creado    : 20/10/2000 - Autor: Demetrio Hurtado Almanza 
-- Modificado: 28/05/2001 - Autor: Demetrio Hurtado Almanza

-- SIS v.2.0 - DEIVID, S.A.

--DROP PROCEDURE sp_pro43_nuevo;			

CREATE PROCEDURE sp_pro43_nuevo(
a_no_poliza		CHAR(10), 
a_no_endoso		CHAR(5)
) RETURNING SMALLINT,
		    CHAR(100);

DEFINE _mensaje         CHAR(100);
DEFINE _cod_compania	CHAR(3);
DEFINE _cod_sucursal	CHAR(3);
DEFINE _cod_endomov		CHAR(3);
DEFINE _tipo_mov		SMALLINT;
DEFINE _periodo_par     CHAR(7);
DEFINE _periodo_end     CHAR(7);
DEFINE _cod_tipocan     CHAR(3);
DEFINE _vigencia_inic   DATE;
DEFINE _vigencia_final	DATE;
DEFINE _prima_bruta     DEC(16,2);
DEFINE _impuesto        DEC(16,2);
DEFINE _prima_neta      DEC(16,2);
DEFINE _descuento       DEC(16,2);
DEFINE _recargo         DEC(16,2);
DEFINE _prima           DEC(16,2);
DEFINE _prima_suscrita  DEC(16,2);
DEFINE _prima_retenida  DEC(16,2);
DEFINE _no_fac_orig     CHAR(10);
DEFINE _error			SMALLINT;

BEGIN

ON EXCEPTION SET _error 
 	RETURN _error, 'Error al Actualizar el Endoso ...';         
END EXCEPTION           

-- Lectura de la Tabla de Endosos

--SET DEBUG FILE TO "\\NEMESIS\Ancon\Store Procedures\Debug\sp_pro43.trc";
--trace on;

LET _no_fac_orig = NULL;

SELECT cod_compania,
	   cod_sucursal,
	   cod_endomov,
	   periodo,
	   vigencia_inic,
	   vigencia_final,
	   cod_tipocan,
	   prima_bruta,
	   impuesto,
	   prima_neta,
	   descuento,
	   recargo,
	   prima,
	   prima_suscrita,
	   prima_retenida,
	   no_factura
  INTO _cod_compania,
	   _cod_sucursal,
	   _cod_endomov,
	   _periodo_end,
	   _vigencia_inic,
	   _vigencia_final,	
	   _cod_tipocan,
	   _prima_bruta,	
	   _impuesto,
	   _prima_neta,
	   _descuento,
	   _recargo,
	   _prima,
	   _prima_suscrita,
	   _prima_retenida,
	   _no_fac_orig
  FROM endedmae
 WHERE no_poliza   = a_no_poliza
   AND no_endoso   = a_no_endoso
   AND actualizado = 0;

IF _cod_compania IS NULL THEN
	LET _mensaje = 'Este Endoso Ya Fue Actualizado, Por Favor Verifique ...';
	RETURN 1, _mensaje;
END IF

-- Seleccion del Periodo Contable

SELECT emi_periodo
  INTO _periodo_par
  FROM parparam
 WHERE cod_compania = _cod_compania;

IF _periodo_end < _periodo_par THEN
	LET _mensaje = 'No Puede Actualizar un Endoso para Un Periodo Cerrado, Por Favor Verifique ...';
	RETURN 1, _mensaje;
END IF

-- Seleccion del Tipo de Movimiento del Endoso

SELECT tipo_mov
  INTO _tipo_mov
  FROM endtimov
 WHERE cod_endomov = _cod_endomov; 	

IF _tipo_mov = 1 THEN -- Aumento de Vigencia 	

	UPDATE emipomae
	   SET vigencia_final = _vigencia_final
	 WHERE no_poliza      = a_no_poliza;

ELIF _tipo_mov = 20 THEN    -- Cancelacion Por Saldo 
	
	BEGIN

		DEFINE _accion SMALLINT;

		SELECT accion
		  INTO _accion
		  FROM endtican
		 WHERE cod_tipocan = _cod_tipocan;

		UPDATE emipomae
		   SET estatus_poliza    = _accion,
			   fecha_cancelacion = CURRENT
		 WHERE no_poliza         = a_no_poliza;
	END 

ELIF _tipo_mov = 2 THEN		-- Cancelacion
	
	BEGIN

		DEFINE _accion SMALLINT;

		SELECT accion
		  INTO _accion
		  FROM endtican
		 WHERE cod_tipocan = _cod_tipocan;

		UPDATE emipomae
		   SET estatus_poliza    = _accion,
			   fecha_cancelacion = CURRENT
		 WHERE no_poliza         = a_no_poliza;
	
	END 

ELIF _tipo_mov = 3 THEN		-- Rehabilitacion

	BEGIN

		DEFINE _vigen_fin_poliza DATE;
		DEFINE _accion           SMALLINT;

		SELECT vigencia_final
		  INTO _vigen_fin_poliza
		  FROM emipomae
		 WHERE no_poliza = a_no_poliza;

		IF _vigen_fin_poliza < CURRENT THEN
			LET _accion = 3;
		ELSE
			LET _accion = 1;
		END IF
	
		UPDATE emipomae
		   SET estatus_poliza    = _accion,
			   fecha_cancelacion = NULL
		 WHERE no_poliza         = a_no_poliza;
	
	END

ELIF _tipo_mov = 4 THEN		-- Inclusion de Unidades

	BEGIN

		DEFINE _null           CHAR(1);      
		DEFINE _suma_asegurada DECIMAL(16,2);
		DEFINE _no_unidad      CHAR(5);      
		DEFINE _cod_cober_reas CHAR(3);      
		DEFINE _no_cambio      SMALLINT;

		LET _null      = NULL;
		LET _no_cambio = 0;

		-- Insercion de Unidades

		INSERT INTO emipouni(
	    no_poliza,
	    no_unidad,
	    cod_ruta,
	    cod_producto,
	    cod_asegurado,
	    suma_asegurada,
	    prima,
	    descuento,
	    recargo,
	    prima_neta,
	    impuesto,
	    prima_bruta,
	    reasegurada,
	    vigencia_inic,
	    vigencia_final,
	    beneficio_max,
	    desc_unidad,
	    activo,
	    prima_asegurado,
	    prima_total,
	    no_activo_desde,
	    facturado,
	    user_no_activo,
	    perd_total,
	    impreso,
	    fecha_emision,
	    prima_suscrita,
	    prima_retenida
		)
		SELECT no_poliza,
			   no_unidad,
			   cod_ruta,
			   cod_producto,
			   cod_cliente,
			   suma_asegurada,
			   prima,
			   descuento,
			   recargo,
			   prima_neta,
			   impuesto,
			   prima_bruta,
			   reasegurada,
			   vigencia_inic,
			   vigencia_final,
			   beneficio_max,
			   desc_unidad,
			   1,
			   0,
			   0,
			   _null,
			   1,
			   _null,
			   0,
			   1,
			   CURRENT,
			   prima_suscrita,
			   prima_retenida
		  FROM endeduni
	 	 WHERE no_poliza = a_no_poliza
	 	   AND no_endoso = a_no_endoso;

		-- Autos por Unidad

		INSERT INTO emiauto(
	    no_poliza,
	    no_unidad,
	    cod_tipoveh,
	    no_motor,
	    uso_auto,
	    ano_tarifa
		)
		SELECT no_poliza,
			   no_unidad,
			   cod_tipoveh,
			   no_motor,
			   uso_auto,
			   ano_tarifa
		  FROM endmoaut
		 WHERE no_poliza = a_no_poliza
		   AND no_endoso = a_no_endoso;		

		-- Descripcion por Unidad

		INSERT INTO emipode2(
	    no_poliza,
	    no_unidad,
	    descripcion
		)
		SELECT no_poliza,
			   no_unidad,
			   descripcion
		  FROM endedde2
		 WHERE no_poliza = a_no_poliza
		   AND no_endoso = a_no_endoso;		

		-- Descuentos por Unidad

		INSERT INTO emiunide(
	    no_poliza,
	    no_unidad,
	    cod_descuen,
	    porc_descuento
		)
		SELECT no_poliza,
			   no_unidad,
			   cod_descuen,
			   porc_descuento
		  FROM endunide
		 WHERE no_poliza = a_no_poliza
		   AND no_endoso = a_no_endoso;		
		
		-- Recargos por Unidad

		INSERT INTO emiunire(
	    no_poliza,
	    no_unidad,
	    cod_recargo,
	    porc_recargo
		)
		SELECT no_poliza,
			   no_unidad,
			   cod_recargo,
			   porc_recargo
		  FROM endunire
		 WHERE no_poliza = a_no_poliza
		   AND no_endoso = a_no_endoso;		

		-- Insercion de Acreedores

		INSERT INTO emipoacr(
		no_poliza,
		no_unidad, 
		cod_acreedor,
		limite
		)
		SELECT no_poliza,
			   no_unidad,
			   cod_acreedor,
			   limite
	 	  FROM endedacr
	 	 WHERE no_poliza = a_no_poliza
	 	   AND no_endoso = a_no_endoso;

		-- Insercion de Coberturas

		INSERT INTO emipocob(
	    no_poliza,
	    no_unidad,
	    cod_cobertura,
	    orden,
	    tarifa,
	    deducible,
	    limite_1,
	    limite_2,
	    prima_anual,
	    prima,
	    descuento,
	    recargo,
	    prima_neta,
	    date_added,
	    date_changed,
	    factor_vigencia,
	    desc_limite1,
	    desc_limite2
		)
		SELECT no_poliza,
			   no_unidad,
			   cod_cobertura,
			   orden,
			   tarifa,
			   deducible,
			   limite_1,
			   limite_2,
			   prima_anual,
			   prima,
			   descuento,
			   recargo,
			   prima_neta,
			   date_added,
			   date_changed,
			   factor_vigencia,
			   desc_limite1,
			   desc_limite2
		  FROM endedcob
		 WHERE no_poliza = a_no_poliza
		   AND no_endoso = a_no_endoso;		

		-- Descuentos por Cobertura

		INSERT INTO emicobde(
	    no_poliza,
	    no_unidad,
	    cod_cobertura,
	    cod_descuen,
	    porc_descuento
		)
		SELECT no_poliza,
			   no_unidad,
			   cod_cobertura,
			   cod_descuen,
			   porc_descuento
		  FROM endcobde
		 WHERE no_poliza = a_no_poliza
		   AND no_endoso = a_no_endoso;		
		
		-- Recargos por Cobertura

		INSERT INTO emicobre(
	    no_poliza,
	    no_unidad,
	    cod_cobertura,
	    cod_recargo,
	    porc_recargo
		)
		SELECT no_poliza,
			   no_unidad,
			   cod_cobertura,
			   cod_recargo,
			   porc_recargo
		  FROM endcobre
		 WHERE no_poliza = a_no_poliza
		   AND no_endoso = a_no_endoso;		

		-- Historico de Reaseguro Individual

		FOREACH
		 SELECT	no_unidad,
		        cod_cober_reas
		   INTO	_no_unidad,
		        _cod_cober_reas
		   FROM	emifacon
		  WHERE	no_poliza = a_no_poliza
		    AND no_endoso = a_no_endoso
		  GROUP BY no_unidad, cod_cober_reas

			INSERT INTO emireama(
			no_poliza,
			no_unidad,
			no_cambio,
			cod_cober_reas,
			vigencia_inic,
			vigencia_final
			)
			VALUES(
			a_no_poliza, 
			_no_unidad,
			_no_cambio,
			_cod_cober_reas,
			_vigencia_inic,
			_vigencia_final
			);

		END FOREACH

		INSERT INTO emireaco(
		no_poliza,
		no_unidad,
		no_cambio,
		cod_cober_reas,
		orden,
		cod_contrato,
		porc_partic_suma,
		porc_partic_prima
		)
		SELECT 
		a_no_poliza, 
		no_unidad,
		_no_cambio,
		cod_cober_reas,
		orden,
		cod_contrato,
		porc_partic_suma,
		porc_partic_prima
		FROM emifacon
		WHERE no_poliza = a_no_poliza
		  AND no_endoso = a_no_endoso;

		INSERT INTO emireafa(
		no_poliza,
		no_unidad,
		no_cambio,
		cod_cober_reas,
		orden,
		cod_contrato,
		cod_coasegur,
		porc_partic_reas,
		porc_comis_fac,
		porc_impuesto
		)
		SELECT 
		a_no_poliza, 
		no_unidad,
		_no_cambio,
		cod_cober_reas,
		orden,
		cod_contrato,
		cod_coasegur,
		porc_partic_reas,
		porc_comis_fac,
		porc_impuesto
		FROM emifafac
		WHERE no_poliza = a_no_poliza
		  AND no_endoso = a_no_endoso;

	SELECT SUM(suma_asegurada)
		  INTO _suma_asegurada
		  FROM emipouni
		 WHERE no_poliza = a_no_poliza;

		UPDATE emipomae
		   SET suma_asegurada = _suma_asegurada
		 WHERE no_poliza = a_no_poliza;

	END 

ELIF _tipo_mov = 5 THEN		-- Eliminacion de Unidades

	BEGIN

		DEFINE _no_unidad      CHAR(5);
		DEFINE _suma_asegurada DECIMAL(16,2);

		FOREACH 
		 SELECT	no_unidad
		   INTO	_no_unidad
		   FROM	endeduni
		  WHERE no_poliza = a_no_poliza
		    AND no_endoso = a_no_endoso

			-- Insertar en endmoaut

			INSERT INTO endmoaut(
		    no_poliza,
			no_endoso,
		    no_unidad,
		    cod_tipoveh,
		    no_motor,
		    uso_auto,
		    ano_tarifa
			)
			SELECT no_poliza,
				   a_no_endoso,	
				   no_unidad,
				   cod_tipoveh,
				   no_motor,
				   uso_auto,
				   ano_tarifa
			  FROM emiauto
			 WHERE no_poliza = a_no_poliza
			   AND no_unidad = _no_unidad;		

			-- Borrar Unidades

			DELETE FROM emipouni
			 WHERE no_poliza = a_no_poliza
			   AND no_unidad = _no_unidad;

		END FOREACH

	    SELECT SUM(suma_asegurada)
		  INTO _suma_asegurada
		  FROM emipouni
		 WHERE no_poliza = a_no_poliza;

		UPDATE emipomae
		   SET suma_asegurada = _suma_asegurada
		 WHERE no_poliza = a_no_poliza;

	END 

ELIF _tipo_mov = 6 THEN		-- Modicicacion de Unidades

	BEGIN

		DEFINE _no_unidad      CHAR(5);      
		DEFINE r_cant          SMALLINT;     
		DEFINE _suma_asegurada DECIMAL(16,2);
		DEFINE _prima          DECIMAL(16,2);
		DEFINE _prima_anual    DECIMAL(16,2);
		DEFINE _prima_neta     DECIMAL(16,2);
		DEFINE _descuento      DECIMAL(16,2);
		DEFINE _recargo        DECIMAL(16,2);
		DEFINE _impuesto       DECIMAL(16,2);
		DEFINE _prima_bruta    DECIMAL(16,2);
		DEFINE _limite_1       DECIMAL(16,2);
		DEFINE _limite_2       DECIMAL(16,2);
		DEFINE _deducible      CHAR(50);     
		DEFINE _cod_cobertura  CHAR(5);      

		FOREACH 
		 SELECT	no_unidad, 
		 		suma_asegurada, 
		 		prima, 
		 		prima_neta, 
		 		descuento, 
		 		recargo, 
		 		impuesto, 
		 		prima_bruta
		   INTO	_no_unidad, 
		   		_suma_asegurada, 
		   		_prima, 
		   		_prima_neta, 
		   		_descuento, 
		   		_recargo, 
		   		_impuesto, 
		   		_prima_bruta
		   FROM	endeduni
		  WHERE no_poliza = a_no_poliza
		    AND no_endoso = a_no_endoso

			-- Actualizar Unidades

			UPDATE emipouni
			   SET suma_asegurada = suma_asegurada + _suma_asegurada,
			       prima          = prima          + _prima,
			       prima_neta     = prima_neta     + _prima_neta,
			       descuento      = descuento      + _descuento,
			       recargo        = recargo        + _recargo,
			       impuesto       = impuesto       + _impuesto,
			       prima_bruta    = prima_bruta    + _prima_bruta
			 WHERE no_poliza      = a_no_poliza
			   AND no_unidad      = _no_unidad;

			-- Actualizar Coberturas

			FOREACH 
			 SELECT	cod_cobertura, 
			 		prima, 
			 		prima_anual, 
			 		prima_neta, 
			 		descuento, 
			 		recargo, 
			 		limite_1, 
			 		limite_2, 
			 		deducible
			   INTO _cod_cobertura, 
			   		_prima, 
			   		_prima_anual, 
			   		_prima_neta, 
			   		_descuento, 
			   		_recargo, 
			   		_limite_1, 
			   		_limite_2, 
			   		_deducible
			   FROM	endedcob
			  WHERE no_poliza = a_no_poliza
			    AND no_endoso = a_no_endoso
			    AND no_unidad = _no_unidad

				LET r_cant = 0;

				SELECT COUNT(*) 
				  INTO r_cant 
				  FROM emipocob
				 WHERE no_poliza     = a_no_poliza
				   AND no_unidad     = _no_unidad
				   AND cod_cobertura = _cod_cobertura;

				IF r_cant = 0 THEN

				   INSERT INTO emipocob(
				   no_poliza,
				   no_unidad,
				   cod_cobertura,
				   orden,
				   tarifa,
				   deducible,
				   limite_1,
				   limite_2,
				   prima_anual,
				   prima,
				   descuento,
				   recargo,
				   prima_neta,
				   date_added,
				   date_changed,
				   factor_vigencia,
				   desc_limite1,
				   desc_limite2 )
				   SELECT no_poliza,
						  no_unidad,
						  cod_cobertura,
						  orden,
						  tarifa,
						  deducible,
						  limite_1,
						  limite_2,
						  prima_anual,
						  prima,
						  descuento,
						  recargo,
						  prima_neta,
						  date_added,
						  date_changed,
						  factor_vigencia,
						  desc_limite1,
					      desc_limite2
					 FROM endedcob
				    WHERE no_poliza     = a_no_poliza
				      AND no_endoso     = a_no_endoso
				      AND no_unidad     = _no_unidad
				      AND cod_cobertura = _cod_cobertura;
				ELSE

				   UPDATE emipocob
				      SET prima         = prima       + _prima,
				          prima_anual   = prima_anual + _prima_anual,
				          prima_neta    = prima_neta  + _prima_neta,
				          descuento     = descuento   + _descuento,
				          recargo	    = recargo     + _recargo,
				          limite_1	    = limite_1    + _limite_1,
				          limite_2	    = limite_2    + _limite_2,
				          deducible     = _deducible
				    WHERE no_poliza     = a_no_poliza
				      AND no_unidad     = _no_unidad
				      AND cod_cobertura = _cod_cobertura;

				END IF

			END FOREACH

		END FOREACH

		SELECT SUM(suma_asegurada)
		  INTO _suma_asegurada
		  FROM endeduni
		 WHERE no_poliza = a_no_poliza
		   AND no_endoso = a_no_endoso;

		UPDATE emipomae
		   SET suma_asegurada = suma_asegurada + _suma_asegurada
		 WHERE no_poliza      = a_no_poliza;
	END 

ELIF _tipo_mov = 9 THEN		-- Cambio de Motor/Chasis

	BEGIN

		DEFINE _no_motor	CHAR(30);
		DEFINE _no_chasis	CHAR(30);
		DEFINE _no_unidad   CHAR(5);

	   FOREACH	
		SELECT no_motor,
		       no_chasis,
			   no_unidad
		  INTO _no_motor,
		       _no_chasis,
			   _no_unidad
		  FROM endmoaut
		 WHERE no_poliza = a_no_poliza
		   AND no_endoso = a_no_endoso

			IF _no_motor IS NOT NULL THEN

				UPDATE emiauto
				   SET no_motor  = _no_motor
				 WHERE no_poliza = a_no_poliza
				   AND no_unidad = _no_unidad;

			END IF

			IF _no_chasis IS NOT NULL THEN
				
				UPDATE emivehic
				   SET no_chasis = _no_chasis
				 WHERE no_motor  = _no_motor;
				 
			END IF

		END FOREACH
		
	END

ELIF _tipo_mov = 10 THEN	-- Modificacion de Acreedores

	BEGIN

		DEFINE _no_unidad    CHAR(5);
		DEFINE _cod_acreedor CHAR(5);
		DEFINE _limite       DEC(16,2);

		FOREACH
		 SELECT	no_unidad
		   INTO	_no_unidad
		   FROM	endeduni
		  WHERE	no_poliza = a_no_poliza
		    AND no_endoso = a_no_endoso

			DELETE FROM emipoacr
			 WHERE no_poliza = a_no_poliza
			   AND no_unidad = _no_unidad;

			FOREACH 
			 SELECT	cod_acreedor,
					limite
			   INTO	_cod_acreedor,
					_limite
			   FROM	endedacr
			  WHERE no_poliza = a_no_poliza
			    AND no_endoso = a_no_endoso
				AND no_unidad = _no_unidad

				INSERT INTO emipoacr(
				no_poliza, 
				no_unidad,
				cod_acreedor,
				limite
				)
				VALUES(
				a_no_poliza,
				_no_unidad,
				_cod_acreedor,
				_limite
				);

			END FOREACH

		END FOREACH

	END 	

ELIF _tipo_mov = 12 THEN		-- Modificacion de Corredores

	BEGIN

		DEFINE _cod_agente   CHAR(5);
		DEFINE _porc_partic  DEC(5,2);
		DEFINE _porc_comis   DEC(5,2);
		DEFINE _porc_produc  DEC(5,2);

		DELETE FROM emipoagt
		 WHERE no_poliza = a_no_poliza;

		FOREACH
		 SELECT	cod_agente, 
				porc_partic_agt,
				porc_comis_agt, 
				porc_produc
		   INTO	_cod_agente, 
				_porc_partic,
				_porc_comis, 
				_porc_produc
		   FROM	endmoage
		  WHERE	no_poliza = a_no_poliza
		    AND no_endoso = a_no_endoso

				INSERT INTO emipoagt(
				no_poliza,
				cod_agente, 
				porc_partic_agt,
				porc_comis_agt, 
				porc_produc
				)
				VALUES(
				a_no_poliza,
				_cod_agente, 
				_porc_partic,
				_porc_comis, 
				_porc_produc
				);

		END FOREACH

	END 

ELIF _tipo_mov = 13 THEN		-- Modificacion de Asegurado

	BEGIN

		DEFINE _cod_cliente CHAR(10);
		DEFINE _cod_viejo   CHAR(10);
		DEFINE _cod_ramo    CHAR(3);
		DEFINE _ramo_sis    SMALLINT;
		DEFINE _por_certificado SMALLINT;

		SELECT cod_cliente 
		  INTO _cod_cliente
		  FROM endmoase
		 WHERE no_poliza = a_no_poliza
		   AND no_endoso = a_no_endoso;

		SELECT cod_ramo, 
			   por_certificado, 
			   cod_contratante 
		  INTO _cod_ramo, 
		       _por_certificado, 
		       _cod_viejo
		  FROM emipomae
		 WHERE no_poliza = a_no_poliza;

		SELECT ramo_sis	 INTO _ramo_sis
		  FROM prdramo
		 WHERE cod_ramo = _cod_ramo;

		IF _ramo_sis <> 5 AND 
		   _por_certificado = 0 Then

			UPDATE emipouni
			   SET cod_asegurado = _cod_cliente
			 WHERE no_poliza     = a_no_poliza
			   AND cod_asegurado = _cod_viejo;

			UPDATE endeduni
			   SET cod_cliente = _cod_cliente
			 WHERE no_poliza   = a_no_poliza
			   AND cod_cliente = _cod_viejo
			   AND no_endoso   = '00000';

		END IF

		UPDATE emipomae
		   SET cod_contratante = _cod_cliente,
		       cod_pagador     = _cod_cliente
		 WHERE no_poliza       = a_no_poliza;
			
	END 

ELIF _tipo_mov = 15 THEN		-- Cambio de Coaseguro

	BEGIN

		DEFINE _cod_coasegur     CHAR(3);
		DEFINE _porc_partic_coas DEC(7,4);
		DEFINE _porc_gastos      DEC(5,2);
		DEFINE _no_cambio_int	 SMALLINT;
		DEFINE _no_cambio_char   CHAR(3);
		DEFINE _cod_tipoprod1    CHAR(3);
		DEFINE _cambio           CHAR(3);
		DEFINE _cant_coas        SMALLINT;

		 SELECT COUNT(*)
		   INTO _no_cambio_int
		   FROM	endcamco
		  WHERE no_poliza = a_no_poliza
		    AND no_endoso = a_no_endoso;

		IF _no_cambio_int IS NULL THEN
			LET _no_cambio_int = 0;
		END IF

		IF _no_cambio_int = 0 THEN -- Cambio para Sin Coaseguro

			DELETE FROM emicoama
			 WHERE no_poliza = a_no_poliza;

			SELECT cod_tipoprod
			  INTO _cod_tipoprod1
			  FROM emitipro
			 WHERE tipo_produccion = 1;

		ELSE

			SELECT par_ase_lider
			  INTO _cod_coasegur
			  FROM parparam
			 WHERE cod_compania = _cod_compania;

			 SELECT COUNT(*)
			   INTO _no_cambio_int
			   FROM	endcamco
			  WHERE no_poliza    = a_no_poliza
			    AND no_endoso    = a_no_endoso
				AND cod_coasegur = _cod_coasegur;

			IF _no_cambio_int IS NULL THEN
				LET _no_cambio_int = 0;
			END IF

			IF _no_cambio_int = 0 THEN -- Cambio en Coaseguro Minoritario

				DELETE FROM emicoama
				 WHERE no_poliza = a_no_poliza;

				DELETE FROM emicoami
				 WHERE no_poliza = a_no_poliza;

				SELECT cod_tipoprod
				  INTO _cod_tipoprod1
				  FROM emitipro
				 WHERE tipo_produccion = 3;

				INSERT INTO emicoami
				SELECT a_no_poliza,
				       cod_coasegur
				  FROM endcamco
				 WHERE no_poliza = a_no_poliza
				   AND no_endoso = a_no_endoso;

			ELSE					   -- Cambio en Coaseguro Mayoritario

				SELECT cod_tipoprod
				  INTO _cod_tipoprod1
				  FROM emitipro
				 WHERE tipo_produccion = 2;

				SELECT COUNT(*)
				  INTO _no_cambio_int
				  FROM emihcmm
				 WHERE no_poliza = a_no_poliza;

				IF _no_cambio_int IS NULL THEN
					LET _no_cambio_int = 0;
				END IF

				LET _no_cambio_char = '000';

				IF _no_cambio_int > 99 THEN
					LET _no_cambio_char[1,3] = _no_cambio_int;
				ELIF _no_cambio_int > 9 THEN
					LET _no_cambio_char[2,3] = _no_cambio_int;
				ELSE
					LET _no_cambio_char[3,3] = _no_cambio_int;
				END IF

				DELETE FROM emicoama
				 WHERE no_poliza = a_no_poliza;

				SELECT MAX(no_cambio) 
				  INTO _cambio 
				  FROM emihcmm
				 WHERE no_poliza = a_no_poliza;

				UPDATE emihcmm 
				   SET vigencia_final = _vigencia_inic
				 WHERE no_poliza      = a_no_poliza
				   AND no_cambio      = _cambio;

				INSERT INTO emihcmm(
				no_poliza,
				no_cambio,
				vigencia_inic,
				vigencia_final,
				fecha_mov,
				no_endoso
				)
				VALUES(
				a_no_poliza,
				_no_cambio_char,
				_vigencia_inic,
				_vigencia_final,
				CURRENT,
				a_no_endoso
				);

				FOREACH
				 SELECT cod_coasegur,    
						porc_partic_coas,
						porc_gastos     
				   INTO _cod_coasegur,    
						_porc_partic_coas,
						_porc_gastos     
				   FROM	endcamco
				  WHERE no_poliza = a_no_poliza
				    AND no_endoso = a_no_endoso

					INSERT INTO emicoama(
					no_poliza,
					cod_coasegur,    
					porc_partic_coas,
					porc_gastos     
					)
					VALUES(
					a_no_poliza,
					_cod_coasegur,    
					_porc_partic_coas,
					_porc_gastos     
					);

					INSERT INTO emihcmd(
					no_poliza,
					no_cambio,
					cod_coasegur,    
					porc_partic_coas,
					porc_gastos     
					)
					VALUES(
					a_no_poliza,
					_no_cambio_char,
					_cod_coasegur,    
					_porc_partic_coas,
					_porc_gastos     
					);

				END FOREACH

			END IF

		END IF

		UPDATE emipomae
		   SET cod_tipoprod = _cod_tipoprod1
		 WHERE no_poliza    = a_no_poliza;

	END

ELIF _tipo_mov = 16 THEN		-- Cambio de Reaseguro Global

ELIF _tipo_mov = 17 THEN		-- Cambio de Reaseguro Individual

	BEGIN

		DEFINE _no_unidad      CHAR(5);
		DEFINE _cod_cober_reas CHAR(3);
		DEFINE _orden          SMALLINT; 
		DEFINE _no_cambio      SMALLINT;
		DEFINE _cant           SMALLINT;
		DEFINE _cod_contrato   CHAR(5);
		DEFINE _cod_coasegur   CHAR(3); 
		DEFINE _porc_partic_reas DEC(9,6);
		DEFINE _porc_comis_fac	 DEC(5,2);
		DEFINE _porc_impuesto	 DEC(5,2);
		DEFINE _porc_partic_suma  DEC(9,6);
		DEFINE _porc_partic_prima DEC(9,6);
		DEFINE _vigencia_inic  DATE;
		DEFINE _vigencia_final DATE;

        SELECT x.vigencia_inic, x.vigencia_final INTO _vigencia_inic, _vigencia_final
		  FROM endedmae x
		 WHERE x.no_poliza   = a_no_poliza
		   AND x.no_endoso   = a_no_endoso;

		FOREACH
		 SELECT	no_unidad INTO _no_unidad 
		   FROM	endeduni
		  WHERE	no_poliza = a_no_poliza
		    AND no_endoso = a_no_endoso

            SELECT MAX(x.no_cambio) INTO _no_cambio
			  FROM emireama x
			 WHERE x.no_poliza   = a_no_poliza
			   AND x.no_unidad   = _no_unidad;

            LET _no_cambio = _no_cambio + 1;
			FOREACH
			 SELECT	cod_cober_reas,
					orden, 
					cod_contrato,
					porc_partic_suma,
					porc_partic_prima
			   INTO _cod_cober_reas,
					_orden, 
					_cod_contrato,
					_porc_partic_suma,
					_porc_partic_prima
			   FROM	emifacon
			  WHERE	no_poliza = a_no_poliza
			    AND no_endoso = a_no_endoso

			 Let _cant = 0;
             SELECT count(*) INTO _cant
			   FROM emireama x
			  WHERE no_poliza   = a_no_poliza
			    AND no_unidad   = _no_unidad
				AND no_cambio   = _no_cambio
				AND cod_cober_reas = _cod_cober_reas;

			    If _cant = 0 Then
			 	   INSERT INTO emireama(
						no_poliza,
						no_unidad,
						no_cambio, 
						cod_cober_reas,
						vigencia_inic, 
						vigencia_final)
				   VALUES(a_no_poliza,
						_no_unidad, 
						_no_cambio,
						_cod_cober_reas, 
						_vigencia_inic,
				   	    _vigencia_final);
				End If
		  		INSERT INTO emireaco(
					no_poliza,
					no_unidad,
					no_cambio, 
					cod_cober_reas,
					orden,
					cod_contrato,
					porc_partic_suma, 
					porc_partic_prima)
		  		VALUES(a_no_poliza,
					_no_unidad,
					_no_cambio,
					_cod_cober_reas, 
					_orden,
					_cod_contrato,
					_porc_partic_suma,
					_porc_partic_prima);

				FOREACH
				 SELECT	cod_coasegur,
						porc_partic_reas,
						porc_comis_fac,
						porc_impuesto
				   INTO _cod_coasegur, 
						_porc_partic_reas,
						_porc_comis_fac,
						_porc_impuesto
				   FROM	emifafac
				  WHERE	no_poliza = a_no_poliza
				    AND no_endoso = a_no_endoso
					AND cod_cober_reas = _cod_cober_reas
					AND orden     = _orden
					AND cod_contrato   = _cod_contrato
				
				 INSERT INTO emireafa(
				 	 no_poliza,
					 no_unidad,
					 no_cambio, 
					 cod_cober_reas,
					 orden,
					 cod_contrato,
					 cod_coasegur,
					 porc_partic_reas,
					 porc_comis_fac,
					 porc_impuesto)
				 VALUES(
				  	 a_no_poliza,
					 _no_unidad,
					 _no_cambio,
					 _cod_cober_reas, 
					 _orden,
					 _cod_contrato,
					 _cod_coasegur, 
					 _porc_partic_reas,
					 _porc_comis_fac,
					 _porc_impuesto);

				END FOREACH
			END FOREACH
		END FOREACH

	END 
ELIF _tipo_mov = 19 THEN		-- Disminucion de Vigencia

	UPDATE emipomae
	   SET vigencia_final = _vigencia_inic
	 WHERE no_poliza      = a_no_poliza;

END IF


BEGIN
	
	DEFINE _no_factura CHAR(10);

	-- Determina el Numero de Factura

	IF _no_fac_orig IS NULL THEN                                              
	 	LET _no_factura = sp_sis14(_cod_compania, _cod_sucursal, a_no_poliza); 
	ELSE                                                                      
	 	LET _no_factura = _no_fac_orig;                                        
	END IF                                                                    

--	LET _no_factura = sp_sis14(_cod_compania, _cod_sucursal, a_no_poliza);

	-- Actualizacion de los Valores del Endoso

	UPDATE endedmae
	   SET actualizado 		= 1,
	       posteado   		= '1',
		   fecha_emision	= CURRENT,
		   date_changed		= CURRENT,
		   no_factura		= _no_factura,
		   activa           = 1
	 WHERE no_poliza		= a_no_poliza
	   AND no_endoso		= a_no_endoso;

	-- Actualizacion de los Valores de la Poliza

   UPDATE emipomae
      SET saldo          = saldo + _prima_bruta
    WHERE no_poliza      = a_no_poliza; 	

	IF _tipo_mov <> 2 AND _tipo_mov <> 3 THEN	-- Cancelacion / Rehabilitacion

	   UPDATE emipomae
	      SET prima_bruta    = prima_bruta    + _prima_bruta,
	   	      impuesto       = impuesto       + _impuesto,
			  prima_neta     = prima_neta     + _prima_neta,
	   	      descuento      = descuento      + _descuento,
			  recargo        = recargo        + _recargo,
			  prima          = prima          + _prima,
			  prima_suscrita = prima_suscrita + _prima_suscrita,
			  prima_retenida = prima_retenida + _prima_retenida
	    WHERE no_poliza      = a_no_poliza; 	

	END IF

END 

LET _mensaje = 'Actualizacion Exitosa ...';
RETURN 0, _mensaje;

END

END PROCEDURE;

