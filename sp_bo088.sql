
drop procedure sp_bo088;

create procedure sp_bo088()
returning smallint,
          char(50);

define _cod_agente	char(5);
define _prima_sus	dec(16,2);
define _tipo_agente	char(15);

foreach
 select cod_agente,
        sum(pri_pag_aa)
   into _cod_agente,
        _prima_sus
   from milan08
  group by 1
  order by 1

	if _prima_sus >= 500000 then
		let _tipo_agente = "Rango 1";
	elif _prima_sus >= 200000 then
		let _tipo_agente = "Rango 2";
	elif _prima_sus >= 100000 then
		let _tipo_agente = "Rango 3";
	else
		let _tipo_agente = "Rango 4";
	end if
		 
	update milan08
	   set tipo_agente = _tipo_agente
	 where cod_agente  = _cod_agente;

end foreach

return 0, "Actualizacion Exitosa";

end procedure 