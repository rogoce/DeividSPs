DROP PROCEDURE sp_proe30;

CREATE PROCEDURE "informix".sp_proe30(a_cia CHAR(3),a_agencia CHAR(3),a_fecha DATE)
--RETURNING INT;
RETURNING CHAR(10), 	--poliza
		  CHAR(20);		--documento

DEFINE _no_poliza       CHAR(10); 
DEFINE _no_documento    CHAR(20);
DEFINE _direccion_1     CHAR(50);
DEFINE _direccion_2     CHAR(50);
DEFINE _telefono1       CHAR(10);
DEFINE _telefono2       CHAR(10);
DEFINE _cod_asegurado   CHAR(10); 
DEFINE _prima_asegurado DEC(16,2);
DEFINE v_desc_ramo,v_descr_cia      CHAR(50);
DEFINE _no_unidad,_cod_cobertura    CHAR(5);
DEFINE _nombre_subramo,_nombre_formadepago,_nombre_perpago  CHAR(50); 
DEFINE _nombre_cliente  CHAR(100); 
DEFINE _fecha			DATE;
DEFINE _edad			INTEGER;
DEFINE _vigencia_inic   DATE;
DEFINE _fecha_hoy       DATE;
DEFINE _cod_ramo,_cod_formapag,_cod_perpago CHAR(3);
DEFINE _cod_subramo     CHAR(3);
DEFINE v_filtros        CHAR(255);
DEFINE _ano_vigenci,_dependientes,cant    INTEGER;
DEFINE _porc_recargo    DEC(5,2);
DEFINE _ano_proceso,_tipo_incendio     SMALLINT;
DEFINE _ano_vigencia    INTEGER;

SET ISOLATION TO DIRTY READ;
LET _fecha_hoy = TODAY;
LET v_descr_cia = sp_sis01(a_cia);
let cant = 0;
--polizas vigentes a la fecha
CALL sp_pro03(a_cia,a_agencia,_fecha_hoy,'001;') RETURNING v_filtros;

{FOREACH
 SELECT no_poliza,
		no_documento,
		cod_ramo
   INTO _no_poliza,
		_no_documento,
		_cod_ramo
   FROM temp_perfil
  WHERE seleccionado = 1

    FOREACH
		SELECT no_unidad
		  INTO _no_unidad
		  FROM emipouni
		 WHERE no_poliza = _no_poliza

	    LET _cod_cobertura = NULL;
	    FOREACH	
			SELECT cod_cobertura
			  INTO _cod_cobertura
			  FROM emipocob
			 WHERE no_poliza     = _no_poliza
			   AND no_unidad     = _no_unidad

			IF _cod_cobertura = "00004" OR _cod_cobertura = "00090" THEN
				UPDATE temp_perfil
				   SET seleccionado = 0	
				 WHERE no_poliza    = _no_poliza;
				EXIT FOREACH;
			END IF
		END FOREACH

	END FOREACH
END FOREACH}
		   --AND cod_cobertura = "00004";   --lucro cesante

		   --AND cod_cobertura = "00090";   --saqueo(contenido)


{		IF _cod_cobertura IS NULL THEN
			CONTINUE FOREACH;
		ELSE
			UPDATE emipouni
			   SET tipo_incendio = 3	
			 WHERE no_poliza     = _no_poliza
			   AND no_unidad     = _no_unidad;
			   let cant = cant + 1;
		END IF

		RETURN v_descr_cia,
			   _no_documento,
			   _no_unidad	
			   WITH RESUME;

	END FOREACH
END FOREACH
	RETURN cant;
DROP TABLE temp_perfil;}

{FOREACH
 SELECT no_poliza,
		no_documento,
		cod_ramo
   INTO _no_poliza,
		_no_documento,
		_cod_ramo
   FROM emipomae
  WHERE actualizado = 1
    AND fecha_suscripcion = a_fecha
    AND cod_ramo = "001" 

	    LET _tipo_incendio = NULL;
   FOREACH	
		SELECT no_unidad,
			   tipo_incendio
		  INTO _no_unidad,
			   _tipo_incendio	
		  FROM emipouni
		 WHERE no_poliza = _no_poliza

		--IF _tipo_incendio IS NULL THEN
			   RETURN _no_documento,
			   		  _no_unidad	
			   WITH RESUME;
		--END IF
   END FOREACH}
FOREACH
 SELECT no_poliza
   INTO _no_poliza
   FROM temp_perfil
  WHERE seleccionado = 1
  GROUP BY no_poliza

	 FOREACH
		 SELECT no_poliza,
				no_documento
		   INTO _no_poliza,
				_no_documento
		   FROM temp_perfil
		  WHERE seleccionado = 1
			AND no_poliza = _no_poliza
			EXIT FOREACH;
	 END FOREACH

   RETURN _no_poliza,
		  _no_documento
   WITH RESUME;
END FOREACH
DROP TABLE temp_perfil;
END PROCEDURE;
