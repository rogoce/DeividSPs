-- Preliminar de la Generacion de los Lotes de las Tarjetas de Credito America Express solamente.
-- Creado    : 23/02/2001 - Autor: Demetrio Hurtado Almanza 
-- Modificado: 26/03/2001 - Autor: Demetrio Hurtado Almanza
-- SIS v.2.0 - DEIVID, S.A.

drop procedure sp_cob146;
create procedure "informix".sp_cob146(a_compania char(3),a_sucursal char(3),a_fecha_hasta date)
returning	char(19),
			char(7),
			char(100),
			char(20),
			date,
			date,
			dec(16,2),
			dec(16,2),
			char(3),
			char(50),
			char(50),
			dec(16,2);

define _error_desc			char(100);
define _nombre				char(100);
define v_compania_nombre	char(50);
define _nombre_agente		char(50);
define _nombre_banco		char(50);
define _mensaje				char(50);
define _no_documento		char(20);
define _no_tarjeta			char(19); 
define _cod_cliente			char(10);
define _cod_agente			char(10);
define _no_poliza			char(10);
define _periodo_today		char(7);
define _periodo_visa		char(7);
define _fecha_exp			char(7);
define v_periodo			char(7);
define _cod_formapag		char(3);
define _cod_banco			char(3);
define _procesar			char(3);
define _cod_ramo			char(3);
define _estatus_poliza		char(1);
define _tipo_tarjeta		char(1);
define _estatus_visa		char(1);
define _nueva_renov			char(1);
define _periodo2			char(1);
define _periodo				char(1);
define _tiene				char(1);
define _cargo_especial		dec(16,2);
define _prima_bruta			dec(16,2);
define v_por_vencer			dec(16,2);
define v_corriente			dec(16,2);
define v_exigible			dec(16,2);
define v_monto_30			dec(16,2);
define v_monto_60			dec(16,2);
define v_monto_90			dec(16,2);
define _ult_pago			dec(16,2);  				
define v_saldo				dec(16,2);
define _monto				dec(16,2);
define _saldo				dec(16,2);
define _cargo				dec(16,2);
define _dif                 dec(16,2);
define _control_procesar	smallint;
define _control_perpago		smallint;
define _rechazada_si		smallint;
define _rechazada_no		smallint;
define _dia_especial		smallint;
define _cnt_perpago			smallint;
define _cnt_dia_esp			smallint;
define _tipo_forma			smallint;
define _rechazada			smallint;
define _excepcion			smallint;
define _ramo_sis			smallint;
define _cantidad			smallint;
define _cnt_ofac			smallint;
define _no_pagos			smallint;
define _cnt_dia             smallint;
define _dia_esp             smallint;
define _mes_esp             smallint;
define _mes_hoy             smallint;
define _valor				smallint;
define _rech				smallint;
define _dia					smallint;
define _error               integer;
define _vigencia_final		date;     
define _vigencia_inic		date;
define _fecha_inicio		date;
define _fecha_1_pago		date;
define _fecha_hasta			date;
define _fecha_hoy			date;
define v_fecha				date;

-- Nombre de la Compania

LET  v_compania_nombre = sp_sis01(a_compania); 

LET v_fecha = TODAY;
let _fecha_hoy = today;
let _mes_hoy = month(_fecha_hoy);


IF MONTH(v_fecha) < 10 THEN
	LET v_periodo = YEAR(v_fecha) || '-0' || MONTH(v_fecha);
ELSE
	LET v_periodo = YEAR(v_fecha) || '-' || MONTH(v_fecha);
END IF 

let _mensaje = "";

SET ISOLATION TO DIRTY READ;

--set debug file to "sp_cob146.trc";
--trace on;

create temp table tmp_tarjeta(
	no_tarjeta		char(19),
	fecha_exp		char(7), 
	nombre			char(100),
	no_documento	char(20),
	vigencia_inic	date,
	vigencia_final	date,
	monto			dec(16,2),
	saldo			dec(16,2),
	procesar		char(3),
	cod_banco		char(3),
	primary key (no_tarjeta, no_documento)
) with no log;

if month(today) < 10 then
	let _periodo_today = year(today) || '-0' || month(today);
else
	let _periodo_today = year(today) || '-' || month(today);
end if

