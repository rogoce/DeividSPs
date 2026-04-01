-- Verificacion de la Distribucion de Reseguro en Produccion

DROP PROCEDURE sp_par04;

CREATE PROCEDURE "informix".sp_par04(
a_periodo  CHAR(4)
) 
RETURNING CHAR(20),
		  CHAR(10),
		  DEC(16,2),
		  DEC(16,2),
		  DEC(16,2),
		  CHAR(100),
		  CHAR(6),
		  CHAR(10),
		  DATE,
		  CHAR(5),
		  CHAR(5);

DEFINE a_compania       CHAR(3);
DEFINE _no_poliza		CHAR(10);
DEFINE _no_endoso		CHAR(6);
DEFINE _cod_tipoprod	CHAR(3);
DEFINE _tipo_produccion	SMALLINT;
DEFINE _porcentaje		DEC(16,4);
DEFINE _cod_coasegur	CHAR(3);
DEFINE _prima_neta		DEC(16,2);
DEFINE _prima_suscrita	DEC(16,2);
DEFINE _prima_retenida	DEC(16,2);
DEFINE _prima_sus_cal	DEC(16,2);
DEFINE _prima_sus_reas	DEC(16,2);
DEFINE _no_documento	CHAR(20);
DEFINE _no_factura		CHAR(10);
DEFINE _cod_endomov		CHAR(5);
DEFINE _cantidad		INTEGER;
DEFINE _no_unidad		CHAR(5);
DEFINE _cobertura		CHAR(5);
DEFINE _fecha			DATE;
DEFINE _asterix			CHAR(1);
DEFINE _no_cambio       CHAR(3);
DEFINE _vigencia_inic	DATE;
DEFINE _vigencia_final	DATE;
DEFINE _contador        INTEGER;

DEFINE _no_endoso_or    CHAR(5);
DEFINE _mas             CHAR(1);

DEFINE _no_poliza_int	INTEGER;
DEFINE _no_endoso_int	INTEGER;
DEFINE _no_unidad_int	INTEGER;
DEFINE _no_cobert_int	INTEGER;
DEFINE _no_serie_int	INTEGER;
DEFINE _no_contrato_int	INTEGER;
DEFINE _no_coasegur_int	INTEGER;
DEFINE _porc_comision	DEC(16,4);
DEFINE _porc_impuesto	DEC(16,4);

DEFINE _orden           SMALLINT;
DEFINE _cod_contrato    CHAR(5);
DEFINE _porcentaje2		DEC(16,4);
DEFINE _suma_reas   	DEC(16,2);
DEFINE _cod_reasegur	CHAR(3);

DEFINE _1_prima_anual  	DEC(16,2);
DEFINE _1_prima_descto 	DEC(16,2);
DEFINE _1_prima     	DEC(16,2);

DEFINE _dias            SMALLINT;

DEFINE _ret_cha			CHAR(30);
DEFINE _ret_sma			SMALLINT;
DEFINE _ret_dec			DEC(16,2);
DEFINE _factor			dec(16,6);

DEFINE _cod_producto    CHAR(5);
DEFINE _cod_ramo        CHAR(3);
DEFINE _cod_subramo     CHAR(3);
DEFINE _cod_asegurado   CHAR(10);
DEFINE _cod_ruta        CHAR(5);
	
--SET DEBUG FILE TO "sp_par04.trc";
--trace on;

SET ISOLATION TO DIRTY READ;

LET a_compania = '001';

SELECT par_ase_lider
  INTO _cod_coasegur
  FROM parparam
 WHERE cod_compania = a_compania;

LET _contador = 0;

FOREACH
 SELECT no_poliza,
		no_endoso,
		prima_neta,
		prima_suscrita,
		no_factura,
		cod_endomov,
		prima_retenida,
		fecha_emision,
		vigencia_inic,
		vigencia_final,
		factor_vigencia
   INTO _no_poliza,
		_no_endoso,
		_prima_neta,
		_prima_suscrita,
		_no_factura,
		_cod_endomov,
		_prima_retenida,
		_fecha,
		_vigencia_inic,
		_vigencia_final,
		_factor
   FROM endedmae
  WHERE actualizado  = 1
    AND periodo[1,4] = a_periodo
--	AND no_factura   = '01-96936'
--	AND no_endoso    = '00000'
--	AND cod_endomov  <> '001'
--	AND cod_endomov  <> '002'
--	AND cod_endomov  <> '003'
--	AND cod_endomov  <> '017'
--	AND cod_endomov  <> '019'
	AND cod_endomov  = '011'
--	AND no_documento IN ("1000-00026-01")
--	AND no_poliza    = '29445'
	AND prima_neta   > 0
  ORDER BY fecha_emision DESC, no_factura DESC

	LET _no_unidad = '00000';
	LET _contador  = _contador + 1;
	LET _mas       = '';

	SELECT cod_tipoprod,
	       no_documento,
		   cod_ramo,
		   cod_subramo,
		   cod_contratante
	  INTO _cod_tipoprod,
		   _no_documento,
		   _cod_ramo,
		   _cod_subramo,
		   _cod_asegurado
	  FROM emipomae
	 WHERE no_poliza = _no_poliza;

	SELECT tipo_produccion
	  INTO _tipo_produccion
	  FROM emitipro
	 WHERE cod_tipoprod = _cod_tipoprod;

	IF _no_endoso = '00000' THEN

		SELECT COUNT(*)
		  INTO _cantidad
		  FROM endedmae
		 WHERE no_poliza = _no_poliza;

		IF _cantidad > 1 THEN
			LET _mas          = '+';
			LET _no_documento = TRIM(_no_documento) || '+';
