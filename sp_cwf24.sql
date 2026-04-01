-- Procedimiento para generacion de cheques
-- 
-- creado: 14/09/2009 - Autor: Amado Perez.

DROP PROCEDURE sp_cwf24;
CREATE PROCEDURE "informix".sp_cwf24(a_usuario CHAR(20)) 
			RETURNING CHAR(1);  

DEFINE _letra CHAR(1);


SET ISOLATION TO DIRTY READ;


SELECT tipo_firma
  INTO _letra
  FROM wf_firmas 
WHERE windows_user = a_usuario;

 IF _letra IS NULL THEN
	LET _letra = "";
 END IF


 RETURN _letra;
END PROCEDURE