-- Ajuste de las letras del número de letras en base al no_pagos de emisión.
-- Creado    : 24/07/2015 - Autor: Román Gordón
-- SIS v.2.0 - DEIVID, S.A.
  
drop procedure sp_pro541c;
create procedure sp_pro541c(
a_no_poliza		char(10),
a_letras_extras	smallint)
returning	int,
			varchar(100);

define _error_desc		varchar(100);
define _no_documento	char(20);
define _cod_formapag	char(3);
define _cod_ramo		char(3);
define _sum_monto_pen	dec(16,2);
define _dias_letra_dec	dec(16,2);
define _monto_pag_ac	dec(16,2);
define _monto_letra		dec(16,2);
define _monto_pen		dec(16,2);
define _monto_pag		dec(16,2);
define _mes_dec			dec(16,2);
define _resto           dec(16,2);
define _min_no_pagada	smallint;
define _cnt_no_letra	smallint;
define _no_pagos_emi	smallint;
define _no_letra		smallint;
define _no_pagos		smallint;
define _cnt_pen			smallint;
define _pagada			smallint;
define _mes_int			smallint;
define _letra			smallint;
define _dias_vigencia	integer;
define _dias_letra		integer;
define _error_isam		integer;
define _error			integer;
define _vigencia_final	date;
define _periodo_gracia	date;
define _vigencia_inic   date;
define _fecha_60_dias	date;
define _fecha_1_pago	date;
define _fecha_aviso		date;
define _fecha_pago		date;
define _vigencia_f      date;
define _vigencia		date;

set isolation to dirty read;

begin 
on exception set _error, _error_isam, _error_desc
	let _error_desc = trim(_error_desc) || 'no_poliza: ' || trim(_no_documento);
	return _error, _error_desc;
end exception

if a_no_poliza = '2851088' then
set debug file to "sp_pro541c.trc";
trace on;
end if

let _vigencia_inic = '01/01/1900';
let _monto_pag_ac = 0.00;
let _cnt_no_letra = 0;
let _no_pagos = 0;
let _no_documento = '';
let _cod_formapag = '';
let _cod_ramo = '';
let _vigencia_final = null;
let _fecha_1_pago = null;
let _fecha_pago = null;

drop table if exists tmp_emiletra;
select *
  from emiletra
 where no_poliza = a_no_poliza
  into temp tmp_emiletra;

select count(*)
  into _cnt_no_letra
  from emiletra
 where no_poliza = a_no_poliza;

if _cnt_no_letra is null then
	let _cnt_no_letra = 0;
end if

if _cnt_no_letra <= 0 then
	return 1,'No se encontraron registros para el # de Póliza: ' || trim(a_no_poliza);
end if

select no_documento,
	   vigencia_final,
	   cod_formapag,
	   cod_ramo
  into _no_documento,
	   _vigencia_final,
	   _cod_formapag,
	   _cod_ramo
  from emipomae
 where no_poliza = a_no_poliza;

if _cod_ramo = '018' then
	return 0,'El Ramo de Salud no Aplica para este proceso.' || trim(a_no_poliza);
end if

select count(*),
	   sum(monto_letra),
	   min(no_letra)
  into _cnt_pen,
	   _sum_monto_pen,
	   _min_no_pagada
  from emiletra
 where no_poliza = a_no_poliza
   and pagada = 0;

if _cnt_pen is null or _cnt_pen = 0 then
	let _sum_monto_pen = 0.00;
	let _min_no_pagada = 0;
	let _cnt_pen = 0;
	
	return 0,'No es Posible hacer el ajuste de letras ya que todas han sido pagadas. ' || trim(a_no_poliza);
end if

select vigencia_inic,
	   monto_pag
  into _fecha_1_pago,
	   _monto_pag_ac
  from tmp_emiletra
 where no_poliza = a_no_poliza
   and no_letra = _min_no_pagada;

select max(fecha)
  into _fecha_pago
  from cobredet
 where no_poliza = a_no_poliza
   and tipo_mov = 'P'
   and actualizado = 1;

let _no_pagos = _cnt_no_letra + a_letras_extras;
let _no_letra = _cnt_pen + a_letras_extras;

select pagada
  into _pagada
  from emiletra
 where no_poliza = a_no_poliza
   and no_letra = _no_pagos;

if _pagada = 1 then
	return 1,'No es Posible hacer el ajuste de letras ya que la letra ' || _no_pagos ||' ya fue pagada.'|| trim(a_no_poliza);
end if


--El # de pagos a quitar no puede ser mayor al número de letras pendientes
--El # de pagos nuevo no puede ser mayor al número de pagos máximos aceptados por  la forma de pago.
{if (_no_letra <= 0 and _no_pagos ) then
	return 1,'No es posible cambiar el # de Pagos a ' || cast(_no_pagos as varchar(2)) ||  ' para el # de Póliza: ' || trim(a_no_poliza);
end if}

delete from emiletra
 where no_poliza = a_no_poliza
   and pagada = 0;

let _dias_vigencia = _vigencia_final - _fecha_1_pago;
let _dias_letra_dec = _dias_vigencia / _no_letra;
let _monto_letra = _sum_monto_pen / _no_letra;
let _dias_letra = _dias_vigencia / _no_letra;

if _dias_letra_dec > _dias_letra then
	let _dias_letra = _dias_letra + 1;
end if

let _mes_int = 12 / _no_letra;
let _mes_dec = 12 / _no_letra;

if _mes_dec > _mes_int then
	let _mes_int = _mes_int + 1;
end if

let _resto = _sum_monto_pen;

for	_letra = _min_no_pagada to _no_pagos

	let _monto_pag = 0.00;
	let _monto_pen = _monto_letra;
	let _pagada = 0;

	if _monto_pag_ac > 0 then
		if _monto_pag_ac > _monto_letra then
			let _monto_pen = 0;
			let _monto_pag = _monto_letra;
			let _pagada = 1;
		else
			let _monto_pag = _monto_pag_ac;
			let _monto_pen = _monto_letra - _monto_pag_ac;
		end if
		
		let _monto_pag_ac = _monto_pag_ac - _monto_letra;
	end if

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
			no_documento,
			pagada)
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
			_monto_pag,
			_monto_pen,
			_no_documento,
			_pagada);

	-- Calculo de la Nueva Letra
	let _fecha_1_pago = _fecha_1_pago + _dias_letra;
	let _resto = _resto - _monto_letra;

	-- Nueva vigencia inicial
	let _vigencia_inic = _fecha_1_pago;
end for

update emiletra	
   set monto_letra = monto_letra + _resto,
	   monto_pen = monto_letra + _resto
 where no_poliza = a_no_poliza
   and no_letra  = _no_pagos;

end

drop table if exists tmp_emiletra;
call sp_cob346a(_no_documento) returning _error,_error_desc;

return 0,'Actualización Exitosa';
end procedure;