-- Borrar transaccion de chqchrec, ya que la anularon.
-- Proyecto Unificacion de los Cheques de Salud
-- Creado: 11/05/2005 - Autor: Armando Moreno M.

drop procedure rv_borra_requis;

create procedure "informix".rv_borra_requis(a_fecha_captura date, a_no_remesa char(10))
returning integer,char(80);

define _no_requis		char(10);
define _error			integer;
define _error_isam		integer;
define _error_desc		char(50);

--SET LOCK MODE TO WAIT;
begin
on exception set _error, _error_isam, _error_desc
    rollback work;
	return _error, _error_desc;
end exception

foreach
	select no_requis
	  into _no_requis 
	  from chqchmae
	 where origen_cheque in ('2','7')
	   and fecha_captura = a_fecha_captura

	delete from chqchpoa
	 where no_requis = _no_requis;

	delete from chqchpol
	 where no_requis = _no_requis;

	delete from recunino
	 where no_requis = _no_requis;

    delete from chqchdes where no_requis = _no_requis;
    delete from chqchagt where no_requis = _no_requis;
    delete from chqctaux where no_requis = _no_requis;
    delete from chqchcta where no_requis = _no_requis;

	delete from chqchmae
	 where no_requis = _no_requis;

end foreach

DELETE FROM chqcomis WHERE fecha_genera = a_fecha_captura and no_requis is null;

DELETE FROM cobasiau WHERE no_remesa = a_no_remesa;
DELETE FROM cobasien WHERE no_remesa = a_no_remesa;
DELETE FROM cobreagt WHERE no_remesa = a_no_remesa;
DELETE FROM cobredet WHERE no_remesa = a_no_remesa;
DELETE FROM cobremae WHERE no_remesa = a_no_remesa;



end
return 0,"";

end procedure
