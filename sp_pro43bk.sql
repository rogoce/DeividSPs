DROP PROCEDURE sp_pro43;
CREATE PROCEDURE sp_pro43(a_no_poliza CHAR(10), a_no_endoso CHAR(5)) RETURNING SMALLINT, CHAR(200);

DEFINE _mensaje,_error_desc													 	CHAR(200);
DEFINE _cod_compania,_cod_sucursal,_cod_endomov,_cod_formapag,_cod_tipocan,_cod_coasegur,_cod_nave,_cod_tipoprod,_cod_ramo	CHAR(3);
DEFINE _periodo_par,_periodo_end     											CHAR(7);
DEFINE _vigencia_inic,_vigencia_final,_fecha_viaje,_fecha_indicador				DATE;
DEFINE _prima_bruta,_impuesto,_prima_neta,_descuento,_recargo,_prima,_prima_suscrita,_prima_retenida	DEC(16,2);
DEFINE _no_fac_orig,nvo_no_pol     												CHAR(10);
DEFINE _porcentaje,_prima_sus_sum,_prima_sus_cal								DEC(16,4);
DEFINE _cantidad																INTEGER;
DEFINE _no_unidad,_cobertura,_no_endoso_ext,_no_endoso							CHAR(5);
DEFINE _user_added																CHAR(8);
DEFINE _tipo_forma,_return,_tiene_impuesto,_tipo_produccion,_error,_tipo_mov,_orden,_estatus_p,_cnt,_error_isam	smallint;
DEFINE _tipo_embarque															char(1);
DEFINE _clausulas,_contenedor,_sello,_viaje_desde,_viaje_hasta,_consignado		varchar(50,0);
DEFINE _sobre																	varchar(250,1);

--SET DEBUG FILE TO "sp_pro43.trc";
--trace on;

SET ISOLATION TO DIRTY READ;
BEGIN
ON EXCEPTION SET _error
 	RETURN _error, 'Error al Actualizar el Endoso ...';
END EXCEPTION
LET _no_fac_orig = NULL;
LET nvo_no_pol = a_no_poliza;
LET _no_endoso = a_no_endoso;
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
	   tiene_impuesto,
	   no_factura,
	   user_added
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
	   _tiene_impuesto,
	   _no_fac_orig,
	   _user_added
  FROM endedmae
 WHERE no_poliza   = a_no_poliza
   AND no_endoso   = a_no_endoso
   AND actualizado = 0;
IF _cod_compania IS NULL THEN
	LET _mensaje = 'Este Endoso Ya Fue Actualizado, Por Favor Verifique ...';
	RETURN 1, _mensaje;
END IF
IF _tiene_impuesto = 0 THEN
	DELETE FROM endedimp WHERE no_poliza = a_no_poliza AND no_endoso = a_no_endoso;
	IF _impuesto <> 0 THEN
		LET _mensaje = 'Este Endoso No Debe Tener Monto de Impuesto, Por Favor Verifique ...';
		RETURN 1, _mensaje;
	END IF
END IF
if ABS(_prima_neta) > 0 then
  if ABS(_prima_bruta) = 0 then
		LET _mensaje = 'La Prima Bruta no debe ser cero, Por Favor Verifique ...';
		RETURN 1, _mensaje;
  end if
end if
SELECT emi_periodo,par_ase_lider INTO _periodo_par, _cod_coasegur FROM parparam WHERE cod_compania = _cod_compania;
SELECT tipo_mov INTO _tipo_mov FROM endtimov WHERE cod_endomov = _cod_endomov;
SELECT cod_tipoprod,estatus_poliza INTO _cod_tipoprod,_estatus_p FROM emipomae WHERE no_poliza = a_no_poliza;
SELECT tipo_produccion INTO _tipo_produccion FROM emitipro WHERE cod_tipoprod = _cod_tipoprod;
let _cnt = 0;
select count(*) into _cnt from emireaut where no_poliza = a_no_poliza;
if _cnt > 0 and _cod_endomov <> '015' then --015=endoso descriptivo
	LET _mensaje = 'Esta Vigencia se esta renovando en este momento, no le puede hacer movimiento.';
	RETURN 1, _mensaje;
end if
LET _porcentaje = 1;
IF _tipo_produccion = 2 THEN
	SELECT porc_partic_coas INTO _porcentaje FROM emicoama WHERE cod_coasegur = _cod_coasegur AND no_poliza = a_no_poliza;
	IF _porcentaje IS NULL THEN
		LET _porcentaje = 0;
	ELSE
		LET _porcentaje = _porcentaje / 100;
	END IF
END IF
IF _tipo_mov <> 17 AND  -- Cambio de Reaseguro Individual
   _tipo_mov <> 15 THEN	-- Cambio de Coaseguro

	LET _prima_sus_sum = _prima_neta * _porcentaje;

	IF abs(_prima_sus_sum - _prima_suscrita) > 0.68 THEN
		LET _mensaje = 'Prima Suscrita por Calculo Diferente de Prima Suscrita, Por Favor Verifique ...';
		RETURN 1, _mensaje;
	END IF

	IF ABS(_prima_retenida) > ABS(_prima_suscrita) THEN
		LET _mensaje = 'Prima Retenida No Puede Ser Mayor que Prima Suscrita, Por Favor Verifique ...';
		RETURN 1, _mensaje;
	END IF
END IF
SELECT SUM(prima)
  INTO _prima_sus_sum
  FROM emifacon
 WHERE no_poliza = a_no_poliza
   AND no_endoso = a_no_endoso;

IF _prima_sus_sum IS NULL THEN
	LET _prima_sus_sum = 0;
END IF
LET _prima_suscrita = _prima_suscrita * 1;
IF ABS(_prima_suscrita - _prima_sus_sum) > 0.02 THEN
	LET _mensaje = 'Sumatoria de Primas de Reaseguro Diferente de Prima Suscrita, Por Favor Verifique ...';
	RETURN 1, _mensaje;
END IF

SELECT SUM(e.prima)
  INTO _prima_sus_sum
  FROM emifacon	e, reacomae r
 WHERE e.no_poliza     = a_no_poliza
   AND e.no_endoso     = a_no_endoso
   AND e.cod_contrato  = r.cod_contrato
   AND r.tipo_contrato = 1;
IF _prima_sus_sum IS NULL THEN
	LET _prima_sus_sum = 0;
END IF
IF ABS(_prima_retenida - _prima_sus_sum) > 0.03 THEN
	LET _mensaje = 'Sumatoria de Prima de Retencion Diferente a Prima Retenida, Por Favor Verifique ...';
	RETURN 1, _mensaje;
END IF
SELECT SUM(prima_neta)
  INTO _prima_sus_sum
  FROM endedcob
 WHERE no_poliza = a_no_poliza
   AND no_endoso = a_no_endoso;
IF _prima_sus_sum IS NULL THEN
	LET _prima_sus_sum = 0;
END IF
IF _tipo_mov <> 24 AND _tipo_mov <> 25 THEN
	IF ABS(_prima_neta - _prima_sus_sum) > 0.07 THEN
		LET _mensaje = 'Sumatoria de Primas de Coberturas Diferente de Prima Neta, Por Favor Verifique ...';
		RETURN 1, _mensaje;
	END IF
END IF
FOREACH
 SELECT no_unidad,
        cod_cober_reas,
	    SUM(porc_partic_prima),
		SUM(porc_partic_suma)
   INTO _no_unidad,
       _cobertura,
	   _prima_sus_cal,
	   _prima_sus_sum
   FROM emifacon
  WHERE no_poliza     = a_no_poliza
    AND no_endoso     = a_no_endoso
  GROUP BY no_unidad, cod_cober_reas
	IF _prima_sus_cal <> 100 THEN
		LET _mensaje = 'Sumatoria de Porcentajes de Prima Diferente de 100%, Por Favor Verifique ...';
		RETURN 1, _mensaje;
	END IF
	IF _prima_sus_sum <> 100 THEN
		LET _mensaje = 'Sumatoria de Porcentajes de Suma Diferente de 100%, Por Favor Verifique ...';
		RETURN 1, _mensaje;
	END IF
END FOREACH
SELECT COUNT(*) INTO _cantidad
  FROM emifacon	e, reacomae r
 WHERE e.no_poliza     = a_no_poliza
   AND e.no_endoso     = a_no_endoso
   AND e.cod_contrato  = r.cod_contrato
   AND r.tipo_contrato = 3;