select estatus_visa
  into _estatus_visa
  from parparam
 where cod_compania = a_compania;

if _estatus_visa = "1" then	--proceso normal
	let _rechazada_si = 1;
	let _rechazada_no = 0;
else
	let _rechazada_si = 1;
	let _rechazada_no = 1;
end if

call sp_cob338('AME',a_fecha_hasta) returning _error,_error_desc;

if _error <> 0 then
	return '','',_error_desc,'','01/01/1900','01/01/1900',_error,0.00,'','','',0.00;
end if

call sp_cob339a() returning _error,_error_desc;

if _error <> 0 then
	return '','',_error_desc,'','01/01/1900','01/01/1900',_error,0.00,'','','',0.00;
end if

-- Polizas con Forma de Pago Tarjeta y No Tienen Tarjetas Creadas
{
if _estatus_visa = "1" then

	update cobtacre
	   set rechazada = 0
	 where no_tarjeta in (select no_tarjeta from cobtahab where tipo_tarjeta = '4');

	foreach                 
		select p.no_documento    
		  into	_no_documento  
		  from emipomae p, cobforpa f       
		 where	p.actualizado   = 1
		   and p.cod_formapag  = f.cod_formapag
		   and f.tipo_forma    = 2      --tarjeta credito
		   and p.tipo_tarjeta = "4"	 --american express
		 group by p.no_documento 

		foreach
			select cod_formapag,
				   vigencia_inic,
				   vigencia_final,
				   cod_contratante,
				   estatus_poliza
			  into _cod_formapag,
				   _vigencia_inic,
				   _vigencia_final,
				   _cod_cliente,
				   _estatus_poliza
			  from emipomae
			 where no_documento  = _no_documento
			   and actualizado   = 1
			 order by vigencia_final desc
			exit foreach;
		end foreach

		select tipo_forma
		  into _tipo_forma
		  from cobforpa
		 where cod_formapag = _cod_formapag;

		if _tipo_forma <> 2 then
			continue foreach;
		end if

		if _estatus_poliza = '2' or
		   _estatus_poliza = '4' then
			continue foreach;
		end if

		let _monto = null;

		call sp_cob33d(a_compania, a_sucursal, _no_documento, v_periodo, v_fecha)
		returning   v_por_vencer,
					v_exigible,
					v_corriente,
					v_monto_30,
					v_monto_60,
					v_monto_90,
					_saldo;
		foreach	
			select monto
			  into _monto
			  from cobtacre
			 where no_documento = _no_documento
			exit foreach;
		end foreach

		if _monto is null then

			select nombre                      
			  into _nombre                     
			  from cliclien                    
			 where cod_cliente = _cod_cliente; 

			insert into tmp_tarjeta
			values(
			'',
			'',
			_nombre,
			_no_documento,
			_vigencia_inic,
			_vigencia_final,
			0.00,
			_saldo,
			'006',
			'');
		end if
	end foreach

	-- Polizas que tienen Tarjetas de Credito y su Forma de Pago 
	-- No es con Tarjeta de Credito
	foreach 
		select c.no_documento,
			   h.no_tarjeta,
			   h.fecha_exp,
			   h.nombre,
			   c.monto,
			   h.cod_banco
		  into _no_documento,
			   _no_tarjeta,
			   _fecha_exp,
			   _nombre,
			   _monto,
			   _cod_banco
		  from cobtacre c, cobtahab h
		 where c.dia in (select dia from tmp_dias_proceso)
		   and c.no_tarjeta = h.no_tarjeta
		   and h.tipo_tarjeta = "4"

		let _cod_formapag = null;
		let _no_poliza    = sp_sis21(_no_documento);

		select cod_formapag,
			   vigencia_inic,
			   vigencia_final
		  into _cod_formapag,
			   _vigencia_inic,
			   _vigencia_final
		  from emipomae
		 where no_poliza = _no_poliza;

		if _cod_formapag is null then
			continue foreach;
		end if

		select tipo_forma                
		  into _tipo_forma
		  from cobforpa                       
		 where cod_formapag = _cod_formapag;  

		if _tipo_forma <> 2 then
			call sp_cob33d(a_compania, a_sucursal, _no_documento, v_periodo, v_fecha)
			returning   v_por_vencer,
						v_exigible,
						v_corriente,
						v_monto_30,
						v_monto_60,
						v_monto_90,
						_saldo;
			begin
			on exception in(-239)
			end exception
				insert into tmp_tarjeta
				values(
				_no_tarjeta,
				_fecha_exp,
				_nombre,
				_no_documento,
				_vigencia_inic,
				_vigencia_final,
				_monto,
				_saldo,
				'007',
				_cod_banco
				);
			end
		end if
	end foreach
end if
}
-- Procesa Todas las Tarjetas de Credito
let _fecha_hasta = null;

