-- Procedimiento que realiza la emisión de Pólizas de Coaseguro Minoritario del Estado.
-- execute procedure sp_pro551a('005','00001',1,'DEIVID')
-- Creado    : 30/03/2016 - Autor: Roman Gordon 

drop procedure sp_pro551a;
create procedure "informix".sp_pro551a(
a_cod_coasegur	char(3),
a_num_carga		integer,
a_renglon		smallint,
a_usuario		char(8))
returning	integer,
			varchar(100);


define _nom_cliente					varchar(50);
define _no_poliza_coaseg			varchar(30);
define _error_title					varchar(30);
define _pasaporte					varchar(30);
define _cedula						varchar(30);
define _ramo						varchar(30);
define _ruc							varchar(30);
define _razon_social				char(100);
define _error_desc					char(100);
define _cliente_ape					char(50);
define _no_chasis					char(30);
define _no_motor					char(30);
define _placa						char(30); 
define _vin							char(30);
define _no_documento				char(20);
define _cod_manzana					char(15);
define _cod_contratante				char(10);
define _no_poliza					char(10);
define _cod_cliente					char(10);
define _periodo						char(7);
define _cod_producto				char(5);
define _cod_contrato				char(5);
define _cod_grupo					char(5);
define _cod_agente					char(5);
define _cod_modelo					char(5);
define _no_unidad					char(5);
define _cod_ruta					char(5);
define _cod_cober_reas				char(3);
define _cod_no_renov				char(3);
define _cod_cobrador				char(3);
define _cod_tipoprod				char(3);
define _cod_compania				char(3);
define _cod_formapag				char(3);
define _cod_tipocalc				char(3);
define _cod_sucursal				char(3);
define _cod_impuesto				char(3);
define _tipo_factura				char(3);
define _cod_tipoveh					char(3);
define _cod_ubica					char(3);
define _cod_subramo					char(3);
define _cod_perpago					char(3);
define _cod_color					char(3);
define _cod_marca					char(5);
define _cod_ramo					char(3);
define _codtipo						char(3);
define _tipo_persona				char(1);
define _cobra_poliza				char(1);
define _nueva_renov					char(1);
define _uso_auto					char(1);
define _sexo						char(1);
define _null						char(1);
define _prima_terremoto				dec(16,2);
define _suma_asegurada				dec(16,2);
define _monto_impuesto				dec(16,2);
define _prima_incendio				dec(16,2);
define _total_a_pagar				dec(16,2);
define _tot_impuesto				dec(16,2);
define _prima_total					dec(16,2);
define _prima_bruta					dec(16,2);
define _prima_neta					dec(16,2);
define _descuento					dec(16,2);
define _impuesto					dec(16,2);
define _comision					dec(16,2);
define _monto						dec(16,2);
define _saldo						dec(16,2);
define _porc_partic_ancon			dec(9,6);
define _porc_partic_prima			dec(9,6);
define _porc_partic_suma			dec(9,6);
define _gastos_manejo				dec(9,6);
define _factor_impuesto				dec(5,2);
define _porc_comision				dec(5,2);
define _tiene_impuesto				smallint;
define _cont_beneficio				smallint;
define _tipo_contrato				smallint;
define _cnt_contratos				smallint;
define _tipo_incendio				smallint;
define _anio_actual					smallint;
define _error_isam					smallint;
define _auto_nuevo					smallint;
define _anio_tarifa					smallint;
define li_no_pagos					smallint;
define _capacidad					smallint;
define _cnt_dias					smallint;
define _no_pagos					smallint;
define _cnt_ramo					smallint;
define li_return					smallint;
define _anio_auto					smallint;
define _cnt_auto					smallint;
define _ramo_sis					smallint;
define _cnt_fac						smallint;
define _cnt_act						smallint;
define _renglon						smallint;
define _meses						smallint;
define _existe						smallint;
define _grupo						smallint;
define r_anios						smallint;
define _dias						smallint;
define _dia							smallint;
define _mes							smallint;
define _anio						smallint;
define _serie						smallint;
define _orden						smallint;
define _error						smallint;
define v_cotizacion_r				integer;
define _cant_unidades				integer; 
define v_nopagos					integer;
define _anioauto					integer;
define _cadena						integer;
define _fecha_primer_pago			date;
define _fecha_aniversario			date;
define _vigencia_inic_fe			date;
define ld_fecha_1_pago				date;
define _vigencia_final				date;
define _vigencia_inic				date;
define _fecha_factura				date;
define _fecha_hoy					date;
--define _descr						references byte;

