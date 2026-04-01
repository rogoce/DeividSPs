-- Procedimiento para obtener las Pre_existencias 
-- Creado    : 16-Julio-2007 - Autor: Rub‚n Arn ez
-- SIS v.2.0 - DEIVID, S.--.

DROP PROCEDURE sp_pro187;

 create procedure sp_pro187(a_no_poliza char(10), a_unidad char(5))

returning CHAR(100); -- 1. Nombre de las exclusiones
		  
define _cod_procedimiento char(5);
define _nom_procedimiento char(100);
define _renglon smallint;
       					  
{drop table if exists tmp_sppro187;
CREATE TEMP TABLE tmp_sppro187(        
		no_poliza char(10), 
		no_unidad char(5),
		renglon smallint,	 
		nom_procedimiento char(100),	
		PRIMARY KEY (no_poliza, no_unidad,renglon)
		) WITH NO LOG;
}		
SET ISOLATION TO DIRTY READ;

let _renglon = 0;
-- Seleccionamos todas las Exclusiones por polizas y unidad  del ramo de Salud
   	  	   
	 
		foreach 
			select cod_procedimiento
			  into _cod_procedimiento
			  from emipreas
			 where no_poliza             = a_no_poliza
		       and no_unidad             = a_unidad

			select nombre 
			  into _nom_procedimiento
			  from emiproce
			 where cod_procedimiento     = _cod_procedimiento;
			 
			 let _renglon = _renglon + 1;
			 
			{begin
				on exception in(-239)		
				end exception
			insert into tmp_sppro187			
			values ( a_no_poliza,
					 a_unidad,
					 _renglon,		
					_nom_procedimiento);				
			end}	 			 
			     
		   	return  _nom_procedimiento	 --1 Nombre de las Exclusiones
					
			 with resume;
	   
  
 end foreach; 
end procedure;
