-- Procedimiento para buscar errores
-- 
-- creado: 30/12/2009 - Autor: Amado Perez.

--DROP PROCEDURE sp_sis131;
CREATE PROCEDURE "informix".sp_sis131(a_tipo_error SMALLINT, a_code_error INTEGER) 
			RETURNING VARCHAR(150);  

DEFINE _descripcion VARCHAR(150);

--SET LOCK MODE TO WAIT;
SET ISOLATION TO DIRTY READ;

SELECT descripcion
  INTO _descripcion
  FROM inserror
 WHERE tipo_error = a_tipo_error
   AND code_error = a_code_error;

 RETURN TRIM(_descripcion);

END PROCEDURE