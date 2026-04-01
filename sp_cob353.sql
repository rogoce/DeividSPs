-- Procedimiento que determina si la póliza aplica para el cobro reiterado electronico de morosidad.
-- Creado    : 24/02/2015 - Autor: Román Gordón
-- SIS v.2.0 - DEIVID, S.A.

drop procedure sp_cob353;
create procedure "informix".sp_cob353(a_documento char(19),a_no_documento char(20),a_monto dec(16,2),a_tipo_elect char(3))
returning	integer,varchar(100)

define _error_desc		varchar(100);
define _no_poliza		char(10);
define _periodo			char(7);
define _cargo_especial	dec(16,2);
define _por_vencer		dec(16,2);
define _corriente		dec(16,2);
define _exigible		dec(16,2);
define _monto_30		dec(16,2);
define _monto_60		dec(16,2);
define _monto_90		dec(16,2);
define _saldo			dec(16,2);
define _pronto_pago		smallint;
define _dia_hoy			smallint;
define _dia				smallint;
define _error_isam		integer;
define _error			integer;
define _fecha_hoy		date;
define _fecha_sig		date;

set isolation to dirty read;

--set debug file to "sp_cob353.trc";
--trace on;

begin
on exception set _error,_error_isam,_error_desc
 	return _error,_error_desc;
end exception

let _fecha_hoy = today;
let _fecha_sig = _fecha_hoy + 1 units day;
let a_documento = trim(a_documento);
let _cargo_especial = 0.00;
let _dia_hoy = day(_fecha_hoy);

if month(_fecha_hoy) < 10 then
	let _periodo = year(_fecha_hoy) || '-0' || month(_fecha_hoy);
else
	let _periodo = year(_fecha_hoy) || '-' || month(_fecha_hoy);
end if

if a_tipo_elect = 'TCR' then
	select dia
	  into _dia
	  from cobtacre
	 where no_tarjeta = a_documento
	   and no_documento = a_no_documento;

	select pronto_pago
	  into _pronto_pago
	  from cobtatra
	 where no_tarjeta = a_documento
	   and no_documento = a_no_documento;
	   
elif a_tipo_elect = 'ACH' then
	select dia
	  into _dia
	  from cobcutas
	 where no_cuenta = a_documento
	   and no_documento = a_no_documento;

	select pronto_pago
	  into _pronto_pago
	  from cobcutmp
	 where no_tarjeta = a_documento
	   and no_documento = a_no_documento;
end if

if _pronto_pago is null then
	let _pronto_pago = 0;
end if

call sp_cob33('001','001',a_no_documento,_periodo,_fecha_hoy)
returning   _por_vencer,
			_exigible,
			_corriente,
			_monto_30,
			_monto_60,
			_monto_90,
			_saldo;

while a_monto != 0
	if _monto_90 > 0 then				
		if _monto_90 > a_monto then
			let _monto_90 = _monto_90 - a_monto;
			let a_monto = 0;
		else 
			let a_monto = a_monto - _monto_90;
			let _monto_90 = 0;
		end if
	elif _monto_60 > 0 then
		if _monto_60 > a_monto then
			let _monto_60 = _monto_60 - a_monto;
			let a_monto = 0;
		else 
			let a_monto = a_monto - _monto_60;
			let _monto_60 = 0;
		end if
	elif _monto_30 > 0 then
		if _monto_30 > a_monto then
			let _monto_30 = _monto_30 - a_monto;
			let a_monto = 0;
		else 
			let a_monto = a_monto - _monto_30;
			let _monto_30 = 0;
		end if
	elif _corriente > 0 then
		if _corriente > a_monto then
			let _corriente = _corriente - a_monto;
			let a_monto = 0;
		else 
			let a_monto = a_monto - _corriente;
			let _corriente = 0;
		end if
	elif _por_vencer > 0 then
		if _por_vencer > a_monto then
			let _por_vencer  = _por_vencer - a_monto;
			let a_monto = 0;
		else 
			let a_monto = a_monto - _por_vencer;
			let _por_vencer = 0;
		end if
	else
		let _corriente = _corriente - a_monto;
		let a_monto  = 0;
	end if
end while

if (_monto_30 + _monto_60 + _monto_90 > 1.00) then-- or (_pronto_pago = 0 and _corriente > 1.00 and _dia_hoy >= _dia)then		
	if _monto_90 > 0 then
		let _cargo_especial = _monto_90;
	elif _monto_60 > 0 then
		let _cargo_especial = _monto_60;
	elif _monto_30 > 0 then
		let _cargo_especial = _monto_30;
	else
		let _cargo_especial = _corriente;
	end if

	if a_tipo_elect = 'TCR' then
		update cobtacre
		   set dia_especial = day(_fecha_sig),
			   fecha_inicio = _fecha_sig,
			   fecha_hasta = _fecha_sig,
			   cargo_especial = _cargo_especial
		 where no_tarjeta = a_documento
		   and no_documento = a_no_documento;
	elif a_tipo_elect = 'ACH' then
		update cobcutas
		   set dia_especial = day(_fecha_hoy),
			   fecha_inicio = _fecha_hoy,
			   fecha_hasta = _fecha_hoy,
			   cargo_especial = _cargo_especial
		 where no_cuenta = a_documento
		   and no_documento = a_no_documento;
	end if
end if

return 0,'Verificación Exitosa';
end
end procedure;