--set debug file to "sp_pro551a.trc"; 
--trace on;

set lock mode to wait;

let _no_unidad = '00001';
let _cod_no_renov = '028';
let _cod_compania = '001';
let _cod_tipocalc = '001';
let _cod_tipoprod = '002';
let _cod_perpago = '002';
let _cod_manzana = '';
let _cod_subramo = '';
let _cod_ubica = '001';
let _cod_grupo = '1000';
let _uso_auto = 'C';
let _suma_asegurada = 0.00;
let _cont_beneficio = 0;
let _tiene_impuesto = 0;
let _descuento = 0.00;
let _no_pagos = 12;
let _cnt_act = 0;
let _tipo_incendio = null;

begin
on exception set _error,_error_isam,_error_desc
  return _error,_error_desc;
end exception

select no_poliza_coaseg,
	   cedula,
	   nom_cliente,
	   tipo_factura,
	   fecha_factura,
	   vigencia_inic_fe,
	   cod_ramo,
	   ramo_coaseguro,
	   vigencia_inic,
	   vigencia_final,
	   prima,
	   impuesto,
	   total_a_pagar,
	   porc_partic_ancon,
	   renglon
  into _no_poliza_coaseg,
	   _cedula,
	   _nom_cliente,
	   _tipo_factura,
	   _fecha_factura,
	   _vigencia_inic_fe,
	   _cod_ramo,
	   _ramo,
	   _vigencia_inic,
	   _vigencia_final,
	   _prima_total,
	   _impuesto,
	   _total_a_pagar,
	   _porc_partic_ancon,
	   _renglon
  from emicacoami
 where cod_coasegur = a_cod_coasegur
   and num_carga = a_num_carga
   and renglon = a_renglon;

let _fecha_hoy = current;
let _fecha_primer_pago = _vigencia_inic;

let _nueva_renov = 'N';
let _prima_bruta = _total_a_pagar * (_porc_partic_ancon/100);

let _tot_impuesto = 0.00;
if _impuesto = 0 then
	let _tiene_impuesto = 0;
	let _prima_neta = _prima_bruta;
else
	let _tiene_impuesto = 1;
	let _prima_neta = 0.00;
end if 

select emi_periodo 														   
  into _periodo
  from parparam
 where cod_compania  = _cod_compania;

select count(*)
  into _cnt_ramo
  from prdinfcoami
 where cod_coasegur = a_cod_coasegur
   and cod_ramo = _cod_ramo;

if _cnt_ramo is null then
	let _cnt_ramo = 0;
end if

if _cnt_ramo = 1 then
	select cod_subramo,
		   cod_producto,
		   suma_asegurada,
		   cod_perpago,
		   no_pagos,
		   cod_agente
	  into _cod_subramo,
		   _cod_producto,
		   _suma_asegurada,
		   _cod_perpago,
		   _no_pagos,
		   _cod_agente
	  from prdinfcoami
	 where cod_coasegur = a_cod_coasegur
	   and cod_ramo = _cod_ramo;
	   
elif _cnt_ramo > 1 and _cod_ramo = '015' then
	if _ramo = 'FIDELIDAD' then
		let _cod_subramo = '011';
	elif _ramo = 'RIESGOS DIVERSOS' then
		let _cod_subramo = '006';
	end if

	select cod_producto,
		   suma_asegurada,
		   cod_perpago,
		   no_pagos,
		   cod_agente
	  into _cod_producto,
		   _suma_asegurada,
		   _cod_perpago,
		   _no_pagos,
		   _cod_agente
	  from prdinfcoami
	 where cod_coasegur = a_cod_coasegur
	   and cod_ramo = _cod_ramo
	   and cod_subramo = _cod_subramo;
