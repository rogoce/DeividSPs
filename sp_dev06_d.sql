-- Procedimiento que actualiza los número de pagos de endosos de pólizas que no han tenido plan pago.
-- Creado: 30/05/2017 - Autor: Román Gordón

drop procedure sp_dev06d;
create procedure sp_dev06d(a_no_documento char(20),a_fecha_calculo date)
returning	smallint		as cod_error,
			varchar(100)	as poliza,
			date			as cubierto_hasta,
			date			as fecha_suspension;

define _mensaje				varchar(100);
define _no_factura			char(10);
define _cod_endomov			char(3);
define _prima_diaria_acum	dec(16,2);
define _monto_devolucion	dec(16,2);
define _monto_cobrado		dec(16,2);
define _prima_diaria		dec(16,2);
define _prima_bruta			dec(16,2);
define _dif_prima			dec(16,2);
define _dias_vigencia		integer;
define _error_isam			integer;
define _contador			integer;
define _error				integer;
define _fecha_suspension	date;
define _cubierto_hasta		date;
define _vigencia_final		date;
define _vigencia_inic		date;
define _fecha_emision		date;
define _max_vigencia		date;
define _fecha_inicio		date;
define _fecha				date;

set isolation to dirty read;

--set debug file to "sp_sis236.trc";
--trace on;

--Query para crear la temporal

begin
on exception set _error,_error_isam,_mensaje
return _error,_mensaje,null,null;
end exception

drop table if exists tmp_consumo_prima;
create temp table tmp_consumo_prima(
no_documento	char(20),
no_factura		char(10),
fecha			date,
prima_diaria	dec(16,2),
prima_cobrada	dec(16,2) default 0.00,
fecha_pago		date,
primary key(no_documento,fecha)) with no log;

let _prima_diaria_acum = 0.00;

foreach
	select cod_endomov,
		   vigencia_inic,
		   vigencia_final,
		   fecha_emision,--vigencia_final - vigencia_inic,
		   prima_bruta
		   --prima_bruta / ((vigencia_final - vigencia_inic) + 1)
	  into _cod_endomov,
		   _vigencia_inic,
		   _vigencia_final,
		   _fecha_emision, -- _dias_vigencia,
		   _prima_bruta
	  from endedmae
	 where no_documento = a_no_documento
	   and fecha_emision < a_fecha_calculo
	   and actualizado = 1
	   and prima_bruta <> 0
	   and activa = 1

	if _fecha_emision > _vigencia_inic and (_prima_bruta > 0 and _cod_endomov <> '025') then
		let _fecha_inicio = _fecha_emision;
		let _dias_vigencia = _vigencia_final - _fecha_emision;
	else
		let _fecha_inicio = _vigencia_inic;
		let _dias_vigencia = _vigencia_final - _vigencia_inic;
	end if

	--let _dias_vigencia = (_dias_vigencia + 1);
	
	if _dias_vigencia = 0 then
		let _prima_diaria = _prima_bruta; --(_dias_vigencia + 1);
	else
		let _prima_diaria = _prima_bruta / _dias_vigencia; --(_dias_vigencia + 1);
	end if
	
	let _prima_diaria_acum = 0.00;
	let _fecha = _fecha_inicio;

	for _contador = 0 to _dias_vigencia
		
		let _fecha = _fecha_inicio + _contador units day;
		begin
			on exception in (-239,-268)
			
				update tmp_consumo_prima
				   set prima_diaria = prima_diaria + _prima_diaria
				 where no_documento = a_no_documento
				   --and no_factura = _no_factura
				   and fecha = _fecha;

			end exception

			insert into tmp_consumo_prima(
					no_documento,
					--no_factura,
					fecha,
					prima_diaria)
			values(	a_no_documento,
					--_no_factura,
					_fecha,
					_prima_diaria);
		end

		let _prima_diaria_acum = _prima_diaria_acum + _prima_diaria;
	end for
	
	if _prima_diaria_acum <> _prima_bruta then
		let _dif_prima = _prima_bruta - _prima_diaria_acum;
		
		update tmp_consumo_prima
		   set prima_diaria = prima_diaria + _dif_prima
		 where no_documento = a_no_documento
		   --and no_factura = _no_factura
		   and fecha = _fecha_inicio;
	end if
end foreach

--Total de Prima Cobrada
select sum(monto)
  into _monto_cobrado
  from cobredet
 where doc_remesa = a_no_documento
   and actualizado = 1
   and tipo_mov in ('P','N','X')
   and fecha <= a_fecha_calculo;

if _monto_cobrado is null then
	let _monto_cobrado = 0.00;
end if

--Total de Devolución de Prima
call sp_che162(a_no_documento,a_fecha_calculo) returning _error,_monto_devolucion;

