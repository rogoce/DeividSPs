-- Procedimiento para generacion una nota del reclamo
-- 
-- creado: 18/02/2011 - Autor: Amado Perez.

--DROP PROCEDURE sp_rwf85;
CREATE PROCEDURE "informix".sp_rwf85(a_no_tramite CHAR(10), a_fecha DATETIME YEAR TO FRACTION(5), a_nota VARCHAR(250), a_usuario CHAR(8));  

DEFINE _no_reclamo			CHAR(10);

SET ISOLATION TO DIRTY READ;

select no_reclamo into _no_reclamo from recrcmae where no_tramite = a_no_tramite;
 
SET LOCK MODE TO WAIT;

Insert into recnotas (no_reclamo, fecha_nota, desc_nota, user_added)
              values (_no_reclamo, a_fecha, a_nota, a_usuario); 

SET ISOLATION TO DIRTY READ;

END PROCEDURE