--			CONTINUE FOREACH;
		END IF

	END IF

	LET _asterix = '';

	SELECT COUNT(*)
	  INTO _cantidad
	  FROM emihcmm
	 WHERE no_poliza = _no_poliza;

	IF _cantidad IS NULL THEN
		LET _cantidad = 0;
	END IF

	IF _cantidad > 1 THEN
		LET _asterix   = '%';
	END IF

	IF _asterix = '%' THEN
		LET _cod_endomov = TRIM(_cod_endomov) || _asterix;
	ELSE

		SELECT COUNT(*)
		  INTO _cantidad
		  FROM endcoama
		 WHERE no_poliza = _no_poliza
		   AND no_endoso = _no_endoso;

		IF _cantidad IS NULL THEN
			LET _cantidad = 0;
		END IF

		IF _cantidad <> 0 THEN
			LET _asterix     = '?';
			LET _cod_endomov = TRIM(_cod_endomov) || _asterix;
		END IF

	END IF

	IF _tipo_produccion = 2 THEN
		LET _asterix     = '*';
		LET _cod_endomov = TRIM(_cod_endomov) || _asterix;
	END IF

	-- Verificacion de Prima Neta

	SELECT SUM(prima_neta)
	  INTO _prima_sus_cal
	  FROM endedcob
	 WHERE no_poliza = _no_poliza
	   AND no_endoso = _no_endoso;

	IF _prima_sus_cal IS NULL THEN
		LET _prima_sus_cal = 0;
	END IF

	IF abs(_prima_sus_cal - _prima_neta) > 0.02 THEN

		{
		IF _cod_endomov = '011' THEN

		   FOREACH 
		    SELECT no_unidad,
			       prima_neta
			  INTO _no_unidad,
			       _prima_neta
			  FROM endeduni
			 WHERE no_poliza = _no_poliza
			   AND no_endoso = _no_endoso

				UPDATE endedcob
				   SET prima_neta  = _prima_neta,
				       prima_anual = _prima_neta,
					   prima       = _prima_neta
				 WHERE no_poliza   = _no_poliza
				   AND no_endoso   = _no_endoso
				   AND no_unidad   = _no_unidad
				   AND prima_neta  <> 0;

			END FOREACH

		END IF
		--}

		LET _no_poliza_int = _no_poliza;
		LET _no_endoso_int = _no_endoso;

		select sum(prima_anual), 
		       sum(prima_sin_descto), 
		       sum(prima)
		  into _1_prima_anual,
			   _1_prima_descto,
			   _1_prima
		  from endcob
		 where no_poliza = _no_poliza_int
		   and no_endoso = _no_endoso_int;

		IF _1_prima_anual  IS NULL THEN
			LET _1_prima_anual = 0;
		END IF
		
		IF _1_prima_descto  IS NULL THEN
			LET _1_prima_descto = 0;
		END IF

		IF _1_prima  IS NULL THEN
			LET _1_prima = 0;
		END IF

		IF _1_prima_anual = _1_prima_descto AND
		   _1_prima_anual = _1_prima		AND
		   _1_prima_anual = _prima_sus_cal  AND
		   abs(_prima_sus_cal) > abs(_prima_neta) AND
		   _1_prima_anual <> 0 				THEN

			{
			LET _dias = _vigencia_final - _vigencia_inic;

			FOREACH 
			 SELECT no_unidad
			   INTO _no_unidad
			   FROM endeduni
			  WHERE no_poliza = _no_poliza
			    AND no_endoso = _no_endoso

				CALL sp_pro461(_no_poliza, _no_endoso, _no_unidad, _dias) RETURNING _ret_sma, _ret_cha;

			END FOREACH

				CALL sp_pro4611(_no_poliza, _no_endoso) RETURNING _ret_sma, _ret_cha, _ret_dec, _ret_dec, _ret_dec, _ret_dec, _ret_dec, _ret_dec, _ret_dec, _ret_dec, _ret_dec;
			--}				

			RETURN _no_documento,
			       _no_factura,
				   _prima_neta,
				   _prima_neta,
				   _prima_sus_cal,
				   '1 - 0 - 0 Sumatoria de Prima Neta de Coberturas Diferente a Prima Neta',
				   _no_endoso,
				   _no_poliza,
				   _fecha,
				   _no_unidad,
				   _cod_endomov
				   WITH RESUME;

		END IF

		IF _1_prima_anual = _1_prima_descto AND
		   _1_prima_anual = _1_prima		AND
		   _1_prima_anual = _prima_sus_cal  AND
		   abs(_prima_sus_cal) > abs(_prima_neta) AND
		   _1_prima_anual <> 0 				THEN

			{
			LET _dias = _vigencia_final - _vigencia_inic;

			FOREACH 
			 SELECT no_unidad
			   INTO _no_unidad
			   FROM endeduni
			  WHERE no_poliza = _no_poliza
			    AND no_endoso = _no_endoso

				CALL sp_pro461(_no_poliza, _no_endoso, _no_unidad, _dias) RETURNING _ret_sma, _ret_cha;

			END FOREACH

				CALL sp_pro4611(_no_poliza, _no_endoso) RETURNING _ret_sma, _ret_cha, _ret_dec, _ret_dec, _ret_dec, _ret_dec, _ret_dec, _ret_dec, _ret_dec, _ret_dec, _ret_dec;
			--}				

			RETURN _no_documento,
			       _no_factura,
				   _prima_neta,
				   _prima_neta,
				   _prima_sus_cal,
				   '1 - 0 - 1 Sumatoria de Prima Neta de Coberturas Diferente a Prima Neta',
				   _no_endoso,
				   _no_poliza,
				   _fecha,
				   _no_unidad,
				   _cod_endomov
				   WITH RESUME;

		END IF

		IF _prima_neta = 0 THEN

			{
			UPDATE endedmae
			   SET prima_neta = _prima_sus_cal,
			       impuesto   = prima_bruta - _prima_sus_cal
			 WHERE no_poliza  =	_no_poliza
			   AND no_endoso  = _no_endoso;
			--}

			RETURN _no_documento,
			       _no_factura,
				   _prima_neta,
				   _prima_neta,
				   _prima_sus_cal,
				   '1 - 1 Prima Neta es Cero',
				   _no_endoso,
				   _no_poliza,
				   _fecha,
				   _no_unidad,
				   _cod_endomov
				   WITH RESUME;

		ELSE

			IF _prima_sus_cal = 0 THEN

				{
			    SELECT COUNT(*)
				  INTO _contador
				  FROM endeduni
				 WHERE no_poliza = _no_poliza
				   AND no_endoso = _no_endoso;

				IF _contador = 1 THEN

					LET _cobertura = NULL;

				   FOREACH	
					SELECT no_unidad,
						   cod_cobertura
					  INTO _no_unidad,
					       _cobertura
					  FROM endedcob
				     WHERE no_poliza = _no_poliza
				       AND no_endoso = _no_endoso
							EXIT FOREACH;
					END FOREACH
					
					IF _cobertura IS NOT NULL THEN

						UPDATE endedcob
						   SET prima_neta    = _prima_neta,
						       prima_anual   = _prima_neta,
							   prima         = _prima_neta
						 WHERE no_poliza     = _no_poliza
						   AND no_endoso     = _no_endoso
						   AND no_unidad     = _no_unidad
						   AND cod_cobertura = _cobertura;

					END IF					       	   	

				END IF
				--}

				IF _1_prima_anual  = 0 AND
				   _1_prima_descto = 0 AND
				   _1_prima        = 0 THEN

					SELECT SUM(prima)
					  INTO _prima_sus_reas
					  FROM emifacon
					 WHERE no_poliza = _no_poliza
					   AND no_endoso = _no_endoso;
					
					IF _prima_sus_reas IS NULL THEN
						LET _prima_sus_reas = 0;
					END IF 

					IF _prima_sus_reas = 0 THEN

						{
						IF _no_endoso = '00000' AND
						   _mas 	  = ''      THEN

							DELETE FROM endedcob
						     WHERE no_poliza = _no_poliza
						       AND no_endoso = _no_endoso;

						END IF
						--}

						{
					    SELECT COUNT(*)
						  INTO _contador
						  FROM endeduni
						 WHERE no_poliza = _no_poliza
						   AND no_endoso = _no_endoso;

						IF _contador = 1 THEN

							LET _cobertura = NULL;

						   FOREACH	
							SELECT no_unidad,
								   cod_cobertura
							  INTO _no_unidad,
							       _cobertura
							  FROM endedcob
						     WHERE no_poliza = _no_poliza
						       AND no_endoso = _no_endoso
									EXIT FOREACH;
							END FOREACH
							
							IF _cobertura IS NOT NULL THEN

								UPDATE endedcob
								   SET prima_neta    = _prima_neta,
								       prima_anual   = _prima_neta,
									   prima         = _prima_neta
								 WHERE no_poliza     = _no_poliza
								   AND no_endoso     = _no_endoso
								   AND no_unidad     = _no_unidad
								   AND cod_cobertura = _cobertura;

								LET  _dias = _vigencia_final - _vigencia_inic;
								CALL sp_pro461(_no_poliza, _no_endoso, _no_unidad, _dias) RETURNING _ret_sma, _ret_cha;
					 			CALL sp_pro4611(_no_poliza, _no_endoso) RETURNING _ret_sma, _ret_cha, _ret_dec, _ret_dec, _ret_dec, _ret_dec, _ret_dec, _ret_dec, _ret_dec, _ret_dec, _ret_dec;

							END IF					       	   	

						END IF
						--}

						RETURN _no_documento,
						       _no_factura,
							   _prima_neta,
							   _prima_neta,
							   _prima_sus_cal,
							   '1 - 2 - 0 Prima Coberturas Cero - Reaseguro Cero',
							   _no_endoso,
							   _no_poliza,
							   _fecha,
							   _no_unidad,
							   _cod_endomov
							   WITH RESUME;

					ELSE

						IF _factor = 1 THEN

							{
						    SELECT COUNT(*)
							  INTO _contador
							  FROM endeduni
							 WHERE no_poliza = _no_poliza
							   AND no_endoso = _no_endoso;

							IF _contador = 1 THEN

								LET _cobertura = NULL;

							   FOREACH	
								SELECT no_unidad,
									   cod_cobertura
								  INTO _no_unidad,
								       _cobertura
								  FROM endedcob
							     WHERE no_poliza = _no_poliza
							       AND no_endoso = _no_endoso
										EXIT FOREACH;
								END FOREACH
								
								IF _cobertura IS NOT NULL THEN

									UPDATE endedcob
									   SET prima_neta    = _prima_neta,
									       prima_anual   = _prima_neta,
										   prima         = _prima_neta
									 WHERE no_poliza     = _no_poliza
									   AND no_endoso     = _no_endoso
									   AND no_unidad     = _no_unidad
									   AND cod_cobertura = _cobertura;

									LET  _dias = _vigencia_final - _vigencia_inic;
									CALL sp_pro461(_no_poliza, _no_endoso, _no_unidad, _dias) RETURNING _ret_sma, _ret_cha;
						 			CALL sp_pro4611(_no_poliza, _no_endoso) RETURNING _ret_sma, _ret_cha, _ret_dec, _ret_dec, _ret_dec, _ret_dec, _ret_dec, _ret_dec, _ret_dec, _ret_dec, _ret_dec;

								END IF					       	   	

							END IF
							--}

							RETURN _no_documento,
							       _no_factura,
								   _prima_neta,
								   _prima_neta,
								   _prima_sus_cal,
								   '1 - 2 - 1 - 0 Prima Coberturas Cero - Reaseguro con Valor - Factor = 1',
								   _no_endoso,
								   _no_poliza,
								   _fecha,
								   _no_unidad,
								   _cod_endomov
								   WITH RESUME;

						ELSE

							RETURN _no_documento,
							       _no_factura,
								   _prima_neta,
								   _prima_neta,
								   _prima_sus_cal,
								   '1 - 2 - 1 - 1 Prima Coberturas Cero - Reaseguro con Valor - Factor <> 1',
								   _no_endoso,
								   _no_poliza,
								   _fecha,
								   _no_unidad,
								   _cod_endomov
								   WITH RESUME;

						END IF

					END IF

				ELSE

					SELECT COUNT(*)
					  INTO _contador
					  FROM endedcob
					 WHERE no_poliza = _no_poliza
					   AND no_endoso = _no_endoso;

					IF _contador = 0 THEN
				
						RETURN _no_documento,
						       _no_factura,
							   _prima_neta,
							   _prima_neta,
							   _prima_sus_cal,
							   '1 - 2 - 2 - 0 No Existen Coberturas',
							   _no_endoso,
							   _no_poliza,
							   _fecha,
							   _no_unidad,
							   _cod_endomov
							   WITH RESUME;

					ELSE

						RETURN _no_documento,
						       _no_factura,
							   _prima_neta,
							   _prima_neta,
							   _prima_sus_cal,
							   '1 - 2 - 2 - 1 Sumatoria de Prima Neta de Coberturas Diferente a Prima Neta',
							   _no_endoso,
							   _no_poliza,
							   _fecha,
							   _no_unidad,
							   _cod_endomov
							   WITH RESUME;

					END IF

				END IF

			ELSE

				IF _cod_endomov[1,3] = '011' THEN

					{
					IF _factor = 1 THEN

					    SELECT COUNT(*)
						  INTO _contador
						  FROM endeduni
						 WHERE no_poliza = _no_poliza
						   AND no_endoso = _no_endoso;

						IF _contador = 1 THEN

							LET _cobertura = NULL;

						   FOREACH	
							SELECT no_unidad,
								   cod_cobertura
							  INTO _no_unidad,
							       _cobertura
							  FROM endedcob
						     WHERE no_poliza = _no_poliza
						       AND no_endoso = _no_endoso
									EXIT FOREACH;
							END FOREACH
							
							IF _cobertura IS NOT NULL THEN

								UPDATE endedcob
								   SET prima_neta    = _prima_neta,
								       prima_anual   = _prima_neta,
									   prima         = _prima_neta
								 WHERE no_poliza     = _no_poliza
								   AND no_endoso     = _no_endoso
								   AND no_unidad     = _no_unidad
								   AND cod_cobertura = _cobertura;

								LET  _dias = _vigencia_final - _vigencia_inic;
								CALL sp_pro461(_no_poliza, _no_endoso, _no_unidad, _dias) RETURNING _ret_sma, _ret_cha;
					 			CALL sp_pro4611(_no_poliza, _no_endoso) RETURNING _ret_sma, _ret_cha, _ret_dec, _ret_dec, _ret_dec, _ret_dec, _ret_dec, _ret_dec, _ret_dec, _ret_dec, _ret_dec;

							END IF					       	   	

						END IF
					END IF
					--}

					RETURN _no_documento,
					       _no_factura,
						   _prima_neta,
						   _prima_neta,
						   _prima_sus_cal,
						   '1 - 3 Sumatoria de Prima Neta de Coberturas Diferente a Prima Neta',
						   _no_endoso,
						   _no_poliza,
						   _fecha,
						   _no_unidad,
						   _cod_endomov
						   WITH RESUME;

				ELSE

					IF _cod_endomov[1,3] = '001' OR
					   _cod_endomov[1,3] = '002' OR
					   _cod_endomov[1,3] = '003' THEN

						RETURN _no_documento,
						       _no_factura,
							   _prima_neta,
							   _prima_neta,
							   _prima_sus_cal,
							   '1 - 4 Sumatoria de Prima Neta de Coberturas Diferente a Prima Neta',
							   _no_endoso,
							   _no_poliza,
							   _fecha,
							   _no_unidad,
							   _cod_endomov
							   WITH RESUME;

					ELSE

						RETURN _no_documento,
						       _no_factura,
							   _prima_neta,
							   _prima_neta,
							   _prima_sus_cal,
							   '1 - 5 Sumatoria de Prima Neta de Coberturas Diferente a Prima Neta',
							   _no_endoso,
							   _no_poliza,
							   _fecha,
							   _no_unidad,
							   _cod_endomov
							   WITH RESUME;

					END IF

				END IF

			END IF

		END IF

	END IF

	IF _cod_endomov[1,3] <> '017' THEN

		IF _prima_neta      = 0 AND
		   _prima_suscrita <> 0 THEN

			LET _prima_sus_cal = _prima_suscrita;

			RETURN _no_documento,
			       _no_factura,
				   _prima_neta,
				   _prima_neta,
				   _prima_sus_cal,
				   '1 - 6 Prima Neta es Cero y Prima Suscrita con Valor',
				   _no_endoso,
				   _no_poliza,
				   _fecha,
				   _no_unidad,
				   _cod_endomov
				   WITH RESUME;

		END IF

		IF _prima_neta      = 0 AND
		   _prima_retenida <> 0 THEN

			LET _prima_sus_cal = _prima_retenida;

			RETURN _no_documento,
			       _no_factura,
				   _prima_neta,
				   _prima_neta,
				   _prima_sus_cal,
				   '1 - 7 Prima Neta es Cero y Prima Retenida con Valor',
				   _no_endoso,
				   _no_poliza,
				   _fecha,
				   _no_unidad,
				   _cod_endomov
				   WITH RESUME;

		END IF

	END IF

	CONTINUE FOREACH;

	SELECT SUM(prima)
	  INTO _prima_sus_cal
	  FROM emifacon
	 WHERE no_poliza = _no_poliza
	   AND no_endoso = _no_endoso;

	IF _prima_sus_cal IS NULL AND
	   _prima_neta    <> 0.00 THEN

		LET _prima_sus_cal = 0;

		--CALL sp_par12(_no_poliza, _no_endoso);

		RETURN _no_documento,
		       _no_factura,
			   _prima_neta,
			   _prima_suscrita,
			   _prima_sus_cal,
			   '2 - No Existe Distribucion de Reaseguros',
			   _no_endoso,
			   _no_poliza,
			   _fecha,
			   _no_unidad,
			   _cod_endomov
			   WITH RESUME;
	END IF