else
	return 1,'No se encuentra el ramo correspondiente a la póliza: ' || trim(_no_poliza_coaseg);
end if


--Verificación de los pagos en caso de ser una emisión a corto plazo
let _dias	= abs(_vigencia_inic - _vigencia_final);
let _mes	= month(_vigencia_inic);

if _cod_perpago = '001' then
	let _cnt_dias = 15;
elif _cod_perpago = '002' then
	let _cnt_dias = 30;
elif _cod_perpago = '003' then
	let _cnt_dias = 60;
elif _cod_perpago = '004' then
	let _cnt_dias = 90;
elif _cod_perpago in ('005','009') then
	let _cnt_dias = 120;
elif _cod_perpago = '007' then
	let _cnt_dias = 180;
elif _cod_perpago = '008' then
	let _cnt_dias = 365;
end if

let _dia = _no_pagos * _cnt_dias;

if (_dias = 28 or _dias = 29) and _mes = 2 Then --febrero
	let _dias = 30;
elif (_dias = 58 or _dias = 59) and _mes = 2 Then
	let _dias = 60;
elif (_dias = 88 or _dias = 89) and _mes = 2 Then
	let _dias = 90;
elif (_dias = 118 or _dias = 119) and _mes = 2 Then
	let _dias = 120;
elif (_dias = 178 or _dias = 179) and _mes = 2 Then
	let _dias = 180;
elif (_dias = 363 or _dias = 364) and _mes = 2 Then
	let _dias = 365;
end if

if _dia > _dias Then
	let _no_pagos = trunc(_dias /_cnt_dias);
	
	if _no_pagos = 0 then
		let _no_pagos = 1;
		let _cod_perpago = '006';
	end if
end if	

let r_anios = 0;

if r_anios > 0 then
   let r_anios = r_anios - 1;
else
   let r_anios = 0;
end if

let _serie = year(_vigencia_inic);
let _mes = month(_vigencia_inic);
let _dia = day(_vigencia_inic);
let _anio = year(_vigencia_inic);

if _dia = 29 and _mes = 2 then
	let _dia = 28;
	let _vigencia_inic = mdy(_mes, _dia, _anio);
end if

let _anio = year(_vigencia_inic) + 1;

if _mes = 2 then
	if _dia > 28 then
		let _dia = 28;
	    let _vigencia_final = mdy(_mes, _dia, _anio);
	end if
end if

let _no_poliza = sp_sis13(_cod_compania, 'PRO', '02', 'par_no_poliza');

--if _tipo_factura = 'EMI' then
--end if

--let _monto      	= _prima_sin_desc;
let _cod_sucursal = '001';

let _cod_cliente = sp_par332(_cedula,_nom_cliente,a_usuario);

update cliclien
   set telefono1 = '301-2265',
       e_mail = 'cmarin@assanet.com'
 where cod_cliente = _cod_cliente;

let _cod_contratante = _cod_cliente;
let _cod_cliente  = trim(_cod_cliente);

select ramo_sis
  into _ramo_sis
  from prdramo
 where cod_ramo = _cod_ramo;

select meses
  into _meses
  from cobperpa
 where cod_perpago = _cod_perpago;

--Quitarle el impuesto a la prima inicial
begin

if _ramo_sis = 5 then	   --las polizas de salud no pueden tener vigencia despues del 28
	if _dia > 28 then
		let _dia = 28;
	    let _vigencia_final = mdy(_mes, _dia, _anio);
	end if

	if _meses = 0 or _meses = 1 then --30 dias
		let _mes = _mes + 1;
	elif _meses = 2 then  --60 dias
		let _mes = _mes + 2;
	elif _meses = 3 then  --90 dias
		let _mes = _mes + 3;
	elif _meses = 4 then  --120 dias
		let _mes = _mes + 4;
	elif _meses = 6 then  --semestral
		let _mes = _mes + 6;
	end if

	if _mes < 13 then
		let _anio = year(_vigencia_inic);

	else
		let _mes = _mes - 12;
		let _anio = year(_vigencia_inic) + 1;
	end if

    let _vigencia_final = mdy(_mes, _dia, _anio);
