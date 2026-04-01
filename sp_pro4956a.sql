--------------------------------------------------------
--      EMICARTASAL2        --
--      CAMBIO DE CORREDOR  --
---     Federico Coronado - 05/06/2017 --
--------------------------------------------------------
drop procedure sp_pro4956a;
create procedure sp_pro4956a(a_no_poliza char(10));
																																												  
begin

define _no_documento	char(20);
define _tipo_cambio     integer;
define _cnt_ducruet     integer; 
define _cod_agente		char(5);
define _nombre_agente   varchar(50);
define _cod_ramo        char(3);


set isolation to dirty read;

--	set debug file to "sp_pro4956a.trc";
--	trace on;

	select no_documento,
		   cod_ramo
	  into _no_documento,
		   _cod_ramo
	  from emipomae 
	 where no_poliza = a_no_poliza;

	let _cnt_ducruet = 0;

	if _cod_ramo = '018' then	
		select count(*) 
		  into _cnt_ducruet
		  from emipoagt
		 where no_poliza = a_no_poliza
		   and cod_agente in ('00815','00035','02154');
			
		if _cnt_ducruet > 0 then
			let _tipo_cambio = 3;
			let _nombre_agente = 'DUCRUET';
		else
		
			let _tipo_cambio = 0;
			
			foreach
				select cod_agente
				  into _cod_agente
				  from emipoagt
				 where no_poliza = a_no_poliza
				exit foreach;
			end foreach
			
			select nombre
			  into _nombre_agente
			  from agtagent
			 where cod_agente  = _cod_agente;
			
		end if

		update emicartasal2
		   set tipo_cambio 		= _tipo_cambio,
			   nombre_agente 	= _nombre_agente
		 where emicartasal2.no_documento = _no_documento;

	end if
end

end procedure  

 
		