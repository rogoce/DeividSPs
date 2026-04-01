-- Procedimeinto para actualizar el monto de la visa o ach en mantenimiento de visa/ach cuando la vigencia entre en vigor.
-- Creado    : 02/05/2013 - Autor: Armando Moreno M.
-- Modificado: 02/05/2013 - Autor: Armando Moreno M.
-- SIS v.2.0 - DEIVID, S.A.

drop procedure sp_sis404;
create procedure "informix".sp_sis404()
returning smallint;

define _no_documento	char(20); 
define _no_tarjeta		char(19); 
define _no_cuenta		char(17); 
define _no_poliza		char(10);
define _nueva_renov		char(1);
define _prima_bruta		dec(16,2);
define _monto_visa		dec(16,2);
define _monto			dec(16,2);
define _no_pagos		smallint;
define _vigencia_inic	date;
define _fecha_ayer		date;
define _fecha_hoy		date;

let _fecha_hoy = today;
let _fecha_ayer = today -1 units day;

-- Procesa Todas las Tarjetas de Credito
foreach
	select h.no_tarjeta,
		   c.monto,
		   c.no_documento
	  into _no_tarjeta,
		   _monto,
		   _no_documento
	  from cobtacre c, cobtahab h
	 where c.no_tarjeta = h.no_tarjeta

	let _no_poliza = sp_sis21(_no_documento);

	select monto_visa,
		   vigencia_inic,
		   nueva_renov,
		   prima_bruta,
		   no_pagos
	  into _monto_visa,
		   _vigencia_inic,
		   _nueva_renov,
		   _prima_bruta,
		   _no_pagos
	  from emipomae
	 where no_poliza = _no_poliza
	   and actualizado = 1;

	let _monto_visa = _prima_bruta / _no_pagos;
	   
	if _vigencia_inic in(_fecha_hoy,_fecha_ayer) and _nueva_renov = 'R' then
		update cobtacre
		   set monto        = _monto_visa
		 where no_tarjeta   = _no_tarjeta
		   and no_documento = _no_documento;
	end if    
end foreach

-- Procesa Todas las Cuentas para ACH
foreach
	select h.no_cuenta,
		   c.monto,
		   c.no_documento
	  into _no_cuenta,
		   _monto,
		   _no_documento
	  from cobcutas c, cobcuhab h
	 where trim(c.no_cuenta) = trim(h.no_cuenta)

	let _no_poliza = sp_sis21(_no_documento);

	select monto_visa,
		   vigencia_inic,
		   nueva_renov,
		   prima_bruta,
		   no_pagos
	  into _monto_visa,
		   _vigencia_inic,
		   _nueva_renov,
		   _prima_bruta,
		   _no_pagos
	  from emipomae
	 where no_poliza   = _no_poliza
	   and actualizado = 1;

	let _monto_visa = _prima_bruta / _no_pagos;

	if _vigencia_inic in(_fecha_hoy,_fecha_ayer) and _nueva_renov = 'R' then
		update cobcutas
		   set monto        = _monto_visa
		 where no_cuenta    = _no_cuenta
		   and no_documento = _no_documento;
	end if
end foreach

-- Habilitando las tarjetas y las cuentas que ya cumplieron la fecha de excepcion
update cobtacre
   set excepcion = 0,
	   rechazada = 0
 where excep_fin < _fecha_hoy
   and excepcion = 1;

update cobcutas
   set excepcion = 0,
	   rechazada = 0
 where excep_fin < _fecha_hoy
   and excepcion = 1;

return 0;
end procedure;