--	CONTINUE FOREACH;

	SELECT SUM(prima)
	  INTO _prima_sus_cal
	  FROM emifacon
	 WHERE no_poliza = _no_poliza
	   AND no_endoso = _no_endoso;

	IF _prima_sus_cal IS NULL THEN
		LET _prima_sus_cal = 0;
	END IF

	IF abs(_prima_sus_cal - _prima_suscrita) > 0.02 THEN

		--CALL sp_par12(_no_poliza, _no_endoso);

		IF _prima_neta = _prima_sus_cal THEN

			--CALL sp_par12(_no_poliza, _no_endoso);

			{
			UPDATE endedmae
			   SET prima_suscrita = _prima_neta
			 WHERE no_poliza      =	_no_poliza
			   AND no_endoso      = _no_endoso;
			--}

			RETURN _no_documento,
			       _no_factura,
				   _prima_neta,
				   _prima_suscrita,
				   _prima_sus_cal,
				   '3 - 0 Sumatoria de Prima de Contratos Diferente a Prima Suscrita',
				   _no_endoso,
				   _no_poliza,
				   _fecha,
				   _no_unidad,
				   _cod_endomov
				   WITH RESUME;

		ELSE

			IF _prima_neta = 0 THEN

				--CALL sp_par12(_no_poliza, _no_endoso);

				{
				UPDATE emifacon
				   SET prima     = _prima_neta
				 WHERE no_poliza = _no_poliza
				   AND no_endoso = _no_endoso;
				--}

				RETURN _no_documento,
				       _no_factura,
					   _prima_neta,
					   _prima_suscrita,
					   _prima_sus_cal,
					   '3 - 1 Sumatoria de Prima de Contratos Diferente a Prima Suscrita',
					   _no_endoso,
					   _no_poliza,
					   _fecha,
					   _no_unidad,
					   _cod_endomov
					   WITH RESUME;

			ELSE

				--CALL sp_par12(_no_poliza, _no_endoso);

				{
				UPDATE endedmae
				   SET prima_suscrita = _prima_sus_cal
				 WHERE no_poliza      =	_no_poliza
				   AND no_endoso      = _no_endoso;
				--}

				RETURN _no_documento,
				       _no_factura,
					   _prima_neta,
					   _prima_suscrita,
					   _prima_sus_cal,
					   '3 - 2 Sumatoria de Prima de Contratos Diferente a Prima Suscrita',
					   _no_endoso,
					   _no_poliza,
					   _fecha,
					   _no_unidad,
					   _cod_endomov
					   WITH RESUME;

			END IF

		END IF

	END IF

	IF _cod_endomov[1,3] <> '017' THEN

		LET _porcentaje = 100;

		SELECT porc_partic_coas
		  INTO _porcentaje
		  FROM endcoama
		 WHERE cod_coasegur = _cod_coasegur
		   AND no_poliza    = _no_poliza
		   AND no_endoso    = _no_endoso;
		
		IF _porcentaje IS NULL THEN
			LET _porcentaje = 100;
		END IF

		LET _porcentaje = _porcentaje / 100;

		LET _prima_sus_cal = _prima_neta * _porcentaje;

		IF abs(_prima_sus_cal - _prima_suscrita) > 0.05 THEN

			{
			IF _asterix = '%' THEN
				CALL sp_par16(_no_poliza, _no_endoso);
			END IF
			--}
			{
			UPDATE endedmae
			   SET prima_suscrita = _prima_sus_cal
			 WHERE no_poliza      = _no_poliza
			   AND no_endoso      = _no_endoso;
			--}

			IF _prima_neta = _prima_sus_cal THEN
	
				{
				UPDATE endedmae
				   SET prima_suscrita = _prima_sus_cal
				 WHERE no_poliza      = _no_poliza
				   AND no_endoso      = _no_endoso;
				--}

				RETURN _no_documento,
				       _no_factura,
					   _prima_neta,
					   _prima_suscrita,
					   _prima_sus_cal,
					   '4 - 0 Prima Suscrita por Calculo Diferente de Prima Suscrita',
					   _no_endoso,
					   _no_poliza,
					   _fecha,
					   _no_unidad,
					   _cod_endomov
					   WITH RESUME;

			ELSE

				IF abs(_prima_sus_cal - _prima_suscrita) <= 1.00 THEN

					{
					UPDATE endedmae
					   SET prima_suscrita = _prima_sus_cal
					 WHERE no_poliza      = _no_poliza
					   AND no_endoso      = _no_endoso;
					--}

					RETURN _no_documento,
					       _no_factura,
						   _prima_neta,
						   _prima_suscrita,
						   _prima_sus_cal,
						   '4 - 2 Prima Suscrita por Calculo Diferente de Prima Suscrita',
						   _no_endoso,
						   _no_poliza,
						   _fecha,
						   _no_unidad,
						   _cod_endomov
						   WITH RESUME;

				ELSE

					IF _prima_neta = _prima_suscrita THEN

						{
						UPDATE endedmae
						   SET prima_suscrita = _prima_sus_cal
						 WHERE no_poliza      = _no_poliza
						   AND no_endoso      = _no_endoso;
						--}

						RETURN _no_documento,
						       _no_factura,
							   _prima_neta,
							   _prima_suscrita,
							   _prima_sus_cal,
							   '4 - 3 Prima Suscrita por Calculo Diferente de Prima Suscrita',
							   _no_endoso,
							   _no_poliza,
							   _fecha,
							   _no_unidad,
							   _cod_endomov
							   WITH RESUME;

					ELSE

						{
						UPDATE endedmae
						   SET prima_suscrita = _prima_sus_cal
						 WHERE no_poliza      = _no_poliza
						   AND no_endoso      = _no_endoso;
						--}

						RETURN _no_documento,
						       _no_factura,
							   _prima_neta,
							   _prima_suscrita,
							   _prima_sus_cal,
							   '4 - 4 Prima Suscrita por Calculo Diferente de Prima Suscrita',
							   _no_endoso,
							   _no_poliza,
							   _fecha,
							   _no_unidad,
							   _cod_endomov
							   WITH RESUME;
	
					END IF

				END IF
	
			END IF

 		END IF

	END IF


	-- Verificacion de Prima Retenida

	SELECT SUM(e.prima)
	  INTO _prima_sus_cal
	  FROM emifacon	e, reacomae r
	 WHERE e.no_poliza     = _no_poliza
	   AND e.no_endoso     = _no_endoso
	   AND e.cod_contrato  = r.cod_contrato
	   AND r.tipo_contrato = 1;

	IF _prima_sus_cal IS NULL THEN

		LET _prima_sus_cal = 0;

		IF abs(_prima_sus_cal - _prima_retenida) > 0.02 THEN

			{
			IF _no_endoso = '00000' THEN
				
				UPDATE emipouni
				   SET prima_retenida = 0
				 WHERE no_poliza      =	_no_poliza;

				UPDATE emipomae
				   SET prima_retenida = 0
				 WHERE no_poliza      =	_no_poliza;

			END IF

			UPDATE endeduni
			   SET prima_retenida = 0
			 WHERE no_poliza      =	_no_poliza
			   AND no_endoso      = _no_endoso;

			UPDATE endedmae
			   SET prima_retenida = 0
			 WHERE no_poliza      =	_no_poliza
			   AND no_endoso      = _no_endoso;
			--}

			RETURN _no_documento,
			       _no_factura,
				   _prima_neta,
				   _prima_retenida,
				   _prima_sus_cal,
				   '5 - No Debe Existir Prima de Retencion',
				   _no_endoso,
				   _no_poliza,
				   _fecha,
				   _no_unidad,
				   _cod_endomov
				   WITH RESUME;

		END IF

	ELSE

		IF abs(_prima_sus_cal - _prima_retenida) > 0.02 THEN

			--CALL sp_par12(_no_poliza, _no_endoso);

			IF _prima_neta = _prima_sus_cal THEN

				{
				UPDATE endedmae
				   SET prima_retenida = _prima_sus_cal
				 WHERE no_poliza      = _no_poliza
				   AND no_endoso      = _no_endoso;
				--}

				RETURN _no_documento,
				       _no_factura,
					   _prima_neta,
					   _prima_retenida,
					   _prima_sus_cal,
					   '6 - 0 Sumatoria de Prima de Retencion Diferente a Prima Retenida',
					   _no_endoso,
					   _no_poliza,
					   _fecha,
					   _no_unidad,
					   _cod_endomov
					   WITH RESUME;

			ELSE

				{
				UPDATE endedmae
				   SET prima_retenida = _prima_sus_cal
				 WHERE no_poliza      = _no_poliza
				   AND no_endoso      = _no_endoso;
				--}

				RETURN _no_documento,
				       _no_factura,
					   _prima_neta,
					   _prima_retenida,
					   _prima_sus_cal,
					   '6 - 1 Sumatoria de Prima de Retencion Diferente a Prima Retenida',
					   _no_endoso,
					   _no_poliza,
					   _fecha,
					   _no_unidad,
					   _cod_endomov
					   WITH RESUME;

			END IF

		END IF

	END IF

	-- Verificacion de Facultativos

	SELECT COUNT(*)
	  INTO _cantidad
	  FROM emifacon	e, reacomae r
	 WHERE e.no_poliza     = _no_poliza
	   AND e.no_endoso     = _no_endoso
	   AND e.cod_contrato  = r.cod_contrato
	   AND r.tipo_contrato = 3;

	IF _cantidad IS NULL THEN
		LET _cantidad = 0;
	END IF

	IF _cantidad <> 0 THEN

	   FOREACH	
		SELECT e.no_unidad,
		       e.cod_cober_reas,
			   e.prima,
			   e.porc_partic_prima,
			   e.orden,
			   e.cod_contrato,
			   e.suma_asegurada
		  INTO _no_unidad,
		       _cobertura,
			   _prima_suscrita,
			   _porcentaje,
			   _orden,
			   _cod_contrato,
			   _suma_reas
		  FROM emifacon	e, reacomae r
		 WHERE e.no_poliza     = _no_poliza
		   AND e.no_endoso     = _no_endoso
		   AND e.cod_contrato  = r.cod_contrato
		   AND r.tipo_contrato = 3
		 ORDER BY no_unidad

			SELECT SUM(porc_partic_reas)
			  INTO _porcentaje2
			  FROM emifafac
			 WHERE no_poliza      = _no_poliza
			   AND no_endoso      = _no_endoso
			   AND no_unidad      = _no_unidad
			   AND cod_cober_reas = _cobertura;
	
			LET _prima_sus_cal = _porcentaje2;

			IF _prima_sus_cal IS NULL THEN

				{
				LET _cod_reasegur  = '010';
				LET _porcentaje    = 100;
				LET _porc_comision = 25;
				LET _porc_impuesto = 2;

				INSERT INTO emifafac
				VALUES(
				_no_poliza,
				_no_endoso,
				_no_unidad,
				_cobertura,
				_orden,
				_cod_contrato,
				_cod_reasegur,
				_porcentaje,
				_porc_comision,
				_porc_impuesto,
				0,
				0,
				0,
				_fecha,
				''
				);
				--}

				{
				LET _no_poliza_int	 = _no_poliza;
				LET _no_unidad_int	 = _no_unidad;

				LET _no_endoso_int = NULL;

				FOREACH
				 SELECT no_endoso,
				        cod_cobertura,
						YEAR(serie),
						tipo_contrato
				   INTO _no_endoso_int,
				        _no_cobert_int,
						_no_serie_int,
						_no_contrato_int
				   FROM distrib2
				  WHERE no_poliza = _no_poliza_int
				    AND no_unidad = _no_unidad_int
				  ORDER BY no_endoso
						EXIT FOREACH;
				END FOREACH
				
				IF _no_endoso_int IS NOT NULL THEN
				
					FOREACH
					 SELECT cod_coasegur,
					        porc_partic,
							porc_comision,
							porc_impuesto
					   INTO _no_coasegur_int,
					        _porcentaje,
							_porc_comision,
							_porc_impuesto
					   FROM distrib2
					  WHERE no_poliza     = _no_poliza_int
					    AND no_endoso     = _no_endoso_int
						AND no_unidad     = _no_unidad_int
						AND cod_cobertura = _no_cobert_int
						AND YEAR(serie)	  = _no_serie_int
						AND tipo_contrato = _no_contrato_int

							LET _cod_reasegur = sp_set_codigo(3, _no_coasegur_int);

							INSERT INTO emifafac
							VALUES(
							_no_poliza,
							_no_endoso,
							_no_unidad,
							_cobertura,
							_orden,
							_cod_contrato,
							_cod_reasegur,
							_porcentaje,
							_porc_comision,
							_porc_impuesto,
							0,
							0,
							0,
							_fecha,
							''
							);

					END FOREACH
				
				ELSE

					FOREACH
					 SELECT no_endoso,
					        cod_cobertura,
							YEAR(serie),
							tipo_contrato
					   INTO _no_endoso_int,
					        _no_cobert_int,
							_no_serie_int,
							_no_contrato_int
					   FROM distrib2
					  WHERE no_poliza = _no_poliza_int
					    AND no_unidad = _no_unidad_int
					  ORDER BY no_endoso
							EXIT FOREACH;
					END FOREACH

				
				END IF
				--}

				RETURN _no_documento,
				       _no_factura,
					   _prima_neta,
					   100,
					   _prima_sus_cal,
					   '7 - 3 No Existe Distribucion de Facultativos',
					   _no_endoso,
					   _no_poliza,
					   _fecha,
					   _no_unidad,
					   _cod_endomov
					   WITH RESUME;

			ELSE

				IF _prima_sus_cal <> 100 THEN

					SELECT COUNT(*)
					  INTO _contador
					  FROM emifafac
					 WHERE no_poliza      = _no_poliza
					   AND no_endoso      = _no_endoso
					   AND no_unidad      = _no_unidad
					   AND cod_cober_reas = _cobertura;

					IF _contador = 1 THEN

						{
						UPDATE emifafac
						   SET porc_partic_reas = 100
						 WHERE no_poliza        = _no_poliza
						   AND no_endoso        = _no_endoso
						   AND no_unidad        = _no_unidad
						   AND cod_cober_reas   = _cobertura;
						--}

						RETURN _no_documento,
						       _no_factura,
							   _prima_neta,
							   100,
							   _prima_sus_cal,
							   '7 - 0 Sumatoria de Porcentajes de Facultativos Diferente de 100',
							   _no_endoso,
							   _no_poliza,
							   _fecha,
							   _no_unidad,
							   _cod_endomov
							   WITH RESUME;

					ELSE

						IF _porcentaje = _prima_sus_cal THEN

							{
							UPDATE emifafac
							   SET porc_partic_reas = (porc_partic_reas / _prima_sus_cal) * 100
							 WHERE no_poliza        = _no_poliza
							   AND no_endoso        = _no_endoso
							   AND no_unidad        = _no_unidad
							   AND cod_cober_reas   = _cobertura;
							--}

							RETURN _no_documento,
							       _no_factura,
								   _prima_neta,
								   100,
								   _prima_sus_cal,
								   '7 - 1 Sumatoria de Porcentajes de Facultativos Diferente de 100',
								   _no_endoso,
								   _no_poliza,
								   _fecha,
								   _no_unidad,
								   _cod_endomov
								   WITH RESUME;

						ELSE

							{
							UPDATE emifafac
							   SET porc_partic_reas = (porc_partic_reas / _prima_sus_cal) * 100
							 WHERE no_poliza        = _no_poliza
							   AND no_endoso        = _no_endoso
							   AND no_unidad        = _no_unidad
							   AND cod_cober_reas   = _cobertura;
							--}

							RETURN _no_documento,
							       _no_factura,
								   _prima_neta,
								   100,
								   _prima_sus_cal,
								   '7 - 2 Sumatoria de Porcentajes de Facultativos Diferente de 100',
								   _no_endoso,
								   _no_poliza,
								   _fecha,
								   _no_unidad,
								   _cod_endomov
								   WITH RESUME;

						END IF

					END IF

				END IF

			END IF

			SELECT SUM(prima)
			  INTO _prima_sus_cal
			  FROM emifafac
			 WHERE no_poliza      = _no_poliza
			   AND no_endoso      = _no_endoso
			   AND no_unidad      = _no_unidad
			   AND cod_cober_reas = _cobertura;

			IF abs(_prima_sus_cal - _prima_suscrita) > 0.02 THEN

				{
				UPDATE emifafac
				   SET prima            = (porc_partic_reas / 100) * _prima_suscrita,
				       suma_asegurada   = (porc_partic_reas / 100) * _suma_reas
				 WHERE no_poliza        = _no_poliza
				   AND no_endoso        = _no_endoso
				   AND no_unidad        = _no_unidad
				   AND cod_cober_reas   = _cobertura;
				--}

				RETURN _no_documento,
				       _no_factura,
					   _prima_neta,
					   _prima_suscrita,
					   _prima_sus_cal,
					   '8 - 0 Sumatoria de Prima de Facultativos Diferente a Prima del Contrato',
					   _no_endoso,
					   _no_poliza,
					   _fecha,
					   _no_unidad,
					   _cod_endomov
					   WITH RESUME;

			END IF
		

		END FOREACH

	END IF