elif _ramo_sis in (2,8) then --Incendio y Multiriesgos
	let _cod_manzana = '08008';
	let _tipo_incendio = 1;
end if

--let v_nopagos     = 1;

--Forma de pago
let _cod_formapag = '084';	--Coaseguro Minoritario
let _cobra_poliza = 2;
let _cod_cobrador = null;

select cod_cobrador
  into _cod_cobrador
  from cobforpa
 where cod_formapag = _cod_formapag;

if _cod_cobrador is null then
	select cod_cobrador
	  into _cod_cobrador
	  from agtagent
	 where cod_agente = _cod_agente;
end if	 
 
select cobra_poliza
  into _cobra_poliza
  from cobdivco
 where cod_formapag = _cod_formapag
   and cod_cobrador = _cod_cobrador;

end

insert into emipomae(
		no_poliza,
		cod_compania,		 
		cod_sucursal,
		sucursal_origen,
		cod_grupo,
		cod_perpago,
		cod_tipocalc,
		cod_ramo,
		cod_subramo,
		cod_formapag,
		cod_tipoprod,
		cod_contratante,
		cod_pagador,
		cod_no_renov,
		serie,
		no_documento,
		no_factura,		 
		prima,			 
		descuento,
		recargo,			 
		prima_neta,		 
		impuesto,			 
		prima_bruta,		 
		prima_suscrita,
		prima_retenida,
		tiene_impuesto,	 
		vigencia_inic,
		vigencia_final,	 
		fecha_suscripcion,
		fecha_impresion,	 
		fecha_cancelacion, 
		no_pagos,			 
		impreso,			 
		nueva_renov,
		estatus_poliza,	 
		direc_cobros,
		por_certificado,
		actualizado,		 
		dia_cobros1,		 
		dia_cobros2,		 
		fecha_primer_pago, 
		no_poliza_coaseg,	 
		date_changed,		 
		renovada,			 
		date_added,		 
		periodo,
		carta_aviso_canc,	 
		carta_prima_gan,	 
		carta_vencida_sal, 
		carta_recorderis,	 
		fecha_aviso_canc,	 
		fecha_prima_gan,	 
		fecha_vencida_sal, 
		fecha_recorderis,	 
		cobra_poliza,		 
		user_added,
		ult_no_endoso,	 
		declarativa,
		abierta,
		fecha_renov,		 
		fecha_no_renov,	 
		no_renovar,		 
		perd_total,		 
		anos_pagador,		 
		saldo_por_unidad,	 
		factor_vigencia,	 
		suma_asegurada,	 
		incobrable,		 
		saldo,			 
		fecha_ult_pago,	 
		reemplaza_poliza,	 
		user_no_renov,	 
		posteado,			 
		no_tarjeta,		 
		fecha_exp,		 
		cod_banco,		 
		monto_visa,		 
		tipo_tarjeta,		 
		no_recibo,		 
		no_cuenta,		 
		tipo_cuenta,		 
		gestion,			 
		fecha_gestion,	 
		dia_cobro_anterior,
		incentivo,		 
		cod_origen,		 
		cotizacion,		 
		de_cotizacion,
		ind_fecha_coti,
		ind_fecha_aprob)
