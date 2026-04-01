drop procedure sp_pro104;

create procedure "informix".sp_pro104()
returning smallint;


define _cantidad		smallint;

set isolation to dirty read;

let _cantidad = 0;

 select count(*)
   into _cantidad
   from eminotas
  where procesado   = 0
    and fecha_aviso <= today
    and fecha_aviso is not null;

if _cantidad > 0 then

	return 1;

end if

return 0;

end procedure