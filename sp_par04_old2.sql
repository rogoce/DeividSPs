-- Verificacion de la Distribucion de Reseguro en Produccion

DROP PROCEDURE sp_par04;

CREATE PROCEDURE "informix".sp_par04() 
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
DEFINE _cod_cober_reas  CHAR(3);

DEFINE _impuesto		DEC(16,2);
DEFINE _prima_bruta		DEC(16,2);
	
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
		factor_vigencia,
		impuesto,
		prima_bruta
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
		_factor,
		_impuesto,
		_prima_bruta
   FROM endedmae
  WHERE actualizado  = 1
--	AND periodo[1,4] MATCHES a_periodo
--  AND periodo[1,4]      = a_periodo
--	AND no_factura        = '01-98634'
--	AND cod_endomov       = '011'
--	AND no_documento[1,2] = "18"
--	AND no_poliza         in ("81515", "84546")
--	AND prima_neta        = 0
  ORDER BY fecha_emision , no_factura 

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

{
	-- Verificacion de Primacob

	select sum(prima_neta)
	  into _prima_sus_cal
	  from primacob
	 where documento = _no_factura;

	if _prima_sus_cal is null then
		continue foreach;
		let _prima_sus_cal = 0;
	end if

	if abs(_prima_sus_cal - _prima_neta) >= 0.05 then

			RETURN _no_documento,
			       _no_factura,
				   _prima_neta,
				   _prima_neta,
				   _prima_sus_cal,
				   'Prima Neta Endedmae y Primacob Diferentes',
				   _no_endoso,
				   _no_poliza,
				   _fecha,
				   _no_unidad,
				   _cod_endomov
				   WITH RESUME;

	end if

continue foreach;
}


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

				RETURN _no_documento,
				       _no_factura,
					   _prima_neta,
					   _prima_neta,
					   _prima_sus_cal,
					   '1 - 2 Prima de Coberturas es Cero',
					   _no_endoso,
					   _no_poliza,
					   _fecha,
					   _no_unidad,
					   _cod_endomov
					   WITH RESUME;

			ELSE

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
				
			    SELECT COUNT(*)
				  INTO _contador
				  FROM endedcob
				 WHERE no_poliza = _no_poliza
				   AND no_endoso = _no_endoso;

				IF _contador = 1 THEN

					{
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

						--delete from endunide
						--WHERE no_poliza     = _no_poliza
						--AND no_endoso     = _no_endoso;

						UPDATE endedcob
						   SET prima_neta    = _prima_neta,
						       prima_anual   = _prima_neta,
							   prima         = _prima_neta
						 WHERE no_poliza     = _no_poliza
						   AND no_endoso     = _no_endoso
						   AND no_unidad     = _no_unidad
						   AND cod_cobertura = _cobertura;

--						LET  _dias = _vigencia_final - _vigencia_inic;
--						CALL sp_pro461(_no_poliza, _no_endoso, _no_unidad, _dias) RETURNING _ret_sma, _ret_cha;

					END IF					       	   	
					--}

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
		 			--CALL sp_pro4611(_no_poliza, _no_endoso) RETURNING _ret_sma, _ret_cha, _ret_dec, _ret_dec, _ret_dec, _ret_dec, _ret_dec, _ret_dec, _ret_dec, _ret_dec, _ret_dec;
					--}

					RETURN _no_documento,
					       _no_factura,
						   _prima_neta,
						   _prima_neta,
						   _prima_sus_cal,
						   '1 - 3 - 0 Prima Neta Facturas-Coberturas Diferente, Una Cobertura',
						   _no_endoso,
						   _no_poliza,
						   _fecha,
						   _no_unidad,
						   _cod_endomov
						   WITH RESUME;

				ELSE

					SELECT SUM(prima_anual)
					  INTO _prima_sus_reas
					  FROM endedcob
				     WHERE no_poliza = _no_poliza
				       AND no_endoso = _no_endoso;
				
					IF _prima_sus_reas = _prima_neta THEN

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
						--}

						RETURN _no_documento,
						       _no_factura,
							   _prima_neta,
							   _prima_neta,
							   _prima_sus_cal,
							   '1 - 3 - 1 - 0 Prima Neta Facturas-Coberturas Diferente, Mas de Una Cobertura',
							   _no_endoso,
							   _no_poliza,
							   _fecha,
							   _no_unidad,
							   _cod_endomov
							   WITH RESUME;

					ELSE

						{
						LET _1_prima_anual = _prima_neta - _prima_sus_reas;

						IF _1_prima_anual > 0 THEN
							
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
								   SET prima_neta    = prima_neta  + _1_prima_anual,
								       prima_anual   = prima_anual + _1_prima_anual,
									   prima         = prima       + _1_prima_anual
								 WHERE no_poliza     = _no_poliza
								   AND no_endoso     = _no_endoso
								   AND no_unidad     = _no_unidad
								   AND cod_cobertura = _cobertura;

							END IF

						ELSE

							LET _cobertura = NULL;

						   FOREACH	
							SELECT no_unidad,
								   cod_cobertura
							  INTO _no_unidad,
							       _cobertura
							  FROM endedcob
						     WHERE no_poliza  = _no_poliza
						       AND no_endoso  = _no_endoso
							   AND prima_neta >= abs(_1_prima_anual)
									EXIT FOREACH;
							END FOREACH
							
							IF _cobertura IS NOT NULL THEN

								UPDATE endedcob
								   SET prima_neta    = prima_neta  + _1_prima_anual,
								       prima_anual   = prima_anual + _1_prima_anual,
									   prima         = prima       + _1_prima_anual
								 WHERE no_poliza     = _no_poliza
								   AND no_endoso     = _no_endoso
								   AND no_unidad     = _no_unidad
								   AND cod_cobertura = _cobertura;

							END IF

						END IF
						--}

						RETURN _no_documento,
						       _no_factura,
							   _prima_neta,
							   _prima_neta,
							   _prima_sus_cal,
							   '1 - 3 - 1 - 1 Prima Neta Facturas-Coberturas Diferente, Mas de Una Cobertura',
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

					select count(*)
					  into _contador
					  from endunide
					 where no_poliza  = _no_poliza
					   and no_endoso  = _no_endoso
					   and no_unidad  = _no_unidad;

					if _contador is null then
						let _contador = 0;
					end if

					if _contador = 0 and 
					   _factor   = 1 then

						UPDATE endedcob
						   SET prima_neta    = _prima_suscrita,
						       prima_anual   = _prima_suscrita,
							   prima         = _prima_suscrita
						 WHERE no_poliza     = _no_poliza
						   AND no_endoso     = _no_endoso
						   AND no_unidad     = _no_unidad
						   AND cod_cobertura = _cobertura;

						LET  _dias = _vigencia_final - _vigencia_inic;
						CALL sp_pro461(_no_poliza, _no_endoso, _no_unidad, _dias) RETURNING _ret_sma, _ret_cha;
			 			CALL sp_pro4611(_no_poliza, _no_endoso) RETURNING _ret_sma, _ret_cha, _ret_dec, _ret_dec, _ret_dec, _ret_dec, _ret_dec, _ret_dec, _ret_dec, _ret_dec, _ret_dec;

					end if

				END IF					       	   	

			END IF
			--}

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

		{
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
		--}

	END IF