foreach
	select no_tarjeta,
		   monto,
		   cargo_especial,
		   fecha_exp,
		   no_documento,
		   nombre,
		   cod_banco,
		   excepcion,
		   tipo_tarjeta,
		   rechazada,
		   dia,
		   dia_especial,
		   fecha_hasta,
		   fecha_inicio
	  into _no_tarjeta,
		   _monto,
		   _cargo,
		   _fecha_exp,
		   _no_documento,
		   _nombre,
		   _cod_banco,
		   _excepcion,
		   _tipo_tarjeta,
		   _rechazada,
		   _dia,
		   _dia_especial,
		   _fecha_hasta,
		   _fecha_inicio
	  from tmp_procesar

--    AND (c.periodo      = a_periodo
--	 OR c.periodo2     is not null)

	if _fecha_inicio is null then
		let _fecha_inicio = _fecha_hoy;
	end if

	let _cnt_ofac = 0;
	
	select count(*)
	  into _cnt_ofac
	  from ofac
	  where no_documento = _no_documento;

	if _cnt_ofac is null then
		let _cnt_ofac = 0;
	end if
	
	if _cnt_ofac <> 0 then
		continue foreach;
	end if

	let _cnt_dia = 0;
	
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
	
	{if _cnt_dia <> 0 then
		if _fecha_hasta is not null then
			if _fecha_hasta >= _fecha_hoy then  -- tiene cargo adicional
				if _fecha_inicio <= _fecha_hoy then
					if _dia = _dia_especial then   -- se debe sumar el cargo al monto
						let _monto = _monto + _cargo;
					end if
				end if
			end if
		end if
	else --Esto es para el cargo adicional.
		if _fecha_hasta is not null then
			if _fecha_hasta >= _fecha_hoy then  -- tiene cargo adicional
				if _fecha_inicio <= _fecha_hoy then

					let _cnt_dia = 0;

					select count(*)
					  into _cnt_dia
					  from tmp_dias_proceso
					 where dia = _dia_especial;
					
					if _cnt_dia is null then
						let _cnt_dia = 0;
					end if
					if _cnt_dia <> 0 then   -- se debe sumar el cargo al monto
						if _cargo > 0 then
							let _monto = _cargo;
						else
							continue foreach;
						end if
					else
						continue foreach;
					end if
				else
					continue foreach;
				end if
			else
				continue foreach;	
			end if
		else
			continue foreach;
		end if
	end if}
	
	if _cnt_dia = 0 then
		if _dia_especial is null then	--Esto es para el cargo adicional.
			let _dia_especial = 0;
		end if

		let _tiene = "";

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
						if _cargo > 0 then
							let _tiene = "1";
							let _monto = _cargo;
						else
							continue foreach;
						end if
					else
						continue foreach;
					end if
				else
					continue foreach;
				end if
			else
				continue foreach;	
			end if
		else
			continue foreach;
		end if
	else
		--Esto es para el cargo adicional.
		if _dia_especial is null then
			let _dia_especial = 0;
		end if

		let _tiene = "";

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

					if _cnt_dia_esp <> 0 then    -- se debe sumar el cargo al monto
						let _tiene = "1";
						let _monto = _monto + _cargo;
					end if
				end if
			end if
		end if
	end if

	let _periodo_visa = _fecha_exp[4,7] || '-' || _fecha_exp[1,2];

	let _vigencia_inic  = null;
	let _vigencia_final = null;
	let _no_poliza      = sp_sis21(_no_documento);
	
	select vigencia_inic,
		   vigencia_final,
		   cod_ramo,
		   estatus_poliza,
		   fecha_primer_pago,
		   nueva_renov,
		   prima_bruta,
		   no_pagos
	  into _vigencia_inic,
		   _vigencia_final,
		   _cod_ramo,
		   _estatus_poliza,
		   _fecha_1_pago,
		   _nueva_renov,
		   _prima_bruta,
		   _no_pagos
	  from emipomae
	 where no_poliza = _no_poliza;

	let _cnt_perpago = 0;
	let _control_perpago = 0;
	
	if _cod_ramo <> '018' then
		let _cnt_perpago = null;

		select count(*)
		  into _cnt_perpago
		  from emipomae
		 where no_documento = _no_documento
		   and cod_perpago in (select cod_perpago from cobperpa where meses not in (0,1))
		   and _fecha_hoy between vigencia_inic and vigencia_final
		   and actualizado = 1;

		if _cnt_perpago is null  then
			let _cnt_perpago = 0;
		end if

		let _control_perpago = 0;

		if _cnt_perpago > 0 then
			call sp_cob391(_no_documento) returning _control_perpago, _error_desc;
		end if
	end if

	let _saldo = null;

	call sp_cob33d(a_compania, a_sucursal, _no_documento, v_periodo, v_fecha)
	returning   v_por_vencer,
				v_exigible,
				v_corriente,
				v_monto_30,
				v_monto_60,
				v_monto_90,
				_saldo;
				
	select ramo_sis
	  into _ramo_sis
	  from prdramo
	 where cod_ramo = _cod_ramo;

	--esto se pone hasta que me consigan la validacion de la american
