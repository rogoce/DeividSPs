-- Procedimiento para generacion una nota del reclamo
-- 
-- creado: 18/02/2011 - Autor: Amado Perez.

DROP PROCEDURE sp_rwf105;
CREATE PROCEDURE "informix".sp_rwf105(a_no_reclamo CHAR(10), a_nota VARCHAR(250), a_usuario CHAR(8))
                  RETURNING integer, varchar(50);  

DEFINE _no_reclamo			CHAR(10);
DEFINE _error               integer;

--SET DEBUG FILE TO "sp_rwf104.trc";
--TRACE ON;


BEGIN
ON EXCEPTION SET _error 
 	RETURN _error, "Error al insertar en RECNOTAS";         
END EXCEPTION 


SET LOCK MODE TO WAIT;

Insert into recnotas (no_reclamo, fecha_nota, desc_nota, user_added)
              values (a_no_reclamo, current, a_nota, a_usuario); 

SET ISOLATION TO DIRTY READ;
END

return 0, "Se inserto en RECNOTAS";

END PROCEDURE
