-- Procedimiento para generacion de cheques
-- 
-- creado: 14/09/2009 - Autor: Amado Perez.

--DROP PROCEDURE sp_rwf73;
CREATE PROCEDURE "informix".sp_cwf16(a_requis CHAR(10), a_firma1 VARCHAR(20)) 


	SET LOCK MODE TO WAIT;

	UPDATE chqchmae 
	SET firma2 = a_firma1
	WHERE no_requis = a_requis
	  AND en_firma = 1;


END PROCEDURE