END FOREACH

LET _prima_sus_cal = _contador;

RETURN '',
       '',
	   0,
	   0,
	   _prima_sus_cal,
	   'Registros Procesados',
	   '',
	   '',
	   '',
	   '',
	   ''
	   WITH RESUME;

END PROCEDURE;

{
IF _tipo_produccion = 2 THEN

	IF _no_endoso = '00000' THEN

		SELECT porc_partic_coas
		  INTO _porcentaje
		  FROM emihcmd
		 WHERE cod_coasegur = _cod_coasegur
		   AND no_poliza    = _no_poliza
		   AND no_cambio    = '000';

		IF _porcentaje IS NULL THEN
			RETURN _no_documento,
			       _no_factura,
				   _prima_neta,
				   _prima_suscrita,
				   _prima_sus_cal,
				   'No Existe Distribucion de Coaseguro',
				   _no_endoso,
				   _no_poliza,
				   _fecha,
				   _no_unidad,
				   _cod_endomov
				   WITH RESUME;
			LET _porcentaje = 100;
		END IF

		LET _porcentaje = _porcentaje / 100;

	ELSE

		SELECT porc_partic_coas
		  INTO _porcentaje
		  FROM endcoama
		 WHERE cod_coasegur = _cod_coasegur
		   AND no_poliza    = _no_poliza
		   AND no_endoso    = _no_endoso;
		
		IF _porcentaje IS NULL THEN
			LET _porcentaje = 100;
		END IF

		SELECT COUNT(*)
		  INTO _cantidad
		  FROM emihcmm
		 WHERE no_poliza = _no_poliza;

		IF _cantidad IS NULL THEN
			LET _cantidad = 0;
		END IF

		IF _cantidad > 1 THEN

			LET _asterix   = '%';
			LET _no_cambio = NULL;

		   FOREACH
		    SELECT no_cambio
			  INTO _no_cambio
			  FROM emihcmm
			 WHERE no_poliza      = _no_poliza
			   AND vigencia_inic  <= _vigencia_inic
			   AND vigencia_final >= _vigencia_inic
			 ORDER BY no_cambio DESC
				EXIT FOREACH;
			END FOREACH

		    SELECT MAX(no_cambio)
			  INTO _no_cambio
			  FROM emihcmm
			 WHERE no_poliza = _no_poliza
			   AND fecha_mov <= _fecha;

			IF _no_cambio IS NOT NULL THEN

				SELECT porc_partic_coas
				  INTO _porcentaje
				  FROM emihcmd
				 WHERE cod_coasegur = _cod_coasegur
				   AND no_poliza    = _no_poliza
				   AND no_cambio    = _no_cambio;

			END IF

		ELSE

			LET _cod_endomov = TRIM(_cod_endomov) || '*';

			SELECT porc_partic_coas
			  INTO _porcentaje
			  FROM emicoama
			 WHERE cod_coasegur = _cod_coasegur
			   AND no_poliza    = _no_poliza;

		END IF

	 	LET _porcentaje = _porcentaje / 100;

	END IF

END IF
}