 													   
drop procedure sp_rec231e;

create procedure sp_rec231e(a_transaccion char(10) default '%', a_cod_proveedor char(10))
returning integer,
          decimal(16,2),
		  char(10),
		  char(18),
		  char(10);

define _mto_orden       decimal(16,2);
define _tramite         char(10);
define _numrecla		char(18);
define _transaccion     char(10);
define _error           integer;
define _cod_proveedor   char(10);

--SET DEBUG FILE TO "sp_rec231a.trc"; 
--TRACE ON;                                                                
set isolation to dirty read;

begin


let _mto_orden = 0.00;
let _error     = 0;

foreach with hold
	select a.transaccion,
	       a.monto,
		   a.numrecla,
	       b.no_tramite
	  into _transaccion,
	       _mto_orden,
		   _numrecla,
	       _tramite
	  from rectrmae a, recrcmae b
	 where a.no_reclamo  = b.no_reclamo
	   and a.transaccion   like a_transaccion
	   and a.cod_cliente   = a_cod_proveedor
	   and a.pagado        = 0
	   and a.cod_tipotran  = "004"
	   and a.actualizado   = 1

	return _error,_mto_orden,_tramite,_numrecla,_transaccion with resume;

end foreach

end

end procedure