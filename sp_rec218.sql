drop procedure sp_rec218;

create procedure "informix".sp_rec218()
returning integer,
          char(50);

define _no_tranrec	char(10);
define _cantidad    integer;

define _error			integer;
define _error_isam		integer;
define _error_desc		char(50);

begin
on exception set _error, _error_isam, _error_desc
	return _error, _error_desc;
end exception

let _cantidad = 0;

foreach
 select no_tranrec
   into _no_tranrec
   from rectrmae
  where actualizado = 0
    and user_added  = "GERENCIA"
--	and no_tranrec  = "1187908"

	let _cantidad = _cantidad + 1;

	delete from rectrcob where no_tranrec = _no_tranrec;
	delete from rectrcon where no_tranrec = _no_tranrec;
	delete from rectrdes where no_tranrec = _no_tranrec;
	delete from rectrde2 where no_tranrec = _no_tranrec;
	delete from rectrrea where no_tranrec = _no_tranrec;
	delete from rectrmae where no_tranrec = _no_tranrec;

end foreach

end 

let _error_desc = _cantidad || " Registros Eliminados con Exito ...";

return 0, _error_desc;

end procedure