IF _cantidad IS NULL THEN
	LET _cantidad = 0;
END IF
IF _cantidad <> 0 THEN
   FOREACH	
	SELECT no_unidad,
	       cod_cober_reas,
		   prima,
		   orden
	  INTO _no_unidad,
	       _cobertura,
		   _prima_sus_cal,
		   _orden
	  FROM emifacon	e, reacomae r
	 WHERE e.no_poliza     = a_no_poliza
	   AND e.no_endoso     = a_no_endoso
	   AND e.cod_contrato  = r.cod_contrato
	   AND e.porc_partic_prima <> 0
	   AND r.tipo_contrato = 3

		SELECT SUM(prima)
		  INTO _prima_sus_sum
		  FROM emifafac
		 WHERE no_poliza      = a_no_poliza
		   AND no_endoso      = a_no_endoso
		   AND no_unidad      = _no_unidad
		   AND cod_cober_reas = _cobertura
		   and orden          = _orden;

		IF abs(_prima_sus_cal - _prima_sus_sum) > 0.03 THEN
			LET _mensaje = 'Sumatoria de Prima de Facultativos Diferente a Prima del Contrato Para la Unidad ' || _no_unidad;
			RETURN 1, _mensaje;
		END IF
	
		SELECT SUM(porc_partic_reas)
		  INTO _prima_sus_cal
		  FROM emifafac
		 WHERE no_poliza      = a_no_poliza
		   AND no_endoso      = a_no_endoso
		   AND no_unidad      = _no_unidad
		   AND cod_cober_reas = _cobertura
		   and orden          = _orden;

		IF _prima_sus_cal IS NULL THEN
			LET _prima_sus_cal = 0;
		END IF

		IF _prima_sus_cal <> 100 THEN
			LET _mensaje = 'Sumatoria de Porcentajes de Facultativos Diferente de 100, Por Favor Verifique ...';
			RETURN 1, _mensaje;
		END IF

	END FOREACH
END IF
IF _periodo_end < _periodo_par THEN
	LET _mensaje = 'No Puede Actualizar un Endoso para Un Periodo Cerrado, Por Favor Verifique ...';
	RETURN 1, _mensaje;
END IF
IF _tipo_mov = 1 THEN -- Aumento de Vigencia 	
	BEGIN
		DEFINE _cambio,_cod_r  CHAR(3);
		DEFINE _renglon 	   SMALLINT;
		DEFINE _no_unidad, _cod_cobertura      CHAR(5);
		DEFINE _suma_asegurada,_prima,_prima_neta,_descuento,_recargo,_impuesto,_prima_bruta,_prima_anual,_limite_1,_limite_2 DECIMAL(16,2);
		DEFINE _deducible      CHAR(50);
		DEFINE _no_doc         CHAR(20);

		call sp_sis57(a_no_poliza, a_no_endoso); -- Informacion Necesaria para BO

		select cod_ramo into _cod_r from emipomae where no_poliza = a_no_poliza;

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
				if _cod_r = '002' then
			   		CALL sp_imp11(a_no_poliza,_no_unidad);
				end if

			FOREACH 
			 SELECT	cod_cobertura,
			 		prima,
			 		prima_neta,
			 		descuento,
			 		recargo,
			 		prima_anual,
					limite_1,
					limite_2,
					deducible
			   INTO _cod_cobertura,
			   		_prima,
			   		_prima_neta,
			   		_descuento,
			   		_recargo,
					_prima_anual,
					_limite_1,
					_limite_2,
					_deducible
			   FROM	endedcob
			  WHERE no_poliza = a_no_poliza
			    AND no_endoso = a_no_endoso
			    AND no_unidad = _no_unidad

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

			END FOREACH

 		END FOREACH

		if _cod_r <> "019" then  --vida individual

			UPDATE emipomae
			   SET vigencia_final = _vigencia_final
			 WHERE no_poliza      = a_no_poliza;

			UPDATE emipouni
			   SET vigencia_final = _vigencia_final
			 WHERE no_poliza      = a_no_poliza;

			UPDATE endeduni								--Actualizando endeduni Amado 31/08/2006
			   SET vigencia_final = _vigencia_final
			 WHERE no_poliza      = a_no_poliza
			   AND no_endoso      = a_no_endoso;

			SELECT MAX(no_cambio) 
			  INTO _renglon
			  FROM emireama
			 WHERE no_poliza = a_no_poliza;

			IF _renglon IS NOT NULL THEN

				UPDATE emireama
				   SET vigencia_final = _vigencia_final
				 WHERE no_poliza      = a_no_poliza
				   AND no_cambio      = _renglon;

			END IF

			SELECT MAX(no_cambio) INTO _cambio FROM emihcmm	WHERE no_poliza = a_no_poliza;

			IF _cambio IS NOT NULL THEN

				UPDATE emihcmm 
				   SET vigencia_final = _vigencia_final
				 WHERE no_poliza      = a_no_poliza
				   AND no_cambio      = _cambio;

			END IF
		else

   			UPDATE emipomae
			   SET vigencia_fin_pol = _vigencia_final
			 WHERE no_poliza        = a_no_poliza;

		end if

		select no_documento
		  into _no_doc
		  from emipomae
		 where no_poliza = a_no_poliza;

		delete from emirepo
		 where no_documento = _no_doc;

	END 

ELIF _tipo_mov = 20 THEN    -- Cancelacion Por Saldo 

	BEGIN
		DEFINE _accion, _opcion SMALLINT;
		DEFINE _no_unidad      CHAR(5);
		DEFINE _suma_inc,_suma_ter,_prima_inc,_prima_ter       DECIMAL(16,2);
		DEFINE _cod_ubica	   CHAR(3);

		SELECT accion
		  INTO _accion
		  FROM endtican
		 WHERE cod_tipocan = _cod_tipocan;

		UPDATE emipomae
		   SET estatus_poliza    = _accion,
			   fecha_cancelacion = _vigencia_inic
		 WHERE no_poliza         = a_no_poliza;

		FOREACH
			SELECT no_unidad INTO _no_unidad FROM endeduni WHERE no_poliza = a_no_poliza AND no_endoso = a_no_endoso

			FOREACH 
			 SELECT	cod_ubica, 
			 		suma_incendio, 
			 		suma_terremoto,
			 		prima_incendio,
					prima_terremoto,
					opcion
			   INTO _cod_ubica,
			   		_suma_inc,
			   		_suma_ter,
			   		_prima_inc,
			   		_prima_ter,
					_opcion
			   FROM	endcuend
			  WHERE no_poliza = a_no_poliza
			    AND no_endoso = a_no_endoso
			    AND no_unidad = _no_unidad

					IF _opcion = 2 THEN -- Modificacion de Cumulos

					   UPDATE emicupol
					      SET suma_incendio   = suma_incendio   + _suma_inc,
					          suma_terremoto  = suma_terremoto  + _suma_ter,
							  prima_incendio  = prima_incendio  + _prima_inc,
							  prima_terremoto = prima_terremoto + _prima_ter
					    WHERE no_poliza       = a_no_poliza
					      AND no_unidad       = _no_unidad
					      AND cod_ubica       = _cod_ubica;

					END IF

			END FOREACH
		END FOREACH

	END 

