-- Preliminar de la Generacion de los Lotes de las Cuentas para Ach

-- Creado    : 03/09/2001 - Autor: Armando Moreno
-- Modificado: 26/12/2001 - Autor: Armando Moreno

-- SIS v.2.0 - DEIVID, S.A.

drop procedure sp_cob70;

create procedure "informix".sp_cob70(a_compania char(3),a_sucursal char(3),a_fecha_hasta date)
returning	char(17),	--cuenta
			char(100),	--cuentahabiente
			char(20),	--poliza
			date,		--vig ini
			date,		--vig fin
			dec(16,2),	--monto
			dec(16,2),	--saldo
			char(3),	--procesar
			char(50),	--cia
			char(1),	--tipo_cuenta
			char(50),	--corredor
			char(50),	--nombre banco
			char(1),	--modificado
			char(1),    --tiene_cargo
			char(1),    --modo ach 1= normal, 2= rechazos
			decimal(16,2);

define _error_desc			char(100);
define _nombre				char(100);
define v_compania_nombre	char(50); 
define _nombre_agente		char(50);
define _nombre_banco		char(50);
define _mensaje				char(50);
define _no_documento		char(20); 
define _no_cuenta			char(17); 
define _cod_pagador			char(10);
define _no_poliza			char(10);
define _cod_agente			char(10);
define _periodo_today		char(7);  
define _periodo_cta			char(7);  
define v_periodo			char(7);
define _cod_formapag		char(3);
define _cod_banco			char(3);
define _procesar			char(3);
define _cod_ramo			char(3);
define _estatus_poliza		char(1);
define _tipo_cuenta			char(1);
define _estatus_ach			char(1);
define _nueva_renov			char(1);
define _modificado			char(1);
define _periodo2			char(1);
define _periodo				char(1);
define _tiene				char(1);
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
define _tarjeta_errada		smallint;
define _dia_especial		smallint;
define _ruta_numero			smallint;			
define _cnt_dia_esp			smallint;
define _tipo_forma			smallint;
define _rechazada			smallint;
define _excepcion			smallint;
define _colectivo			smallint;
define _cantidad			smallint;
define _ramo_sis			smallint;
define _cnt_dia				smallint;
define _valor				smallint;
define _rech				smallint;
define _dia					smallint;
define _error				integer;
define _saber				integer;
define _cnt					integer;
define _vigencia_final		date;
define _vigencia_inic		date;
define _fecha_inicio		date;
define _fecha_1_pago		date;
define _fecha_hasta			date;
define _fecha_hoy			date;
define v_fecha				date;
define _dif                 decimal(16,2);				

-- Nombre de la Compania
set isolation to dirty read;

let  v_compania_nombre = sp_sis01(a_compania); 

let v_fecha = today;
let _rechazada = 0;

if month(v_fecha) < 10 then
	let v_periodo = year(v_fecha) || '-0' || month(v_fecha);
else
	let v_periodo = year(v_fecha) || '-' || month(v_fecha);
end if 
let _fecha_hoy    = today;

--set debug file to "sp_cob70.trc"; 
--trace on;                                                                

--drop table tmp_cuenta;

create temp table tmp_cuenta(
no_cuenta		char(17),
nombre			char(100),
no_documento	char(20),
vigencia_inic	date,
vigencia_final	date,
monto			dec(16,2),
saldo			dec(16,2),
procesar		char(3),
cod_banco		char(3),
tipo_cuenta		char(1),
modificado      char(1),
tiene_cargo     char(1),
primary key (no_cuenta, no_documento)) with no log;

if month(today) < 10 then
	let _periodo_today = year(today) || '-0' || month(today);
else
	let _periodo_today = year(today) || '-' || month(today);
end if

select estatus_ach
  into _estatus_ach
  from parparam
 where cod_compania = a_compania;
{
if _estatus_ach = "1" then
	let _rechazada_si = 1;
	let _rechazada_no = 0;
else
	let _rechazada_si = 1;
	let _rechazada_no = 1;
end if

--if _estatus_ach = "1" then	--proceso normal
}
{update cobcutas
   set rechazada = 0
 where periodo   = a_periodo;}

 
 
--**********************************************************
--polizas con forma de pago ach y no tienen cuentas creadas
call sp_cob338('ACH',a_fecha_hasta) returning _error,_error_desc;

