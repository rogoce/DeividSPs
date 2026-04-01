-- Ajuste de las letras de pago de las polizas por nueva ley de seguros cuando la poliza de salud es facturada
-- Creado    : 13/11/2014 - Autor: Román Gordón
-- SIS v.2.0 - DEIVID, S.A.
  
drop procedure sp_pro541b;
create procedure sp_pro541b(a_no_poliza char(10), a_no_endoso char(5))
returning	int,
			char(50);

define _error_desc		char(50);
define _no_documento	char(20);
define _cod_endomov		char(3);
define _monto_pendiente	dec(16,2);
define _dias_letra_dec	dec(16,2);
define _letra_residuo	dec(16,2);
define _monto_residuo	dec(16,2);
define _monto_pagado	dec(16,2);
define _monto_letra		dec(16,2);
define _prima_bruta		dec(16,2);
define _nuevo_monto		dec(16,2);
define _monto_pen		dec(16,2);
define _mes_dec			dec(16,2);
define _resto           dec(16,2);
define _cnt_no_pagada	smallint;
define _letra_pagada	smallint;
define _mes_cancela		smallint;
define _ano_cancela		smallint;
define _cnt_endoso		smallint;
define _mes_gracia		smallint;
define _ano_gracia		smallint;
define _mes_letra		smallint;
define _ano_letra		smallint;
define _ult_letra		smallint;
define _no_letra		smallint;
define _no_pagos		smallint;
define _mes_int			smallint;
define _letra			smallint;
define _pagada			smallint;
define _dias_letra		integer;
define _error_isam		integer;
define _dias_vigencia	integer;
define _error			integer;
define _vigencia_final	date;
define _periodo_gracia	date;
define _vigencia_inic   date;
define _vig_final_pol	date;
define _fecha_60_dias	date;
define _fecha_pagado	date;
define _fecha_1_pago	date;
define _fecha_aviso		date;
define _fecha_pago		date;
define _vigencia_f      date;
define _vigencia		date;


set isolation to dirty read;

begin 
on exception set _error, _error_isam, _error_desc
	let _error_desc = trim(_error_desc) || 'no_poliza: ' || trim(a_no_poliza) || ' no_endoso: ' || trim(a_no_endoso);
	return _error, _error_desc;
end exception

--set debug file to "sp_pro541.trc";
--trace on;

let _vigencia_inic = '01/01/1900';

select no_documento,
	   cod_endomov,
	   prima_bruta,
	   vigencia_inic,
	   vigencia_final
  into _no_documento,
	   _cod_endomov,
	   _prima_bruta,
	   _fecha_1_pago,
	   _vigencia_final
  from endedmae
 where no_poliza = a_no_poliza
   and no_endoso = a_no_endoso;
   
if _cod_endomov <> '014' then
	return 0,'El endoso no es Facturación Mensual';
end if

let _no_pagos = 1;

select max(no_letra)
  into _ult_letra
  from emiletra
 where no_poliza = a_no_poliza;
 
let _letra = _ult_letra + 1;

let _dias_vigencia  = _vigencia_final - _fecha_1_pago;
let _dias_letra_dec = _dias_vigencia / _no_pagos;
let _monto_letra	= _prima_bruta / _no_pagos;
let _dias_letra		= _dias_vigencia / _no_pagos;

if _dias_letra_dec > _dias_letra then
	let _dias_letra = _dias_letra + 1;
end if

let _mes_int = 12 / _no_pagos;
let _mes_dec = 12 / _no_pagos;

if _mes_dec > _mes_int then
	let _mes_int = _mes_int + 1;
end if

let _mes_letra = month(_fecha_1_pago);
let _ano_letra = year(_fecha_1_pago);

{
if _mes_letra = 12 then
	let _mes_letra = 1;
	let _ano_letra = _ano_letra + 1;
else
	let _mes_letra = _mes_letra + 1;
end if
}

let _resto = _prima_bruta;
-- Fecha del Pago de la Letra
let _fecha_pago = _fecha_1_pago;

-- Periodo de Gracia (30 dias)
let _periodo_gracia	= _fecha_pago + 30;

-- Cancelacion de la Poliza (60 dias despues del periodo de gracia)
let _fecha_60_dias	= _periodo_gracia + 60;

-- Envio Aviso Cancelacion (1 dias despues del periodo de gracia)
let _fecha_aviso	= _periodo_gracia + 1;

-- Nueva vigencia inicial	
if _vigencia_inic = '01/01/1900' then 
	let _vigencia_f  = _fecha_1_pago;
end if

let _vigencia   = _vigencia_f ;
let _vigencia_f = _vigencia + _dias_letra;

if _letra = _no_pagos then
	let _vigencia_f = _vigencia_final;
	let _dias_letra = _vigencia_f - _vigencia;
	
	if _vigencia_f <= _periodo_gracia  then
	let _periodo_gracia = _vigencia_f - 1;
	end if	
end if

insert into emiletra (
		no_poliza,
		no_letra,
		fecha_vencimiento,
		periodo_gracia,
		fecha_aviso,
		cancelar_poliza,
		monto_letra,
		dias_letra,
		vigencia_inic,
		vigencia_final,
		monto_pag,
		monto_pen,
		no_documento)
values(	a_no_poliza,
		_letra,
		_fecha_pago,
		_periodo_gracia,
		_fecha_aviso,
		_fecha_60_dias,
		_monto_letra,
		_dias_letra,
		_vigencia,
		_vigencia_f,
		0.00,
		_monto_letra,
		_no_documento);

-- Calculo de la Nueva Letra
let _fecha_1_pago = _fecha_1_pago + _dias_letra;

-- Nueva vigencia inicial
let _vigencia_inic = _fecha_1_pago;

end

call sp_cob346a(_no_documento) returning _error,_error_desc;

return 0,'Actualización Exitosa';
end procedure;