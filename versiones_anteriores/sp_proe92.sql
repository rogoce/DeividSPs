-- Procedimiento para listar endosos especiales a imprimir por ramo y poliza -- 
-- Creado    : 17/02/2022 - Autor: Henry Giron CASO SD# 2468 JEPEREZ
-- SIS v.2.0 - DEIVID, S.A.

DROP PROCEDURE sp_proe92;
CREATE PROCEDURE "informix".sp_proe92(a_ramo CHAR(3),a_no_poliza CHAR(10) DEFAULT "*") 
RETURNING   CHAR(255);	-- nombre_endoso

DEFINE _nombre_endoso  CHAR(255);
DEFINE a_no_endoso     CHAR(5);

SET ISOLATION TO DIRTY READ;

LET a_no_endoso = '00000';
FOREACH
  SELECT lower(a.nombre_endoso)
	INTO _nombre_endoso
    FROM endespimp a,endesppol b
   WHERE b.no_poliza  = a_no_poliza
     and b.no_endoso  = a_no_endoso
     and b.cod_ramo   = a.cod_ramo
     and a.cod_ramo   = b.cod_ramo
     and b.cod_endoso = a.cod_endoso
     and a.cod_ramo   = a_ramo
     AND a.activo = '1'
     order by 1 asc

	

	RETURN _nombre_endoso		   
		   WITH RESUME;   	

END FOREACH
END PROCEDURE	

