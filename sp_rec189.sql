-- Procedimiento que Arregla las transacciones de reclamos con error en los decimales

-- Creado    : 28/10/2011 - Autor: Demetrio Hurtado Almanza

-- SIS v.2.0 - DEIVID, S.A.

drop procedure sp_rec189;

create procedure "informix".sp_rec189(
a_transaccion char(10)
) returning smallint,
            char(100);

define _no_tranrec	char(10);
define _monto		dec(16,2);
define _variacion	dec(16,2);

define _cantidad	smallint;

define _error	    integer;
define _error_isam  integer;
define _error_desc  char(50);

begin

on exception set _error, _error_isam, _error_desc
	rollback work;
 	return _error, _error_desc;         
end exception

begin work;

select monto,
       variacion,
	   no_tranrec
  into _monto,
       _variacion,
	   _no_tranrec
  from rectrmae
 where transaccion = a_transaccion;

select count(*) 
  into _cantidad
  from rectrcob
 where no_tranrec = _no_tranrec;

if _cantidad > 1 then
	return  1, "Mas de Una Cobertura";
end if

let _monto     = _monto / 100;
let _variacion = _variacion / 100;

update rectrmae
   set monto        = _monto,
       variacion    = _variacion,
	   sac_asientos = 0
 where transaccion  = a_transaccion;

update rectrcob
   set monto      = _monto,
       variacion  = _variacion
 where no_tranrec = _no_tranrec;

delete from recasiau where no_tranrec = _no_tranrec;
delete from recasien where no_tranrec = _no_tranrec;

commit work;

end

return 0, "Actualizacion Exitosa";

end procedure
