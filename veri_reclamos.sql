DROP PROCEDURE ver_recl;		

CREATE PROCEDURE "informix".ver_recl()
	RETURNING CHAR(10),
	          CHAR(10),
			  CHAR(5),
			  CHAR(20),
	          DATE,
			  DATE,
			  DATE,
			  CHAR(255);

DEFINE v_nopoliza, v_noreclamo 							CHAR(10);
DEFINE v_nodocumento           							CHAR(20);
DEFINE v_fechasinis, v_vigencia_inic, v_vigencia_final 	DATE;
DEFINE v_nounidad                                       CHAR(5);
DEFINE _no_cambio, _cod_tipoprod, _cod_cober_reas		CHAR(3);
DEFINE _mensaje                                         CHAR(255);
DEFINE _tipo_produccion									INT;
DEFINE _porcentaje      								DEC(7,4);


CREATE TEMP TABLE tmp_arreglo(
		no_reclamo       CHAR(10),
		no_poliza	     CHAR(10),
		no_unidad        CHAR(5),
		no_documento     CHAR(20),
		fecha_siniestro	 DATE,
		vig_ini_pol  	 DATE,
		vig_fin_pol		 DATE,
		mensaje		     CHAR(255)
		) WITH NO LOG;

FOREACH
	SELECT no_reclamo,
	       no_poliza,
	       no_documento,
		   no_unidad,
	       fecha_siniestro
	  INTO v_noreclamo,
	       v_nopoliza,
	  	   v_nodocumento,
		   v_nounidad,
	       v_fechasinis
	  FROM recrcmae
	 WHERE actualizado = 0
	   AND no_reclamo is not null 

	SELECT cod_tipoprod
	  INTO _cod_tipoprod
	  FROM emipomae
	 WHERE no_poliza = v_nopoliza;

	-- Coaseguradoras

	SELECT tipo_produccion
	  INTO _tipo_produccion
	  FROM emitipro
	 WHERE cod_tipoprod = _cod_tipoprod;

	LET _no_cambio = NULL;

	FOREACH
	 SELECT	no_cambio
	   INTO	_no_cambio
	   FROM	emihcmm
	  WHERE	no_poliza      = v_nopoliza
	    AND vigencia_inic  <= v_fechasinis
		AND vigencia_final >= v_fechasinis
			EXIT FOREACH;
	END FOREACH

	IF _tipo_produccion = 2 AND
	   _no_cambio IS NULL THEN
		LET _mensaje = 'No Existe Distribucion de Coaseguro para Este Reclamo, Por Favor Verifique ...';
		INSERT INTO tmp_arreglo(
		no_reclamo,     
		no_poliza,	   
		no_unidad,      
		no_documento,   
		fecha_siniestro,
		vig_ini_pol,  	
		vig_fin_pol,			
		mensaje		   	
		)
		VALUES(
		v_noreclamo,
		v_nopoliza,
		v_nounidad,
		v_nodocumento,
		v_fechasinis,
		NULL,
		NULL,
		_mensaje
		);
		CONTINUE FOREACH ;
	END IF


	-- Reaseguradoras

	LET _no_cambio = NULL;

	FOREACH
	 SELECT	no_cambio,
	  		cod_cober_reas,
	        vigencia_inic,
			vigencia_final
	   INTO	_no_cambio,
	        _cod_cober_reas,
			v_vigencia_inic,
			v_vigencia_final
	   FROM	emireama
	  WHERE	no_poliza       = v_nopoliza
	    AND no_unidad       = v_nounidad
	    AND vigencia_inic  <= v_fechasinis
		AND vigencia_final >= v_fechasinis
	  ORDER BY no_cambio DESC
			EXIT FOREACH;
	END FOREACH

	IF _no_cambio IS NULL THEN
		LET _mensaje = 'No Existe Distribucion de Reaseguro para Este Reclamo, Por Favor Verifique ...';
		INSERT INTO tmp_arreglo(
		no_reclamo,     
		no_poliza,	   
		no_unidad,      
		no_documento,   
		fecha_siniestro,
		vig_ini_pol,  	
		vig_fin_pol,			
		mensaje		   	
		)
		VALUES(
		v_noreclamo,
		v_nopoliza,
		v_nounidad,
		v_nodocumento,
		v_fechasinis,
		null,
		null,
		_mensaje
		);
		CONTINUE FOREACH ;
	END IF

	-- Contratos

	SELECT SUM(porc_partic_suma)
	  INTO _porcentaje
	 FROM emireaco
	WHERE no_poliza       = v_nopoliza
	  AND no_unidad       = v_nounidad
	  AND no_cambio       = _no_cambio
	  AND cod_cober_reas  = _cod_cober_reas;

	IF _porcentaje IS NULL THEN
		LET _porcentaje = 0;
	END IF

	IF _porcentaje <> 100 THEN
		LET _mensaje = 'Distribucion de Reaseguro de Suma No Suma 100%, Por Favor Verifique ...';
		INSERT INTO tmp_arreglo(
		no_reclamo,     
		no_poliza,	   
		no_unidad,      
		no_documento,   
		fecha_siniestro,
		vig_ini_pol,  	
		vig_fin_pol,			
		mensaje		   	
		)
		VALUES(
		v_noreclamo,
		v_nopoliza,
		v_nounidad,
		v_nodocumento,
		v_fechasinis,
		v_vigencia_inic,
		v_vigencia_final,
		_mensaje
		);
		CONTINUE FOREACH ;
	END IF


	SELECT SUM(porc_partic_prima)
	  INTO _porcentaje
	 FROM emireaco
	WHERE no_poliza       = v_nopoliza
	  AND no_unidad       = v_nounidad
	  AND no_cambio       = _no_cambio
	  AND cod_cober_reas  = _cod_cober_reas;

	IF _porcentaje IS NULL THEN
		LET _porcentaje = 0;
	END IF

	IF _porcentaje <> 100 THEN
		LET _mensaje = 'Distribucion de Reaseguro de Prima No Suma 100%, Por Favor Verifique ...';
		INSERT INTO tmp_arreglo(
		no_reclamo,     
		no_poliza,	   
		no_unidad,      
		no_documento,   
		fecha_siniestro,
		vig_ini_pol,  	
		vig_fin_pol,			
		mensaje		   	
		)
		VALUES(
		v_noreclamo,
		v_nopoliza,
		v_nounidad,
		v_nodocumento,
		v_fechasinis,
		v_vigencia_inic,
		v_vigencia_final,
		_mensaje
		);
		CONTINUE FOREACH ;
	END IF


	-- Facultativos

	SELECT SUM(porc_partic_reas)
	 INTO _porcentaje
	 FROM emireafa
	WHERE no_poliza       = v_nopoliza
	  AND no_unidad       = v_nounidad
	  AND no_cambio       = _no_cambio
	  AND cod_cober_reas  = _cod_cober_reas;

	IF _porcentaje IS NOT NULL THEN
		IF _porcentaje <> 100 THEN
			LET _mensaje = 'Distribucion de Reaseguro de Facultativos No Suma 100%, Por Favor Verifique ...';
			INSERT INTO tmp_arreglo(
			no_reclamo,     
			no_poliza,	   
			no_unidad,      
			no_documento,   
			fecha_siniestro,
			vig_ini_pol,  	
			vig_fin_pol,			
			mensaje		   	
			)
			VALUES(
			v_noreclamo,
			v_nopoliza,
			v_nounidad,
			v_nodocumento,
			v_fechasinis,
			v_vigencia_inic,
			v_vigencia_final,
			_mensaje
			);
			CONTINUE FOREACH ;
		END IF
	END IF


END FOREACH

--Recorre la tabla temporal y asigna valores a variables de salida
FOREACH WITH HOLD
 SELECT no_reclamo,     
		no_poliza,	   
		no_unidad,      
		no_documento,   
		fecha_siniestro,
		vig_ini_pol,  	
        vig_fin_pol,	
 		mensaje		   	
   INTO v_noreclamo,
        v_nopoliza,
		v_nounidad,
		v_nodocumento,
		v_fechasinis,
		v_vigencia_inic,
		v_vigencia_final,
		_mensaje
   FROM tmp_arreglo

	RETURN v_noreclamo,
		   v_nopoliza,
		   v_nounidad,
		   v_nodocumento,
		   v_fechasinis,
		   v_vigencia_inic,
		   v_vigencia_final,
		   _mensaje
		   WITH RESUME; 

END FOREACH
DROP TABLE tmp_arreglo;
--:):x:-/:O>:)0:):(:xX-(:((:B;):">:>:))=;:D:pB-):|I-)

END PROCEDURE