if _error <> 0 then
	return '','',_error_desc,'01/01/1900','01/01/1900',_error,0.00,'','','','','','','','',0.00;
end if

call sp_cob339b() returning _error,_error_desc;

if _error <> 0 then
	return '','',_error_desc,'01/01/1900','01/01/1900',_error,0.00,'','','','','','','','',0.00;
end if

foreach
	select p.no_documento    
	  into _no_documento  
	  from emipomae p, cobforpa f       
	 where p.actualizado  = 1
	   and p.cod_formapag = f.cod_formapag
	   and f.tipo_forma   = 4      --ach
	 group by p.no_documento 

	foreach
		select cod_formapag,
			   vigencia_inic,
			   vigencia_final,
			   cod_pagador,
			   estatus_poliza
		  into _cod_formapag,
			   _vigencia_inic,
			   _vigencia_final,
			   _cod_pagador,
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

	if _tipo_forma <> 4 then  --4 es db-ach del 15 y del 30
		continue foreach;
	end if

	if _estatus_poliza = '2' or	   --cancelada
	   _estatus_poliza = '4' then  --anulada
		continue foreach;
	end if

	let _monto = null;

	foreach	
		select monto
		  into _monto
		  from cobcutas
		 where no_documento = _no_documento
		exit foreach;
	end foreach

	if _monto is null then
		call sp_cob33(a_compania, a_sucursal, _no_documento, v_periodo, v_fecha)
		returning	v_por_vencer,
					v_exigible,
					v_corriente,
					v_monto_30,
					v_monto_60,
					v_monto_90,
					_saldo;
					
		select nombre                      
		  into _nombre                     
		  from cliclien                    
		 where cod_cliente = _cod_pagador;

		insert into tmp_cuenta
		values(
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
		'',
		'');
	end if
end foreach

--polizas que tienen cuenta y su forma de pago no es con ach
let _colectivo = 0;

foreach
	select c.no_documento,
		   h.no_cuenta,
		   h.tipo_cuenta,
		   h.cod_pagador,
		   c.monto,
		   h.cod_banco,
		   c.colectivo
	  into _no_documento,
		   _no_cuenta,
		   _tipo_cuenta,
		   _cod_pagador,
		   _monto,
		   _cod_banco,
		   _colectivo
	  from cobcutas c, cobcuhab h
	 where trim(c.no_cuenta) = trim(h.no_cuenta)
	   and dia in (select dia from tmp_dias_proceso) or dia_especial in (select dia from tmp_dias_proceso)

	let _cod_formapag = null;

	if _colectivo is null then
		let _colectivo = 0;
	end if

	let _no_cuenta = trim(_no_cuenta);

	foreach
		select cod_formapag,
			   vigencia_inic,
			   vigencia_final
		  into _cod_formapag,
			   _vigencia_inic,
			   _vigencia_final
		  from emipomae
		 where no_documento = _no_documento
		   and actualizado  = 1
		 order by vigencia_final desc
		exit foreach;
	end foreach

	if _cod_formapag is null then
		continue foreach;
	end if

	select tipo_forma                
	  into _tipo_forma
	  from cobforpa                       
	 where cod_formapag = _cod_formapag;  

	select nombre                      
	  into _nombre                     
	  from cliclien
	 where cod_cliente = _cod_pagador;

	if _tipo_forma <> 4 then
		call sp_cob33(a_compania, a_sucursal, _no_documento, v_periodo, v_fecha)
		returning   v_por_vencer,
					v_exigible,
					v_corriente,
					v_monto_30,
					v_monto_60,
					v_monto_90,
					_saldo;

		if _colectivo = 0 then 
			begin
				on exception in(-239)
				end exception
				insert into tmp_cuenta
				values(
				_no_cuenta,
				_nombre,
				_no_documento,
				_vigencia_inic,
				_vigencia_final,
				_monto,
				_saldo,
				'007',
				_cod_banco,
				_tipo_cuenta,
				'',
				''
				);
			end
		else
			begin
				on exception in(-239)
				end exception
				insert into tmp_cuenta
				values(
				_no_cuenta,
				_nombre,
				_no_documento,
				_vigencia_inic,
				_vigencia_final,
				_monto,
				_saldo,
				'000',
				_cod_banco,
				_tipo_cuenta,
				'',
				''
				);
			end
		end if
	end if
end foreach 

-- Polizas que tienen banco y no tienen No. de ruta.

