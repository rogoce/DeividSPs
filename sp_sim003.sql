-- Procedimiento que carga los comprobantes de reaseguro para que se generen los registros contables Simulacion
-- 
-- Creado    : 04/02/2010 - Autor: Demetrio Hurtado Almanza 
--
-- SIS v.2.0 - DEIVID, S.A.

--drop procedure sp_sim003;		

create procedure "informix".sp_sim003()
returning integer, 
          char(100);
		  	
define _no_registro	char(10);
define _contador	smallint;

define _error		integer;
define _error_isam	integer;
define _error_desc	char(50);

set isolation to dirty read;

begin 
on exception set _error, _error_isam, _error_desc
	return _error, _error_desc;
end exception

let _contador = 0;

--SET DEBUG FILE TO "sp_sim003.trc";
--TRACE ON;                                                                

foreach
 select no_registro
   into _no_registro
   from sac999:sreacomp
  where sac_asientos  = 0
  	  	

	delete from sac999:sreacompasiau  where no_registro = _no_registro;
	delete from sac999:sreacompasie	  where no_registro = _no_registro;

	call sp_sim004(_no_registro) returning _error, _error_desc;

	if _error <> 0 then
		return _error, trim(_error_desc) || " " || _no_registro;
	end if

	--{
	update sac999:sreacomp
	   set sac_asientos = 1
	 where no_registro  = _no_registro;
	--}
	--return 1,'' with resume;
end foreach

end 

let _error  = 0;
let _error_desc = "Proceso Completado ...";	

return _error, _error_desc;

end procedure;