VALUES(	_no_poliza,				--no_poliza
		_cod_compania,			--cod_compania		 001
		_cod_sucursal,			--cod_sucursal
		_cod_sucursal,			--sucursal_origen
		_cod_grupo,				--cod_grupo
		_cod_perpago,			--cod_perpago
		_cod_tipocalc,			--cod_tipocalc
		_cod_ramo,				--cod_ramo
		_cod_subramo,			--cod_subramo
		_cod_formapag,			--cod_formapag
		_cod_tipoprod,			--cod_tipoprod
		_cod_contratante,		--cod_contratante
		_cod_contratante,		--cod_pagador
		_cod_no_renov,			--cod_no_renov		 null
		_serie,					--serie
		null,					--no_documento		 null
		null,					--no_factura		 null
		_prima_neta,			--prima			 0
		_descuento,				--descuento
		0,						--recargo			 0
		_prima_neta,			--prima_neta		 0
		0,						--impuesto			 0
		_prima_bruta,			--prima_bruta		 0				  
		_prima_neta,			--prima_suscrita					  
		0.00,					--prima_retenida
		_tiene_impuesto,		--tiene_impuesto	 1
		_vigencia_inic,			--vigencia_inic
		_vigencia_final,		--vigencia_final	 null
		_fecha_hoy,				--fecha_suscripcion
		_fecha_hoy,				--fecha_impresion	 today
		null,					--fecha_cancelacion null
		_no_pagos,				--no_pagos			 1
		0,						--impreso			 0
		_nueva_renov,			--nueva_renov
		1,						--estatus_poliza	 1
		1,						--direc_cobros
		0,						--por_certificado
		0,						--actualizado		 0
		0,						--dia_cobros1		 0
		0,						--dia_cobros2		 0
		_fecha_primer_pago,		--fecha_primer_pago 
		_no_poliza_coaseg,		--no_poliza_coaseg	 null
		_fecha_hoy,				--date_changed		 today
		0,						--renovada			 0
		_fecha_hoy,				--date_added		 today
		_periodo,				--periodo
		0,						 --carta_aviso_canc	 
		0,						 --carta_prima_gan	 
		0,						 --carta_vencida_sal 
		0,						 --carta_recorderis	 
		null,					 --fecha_aviso_canc	 null
		null,					 --fecha_prima_gan	 null
		null,					 --fecha_vencida_sal null
		null,					 --fecha_recorderis	 null
		_cobra_poliza,			 --cobra_poliza		 E
		a_usuario,				 --user_added
		0,						 --ult_no_endoso	 0
		0,						 --declarativa
		0,						 --abierta
		null,					 --fecha_renov		 null
		null,					 --fecha_no_renov	 null
		1,						 --no_renovar		 0
		0,						 --perd_total		 0
		0,						 --anos_pagador		 0
		0,						 --saldo_por_unidad	 0
		1,						 --factor_vigencia	 0
		_suma_asegurada,		--suma_asegurada	 0
		0,						 --incobrable		 0
		0,						--saldo			 0
		null,					 --fecha_ult_pago	 null
		null,					 --reemplaza_poliza	 null
		null,					 --user_no_renov	 null
		0,					     --posteado			 0
		null,					 --no_tarjeta		 null
		null,					 --fecha_exp		 null
		null,					 --cod_banco		 null
		null,					 --monto_visa		 null
		null,					 --tipo_tarjeta		 null
		null,	 				 --no_recibo		 null
		null,					 --no_cuenta		 null
		null,					 --tipo_cuenta		 null
		null,					 --gestion			 null
		null,					 --fecha_gestion	 null
		null,					 --dia_cobro_anterior 0
		null,					 --incentivo		 0
		'001',					 --cod_origen		 null
		null,   				     --cotizacion		 null
		0,						 --de_cotizacion	 0
		null,
		null);

--Coaseguro Minoritario
if _cod_tipoprod = '002' then
	insert into emicoami(
			no_poliza,
			cod_coasegur,
			subir_bo,
			porc_partic_ancon)
	values(	_no_poliza,
			a_cod_coasegur,
			1,
			_porc_partic_ancon);
end if

let _no_documento = sp_sis19(_cod_compania, _cod_sucursal, _no_poliza);

update emipomae
   set no_documento = _no_documento
 where no_poliza = _no_poliza;

select fecha_primer_pago,
       no_pagos,
	   cod_perpago
  into ld_fecha_1_pago,
       li_no_pagos,
	   _cod_perpago	
  from emipomae
 where no_poliza = _no_poliza;