foreach
	select c.no_documento,
		   h.no_cuenta,
		   h.tipo_cuenta,
		   h.cod_pagador,
		   c.monto,
		   h.cod_banco
	  into _no_documento,
		   _no_cuenta,
		   _tipo_cuenta,
		   _cod_pagador,
		   _monto,
		   _cod_banco
	  from cobcutas c, cobcuhab h
	 where dia in (select dia from tmp_dias_proceso) or dia_especial in (select dia from tmp_dias_proceso)
	   and trim(c.no_cuenta) = trim(h.no_cuenta)

	let _no_cuenta = trim(_no_cuenta);

	foreach
		select vigencia_inic,
			   vigencia_final
		  into _vigencia_inic,
			   _vigencia_final
		  from emipomae
		 where no_documento = _no_documento
		   and actualizado  = 1
		 order by vigencia_final desc
		exit foreach;
	end foreach

	if _cod_banco is null then
		continue foreach;
	end if

	let _ruta_numero = null;

	select ruta_numero
	  into _ruta_numero
	  from chqbanco
	 where cod_banco = _cod_banco;

	select nombre                      
	  into _nombre                     
	  from cliclien                    
	 where cod_cliente = _cod_pagador;

	if _ruta_numero is null or _ruta_numero = 0 then
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
			insert into tmp_cuenta
			values(
			_no_cuenta,
			_nombre,
			_no_documento,
			_vigencia_inic,
			_vigencia_final,
			_monto,
			_saldo,
			'010',
			_cod_banco,
			_tipo_cuenta,
			'',
			''
			);
		end
	end if
end foreach 
--end if

--***********************************
-- Procesa Todas las Cuentas para ACH
let _cargo = 0;

foreach
	select no_cuenta,
		   monto,
		   cargo_especial,
		   no_documento,
		   cod_pagador,
		   cod_banco,
		   tipo_cuenta,
		   rechazada,
		   excepcion,
		   modificado,
		   dia,
		   dia_especial,
		   fecha_hasta,
		   fecha_inicio
	  into _no_cuenta,
		   _monto,
		   _cargo,
		   _no_documento,
		   _cod_pagador,
		   _cod_banco,
		   _tipo_cuenta,
		   _rechazada,
		   _excepcion,
		   _modificado,
		   _dia,
		   _dia_especial,
		   _fecha_hasta,
		   _fecha_inicio
	  from tmp_procesar

	let _no_cuenta = trim(_no_cuenta);

	if _fecha_inicio is null then
		let _fecha_inicio = v_fecha;
	end if
	
	select count(*)
	  into _cnt_dia
	  from tmp_dias_proceso
	  where dia = _dia;
	
	if _cnt_dia is null then
		let _cnt_dia = 0;
	end if
	
	if _cnt_dia > 0 then
		if _dia_especial is null then 		--Esto es para el cargo adicional.
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
						let _monto = _monto + _cargo;
					end if
				end if
			end if
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
		end if
	end if

	if _modificado is null then
		let _modificado = "";
	end if
	
	if _tiene is null then
		let _tiene = "";
	end if
	
	let _vigencia_inic  = null;
	let _vigencia_final = null;

	let _no_poliza = sp_sis21(_no_documento);
	
	if _no_poliza is null then
		continue foreach;
	end if

	foreach
		select vigencia_inic,
			   vigencia_final,
			   cod_ramo,
			   estatus_poliza,
			   fecha_primer_pago,
			   nueva_renov
		  into _vigencia_inic,
			   _vigencia_final,
			   _cod_ramo,
			   _estatus_poliza,
			   _fecha_1_pago,
			   _nueva_renov
		  from emipomae
		 where no_documento = _no_documento
		   and actualizado  = 1
		 order by vigencia_final desc
		exit foreach;
	end foreach

	let _saldo = null;

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

	if _monto <= 0 then
		let _excepcion = 1;
	end if

	if _saldo is null then
		let _procesar = '009'; 	--polizas erradas
	elif _fecha_1_pago > today and _nueva_renov = "N" then
		let _procesar = '004';
	elif _fecha_1_pago > today and _nueva_renov = "R" and v_exigible = 0 then
		let _procesar = '004';
	elif _excepcion = 1 then
		if _saldo = 0 then
			let _procesar = '050';	--Saldos 0
		else

			select count(*)
			  into _cnt
			  from cobcutmp
			 where no_documento	= _no_documento
			   and motivo[1,3]  in('R04','R16','R02');

			if _cnt > 0 then
				let _procesar = '051';	--CUENTA BLOQUEADA
			else
				let _procesar = '040';	--excepciones
			end if

		end if
	elif _saldo <= 0 then
	    if _saldo = 0 then
			let _procesar = '050';	--Saldos 0
		else
			if _estatus_poliza = '2' or _estatus_poliza = '4' then
				let _procesar = '035';	  --polizas canceladas
			else
				let _procesar = '020';    --saldos negativos
			end if
		end if
    elif _monto > _saldo then	      --cargo mayor al saldo
		   let _procesar = '100';
		   let _monto = _saldo;
	elif _rechazada = 1 then
		if _estatus_ach = "1" then	--proceso normal
			let _procesar = '003';	--cuenta rechazada
			{update cobcuhab
			   set rechazada  = 0
			 where trim(no_cuenta) = _no_cuenta;}
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
			if _monto > _saldo then
				let _procesar = '100';
			    let _monto = _saldo;
			end if
		end if
	else
		let _procesar = '100';
	end if

	if _procesar = '100' then
		call sp_cob33(a_compania, a_sucursal, _no_documento, v_periodo, v_fecha)
		returning   v_por_vencer,
					v_exigible,
					v_corriente,
					v_monto_30,
					v_monto_60,
					v_monto_90,
					_saldo;

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

 	select nombre                      
	  into _nombre                     
 	  from cliclien                    
 	 where cod_cliente = _cod_pagador;

	 select count(*)
	   into	_cnt
	   from	cobcutas
	  where	no_documento = _no_documento;

	if _cnt > 1 then
		let _procesar = '001';
        update tmp_cuenta
	       set procesar        = _procesar
    	 where trim(no_cuenta) = _no_cuenta
           and no_documento    = _no_documento;
	end if

	begin
		on exception in(-239)
			update tmp_cuenta
			   set modificado      = _modificado,
				   tiene_cargo     = _tiene
			 where trim(no_cuenta) = _no_cuenta
			   and no_documento    = _no_documento;

		end exception
		insert into tmp_cuenta
		values(
		_no_cuenta,
		_nombre,
		_no_documento,
		_vigencia_inic,
		_vigencia_final,
		_monto,
		_saldo,
		_procesar,
		_cod_banco,
		_tipo_cuenta,
		_modificado,
		_tiene
		);
	end   		   	