ELIF _tipo_mov = 2 THEN		-- Cancelacion

	BEGIN

		DEFINE _accion,_cant_emirepol,_opcion  SMALLINT;
		DEFINE _no_unidad CHAR(5);      
		DEFINE _suma_inc,_suma_ter,_prima_inc,_prima_ter DECIMAL(16,2);
		DEFINE _cod_ubica,_cod_no_renov	CHAR(3);

			-- Armando, para que no cancelen la misma vigencia varias veces. 02/11/2010

			CALL sp_pro520(a_no_poliza) returning _error, _mensaje;

			IF _error <> 0 THEN --esta vigencia ya esta cancelada
				RETURN _error, _mensaje;
			END IF 

		SELECT accion,
		       cod_no_renov
		  INTO _accion,
		       _cod_no_renov
		  FROM endtican
		 WHERE cod_tipocan = _cod_tipocan;

		UPDATE emipomae
		   SET estatus_poliza    = _accion,
			   fecha_cancelacion = _vigencia_inic
		 WHERE no_poliza         = a_no_poliza;

		SELECT COUNT(*)
		  INTO _cant_emirepol
		  FROM emirepol
		 WHERE no_poliza = a_no_poliza;

		IF _cant_emirepol IS NULL THEN
			LET _cant_emirepol = 0;
		END IF

		UPDATE emipomae
		   SET cod_no_renov   = _cod_no_renov,
			   fecha_no_renov = CURRENT,
			   user_no_renov  = _user_added,
			   no_renovar     = 1
		 WHERE no_poliza      = a_no_poliza;

		DELETE FROM emirepol
		 WHERE no_poliza = a_no_poliza;

		DELETE FROM emirepo
		 WHERE no_poliza = a_no_poliza;

		DELETE FROM emideren
		 WHERE no_poliza = a_no_poliza;

		call sp_sis57(a_no_poliza, a_no_endoso); -- Informacion Necesaria para BO

		FOREACH
			SELECT no_unidad
			  INTO _no_unidad
			  FROM endeduni
		     WHERE no_poliza = a_no_poliza
			   AND no_endoso = a_no_endoso

			FOREACH 
			 SELECT	cod_ubica, 
			 		suma_incendio, 
			 		suma_terremoto,
			 		prima_incendio,
					prima_terremoto,
					opcion
			   INTO _cod_ubica,
			   		_suma_inc, 
			   		_suma_ter, 
			   		_prima_inc,
			   		_prima_ter,
					_opcion
			   FROM	endcuend
			  WHERE no_poliza = a_no_poliza
			    AND no_endoso = a_no_endoso
			    AND no_unidad = _no_unidad

				IF _opcion = 2 THEN

				   UPDATE emicupol
				      SET suma_incendio   = suma_incendio   + _suma_inc,
				          suma_terremoto  = suma_terremoto  + _suma_ter,
						  prima_incendio  = prima_incendio  + _prima_inc,
						  prima_terremoto = prima_terremoto + _prima_ter
				    WHERE no_poliza       = a_no_poliza
				      AND no_unidad       = _no_unidad
				      AND cod_ubica       = _cod_ubica;

				END IF

			END FOREACH

		END FOREACH

	END 

ELIF _tipo_mov = 3 THEN	-- Rehabilitacion

	BEGIN
		DEFINE _vigen_fin_poliza DATE;
		DEFINE _periodo_pro      CHAR(7);
		DEFINE _mes_char         CHAR(2);
		DEFINE _ano_char         CHAR(4);
		DEFINE _ramo_sis,_valor,_accion  SMALLINT;
		DEFINE _no_documento     CHAR(20);

		IF _estatus_p <> 2 THEN
			LET _mensaje = 'La poliza no necesita ser rehabilitada, verifique!';
			RETURN 1, _mensaje;
		END IF 

		call sp_sis57(a_no_poliza, a_no_endoso); -- BO

		SELECT vigencia_final,
			   cod_formapag,
			   no_documento,
			   cod_ramo
		  INTO _vigen_fin_poliza,
			   _cod_formapag,
			   _no_documento,
			   _cod_ramo
		  FROM emipomae
		 WHERE no_poliza = a_no_poliza;

		IF  MONTH(_vigen_fin_poliza) < 10 THEN
			LET _mes_char = '0'|| MONTH(_vigen_fin_poliza);
		ELSE
			LET _mes_char = MONTH(_vigen_fin_poliza);
		END IF

		LET _ano_char    = YEAR(_vigen_fin_poliza);
		LET _periodo_pro = _ano_char || "-" || _mes_char;

		select ramo_sis
		  into _ramo_sis
		  from prdramo
		 where cod_ramo = _cod_ramo;

		IF _vigen_fin_poliza < CURRENT THEN
			LET _accion = 3;
		ELSE
			LET _accion = 1;
		END IF

		UPDATE emipomae SET estatus_poliza = _accion, fecha_cancelacion = NULL, no_renovar = 0, cod_no_renov = NULL, fecha_no_renov = NULL WHERE no_poliza = a_no_poliza;

		SELECT tipo_forma
		  INTO _tipo_forma
		  FROM cobforpa
		 WHERE cod_formapag = _cod_formapag;

		if _accion = 1 and (_tipo_forma = 5 or _tipo_forma = 3) then 
			LET _return	= sp_cas022(a_no_poliza);
		end if
		
		if _ramo_sis <> 5 then
			let _valor = sp_pro28c(_periodo_pro,_no_documento); 
		end if
	END

ELIF _tipo_mov = 4 THEN	-- Inclusion de Unidades

	BEGIN
		DEFINE _null            CHAR(1);      
		DEFINE _suma_asegurada,_suma_aseg_adic DECIMAL(16,2);
		DEFINE _no_unidad,_no_unidad_m      CHAR(5);      
		DEFINE _cod_cober_reas  CHAR(3);      
		DEFINE _no_cambio,_retorno SMALLINT;
		DEFINE _no_motor        char(30);
		DEFINE _no_documento    CHAR(20);
		DEFINE _vig_final       DATE;
		DEFINE _s_vig_final     char(10);

		LET _null      = NULL;
		LET _no_cambio = 0;

		UPDATE endeduni SET vigencia_inic = _vigencia_inic, vigencia_final = _vigencia_final WHERE no_poliza = a_no_poliza	AND no_endoso = a_no_endoso;

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
	    prima_retenida,
		suma_aseg_adic,
		tipo_incendio,
		cod_manzana
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
			   prima_retenida,
			   suma_aseg_adic,
			   tipo_incendio,
			   cod_manzana
		  FROM endeduni
	 	 WHERE no_poliza = a_no_poliza
	 	   AND no_endoso = a_no_endoso;

		LET _retorno = 0;
		FOREACH	 -- Verificando si el motor existe en otra poliza - Amado 25-11-2011 - caso 11642
			SELECT no_motor INTO _no_motor FROM endmoaut WHERE no_poliza = a_no_poliza AND no_endoso = a_no_endoso
			CALL sp_proe23(a_no_poliza, _no_motor, _vigencia_inic) returning _retorno, _no_documento, _vig_final, _no_unidad_m;
			LET _s_vig_final = _vig_final;
			If _retorno = 1 Then 
				EXIT FOREACH;
			End If    		
		END FOREACH
 		If _retorno = 1 Then
			LET _mensaje = 'El No. de Motor ' || trim(_no_motor) || " esta Asegurado en la Unidad No. " || trim(_no_unidad_m) || " de la Poliza " || trim(_no_documento) || " y con Vigencia Final del " || trim(_s_vig_final);
			RETURN 1, _mensaje;
		End If

		INSERT INTO emiauto(no_poliza, no_unidad, cod_tipoveh, no_motor, uso_auto, ano_tarifa)
		SELECT no_poliza, no_unidad, cod_tipoveh, no_motor, uso_auto, ano_tarifa FROM endmoaut WHERE no_poliza = a_no_poliza AND no_endoso = a_no_endoso;		

		INSERT INTO emipode2(no_poliza, no_unidad, descripcion)
		SELECT no_poliza, no_unidad, descripcion FROM endedde2 WHERE no_poliza = a_no_poliza AND no_endoso = a_no_endoso;		

		INSERT INTO emiunide(no_poliza, no_unidad, cod_descuen, porc_descuento)
		SELECT no_poliza, no_unidad, cod_descuen, porc_descuento FROM endunide WHERE no_poliza = a_no_poliza AND no_endoso = a_no_endoso;		

		INSERT INTO emiunire(no_poliza, no_unidad, cod_recargo, porc_recargo)
		SELECT no_poliza, no_unidad, cod_recargo, porc_recargo FROM endunire WHERE no_poliza = a_no_poliza AND no_endoso = a_no_endoso;		

		INSERT INTO emipoacr(no_poliza,	no_unidad, cod_acreedor, limite)
		SELECT no_poliza, no_unidad, cod_acreedor, limite FROM endedacr	WHERE no_poliza = a_no_poliza AND no_endoso = a_no_endoso;

		INSERT INTO emipocob(no_poliza, no_unidad, cod_cobertura, orden, tarifa, deducible,	limite_1, limite_2, prima_anual, prima, descuento, recargo,	prima_neta, date_added, date_changed, factor_vigencia, desc_limite1, desc_limite2)
		SELECT no_poliza, no_unidad, cod_cobertura, orden, tarifa, deducible, limite_1,	limite_2, prima_anual, prima, descuento, recargo, prima_neta, date_added, date_changed,	factor_vigencia, desc_limite1, desc_limite2 FROM endedcob WHERE no_poliza = a_no_poliza AND no_endoso = a_no_endoso;		

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

		FOREACH
		 SELECT	no_unidad, cod_cober_reas
		   INTO	_no_unidad, _cod_cober_reas
		   FROM	emifacon
		  WHERE	no_poliza = a_no_poliza
		    AND no_endoso = a_no_endoso
		  GROUP BY no_unidad, cod_cober_reas

			DELETE FROM emireafa
			 WHERE no_poliza      = a_no_poliza
			   AND no_unidad      = _no_unidad
			   AND no_cambio      = _no_cambio
			   AND cod_cober_reas = _cod_cober_reas;

			DELETE FROM emireaco
			 WHERE no_poliza      = a_no_poliza
			   AND no_unidad      = _no_unidad
			   AND no_cambio      = _no_cambio
			   AND cod_cober_reas = _cod_cober_reas;

			DELETE FROM emireama
			 WHERE no_poliza      = a_no_poliza
			   AND no_unidad      = _no_unidad
			   AND no_cambio      = _no_cambio
			   AND cod_cober_reas = _cod_cober_reas;

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

		INSERT INTO emibenef(
	    no_poliza,
	    no_unidad,
	    cod_cliente,
	    cod_parentesco,
	    benef_desde,
	    porc_partic_ben,
		nombre
		)
		SELECT no_poliza,
			   no_unidad,
			   cod_cliente,
			   cod_parentesco,
			   benef_desde,
			   porc_partic_ben,
			   nombre
		  FROM endbenef
		 WHERE no_poliza = a_no_poliza
		   AND no_endoso = a_no_endoso;

		INSERT INTO emicupol(
	    no_poliza,
	    no_unidad,
	    cod_ubica,
	    suma_incendio,
	    suma_terremoto,
	    prima_incendio,
		prima_terremoto
		)
		SELECT no_poliza,
			   no_unidad,
			   cod_ubica,
			   suma_incendio,
			   suma_terremoto,
			   prima_incendio,
			   prima_terremoto
		  FROM endcuend
		 WHERE no_poliza = a_no_poliza
		   AND no_endoso = a_no_endoso;		   		

	SELECT SUM(suma_asegurada)
		  INTO _suma_asegurada
		  FROM emipouni
		 WHERE no_poliza = a_no_poliza;

		UPDATE emipomae
		   SET suma_asegurada = _suma_asegurada
		 WHERE no_poliza = a_no_poliza;

		INSERT INTO emitrans(
	    no_poliza,
	    no_unidad,
		cod_nave,
		consignado,
		tipo_embarque,
		clausulas,
		contenedor,
		sello,
		fecha_viaje,
		viaje_desde,
		viaje_hasta,
		sobre
		)
		SELECT no_poliza,
			   no_unidad,
			   cod_nave,
			   consignado,
			   tipo_embarque,
			   clausulas,
			   contenedor,
			   sello,
			   fecha_viaje,
			   viaje_desde,
			   viaje_hasta,
			   sobre
		  FROM endmotra
		 WHERE no_poliza = a_no_poliza
		   AND no_endoso = a_no_endoso;		

	END 

