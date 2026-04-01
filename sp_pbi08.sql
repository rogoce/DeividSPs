-- PBI
-- Devuelve Información para la tabla dimEndosos
-- Creado    : 28/07/2021 - Autor: Armando Moreno M.

DROP PROCEDURE sp_pbi08;
CREATE PROCEDURE sp_pbi08(a_fecha1 date, a_fecha2 date) 
RETURNING char(10) as NoPoliza,
          char(5)  as NoEndoso,
		  date     as FechaDesde,
		  date     as FecahHasta;

DEFINE _no_poliza 			          char(10);
DEFINE _no_endoso                     char(5);
DEFINE _vigencia_inic,_vigencia_final DATE;
           
SET ISOLATION TO DIRTY READ;

 -- set debug file to "sp_pbi08.trc";	
 -- trace on;


FOREACH
	select no_poliza,
	       no_endoso,
		   vigencia_inic,
		   vigencia_final
	  into _no_poliza,
		   _no_endoso,
		   _vigencia_inic,
		   _vigencia_final
	  from endedmae
     where actualizado = 1 
	   and fecha_emision >= a_fecha1 and fecha_emision <= a_fecha2
	  order by 1,2 
	 
	RETURN _no_poliza, _no_endoso, _vigencia_inic, _vigencia_final  WITH RESUME;
	
END FOREACH;
END PROCEDURE	  