--	let _tarjeta_errada = 0;

--	IF _tarjeta_errada = 1 THEN

	{if _ramo_sis = 5 then
		if v_exigible <> 0 then
			let _monto = v_exigible; --15/09/2014 9:20 am
		end if
	end if}
	
	if _fecha_exp is null then
		let _fecha_exp = '';
	end if

	if _saldo = 0 then
		let _procesar = '030';
	elif _excepcion = 1 then
		let _procesar = '040';
	elif _fecha_exp = '' then				--Fecha Exp. Incorrecta
		let _procesar = '011';
	elif _tiene = '1' then
		let _procesar = '100';
	elif _rechazada = 1 then
		if _estatus_visa = "1" then
			let _procesar = '003';
			update cobtahab
			   set rechazada = 0
			 where no_tarjeta = _no_tarjeta;
		else
			if _saldo <= 0 then
				if _estatus_poliza = '2' or
				   _estatus_poliza = '4' then
					let _procesar = '035';
				else
					let _procesar = '020';
				end if
			else
				let _procesar = '100';
			end if
		end if
		
		if _monto > _saldo then
			let _procesar = '030';		-- Cargo Mayor al Saldo
		end if
		
	elif _saldo is null then
		let _procesar = '009';
	elif _periodo_today > _periodo_visa then
	   if _estatus_poliza = '1' and _saldo > 0 then
			let _procesar = '100';
	   else
			let _procesar = '010';
	   end if
	elif _fecha_1_pago > today and _nueva_renov = "N" then
		let _dia_esp = day(_fecha_1_pago);		
		let _mes_esp = month(_fecha_1_pago);
		
		if _mes_esp = _mes_hoy then
			let _cargo_especial = 0.00;
			let _cargo_especial = _prima_bruta / _no_pagos;
			
			if _dia_esp <> _dia then
				update cobtacre
				   set cargo_especial = _cargo_especial,
					   dia_especial = _dia_esp,
					   fecha_inicio = _fecha_1_pago,
					   fecha_hasta = _fecha_1_pago
				 where no_tarjeta = _no_tarjeta
				   and no_documento = _no_documento;
			end if
		end if
		
		let _procesar = '004';
	elif _fecha_1_pago > today and _nueva_renov = "R" and v_exigible = 0 then
		let _dia_esp = day(_fecha_1_pago);		
		let _mes_esp = month(_fecha_1_pago);
		
		if _mes_esp = _mes_hoy then
			let _cargo_especial = 0.00;
			let _cargo_especial = _prima_bruta / _no_pagos;
			
			if _dia_esp <> _dia then
				update cobtacre
				   set cargo_especial = _cargo_especial,
					   dia_especial = _dia_esp,
					   fecha_inicio = _fecha_1_pago,
					   fecha_hasta = _fecha_1_pago
				 where no_tarjeta = _no_tarjeta
				   and no_documento = _no_documento;
			end if
		end if

		let _procesar = '004';		
	elif _saldo <= 0 then
		if _estatus_poliza = '2' or
		   _estatus_poliza = '4' then
			let _procesar = '035';
		else
			if _ramo_sis = 5 then
				let _procesar = '100';
			else
				let _procesar = '020';
			end if			
		end if
	elif _monto > _saldo then
		if abs(_monto - _saldo) < 1.00 then
			let _procesar = '100';
			let _monto = _saldo;
		else
			let _procesar = '030';
		end if
	elif _control_perpago = 1 then
		let _control_procesar = sp_cob392(_no_documento,_dia,'TCR');

		if _control_procesar = 1 then
			let _procesar = '100'; --Tarjeta Normal
		elif _control_procesar = 0 then
			let _procesar = '012';	--Periodo de Pagos
		end if
	else
		let _procesar = '100';
	end if

	if _procesar = '100' then
		call sp_cob33d(a_compania, a_sucursal, _no_documento, v_periodo, v_fecha)
		returning   v_por_vencer,
					v_exigible,
					v_corriente,
					v_monto_30,
					v_monto_60,
					v_monto_90,
					v_saldo;

		if _monto < v_exigible then

			let _dif = 0.00;
			let _dif = v_exigible - _monto;
			if _dif <= 1.00 then
				let _monto = v_exigible;
			end if

			let _procesar = '090';
			let _saldo    = v_exigible;
		end if
	end if

	begin
	on exception in(-239)
	end exception
		insert into tmp_tarjeta
		values(
		_no_tarjeta,
		_fecha_exp,
		_nombre,
		_no_documento,
		_vigencia_inic,
		_vigencia_final,
		_monto,
		_saldo,
		_procesar,
		_cod_banco
		);
	end   		   	