ELIF _tipo_mov = 5 THEN	-- Eliminacion de Unidades

	BEGIN

		DEFINE _no_unidad      CHAR(5);
		DEFINE _suma_asegurada DECIMAL(16,2);
		DEFINE _cod_ubica	   CHAR(3);
		DEFINE _cantidad	   INTEGER;

		FOREACH 
		 SELECT	no_unidad INTO _no_unidad FROM endeduni WHERE no_poliza = a_no_poliza AND no_endoso = a_no_endoso

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

			INSERT INTO endbenef(
		    no_poliza,
			no_endoso,
		    no_unidad,
		    cod_cliente,
		    cod_parentesco,
		    benef_desde,
		    porc_partic_ben,
			nombre
			)
			SELECT no_poliza,
				   a_no_endoso,	
				   no_unidad,
				   cod_cliente,
				   cod_parentesco,
				   benef_desde,
				   porc_partic_ben,
				   nombre
			  FROM emibenef
			 WHERE no_poliza = a_no_poliza
			   AND no_unidad = _no_unidad;

			DELETE FROM emibenef
			 WHERE no_poliza = a_no_poliza
			   AND no_unidad = _no_unidad;

			 SELECT	cod_ubica
			   INTO _cod_ubica
			   FROM	endcuend
			  WHERE no_poliza = a_no_poliza
			    AND no_endoso = a_no_endoso
			    AND no_unidad = _no_unidad;

			IF _cod_ubica IS NULL THEN
			INSERT INTO endcuend(
		    no_poliza,
			no_endoso,
		    no_unidad,
		    cod_ubica,
		    suma_incendio,
		    suma_terremoto,
		    prima_incendio,
			prima_terremoto
			)
			SELECT no_poliza,
				   a_no_endoso,	
				   no_unidad,
				   cod_ubica,
				   suma_incendio,
				   suma_terremoto,
				   prima_incendio,
				   prima_terremoto
			  FROM emicupol
			 WHERE no_poliza = a_no_poliza
			   AND no_unidad = _no_unidad;
			END IF

			DELETE FROM emicupol
			 WHERE no_poliza = a_no_poliza
			   AND no_unidad = _no_unidad;

			DELETE FROM emipouni
			 WHERE no_poliza = a_no_poliza
			   AND no_unidad = _no_unidad;

		END FOREACH

		LET _cantidad = NULL;

		SELECT COUNT(*)	INTO _cantidad FROM emipouni WHERE no_poliza = a_no_poliza;

		IF _cantidad < 1 OR _cantidad IS NULL THEN
			LET _mensaje = 'La poliza tiene una unidad, debe cancelarla si desea eliminarla...';
			RETURN 1, _mensaje;
		END IF 

	    SELECT SUM(suma_asegurada) INTO _suma_asegurada	FROM emipouni WHERE no_poliza = a_no_poliza;

		UPDATE emipomae
		   SET suma_asegurada = _suma_asegurada
		 WHERE no_poliza = a_no_poliza;
END 

