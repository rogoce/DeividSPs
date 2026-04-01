-- Creado    : 21/08/2014 - Autor: Armando Moreno M.
-- Reporte para verificar letras de Tarjetas de credito diferentes

drop procedure sp_par351;
create procedure "informix".sp_par351()
returning char(20)		as Poliza,
		  char(19)		as tarjeta_cuenta,
		  smallint		as No_Pagos,
		  varchar(100)	as Cliente,
          varchar(100)	as Nom_FormaPago,
          dec(16,2)		as letra_a_cobrar,
		  dec(16,2)		as PrimaBruta_Endoso,
		  dec(16,2)		as PrimaBruta_Emi,
		  dec(16,2)		as Diferencia;

define _nom_formapag	varchar(100);
define _nombre			varchar(100);
define _no_documento	char(20);
define _no_tarjeta		char(19);
define _no_poliza		char(10);
define _periodo			char(7);
define _cod_formapag	char(3);
define _cod_ramo		char(3);
define _prima_bruta_e	dec(16,2);
define _prima_bruta		dec(16,2);
define _dif_letra		dec(16,2);
define _prima_b			dec(16,2);
define _saldo			dec(16,2);
define _monto			dec(16,2);
define _cnt_existe		smallint;
define _no_pagos		smallint;
define _estatus			smallint;
define _dia				smallint;
define _fecha_hoy		date;
define _vig_ini			date;

let _prima_bruta	= 0;
let _prima_b		= 0;
let _monto			= 0;
let	_saldo			= 0;
let _dia			= 0;

let _fecha_hoy = today;

if month(_fecha_hoy) < 10 then
	let _periodo = year(_fecha_hoy) || '-0' || month(_fecha_hoy);
else
	let _periodo = year(_fecha_hoy) || '-' || month(_fecha_hoy);
end if 

foreach
	select prima_bruta,
	       no_pagos,
		   no_documento,
		   no_poliza,
		   cod_formapag
	  into _prima_bruta,
	       _no_pagos,
		   _no_documento,
		   _no_poliza,
		   _cod_formapag
	  from endedmae
	 where periodo = _periodo
	   and cod_endomov in ('014','011')
	   and actualizado = 1

	select cod_ramo,
		   prima_bruta
	  into _cod_ramo,
		   _prima_bruta_e
	  from emipomae
	 where no_poliza = _no_poliza;

	if _cod_ramo <> '018' then
		continue foreach;
	end if

	let _cnt_existe = 0;

	if _cod_formapag = '003' then
		select count(*)
		  into _cnt_existe
		  from cobtacre
		 where no_documento = _no_documento;

		if _cnt_existe is null or _cnt_existe = 0 then
			continue foreach;
		end if

		select monto,
			   nombre,
			   no_tarjeta,
			   dia
		  into _monto,
			   _nombre,
			   _no_tarjeta,
			   _dia
		  from cobtacre
		 where no_documento = _no_documento;
	elif _cod_formapag = '005' then
		select count(*)
		  into _cnt_existe
		  from cobcutas
		 where no_documento = _no_documento;

		if _cnt_existe is null or _cnt_existe = 0 then
			continue foreach;
		end if

		select monto,
			   nombre,
			   no_cuenta,
			   dia
		  into _monto,
			   _nombre,
			   _no_tarjeta,
			   _dia
		  from cobcutas
		 where no_documento = _no_documento;
	else
		continue foreach;
	end if

	select nombre
	  into _nom_formapag
	  from cobforpa
	 where cod_formapag = _cod_formapag;

	let _dif_letra = 0.00;
	let _dif_letra = _prima_bruta - _monto;

	if abs(_dif_letra) <> 0.00 then
		{update cobtacre
		   set monto = _prima_bruta
		 where no_documento = _no_documento;}
		return	_no_documento,
				_no_tarjeta,
				_no_pagos,
				_nombre,
				_nom_formapag,
				_monto,
				_prima_bruta,
				_prima_bruta_e,
				_dif_letra with resume;
	end if
end foreach
end procedure;