if li_no_pagos = 1 then

	select meses
	  into _meses
	  from cobperpa
	 where cod_perpago = _cod_perpago;

	let _mes = month(ld_fecha_1_pago) + _meses;
	let _anio = year(ld_fecha_1_pago);
	let _dia = day(ld_fecha_1_pago);

	if _mes > 12 then
		let _mes = _mes - 12;
		let _anio = _anio + 1;
	end if

	if _mes = 2 then
		if _dia > 28 then
			let _dia = 28;
		end if
	elif _mes in (4, 6, 9, 11) then
		if _dia > 30 then
			let _dia = 30;
		end if
	end if

	let ld_fecha_1_pago = mdy(_mes, _dia, _anio);

	if ld_fecha_1_pago < _vigencia_final then
		update emipomae
		   set fecha_primer_pago = ld_fecha_1_pago
		 where no_poliza         = _no_poliza;
	end if
end if

-- Buscando el % de comision
LET _porc_comision = sp_pro305(_cod_agente, _cod_ramo,_cod_subramo);

IF _porc_comision IS NULL THEN
    LET _porc_comision = 0.00;
END IF

insert into emipoagt(
cod_agente,
no_poliza,
porc_partic_agt,
porc_comis_agt,
porc_produc
)
values (
_cod_agente,		--cod_agente
_no_poliza,			--no_poliza
100,			    --porc_partic_agt
_porc_comision,		--porc_comis_agt
100					--porc_produc
);

-- Reaseguro Global
foreach
	select cod_ruta
	  into _cod_ruta
	  from rearumae
	 where cod_compania = _cod_compania
	   and cod_sucursal = "001"
	   and cod_ramo     = _cod_ramo
	   and activo = 1
	   and _vigencia_inic between vig_inic and vig_final

	select count(*)
	  into _cnt_fac
	  from rearucon r, reacomae c
	 where r.cod_contrato = c.cod_contrato
	   and r.cod_ruta = _cod_ruta
	   and c.tipo_contrato = 3;

	if _cnt_fac is null then
		let _cnt_fac = 0;
	end if
	
	if _cnt_fac <> 0 then
		continue foreach;
	end if

	exit foreach;
end foreach

foreach
	select orden,
		   cod_contrato,
		   cod_cober_reas,
		   porc_partic_prima,
		   porc_partic_suma
	  into _orden,
		   _cod_contrato,
		   _cod_cober_reas,
		   _porc_partic_prima,
		   _porc_partic_suma
	  from rearucon
	 where cod_ruta = _cod_ruta

	if _porc_partic_prima is null then
		let _porc_partic_prima = 0.00;
	end if
	
	select tipo_contrato
	  into _tipo_contrato
	  from reacomae
	 where cod_contrato = _cod_contrato;

	--No debe insertar contratos facultativos
	if _tipo_contrato = 3 then
		continue foreach;
	end if

	if _porc_partic_prima = 0.00 then
		select count(*)
		  into _cnt_contratos
		  from rearucon r, reacomae m
		 where r.cod_contrato = m.cod_contrato
		   and r.cod_ruta = _cod_ruta
		   and r.cod_cober_reas = _cod_cober_reas
		   and m.tipo_contrato <> 3;

		if _cnt_contratos = 1 then
			let _porc_partic_prima = 100;
			let _porc_partic_suma = 100;
		end if
	end if

	insert into emigloco (
			no_poliza,
			no_endoso,
			orden,
			cod_contrato,
			porc_partic_prima,
			porc_partic_suma,
			suma_asegurada,
			prima,
			cod_ruta)
	values (
			_no_poliza,
			'00000',
			_orden,
			_cod_contrato,
			_porc_partic_prima,
			_porc_partic_suma,
			0.00,
			0.00,
			_cod_ruta);
end foreach

