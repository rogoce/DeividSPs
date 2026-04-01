-- PBI 
-- Devuelve Información para la tabla dimRamos
-- Creado    : 26/07/2021 - Autor: Armando Moreno M.

DROP PROCEDURE sp_pbi02;
CREATE PROCEDURE sp_pbi02()
RETURNING  smallint    as CodArea,
           char(3)     as CodRamo,
           varchar(50) as Descripcion;

           
DEFINE _cod_area			smallint;
DEFINE _cod_ramo            char(3);
DEFINE _descripcion			varchar(50);
	

SET ISOLATION TO DIRTY READ;
 -- set debug file to "sp_pbi02.trc";	
 -- trace on;

FOREACH
	select cod_area,
	       cod_ramo,
		   nombre
	  into _cod_area,
	       _cod_ramo,
		   _descripcion
	  from prdramo
     order by cod_area
	 
	if _cod_ramo = '008' then
		let _cod_area = 3;
	end if
	
	RETURN _cod_area, _cod_ramo, _descripcion WITH RESUME;

END FOREACH
END PROCEDURE	  