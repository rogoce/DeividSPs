-- Procedimiento que trae los totales de prima cobrado por Pago Voluntarios
--
-- creado    : 25/01/2013 - Autor: Roman Gordon--
-- sis v.2.0 - deivid, s.a.

drop procedure sp_cob318;
create procedure "informix".sp_cob318()
returning   integer,
			char(100),
			dec(16,2),
			dec(16,2),
			dec(16,2),
			dec(16,2),
			dec(16,2);   -- _error

define _error_desc		char(100);
define _no_poliza		char(10);
define _no_remesa		char(10);
define _cod_formapag	char(3);
define _sum_pagos		dec(16,2);
define _sum_pagos_cash	dec(16,2);
define _sum_pagos_chq  	dec(16,2);
define _sum_pagos_tcr  	dec(16,2);
define _monto_pago		dec(16,2);
define _importe			dec(16,2);
define _sum_total_pagos	dec(16,2);
define _tipo_pago		smallint;
define _error			smallint;
define _error_isam		smallint;
define _fronting		smallint;
define _renglon			integer;

begin

on exception set _error,_error_isam,_error_desc 
 	return _error,_error_desc,0.00,0.00,0.00,0.00,0.00;
end exception

set isolation to dirty read;

--set debug file to "sp_cob318.trc"; 
--trace on;
let _sum_pagos		= 0.00;
let _sum_pagos_cash = 0.00;
let _sum_pagos_chq	= 0.00;
let _sum_pagos_tcr	= 0.00;
let _monto_pago		= 0.00;
let _sum_total_pagos	= 0.00;

foreach
	select no_remesa
	  into _no_remesa
	  from cobremae
	 where tipo_remesa = 'A'
	 and periodo[1,4] = '2012'
	   -- cod_chequera not in ('025','026','027','041')
	 and actualizado = 1	   
	 
	foreach
		select monto,
			   no_poliza,
			   renglon
		  into _monto_pago,
			   _no_poliza,
			   _renglon
		  from cobredet
		 where no_remesa	= _no_remesa
		   and tipo_mov		in ('P','N')
		   and actualizado = 1
		   
		select fronting,
			   cod_formapag
		  into _fronting,
			   _cod_formapag
		  from emipomae
		 where no_poliza = _no_poliza;	
		
		let _importe = 0.00;
		let _sum_pagos = _sum_pagos + _monto_pago;
		
		foreach
			select tipo_pago,
				   importe
			  into _tipo_pago,
				   _importe
			  from cobrepag
			 where no_remesa	= _no_remesa
			   and renglon = _renglon

			if _tipo_pago = 1 then
				let _sum_pagos_cash = _sum_pagos_cash + _importe;
			elif _tipo_pago = 2 then
				let _sum_pagos_chq = _sum_pagos_chq + _importe;
			elif _tipo_pago = 3 then
				let _sum_pagos_tcr = _sum_pagos_tcr + _importe;
			end if
		end foreach
	end foreach	
end foreach

let _sum_total_pagos = _sum_pagos_cash + _sum_pagos_chq + _sum_pagos_tcr;
return	0,
		'Exito',
		_sum_pagos,
		_sum_pagos_cash,
		_sum_pagos_chq,
		_sum_pagos_tcr,
		_sum_total_pagos;
		
end
end procedure