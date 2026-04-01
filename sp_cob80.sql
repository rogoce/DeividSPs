-- Carga de la tabla para la generación del archivo que se enviará al banco.

-- Creado    : 03/09/2001 - Autor: Armando Moreno
-- Modificado: 26/12/2001 - Autor: Armando Moreno

-- SIS v.2.0 - DEIVID, S.A.

drop procedure sp_cob80;
create procedure "informix".sp_cob80(
a_compania	char(3),
a_sucursal	char(3),
a_fecha		date,
a_user		char(8))
returning	smallint,
			char(100);

define _error_desc			char(100);
define _nombre_pagador		char(100);
define _nombr				char(100);
define _campo				char(81);
define _adenda				char(80);
define _mensaje				char(50);
define _aseg_resultado		char(22);
define _no_documento		char(20);
define _no_cuenta			char(17);
define _monto_char			char(11);
define _cod_cliente			char(10);
define _cod_pagador			char(10);
define _no_poliza			char(10);
define _ruta_char			char(9);
define _fecha_char			char(8);
define v_periodo			char(7);
define _orden				char(6);
define _no_lote_char		char(5);
define _cedula				char(5);
define _cant_tran_char		char(3);
define _cod_banco			char(3);
define _char_3				char(3);
define _mes_char			char(2);
define _dia_char			char(2);
define _codigo				char(2);
define _tipo_transaccion	char(1);
define _tipo_cuenta			char(1);
define _char_2				char(1);
define _cargo_especial_tmp	dec(16,2);
define _cargo_especial		dec(16,2);
define _monto_poliza		dec(16,2);
define v_por_vencer			dec(16,2);
define v_corriente			dec(16,2);
define _monto_ach			dec(16,2);
define v_exigible			dec(16,2);
define v_monto_30			dec(16,2);
define v_monto_60			dec(16,2);
define v_monto_90			dec(16,2);
define _ult_pago			dec(16,2);
define _monto				dec(16,2);
define _saldo				dec(16,2);
define _dif        			dec(16,2);
define _pronto_pago			smallint;
define _cnt_dia_esp			smallint;
define _error_isam			smallint;
define _error_code			smallint;
define _tipo_monto			smallint;
define _cnt_trans			smallint;
define _rechazada			smallint;
define _cnt_dia				smallint;
define _valor				smallint;
define _dia					smallint;
define _ruta_numero			integer;
define _dia_especial        integer;
define _max_por_lote		integer;
define _max_por_tran		integer;
define _cant_tran			integer;
define _cant_lote			integer;
define _mes					integer;
define _ano					integer;
define _van					integer;
define _cnt					integer;
define _max					integer;
define i					integer;
define _fecha_proceso		date;
define _fecha_inicio		date;
define _fecha_hasta			date;
define _fecha_hoy			date;
define v_fecha				date;


--SET DEBUG FILE TO "sp_cob80.trc";
--trace on;

begin

on exception set _error_code,_error_isam,_error_desc 
	let _error_desc = trim(_error_desc) || 'Error al Actualizar las Transacciones para el Banco. Cuenta:'||_no_cuenta;
 	return _error_code, _error_desc;
end exception           

delete from cobcuban;

let v_fecha  = today;
let _mensaje = "";

if month(v_fecha) < 10 then
	let v_periodo = year(v_fecha) || '-0' || month(v_fecha);
else
	let v_periodo = year(v_fecha) || '-' || month(v_fecha);
end if 


let _max_por_tran	= 99999;
let _max_por_lote	= 99;
let _char_3			= '   ';
let _char_2			= ' ';
let _fecha_hoy		= today;

	{select * 
	  from cobcutmp
	 where 1=2
	  into temp temp_cobcutmp;}

let _cant_lote = 0;
let _cant_tran = 0;

--delete from cobcutmp;
delete from cobculot;

let _cant_lote    = _cant_lote + 1;
let _no_lote_char = sp_set_codigo(5, _cant_lote);

insert into cobculot(
		no_lote,
		fecha,
		total_transac,
		total_monto,
		id_operador,
		id_terminal,
		id_oficina,
		procesar,
		no_remesa,
		total_cobrado)
values(	_no_lote_char,
		a_fecha,
		0,
		0,
		a_user,
		'',
		a_sucursal,
		1,
		'',
		0);

-- Selecciona los Lotes

let _monto_char = '00000000000';
let _ruta_char  = '000000000';

select max(fecha)
  into _fecha_proceso
  from cobfecach
 where procesado = 2;

call sp_cob338('ACH',_fecha_proceso) returning _error_code,_error_desc;

