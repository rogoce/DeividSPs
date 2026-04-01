-- Procedimiento para Obtener los Dependientes 
-- Creado    : 16-Julio-2007 - Autor: Rub‚n Arn ez
-- SIS v.2.0 - DEIVID, S.--.

DROP PROCEDURE sp_pro188;

 create procedure sp_pro188(a_no_poliza char(10), a_unidad char(5), a_cod_cliente char(10))

returning  char(100); -- 1. Nombre del Procedimiento.
   
define _cod_procedimiento char(5);
define _nom_procedimiento char(100);
       					  
  {drop table if exists tmp_sppro188;
CREATE TEMP TABLE tmp_sppro188(        
		no_poliza char(10), 
		no_unidad char(5),
		cod_cliente char(10),	 
		nom_procedimiento char(100),	
		PRIMARY KEY (no_poliza, no_unidad,cod_cliente)
		) WITH NO LOG;}
		
SET ISOLATION TO DIRTY READ;

foreach 
	select cod_procedimiento
	  into _cod_procedimiento
	  from emiprede
	 where no_poliza   = a_no_poliza
       and no_unidad   = a_unidad
	   and cod_cliente = a_cod_cliente

	select nombre 
	  into _nom_procedimiento
	  from emiproce
	 where cod_procedimiento  = _cod_procedimiento;	
	 
		{begin
			on exception in(-239)		
			end exception
		insert into tmp_sppro188			
		values ( a_no_poliza,
				 a_unidad,
				 a_cod_cliente,		
				_nom_procedimiento);				
		end}	 

	return _nom_procedimiento 	-- 4.Nombre del Procedimiento 
	  with resume;

end foreach;

end procedure;
