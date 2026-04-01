--******************************************************************************************************************************
-- Procedimiento que genera el Reporte para consurso a Roma 2017 para los corredores
--******************************************************************************************************************************

--execute procedure sp_che86('001','001')
-- Creado    : 16/02/2012 - Autor: Armando Moreno M.

-- SIS v.2.0 - DEIVID, S.A.

DROP PROCEDURE prueba_eliminar;

CREATE PROCEDURE prueba_eliminar()
RETURNING SMALLINT;--,datetime year to fraction(5);

--delete from milan08;
truncate table milan08;
--truncate table tmp_concurso;

update statistics for table milan08;
--update statistics for table tmp_concurso;

--let _fecha_proceso = sp_sis40();
return 0;
END PROCEDURE; 