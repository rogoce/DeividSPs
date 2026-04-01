-- Procedimiento para generacion de cheques
-- 
-- creado: 14/09/2009 - Autor: Amado Perez.

--DROP PROCEDURE sp_rwf80;
CREATE PROCEDURE "informix".sp_rwf80(a_requis CHAR(10)) 
			RETURNING INTEGER;  

DEFINE _incident INTEGER;

--SET LOCK MODE TO WAIT;
SET ISOLATION TO DIRTY READ;

SELECT a.incident
  INTO _incident 
  FROM wf_opago a 
 WHERE a.no_requis = Trim(a_requis);


 RETURN _incident;
END PROCEDURE