
-- Creado: 30/05/2017 - Autor: Román Gordón

drop procedure sp_dev06_sin_fac;
create procedure sp_dev06_sin_fac(a_no_documento char(20),a_fecha_calculo date)
returning	smallint		as cod_error,
			varchar(100)	as poliza,
			date			as cubierto_hasta,
			date			as fecha_suspension;

define _mensaje				varchar(100);
define _no_factura			char(10);
define _no_poliza			char(10);
define _no_remesa           char(10);
define _cod_endomov			char(3);
define _cod_ramo			char(3);
define _tipo_mov            char(1);
define _prima_diaria_acum	dec(16,2);
define _monto_devolucion	dec(16,2);
define _monto_cobrado		dec(16,2);
define _prima_diaria		dec(16,2);
define _prima_bruta			dec(16,2);
define _dif_prima			dec(16,2);
define _ajuste,_pri_bruta_acum				dec(16,2);
define _prima_neta_sin      dec(16,2);
define _prima_neta_cr,_prima_neta  		dec(16,2);
define _porc_proporcion,_porc_partic_prima		dec(9,6);
define _dias_vigencia		integer;
define _error_isam			integer;
define _contador,_tipo_prod			integer;
define _error,_cnt			integer;
define _vigencia_inic_pol	date;
define _fecha_suspension	date;
define _cubierto_hasta		date;
define _vigencia_final		date;
define _vigencia_inic		date;
define _fecha_emision		date;
define _max_vigencia		date;
define _fecha_inicio		date;
define _fecha				date;
define _renglon,_cntt       integer;
define _porc_coas_ancon		dec(5,2);
define _cod_contrato,_no_endoso        char(5);

define _cod_tipoprod        char(3);

set isolation to dirty read;

begin
on exception set _error,_error_isam,_mensaje
return _error,_mensaje,null,null;
end exception

--set debug file to "sp_dev06_sin_fac.trc";
--trace on;

truncate table consumo_prima;

let _prima_diaria_acum = 0.00;

foreach
	select e.no_poliza,
	       e.no_endoso,
	       e.cod_endomov,
		   e.vigencia_inic,
		   e.vigencia_final,
		   e.fecha_emision
	  into _no_poliza,
	       _no_endoso,
		   _cod_endomov,
		   _vigencia_inic,
		   _vigencia_final,
		   _fecha_emision
	  from endedmae e
	 where e.no_documento = a_no_documento
	   and e.fecha_emision < a_fecha_calculo
	   and e.actualizado  = 1
	   and e.prima_bruta <> 0
	   and e.activa      = 1
	 order by fecha_emision
	
	let _prima_bruta    = 0.00;
	let _pri_bruta_acum = 0.00;
    foreach
		select a.prima
		  into _prima_bruta
		  from emifacon a, reacomae r
		 where a.cod_contrato = r.cod_contrato
		   and r.tipo_contrato not in(3)
		   and a.no_poliza = _no_poliza
		   and a.no_endoso = _no_endoso
		   and a.prima <> 0
		   
		let _pri_bruta_acum = _pri_bruta_acum + _prima_bruta;
		   
	end foreach

	let _prima_bruta = _pri_bruta_acum;

    if _cod_endomov in ('001','019') then	--Aumento y Disminucion de vigencia respectivamente
		select vigencia_inic
		  into _vigencia_inic_pol
		  from emipomae
		 where no_poliza = _no_poliza;

		let _vigencia_inic = _vigencia_inic_pol;
	end if
	
	if _fecha_emision > _vigencia_inic and (_prima_bruta > 0 and _cod_endomov <> '025') then	--Reversar descuento pronto pago
		let _fecha_inicio = _fecha_emision;
		let _dias_vigencia = _vigencia_final - _fecha_emision;
	else
		let _fecha_inicio = _vigencia_inic;
		let _dias_vigencia = _vigencia_final - _vigencia_inic;
	end if

	if _dias_vigencia = 0 then
		let _prima_diaria = _prima_bruta; --(_dias_vigencia + 1);
	else
		let _prima_diaria = _prima_bruta / _dias_vigencia; --(_dias_vigencia + 1);
	end if
	
	let _prima_diaria_acum = 0.00;
	let _fecha             = _fecha_inicio;

	for _contador = 0 to _dias_vigencia
		
		let _fecha = _fecha_inicio + _contador units day;
		begin
			on exception in (-239,-268)
			
				update consumo_prima
				   set prima_diaria = prima_diaria + _prima_diaria
				 where no_documento = a_no_documento
				   and fecha = _fecha;

			end exception

			insert into consumo_prima(
					no_documento,
					fecha,
					prima_diaria)
			values(	a_no_documento,
					_fecha,
					_prima_diaria);
		end

		let _prima_diaria_acum = _prima_diaria_acum + _prima_diaria;
	end for
	
	if _prima_diaria_acum <> _prima_bruta then
		let _dif_prima = _prima_bruta - _prima_diaria_acum;
		update consumo_prima
		   set prima_diaria = prima_diaria + _dif_prima
		 where no_documento = a_no_documento
		   and fecha = _fecha_inicio;
	end if
