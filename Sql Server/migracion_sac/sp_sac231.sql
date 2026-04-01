-- Procedimiento que elomina los registros de devolucion de primas
-- 
-- Creado    : 13/09/2013 - Autor: Demetrio Hurtado Almanza 
--
-- SIS v.2.0 - DEIVID, S.A.

drop procedure sp_sac231;		

create procedure "informix".sp_sac231()
returning integer, 
          char(100);
		  	
define _no_registro		char(10);
define _contador		smallint;

define _error			integer;
define _error_isam		integer;
define _error_desc		char(50);

set isolation to dirty read;

begin 
on exception set _error, _error_isam, _error_desc
	return _error, _error_desc;
end exception

let _contador = 0;

foreach
 select no_registro
   into _no_registro
   from sac999:reacomp
  where tipo_registro in (4, 5)

	let _contador = _contador + 1;

	delete from sac999:reacompasiau  where no_registro = _no_registro;
	delete from sac999:reacompasie	 where no_registro = _no_registro;
	delete from sac999:reacomp   	 where no_registro = _no_registro;

end foreach

end 

return _contador, "Actualizacion Exitosa";

end procedure;
