-- Preliminar de la Generacion de los Lotes de las Tarjetas de Credito

-- Creado    : 23/02/2001 - Autor: Demetrio Hurtado Almanza 
-- Modificado: 26/03/2001 - Autor: Demetrio Hurtado Almanza

-- SIS v.2.0 - DEIVID, S.A.

drop procedure sp_cob47;
create procedure "informix".sp_cob47(
a_compania		char(3),
a_sucursal		char(3),
a_fecha_hasta	date)
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
			char(1),
			char(1),
			char(1),
			dec(16,2);

define _error_desc			char(100);
define _nombre				char(100);
define v_compania_nombre	char(50); 
define _nombre_banco		char(50);
define _nombre_agente		char(50);
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
define _modificado			char(1);
define _periodo2			char(1);
define _periodo				char(1);
define _tiene				char(1);
define _monto_a_cobrar      dec(16,2);
define _cargo_especial      dec(16,2);
define _letra_tcr			dec(16,2);
define _prima_bruta         dec(16,2);
define v_por_vencer			dec(16,2);
define v_corriente			dec(16,2);
define v_exigible			dec(16,2);
define v_monto_30			dec(16,2);
define v_monto_60			dec(16,2);
define v_monto_90			dec(16,2);
define _ult_pago			dec(16,2);
define _saldo				dec(16,2);
define _cargo				dec(16,2);
define _monto				dec(16,2);
define _dif                 dec(16,2);
define _tarjeta_errada		smallint;
define _dia_especial		smallint;
define _cnt_dia_esp			smallint;
define _tipo_forma			smallint;
define _excepcion			smallint;			
define _rechazada			smallint;
define _cantidad			smallint;
define _no_pagos            smallint;
define _ramo_sis			smallint;
define _cnt_dia2			smallint;
define _dia_hoy				smallint;
define _dia_esp				smallint;
define _mes_esp				smallint;
define _mes_hoy				smallint;
define _cnt_dia				smallint;
define _valor				smallint;
define _rech				smallint;
define _dia					smallint;
define _error				integer;
define _saber				integer;
define _vigencia_final		date;
define _vigencia_inic		date;
define _fecha_1_pago		date;
define _fecha_inicio		date;
define _fecha_hasta			date;
define _fecha_hoy			date;
define v_fecha				date;

-- Nombre de la Compania
let v_compania_nombre = sp_sis01(a_compania);
let _fecha_hoy	= today;
let v_fecha		= today;

let _dia_hoy = day(_fecha_hoy);
let _mes_hoy = month(_fecha_hoy);

if month(v_fecha) < 10 then
	let v_periodo = year(v_fecha) || '-0' || month(v_fecha);
else
	let v_periodo = year(v_fecha) || '-' || month(v_fecha);
end if

set isolation to dirty read;

let _dif = 0.00;
let _prima_bruta = 0.00;

--set debug file to "sp_cob47.trc"; 
--trace on;                                                                

--drop table tmp_tarjeta;
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
	modificado		char(1),
	tiene_cargo     char(1),
primary key (no_tarjeta, no_documento)) with no log;

if month(today) < 10 then
	let _periodo_today = year(today) || '-0' || month(today);
else
	let _periodo_today = year(today) || '-' || month(today);
end if

select estatus_visa
  into _estatus_visa
  from parparam
 where cod_compania = a_compania;

--Proceso de Cobros Electrónicos por Día
--let _fecha_hoy = '15/05/2014';
call sp_cob338('TCR',a_fecha_hasta) returning _error,_error_desc;

if _error <> 0 then
	return '','',_error_desc,'','01/01/1900','01/01/1900',_error,0.00,'','','','','','',0.00;
end if

call sp_cob339() returning _error,_error_desc;

if _error <> 0 then
	return '','',_error_desc,'','01/01/1900','01/01/1900',_error,0.00,'','','','','','',0.00;
end if

{
if _estatus_visa = "1" then	--proceso normal

	update cobtacre
	   set rechazada = 0
	 where periodo   = a_periodo;

	-- polizas con forma de pago tarjeta y no tienen tarjetas creadas
	foreach                 
		select p.no_documento    
		  into _no_documento  
		  from emipomae p, cobforpa f       
		 where p.actualizado  = 1
		   and p.cod_formapag = f.cod_formapag
		   and f.tipo_forma   = 2      --tarjeta credito
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
			 where no_documento = _no_documento
			   and actualizado  = 1
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

		if _estatus_poliza = '2' or _estatus_poliza = '4' then
			continue foreach;
		end if

		let _monto = null;

		call sp_cob33(a_compania, a_sucursal, _no_documento, v_periodo, v_fecha)
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
					'',
					'',
					''
					);
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
		 where periodo      = a_periodo
		   and c.no_tarjeta = h.no_tarjeta

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
			call sp_cob33(a_compania, a_sucursal, _no_documento, v_periodo, v_fecha)
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
					_cod_banco,
					'',
					''
					);
			end
		end if
	end foreach
