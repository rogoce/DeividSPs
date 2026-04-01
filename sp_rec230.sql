--- Busqueda por numero de orden
--- Creado 03/10/2014 por Armando Moreno

drop procedure sp_rec230;

create procedure "informix".sp_rec230(a_tipo char(1), a_cod_proveedor char(10))
returning decimal(16,2),
          char(10),
          char(18),
          char(10);

begin

define _mto_orden       decimal(16,2);
define _tramite         char(10);
define _numrecla		char(18);
define _no_orden        char(10);

--SET DEBUG FILE TO "sp_rec230.trc"; 
--TRACE ON;                                                                


set isolation to dirty read;

let _mto_orden = 0.00;

foreach
	select monto - monto_pagado,
	       no_tramite,
		   numrecla,
		   no_orden
	  into _mto_orden,
	       _tramite,
		   _numrecla,
		   _no_orden
	  from recordma
	 where tipo_ord_comp = a_tipo
	   and cod_proveedor = a_cod_proveedor
	   and pagado        = 0

	 return _mto_orden,_tramite,_numrecla,_no_orden with resume;	

end foreach


end

end procedure;
