-- Procedimiento que verifica si cambia el evento de un reclamo desde el paso de digitalizacion en WF

-- Creado    : 04/04/2014 - Autor: Amado Perez  

drop procedure ap_rehab;

create procedure ap_rehab() 
returning int, VARCHAR(100);

define _prima         	  dec(16,2);
define _descuento     	  dec(16,2);
define _recargo       	  dec(16,2);
define _prima_neta    	  dec(16,2);
define _impuesto      	  dec(16,2);
define _prima_bruta   	  dec(16,2);
define _prima_suscrita	  dec(16,2);
define _prima_retenida	  dec(16,2);
define _suma_asegurada	  dec(16,2);
define _gastos   		  dec(16,2);
define _no_unidad         char(10);
define _signo             smallint;
define _prima_anual_cob	  dec(16,2);
define _prima_cob     	  dec(16,2);
define _descuento_cob 	  dec(16,2);
define _recargo_cob   	  dec(16,2);
define _prima_neta_cob	  dec(16,2);
define _cod_cobertura     char(5);
define _cod_cober_reas	  char(3);
define _orden			  smallint;
define _suma_asegurada_con dec(16,2);
define _prima_con		   dec(16,2);



let _signo = -1;

--return 0, "Actualizacion Exitosa";
--SET DEBUG FILE TO "ap_rehab.trc"; 
--trace on;


set isolation to dirty read;

delete from endedcob
  where no_poliza = '58337'
    and no_endoso = '00448'
	and no_unidad not in (select no_unidad from endeduni where no_poliza = '58337' and no_endoso = '00447'); 

delete from endunide
  where no_poliza = '58337'
    and no_endoso = '00448'
	and no_unidad not in (select no_unidad from endeduni where no_poliza = '58337' and no_endoso = '00447');
	 
delete from endunire
  where no_poliza = '58337'
    and no_endoso = '00448'
	and no_unidad not in (select no_unidad from endeduni where no_poliza = '58337' and no_endoso = '00447'); 


delete from endeduni
  where no_poliza = '58337'
    and no_endoso = '00448'
	and no_unidad not in (select no_unidad from endeduni where no_poliza = '58337' and no_endoso = '00447'); 

foreach
	select no_unidad,
	       prima,         
		   descuento,     
		   recargo,       
		   prima_neta,    
		   impuesto,      
		   prima_bruta,   
		   prima_suscrita,
		   prima_retenida,
		   suma_asegurada,
		   gastos
      into _no_unidad,
           _prima,         
      	   _descuento,     
      	   _recargo,       
      	   _prima_neta,    
      	   _impuesto,      
      	   _prima_bruta,   
      	   _prima_suscrita,
      	   _prima_retenida,
      	   _suma_asegurada,
           _gastos   
	  from endeduni
	 where no_poliza      = '58337'
	   and no_endoso      = '00447'

    update endeduni		   
	   set prima          =  _prima * _signo,         
		   descuento      =  _descuento * _signo,     
		   recargo        =  _recargo * _signo,       
		   prima_neta     =  _prima_neta * _signo,    
		   impuesto       =  _impuesto * _signo,      
		   prima_bruta    =  _prima_bruta * _signo,   
		   prima_suscrita =  _prima_suscrita * _signo,
		   prima_retenida =  _prima_retenida * _signo,
	   	   suma_asegurada =  _suma_asegurada * _signo,
	   	   gastos		  =  _gastos 
	 where no_poliza      = '58337'
	   and no_endoso      = '00448'
	   and no_unidad      = _no_unidad;

    foreach
		select cod_cobertura,
		       prima_anual,
			   prima,     
			   descuento, 
			   recargo,   
			   prima_neta
		  into _cod_cobertura,
		       _prima_anual_cob,
			   _prima_cob,     
			   _descuento_cob, 
		  	   _recargo_cob,   
		  	   _prima_neta_cob
		  from endedcob
		 where no_poliza      = '58337'
		   and no_endoso      = '00447'
		   and no_unidad      = _no_unidad
		   and prima         <> 0

		update endedcob
		   set prima_anual   =  _prima_anual_cob * _signo,
			   prima         =  _prima_cob * _signo,     
			   descuento     =  _descuento_cob * _signo, 
			   recargo       =  _recargo_cob * _signo,   
			   prima_neta    =  _prima_neta_cob * _signo
		 where no_poliza     = '58337'
		   and no_endoso     = '00448'
		   and no_unidad     = _no_unidad
		   and cod_cobertura = _cod_cobertura;
   	end foreach

	foreach
		select cod_cober_reas, 
			   orden,
			   suma_asegurada,
			   prima
		  into _cod_cober_reas,
			   _orden,
			   _suma_asegurada_con,
			   _prima_con
		  from emifacon
		 where no_poliza      = '58337'
		   and no_endoso      = '00447'
		   and no_unidad      = _no_unidad

		update emifacon
		   set suma_asegurada = _suma_asegurada_con * _signo,
		       prima          = _prima_con * _signo
		 where no_poliza      = '58337'
		   and no_endoso      = '00448'
		   and no_unidad      = _no_unidad
		   and cod_cober_reas = _cod_cober_reas
		   and orden          = _orden;
	end foreach
end foreach

select prima_suscrita,
	   prima_retenida,
	   prima,         
	   descuento,     
	   recargo,       
	   suma_asegurada,
	   prima_neta,    
	   impuesto, 	 
	   prima_bruta	
  into _prima_suscrita,
	   _prima_retenida,
	   _prima,         
	   _descuento,     
	   _recargo,       
	   _suma_asegurada,
	   _prima_neta,    
	   _impuesto, 	 
	   _prima_bruta	
  from endedmae
 where no_poliza      = '58337' 	  
   and no_endoso      = '00447';	  		
			 
update endedmae
   set prima_suscrita = _prima_suscrita * _signo,
	   prima_retenida = _prima_retenida * _signo,
       prima          = _prima * _signo,         
       descuento      = _descuento * _signo,     
	   recargo        = _recargo,       
	   suma_asegurada = _suma_asegurada * _signo,
  	   prima_neta     = _prima_neta * _signo,    
  	   impuesto 	  = _impuesto * _signo, 	 
  	   prima_bruta	  = _prima_bruta * _signo	
 where no_poliza      = '58337'
   and no_endoso      = '00448';

return 0, "Exitoso";
end procedure