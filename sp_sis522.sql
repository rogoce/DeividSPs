

DROP PROCEDURE sp_sis522;
CREATE PROCEDURE sp_sis522(a_no_poliza CHAR(10))
RETURNING CHAR(5);

define _no_unidad char(5);

SET ISOLATION TO DIRTY READ;


FOREACH
	select no_unidad
	  into _no_unidad
	  from emipouni
	 where no_poliza = a_no_poliza
	 
	exit foreach;
END FOREACH

RETURN _no_unidad;

END PROCEDURE;