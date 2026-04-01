-- Reversar Avisos de Cancelacion para un Cobrador
-- 
-- Creado    : 26/06/2003 - Autor: Demetrio Hurtado Almanza 
-- Modificado: 26/06/2003 - Autor: Demetrio Hurtado Almanza
--
-- SIS v.2.0 - DEIVID, S.A.

drop procedure sp_cob117;

create procedure sp_cob117(
a_cobrador	char(3), 
a_fecha 	date
) returning char(100);

define _no_poliza		char(10);
define _es_cobrador		smallint;
define _cod_agente  	char(5);
define _cod_cobrador	char(3);
define _cantidad	    integer;

let _cantidad = 0;

foreach
 select no_poliza
   into _no_poliza
   from emipomae
  where carta_aviso_canc = 1
    and fecha_aviso_canc = a_fecha

	let _es_cobrador = 0;

	foreach
	 select cod_agente
       into _cod_agente
	   from emipoagt
	  where no_poliza = _no_poliza

		select cod_cobrador
		  into _cod_cobrador
		  from agtagent
		 where cod_agente = _cod_agente;

		if _cod_cobrador = a_cobrador then
			
			let _es_cobrador = 1;
			exit foreach;

		end if

	end foreach

	if _es_cobrador = 1 then

		let _cantidad = _cantidad + 1;

--{
		update emipomae
		   set carta_aviso_canc = 0,
    		   fecha_aviso_canc = null
		 where no_poliza = _no_poliza;
--}

	end if

end foreach

return _cantidad || " Registros Procesados ...";

end procedure