--	CONTINUE FOREACH;

	SELECT SUM(prima)
	  INTO _prima_sus_cal
	  FROM emifacon
	 WHERE no_poliza = _no_poliza
	   AND no_endoso = _no_endoso;

	IF _prima_sus_cal IS NULL AND
	   _prima_neta    <> 0.00 THEN

		LET _prima_sus_cal = 0;

		LET _no_poliza_int	 = _no_poliza;
		LET _no_endoso_int	 = _no_endoso;

		SELECT COUNT(*)
		  INTO _contador
		  FROM emifacon
		 WHERE no_poliza = _no_poliza;

		IF _contador is null then
			let _contador = 0;
		end if
	
		IF _contador <> 0 then

			{
			SELECT min(no_endoso)
			  into _no_endoso_or
			  from emifacon
			 where no_poliza = _no_poliza;

			insert into emifacon
			select no_poliza,
			       _no_endoso,
				   no_unidad,
				   cod_cober_reas,
				   orden,
				   cod_contrato,
				   cod_ruta,
				   porc_partic_suma,
				   porc_partic_prima,
				   0,
				   0
			  from emifacon
			 where no_poliza = _no_poliza
			   and no_endoso = _no_endoso_or;
			 --}

			RETURN _no_documento,
			       _no_factura,
				   _prima_neta,
				   _prima_suscrita,
				   _prima_sus_cal,
				   '2 - 0 No Existe Distribucion de Reaseguros - Si Existe Distrib1',
				   _no_endoso,
				   _no_poliza,
				   _fecha,
				   _no_unidad,
				   _cod_endomov
				   WITH RESUME;

		else

			--CALL sp_par12(_no_poliza, _no_endoso);

			{
		   foreach	
			select cod_cober_reas
			  into _cod_cober_reas
			  from reacobre
			 where cod_ramo = _cod_ramo
				exit foreach;
			end foreach				
			
		   foreach	
			select cod_contrato
			  into _cod_contrato
			  from reacomae
			 where serie = year(_vigencia_inic)
			   and tipo_contrato = 1
			 order by cod_contrato
				exit foreach;
			end foreach				

			foreach
			 select no_unidad
			   into _no_unidad
			   from endeduni
			  where no_poliza = _no_poliza
			    and no_endoso = _no_endoso

				insert into emifacon
				values(
				_no_poliza,
		        _no_endoso,
			    _no_unidad,
			    _cod_cober_reas,
			    1,
			    _cod_contrato,
			    "00001",
			    100,
			    100,
			    0,
			    0);

			end foreach
			--}

			RETURN _no_documento,
			       _no_factura,
				   _prima_neta,
				   _prima_retenida,
				   _prima_sus_cal,
				   '2 - 1 No Existe Distribucion de Reaseguros - No Existe Distrib1',
				   _no_endoso,
				   _no_poliza,
				   _fecha,
				   _no_unidad,
				   _cod_endomov
				   WITH RESUME;

		end if

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
				update endedmae
				   set prima_suscrita = _prima_sus_cal
				 WHERE no_poliza      = _no_poliza
				   AND no_endoso      = _no_endoso;
				--}

				{
				UPDATE emifacon
				   SET prima     = _prima_neta
				 WHERE no_poliza = _no_poliza
				   AND no_endoso = _no_endoso;
				--}

				if _cod_ramo    = "018" and
				   _cod_endomov = "011" then

			   else

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

				end if

			ELSE

				if _cod_ramo    = "018" and
				   _cod_endomov = "011" then
