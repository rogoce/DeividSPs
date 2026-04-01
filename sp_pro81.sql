-- procedimiento para actualizar la ubicacion del cumulo a polizas ya actualizadas.
-- actualiza en emicupol y en endcuend.
-- Creado    : 08/11/2001 - Autor: Armando Moreno M.

DROP PROCEDURE sp_pro81;

CREATE PROCEDURE sp_pro81(a_no_documento CHAR(20), a_no_unidad CHAR(5), a_cod_ubica CHAR(3))
RETURNING INTEGER;

DEFINE v_no_poliza	 	    		CHAR(10);
DEFINE v_no_unidad	 	    		CHAR(5);
DEFINE _cod_ubica		   			CHAR(3);
DEFINE v_no_endoso	 	    		CHAR(5);
DEFINE _error						SMALLINT;

BEGIN
	ON EXCEPTION SET _error 
	 	RETURN _error;         
	END EXCEPTION

FOREACH
	   --POLIZA
		SELECT no_poliza
		  INTO v_no_poliza
		  FROM emipomae
		 WHERE actualizado  = 1
		   AND no_documento = a_no_documento

		SELECT cod_ubica
		  INTO _cod_ubica
		  FROM emicupol
		 WHERE no_poliza = v_no_poliza
		   AND no_unidad = a_no_unidad;

	   --Actualizacion a Emicupol
		IF _cod_ubica IS NOT NULL THEN
			UPDATE emicupol
			   SET cod_ubica = a_cod_ubica
	 		 WHERE no_poliza = v_no_poliza
			   AND no_unidad = a_no_unidad;
		END IF
END FOREACH

FOREACH
	   --ENDOSO
		SELECT no_poliza
		  INTO v_no_poliza
		  FROM endedmae
		 WHERE no_documento = a_no_documento
		   AND actualizado = 1
	  GROUP BY no_poliza
	  ORDER BY no_poliza

		 FOREACH
			SELECT no_endoso
			  INTO v_no_endoso
			  FROM endedmae
			 WHERE no_poliza = v_no_poliza
			 	  	 
			SELECT cod_ubica
			  INTO _cod_ubica
			  FROM endcuend
			 WHERE no_poliza = v_no_poliza
			   AND no_endoso = v_no_endoso
			   AND no_unidad = a_no_unidad;

			IF _cod_ubica IS NOT NULL THEN
				UPDATE endcuend
				   SET cod_ubica = a_cod_ubica
		 		 WHERE no_poliza = v_no_poliza
				   AND no_endoso = v_no_endoso
				   AND no_unidad = a_no_unidad;
		    END IF
		 END FOREACH
END FOREACH
END

RETURN 0;

END PROCEDURE;