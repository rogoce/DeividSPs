
--DROP PROCEDURE sp_rec39;		

CREATE PROCEDURE "informix".sp_rec39(a_no_doc CHAR(20))
RETURNING CHAR(10);

		  	
DEFINE _cod_asignacion  CHAR(10);

let _cod_asignacion = "";

SET ISOLATION TO DIRTY READ;

foreach

	SELECT cod_asignacion
	  INTO _cod_asignacion
	  FROM atcdocde
	 WHERE completado         = 0
       AND suspenso          <> 1
	   AND en_mora            = 1
	   AND no_documento       = a_no_doc

	exit foreach;

end foreach


RETURN _cod_asignacion;

END PROCEDURE;
