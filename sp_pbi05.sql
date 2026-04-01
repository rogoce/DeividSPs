-- PBI 
-- Devuelve Información para la tabla dimCorredor
-- Creado    : 27/07/2021 - Autor: Armando Moreno M.

DROP PROCEDURE sp_pbi05;
CREATE PROCEDURE sp_pbi05()
RETURNING  char(3)     as CodVendedor,
           char(10)    as CodAgente,
		   varchar(50) as Descripcion;

           
DEFINE _descripcion			varchar(50);
define _usuario             char(8);
define _cod_vendedor        char(3);
define _cod_agente          char(10);

SET ISOLATION TO DIRTY READ;
 -- set debug file to "sp_pbi04.trc";	
 -- trace on;

FOREACH
	select cod_vendedor,
	       cod_agente,
	       nombre
	  into _cod_vendedor,
	       _cod_agente,
           _descripcion
      from agtagent

	RETURN _cod_vendedor, _cod_agente, _descripcion WITH RESUME;

END FOREACH
END PROCEDURE	  