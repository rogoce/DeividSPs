--******************************************************************************************************************************
-- Procedimiento que elimina los datos de las tablas de Deivid_cob
--******************************************************************************************************************************

--execute procedure sp_elimina_datos_cob()
-- Creado    : 29/06/2017- Autor: Jorge Contreras

-- SIS v.2.0 - DEIVID, S.A.

DROP PROCEDURE sp_elimina_datos_cob;

CREATE PROCEDURE sp_elimina_datos_cob()
RETURNING SMALLINT;

truncate table cobmoros;

update statistics for table cobmoros;

return 0;
END PROCEDURE; 