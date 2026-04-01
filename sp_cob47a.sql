-- Preliminar de la Generacion de los Lotes de las Tarjetas de Crédito (SOLO REPORTE, NO ACTUALIZA LA INFORMACIÓN EN LA ESTRUCTURA TCR)
-- Creado    : 15/05/2015 - Autor: Román Gordón
-- SIS v.2.0 - DEIVID, S.A.

drop procedure sp_cob47a;
create procedure "informix".sp_cob47a(
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

set isolation to dirty read;

--set debug file to "sp_cob47.trc"; 
--trace on;

let _dif = 0.00;
let _prima_bruta = 0.00;

-- Determina el nombre de la compañia
let v_compania_nombre = sp_sis01(a_compania);
let _fecha_hoy	= today;
let v_fecha		= today;

--Se extrae el día y el mes del día de hoy.
let _dia_hoy = day(_fecha_hoy);
let _mes_hoy = month(_fecha_hoy);

--Inicializa el estatus visa en "Proceso Normal"
let _estatus_visa = '1' ;

--Determina el Periodo de la fecha de hoy
let _periodo_today = sp_sis39(v_fecha);

--Elimina las Temporales del proceso
drop table if exists tmp_cobtahab;
drop table if exists tmp_cobtacre;
drop table if exists tmp_tarjeta;

--Crea la tabla temporal que contendrá la información que retornará el reporte.
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

--Se crea una tabla temporal a partir de la tabla maestra de Tarjeta de Crédito
select *
  from cobtahab
   into temp tmp_cobtahab;

alter table tmp_cobtahab add constraint ( primary key ( no_tarjeta ) constraint pk_cobtahab ) ;
alter table tmp_cobtahab add constraint ( foreign key ( cod_banco ) references informix.chqbanco constraint fk_ref_37870_37870 ) ;

--Se crea una tabla temporal a partir de la tabla de detalle de póliza pagadas con Tarjeta de Crédito
select *
  from cobtacre
   into temp tmp_cobtacre;

alter table tmp_cobtacre add constraint ( primary key ( no_tarjeta, no_documento ) constraint pk_cobtacre ) ;
alter table tmp_cobtacre add constraint ( foreign key ( no_tarjeta ) references tmp_cobtahab constraint fk_ref_37871_37871 ) ;
create index idx_cobtacre_1 on tmp_cobtacre (no_documento ) ;

let _fecha_hasta = null;

--Se determinan los días que seran procesados por el reporte
call sp_cob338a('TCR',a_fecha_hasta) returning _error,_error_desc;

if _error <> 0 then
	return '','',_error_desc,'','01/01/1900','01/01/1900',_error,0.00,'','','','','','',0.00;
end if

--Se insertan los registros que seran procesados en una tabla temporal
call sp_cob339() returning _error,_error_desc;

if _error <> 0 then
	return '','',_error_desc,'','01/01/1900','01/01/1900',_error,0.00,'','','','','','',0.00;
end if


if _estatus_visa = "1" then	--proceso normal

	-- Pólizas con forma de pago tarjeta y no tienen tarjetas creadas
	foreach                 
		select p.no_documento    
		  into _no_documento  
		  from emipomae p, cobforpa f       
		 where p.cod_formapag = f.cod_formapag
		   and f.tipo_forma   = 2
		   and p.actualizado  = 1
		 group by p.no_documento 

		--Determina la información de la última vigencia actualizada de la póliza
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

		--Determina la forma de pago de la última vigencia actualizada de la póliza
		select tipo_forma
		  into _tipo_forma
		  from cobforpa
		 where cod_formapag = _cod_formapag;

		if _tipo_forma <> 2 then
			continue foreach;
		end if

		--No se deben  procesar pólizas canceladas (2) o anuladas (4)
		if _estatus_poliza = '2' or _estatus_poliza = '4' then
			continue foreach;
		end if

		let _monto = null;

		--Se determina la morosidad de la póliza
		call sp_cob33d(a_compania, a_sucursal, _no_documento, _periodo_today, v_fecha)
		returning   v_por_vencer,
					v_exigible,
					v_corriente,
					v_monto_30,
					v_monto_60,
					v_monto_90,
					_saldo;

		--En Caso de que haya más de un registro en la estructura de TCR se clasifica como Tarjeta Duplicada (005)
		begin
			on exception in(-284)
				select nombre
				  into _nombre
				  from cliclien
				 where cod_cliente = _cod_cliente;

				--Si el registro ya existe en la tabla temporal se continua con el proceso
				begin
					on exception in(-239)
					end exception
					insert into tmp_tarjeta
					values(	'',
							'',
							_nombre,
							_no_documento,
							_vigencia_inic,
							_vigencia_final,
							0.00,
							_saldo,
							'005 ',
							'',
							'',
							'');
				end

				continue foreach;
			end exception

			select monto
			  into _monto
			  from tmp_cobtacre
			 where no_documento = _no_documento;
		end

		if _monto is null then
		 	select nombre                      
			  into _nombre                     
		 	  from cliclien                    
		 	 where cod_cliente = _cod_cliente;

			begin
				on exception in(-239)
				end exception

				insert into tmp_tarjeta
				values(	'',
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
						'');
			end
		end if
	end foreach             

	-- Polizas que tienen Tarjetas de Credito y su Forma de Pago no es Tarjeta de Crédito
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
		  from tmp_cobtacre c, tmp_cobtahab h
		 where c.no_tarjeta = h.no_tarjeta

		let _cod_formapag = null;

		--Se busca la última vigencia emitida
		let _no_poliza = sp_sis21(_no_documento);

		--Si la vigencia no existe se marca el registro en la categoría Póliza Errada (008)
		if _no_poliza is null or _no_poliza = '' then

			--Si el registro ya existe en la tabla temporal se continua con el proceso
			begin
				on exception in(-239)
				end exception
				insert into tmp_tarjeta
				values(	_no_tarjeta,
						_fecha_exp,
						_nombre,
						_no_documento,
						'01/01/1900',
						'01/01/1900',
						_monto,
						0.00,
						'008',
						_cod_banco,
						'',
						'');
			end

			--Se busca el siguiente registro
			continue foreach;
		end if

		--Selecciona la información de la última vigencia
		select cod_formapag,
			   vigencia_inic,
			   vigencia_final
		  into _cod_formapag,
			   _vigencia_inic,
			   _vigencia_final
		  from emipomae
		 where no_poliza = _no_poliza;

		--Se determina la forma de pago de la póliza.
	  	select tipo_forma                
	  	  into _tipo_forma
	  	  from cobforpa                       
	  	 where cod_formapag = _cod_formapag;  

		--Si la póliza no es TCR entonces se coloca en la categoría 007 - NO SON TARJETAS
		if _tipo_forma <> 2 then

			--Se determina la morosidad de la póliza
			call sp_cob33d(a_compania, a_sucursal, _no_documento, _periodo_today, v_fecha)
			returning   v_por_vencer,
						v_exigible,
						v_corriente,
						v_monto_30,
						v_monto_60,
						v_monto_90,
						_saldo;
			begin
				--Si el registro ya existe en la tabla temporal se continua con el proceso
				on exception in(-239)
				end exception
					insert into tmp_tarjeta
					values(	_no_tarjeta,
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
							'');
			end
		end if
	end foreach
end if

-- Procesa Todas las Tarjetas de Credito de los días que se van a procesar
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
		   _monto,
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

	--Si no hay fecha de inicio para el cobro Adicional se le asigna el día de hoy
	if _fecha_inicio is null then
		let _fecha_inicio = _fecha_hoy;
	end if

	--Se verifica si el día de proceso de la póliza se encuentra dentro de los días a procesar
	--La póliza puede no tener el día que se va a procesar si la póliza esta marcada como rechazada y se le va a hacer un reintento
	select count(*)
	  into _cnt_dia
	  from tmp_dias_proceso
	  where dia = _dia;

	if _cnt_dia is null then
		let _cnt_dia = 0;
	end if

	--Si la póliza esta rechaza se debe procesar como si fuera su día de cobros
	if _rechazada = 1 then
		let _cnt_dia = 1;
	end if

	--Se inicializa la variable que determina si la póliza tiene un cargo adicional o no.
	let _tiene = "";

	--Si el día de proceso de la póliza no está dentro de los días a procesar y no está rechazada se determina si tiene cargo adicional.
	if _cnt_dia = 0 then
		if _dia_especial is null then	--Esto es para el cargo adicional.
			let _dia_especial = 0;
		end if
		
		--Se verifica si la póliza tiene una fecha  limite para el cargo adicional
		if _fecha_hasta is not null then
			--Si la fecha limite para hacer el cargo es mayor al día de hoy se le debe hacer el cargo adicional
			if _fecha_hasta >= _fecha_hoy then  -- tiene cargo adicional
				--Si la fecha minima para hacer el cargo es mayor al día de hoy se le debe hacer el cargo adicional
				if _fecha_inicio <= _fecha_hoy then
					--Se marca la póliza como que tiene un cargo adicional
					let _tiene = "1";

					--Se verifica si el día del cargo adicional pactado está dentro de los días que serán procesados
					select count(*)
					  into _cnt_dia_esp
					  from tmp_dias_proceso
					  where dia = _dia_especial;

					if _cnt_dia_esp is null then
						let _cnt_dia_esp = 0;
					end if
					
					--Si el día del cargo adicional pactado está dentro de los días que serán procesados se le asigna el cargo adicional al monto a cobrar.
					if _cnt_dia_esp > 0 then   -- se debe sumar el cargo al monto
						if _cargo > 0 then
							let _monto = _cargo;
						else
							continue foreach;--No cumplio la condición del monto del cargo adicional (Debe ser mayor a 0;
						end if
					else
						continue foreach; --No cumplio la condición del día de cargo adicional.
					end if
				else
					continue foreach; -- El cargo adicional no ha comenzado a regir.
				end if
			else
				continue foreach;	--El cargo adicional no esta en vigencia.
			end if
		else
			continue foreach; --El cargo adicional no tiene fecha limite.
		end if

	--el día a procesar de la póliza esta dentro de los días a procesar o esta rechazada
	else
		if _dia_especial is null then
			let _dia_especial = 0;
		end if

		--Se verifica si la póliza tiene una fecha  limite para el cargo adicional
		if _fecha_hasta is not null then
			--Si la fecha limite para hacer el cargo es mayor al día de hoy se le debe hacer el cargo adicional
			if _fecha_hasta >= _fecha_hoy then  -- tiene cargo adicional
				--Si la fecha minima para hacer el cargo es mayor al día de hoy se le debe hacer el cargo adicional
				if _fecha_inicio <= _fecha_hoy then

					--Se marca la póliza como que tiene un cargo adicional
					let _tiene = "1";

					--Se verifica si el día del cargo adicional pactado está dentro de los días que serán procesados
					select count(*)
					  into _cnt_dia_esp
					  from tmp_dias_proceso
					  where dia = _dia_especial;

					if _cnt_dia_esp is null then
						let _cnt_dia_esp = 0;
					end if

					--Si el día del cargo adicional pactado está dentro de los días que serán procesados se le suma el cargo adicional al monto a cobrar.
					if _cnt_dia_esp <> 0 then    -- se debe sumar el cargo al monto
						let _monto = _monto + _cargo;
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

	--Se determina el periodo de la Fecha de Expiración
	let _periodo_visa = _fecha_exp[4,7] || '-' || _fecha_exp[1,2];

	let _no_poliza = sp_sis21(_no_documento);

	--Si la vigencia no existe se marca el registro en la categoría Póliza Errada (008)
	if _no_poliza is null then
		--Si el registro ya existe en la tabla temporal se continua con el proceso
		begin
			on exception in(-239)
			end exception
			insert into tmp_tarjeta
			values(	_no_tarjeta,
					_fecha_exp,
					'',
					_no_documento,
					'01/01/1900',
					'01/01/1900',
					_monto,
					0.00,
					'008',
					_cod_banco,
					'',
					'');
		end

		--Se busca el siguiente registro
		continue foreach;
	end if

	--Se busca la información de la última vigencia de la póliza
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

	--Se determina la morosidad de la póliza.
	call sp_cob33d(a_compania, a_sucursal, _no_documento, _periodo_today, v_fecha)
	returning   v_por_vencer,
				v_exigible,
				v_corriente,
				v_monto_30,
				v_monto_60,
				v_monto_90,
				_saldo;

	--Si la póliza es American Express (4) se coloca en la categoría de Tarjeta Errada (008)
	if _tipo_tarjeta = "4" then -- American Express
		let _tarjeta_errada = 0; 
	else
		--Procesdimiento que termina el formato de la tarjeta de crédito
		call sp_sis22(_no_tarjeta) returning _tarjeta_errada;
	end if

	--Si el monto a cobrar el menor a 0 se coloca en la categoría de excepciónes
	if _monto <= 0 then
		let _excepcion = 1;
	end if
	
	if _fecha_exp is null then
		let _fecha_exp = '';
	end if

	--Si la polizas esta cancelada (2) o anulada (4) se coloca en la categoría de Polizas Canceladas (035)
	if _estatus_poliza in ('2','4') then
		let _procesar = '035';

	--Si la tarjeta esta errada se coloca en la categoría de Tarjetas Erradas (008)
	elif _tarjeta_errada = 1 then				-- Tarjeta Errada
		let _procesar = '008';

	--Si la fecha de expiración está en blanco se coloca en la categoría de Fecha Exp. Incorrecta (011)
	elif _fecha_exp = '' then
		let _procesar = '011';

	elif _excepcion = 1 then
		--Si la póliza está marcada como excepción y no tiene saldo se coloca en la categoría de Saldo 0 (050)
		if _saldo = 0 then
			let _procesar = '050';
		else
			--Si la póliza está marcada como excepción y no tiene saldo se coloca en la categoría de Excepciones(040)
			let _procesar = '040';
		end if

	--Si la póliza es nueva y la fecha del primer pago es mayor a hoy se coloca en la categoría de Fecha no ha Llegado(004)
	elif _fecha_1_pago > today and _nueva_renov = "N" then
		{let _dia_esp = day(_fecha_1_pago);		
		let _mes_esp = month(_fecha_1_pago);
		
		if _mes_esp = _mes_hoy then
			let _cargo_especial = _prima_bruta / _no_pagos;
			
			if _dia_esp <> _dia then 
				update tmp_cobtacre
				   set cargo_especial = _cargo_especial,
					   dia_especial = _dia_esp,
					   fecha_inicio = _fecha_1_pago,
					   fecha_hasta  = _fecha_1_pago
				 where no_tarjeta   = _no_tarjeta
				   and no_documento = _no_documento;
			end if
		end if}
		let _procesar = '004';

	--Si la póliza es renovada, la fecha del primer pago es mayor a hoy y no tiene exigible se coloca en la categoría de Fecha no ha Llegado (004)
	elif _fecha_1_pago > today and _nueva_renov = "R" and v_exigible = 0 then

		{let _dia_esp = day(_fecha_1_pago);		
		let _mes_esp = month(_fecha_1_pago);
		
		if _mes_esp = _mes_hoy then
			let _cargo_especial = _prima_bruta / _no_pagos;
			
			if _dia_esp <> _dia then
				update tmp_cobtacre
				   set cargo_especial = _cargo_especial,
					   dia_especial = _dia_esp,
					   fecha_inicio = _fecha_1_pago,
					   fecha_hasta  = _fecha_1_pago
				 where no_tarjeta   = _no_tarjeta
				   and no_documento = _no_documento;
			end if
		end if}

		let _procesar = '004';

	elif _rechazada = 1 then
		--Si la póliza está marcada como rechazada y el proceso a realizar es el normal se coloca en la categoría de Tarjeta Rechazada (003)
		if _estatus_visa = "1" then
			let _procesar = '003';
		else
			if _saldo <= 0 then
				--Si la póliza está marcada como rechazada y la polizas esta cancelada (2) o anulada (4) se coloca en la categoría de Polizas Canceladas (035)
				if _estatus_poliza = '2' or _estatus_poliza = '4' then
					let _procesar = '035';	--PÃ³lizas Canceladas
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
		let _procesar = '009';		--PÃ³lizas Erradas
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

		{call sp_cob33(a_compania, a_sucursal, _no_documento, _periodo_today, v_fecha)
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

{
update tmp_cobtacre
   set procesar = 0;}

select count(c.rechazada)
  into _saber
  from tmp_cobtacre c, tmp_cobtahab h
 where c.no_tarjeta = h.no_tarjeta
   and h.tipo_tarjeta <> "4"
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
			  from tmp_cobtacre
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

	if _procesar in ('100','090','003') 	-- Tarjetas Normales,Cargo Menor al Exigible -- Tarjetas Rechazadas	

		{update tmp_cobtacre
		   set procesar     = 1
		 where no_tarjeta   = _no_tarjeta
		   and no_documento = _no_documento;}
	else
		{update tmp_cobtacre
		   set procesar     = 0
		 where no_tarjeta   = _no_tarjeta
		   and no_documento = _no_documento;}
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

--commit work;

drop table tmp_dias_proceso;
drop table tmp_procesar;
drop table tmp_tarjeta;

end procedure;