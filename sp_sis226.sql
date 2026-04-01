-- Actualiza la tabla emiletra cuando la póliza recibe un pago
-- Creado    : 13/11/2014 - Autor: Román Gordón
-- SIS v.2.0 - DEIVID, S.A.

drop procedure sp_sis226;
create procedure sp_sis226()
returning	char(20)	as poliza,
			smallint	as dia,
			dec(16,2)	as monto_letra,
			dec(16,2)	as por_vencer,
			dec(16,2)	as exigible,
			dec(16,2)	as corriente,
			dec(16,2)	as monto30,
			dec(16,2)	as monto60,
			dec(16,2)	as monto90,
			dec(16,2)	as saldo,
			smallint	as no_pagos;

define _error_desc			char(50);
define _no_documento		char(20);
define _no_poliza_c			char(10);
define _no_poliza			char(10);
define _no_remesa			char(10);
define _periodo				char(7);
define _cod_ramo			char(3);
define _monto_pendiente		dec(16,2);
define _monto_letra			dec(16,2);
define _por_vencer			dec(16,2);
define _corriente			dec(16,2);
define _exigible			dec(16,2);
define _monto30				dec(16,2);
define _monto60				dec(16,2);
define _monto90				dec(16,2);
define _saldo				dec(16,2);
define _estatus_poliza		smallint;
define _no_pagos			smallint;
define _dia					smallint;
define _error_isam			integer;
define _error				integer;
define _fecha_primer_pago	date;
define _fecha_ult_letra		date;
define _vigencia_final		date;
define _fecha_pago			date;

set isolation to dirty read;

begin 
on exception set _error, _error_isam, _error_desc
	return _error_desc,_error,0.00,0.00,0.00,0.00,0.00,0.00,0.00,0.00,0;
end exception

--set debug file to "sp_sis226.trc";
--trace on;

let _fecha_pago = '30/09/2016';

foreach
	select no_documento,
		   dia,
		   monto
	  into _no_documento,
		   _dia,
		   _monto_letra
	  from cobtacre

	let _no_poliza = sp_sis21(_no_documento);

	select vigencia_final,
		   estatus_poliza,
		   fecha_primer_pago,
		   no_pagos,
		   cod_ramo
	  into _vigencia_final,
		   _estatus_poliza,
		   _fecha_primer_pago,
		   _no_pagos,
		   _cod_ramo
	  from emipomae
	 where no_poliza = _no_poliza;

	if _estatus_poliza <> 1 then
		continue foreach;
	end if

	if _cod_ramo = '018' then
		continue foreach;
	end if

	if day(_fecha_primer_pago) = 31 then
		let _fecha_primer_pago = _fecha_primer_pago - 1 units day;
	end if
	
	if month(_fecha_primer_pago) + (_no_pagos) - 12 in (2,-10) and day(_fecha_primer_pago) > 28 then
		let _fecha_primer_pago = mdy(month(_fecha_primer_pago),28,year(_fecha_primer_pago));
	end if

	let _fecha_ult_letra = _fecha_primer_pago + (_no_pagos) units month;
	let _fecha_ult_letra = _fecha_ult_letra + 1 units day;

	let _periodo = sp_sis39(_fecha_ult_letra);

	call sp_cob33bk('001','001',_no_documento,_periodo,_fecha_ult_letra)
	returning	_por_vencer,
				_exigible,	
				_corriente,	
				_monto30,	
				_monto60,	
				_monto90,	
				_saldo;		

	if _saldo <= 1 then
		continue foreach;
	end if

	return	_no_documento,
			_dia,
			_monto_letra,
			_por_vencer,
			_exigible,	
			_corriente,	
			_monto30,	
			_monto60,	
			_monto90,	
			_saldo,
			_no_pagos
			with resume;		
end foreach

end
end procedure;