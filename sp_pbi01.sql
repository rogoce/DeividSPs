-- PBI 
-- Devuelve Información para la tabla dimLOB
-- Creado    : 27/07/2021 - Autor: Armando Moreno M.

DROP PROCEDURE sp_pbi01;
CREATE PROCEDURE sp_pbi01()
RETURNING  smallint    as CodArea,
           varchar(50) as Descripcion;

           
DEFINE _cod_area			smallint;
DEFINE _descripcion			varchar(50);
	

SET ISOLATION TO DIRTY READ;
 -- set debug file to "sp_pbi01.trc";	
 -- trace on;

select * from prdramo
into temp prdramotmp;

update prdramotmp
   set cod_area = 3
 where cod_ramo = '008';

FOREACH
	select decode(cod_area,0,'PATRIMONIALES',1,'AUTOMOVIL',2,'PERSONAS',3,'FIANZAS'),
	       cod_area
	  into _descripcion,
	       _cod_area
	  from prdramotmp
     group by cod_area
     order by 2

	RETURN _cod_area, _descripcion WITH RESUME;

END FOREACH
drop table prdramotmp;
END PROCEDURE	  