ELIF _tipo_mov = 6 THEN	-- Modicicacion de Unidades
	BEGIN
		DEFINE _no_unidad,_cod_cobertura      CHAR(5);      
		DEFINE r_cant,_opcion   SMALLINT;     
		DEFINE _porc_partic_ben DECIMAL(5,2);
		DEFINE _suma_asegurada,_prima,_prima_anual,_prima_neta,_descuento,_recargo,_impuesto,_prima_bruta,_limite_1,_limite_2,_suma_inc DECIMAL(16,2);
		DEFINE _suma_ter,_prima_inc,_prima_ter,_suma_aseg_adic          DECIMAL(16,2);
		DEFINE _deducible,_nom_bene      CHAR(50);
		DEFINE _cod_cliente    			 CHAR(10);
		DEFINE _cod_parentesco,_cod_ubica CHAR(3);
		DEFINE _benef_desde    			 DATE;

		call sp_sis57(a_no_poliza, a_no_endoso); -- Informacion Necesaria para BO
		SELECT cod_ramo INTO _cod_ramo  FROM emipomae WHERE no_poliza = a_no_poliza;

		if _cod_ramo <> "018" then

			FOREACH 
			 SELECT	no_unidad, 
			 		suma_asegurada, 
			 		prima, 
			 		prima_neta, 
			 		descuento, 
			 		recargo, 
			 		impuesto, 
			 		prima_bruta,
					suma_aseg_adic
			   INTO	_no_unidad, 
			   		_suma_asegurada, 
			   		_prima, 
			   		_prima_neta, 
			   		_descuento, 
			   		_recargo, 
			   		_impuesto, 
			   		_prima_bruta,
					_suma_aseg_adic
			   FROM	endeduni
			  WHERE no_poliza = a_no_poliza
			    AND no_endoso = a_no_endoso

				UPDATE emipouni
				   SET suma_asegurada = suma_asegurada + _suma_asegurada,
				       prima          = prima          + _prima,
				       prima_neta     = prima_neta     + _prima_neta,
				       descuento      = descuento      + _descuento,
				       recargo        = recargo        + _recargo,
				       impuesto       = impuesto       + _impuesto,
				       prima_bruta    = prima_bruta    + _prima_bruta,
					   suma_aseg_adic = suma_aseg_adic + _suma_aseg_adic
				 WHERE no_poliza      = a_no_poliza
				   AND no_unidad      = _no_unidad;
				if _cod_ramo = '002' then
			   		CALL sp_imp11(a_no_poliza,_no_unidad);
				end if
				{if _suma_asegurada <> 0 then
			   		CALL sp_pro217(a_no_poliza,_no_unidad,a_no_endoso);
				end if}

				FOREACH 
				 SELECT	cod_cobertura,prima,prima_anual,prima_neta,descuento,recargo,limite_1,limite_2,deducible,opcion
				   INTO _cod_cobertura,_prima,_prima_anual,_prima_neta,_descuento,_recargo,_limite_1,_limite_2,_deducible,_opcion
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
						
						IF _opcion = 2 THEN -- Modificacion de Coberturas

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

						ELIF _opcion = 3 THEN -- Eliminacion de Coberturas

							DELETE FROM emipocob
						     WHERE no_poliza     = a_no_poliza
						       AND no_unidad     = _no_unidad
						       AND cod_cobertura = _cod_cobertura;

						END IF

					END IF

				END FOREACH

				FOREACH 
				 SELECT	cod_cliente, 
				 		cod_parentesco, 
				 		benef_desde,
				 		porc_partic_ben,
						opcion,
						nombre
				   INTO _cod_cliente, 
				   		_cod_parentesco, 
				   		_benef_desde, 
				   		_porc_partic_ben,
						_opcion,
						_nom_bene
				   FROM	endbenef
				  WHERE no_poliza = a_no_poliza
				    AND no_endoso = a_no_endoso
				    AND no_unidad = _no_unidad

					let _nom_bene = trim(_nom_bene);

					LET r_cant = 0;

					SELECT COUNT(*)
					  INTO r_cant
					  FROM emibenef
					 WHERE no_poliza     = a_no_poliza
					   AND no_unidad     = _no_unidad
					   AND cod_cliente   = _cod_cliente;

					IF r_cant = 0 THEN

					   INSERT INTO emibenef(
					   no_poliza,
					   no_unidad,
					   cod_cliente,
					   cod_parentesco,
					   benef_desde,
					   porc_partic_ben,
					   nombre )
					   SELECT no_poliza,
							  no_unidad,
							  cod_cliente,
							  cod_parentesco,
							  benef_desde,
							  porc_partic_ben,
							  nombre
						 FROM endbenef
					    WHERE no_poliza     = a_no_poliza
					      AND no_endoso     = a_no_endoso
					      AND no_unidad     = _no_unidad
					      AND cod_cliente   = _cod_cliente;

					ELSE
						
						IF _opcion = 2 THEN -- Modificacion de beneficiarios

						   UPDATE emibenef
						      SET cod_parentesco  = _cod_parentesco,
						          benef_desde     = _benef_desde,
						          porc_partic_ben = _porc_partic_ben,
								  nombre		  = _nom_bene
						    WHERE no_poliza       = a_no_poliza
						      AND no_unidad       = _no_unidad
						      AND cod_cliente     = _cod_cliente;

						ELIF _opcion = 3 THEN -- Eliminacion de beneficiarios

							DELETE FROM emibenef
						     WHERE no_poliza     = a_no_poliza
						       AND no_unidad     = _no_unidad
						       AND cod_cliente   = _cod_cliente;

						END IF

					END IF

				END FOREACH

				FOREACH
				 SELECT	cod_ubica, 
				 		suma_incendio, 
				 		suma_terremoto,
				 		prima_incendio,
						prima_terremoto,
						opcion
				   INTO _cod_ubica,
				   		_suma_inc, 
				   		_suma_ter, 
				   		_prima_inc,
				   		_prima_ter,
						_opcion
				   FROM	endcuend
				  WHERE no_poliza = a_no_poliza
				    AND no_endoso = a_no_endoso
				    AND no_unidad = _no_unidad

						IF _opcion = 2 THEN -- Modificacion de Cumulos

						   UPDATE emicupol
						      SET suma_incendio   = suma_incendio   + _suma_inc,
						          suma_terremoto  = suma_terremoto  + _suma_ter,
								  prima_incendio  = prima_incendio  + _prima_inc,
								  prima_terremoto = prima_terremoto + _prima_ter
						    WHERE no_poliza       = a_no_poliza
						      AND no_unidad       = _no_unidad
						      AND cod_ubica       = _cod_ubica;

						ELIF _opcion = 3 THEN -- Eliminacion de Cumulos

							DELETE FROM emicupol
						     WHERE no_poliza     = a_no_poliza
						       AND no_unidad     = _no_unidad
						       AND cod_ubica     = _cod_ubica;
						END IF

				END FOREACH
				FOREACH
					SELECT cod_nave,
						   consignado,
						   tipo_embarque,
						   clausulas,
						   contenedor,
						   sello,
						   fecha_viaje,
						   viaje_desde,
						   viaje_hasta,
						   sobre
					  INTO _cod_nave,
						   _consignado,
						   _tipo_embarque,
						   _clausulas,
						   _contenedor,
						   _sello,
						   _fecha_viaje,
						   _viaje_desde,
						   _viaje_hasta,
						   _sobre
					  FROM endmotra
					 WHERE no_poliza = a_no_poliza
					   AND no_endoso = a_no_endoso
					   AND no_unidad = _no_unidad

					UPDATE emitrans
					   SET cod_nave		 = _cod_nave,
						   consignado	 = _consignado,
						   tipo_embarque = _tipo_embarque,
						   clausulas	 = _clausulas,
						   contenedor	 = _contenedor,
						   sello 		 = _sello,
						   fecha_viaje	 = _fecha_viaje,
						   viaje_desde	 = _viaje_desde,
						   viaje_hasta	 = _viaje_hasta,
						   sobre		 = _sobre
					 WHERE no_poliza = a_no_poliza
					   AND no_unidad = _no_unidad;

					UPDATE endmotra
					   SET cod_nave		 = _cod_nave,
						   consignado	 = _consignado,
						   tipo_embarque = _tipo_embarque,
						   clausulas	 = _clausulas,
						   contenedor	 = _contenedor,
						   sello 		 = _sello,
						   fecha_viaje	 = _fecha_viaje,
						   viaje_desde	 = _viaje_desde,
						   viaje_hasta	 = _viaje_hasta,
						   sobre		 = _sobre
					 WHERE no_poliza = a_no_poliza
					   AND no_endoso = "00000"
					   AND no_unidad = _no_unidad;
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

		end if
	END 
