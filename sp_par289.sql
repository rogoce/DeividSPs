
drop procedure sp_par289;

create procedure "informix".sp_par289()
returning integer,
          char(50);

define _cod_agente		char(5);
define _cod_vendedor	char(3);
define _cantidad		integer;

define _error			integer;
define _error_desc		char(50);
	
--set debug file to "sp_cob170";

-- Se asignas todos a pendiente para empezar el proceso

delete from deivid_tmp:prom2010;

foreach
 select cod_agente,
        cod_vendedor
   into _cod_agente,
        _cod_vendedor
   from deivid_tmp:tmp_promtot

	select count(*)
	  into _cantidad
	  from deivid_tmp:prom2010
	 where cod_agente = _cod_agente;

	if _cantidad = 0 then

		insert into deivid_tmp:prom2010
		values ("", _cod_vendedor, _cod_agente);

	end if

end foreach

return 0, "Actualizacion Exitosa";

end procedure