-- Verificacion de la Reserva entre Rectrmae y Rectrcob

DROP PROCEDURE sp_par03;

CREATE PROCEDURE "informix".sp_par03(
a_compania CHAR(3), 
a_agencia CHAR(3)
) RETURNING CHAR(20),
			CHAR(10),
			DEC(16,2),
			DEC(16,2),
			char(10);

DEFINE _no_reclamo		CHAR(10);
DEFINE _numrecla		CHAR(20);
DEFINE _variacion		DEC(16,2);
DEFINE _reserva			DEC(16,2);
DEFINE _transaccion		CHAR(10);
DEFINE _no_tranrec		CHAR(10);

SET ISOLATION TO DIRTY READ;

FOREACH
 SELECT variacion,
		no_tranrec,
		no_reclamo,
		transaccion
   INTO _variacion,
		_no_tranrec,
		_no_reclamo,
		_transaccion
   FROM rectrmae
  WHERE actualizado = 1
  ORDER BY transaccion

	SELECT SUM(variacion)
	  INTO _reserva
	  FROM rectrcob 
	 WHERE no_tranrec  = _no_tranrec;

	IF _variacion IS NULL THEN
		LET _variacion = 0;
	END IF

	IF _reserva IS NULL THEN
		LET _reserva = 0;
	END IF

	IF _variacion <> _reserva THEN
			
		SELECT numrecla
		  INTO _numrecla
		  FROM recrcmae
		 WHERE no_reclamo = _no_reclamo;

		RETURN _numrecla,
		       _transaccion,
			   _variacion,
			   _reserva,
			   _no_tranrec
			   WITH RESUME;

	END IF

END FOREACH

END PROCEDURE;
