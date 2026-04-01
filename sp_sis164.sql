--Procedure que retorna si la poliza tiene reclamo abierto y es de patrimonial

DROP PROCEDURE sp_sis164;
--Armando Moreno 29/12/2011

CREATE PROCEDURE "informix".sp_sis164(a_no_poliza CHAR(10))
RETURNING INTEGER;

define _cnt          smallint;
--define _cod_ramo     char(3);

SET ISOLATION TO DIRTY READ;

BEGIN

	select count(*)
	  into _cnt
	  from recrcmae
	 where no_poliza       = a_no_poliza
	   and estatus_reclamo = "A"
	   and actualizado     = 1;

	if _cnt > 0 then --Tiene Reclamo Abierto

		return 1;

    end if

RETURN 0;

END

END PROCEDURE;
