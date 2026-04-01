-- Procedimiento que cambia cod_vendedor de agt_vendnew
-- Creado : 11/03/2020 - Autor: Henry Giron

drop procedure sp_par371;
create procedure "informix".sp_par371()
  returning char(5) as cod_agente_agtagent, 
			char(50) as nombre_agente,
			char(3) as cod_vendedor_agtagent,
			char(3) as cod_vendedor_actual,			
			char(3) as cod_vendedor_nuevo,
			char(3) as cod_vendedor_parpromo,
			char(3) as cod_agencia,
			char(3) as cod_ramo;	  

define _cod_agente		       char(5);
define _cod_agente_agtagent    char(5);
define _cod_vendedor_agtagent  char(3);
define _cod_vendedor_actual    char(3);
define _cod_vendedor_nuevo     char(3);			
define _cod_vendedor_parpromo  char(3);		
define _nombre_agente	char(50);
define _cod_agencia		char(3);
define _cod_ramo	    char(3);

--SET DEBUG FILE TO "sp_sp_par371.trc";      
--TRACE ON;                                                                    


foreach
	 select cod_agente,
			cod_vendedor_actua,
			cod_vendedor_nuevo
	   into _cod_agente, 
	        _cod_vendedor_actual,
			_cod_vendedor_nuevo
	   from agt_vendnew	         	   
	   
	   	select nombre
		  into _nombre_agente
		  from agtagent
		 where cod_agente = _cod_agente;
	   
	   foreach
		   select cod_agente,
				  cod_vendedor
			into _cod_agente_agtagent, 
				 _cod_vendedor_agtagent	   
		   from agtagent
		   where cod_agente   = _cod_agente		   
		   
		   	   
			 update agtagent
				set cod_vendedor = _cod_vendedor_nuevo
			  where cod_agente   = _cod_agente
				and cod_vendedor = _cod_vendedor_actual; 
			
	   
		   foreach
			   select cod_vendedor, 
					   cod_agencia,
					   cod_ramo
			  into _cod_vendedor_parpromo,
				  _cod_agencia,
				  _cod_ramo
			  from parpromo
			 where cod_agente  = _cod_agente
			 
			 update parpromo
				set cod_vendedor = _cod_vendedor_nuevo
			  where cod_agente   = _cod_agente
			    and cod_vendedor = _cod_vendedor_parpromo; 
				
			return	_cod_agente_agtagent, 
			        _nombre_agente,
					_cod_vendedor_agtagent,
                    _cod_vendedor_actual,
					_cod_vendedor_nuevo,
					_cod_vendedor_parpromo,
					_cod_agencia,
				    _cod_ramo
					with resume;
					
			end foreach			
			
			

			
			
	end foreach					

end foreach

--return 0, "Actualizacion Exitosa";

end procedure