--drop procedure sp_rec111;

create procedure "informix".sp_rec111(a_transaccion char(10))
returning integer,
          char(50);

define _numrecla	char(20);
define _cantidad	smallint;
define _monto		dec(16,2);

select numrecla,
       monto
  into _numrecla,
       _monto
  from rectrmae
 where transaccion = a_transaccion;

if _numrecla is null then
	return 1, "Transaccion Incorrecta";
end if	

select count(*)
  into _cantidad
  from respen0512
 where reclamo = _numrecla;

if _cantidad = 0 then
	return 1, "No Se Encontro Registro";
end if

update respen0512
   set transaccion = a_transaccion,
       monto       = _monto
 where reclamo     = _numrecla;

return 0, "Actualizacion Exitosa";

end procedure