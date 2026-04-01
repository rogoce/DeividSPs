-- Filtros para el Drop Down dw de Motivos de Cancelacion.
-- Creado : 27/06/2011 -- Autor: Henry Giron.
-- SIS v.2.0 -- DEIVID, S.A.
DROP PROCEDURE sp_co98;
CREATE PROCEDURE "informix".sp_co98(a_rol SMALLINT) RETURNING CHAR(3), CHAR(50);
DEFINE _cod_motivo     CHAR(3); 
DEFINE _nombre         CHAR(50);
DEFINE _tipo_contacto  SMALLINT;
DEFINE _grupo          SMALLINT;
SET ISOLATION TO DIRTY READ;
IF a_rol = 1 or a_rol = 11 or a_rol = 12 THEN 
   -- Gestor de Base de Datos
END IF
FOREACH	WITH HOLD
	select cod_motivo,
		   nombre
      into _cod_motivo,
	       _nombre
	  from avicanmot
     where estatus = 1
  order by nombre,cod_motivo
    return _cod_motivo,
           _nombre
      WITH RESUME;
END FOREACH
END PROCEDURE;