end foreach

--Total de Prima Cobrada
let _monto_cobrado = 0;

foreach
	select no_remesa,
		   renglon,
		   tipo_mov,
		   no_poliza,
		   prima_neta
	  into _no_remesa,
		   _renglon,
		   _tipo_mov,
		   _no_poliza,
		   _prima_neta
	  from cobredet
	 where doc_remesa = a_no_documento
	   and actualizado = 1
	   and tipo_mov in ('P','N','X')
	   and fecha <= a_fecha_calculo

	let _prima_neta_sin = 0;
	let _prima_neta_cr  = 0;
	select count(*)
	  into _cnt
	  from cobreaco
	 where no_remesa = _no_remesa
	   and renglon   = _renglon;

	if _cnt is null then
		let _cnt = 0;
	end if
	if _cnt = 0 then
		if _tipo_mov in('P','N') then
			call sp_sis171bk(_no_remesa, _renglon) returning _error,_mensaje;
		end if
	end if
	
	select cod_tipoprod
	  into _cod_tipoprod
	  from emipomae
	 where no_poliza = _no_poliza;
	 
	select tipo_produccion
	  into _tipo_prod
	  from emitipro
	 where cod_tipoprod = _cod_tipoprod;
	 
	if _tipo_prod = 2 then  --coas mayoritario
		select porc_partic_coas
		  into _porc_coas_ancon
		  from emicoama
		 where no_poliza    = _no_poliza
		   and cod_coasegur = "036";    --ancon
	else
		let _porc_coas_ancon = 100;
	end if
	
	let _prima_neta_cr = 0.00;
	let _prima_neta_sin = 0.00;
	
	foreach
		select c.porc_partic_prima,
			   c.porc_proporcion,
			   c.cod_contrato
		  into _porc_partic_prima,
			   _porc_proporcion,
			   _cod_contrato
		  from cobreaco c , reacomae r
		 where c.cod_contrato = r.cod_contrato
		   and r.tipo_contrato not in(3)		--No facultativos
		   and c.no_remesa = _no_remesa
		   and c.renglon   = _renglon
		   
		let _prima_neta_sin = (_prima_neta * _porc_partic_prima /100) * _porc_proporcion / 100;
		
		let _prima_neta_cr = _prima_neta_cr + _prima_neta_sin;
	end foreach
	
	if _prima_neta_cr is null then
		let _prima_neta_cr = 0.00;
	end if
	let _monto_cobrado = _monto_cobrado + ( _prima_neta_cr * _porc_coas_ancon) / 100;
end foreach

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
  from consumo_prima
 where no_documento = a_no_documento;

while _monto_cobrado <> 0.00 
	select prima_diaria
	  into _prima_diaria
	  from consumo_prima
	 where no_documento = a_no_documento
	   and fecha        = _fecha_inicio;

	if _prima_diaria is null then
		select min(fecha)
		  into _fecha_inicio
		  from consumo_prima
		 where no_documento = a_no_documento
		   and fecha > _fecha_inicio;

		if _fecha_inicio is null then
			exit while;
		else
			select prima_diaria
			  into _prima_diaria
			  from consumo_prima
			 where no_documento = a_no_documento
			   and fecha = _fecha_inicio;
		end if
	end if

	if _monto_cobrado >= _prima_diaria then
		let _monto_cobrado = _monto_cobrado - _prima_diaria;

		update consumo_prima
		   set prima_cobrada = _prima_diaria
		 where no_documento  = a_no_documento
		   and fecha         = _fecha_inicio;
	else
		update consumo_prima
		   set prima_cobrada = _monto_cobrado
		 where no_documento  = a_no_documento
		   and fecha         = _fecha_inicio;

		let _monto_cobrado = 0;
	end if
	let _fecha_inicio = _fecha_inicio + 1 units day;
end while

select max(fecha)
  into _max_vigencia
  from consumo_prima
 where no_documento = a_no_documento;

select max(fecha)
  into _cubierto_hasta
  from consumo_prima
 where no_documento = a_no_documento
   and prima_cobrada <> 0;

let _cubierto_hasta   = _cubierto_hasta + 1 units day;
let _fecha_suspension = _cubierto_hasta + 30 units day;

select cod_ramo
  into _cod_ramo
  from emipoliza
 where no_documento = a_no_documento;

if _cod_ramo <> '018' then
	if _cubierto_hasta > _max_vigencia then
		let _cubierto_hasta = _max_vigencia;
		let _fecha_suspension = _max_vigencia;
	end if

	if _fecha_suspension > _max_vigencia then
		let _fecha_suspension = _max_vigencia;
	end if
end if

return 0,a_no_documento,_cubierto_hasta,_fecha_suspension;
end
end procedure;