-- Borrar Requisiciones con seis meses que no han sido impresas

-- Creado: 16/06/2011 - Autor: Armando Moreno M.

drop procedure sp_borra_requis_automa;

create procedure "informix".sp_borra_requis_automa(a_no_requis char(10))
returning integer,char(80);

define _no_requis		char(10);
define _error			integer;
define _error_isam		integer;
define _error_desc		char(50);
define _incidente       integer;
define _trx             char(10);

--SET DEBUG FILE TO "sp_borra.trc"; 
--trace on;


--SET LOCK MODE TO WAIT;

begin
on exception set _error, _error_isam, _error_desc
	return _error, _error_desc;
end exception

foreach
	select no_requis,
	       incidente
	  into _no_requis,
	       _incidente
	  from chqchmae
	 where no_requis = a_no_requis
	   and no_cheque = 0
	   and autorizado = 0
	   and pagado = 0
	   and anulado = 0
	   and (today - fecha_impresion) > 180


		update rectrmae
		   set no_requis = null
		 where no_requis = _no_requis;

		delete from chqchpoa
		 where no_requis = _no_requis;

		delete from chqchpol
		 where no_requis = _no_requis;

	    DELETE FROM chqchdes WHERE no_requis = _no_requis;
	    DELETE FROM chqchagt WHERE no_requis = _no_requis;
	    DELETE FROM chqctaux WHERE no_requis = _no_requis;
	    DELETE FROM chqchcta WHERE no_requis = _no_requis;


	    DELETE FROM chqchrec WHERE no_requis = _no_requis;

		delete from recunino  where no_requis = _no_requis;
		delete from chqchmae  where no_requis = _no_requis;


end foreach

end
return 0,"";

end procedure