ELIF _tipo_mov = 9 THEN		-- Cambio de Motor/Chasis

	BEGIN
		DEFINE _no_motor,_no_chasis	CHAR(30);
		DEFINE _no_unidad  			CHAR(5);

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
		DEFINE _no_unidad,_cod_acreedor    CHAR(5);
		DEFINE _limite       			   DEC(16,2);

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
		DEFINE _porc_partic,_porc_comis,_porc_produc,r_porc  DEC(5,2);

		LET	r_porc = 0.00;

		 SELECT SUM(porc_partic_agt)
		   INTO	r_porc
		   FROM endmoage
		  WHERE no_poliza = a_no_poliza
			AND	no_endoso = a_no_endoso;

		 IF r_porc IS NULL THEN
		 	LET _mensaje = 'No ha colocado el Corredor, verifique...';
		 	RETURN 1, _mensaje;
		 END IF 

		 IF r_porc <> 100.00 THEN
		 	LET _mensaje = 'El porcentaje de participacion de los agentes debe sumar 100.00...';
		 	RETURN 1, _mensaje;
		 END IF

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
		DEFINE _cod_cliente,_cod_viejo     CHAR(10);
		DEFINE _cod_subramo      CHAR(3);
		DEFINE _ramo_sis,_por_certificado,_tipo,_cambiar_unidad,_cant_unidad,_camb_desc_uni,_leasing,_tiene_leasing        SMALLINT;
		DEFINE _desc_unidad     VARCHAR(50);
		define _no_doc          char(20);
		define _no_cuenta       char(17);
		define _nombre          char(100);
		define _no_tarjeta      char(19);
		define _cod_grupo       char(5);
		let _leasing = 0;
		let _tiene_leasing = 0;
		let _no_cuenta = null;
		let _no_tarjeta = null;
		SELECT cod_cliente,
			   tipo,
			   leasing
		  INTO _cod_cliente,
			   _tipo,
			   _tiene_leasing
		  FROM endmoase
		 WHERE no_poliza = a_no_poliza
		   AND no_endoso = a_no_endoso;

        IF _tiene_leasing IS NULL THEN
			LET _tiene_leasing = 0;
		END IF
         
		select nombre
		  into _nombre
		  from cliclien
		 where cod_cliente = _cod_cliente;

		SELECT cod_ramo, 
			   por_certificado, 
			   cod_contratante,
			   leasing,
			   no_documento,
			   no_cuenta,
			   no_tarjeta,
			   cod_subramo,
			   cod_grupo
		  INTO _cod_ramo, 
		       _por_certificado, 
		       _cod_viejo,
			   _leasing,
			   _no_doc,
			   _no_cuenta,
			   _no_tarjeta,
			   _cod_subramo,
			   _cod_grupo
		  FROM emipomae
		 WHERE no_poliza = a_no_poliza;

		SELECT ramo_sis INTO _ramo_sis FROM prdramo WHERE cod_ramo = _cod_ramo;

		LET _cambiar_unidad = 1;
		LET _camb_desc_uni  = 0;
		SELECT COUNT(*)
		  INTO _cant_unidad
		  FROM emipouni
		 WHERE no_poliza = a_no_poliza;
		IF _ramo_sis = 7 THEN	   --colectivo de vida
			IF _cant_unidad > 1 THEN
				LET _cambiar_unidad = 0;
			else
				LET _cambiar_unidad = 1;
			END IF
			LET _camb_desc_uni = 1;
			if _cod_subramo = '002' and _cod_grupo = '01016' then
				LET _cambiar_unidad = 1;
			end if
		END IF
		IF _ramo_sis = 1 THEN	   -- auto y soda
			IF _cant_unidad > 1 THEN
				LET _cambiar_unidad = 0;
			else
				LET _cambiar_unidad = 1;
			END IF
			LET _camb_desc_uni = 1;
		END IF	
		IF _ramo_sis = 5 THEN	   --salud
			LET _cambiar_unidad = 0;
		END IF		
		IF _ramo_sis = 9 THEN					   --acc. personales
			IF _cant_unidad > 1 THEN
				LET _cambiar_unidad = 0;
			END IF
			LET _camb_desc_uni = 1;
		END IF		
		IF _ramo_sis = 6 or _ramo_sis = 2 THEN	   --vida individual o Incendio o multiriesgo
			LET _camb_desc_uni = 1;
		END IF		
		IF _camb_desc_uni = 1 THEN
			SELECT nombre
			  INTO _desc_unidad
			  FROM cliclien
			 WHERE cod_cliente = _cod_cliente;
		END IF
		IF _cambiar_unidad = 1 AND _por_certificado = 1 THEN
			LET _cambiar_unidad = 0;
		END IF		
		IF _cambiar_unidad = 1 THEN	  --UNA SOLA UNIDAD
			IF _tipo = 1 THEN	--AMBOS

                IF _camb_desc_uni = 1 THEN
					UPDATE emipouni
					   SET cod_asegurado = _cod_cliente,
					       desc_unidad   = _desc_unidad
					 WHERE no_poliza     = a_no_poliza;
				ELSE
					UPDATE emipouni
					   SET cod_asegurado = _cod_cliente
					 WHERE no_poliza     = a_no_poliza;
				END IF

				UPDATE endeduni
				   SET cod_cliente = _cod_cliente
				 WHERE no_poliza   = a_no_poliza
				   AND no_endoso   = '00000';

				UPDATE endeduni
				   SET cod_cliente = _cod_cliente
				 WHERE no_poliza   = a_no_poliza
				   AND no_endoso   = a_no_endoso;

				UPDATE emipomae
				   SET cod_contratante = _cod_cliente,
				       cod_pagador     = _cod_cliente
				 WHERE no_poliza       = a_no_poliza;

				if _no_cuenta is not null then

				    UPDATE cobcutas
				       SET nombre       = _nombre
				     WHERE no_cuenta    = _no_cuenta
					   and no_documento = _no_doc;

				    UPDATE cobcuhab
				       SET cod_pagador  = _cod_cliente,
					       nombre       = _nombre
				     WHERE no_cuenta    = _no_cuenta;

				end if

				if _no_tarjeta is not null then

				    UPDATE cobtacre
				       SET nombre       = _nombre
				     WHERE no_tarjeta   = _no_tarjeta
					   and no_documento = _no_doc;

				    UPDATE cobtahab
				       SET nombre     = _nombre
				     WHERE no_tarjeta = _no_tarjeta;

				end if
			ELIF _tipo = 2 THEN	  --ASEGURADO

                IF _camb_desc_uni = 1 THEN
					UPDATE emipouni
					   SET cod_asegurado = _cod_cliente,
					       desc_unidad   = _desc_unidad
					 WHERE no_poliza     = a_no_poliza;
				ELSE
					UPDATE emipouni
					   SET cod_asegurado = _cod_cliente
					 WHERE no_poliza     = a_no_poliza;
			    END IF

				UPDATE endeduni
				   SET cod_cliente = _cod_cliente
				 WHERE no_poliza   = a_no_poliza
				   AND no_endoso   = '00000';

				UPDATE endeduni
				   SET cod_cliente = _cod_cliente
				 WHERE no_poliza   = a_no_poliza
				   AND no_endoso   = a_no_endoso;

				if _tiene_leasing = 1 then	--Poner poliza como leasing

					UPDATE emipomae
					   SET leasing   = 1
					 WHERE no_poliza = a_no_poliza;

					let _leasing = 1;

				elif _tiene_leasing = 2 then  --Quitar el leasing

					UPDATE emipomae
					   SET leasing   = 0
					 WHERE no_poliza = a_no_poliza;

					let _leasing = 0;

				end if

				if _leasing <> 1 then
					UPDATE emipomae
					   SET cod_contratante = _cod_cliente
					 WHERE no_poliza       = a_no_poliza;
				end if

			ELIF _tipo = 3 THEN	  --CONTRATANTE
				UPDATE emipomae
				   SET cod_pagador = _cod_cliente
				 WHERE no_poliza   = a_no_poliza;
				if _no_cuenta is not null then
				    UPDATE cobcuhab
				       SET cod_pagador = _cod_cliente,
					       nombre      = _nombre
				     WHERE no_cuenta   = _no_cuenta;
				end if
				if _no_tarjeta is not null then
				    UPDATE cobtahab
				       SET nombre     = _nombre
				     WHERE no_tarjeta = _no_tarjeta;
				end if
				if _tiene_leasing = 1 then	--Poner poliza como leasing
					UPDATE emipomae
					   SET leasing   = 1
					 WHERE no_poliza = a_no_poliza;
					let _leasing = 1;
				elif _tiene_leasing = 2 then  --Quitar el leasing
					UPDATE emipomae
					   SET leasing   = 0
					 WHERE no_poliza = a_no_poliza;
					let _leasing = 0;
				end if
				if _leasing = 1 then
					UPDATE emipomae
					   SET cod_contratante = _cod_cliente
					 WHERE no_poliza       = a_no_poliza;
				end if
			END IF
	    END IF
		SELECT no_unidad
		  INTO _no_unidad
		  FROM endeduni
		 WHERE no_poliza = a_no_poliza
	       AND no_endoso = a_no_endoso;	--> Aqui hay problemas que trae varias unidades
		IF _camb_desc_uni = 1 THEN
			SELECT nombre
			  INTO _desc_unidad
			  FROM cliclien
			 WHERE cod_cliente = _cod_cliente;
		END IF
		IF _tipo = 1 THEN     --AMBOS
			UPDATE emipomae
			   SET cod_contratante = _cod_cliente,
			       cod_pagador     = _cod_cliente
			 WHERE no_poliza       = a_no_poliza;
				if _no_cuenta is not null then
				    UPDATE cobcutas
				       SET nombre       = _nombre
				     WHERE no_cuenta    = _no_cuenta
					   and no_documento = _no_doc;
				    UPDATE cobcuhab
				       SET cod_pagador  = _cod_cliente,
					       nombre       = _nombre
				     WHERE no_cuenta    = _no_cuenta;
				end if
				if _no_tarjeta is not null then
				    UPDATE cobtacre
				       SET nombre       = _nombre
				     WHERE no_tarjeta   = _no_tarjeta
					   and no_documento = _no_doc;
				    UPDATE cobtahab
				       SET nombre     = _nombre
				     WHERE no_tarjeta = _no_tarjeta;
				end if

		ELIF _tipo = 2 THEN	  --ASEGURADO

            IF _camb_desc_uni = 1 THEN
				UPDATE emipouni
				   SET cod_asegurado = _cod_cliente,
				       desc_unidad   = _desc_unidad
				 WHERE no_poliza     = a_no_poliza
				   AND no_unidad     = _no_unidad;
			ELSE
				UPDATE emipouni
				   SET cod_asegurado = _cod_cliente
				 WHERE no_poliza     = a_no_poliza
				   AND no_unidad     = _no_unidad;
			END IF

			UPDATE endeduni
			   SET cod_cliente = _cod_cliente
			 WHERE no_poliza   = a_no_poliza
			   AND no_endoso   = '00000'
			   AND no_unidad   = _no_unidad;

			UPDATE endeduni
			   SET cod_cliente = _cod_cliente
			 WHERE no_poliza   = a_no_poliza
			   AND no_endoso   = a_no_endoso;

		ELIF _tipo = 3 THEN	  --CONTRATANTE

			UPDATE emipomae
			   SET cod_pagador     = _cod_cliente
			 WHERE no_poliza       = a_no_poliza;

			if _leasing = 1 then
				UPDATE emipomae
				   SET cod_contratante = _cod_cliente
				 WHERE no_poliza       = a_no_poliza;
			end if
			if _no_cuenta is not null then
			    UPDATE cobcuhab
			       SET cod_pagador  = _cod_cliente,
				       nombre       = _nombre
			     WHERE no_cuenta    = _no_cuenta;
			end if
			if _no_tarjeta is not null then
			    UPDATE cobtahab
			       SET nombre     = _nombre
			     WHERE no_tarjeta = _no_tarjeta;
			end if
		END IF
	END