end if}

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
		   modificado,
		   dia,
		   dia_especial,
		   fecha_hasta,
		   fecha_inicio
	  into _no_tarjeta,
		   _letra_tcr,
		   _cargo,
		   _fecha_exp,
		   _no_documento,
		   _nombre,
		   _cod_banco,
		   _excepcion,
		   _tipo_tarjeta,
		   _rechazada,
		   _modificado,
		   _dia,
		   _dia_especial,
		   _fecha_hasta,
		   _fecha_inicio
	  from tmp_procesar

	let _periodo_visa = _fecha_exp[4,7] || '-' || _fecha_exp[1,2];

	let _vigencia_inic  = null;
	let _vigencia_final = null;

	let _no_poliza = sp_sis21(_no_documento);

	if _no_poliza is null then
		continue foreach;
	end if

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

	let _saldo = null;
	let _monto = _letra_tcr;

	call sp_cob33(a_compania, a_sucursal, _no_documento, v_periodo, v_fecha)
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
	
	if _ramo_sis = 5 and _tiene = '' then
		let _cnt_dia2 = 0;
		
		select count(*)
		  into _cnt_dia2
		  from tmp_dias_proceso
		 where dia = _dia;
		
		if _cnt_dia2 is null then
			let _cnt_dia2 = 0;
		end if
		
		if _cnt_dia2 > 0 then
			let _monto = _saldo;
		end if
		
		if _rechazada = 1 then
			select monto_a_cobrar
			  into _monto_a_cobrar
			  from cobtacre
			 where no_tarjeta = _no_tarjeta
			   and no_documento = _no_documento;
			
			if _monto_a_cobrar is null then
				let _monto_a_cobrar = 0.00;
			end if
			
			if _monto_a_cobrar <> 0 then
				let _monto = _monto_a_cobrar;
			end if
		end if
		--let _monto = _saldo;	--15/09/2014 9:20 am
		{if v_exigible <> 0 then
			let _monto = v_exigible;
		end if}-- - v_corriente;
	end if
	
	if _fecha_inicio is null then
		let _fecha_inicio = _fecha_hoy;
	end if

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

	if _cnt_dia = 0 then
		if _dia_especial is null then	--Esto es para el cargo adicional.
			let _dia_especial = 0;
		end if

		let _tiene = "";

		if _fecha_hasta is not null then
			if _fecha_hasta >= _fecha_hoy then  -- tiene cargo adicional
				if _fecha_inicio <= _fecha_hoy then --ok
					let _tiene = "1";

					select count(*)
					  into _cnt_dia_esp
					  from tmp_dias_proceso
					  where dia = _dia_especial;

					if _cnt_dia_esp is null then
						let _cnt_dia_esp = 0;
					end if
					
					if _cnt_dia_esp > 0 then   -- se debe sumar el cargo al monto
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
	else
		--Esto es para el cargo adicional.
		if _dia_especial is null then
			let _dia_especial = 0;
		end if

		let _tiene = "";
		let _monto = _letra_tcr;

		if _fecha_hasta is not null then
			if _fecha_hasta >= _fecha_hoy then  -- tiene cargo adicional
				if _fecha_inicio <= _fecha_hoy then --ok
					let _tiene = "1";

					select count(*)
					  into _cnt_dia_esp
					  from tmp_dias_proceso
					  where dia = _dia_especial;

					if _cnt_dia_esp is null then
						let _cnt_dia_esp = 0;
					end if

					if _cnt_dia_esp <> 0 then    -- se debe sumar el cargo al monto
						let _monto = _letra_tcr + _cargo;
					end if
				end if
			end if
		end if
	end if

	if _modificado is null then
		let _modificado = "";
	end if
	if _tiene is null then
		let _tiene = "";
	end if

	if _tipo_tarjeta = "4" then -- American Express
		let _tarjeta_errada = 0; 
	else
		call sp_sis22(_no_tarjeta) returning _tarjeta_errada;
	end if

	if _monto <= 0 then
		let _excepcion = 1;
	end if

	if _tarjeta_errada = 1 then				-- Tarjeta Errada
		let _procesar = '008';
	elif _excepcion = 1 then
		if _saldo = 0 then
			let _procesar = '050';	--Saldos 0
		else
			let _procesar = '040';	--Excepciones		
		end if
	elif (_fecha_1_pago > today and _nueva_renov = "N") then
		{let _dia_esp = day(_fecha_1_pago);		
		let _mes_esp = month(_fecha_1_pago);
		
		if _mes_esp = _mes_hoy then
			let _cargo_especial = _prima_bruta / _no_pagos;
			
			if _dia_esp <> _dia then 
				update cobtacre
				   set cargo_especial = _cargo_especial,
					   dia_especial = _dia_esp,
					   fecha_inicio = _fecha_1_pago,
					   fecha_hasta  = _fecha_1_pago
				 where no_tarjeta   = _no_tarjeta
				   and no_documento = _no_documento;
			end if
		end if}
		let _procesar = '004';				--fecha no ha llegado aun

	elif _fecha_1_pago > today and _nueva_renov = "R" and v_exigible = 0 then

		{let _dia_esp = day(_fecha_1_pago);		
		let _mes_esp = month(_fecha_1_pago);
		
		if _mes_esp = _mes_hoy then
			let _cargo_especial = _prima_bruta / _no_pagos;
			
			if _dia_esp <> _dia then
				update cobtacre
				   set cargo_especial = _cargo_especial,
					   dia_especial = _dia_esp,
					   fecha_inicio = _fecha_1_pago,
					   fecha_hasta  = _fecha_1_pago
				 where no_tarjeta   = _no_tarjeta
				   and no_documento = _no_documento;
			end if
		end if}

		let _procesar = '004';					--fecha no ha llegado aun

	elif _rechazada = 1 then
		if _estatus_visa = "1" then
			let _procesar = '003';			--Tarjeta Rechazada
			update cobtahab
			   set rechazada  = 0
			 where no_tarjeta = _no_tarjeta;
		else
			if _saldo <= 0 then
				if _estatus_poliza = '2' or _estatus_poliza = '4' then
					let _procesar = '035';	--Pólizas Canceladas
				else
					let _procesar = '020';	--Saldos Negativos
				end if
			else
				let _procesar = '100';		--Tarjeta Normal
			end if

			if _monto > _saldo then
				let _procesar = '030';		-- Cargo Mayor al Saldo
			end if
		end if
	elif _saldo is null then
		let _procesar = '009';		--Pólizas Erradas
	elif _periodo_today > _periodo_visa then
		if _estatus_poliza = '1' And _saldo > 0 then --Esta Vigente y tiene saldo
			let _procesar = '100';	--Tarjeta Normal
		else
			if _saldo = 0 then
				let _procesar = '050';	--Saldos 0
			else
				let _procesar = '010';	--Tarjetas Vencidas
			end if
		end if
	elif _saldo <= 0 then
		if _saldo = 0 then
			let _procesar = '050';	--Saldos 0
		else
			if _estatus_poliza = '2' or _estatus_poliza = '4' then
				let _procesar = '035';	--Polizas Canceladas
			else
				let _procesar = '020';	--Saldos Negativos
			end if
		end if
	elif _monto > _saldo then
		let _procesar = '030';		-- Cargo Mayor al Saldo
	else
		let _procesar = '100';		--Tarjeta Normal
	end if

	if _procesar = '100' then

		{call sp_cob33(a_compania, a_sucursal, _no_documento, v_periodo, v_fecha)
		returning   v_por_vencer,
					v_exigible,
					v_corriente,
					v_monto_30,
					v_monto_60,
					v_monto_90,
					v_saldo;}

		if _monto < v_exigible then

		  	let _dif = 0.00;
			let _dif = v_exigible - _monto;
			if _dif <= 1.00 then
				let _monto = v_exigible;
			end if

			let _procesar = '090';	--Cargo Menor al Exigible
			let _saldo    = v_exigible;
		end if
		
		{if v_exigible <= 0 then
			let _procesar = '020';	--Saldos Negativos
		end if}
	end if

	begin
		on exception in(-239)
	       update tmp_tarjeta
	          set modificado   = _modificado,
			      tiene_cargo  = _tiene
	        where no_tarjeta   = _no_tarjeta
	          and no_documento = _no_documento;
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
		_cod_banco,
		_modificado,
		_tiene
		);
	end   		   	
