-- Procedimiento que actualiza los número de pagos de endosos de pólizas que no han tenido plan pago.
-- Creado: 30/05/2017 - Autor: Román Gordón

--drop procedure sp_dev06_amm;
create procedure sp_dev06_amm(a_no_documento char(20),a_fecha_calculo date)
returning	smallint		as cod_error,
			varchar(100)	as poliza,
			date			as cubierto_hasta,
			date			as fecha_suspension;

define _mensaje				varchar(100);
define _no_factura			char(10);
define _no_poliza			char(10);
define _cod_endomov			char(3);
define _cod_ramo			char(3);
define _cod_grupo           char(5);
define _prima_diaria_acum	dec(16,2);
define _monto_devolucion	dec(16,2);
define _monto_cobrado		dec(16,2);
define _prima_diaria		dec(16,2);
define _prima_bruta			dec(16,2);
define _dif_prima			dec(16,2);
define _ajuste				dec(16,2);
define _dias_vigencia		integer;
define _error_isam			integer;
define _contador			integer;
define _error				integer;
define _vigencia_inic_pol	date;
define _fecha_suspension	date;
define _fecha_emi_rehab,_f_p_pago	date;
define _fecha_emi_canc		date;
define _cubierto_hasta		date;
define _vigencia_final		date;
define _vigencia_inic		date;
define _fecha_emision		date;
define _min_vig_inic		date;
define _max_vigencia		date;
define _fecha_inicio		date;
define _fecha				date;
define _dias                smallint;

set isolation to dirty read;

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
create index itmp_con1 on tmp_consumo_prima(no_documento);

let _prima_diaria_acum = 0.00;

select min(vigencia_inic)
  into _min_vig_inic
  from emipomae
 where no_documento = a_no_documento;

let _fecha_emi_rehab = _min_vig_inic;
let _fecha_emi_canc = _min_vig_inic;

Let _dias = 30;
let _f_p_pago = null;

foreach
	select no_poliza,
		   cod_endomov,
		   vigencia_inic,
		   vigencia_final,
		   fecha_emision,
		   prima_bruta
	  into _no_poliza,
		   _cod_endomov,
		   _vigencia_inic,
		   _vigencia_final,
		   _fecha_emision,
		   _prima_bruta
	  from endedmae
	 where no_documento = a_no_documento
	   and fecha_emision < a_fecha_calculo
	   and actualizado = 1
	   --and prima_bruta <> 0
	   and activa = 1
	 order by fecha_emision
	 
	select fecha_primer_pago
	  into _f_p_pago
	  from emipomae
	 where no_poliza = _no_poliza; 
	 
	if _cod_endomov in ('001','019') then	--Aumento y Disminucion de vigencia respectivamente
		select vigencia_inic
		  into _vigencia_inic_pol
		  from emipomae
		 where no_poliza = _no_poliza;

		let _vigencia_inic = _vigencia_inic_pol;
	end if

	if _cod_endomov = '002' and _fecha_emision > _fecha_emi_canc then
		let _fecha_emi_canc = _fecha_emision;
	end if	

	if _cod_endomov = '003' then
		let _fecha_inicio = _fecha_emi_canc;
		let _dias_vigencia = _vigencia_final - _fecha_emi_canc;
	else
		if _fecha_emision > _vigencia_inic and (_prima_bruta > 0 and _cod_endomov not in ('025')) and a_no_documento not in ('0620-00158-01') then	--Reversar descuento pronto pago
			let _fecha_inicio = _fecha_emision;
			let _dias_vigencia = _vigencia_final - _fecha_emision;
		else
			let _fecha_inicio = _vigencia_inic;
			let _dias_vigencia = _vigencia_final - _vigencia_inic;
		end if
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
	
	if _prima_diaria_acum <> _prima_bruta then
		let _dif_prima = _prima_bruta - _prima_diaria_acum;
		update tmp_consumo_prima
		   set prima_diaria = prima_diaria + _dif_prima
		 where no_documento = a_no_documento
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
	   and fecha        = _fecha_inicio;

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
		 where no_documento  = a_no_documento
		   and fecha         = _fecha_inicio;
	else
		update tmp_consumo_prima
		   set prima_cobrada = _monto_cobrado
		 where no_documento  = a_no_documento
		   and fecha         = _fecha_inicio;

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
   
if _cubierto_hasta is null then
	let _cubierto_hasta = _f_p_pago;
end if

select cod_ramo,
       cod_grupo
  into _cod_ramo,
       _cod_grupo
  from emipoliza
 where no_documento = a_no_documento;

--CASO 4626 DRN ENVIADO 29/09/2022 -- SD 7632 Se agregan dos grupos más 77989 y 77982
if _cod_grupo in('00068','77972','77973','77974','77978','77979','77980','77989','77982') or a_no_documento in ('2322-00088-01') then
	let _dias = 60;
else
	Let _dias = 30;
end if
 
let _cubierto_hasta   = _cubierto_hasta + 1 units day;
--let _fecha_suspension = _cubierto_hasta + 30 units day;
let _fecha_suspension = _cubierto_hasta + _dias units day;

if _cod_ramo not in('018','016') then
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