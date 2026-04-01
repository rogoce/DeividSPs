drop procedure sp_cob170;

create procedure "informix".sp_cob170()
returning integer,
          char(50);

define _cod_agente		char(10);
define _cod_vendedor	char(10);

define _user_added		char(8);

define _error			integer;
define _error_desc		char(50);
	
--set debug file to "sp_cob170";

foreach
 select cod_agente
   into _cod_agente
   from agtagent
--  where cod_agente = "01644"

   	foreach	
	 select cod_vendedor,
	        user_added
	   into _cod_vendedor,
	        _user_added
	   from parpromo
	  where cod_agente  = _cod_agente
	    and cod_agencia = "001"
		and cod_ramo    = "001"
			exit foreach;
	end foreach

	update agtagent
	   set cod_vendedor = _cod_vendedor
	 where cod_agente   = _cod_agente;

    delete from parpromo
	 where cod_agente   = _cod_agente;
	 
	call sp_par82(_cod_agente, _user_added) returning _error, _error_desc;

	if _error <> 0 then
		return _error, _error_desc;
	end if
			
end foreach

return 0, "Actualizacion Exitosa";

end procedure