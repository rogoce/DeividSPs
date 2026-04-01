--------------------------------------------------------
--      EMICARTASAL2          --
--      VERIFICACIÓN SI LA POLIZA CAMBIO DE CORREDOR  --
---     Federico Coronado - 05/06/2017 --
--------------------------------------------------------
drop procedure sp_pro4953a;
create procedure sp_pro4953a(a_periodo char(7)) returning smallint;
																																												  
--integer li_imp1, li_imp2, li_envi1, li_envi2, li_envi3, li_envi4																												  
--string ls_periodo,ls_poliza
begin

define _nombre_zona		varchar(50);
define _nombre_cliente	varchar(100);
define _fecha_desde     date;
define _fecha_hasta     date;
define _no_documento	char(20);
define _tipo_cambio     integer;
define _cnt_ducruet     integer; 
define _no_poliza		char(10);
define _cod_agente		char(5);
define _nombre_agente   varchar(50);


set isolation to dirty read;

let _fecha_desde = MDY(a_periodo[6,7], 1, a_periodo[1,4]);
let _fecha_hasta = sp_sis36(a_periodo);

--	set debug file to "sp_pro4953a.trc";
--	trace on;

	foreach
		select emicartasal2.no_documento
		  into _no_documento	   
		  from emicartasal2 
		 where emicartasal2.fecha_aniv >= _fecha_desde and  emicartasal2.fecha_aniv <= _fecha_hasta		 
	  order by emicartasal2.no_documento asc 
		
		let _no_poliza = sp_sis21(_no_documento);
		
		let _cnt_ducruet = 0;
		
		select count(*) 
		  into _cnt_ducruet
		  from emipoagt
		 where no_poliza = _no_poliza
		   and cod_agente in ('00815','00035','02154','02904');
		   
		if _cnt_ducruet > 0 then
			let _tipo_cambio = 3;
			let _nombre_agente = 'DUCRUET';
		else
		
			let _tipo_cambio = 0;
			
			foreach
				select cod_agente
				  into _cod_agente
				  from emipoagt
				 where no_poliza = _no_poliza
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
		 where emicartasal2.fecha_aniv >= _fecha_desde and  emicartasal2.fecha_aniv <= _fecha_hasta
		   and emicartasal2.no_documento = _no_documento;
		
	end foreach
return 0;
end

end procedure  

 
		