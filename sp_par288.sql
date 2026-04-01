drop procedure sp_par288;

create procedure "informix".sp_par288()
returning integer,
          char(50),
          char(5);

define _cod_agente		char(5);
define _cod_vendedor	char(3);
define _cod_vendedor2	char(3);
define _nombre_vende	char(50);

define _error			integer;
define _error_desc		char(50);
	
-- Se asignas todos a pendiente para empezar el proceso

update agtagent
   set cod_vendedor = "031";

foreach
 select cod_agente,
        cod_vendedor
   into _cod_agente,
        _cod_vendedor
   from deivid_tmp:prom2010

	select cod_vendedor,
	       nombre
	  into _cod_vendedor2,
	       _nombre_vende
	  from agtagent
	 where cod_agente = _cod_agente;

	if _cod_vendedor2 = "031" then

		update agtagent
		   set cod_vendedor = _cod_vendedor
		 where cod_agente   = _cod_agente;   

	else

		return 1, _nombre_vende, _cod_agente with resume;

	end if

end foreach

-- Los que quedaron pendientes de asignar se pasan a oficina

--{
update agtagent
   set cod_vendedor = "047"
 where cod_vendedor = "031";

foreach
 select cod_agente
   into _cod_agente
   from agtagent

	call sp_par82(_cod_agente, "informix") returning _error, _error_desc;

	if _error <> 0 then
		return _error, _error_desc, _cod_agente;
	end if
			
end foreach
--}

return 0, "Actualizacion Exitosa", "";

end procedure