 													   
--drop procedure sp_rec231b;

create procedure sp_rec231b(a_tramite char(10) default '%', a_cod_proveedor char(10), a_tipo char(1))
returning integer,
          decimal(16,2),
		  char(10),
		  char(18),
		  char(10);

define _mto_orden       decimal(16,2);
define _tramite         char(10);
define _numrecla		char(18);
define _no_orden        char(10);
define _error           integer;
define _cod_proveedor   char(10);

--SET DEBUG FILE TO "sp_rec231a.trc"; 
--TRACE ON;                                                                
set isolation to dirty read;

begin


let _mto_orden = 0.00;
let _error     = 0;

foreach with hold
	select monto - monto_pagado,
	       no_tramite,
		   numrecla,
		   no_orden,
		   cod_proveedor
	  into _mto_orden,
	       _tramite,
		   _numrecla,
		   _no_orden,
		   _cod_proveedor
	  from recordma
	 where no_tramite    like a_tramite
	   and cod_proveedor = a_cod_proveedor
	   and tipo_ord_comp = a_tipo
	   and pagado        = 0

	return _error,_mto_orden,_tramite,_numrecla,_no_orden with resume;

end foreach

end

end procedure