--******************************************************************************************************************************
-- Procedimiento que elimina los datos de las tablas de concurso
--******************************************************************************************************************************

--execute procedure sp_elimina_datos()
-- Creado    : 29/06/2017- Autor: Jorge Contreras

-- SIS v.2.0 - DEIVID, S.A.

DROP PROCEDURE sp_elimina_datos;

CREATE PROCEDURE sp_elimina_datos()
RETURNING SMALLINT;

/*truncate table milan08;
truncate table fis_concurso;
truncate table fisc_bono;

update statistics for table milan08;
update statistics for table fis_concurso;
update statistics for table fisc_bono;*/

return 0;
END PROCEDURE; 