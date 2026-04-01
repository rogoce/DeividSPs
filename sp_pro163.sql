-- Procedure que realiza el calculo de las tarifas nuevas de salud 
-- como el cambio de tarifa por el cambio de edad

-- Creado    : 23/08/2005 - Autor: Demetrio Hurtado Almanza 

-- SIS v.2.0 - sp_pro30 - DEIVID, S.A.

drop procedure sp_pro163;

create procedure "informix".sp_pro163()

define _no_poliza		char(10);
define _no_documento	char(20);
define _cod_agente		char(5);
define _nombre_agente	char(50);
define _cantidad		smallint;
define _nuevo			smallint;


foreach
 select no_documento
   into _no_documento
   from prosalud
  group by 1

	let _no_poliza = sp_sis21(_no_documento);

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
	 where cod_agente = _cod_agente;

{
	select count(*)
	  into _cantidad
	  from prdnewpro
	 where producto_nuevo = _cod_producto;
	 
	if _cantidad = 0 then
		let _nuevo = 0;
	else
		let _nuevo = 1;
	end if
}
	update prosalud
	   set nombre_corredor = _nombre_agente
	 where no_documento    = _no_documento;

end foreach

end procedure 