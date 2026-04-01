-- Procedimiento que carga los cobros para que se generen los registros contables
-- 
-- Creado    : 26/01/2010 - Autor: Demetrio Hurtado Almanza
--
-- SIS v.2.0 - DEIVID, S.A.

--drop procedure sp_sac156cam;		

create procedure "informix".sp_sac156cam()
returning integer, 
          char(100);
		  	
define _no_remesa   char(10); 

define _error		integer;
define _error_isam	integer;
define _error_desc	char(50);

set isolation to dirty read;

begin 
on exception set _error, _error_isam, _error_desc
	return _error, _error_desc;
end exception

foreach

	 select no_remesa
	   into _no_remesa
	   from camcobreaco
   group by no_remesa
   order by no_remesa
  	  	
	delete from cobasiau where no_remesa = _no_remesa;
	delete from cobasien where no_remesa = _no_remesa;
	delete from cobredet where no_remesa = _no_remesa and renglon = 0;

	call sp_par203(_no_remesa) returning _error, _error_desc;

	if _error <> 0 then
		return _error, trim(_error_desc) || " " || _no_remesa with resume;
	end if

	update cobredet
	   set sac_asientos = 1
	 where no_remesa    = _no_remesa;

end foreach;

end 

let _error  = 0;
let _error_desc = "Proceso Completado ...";	

return _error, _error_desc;

end procedure;
