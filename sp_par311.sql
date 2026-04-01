-- Procedimiento que carga los registros contables de la facturacion de salud con error de octubre 2010
-- 
-- Creado    : 19/11/2010 - Autor: Demetrio Hurtado Almanza
--
-- SIS v.2.0 - DEIVID, S.A.

drop procedure sp_par311;		

create procedure "informix".sp_par311()
returning integer, 
          char(100);
		  	
define _no_poliza   char(10); 
define _no_endoso	char(5);
define _no_factura  char(10); 

define _error_cod	integer;
define _error_isam	integer;
define _error_desc	char(100);

set isolation to dirty read;

begin 
on exception set _error_cod, _error_isam, _error_desc
	return _error_cod, _error_desc;
end exception

foreach
 select no_factura
   into _no_factura
   from deivid_tmp:error_salud
  where sac_asientos = 2
  	  	
 select no_poliza,
		no_endoso
   into _no_poliza,
	    _no_endoso
   from endedmae
  where no_factura = _no_factura;

	delete from endasiau
	 where no_poliza = _no_poliza
	   and no_endoso = _no_endoso;

	delete from endasien
	 where no_poliza = _no_poliza
	   and no_endoso = _no_endoso;

{

	call sp_par59(_no_poliza, _no_endoso) returning _error_cod, _error_desc;

	if _error_cod <> 0 then
		return _error_cod, trim(_error_desc) || " " || _no_factura || " " || _no_poliza || " " || _no_endoso with resume;
	end if

	update deivid_tmp:error_salud
	   set sac_asientos = 1
	 where no_factura   = _no_factura;

--}

end foreach;

end

let _error_cod  = 0;
let _error_desc = "Proceso Completado ...";	

return _error_cod, _error_desc;

end procedure;