end foreach

update cobtacre
   set procesar = 0;

select count(c.rechazada)
  into _saber
  from cobtacre c, cobtahab h
 where c.no_tarjeta = h.no_tarjeta
   and h.tipo_tarjeta <> "4"
   --and c.periodo    = a_periodo
   and c.rechazada    = 1;

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
		   cod_banco,
		   modificado,
		   tiene_cargo
	  into _no_tarjeta,
		   _fecha_exp,
		   _nombre,
		   _no_documento,
		   _vigencia_inic,
		   _vigencia_final,
		   _monto,
		   _saldo,
		   _procesar,
		   _cod_banco,
		   _modificado,
		   _tiene
	  from tmp_tarjeta
	 order by procesar, nombre

	select nombre
	  into _nombre_banco
	  from chqbanco
	 where cod_banco = _cod_banco;

	{if _estatus_visa = "2" then	--Modo Rechazadas
		if _saber = 0 then      --No hay poliza rechazada
		else
			select rechazada
			  into _rech
			  from cobtacre
			 where no_tarjeta   = _no_tarjeta
			   and no_documento	= _no_documento;

			if _rech = 1 then
			else
				let _procesar = '040';
			end if
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

	if _procesar = '100' or	-- Tarjetas Normales
	   _procesar = '090' or	-- Cargo Menor al Exigible
	   _procesar = '003' then  -- Tarjetas Rechazadas	

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

	-- Las polizas con saldos 0 no deben aparecer en el reporte
	-- Adecuaciones Proyecto Cobros 2014
	-- Demetrio Hurtado Almanza - Fecha 19/06/2014

	if _procesar = '050' then
		continue foreach;
	end if

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
		   _estatus_visa,
		   _modificado,
		   _tiene,
		   _ult_pago
		   with resume; 
end foreach

commit work;

drop table tmp_dias_proceso;
drop table tmp_procesar;
drop table tmp_tarjeta;

end procedure;