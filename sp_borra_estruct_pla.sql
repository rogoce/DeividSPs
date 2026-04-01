-- Procedure que crea los Cheques de Planilla.
-- 
-- Creado    : 19/03/2012 - Autor: Roman Gordon
--
-- SIS v.2.0 - DEIVID, S.A.

drop procedure sp_borra_estruct_pla;		

create procedure "informix".sp_borra_estruct_pla(a_origen_cheque char(1))
returning integer,
		  integer,	
          char(100);


define _error_desc		char(100);
define _no_requis		char(10);
define _no_trx			integer;
define _error			integer;
define _error_isam		integer;

begin
on exception set _error, _error_isam, _error_desc
	return _error,_error_isam, _error_desc;									   
end exception

set isolation to dirty read;


foreach
	select no_requis
	  into _no_requis
	  from chqchmae
	 where origen_cheque = a_origen_cheque

	foreach
		select distinct sac_notrx
		  into _no_trx
		  from chqchcta
		 where no_requis = _no_requis

		delete from cgltrx3 
		 where trx3_notrx = _no_trx;

		delete from cgltrx2 
		 where trx2_notrx = _no_trx;

		delete from cgltrx1
		 where trx1_notrx = _no_trx;
	end foreach

	delete from chqchdes
	 where no_requis = _no_requis;
	
	delete from chqchcta
	 where no_requis = _no_requis;

	delete from chqctaux
	 where no_requis = _no_requis;

end foreach

delete from chqchmae
 where origen_cheque = a_origen_cheque;

end 
end procedure