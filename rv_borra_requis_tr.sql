-- Borrar transaccion de chqchrec.
-- Creado: 29/11/2019 - Autor: Amado Perez

drop procedure rv_borra_requis_tr;

create procedure "informix".rv_borra_requis_tr(a_transaccion char(10))
returning integer,char(80);

define _no_requis		char(10);
define _transaccion     char(10);
define _monto           dec(16,2);
define _error			integer;
define _error_isam		integer;
define _error_desc		char(50);

--SET LOCK MODE TO WAIT;

--set debug file to "aa.trc";
--trace on;

begin work;
begin
on exception set _error, _error_isam, _error_desc
    rollback work;
	return _error, _error_desc;
end exception

select no_requis
  into _no_requis
  from rectrmae
 where transaccion = a_transaccion;
 
delete from chqchrec where no_requis = _no_requis and transaccion = a_transaccion;

select sum(monto)
  into _monto
  from chqchrec
 where no_requis = _no_requis;
 
update chqchmae
   set monto = _monto
 where no_requis = _no_requis;
	
update rectrmae
   set no_requis      = null,
	   generar_cheque = 0
 where transaccion    = a_transaccion;	

end
commit work;
return 0,"";

end procedure