if _error_code <> 0 then
	return _error_code,_error_desc;
end if

delete from cobcutmp;

foreach
	select h.no_cuenta,
	   	   c.monto,
	   	   c.cargo_especial,
		   c.no_documento,
		   c.fecha_hasta,
		   c.fecha_inicio,
		   c.dia,
		   c.dia_especial,
		   c.rechazada
	  into _no_cuenta,
		   _monto,
		   _cargo_especial,
		   _no_documento,
		   _fecha_hasta,
		   _fecha_inicio,
		   _dia,
		   _dia_especial,
		   _rechazada
	  from cobcutas c, cobcuhab h
	 where c.no_cuenta = h.no_cuenta
	   and c.procesar  = 1
	   and c.excepcion = 0
	 order by h.no_cuenta
	
	--Prcoceso de Cargo adicional.
	
	let _cnt_dia = 0;
	let _cnt_dia_esp = 0;
	
	select count(*)
	  into _cnt_dia
	  from tmp_dias_proceso
	  where dia = _dia;
	
	if _cnt_dia is null then
		let _cnt_dia = 0;
	end if
	
	if _rechazada = 1 then
		let _cnt_dia = 1;
	end if
	
	if _cnt_dia > 0 then
		if _dia_especial is null then 		--Esto es para el cargo adicional.
			let _dia_especial = 0;
		end if
		
		if _fecha_hasta is not null then
			if _fecha_hasta >= _fecha_hoy then  -- tiene cargo adicional
				if _fecha_inicio <= _fecha_hoy then --ok
					
					select count(*)
					  into _cnt_dia_esp
					  from tmp_dias_proceso
					  where dia = _dia_especial;
					
					if _cnt_dia_esp is null then
						let _cnt_dia_esp = 0;
					end if
					
					if _cnt_dia_esp > 0 then   -- se debe sumar el cargo al monto
						let _monto = _monto + _cargo_especial;
					end if
				end if
			end if
		end if
	else
		--Esto es para el cargo adicional.
		if _dia_especial is null then
			let _dia_especial = 0;
		end if
		
		if _fecha_hasta is not null then
			if _fecha_hasta >= _fecha_hoy then  -- tiene cargo adicional
				if _fecha_inicio <= _fecha_hoy then --ok

					select count(*)
					  into _cnt_dia_esp
					  from tmp_dias_proceso
					  where dia = _dia_especial;
					
					if _cnt_dia_esp is null then
						let _cnt_dia_esp = 0;
					end if
					
					if _cnt_dia_esp > 0 then   -- se debe sumar el cargo al monto
						if _cargo_especial > 0 then
							let _monto = _cargo_especial;
						else
							--return 1, 'cargo especial' with resume;
							continue foreach;
						end if
					else
						--return 2, 'cargo especial' with resume;
						continue foreach;
					end if
				else
					--return 3, 'cargo especial'with resume;
					continue foreach;
				end if
			else
				--return 4, 'cargo especial'with resume;
				continue foreach;	
			end if
		end if
	end if

	call sp_cob33(a_compania, a_sucursal, _no_documento, v_periodo, v_fecha)
	returning   v_por_vencer,
				v_exigible,
				v_corriente,
				v_monto_30,
				v_monto_60,
				v_monto_90,
				_saldo;

    if _monto > _saldo then	      --cargo mayor al saldo --Se habilita la asignación del monto a cobrar
		let _monto = _saldo;
	end if

	if _monto < v_exigible then
		let _dif = 0.00;
		let _dif = v_exigible - _monto;
		
		if _dif <= 1.00 then
			let _monto = v_exigible;
		end if
	end if

	select cod_pagador,
		   tipo_monto,
		   monto_ach,
		   cnt_trans,
		   cod_banco,
		   tipo_cuenta,
		   tipo_transaccion
      into _cod_pagador,
	       _tipo_monto,
		   _monto_ach,
		   _cnt_trans,
		   _cod_banco,
		   _tipo_cuenta,
		   _tipo_transaccion
      from cobcuhab
     where no_cuenta = _no_cuenta;

	let _cedula = null;

 	select nombre,
		   cedula
	  into _nombre_pagador,
		   _cedula
 	  from cliclien                    
 	 where cod_cliente = _cod_pagador;


	if _cedula is null then
		return 1, 'No existe cedula del pagador para la cuenta: ' || _no_cuenta; 
	end if

	let _aseg_resultado = trim(_nombre_pagador);
	let _cedula = trim(_cedula);

	let _adenda = 'REF*TXT**POLIZA';

    let _adenda = trim(_adenda) || trim(_no_documento);

	let _ult_pago    = 0;
	let _pronto_pago = 0;
	
	call sp_sis21(_no_documento) returning _no_poliza;
	
	if _no_poliza is not null then
		call sp_sis395(_no_documento) returning _valor, _mensaje,_ult_pago;
	end if

	if _valor = 0 then
		let _pronto_pago = 1;
		let _monto       = _ult_pago;
	else
		let _pronto_pago = 0;		
	end if

	let _monto_char = "00000000000";

	if _monto > 9999999.99 then
		let _monto_char[1,11] = _monto;
	elif _monto > 999999.99 then
		let _monto_char[2,11] = _monto;
	elif _monto > 99999.99 then
		let _monto_char[3,11] = _monto;
	elif _monto > 9999.99 then
		let _monto_char[4,11] = _monto;
	elif _monto > 999.99 then
		let _monto_char[5,11] = _monto;
	elif _monto > 99.99 then
		let _monto_char[6,11] = _monto;
	elif _monto > 9.99 then
		let _monto_char[7,11] = _monto;
	else
		let _monto_char[8,11] = _monto;
	end if

	select ruta_numero
	  into _ruta_numero
	  from chqbanco
	 where cod_banco = _cod_banco;

	let _ruta_char = "000000000";

	if   _ruta_numero > 99999999 then
		let _ruta_char[1,9] = _ruta_numero;
	elif _ruta_numero > 9999999 then
		let _ruta_char[2,9] = _ruta_numero;
	elif _ruta_numero > 999999 then
		let _ruta_char[3,9] = _ruta_numero;
	elif _ruta_numero > 99999 then
		let _ruta_char[4,9] = _ruta_numero;
	elif _ruta_numero > 9999 then
		let _ruta_char[5,9] = _ruta_numero;
	elif _ruta_numero > 999 then
		let _ruta_char[6,9] = _ruta_numero;
	elif _ruta_numero > 99 then
		let _ruta_char[7,9] = _ruta_numero;
	else
		let _ruta_char[8,9] = _ruta_numero;
	end if

	let _cant_tran = _cant_tran + 1;

	if _monto = 0 then
		return 5, 'cuenta: ' || trim(_no_cuenta) || ' monto 0' with resume;
		continue foreach;
	end if

	if _cant_tran > _max_por_tran then

		let _cant_tran    = 1;
		let _cant_lote    = _cant_lote + 1;
		let _no_lote_char = sp_set_codigo(5, _cant_lote);

		insert into cobculot(
				no_lote,
				fecha,
				total_transac,
				total_monto,
				id_operador,
				id_terminal,
				id_oficina,
				procesar,
				no_remesa,
				total_cobrado)
		values(	_no_lote_char,
				a_fecha,
				0,
				0,
				a_user,
				'',
				a_sucursal,
				1,
				'',
				0);
	end if

   	let _cedula = sp_set_codigo(5, _cant_tran);

    let _campo[1,1]   = 'L';
    let _campo[2,16]  = _cedula;
	let _campo[17,38] =	_aseg_resultado;
	let _campo[39,49] =	trim(_monto_char);
	let _campo[50,58] =	trim(_ruta_char);
	let _campo[59,75] =	trim(_no_cuenta);
	let _campo[76,76] =	trim(_tipo_cuenta);
	let _campo[77,77] =	trim(_tipo_transaccion);
	let _campo[78,78] =	' ';
	let _campo[79,81] =	'   ';

	let _orden = _cedula;

	insert into cobcuban 
	values (_campo,_orden);

	let _campo = 'A' || trim(_adenda);
	let _orden = _cedula || 'A';

	insert into cobcuban 
	values (_campo,_orden);

	insert into cobcutmp
	values (
	_cant_tran,
	_no_cuenta,
	_cod_pagador,
	'',
	_nombre_pagador,
	_monto,
	0,
	0,
	'',
	'',
	_no_lote_char,
	_no_documento,
	_pronto_pago
	);

	update cobcutas
	   set fecha_ult_tran = a_fecha
	 where no_cuenta      = _no_cuenta
	   and procesar       = 1
	   and excepcion      = 0;
end foreach

foreach
	select count(*),
		   sum(monto),
		   no_lote
	  into _cant_tran,
		   _monto,
		   _no_lote_char
	  from cobcutmp
	 group by no_lote      

	update cobculot
	   set total_transac = _cant_tran,
	       total_monto   = _monto
     where no_lote       = _no_lote_char;     
end foreach


return 0, 'Actualizacion Exitosa ...'; 
end 
end procedure;