end foreach

--RECHAZADAS DE QUINCENA ANTERIOR, COLOCARLAS DENTRO DEL PROCESO NORMAL
{
if _estatus_ach = "1" then --proceso normal
	foreach
		select no_cuenta,
			   cod_pagador,
			   monto,
			   no_documento
		  into _no_cuenta,
			   _cod_pagador,
			   _monto,
			   _no_documento
		  from cobcutmp
		 where rechazado = 1

		let _no_cuenta = trim(_no_cuenta);
		let _procesar = '003';
		
		call sp_cob33(a_compania, a_sucursal, _no_documento, v_periodo, v_fecha)
		returning   v_por_vencer,
					v_exigible,
					v_corriente,
					v_monto_30,
					v_monto_60,
					v_monto_90,
					_saldo;

		select count(*)
		  into _cnt
		  from cobcutas
		 where trim(no_cuenta) = _no_cuenta
		   and no_documento = _no_documento;

		if _cnt = 0 then
			delete from cobcutmp
			 where trim(no_cuenta) = _no_cuenta
			   and no_documento    = _no_documento;
		end if

		let _no_cuenta = trim(_no_cuenta);

		select tipo_cuenta,
			   cod_banco
		  into _tipo_cuenta,
			   _cod_banco
		  from cobcuhab
		 where trim(no_cuenta) = _no_cuenta;

		foreach
			select vigencia_inic,
				   vigencia_final,
				   estatus_poliza
			  into _vigencia_inic,
				   _vigencia_final,
				   _estatus_poliza
			  from emipomae
			 where no_documento = _no_documento
			   and actualizado  = 1			   
			 order by vigencia_final desc
			exit foreach;
		end foreach

		if _saldo <= 0 then
			if _estatus_poliza = '2' or
			   _estatus_poliza = '4' then
				let _procesar = '035';
			else
				let _procesar = '020';
			end if
		end if

	   	select nombre                      
		  into _nombre                     
	 	  from cliclien                    
	 	 where cod_cliente = _cod_pagador;

		begin
			on exception in(-239)
			end exception
			insert into tmp_cuenta
			values(
			_no_cuenta,				 
			_nombre,				 
			_no_documento,			 
			_vigencia_inic,			 
			_vigencia_final,		 
			_monto,					 
			0,						 
			_procesar,					 
			_cod_banco,				 
			_tipo_cuenta,			 	
			'',
			''					 
			);						 
		end
		
		{update cobcutas
		   set rechazada       = 0
		 where trim(no_cuenta) = _no_cuenta
		   and no_documento    = _no_documento; 
	end foreach
end if}

update cobcutas
   set procesar = 0;

select count(*)
  into _saber
  from cobcutas
 where rechazada = 1;

foreach
	select no_cuenta,
		   nombre,
		   no_documento,
		   vigencia_inic,
		   vigencia_final,
		   monto,
		   saldo,
		   procesar,
		   cod_banco,
		   tipo_cuenta,
		   modificado,
		   tiene_cargo
	  into _no_cuenta,
		   _nombre,
		   _no_documento,
		   _vigencia_inic,
		   _vigencia_final,
		   _monto,
		   _saldo,
		   _procesar,
		   _cod_banco,
		   _tipo_cuenta,
		   _modificado,
		   _tiene
	  from tmp_cuenta
	 order by procesar, nombre

	let _no_cuenta = trim(_no_cuenta);

	select nombre
	  into _nombre_banco
	  from chqbanco
	 where cod_banco = _cod_banco;

	if _estatus_ach = "2" then	--Modo Rechazadas
		if _saber = 0 then      --No hay poliza rechazada
		else
			select rechazada
			  into _rech
			  from cobcutas
			 where trim(no_cuenta) = _no_cuenta
			   and no_documento	   = _no_documento;

			if _rech = 1 then
				call sp_cob33(a_compania, a_sucursal, _no_documento, v_periodo, v_fecha)
				returning   v_por_vencer,
							v_exigible,
							v_corriente,
							v_monto_30,
							v_monto_60,
							v_monto_90,
							_saldo;

				foreach
					select estatus_poliza
					  into _estatus_poliza
					  from emipomae
					 where no_documento = _no_documento
					   and actualizado  = 1
					 order by vigencia_final desc
					exit foreach;
				end foreach

				if _saldo <= 0 then
					if _estatus_poliza = '2' or
					   _estatus_poliza = '4' then
						let _procesar = '035';
					else
						let _procesar = '020';
					end if
				end if
			else
				select count(*)
				  into _cnt
				  from cobcutmp
				 where no_documento	 = _no_documento
				   and motivo[1,3] in('R04','R16','R02');

				if _cnt > 0 then
					let _procesar = '051';	--CUENTA BLOQUEADA
				else
					let _procesar = '040';	--excepciones
				end if
			end if
		end if
	end if

	if _procesar = '100' or	--cuentas normales
	   _procesar = '090' or	--cargo menor exigible
	   _procesar = '002' or	--rechazos quincena anterior y pasan a proceso normal
	   _procesar = '003' or	--rechazos 
	   _procesar = '000' then	--colectivos
		update cobcutas
		   set procesar     = 1
		 where trim(no_cuenta) = _no_cuenta
		   and no_documento    = _no_documento; 
	else
		update cobcutas
		   set procesar        = 0
		 where trim(no_cuenta) = _no_cuenta
		   and no_documento    = _no_documento; 
	end if

	let _no_poliza = sp_sis21(_no_documento);

	let _ult_pago = 0;
	call sp_sis395(_no_documento) returning _valor, _mensaje,_ult_pago;

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
	-- Demetrio Hurtado Almanza - Fecha 25/06/2014

	if _procesar = '050' then
		continue foreach;
	end if

	return _no_cuenta,
		   _nombre,
		   _no_documento,
		   _vigencia_inic,
		   _vigencia_final,
		   _monto,
		   _saldo,
		   _procesar,
		   v_compania_nombre,
		   _tipo_cuenta,
		   _nombre_agente,
		   _nombre_banco,
		   _modificado,
		   _tiene,
		   _estatus_ach,
		   _ult_pago
		   with resume;
end foreach

commit work;
drop table tmp_cuenta;
end procedure;