ELIF _tipo_mov = 15 THEN		-- Cambio de Coaseguro
	BEGIN
		DEFINE _porc_partic_coas DEC(7,4);
		DEFINE _porc_gastos      DEC(5,2);
		DEFINE _no_cambio_int,_cant_coas SMALLINT;
		DEFINE _no_cambio_char,_cod_tipoprod1,_cambio,_cod_coasegur   CHAR(3);

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

			SELECT MAX(no_cambio) 
			  INTO _cambio
			  FROM emihcmm
			 WHERE no_poliza = a_no_poliza;

			UPDATE emihcmm 
			   SET vigencia_final = _vigencia_inic
			 WHERE no_poliza      = a_no_poliza
			   AND no_cambio      = _cambio;
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

				SELECT MAX(no_cambio) 
				  INTO _cambio
				  FROM emihcmm
				 WHERE no_poliza = a_no_poliza;

				LET _no_cambio_int = _cambio;

				IF _no_cambio_int IS NULL THEN
					LET _no_cambio_int = 0;
				END IF

				LET _no_cambio_int  = _no_cambio_int + 1;
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
ELIF _tipo_mov = 17 THEN		-- Cambio de Reaseguro Individual
	BEGIN
		DEFINE _no_unidad,_cod_contrato         	 				   CHAR(5);
		DEFINE _cod_cober_reas,_cod_coasegur		 				   CHAR(3);
		DEFINE _orden,_no_cambio,_cant               				   SMALLINT; 
		DEFINE _porc_comis_fac,_porc_impuesto	     				   DEC(5,2);
		DEFINE _porc_partic_suma,_porc_partic_prima,_porc_partic_reas  DEC(9,6);
		DEFINE _vigencia_inic,_vigencia_final     	 				   DATE;
		DEFINE _prima_s												   DEC(16,2);

		LET _prima_s = 0.00;
        SELECT vigencia_inic,vigencia_final,prima_suscrita 
          INTO _vigencia_inic, _vigencia_final,_prima_s
		  FROM endedmae	x
		 WHERE x.no_poliza = a_no_poliza
		   AND x.no_endoso = a_no_endoso;

		if _prima_s <> 0.00 Then
			LET _mensaje = 'Prima Suscrita debe ser Cero, Por Favor Verifique ...';
			RETURN 1, _mensaje;
		end if
		FOREACH
		 SELECT	no_unidad 
		   INTO _no_unidad 
		   FROM	endeduni
		  WHERE	no_poliza = a_no_poliza
		    AND no_endoso = a_no_endoso

            SELECT MAX(x.no_cambio) 
              INTO _no_cambio
			  FROM emireama x
			 WHERE x.no_poliza = a_no_poliza
			   AND x.no_unidad = _no_unidad;

			IF _no_cambio IS NULL THEN
			   	LET _no_cambio = 0;
			ELSE
            	LET _no_cambio = _no_cambio + 1;
			END IF

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
				AND no_unidad = _no_unidad

			 LET _cant = 0;

             SELECT COUNT(*) 
               INTO _cant
			   FROM emireama x
			  WHERE no_poliza      = a_no_poliza
			    AND no_unidad      = _no_unidad
				AND no_cambio      = _no_cambio
				AND cod_cober_reas = _cod_cober_reas;

			    IF _cant = 0 THEN

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

				END IF

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
				 SELECT	cod_coasegur,porc_partic_reas,porc_comis_fac,porc_impuesto INTO _cod_coasegur,_porc_partic_reas,_porc_comis_fac,_porc_impuesto
				   FROM	emifafac
				  WHERE	no_poliza      = a_no_poliza
				    AND no_endoso      = a_no_endoso
					AND no_unidad      = _no_unidad
					AND cod_cober_reas = _cod_cober_reas
					AND orden          = _orden
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
	BEGIN
		DEFINE _cambio,_ls_cod_ramo  		CHAR(3);
		DEFINE _renglon 					SMALLINT;
		DEFINE _no_unidad,_cod_cobertura    CHAR(5);      
		DEFINE _suma_asegurada,_prima,_prima_neta,_descuento,_recargo,_impuesto,_prima_bruta,_prima_anual,_limite_1,_limite_2 DECIMAL(16,2);
		DEFINE _deducible      				CHAR(50);

		call sp_sis57(a_no_poliza, a_no_endoso); -- Informacion Necesaria para BO
		
		SELECT cod_ramo INTO _cod_ramo FROM emipomae WHERE no_poliza = a_no_poliza;
		 
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
			   	if _cod_ramo = '002' then
			   		CALL sp_imp11(a_no_poliza,_no_unidad);
				end if
			FOREACH 
			 SELECT	cod_cobertura,
			 		prima,
			 		prima_neta,
			 		descuento,
			 		recargo,
			 		prima_anual,
					limite_1,
					limite_2,
					deducible
			   INTO _cod_cobertura,
			   		_prima,
			   		_prima_neta,
			   		_descuento,
			   		_recargo,
					_prima_anual,
					_limite_1,
					_limite_2,
					_deducible
			   FROM	endedcob
			  WHERE no_poliza = a_no_poliza
			    AND no_endoso = a_no_endoso
			    AND no_unidad = _no_unidad

			   UPDATE emipocob
			      SET prima         = prima       + _prima,
			          prima_neta    = prima_neta  + _prima_neta,
			          descuento     = descuento   + _descuento,
			          recargo	    = recargo     + _recargo,
			          limite_1	    = limite_1    + _limite_1,
			          limite_2	    = limite_2    + _limite_2,
			          deducible     = _deducible
			    WHERE no_poliza     = a_no_poliza
			      AND no_unidad     = _no_unidad
			      AND cod_cobertura = _cod_cobertura;
			END FOREACH
 		END FOREACH

		select cod_ramo, vigencia_final
		  into _ls_cod_ramo, _vigencia_final
		  from emipomae
		 where no_poliza = a_no_poliza;
		   
		if _ls_cod_ramo <> "019" then

			UPDATE emipomae
			   SET vigencia_final = _vigencia_inic
			 WHERE no_poliza      = a_no_poliza;

			UPDATE emipouni
			   SET vigencia_final = _vigencia_inic
			 WHERE no_poliza      = a_no_poliza;
		else

			UPDATE emipomae
			   SET vigencia_fin_pol = _vigencia_inic
			 WHERE no_poliza        = a_no_poliza;

		end if

		SELECT MAX(no_cambio) 
		  INTO _cambio 
		  FROM emihcmm
		 WHERE no_poliza = a_no_poliza;

		IF _cambio IS NOT NULL THEN
			UPDATE emihcmm 
			   SET vigencia_final = _vigencia_inic
			 WHERE no_poliza      = a_no_poliza
			   AND no_cambio      = _cambio;
		END IF

	END
