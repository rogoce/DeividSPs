--- Insercion de endosos especiales desde produccion para ser impresos por logistica
--- Creado 28/09/2011 por Henry 
--drop procedure sp_pro354;
create procedure "informix".sp_pro354(a_cod_end char(5), a_no_poliza char(10), a_cod_ramo char(3))
returning integer;
begin
define _cantidad	  	smallint;
define _no_endoso       char(5);
define _error			integer;
define _error_isam		integer;
define _error_desc		char(50);

on exception set _error, _error_isam, _error_desc
   return _error;
end exception

set isolation to dirty read;

let _no_endoso = "00000";

select count(*)
  into _cantidad
  from endesppol
 where no_poliza  = a_no_poliza
   and no_endoso  = _no_endoso
   and cod_ramo   = a_cod_ramo
   and cod_endoso = a_cod_end;

if _cantidad <> 0 then
	delete from endesppol where no_poliza = a_no_poliza and no_endoso = _no_endoso and 	cod_ramo = a_cod_ramo and cod_endoso = a_cod_end;
end if

end
return 0;
end procedure;
