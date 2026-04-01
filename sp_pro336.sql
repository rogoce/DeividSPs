-- Procedure que retorna si se puede renovar un corredor especial

drop procedure sp_pro336;

create procedure sp_pro336(a_no_poliza char(10)) 
returning smallint;

define _cod_agente	    char(5);
define _tipo_agente		char(1);
define _flag,_renueva   smallint;

set isolation to dirty read;

let _flag = 0;

foreach

	select cod_agente
	  into _cod_agente
	  from emipoagt
	 where no_poliza = a_no_poliza

	select tipo_agente,
	       renueva
	  into _tipo_agente,
	       _renueva
	  from agtagent
	 where cod_agente = _cod_agente;

	if _tipo_agente = "E" and _renueva = 0 then
		let _flag = 1;
		exit foreach;
	end if

end foreach

return _flag;

end procedure