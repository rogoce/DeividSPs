-- Borrar transaccion de chqchrec, ya que la anularon.
-- Proyecto Unificacion de los Cheques de Salud
-- Creado: 11/05/2005 - Autor: Armando Moreno M.

drop procedure rv_borra_requis_amm;
create procedure rv_borra_requis_amm(a_no_requis char(10))
returning integer,char(80);

define _no_requis		char(10);
define _transaccion     char(10);
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

{foreach

select no_requis
  into _no_requis
  from chqchmae
 where origen_cheque = '2' and fecha_captura = '22/10/2020'
}

	select no_requis
	  into _no_requis 
	  from chqchmae
	 where no_requis = a_no_requis;
    
      
	DELETE FROM chqchpoa WHERE no_requis = _no_requis;
	DELETE FROM chqchpol WHERE no_requis = _no_requis;
	DELETE FROM chqchdes WHERE no_requis = _no_requis;
	DELETE FROM chqchagt WHERE no_requis = _no_requis;
	DELETE FROM chqctaux WHERE no_requis = _no_requis;
	DELETE FROM chqchcta WHERE no_requis = _no_requis;
	DELETE FROM chqchrec WHERE no_requis = _no_requis;
	DELETE FROM chqchmae WHERE no_requis = _no_requis;

end
commit work;
return 0,"";

end procedure
