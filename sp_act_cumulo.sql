

--DROP PROCEDURE sp_act_cumulo;
CREATE PROCEDURE sp_act_cumulo(a_no_poliza CHAR(10),a_no_endoso char(5))
RETURNING smallint;
 
define _no_unidad 		char(5);
DEFINE _suma_inc,_suma_ter,_prima_inc,_prima_ter DECIMAL(16,2);
DEFINE _cod_ubica	CHAR(3);
define _opcion 			smallint;
SET ISOLATION TO DIRTY READ;

FOREACH
	SELECT no_unidad
	  INTO _no_unidad
	  FROM endeduni
	 WHERE no_poliza = a_no_poliza
	   AND no_endoso = a_no_endoso
	FOREACH 
		SELECT	cod_ubica,suma_incendio,suma_terremoto,prima_incendio,prima_terremoto,opcion
		  INTO _cod_ubica,_suma_inc,_suma_ter,_prima_inc,_prima_ter,_opcion
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
RETURN 0;
END PROCEDURE 
