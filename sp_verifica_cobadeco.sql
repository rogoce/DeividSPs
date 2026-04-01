-- SIS v.2.0 - 

drop procedure sp_verifica_cobadeco;

create procedure sp_verifica_cobadeco()
returning	char(21),
			smallint,
			char(100);	-- compania

define _razon			char(100);
define _no_documento	char(20);
define _cod_agente		char(5);
define _no_poliza		char(10);
define _aplica			smallint;

 set debug file to "sp_verifica_cobadeco.trc";      
 trace on; 
foreach
	select no_documento,
		   cod_agente
	  into _no_documento,
		   _cod_agente
	  from cobadeco
	  
	call sp_sis21(_no_documento) returning _no_poliza;
	call sp_cob309a(_no_poliza,_cod_agente) returning _aplica,_razon;
	if _aplica = 1 then
		continue foreach;
	end if
	
	return _no_documento,_aplica,_razon with resume;
end foreach
end procedure