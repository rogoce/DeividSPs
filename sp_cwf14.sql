-- Procedimiento para generacion de cheques
-- 
-- creado: 14/09/2009 - Autor: Amado Perez.

DROP PROCEDURE sp_cwf14;
CREATE PROCEDURE "informix".sp_cwf14(a_user VARCHAR(20)) 
			RETURNING VARCHAR(50);  

DEFINE _encript_salud VARCHAR(50);

SET ISOLATION TO DIRTY READ;

SELECT a.encript_salud
  INTO _encript_salud 
  FROM wf_firmas a, insuser b 
 WHERE a.usuario = b.usuario 
   AND b.windows_user = Trim(a_user);

 IF _encript_salud IS NULL THEN
	LET _encript_salud = "";
 END IF


 RETURN TRIM(_encript_salud);
END PROCEDURE