end foreach

foreach
	select no_tarjeta,
		   fecha_exp,
		   nombre,
		   no_documento,
		   vigencia_inic,
		   vigencia_final,
		   monto,
		   saldo,
		   procesar,
		   cod_banco
	  into _no_tarjeta,
		   _fecha_exp,
		   _nombre,
		   _no_documento,
		   _vigencia_inic,
		   _vigencia_final,
		   _monto,
		   _saldo,
		   _procesar,
		   _cod_banco
	  from tmp_tarjeta
	 order by procesar, nombre

	select nombre
	  into _nombre_banco
	  from chqbanco
	 where cod_banco = _cod_banco;

	{if _estatus_visa = "2" then	--Modo Rechazadas
		select rechazada
		  into _rech
		  from cobtacre
		 where no_tarjeta   = _no_tarjeta
		   and no_documento	= _no_documento;

		if _rech = 1 then
		else
			let _procesar = '040';
		end if
	end if}
	
	let _no_poliza = sp_sis21(_no_documento);

	let _ult_pago = 0;
	call sp_sis395(_no_documento) returning _valor, _mensaje,_ult_pago;
	
	if _procesar = '030' and _valor = 0 then  --cargo mayor al saldo y aplica el descuento
		 if _ult_pago <= _saldo then
            let _procesar = '100';
		 end if
	end if

	if _procesar = '100' or
	   _procesar = '090' or
	   _procesar = '003' then
		update cobtacre
		   set procesar     = 1
		 where no_tarjeta   = _no_tarjeta
		   and no_documento = _no_documento; 
	else
		update cobtacre
		   set procesar     = 0
		 where no_tarjeta   = _no_tarjeta
		   and no_documento = _no_documento; 
	end if

	foreach
		select cod_agente
		  into _cod_agente
		  from emipoagt
		 where no_poliza = _no_poliza
		exit foreach;
	end foreach

	select nombre
	  into _nombre_agente
	  from agtagent
	 where cod_agente = _cod_agente;

	return _no_tarjeta,
		   _fecha_exp,
		   _nombre,
		   _no_documento,
		   _vigencia_inic,
		   _vigencia_final,
		   _monto,
		   _saldo,
		   _procesar,
		   v_compania_nombre,
		   _nombre_agente,
		   _ult_pago
		   with resume;    
end foreach

commit work;
drop table tmp_tarjeta;
end procedure;
