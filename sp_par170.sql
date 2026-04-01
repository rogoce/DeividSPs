drop procedure sp_par170;

create procedure "informix".sp_par170()
returning integer,
          char(50);

define _fecha		date;
define _periodo		char(7);
define _descripcion	char(50);
define _no_tranrec	char(10);
define _cantidad    integer;
define _error	    integer;

let _fecha   = today;
let _fecha   = _fecha - 3 units month;
let _periodo = sp_sis39(_fecha);

begin
on exception set _error
	return _error, _descripcion;
end exception

select *
  from rectrmae
 where periodo     < _periodo
   and actualizado = 0
   and wf_aprobado is null
  into temp tmp_transac;

let _cantidad = 0;

foreach
 select no_tranrec
   into _no_tranrec
   from tmp_transac

	let _cantidad = _cantidad + 1;

	delete from rectrcob where no_tranrec = _no_tranrec;
	delete from rectrcon where no_tranrec = _no_tranrec;
	delete from rectrdes where no_tranrec = _no_tranrec;
	delete from rectrde2 where no_tranrec = _no_tranrec;
	delete from rectrrea where no_tranrec = _no_tranrec;
	delete from rectrmae where no_tranrec = _no_tranrec;

end foreach

end 

drop table tmp_transac;

let _descripcion = _cantidad || " Registros Eliminados con Exito ...";

return 0, _descripcion;

end procedure