--Impuestos
if _tiene_impuesto = 1 then
	begin

	select sum(factor_impuesto)
	  into _factor_impuesto
	  from prdimsub p, prdimpue i
	 where p.cod_impuesto = i.cod_impuesto
	   and p.cod_ramo    = _cod_ramo
	   and p.cod_subramo = _cod_subramo;

	let _prima_neta = _prima_bruta / (1 + (_factor_impuesto/100));
	let _factor_impuesto = 0.00;
	
	foreach
		select cod_impuesto
		  into _cod_impuesto
		  from prdimsub
		 where cod_ramo    = _cod_ramo
		   and cod_subramo = _cod_subramo

		select factor_impuesto
		  into _factor_impuesto
		  from prdimpue
		 where cod_impuesto = _cod_impuesto;

		let _monto_impuesto = _prima_neta * (_factor_impuesto/100);

		insert into emipolim(
				no_poliza,
				cod_impuesto,
				monto)
		values(	_no_poliza,	   --no_poliza
				_cod_impuesto,	   --cod_impuesto
				_monto_impuesto);
	end foreach
	
	select sum(monto)
	  into _tot_impuesto
	  from emipolim
	 where no_poliza = _no_poliza;

	if _tot_impuesto is null then
		let _tot_impuesto = 0.00;
	end if

	let _prima_neta = _prima_bruta - _tot_impuesto;
	
	update emipomae
	   set prima = _prima_neta,
		   prima_neta = _prima_neta,
		   prima_suscrita = _prima_neta
	 where no_poliza = _no_poliza;

	end
end if

{
begin

	select cod_ruta,   
		   nombre,
		   vig_inic,
		   vig_final  
	  from rearumae  
	 where cod_compania = _codcompania
	   and cod_ramo = :a_ramo
	   and :a_vig_ini between vig_inic and vig_final ) and  
         ( activo = 1 )   
order by cod_ruta asc   

end}

insert into emipouni(
		no_poliza,
		no_unidad,
		cod_ruta,
		cod_producto,
		cod_asegurado,
		suma_asegurada,
		prima,
		descuento,
		recargo,
		prima_neta,
		impuesto,
		prima_bruta,
		reasegurada,
		vigencia_inic,	
		vigencia_final,	
		beneficio_max,	
		desc_unidad,		
		activo,
		prima_asegurado,
		prima_total,		
		no_activo_desde,
		facturado,
		user_no_activo,	
		perd_total,		
		impreso,			
		fecha_emision,
		prima_suscrita,
		prima_retenida,
		eliminada,		
		suma_aseg_adic,	
		tipo_incendio,
		cont_beneficios,
		cod_manzana)
values(	_no_poliza,		 -- no_poliza
		'00001',		 	 -- no_unidad
		_cod_ruta,			 -- cod_ruta
		_cod_producto,		 -- cod_producto
		_cod_cliente,		 -- cod_asegurado	 null
		_suma_asegurada,	 -- suma_asegurada	 0
		_prima_neta,	 -- prima			 0
		_descuento,			 -- descuento
		0,		 			 -- recargo			 0
		_prima_neta,		 -- prima_neta       0
		0,          	     -- impuesto		 0
		0,       			 -- prima_bruta		 0
		0,			         -- reasegurada		 0
		_vigencia_inic,      -- vigencia_inic	 
		_vigencia_final,	 -- vigencia_final	 null
		0,					 -- beneficio_max	 0
		null,		         -- desc_unidad		 null
		1,					 -- activo
		0,					-- prima_asegurado	 0
		0,					 -- prima_total		 0
		null,				 -- no_activo_desde	 null
		1,					 -- facturado
		null,				 -- user_no_activo	 null
		0,					 -- perd_total		 0
		0,					 -- impreso			 0
		_fecha_hoy,			 -- fecha_emision
		_prima_neta,		 -- prima_suscrita
		_prima_neta,		 -- prima_retenida
		0,					 -- eliminada		 null 0
		null,				 -- suma_aseg_adic	 null 0
		_tipo_incendio,		-- tipo_incendio	 null
		_cont_beneficio,
		_cod_manzana);

-- Descripcion de la Unidad
insert into emipode2
		(no_poliza,
		no_unidad,
		descripcion)
 select first 1 _no_poliza,
		'00001',
		descripcion
   from prddesc
  where cod_producto = _cod_producto;

