

DROP PROCEDURE sp_sis524;
CREATE PROCEDURE sp_sis524(a_no_remesa CHAR(10))
RETURNING smallint;

DEFINE _tipo_formato 	smallint;

SET ISOLATION TO DIRTY READ;

FOREACH
	select tipo_formato
	  into _tipo_formato
	  from cobpaex0
	 where no_remesa_ancon = a_no_remesa
	 
	exit foreach;
END FOREACH

RETURN _tipo_formato;

END PROCEDURE;