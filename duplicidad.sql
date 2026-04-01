-- Procedimiento Para Borrar transacciones de auto sin # de incidente
-- 
-- Creado    : 17/12/2004 - Autor: Amado Perez
-- Modificado: 17/12/2004 - Autor: Amado Perez
-- mODIFICADO: 10/08/2005 - Autor: Amado Perez -- Ahora borra la transaccion, no actualizada, que no se usara
--
-- SIS v.2.0 - DEIVID, S.A.

DROP PROCEDURE duplicidad;

CREATE PROCEDURE "informix".duplicidad()
RETURNING CHAR(10), INT;

DEFINE _transaccion     CHAR(10); 
DEFINE _cant     		INT; 

DEFINE _error, _actualizado	    SMALLINT; 

--SET DEBUG FILE TO "sp_sis27.trc";  
--TRACE ON;                                                                 

SET ISOLATION TO DIRTY READ;

CREATE TEMP TABLE tmp_rectr1(
			transaccion     CHAR(10),
			cant           int,
			PRIMARY KEY (transaccion)
			) WITH NO LOG;


FOREACH
	SELECT transaccion
	  INTO _transaccion
	  FROM rectrmae
	 WHERE actualizado = 1

    IF 	_transaccion is null THEN
		LET _transaccion = "";
	END IF

	BEGIN

	    ON EXCEPTION IN(-268, -239)	
			UPDATE tmp_rectr1
			   SET cant = cant + 1
			 WHERE transaccion = _transaccion;

		END EXCEPTION

	    INSERT INTO tmp_rectr1(
		transaccion,
		cant
		)
		VALUES
		(
		_transaccion,
		1
		);
	END

END FOREACH

FOREACH	WITH HOLD
	SELECT transaccion,
	       cant
	  INTO _transaccion,
	       _cant
	  FROM tmp_rectr1
	 WHERE cant > 1

    RETURN _transaccion,
	 	   _cant
	with resume;
END FOREACH
DROP TABLE tmp_rectr1;

END PROCEDURE;