ELIF _tipo_mov = 24 OR _tipo_mov = 25 THEN		-- Descuento de Pronto Pago
  UPDATE endedcob
     SET deducible    = '0',   
         limite_1     = 0,   
         limite_2     = 0,   
         desc_limite1 = "",   
         desc_limite2 = ""  
   WHERE ( endedcob.no_poliza = a_no_poliza ) AND  
         ( endedcob.no_endoso = a_no_endoso )   ;

	UPDATE endeduni  
	   SET suma_asegurada = 0  
	 WHERE ( endeduni.no_poliza = a_no_poliza ) AND  
			 ( endeduni.no_endoso = a_no_endoso )   ;
  UPDATE emifacon  
     SET suma_asegurada = 0  
   WHERE ( emifacon.no_poliza = a_no_poliza ) AND  
         ( emifacon.no_endoso = a_no_endoso )   ;
ELIF _tipo_mov = 26 THEN		-- Cambio de Tipo de Vehic.	 Henry-16/03/2011
	BEGIN
		DEFINE _no_unidad   CHAR(5);
		DEFINE _cod_tipoveh CHAR(3);

	   FOREACH	
		SELECT no_unidad,
		       cod_tipoveh			   
		  INTO _no_unidad,
		       _cod_tipoveh
		  FROM endmoaut
		 WHERE no_poliza = a_no_poliza
		   AND no_endoso = a_no_endoso

			IF _no_unidad IS NOT NULL THEN
				IF _cod_tipoveh IS NOT NULL THEN
					UPDATE emiauto
					   SET cod_tipoveh = _cod_tipoveh
					 WHERE no_poliza   = a_no_poliza
					   AND no_unidad   = _no_unidad;
				ELSE
					LET _mensaje = 'No Existe Tipo de Vehiculo, Por Favor Actualice Nuevamente ...';
					RETURN 1, _mensaje;
				END IF
			ELSE
				LET _mensaje = 'No Existe Unidad, Por Favor Actualice Nuevamente ...';
				RETURN 1, _mensaje;
			END IF
		END FOREACH		
	END

ELIF _tipo_mov = 28 THEN		-- Cambio de codigo de manzana.	Federico 30/11/2012
	BEGIN
		DEFINE _cod_manzana   CHAR(50);

		  SELECT cod_manzana,
				 no_unidad
		  INTO _cod_manzana,
			   _no_unidad
		  FROM endeduni
		  WHERE no_poliza = a_no_poliza
		  AND no_endoso = a_no_endoso;

			IF _cod_manzana IS NOT NULL THEN
				update emipouni
				set cod_manzana = _cod_manzana
			    WHERE no_poliza = a_no_poliza
				AND no_unidad = _no_unidad;
			ELSE
				LET _mensaje = 'No Existe codigo de manzana, Por Favor Actualice Nuevamente ...';
				RETURN 1, _mensaje;
			END IF	
	END
END IF

update emifafac
   set monto_comision = prima * porc_comis_fac / 100,
       monto_impuesto = prima * porc_impuesto  / 100
 where no_poliza      = a_no_poliza
   and no_endoso      = a_no_endoso
   and prima          <> 0.00;
BEGIN
	DEFINE _no_factura,_no_pol_ele 		CHAR(10);
	DEFINE _cant_fact,_no_pagos  		INTEGER;
	define _suma_aseg,_monto_visa		dec(16,2);
	DEFINE _cantidad_uni    SMALLINT;
	DEFINE _no_tarjeta      CHAR(19);
	DEFINE _no_documento    CHAR(20); 
	DEFINE _no_cuenta       CHAR(17);
	
	let _no_pagos = 0;
	let _no_tarjeta = null;
	let _no_documento = "";
	let _monto_visa = 0;
	let _cod_formapag = null;
	let _no_cuenta    = null;

	IF _no_fac_orig IS NULL THEN                                              
	 	LET _no_factura = sp_sis14(_cod_compania, _cod_sucursal, a_no_poliza); 
	ELSE                                                                      
	 	LET _no_factura = _no_fac_orig;                                        
	END IF                                                                    

	SELECT COUNT(*)
	  INTO _cant_fact
	  FROM endedmae
	 WHERE no_factura  = _no_factura AND no_poliza <> a_no_poliza and no_endoso <> a_no_endoso;

	IF _cant_fact IS NULL THEN
		LET _cant_fact = 0;
	END IF

	IF _cant_fact >= 1 THEN
		LET _mensaje = 'Numero de Factura Duplicado, Por Favor Actualice Nuevamente ...';
		RETURN 1, _mensaje;
	END IF

	let _no_endoso_ext   = sp_sis30(a_no_poliza, a_no_endoso);
	let _fecha_indicador = sp_sis156(today, _periodo_end);
	UPDATE endedmae
	   SET actualizado 	   = 1,
	       posteado   	   = '1',
		   fecha_emision   = CURRENT,
		   date_changed	   = CURRENT,
		   no_factura	   = _no_factura,
		   activa          = 1,
		   cod_tipoprod	   = _cod_tipoprod,
		   no_endoso_ext   = _no_endoso_ext,
		   fecha_indicador = _fecha_indicador
	 WHERE no_poliza	   = a_no_poliza
	   AND no_endoso	   = a_no_endoso;

	if _tipo_mov <> 15 then	-- El proceso de cambio de coaseguro crea la tabla con los valores
		select suma_asegurada
		  into _suma_aseg
		  from endedmae
		 where no_poliza = a_no_poliza
		   and no_endoso = a_no_endoso;

		INSERT INTO endcoama(
		       no_poliza,
			   no_endoso,
			   cod_coasegur,
			   porc_partic_coas,
			   porc_gastos,
			   prima,
			   suma
			   )
		SELECT no_poliza,
		       a_no_endoso,
		       cod_coasegur,
		       porc_partic_coas,
		       porc_gastos,
			   (_prima_neta * porc_partic_coas / 100),
			   (_suma_aseg  * porc_partic_coas / 100)
		  FROM emicoama
	     WHERE no_poliza = a_no_poliza;

	end if
	select count(*)
	  into _cantidad_uni
	  from emipouni
	 where no_poliza = a_no_poliza;
	if _cantidad_uni > 1 then
		update emipomae
		   set colectiva = "C"
	     where no_poliza = a_no_poliza;
	end if
   UPDATE emipomae
      SET saldo     = saldo + _prima_bruta
    WHERE no_poliza = a_no_poliza;

	IF _tipo_mov <> 2 AND _tipo_mov <> 3 then -- Cancelacion / Rehabilitacion
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
		select cod_formapag,
		       prima_bruta,
			   no_pagos,
			   no_tarjeta,
			   no_documento,
			   no_cuenta
		  into _cod_formapag,
		       _prima_bruta,
			   _no_pagos,
			   _no_tarjeta,
			   _no_documento,
			   _no_cuenta
		  from emipomae
		 where no_poliza = a_no_poliza;

		SELECT tipo_forma
		  INTO _tipo_forma
		  FROM cobforpa
		 WHERE cod_formapag = _cod_formapag;

		if _no_documento[1,2] = "18" or _no_documento[1,2] = "19" then
		else
			LET _no_pol_ele = sp_sis21(_no_documento);
			IF _tipo_forma = 2 and _no_tarjeta is not null THEN -- Tarjetas de Credito
			    LET _monto_visa = _prima_bruta / _no_pagos;
			    UPDATE emipomae
			       SET monto_visa = _monto_visa
			     WHERE no_poliza  = a_no_poliza;

				if trim(_no_pol_ele) = trim(a_no_poliza) then
				    UPDATE cobtacre
				       SET monto        = _monto_visa
				     WHERE no_tarjeta   = _no_tarjeta
					   and no_documento = _no_documento;
				end if
			END IF
		end if
	END IF
END
{CALL sp_pro517(a_no_poliza, a_no_endoso) returning _error, _mensaje; --Nueva ley de seguro
if _error <> 0 then
	return _error, _mensaje;
end if }
CALL sp_pro100(a_no_poliza, a_no_endoso); --genera endedhis
CALL sp_sis70(a_no_poliza, a_no_endoso);  -- Historico de emipoagt (endmoage)
CALL sp_sis94(a_no_poliza, a_no_endoso) returning _error, _mensaje;
if _error <> 0 then
	return _error, _mensaje;
end if
RETURN 0, 'Actualizacion Exitosa ...';
END
END PROCEDURE;