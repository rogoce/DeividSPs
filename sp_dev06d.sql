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
define _monto_neto		dec(16,2);
define _prima_diaria		dec(16,2);
define _prima_neta			dec(16,2);
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
		   prima_neta
		   --prima_bruta / ((vigencia_final - vigencia_inic) + 1)
	  into _cod_endomov,
		   _vigencia_inic,
		   _vigencia_final,
		   _fecha_emision, -- _dias_vigencia,
		   _prima_neta
	  from endedmae
	 where no_documento = a_no_documento
	   and fecha_emision < a_fecha_calculo
	   and actualizado = 1
	   and prima_bruta <> 0
	   and activa = 1

	if _fecha_emision > _vigencia_inic and (_prima_neta > 0 and _cod_endomov <> '025') then
		let _fecha_inicio = _fecha_emision;
		let _dias_vigencia = _vigencia_final - _fecha_emision;
	else
		let _fecha_inicio = _vigencia_inic;
		let _dias_vigencia = _vigencia_final - _vigencia_inic;
	end if

	--let _dias_vigencia = (_dias_vigencia + 1);
	
	if _dias_vigencia = 0 then
		let _prima_diaria = _prima_neta; --(_dias_vigencia + 1);
	else
		let _prima_diaria = _prima_neta / _dias_vigencia; --(_dias_vigencia + 1);
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
				   and fecha = _fecha;
			end exception

			insert into tmp_consumo_prima(
					no_documento,
					fecha,
					prima_diaria)
			values(	a_no_documento,
					_fecha,
					_prima_diaria);
		end

		let _prima_diaria_acum = _prima_diaria_acum + _prima_diaria;
	end for

	if _prima_diaria_acum <> _prima_neta then
		let _dif_prima = _prima_neta - _prima_diaria_acum;
		
		update tmp_consumo_prima
		   set prima_diaria = prima_diaria + _dif_prima
		 where no_documento = a_no_documento
		   and fecha = _fecha_inicio;
	end if
end foreach

--Total de Prima Cobrada
{select sum(monto)
  into _monto_neto
  from cobredet
 where doc_remesa = a_no_documento
   and actualizado = 1
   and tipo_mov in ('P','N','X')
   and fecha <= a_fecha_calculo;

if _monto_neto is null then
	let _monto_neto = 0.00;
end if

--Total de Devolución de Prima
call sp_che162(a_no_documento,a_fecha_calculo) returning _error,_monto_devolucion;

if _error <> 0 then
	return _error,'Error en el cálculo de la prima devuelta. Póliza: ' || trim(a_no_documento),null,null;
end if

let _monto_neto = _monto_neto + _monto_devolucion;

let _fecha_inicio = null;

select min(fecha)
  into _fecha_inicio
  from tmp_consumo_prima
 where no_documento = a_no_documento;

while _monto_neto <> 0.00 
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

	if _monto_neto >= _prima_diaria then
		let _monto_neto = _monto_neto - _prima_diaria;

		update tmp_consumo_prima
		   set prima_cobrada = _prima_diaria
		 where no_documento = a_no_documento
		   and fecha = _fecha_inicio;
	else
		update tmp_consumo_prima
		   set prima_cobrada = _monto_neto
		 where no_documento = a_no_documento
		   and fecha = _fecha_inicio;

		let _monto_neto = 0;
	end if

	let _fecha_inicio = _fecha_inicio + 1 units day;
end while
}
foreach
	select tipo_mov,
		   fecha,
		   prima_neta
	  into _tipo_mov,
		   _fecha,
		   _monto_neto
	  from (select tipo_mov,	--detalle de Pagos
				   doc_remesa as documento,
				   fecha,
				   prima_neta
			   from cobredet
			  where doc_remesa = a_no_documento
				and actualizado = 1
				and tipo_mov in ('P','N')
				and fecha <= a_fecha_calculo
			union
			select 'C' as tipo_mov,	--detalle de devoluciones de primas
				   m.fecha_impresion as fecha,
				   c.prima_neta
			  from chqchpol c, chqchmae m
			 where c.no_requis = m.no_requis
			   and c.no_documento = a_no_documento
			   and m.fecha_impresion <= a_fecha_calculo
			   and (m.fecha_anulado is null or m.fecha_anulado > a_fecha_calculo))
	   order by fecha

	let _fecha_inicio = null;

	select min(fecha)
	  into _fecha_inicio
	  from tmp_consumo_prima
	 where no_documento = a_no_documento;

	while _monto_neto <> 0.00 
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

		if _monto_neto >= _prima_diaria then
			let _monto_neto = _monto_neto - _prima_diaria;

			update tmp_consumo_prima
			   set prima_cobrada = _prima_diaria
			 where no_documento = a_no_documento
			   and fecha = _fecha_inicio;
		else
			update tmp_consumo_prima
			   set prima_cobrada = _monto_neto
			 where no_documento = a_no_documento
			   and fecha = _fecha_inicio;

			let _monto_neto = 0;
		end if

		let _fecha_inicio = _fecha_inicio + 1 units day;
	end while
end foreach

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