-- Insercion de las Tablas de Soda y Automovil
if _ramo_sis = 1 then

	let _no_motor = 'ASSA' || trim(_no_poliza_coaseg);
	let _anio_auto = 2010;
	let _capacidad = 5;
	let _no_chasis = null;
	let _vin = null;
	let _placa = 'N/C';

	let _anio_actual = year(today);
	let _anio_tarifa = _anio_actual - _anio_auto + 1;
	
	let _cod_color = '001';
	let _cod_marca = '00251';
	let _cod_modelo = '02226';

	if _anio_tarifa <= 1 then
	  --let _anio_tarifa = 1;
		let _auto_nuevo = 1;
	else
		let _auto_nuevo = 0;
	end if

	select count(*)
	  into _cnt_auto
	  from emivehic
	 where no_motor = _no_motor;

	if _cnt_auto = 0 then
		call sp_sis178(_placa) returning _placa;
		insert into emivehic(
				no_motor,
				cod_color,
				cod_marca,
				cod_modelo,
				valor_auto,
				valor_original,
				ano_auto,
				no_chasis,
				vin,
				placa,
				placa_taxi,
				nuevo,
				user_added,
				date_added,
				capacidad)
		values	(_no_motor,
				_cod_color,
				_cod_marca,										   
				_cod_modelo,									   
				_suma_asegurada,
				0.00,
				_anio_auto,
				_no_chasis,
				_vin,
				_placa,
				null,
				_auto_nuevo,
				a_usuario,
				_fecha_hoy,
				_capacidad);
	else
		update emivehic
		   set valor_auto = _suma_asegurada
		 where no_motor = _no_motor;
	end if 

	let _cod_tipoveh = '009';

	insert into emiauto																						  	
		   (no_poliza,
		   	no_unidad,
		   	cod_tipoveh,
		   	no_motor,
		   	uso_auto,
		   	ano_tarifa,
		   	subir_bo
		   )
	 values(_no_poliza,
	 		'00001',
	 		_cod_tipoveh,		--??????????
	 		_no_motor,
	 		_uso_auto,
	 		_anio_tarifa,
	 		0);
elif _ramo_sis in (2,8) then
	let _prima_incendio = _prima_neta;
	let _prima_terremoto = 0.00;

	-- Cumulos de Incendio
	insert into emicupol(
			no_poliza,
			no_unidad,
			cod_ubica,
			suma_incendio,
			suma_terremoto,
			prima_incendio,
			prima_terremoto)
	values(	_no_poliza,
			_no_unidad,
			_cod_ubica,
			0.00,
			0.00,
			_prima_incendio,
			_prima_terremoto);
end if

--Cargar las coberturas de la Unidad
call sp_pro552(_no_poliza, _no_unidad) returning _error,_error_desc;

if _error <> 0 then
	return _error,_error_desc;
end if

--Cargar el Reaseguro Individual de la Unidad
call sp_sis107a(_no_poliza)	returning _error,_error_desc;

if _error <> 0 then
	return _error,_error_desc;
end if

--Actualizar los valores en las unidades
call sp_proe02(_no_poliza, "00001", _cod_compania) returning li_return;

if li_return = 0 then
	let li_return = sp_proe03(_no_poliza,_cod_compania);
	if li_return <> 0 then
		return li_return,_error_desc;
	end if
else
	return li_return,_error_desc;
end if

call sp_proe03(_no_poliza,'001') returning li_return;

if li_return <> 0 then
	return li_return,'Error al Emitir la Póliza ';
end if

-- Actualización de la Póliza
call sp_pro374 (_no_poliza) returning _error,_error_isam,_error_title,_error_desc;

if _error <> 0 then
	return _error,_error_desc;
end if

update emicacoami
   set no_documento = _no_documento
 where cod_coasegur = a_cod_coasegur
   and num_carga = a_num_carga
   and renglon = a_renglon;
end

return 0,_no_poliza;
end procedure;
