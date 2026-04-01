
drop procedure sp_rec248;

create procedure sp_rec248(a_no_tranrec char(10))
returning smallint, char(50);

define _error		integer;
define _error_isam	integer;
define _error_desc	char(50);

define _cantidad	smallint;
define _transaccion	char(10);
define _actualizado smallint;

begin 
on exception set _error, _error_isam, _error_desc

	return _error, _error_desc;

end exception

select count(*)
  into _cantidad
  from recasien
 where no_tranrec = a_no_tranrec;

if _cantidad <> 0 then
	return 1, "Hay Registros en Asientos";
end if

select transaccion,
       actualizado 
  into _transaccion,
       _actualizado
  from rectrmae
 where no_tranrec = a_no_tranrec;	 

if _actualizado = 1 or
   _transaccion is not null then
	return 1, "Este Transaccion esta Actualizada";
end if
 
delete from rectrcob where no_tranrec = a_no_tranrec;
delete from rectrcon where no_tranrec = a_no_tranrec;
delete from rectrdes where no_tranrec = a_no_tranrec;
delete from rectrde2 where no_tranrec = a_no_tranrec;
delete from rectrref where no_tranrec = a_no_tranrec;
delete from rectrrea where no_tranrec = a_no_tranrec;
delete from rectrmae where no_tranrec = a_no_tranrec;

end 

return 0, "Actualizacion Exitosa";

end procedure
