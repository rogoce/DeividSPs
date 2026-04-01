-- Procedimiento que carga los comprobantes de reaseguro para que se generen los registros contables
-- 
-- Creado    : 04/02/2010 - Autor: Demetrio Hurtado Almanza 
--
-- SIS v.2.0 - DEIVID, S.A.

drop procedure sp_sac161;		

create procedure "informix".sp_sac161()
returning integer, 
          char(100);
		  	
define _no_registro		char(10);
define _contador		smallint;
define _tipo_registro	smallint;

define _error			integer;
define _error_isam		integer;
define _error_desc		char(50);
define _periodo         char(7);

set isolation to dirty read;

begin 
on exception set _error, _error_isam, _error_desc
	return _error, _error_desc;
end exception

-- Validacion del periodo de reclamos

call sp_rea054() returning _error, _error_desc;

if _error <> 0 then 
	return _error, _error_desc;
end if

--set debug file to "sp_sac161.trc";
--trace on;

let _contador = 0;

select periodo_verifica
  into _periodo
  from emirepar;

foreach
 select no_registro,
        tipo_registro
   into _no_registro,
        _tipo_registro
   from sac999:reacomp
  where sac_asientos  = 0
    and periodo = _periodo
--    and periodo       <= "2014-11"

    --and no_registro   = "4528878"
--    and tipo_registro <> 2

--    and no_registro   = "3174508"

--	if _tipo_registro = 4 or
--	   _tipo_registro = 5 then
--		continue foreach;
--	end if	   
	   	  	
--	if _tipo_registro = 3 then
--		continue foreach;
--	end if	   

--	let _contador = _contador + 1;

--	trace _no_registro;

	delete from sac999:reacompasiau  where no_registro = _no_registro;
	delete from sac999:reacompasie	 where no_registro = _no_registro;

	call sp_par296(_no_registro) returning _error, _error_desc;

	if _error <> 0 then
		return _error, trim(_error_desc) || " " || _no_registro;
	end if

	--{
	update sac999:reacomp
	   set sac_asientos = 1
	 where no_registro  = _no_registro;
	--}

--	if _contador > 1000 then
--		exit foreach;
--	end if

end foreach

end 

let _error  = 0;
let _error_desc = "Proceso Completado ...";	

return _error, _error_desc;

end procedure;
