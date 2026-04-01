-- Procedimiento para generacion de cheques
-- 
-- creado: 14/09/2009 - Autor: Amado Perez.

DROP PROCEDURE sp_rwf75;
CREATE PROCEDURE "informix".sp_rwf75(a_user VARCHAR(20)) 
			RETURNING VARCHAR(50);  

DEFINE _encript_salud VARCHAR(50);

SET ISOLATION TO DIRTY READ;

SELECT encript_salud
  INTO _encript_salud 
  FROM wf_firmas 
 WHERE usuario = a_user;

 IF _encript_salud IS NULL THEN
	LET _encript_salud = "";
 END IF


 RETURN TRIM(_encript_salud);
END PROCEDURE