if _error <> 0 then
	return _error,'Error en el cálculo de la prima devuelta. Póliza: ' || trim(a_no_documento),null,null;
end if

let _monto_cobrado = _monto_cobrado + _monto_devolucion;

let _fecha_inicio = null;

select min(fecha)
  into _fecha_inicio
  from tmp_consumo_prima
 where no_documento = a_no_documento;

while _monto_cobrado <> 0.00 
	select prima_diaria
	  into _prima_diaria
	  from tmp_consumo_prima
	 where no_documento = a_no_documento
	   and fecha = _fecha_inicio;

	if _prima_diaria is null then
		select min(fecha)
		  into _fecha_inicio
		  from tmp_consumo_prima
		 where no_documento = a_no_documento
		   and fecha > _fecha_inicio;

		if _fecha_inicio is null then
			exit while;
		else
			select prima_diaria
			  into _prima_diaria
			  from tmp_consumo_prima
			 where no_documento = a_no_documento
			   and fecha = _fecha_inicio;
		end if
	end if

	if _monto_cobrado >= _prima_diaria then
		let _monto_cobrado = _monto_cobrado - _prima_diaria;

		update tmp_consumo_prima
		   set prima_cobrada = _prima_diaria
		 where no_documento = a_no_documento
		   and fecha = _fecha_inicio;
	else
		update tmp_consumo_prima
		   set prima_cobrada = _monto_cobrado
		 where no_documento = a_no_documento
		   and fecha = _fecha_inicio;

		let _monto_cobrado = 0;
	end if

	let _fecha_inicio = _fecha_inicio + 1 units day;
end while

select max(fecha)
  into _max_vigencia
  from tmp_consumo_prima
 where no_documento = a_no_documento;

select max(fecha)
  into _cubierto_hasta
  from tmp_consumo_prima
 where no_documento = a_no_documento
   and prima_cobrada <> 0;

let _cubierto_hasta = _cubierto_hasta + 1 units day;
let _fecha_suspension = _cubierto_hasta + 30 units day;

if _cubierto_hasta > _max_vigencia then
	let _cubierto_hasta = _max_vigencia;
	let _fecha_suspension = _max_vigencia;
end if

if _fecha_suspension > _max_vigencia then
	let _fecha_suspension = _max_vigencia;
end if

--drop table tmp_consumo_prima;

return 0,a_no_documento,_cubierto_hasta,_fecha_suspension;
end
end procedure;

--let _fecha_hoy = current;
{
call sp_cob174a(a_no_documento,a_fecha_calculo)
returning	_monto_facturado,
			_monto_cobrado,
			_monto_devuelto,
			_saldo;

select min(vigencia_inic),
	   max(vigencia_final)
  into _vigencia_inic,
	   _vigencia_final
  from emipomae
 where no_documento = a_no_documento;

if _monto_facturado = 0.00 then
	let _cubierto_hasta = _vigencia_inic;
else
	let _total_dias = _vigencia_final - _vigencia_inic + 1;

	let _dias_cubiertos = (_saldo/_monto_facturado) * _total_dias;	
	let _cubierto_hasta = _vigencia_final - _dias_cubiertos units day;
end if

return 0,'Actualización Exitosa',_cubierto_hasta;
end
end procedure;

	select no_documento,vigencia_inic,vigencia_final,prima_bruta , prima_bruta / ((vigencia_final - vigencia_inic) + 1) as  prima_diaria,
		case
			when vigencia_inic < a_fecha_calculo and vigencia_final > a_fecha_calculo --Factura devengada parcialmente
				then   ( prima_bruta / ((vigencia_final - vigencia_inic) + 1 )) * ((date(a_fecha_calculo) - date(vigencia_inic)  )  + 1 )
			when a_fecha_calculo > vigencia_final and a_fecha_calculo > vigencia_inic
				then prima_bruta
			else 0
		end
		as prima_devengada
	  into _no_documento,_vigencia_inic,_vigencia_final,_prima_pagada,_prima_diaria,_prima_devengada
	  from endedmae
	 where no_documento = a_no_documento
	 
	{SELECT 
			CASE
					WHEN _vigencia_inic >= a_fecha_calculo THEN 0 --Policy not yet in effect
					WHEN _vigencia_final < a_fecha_calculo THEN _total_dias --Policy completed
					ELSE a_fecha_calculo - _vigencia_inic, ) + 1 --Other cases, ie policy is current
			END AS EarnedDays,
			
			CASE
					WHEN _vigencia_inic >= a_fecha_calculo THEN _total_dias --Policy not yet in effect
					WHEN _vigencia_final < a_fecha_calculo THEN 0 --Policy completed
					ELSE _vigencia_final - a_fecha_calculo --Other cases, ie policy is current
			END AS UnearnedDays}