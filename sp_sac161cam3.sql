-- Procedimiento que carga los comprobantes de reaseguro para que se generen los registros contables
-- 
-- Creado    : 18/11/2021 - Autor: Amado Perez 
--
-- SIS v.2.0 - DEIVID, S.A.

drop procedure sp_sac161cam3;		

create procedure "informix".sp_sac161cam3()
returning integer, 
          char(100);
		  	
define _no_registro	char(10);
define _contador		smallint;
define _tipo_registro	smallint;

define _error			integer;
define _error_isam		integer;
define _error_desc		char(50);

set isolation to dirty read;

begin 
on exception set _error, _error_isam, _error_desc
	return _error, _error_desc;
end exception


--set debug file to "sp_sac161cam.trc";
--trace on;

--return 1, "Inicio " || current with resume;

let _contador = 0;

-- produccion y cobros

foreach 
 select r.no_registro,
         r.tipo_registro
   into _no_registro,
	    _tipo_registro
   from sac999:reacomp r, camrea2 c
  where r.no_poliza    = c.no_poliza
    and r.sac_asientos = 0
    and r.tipo_registro in (1,2,3)
    and r.periodo >= '2020-06'
    and r.periodo <= '2021-10'
	and c.actualizado = 1
	and c.tipo in (1,2,3)
   order by r.no_registro

	delete from sac999:reacompasiau  where no_registro = _no_registro;
	delete from sac999:reacompasie	 where no_registro = _no_registro;

	call sp_par296(_no_registro) returning _error, _error_desc;

	if _error <> 0 then
		return _error, trim(_error_desc) || " " || _no_registro;
	end if

	update sac999:reacomp
	   set sac_asientos = 1
	 where no_registro  = _no_registro;

end foreach

call sp_sac61cam("informix", 12) returning _error, _error_desc;

end 
let _error  = 0;
let _error_desc = "Proceso Completado ...";	

return _error, _error_desc;

end procedure;
