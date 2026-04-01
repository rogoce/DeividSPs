-- Procedimiento para cotizar
-- Creado:	23/09/2015 - Autor: Federico Coronado
-- SIS v.2.0 - DEIVID, S.A.

drop procedure sp_web45;
 
create procedure sp_web45(a_cod_producto CHAR(5), a_cod_cobertura char(5))
returning char(10),
          varchar(100),
          varchar(50),
          varchar(50),
          dec(16,2),
          char(1),
          dec(5,2),
          char(1),
          integer,
          char(1),	 
          dec(16,2),
          smallint,
          dec(5,2),
          smallint,
          dec(16,2),
          smallint,
		  dec(16,2),
		  dec(16,2),
		  integer,
		  dec(16,2);
		  
define _cod_cobertura 		char(10);
define _nombre        		varchar(100);
define _desc_limite1	    varchar(50);	
define _desc_limite2 		varchar(50);
define _valor_tar_unica		dec(16,2);
define _valor_asignar		char(1);
define _porc_suma			dec(5,2);
define _busqueda			char(1);
define _factor_division		integer;
define _tipo_valor 			char(1);	                      
define _deducible			dec(16,2);
define _acepta_desc			smallint;
define _descuento_max		dec(5,2);
define _tipo_descuento		smallint;
define _deducible_min       dec(16,2);
define _tipo_deducible		smallint;
define _val_min             dec(16,2);
define _val_max             dec(16,2);
define _cob_requerida       integer;
define _prima_min           dec(16,2);
       
--set debug file to "sp_web33.trc";
--trace on;

set isolation to dirty read;

	foreach
		SELECT prdcober.cod_cobertura, 
			   nombre, 
			   prdcobpd.desc_limite1, 
			   prdcobpd.desc_limite2, 
			   valor_tar_unica, 
			   valor_asignar, 
			   porc_suma, 
			   busqueda, 
			   factor_division,
			   tipo_valor, 				                      
			   deducible, 
			   acepta_desc, 
			   descuento_max, 
			   tipo_descuento, 
			   deducible_min, 
			   tipo_deducible,
			   val_min,   
			   val_max,
			   cob_requerida,
			   prima_min
		  into _cod_cobertura, 	
			   _nombre,        	
			   _desc_limite1,	
			   _desc_limite2, 	
			   _valor_tar_unica,
			   _valor_asignar,	
			   _porc_suma,		
			   _busqueda,		
			   _factor_division,	
			   _tipo_valor, 		
			   _deducible,		
			   _acepta_desc,		
			   _descuento_max,	
			   _tipo_descuento,	
			   _deducible_min,  
			   _tipo_deducible,
			   _val_min,   
               _val_max,
			   _cob_requerida,
			   _prima_min
		  FROM prdcober inner join prdcobpd on prdcober.cod_cobertura = prdcobpd.cod_cobertura
		 where prdcobpd.cod_producto = a_cod_producto
		   and prdcober.cod_cobertura = a_cod_cobertura
		   and cob_default = '1'
	  order by orden
		if _deducible_min is null then
			let _deducible_min = 0;
		end if
		if _tipo_deducible is null then
			let _tipo_deducible = 0;
		end if
	return _cod_cobertura, 	
		   _nombre,        	
		   _desc_limite1,	
		   _desc_limite2, 	
		   _valor_tar_unica,	
		   _valor_asignar,	
		   _porc_suma,		
		   _busqueda,		
		   _factor_division,	
		   _tipo_valor, 		
		   _deducible,	
		   _acepta_desc,	
		   _descuento_max,	
		   _tipo_descuento,	
		   _deducible_min,   
		   _tipo_deducible,
		   _val_min,   
           _val_max,
		   _cob_requerida,
		   _prima_min
		   WITH RESUME;
	end foreach;
end procedure