--				   _mas         = '+'   then
				   {
					RETURN _no_documento,
					       _no_factura,
						   _prima_neta,
						   _prima_suscrita,
						   _prima_sus_cal,
						   '3 - 2 - 1 Sumatoria de Prima de Contratos Diferente a Prima Suscrita',
						   _no_endoso,
						   _no_poliza,
						   _fecha,
						   _no_unidad,
						   _cod_endomov
						   WITH RESUME;
					}
				else
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
						   '3 - 2 - 2 Sumatoria de Prima de Contratos Diferente a Prima Suscrita',
						   _no_endoso,
						   _no_poliza,
						   _fecha,
						   _no_unidad,
						   _cod_endomov
						   WITH RESUME;
				end if

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

		IF _porcentaje = 1 THEN

			IF abs(_prima_sus_cal - _prima_suscrita) > 0.01 THEN

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

			END IF

		ELSE
			
			IF abs(_prima_sus_cal - _prima_suscrita) > 0.20 THEN

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
					   '4 - 1 Prima Suscrita por Calculo Diferente de Prima Suscrita',
					   _no_endoso,
					   _no_poliza,
					   _fecha,
					   _no_unidad,
					   _cod_endomov
					   WITH RESUME;

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

				if _cod_ramo    = "018" and
				   _cod_endomov = "011" Then
--				   _mas         = '+'   then
				   {
					RETURN _no_documento,
					       _no_factura,
						   _prima_neta,
						   _prima_retenida,
						   _prima_sus_cal,
						   '6 - 1 - 1 Sumatoria de Prima de Retencion Diferente a Prima Retenida',
						   _no_endoso,
						   _no_poliza,
						   _fecha,
						   _no_unidad,
						   _cod_endomov
						   WITH RESUME;
					}
				else
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
						   '6 - 1 - 2 Sumatoria de Prima de Retencion Diferente a Prima Retenida',
						   _no_endoso,
						   _no_poliza,
						   _fecha,
						   _no_unidad,
						   _cod_endomov
						   WITH RESUME;
				end if
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

				{
				foreach
				 select facultativ,
						retencion,
						comifacult,
						sumareaseg
				   into _cod_reasegur,
						_porcentaje,
						_porc_comision,
						_suma_reas
				   from det_reas
				  where sucursal   = trim(_no_factura[1,2])
				    and fact_rf    = trim(_no_factura[4,10])
					and isfacucont = "Facultativo"

					begin
					on exception in(-691)
					end exception

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
						0,
						_suma_reas,
						0,
						0,
						_fecha,
						''
						);
					
				  end 

				end foreach
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

