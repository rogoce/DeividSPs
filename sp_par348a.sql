-- Creado    : 21/08/2014 - Autor: Armando Moreno M.
-- Reporte para verificar letras de Tarjetas de credito diferentes

drop procedure sp_par348a;
create procedure "informix".sp_par348a()
returning char(20)		as Poliza,
          char(19)		as Tarjeta,
		  varchar(100)	as Cliente,
          dec(16,2)		as Letra_Tarjeta,
		  dec(16,2)		as Letra_Calculada,
		  dec(16,2)		as Prima_Bruta_Endoso,
		  smallint		as No_Pagos,
		  smallint		as Dia,
		  smallint		as Dia_Cobros,
		  date			as Vigencia_Inicial,
		  date			as Fecha_Emision,
		  date			as Fecha_ult_cambio,
		  dec(16,2)		as monto_ult_cambio,
		  dec(16,2)		as monto_visa;

		  
define _error_desc		varchar(100);
define _nombre			varchar(100);
define _no_documento	char(20);
define _no_tarjeta		char(19);
define _no_poliza		char(10);
define _no_endoso		char(5);
define _periodo			char(7);
define _prima_bruta_tot	dec(16,2);
define _prima_b_orginal	dec(16,2);
define _prima_bruta_end	dec(16,2);
define _monto_a_cobrar	dec(16,2);
define _monto_cobcampl	dec(16,2);
define _letra_calc		dec(16,2);
define _por_vencer		dec(16,2);
define _monto_visa		dec(16,2);
define _corriente		dec(16,2);
define _exigible		dec(16,2);
define _monto_30		dec(16,2);
define _monto_60		dec(16,2);
define _monto_90		dec(16,2);
define _saldo			dec(16,2);
define _dia_cobros1		smallint;
define _dia_cobros2		smallint;
define _error_isam		smallint;
define _no_pagos		smallint;
define _estatus			smallint;
define _error			smallint;
define _dia				smallint;
define _fecha_cambio	date;
define _fecha_susc		date;
define _fecha			date;
define _vig_ini			date;

begin
on exception set _error,_error_isam,_error_desc
	drop table tmp_datos;
 	return '','',_error_desc,0.00,0.00,0.00,_error,_error_isam,0,'01/01/1900','01/01/1900','01/01/1900',0.00,0.00;
end exception

let _prima_bruta_tot	= 0;
let _monto_a_cobrar		= 0;
let _letra_calc			= 0;
let	_por_vencer			= 0;
let	_corriente			= 0;
let	_exigible			= 0;
let	_monto_30			= 0;
let	_monto_60			= 0;
let	_monto_90			= 0;
let	_saldo				= 0;
let _dia				= 0;

let _fecha_cambio	= '01/01/1900';
let _fecha			= today;

if month(_fecha) < 10 then
	let _periodo = year(_fecha) || '-0' || month(_fecha);
else
	let _periodo = year(_fecha) || '-' || month(_fecha);
end if

create temp table tmp_datos(
no_documento	char(20),
monto			dec(16,2),
nombre			char(100),
no_tarjeta		char(19),
dia				smallint,
primary key (no_tarjeta, no_documento)) with no log;

insert into tmp_datos
select no_documento,
	   monto,
	   nombre,
	   no_tarjeta,
	   dia
  from cobtacre
 where no_documento[1,2] <> '18';

insert into tmp_datos
select no_documento,
	   monto,
	   nombre,
	   no_cuenta,
	   dia
  from cobcutas
 where no_documento[1,2] <> '18';

foreach
	select no_documento,
		   monto,
		   nombre,
		   no_tarjeta,
		   dia
	  into _no_documento,
		   _monto_a_cobrar,
		   _nombre,
		   _no_tarjeta,
		   _dia
	  from tmp_datos
	 order by no_documento

	foreach
		select no_poliza,
			   vigencia_inic
		  into _no_poliza,
			   _vig_ini
		  from emipomae
		 where no_documento = _no_documento
		   and actualizado = 1
		 order by vigencia_final desc

		if _vig_ini <= _fecha then
			exit foreach;
		end if
	end foreach
	
	select estatus_poliza,
		   no_pagos,
		   vigencia_inic,
		   fecha_suscripcion,
		   monto_visa,
		   dia_cobros1
	  into _estatus,
		   _no_pagos,
		   _vig_ini,
		   _fecha_susc,
		   _monto_visa,
		   _dia_cobros1
	  from emipomae
	 where no_poliza = _no_poliza
	   and actualizado = 1;

	if _vig_ini > _fecha then
		continue foreach;
	end if
	
	if _estatus <> 1 then
		continue foreach;
	end if
	
	let _prima_bruta_tot = 0.00;
	let _prima_b_orginal = 0.00;
	
	foreach
		select no_endoso,
			   prima_bruta
		  into _no_endoso,
			   _prima_bruta_end
		  from endedmae
		 where no_poliza = _no_poliza
		   and prima_bruta <> 0
		   and actualizado = 1

		if _no_endoso = '00000' then
			let _prima_b_orginal = _prima_bruta_end;
		end if
		
		let _prima_bruta_tot = _prima_bruta_tot + _prima_bruta_end;
	end foreach
	
	call sp_cob33('001', '001', _no_documento, _periodo, _fecha)
	returning   _por_vencer,
				_exigible,
				_corriente,
				_monto_30,
				_monto_60,
				_monto_90,
				_saldo;

	if _saldo <= 0 then
		continue foreach;
	end if
	
	let _letra_calc = _prima_bruta_tot / _no_pagos;

	if _monto_a_cobrar <> _letra_calc then
		if abs(_monto_a_cobrar - _letra_calc) > 0.01 then
			
			let _monto_cobcampl = 0.00;
			
			foreach
				select fecha_cambio,
					   monto_visa
				  into _fecha_cambio,
					   _monto_cobcampl
				  from cobcampl
				 where no_documento = _no_documento
				 order by fecha_cambio desc
				exit foreach;
			end foreach
			
			if _fecha_cambio is null then
				let _fecha_cambio = '01/01/1900';
				let _monto_cobcampl = 0.00;
			end if

			return	_no_documento,		--Póliza
					_no_tarjeta,		--Tarjeta
					_nombre,			--Cliente
					_monto_a_cobrar,	--Letra Actual
					_letra_calc,		--Letra Calculada
					_prima_bruta_tot,	--Prima Bruta Total
					_no_pagos,		
					_dia,
					_dia_cobros1,
					_vig_ini,
					_fecha_susc,
					_fecha_cambio,
					_monto_cobcampl,
					_monto_visa with resume;
		end if
	end if
end foreach
end
end procedure;