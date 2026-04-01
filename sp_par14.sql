DROP PROCEDURE sp_par14;

CREATE PROCEDURE "informix".sp_par14()
RETURNING CHAR(20),
		  CHAR(10),
		  CHAR(3);

DEFINE _no_poliza CHAR(5);
DEFINE _no_cambio CHAR(3);
DEFINE _cantidad  INTEGER;
DEFINE _documento CHAR(20);

BEGIN

SET ISOLATION TO DIRTY READ;

FOREACH
 select no_poliza,
        no_cambio
   into _no_poliza,
        _no_cambio
   from emihcmm
  WHERE no_cambio = '000'

	SELECT COUNT(*)
	  INTO _cantidad
	  FROM emihcmd
	 WHERE no_poliza = _no_poliza
	   AND no_cambio = _no_cambio;

	IF _cantidad IS NULL THEN
		LET _cantidad = 0;
	END IF

	IF _cantidad = 0 THEN

		DELETE FROM emihcmm
		 WHERE no_poliza = _no_poliza
		   AND no_cambio = _no_cambio;

		SELECT no_documento
		  INTO _documento
		  FROM emipomae
		 WHERE no_poliza = _no_poliza;
		  		
		RETURN _documento,
			   _no_poliza,
		       _no_cambio
			   WITH RESUME;

	END IF

END FOREACH

END

END PROCEDURE;