---------------------------------------------------------------------------------------------------

	-- Verificacion del Impuesto

	select sum(i.factor_impuesto)
	  into _suma_reas
	  from prdimpue i, endedimp e
	 where e.cod_impuesto = i.cod_impuesto
	   and e.no_poliza    = _no_poliza
	   and e.no_endoso    = _no_endoso;

	if _suma_reas is null then
		let _suma_reas = 0;
	end if

	let _suma_reas     = _suma_reas / 100;
	let _prima_sus_cal = _prima_neta * _suma_reas;
	
	if abs(_prima_sus_cal - _impuesto) > 0.05 then	

		let _prima_sus_reas = null;
		
	   foreach	
		select itbmfact
		  into _prima_sus_reas
		  from facturas
		 where numfact  = trim(_no_factura[4,10])
		   and sucursal = trim(_no_factura[1,2])
				exit foreach;
		end foreach

		if _prima_sus_reas is null then
			if _impuesto <> 0 then
				if round((_impuesto/_prima_neta*100),2) = 5.00 or 
				   round((_impuesto/_prima_neta*100),2) = 6.00 then	
					if _prima_sus_cal <> 0.00 then	
						{
						update endedmae
						   set impuesto  = _prima_sus_cal
						 WHERE no_poliza = _no_poliza
						   AND no_endoso = _no_endoso;
						--}
						RETURN _no_documento,
						       _no_factura,
							   _prima_neta,
							   _impuesto,
							   _prima_sus_cal,
							   '9 - 0 - 0 - 1 Calculo del Impuesto Incorrecto',
							   _no_endoso,
							   _no_poliza,
							   _fecha,
							   _no_unidad,
							   _cod_endomov
							   WITH RESUME;
					else
						{
						insert into endedimp
						select 
						no_poliza,
						_no_endoso,
						cod_impuesto,
						0
						from emipolim
						where no_poliza = _no_poliza;

						update endedmae
						   set tiene_impuesto = 1
						 where no_poliza      = _no_poliza
						   and no_endoso      = _no_endoso;  
						--}
						
						RETURN _no_documento,
						       _no_factura,
							   _prima_neta,
							   _impuesto,
							   _prima_sus_cal,
							   '9 - 0 - 0 - 2 Calculo del Impuesto Incorrecto',
							   _no_endoso,
							   _no_poliza,
							   _fecha,
							   _no_unidad,
							   _cod_endomov
							   WITH RESUME;
					end if
				else
					{
					update endedmae
					   set impuesto  = _prima_sus_cal
					 WHERE no_poliza = _no_poliza
					   AND no_endoso = _no_endoso;
					--}
					RETURN _no_documento,
					       _no_factura,
						   _prima_neta,
						   _impuesto,
						   _prima_sus_cal,
						   '9 - 0 - 0 - 3 Calculo del Impuesto Incorrecto',
						   _no_endoso,
						   _no_poliza,
						   _fecha,
						   _no_unidad,
						   _cod_endomov
						   WITH RESUME;
				end if
			else
				{
				update endedmae
				   set impuesto  = _prima_sus_cal
				 WHERE no_poliza = _no_poliza
				   AND no_endoso = _no_endoso;
				--}
				RETURN _no_documento,
				       _no_factura,
					   _prima_neta,
					   _impuesto,
					   _prima_sus_cal,
					   '9 - 0 - 0 - 4 Calculo del Impuesto Incorrecto',
					   _no_endoso,
					   _no_poliza,
					   _fecha,
					   _no_unidad,
					   _cod_endomov
					   WITH RESUME;
			end if
		else
			if _impuesto <> _prima_sus_reas then -- Impuesto de Facturas
				if _prima_sus_reas = 0 then
					{
					update endedmae
					   set impuesto  = _prima_sus_reas
					 WHERE no_poliza = _no_poliza
					   AND no_endoso = _no_endoso;
					--}
					RETURN _no_documento,
					       _no_factura,
						   _prima_neta,
						   _impuesto,
						   _prima_sus_reas,
						   '9 - 0 - 1 Impuesto de Facturas Diferente a Endosos',
						   _no_endoso,
						   _no_poliza,
						   _fecha,
						   _no_unidad,
						   _cod_endomov
						   WITH RESUME;
				else
					if _prima_neta = 0 then
						RETURN _no_documento,
						       _no_factura,
							   _prima_neta,
							   _impuesto,
							   _prima_sus_reas,
							   '9 - 0 - 2 Impuesto Diferente (Prima Neta es 0.00)',
							   _no_endoso,
							   _no_poliza,
							   _fecha,
							   _no_unidad,
							   _cod_endomov
							   WITH RESUME;
					else
						if round((_prima_sus_reas/_prima_neta*100),2) = 5.00 then
							{
							update endedmae
							   set impuesto  = _prima_sus_reas
							 WHERE no_poliza = _no_poliza
							   AND no_endoso = _no_endoso;

							delete from endedimp
							 WHERE no_poliza    = _no_poliza
							   AND no_endoso    = _no_endoso
							   and cod_impuesto = "002";
							--}
							RETURN _no_documento,
							       _no_factura,
								   _prima_neta,
								   _impuesto,
								   _prima_sus_reas,
								   '9 - 0 - 3 Impuesto Diferente (5 % en Impuesto)',
								   _no_endoso,
								   _no_poliza,
								   _fecha,
								   _no_unidad,
								   _cod_endomov
								   WITH RESUME;
						elif round((_prima_sus_reas/_prima_neta*100),2) = 6.00 then	
							RETURN _no_documento,
							       _no_factura,
								   _prima_neta,
								   _impuesto,
								   _prima_sus_reas,
								   '9 - 0 - 4 Impuesto Diferente (6 % en Impuesto)',
								   _no_endoso,
								   _no_poliza,
								   _fecha,
								   _no_unidad,
								   _cod_endomov
								   WITH RESUME;
						else
							{
							update endedmae
							   set impuesto  = _prima_sus_reas
							 WHERE no_poliza = _no_poliza
							   AND no_endoso = _no_endoso;
							--}
							RETURN _no_documento,
							       _no_factura,
								   _prima_neta,
								   _impuesto,
								   _prima_sus_reas,
								   '9 - 0 - 5 Impuesto de Facturas Diferente a Endosos',
								   _no_endoso,
								   _no_poliza,
								   _fecha,
								   _no_unidad,
								   _cod_endomov
								   WITH RESUME;
						end if
					end if
				end if
			end if
		end if
	end if

	-- Verificacion de Prima Neta + Impuesto contra Prima Bruta
	
	IF abs((_prima_neta + _impuesto) - _prima_bruta) <> 0.00 THEN	

		let _prima_sus_reas = null;
		
	   foreach	
		select totalfact
		  into _prima_sus_reas
		  from facturas
		 where numfact  = trim(_no_factura[4,10])
		   and sucursal = trim(_no_factura[1,2])
				exit foreach;
		end foreach

		if _prima_sus_reas is null then

			if (_prima_neta + _impuesto) = 0 then

				RETURN _no_documento,
				       _no_factura,
					   _prima_neta,
					   (_prima_neta + _impuesto),
					   _prima_bruta,
					   '9 - 1 - 0 Prima Neta + Impuesto Diferente a Prima Bruta',
					   _no_endoso,
					   _no_poliza,
					   _fecha,
					   _no_unidad,
					   _cod_endomov
					   WITH RESUME;

			else

				IF abs((_prima_neta + _impuesto) - _prima_bruta) > 10.00 THEN	

					{
					update endedmae
					   set prima_bruta = (_prima_neta + _impuesto)
					 WHERE no_poliza   = _no_poliza
					   AND no_endoso   = _no_endoso;
					--}

					RETURN _no_documento,
					       _no_factura,
						   _prima_neta,
						   (_prima_neta + _impuesto),
						   _prima_bruta,
						   '9 - 1 - 1 Prima Neta + Impuesto Diferente a Prima Bruta',
						   _no_endoso,
						   _no_poliza,
						   _fecha,
						   _no_unidad,
						   _cod_endomov
						   WITH RESUME;

				else

					{
					update endedmae
					   set prima_bruta = (_prima_neta + _impuesto)
					 WHERE no_poliza   = _no_poliza
					   AND no_endoso   = _no_endoso;
					--}
					
					RETURN _no_documento,
					       _no_factura,
						   _prima_neta,
						   (_prima_neta + _impuesto),
						   _prima_bruta,
						   '9 - 1 - 2 Prima Neta + Impuesto Diferente a Prima Bruta',
						   _no_endoso,
						   _no_poliza,
						   _fecha,
						   _no_unidad,
						   _cod_endomov
						   WITH RESUME;
	
				end if

			end if

		else
		
			if _prima_sus_reas <> _prima_bruta then

				{
				update endedmae
				   set prima_bruta = _prima_sus_reas
				 WHERE no_poliza   = _no_poliza
				   AND no_endoso   = _no_endoso;
				--}

				RETURN _no_documento,
				       _no_factura,
					   _prima_neta,
					   _prima_sus_reas,
					   _prima_bruta,
					   '9 - 1 - 3 Prima Bruta de Facturas Diferente a Endosos',
					   _no_endoso,
					   _no_poliza,
					   _fecha,
					   _no_unidad,
					   _cod_endomov
					   WITH RESUME;

			end if

		end if

	END IF

--continue foreach;
---------------------------------------------------------------------------------------------------
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