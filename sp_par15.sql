-- Verificacion de Endosos de Cambio de Vigencia para Polizas
-- con Coaseguro Mayoritario

DROP PROCEDURE sp_par15;

CREATE PROCEDURE "informix".sp_par15()
RETURNING CHAR(10),
		  CHAR(5),
		  CHAR(3),
		  DATE,
		  DATE,
		  CHAR(3),
		  DATE,
		  DATE;

DEFINE _no_poliza       CHAR(10);
DEFINE _no_endoso       CHAR(5); 
DEFINE _no_cambio       CHAR(3); 
DEFINE _vigencia_inic   DATE;    
DEFINE _vigencia_final  DATE;    
DEFINE _vigencia_inic2  DATE;    
DEFINE _vigencia_final2 DATE;    
DEFINE _cod_endomov     CHAR(3);
BEGIN

SET ISOLATION TO DIRTY READ;

FOREACH
 select no_poliza,
        no_endoso,
        vigencia_inic,
		vigencia_final,
		cod_endomov
   into _no_poliza,
        _no_endoso,
		_vigencia_inic,
		_vigencia_final,
		_cod_endomov
   from endedmae
  WHERE actualizado = 1
    AND cod_endomov IN ('001', '019')
  ORDER BY no_poliza, no_endoso

	SELECT MAX(no_cambio)
	  INTO _no_cambio
	  FROM emihcmm
	 WHERE no_poliza = _no_poliza;

	IF _no_cambio IS NOT NULL THEN
		
		SELECT vigencia_inic,
			   vigencia_final
   		  into _vigencia_inic2,
		       _vigencia_final2
		  FROM emihcmm
		 WHERE no_poliza = _no_poliza
		   AND no_cambio = _no_cambio;

{
		IF _cod_endomov = '001' THEN

			UPDATE emihcmm
			   SET vigencia_final = _vigencia_final
			 WHERE no_poliza      = _no_poliza
			   AND no_cambio      = _no_cambio;
		ELSE

			UPDATE emihcmm
			   SET vigencia_final = _vigencia_inic
			 WHERE no_poliza      = _no_poliza
			   AND no_cambio      = _no_cambio;

		END IF
}

		RETURN _no_poliza,
		       _no_endoso,
			   _cod_endomov,
			   _vigencia_inic,
			   _vigencia_final,
			   _no_cambio,
			   _vigencia_inic2,
			   _vigencia_final2
			   WITH RESUME;

	END IF

END FOREACH

END

END PROCEDURE;