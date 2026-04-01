--******************************************************************************************************************************
-- Procedimiento que elimina los datos de las tablas de Deivid_bo
--******************************************************************************************************************************

--execute procedure sp_elimina_datos()
-- Creado    : 29/06/2017- Autor: Jorge Contreras

-- SIS v.2.0 - DEIVID, S.A.

DROP PROCEDURE sp_elimina_datos_bo;

CREATE PROCEDURE sp_elimina_datos_bo()
RETURNING SMALLINT;

truncate table boindancon;
truncate table boindmul;
truncate table boendedmae;
truncate table fis_multi;

update statistics for table boindancon;
update statistics for table boindmul;
update statistics for table boendedmae;
update statistics for table fis_multi;

return 0;
END PROCEDURE; 