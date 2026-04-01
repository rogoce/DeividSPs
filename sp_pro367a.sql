-- Procedimiento que Realiza la insercion a la tabla de Emision, Proceso de Emisiones Electronicas.
-- Creado    : 21/08/2012 - Autor: Roman Gordon 

drop procedure sp_pro367a;

create procedure "informix".sp_pro367a(
v_usuario		char(8),
v_cod_agente	char(5),
v_num_carga		char(10),
v_no_documento	char(20),
v_codcompania	char(3),
v_codagencia	char(3)
)
returning	integer,
			char(100);

--- actualizacion de polizas

define ls_ded						varchar(50);
define _desclimite1					varchar(50);
define _desclimite2					varchar(50);
define _cedula_contratante			varchar(30);
define _error_title					varchar(30);
define _pasaporte					varchar(30);
define _cedula						varchar(30);
define _ruc							varchar(30);
define _observaciones				char(250);
define _direccion_cobros			char(100);
define _razon_social				char(100);
define _cliente_nom					char(100);
define _error_desc					char(100);
define _direccion					char(100);
define _cliente_ape_seg				char(50);
define _conductor_nom				char(50);
define _conductor_ape				char(50);
define _beneficiario1				char(50);
define _beneficiario2				char(50);
define _beneficiario3				char(50);
define _beneficiario4				char(50);
define _nom_edificio				char(50);
define _observacion					char(50);
define _cliente_ape					char(50);
define _e_mail						char(50);
define _no_chasis					char(30);
define _no_motor					char(30);
define _placa						char(30); 
define _vin							char(30);
define _cliente_ape_casada			char(20);
define _responsable_cobro			char(20);
define _cod_contratante				char(10);
define v_poliza_nuevo				char(10);
define _estado_civil				char(10);
define v_codcliente					char(10);
define _cod_depend					char(10);
define _telefono1					char(10);
define _telefono2					char(10);
define _celular						char(10);
define _usuario_eval				char(8);
define v_usuario_r					char(8);
define _periodo						char(7);
define _asiento						char(7);
define _tomo						char(7);
define _cod_cobertura				char(5);
define _cod_producto				char(5);
define _codcobertura				char(5);
define _cod_contrato				char(5);
define _cod_acreedor				char(5);
define _codproducto					char(5);
define _exclusion1					char(5);
define _exclusion2					char(5);
define _exclusion3					char(5);
define _cod_modelo					char(5);
define _no_unidad					char(5);
define _cod_ruta					char(5);
define _cod_parentesco				char(3);
define _cod_descuento				char(3);
define ls_cod_perpago				char(3);
define v_codformapago				char(3);
define _cod_ocupacion				char(3);
define _cod_formapag				char(3);
define v_codtipocalc				char(3);
define _cod_sucursal				char(3);
define _cod_impuesto				char(3);
define _cod_tipoauto				char(3);
define _cod_subramo					char(3);
define _cod_tipoveh					char(3);
define _cod_perpago					char(3);
define _cod_recargo					char(3);
define v_codsubramo					char(3);
define _cod_marca					char(5);
define _cod_color					char(3);
define _cod_ramo					char(3);
define _codtipo						char(3);
define _provincia					char(2);
define _inicial						char(2);
define _tipo_persona				char(1);
define _cobra_poliza				char(1);
define _usandocar					char(1);
define _uso_auto					char(1);
define _sexo						char(1);
define _null						char(1);
define _prima_total_otros_riesgos	dec(16,2);
define _prima_total_transporte		dec(16,2);
define _deducible_comprensivo		dec(16,2);
define _prima_otros_incendio		dec(16,2);
define _limite_comprensivo1			dec(16,2);
define _limite_comprensivo2			dec(16,2);
define _prima_lesiones_corp			dec(16,2);
define _limite_gastos_med2			dec(16,2);
define _limite_gastos_med1			dec(16,2);
define _saldo_con_impuesto			dec(16,2);
define _deducible_colision			dec(16,2);
define _porc_desc_tarjeta			dec(16,2);
define _prima_comprensivo			dec(16,2);
define _tarjeta_descuento			dec(16,2);
define _limite_colision1			dec(16,2);
define _limite_colision2			dec(16,2);
define _limite_lesiones1			dec(16,2);
define _limite_lesiones2			dec(16,2);
define _prima_gastos_med			dec(16,2);
define _prima_terremoto				dec(16,2);
define _mercancia_desde				dec(16,2);
define _mercancia_hasta				dec(16,2);
define _prima_explosion				dec(16,2);
define _prima_asegurado				dec(16,2);
define _descuentoflota				dec(16,2);
define _impuesto_saldo				dec(16,2);
define _prima_colision				dec(16,2);
define _suma_asegurada				dec(16,2);
define _prima_sin_desc				dec(16,2);
define _prima_vendabal				dec(16,2);
define _suma_contenido				dec(16,2);
define _porc_descuento				dec(16,2);
define _valororiginal				dec(16,2);
define _totprimaanual				dec(16,2);
define _totprimabruta				dec(16,2);
define _limite_danos1				dec(16,2);
define _limite_danos2				dec(16,2);
define _porc_impuesto				dec(16,2);
define _suma_edificio				dec(16,2);
define _tot_impuesto				dec(16,2);
define _recargototal				dec(16,2);
define _descuentoesp				dec(16,2);
define _totprimaneta				dec(16,2);
define _suma_decimal				dec(16,2);
define _excl_fumador				dec(16,2);
define _descuentobe					dec(16,2);
define _valoractual					dec(16,2);
define _prima_anual					dec(16,2);
define _prima_bruta					dec(16,2);
define _prima_danos					dec(16,2);
define _primaanual					dec(16,2);
define _primabruta					dec(16,2);
define _suma_difer					dec(16,2);
define _prima_vida					dec(16,2);
define _prima_neta					dec(16,2);
define _primaneta					dec(16,2);
define _excl_peso					dec(16,2);
define _impuestos					dec(16,2);
define _desctotal					dec(16,2);
define _deducible					dec(16,2);
define _descuento					dec(16,2);
define _otras_cob					dec(16,2);
define _limite1						dec(16,2);
define _limite2						dec(16,2);
define _recargo						dec(16,2);
define _monto						dec(16,2);
define _saldo						dec(16,2);
define _porc_partic_prima			dec(9,6);
define _porc_partic_suma			dec(9,6);
define _factorvigencia  			dec(9,2);
define _tarifa						dec(9,2);
define _factor_impuesto				dec(5,2);
define _porc_depre_uni				dec(5,2);
define _porc_depre_pol				dec(5,2);
define _porcdescflota				dec(5,2);
define _porc_comision				dec(5,2);
define _porc_recargod				dec(5,2);
define _porc_recargo				dec(5,2);
define _porcrecargou				dec(5,2);
define _porcdescesp					dec(5,2);
define _porcdescbe					dec(5,2);
define _porc_depre					dec(5,2);
define _tarjeta_credito				smallint;
define _tipo_evaluacion				smallint;
define _cont_beneficio				smallint;
define _indivi_colec				smallint;
define _facultativo					smallint;
define _declarativa					smallint;
define _ano_actual					smallint;
define _error_isam					smallint;
define _auto_nuevo					smallint;
define _ano_tarifa					smallint;
define _aceptadesc					smallint;
define li_no_pagos					smallint;
define _tipo_ramo					smallint;
define _capacidad					smallint;
define _coaseguro					smallint;
define _tipo_doc					smallint;
define _decnuevo					smallint;
define _anosauto					smallint;
define _no_pagos					smallint;
define li_return					smallint;
define _ano_auto					smallint;
define _cnt_auto					smallint;
define _ramo_sis					smallint;
define _tiempo1						smallint;
define _tiempo2						smallint;
define _tiempo3						smallint;
define _retorna						smallint;
define li_meses						smallint;
define _cnt_act						smallint;
define _renglon						smallint;
define _existe						smallint;
define _grupo						smallint;
define r_anos						smallint;
define li_dia						smallint;
define li_mes						smallint;
define li_ano						smallint;
define _serie						smallint;
define _meses						smallint;
define _orden						smallint;
define _error						smallint;
define _unidad						smallint;
define v_cotizacion_r				integer;
define _cant_unidades				integer; 
define v_nopagos					integer;
define _anoauto						integer;
define _cadena						integer;
define _fecha_primer_pago			date;
define _fecha_aniversario			date;
define _fecha_registro				date;
define ld_fecha_1_pago				date;
define _vigencia_final				date;
define v_vigenciainic				date;
define _fecha_excl					date;
define v_fecha_r					date;
define _fecha_emision				datetime year to minute;
define _fechainicio					datetime year to minute;
--define _descr						references byte;

--set debug file to "sp_pro367.trc"; 
--trace on;

set lock mode to wait;

let _cod_ocupacion	= '';
let _cod_subramo	= '';
let _cnt_act		= 0;
let _cont_beneficio = 0;
let _porc_recargo	= 0;
let _tarjeta_credito = 0;

begin

on exception set _error,_error_isam,_error_desc
  return _error,_error_desc;
end exception

foreach
Select cod_ramo,					  
	   cod_subramo,					  
	   cod_producto,				  
	   cod_acreedor,				  
	   cod_formapag,				  
	   cod_perpago,					  
	   no_pagos,					  
	   fecha_primer_pago,			  
	   direccion_cobros,			  
	   vigencia_inic,				  
	   vigencia_final,				  
	   cod_contratante,				  
	   cedula_contratante,			  
	   cedula,
	   pasaporte,
	   ruc,
	   cliente_nom,					  
	   cliente_ape,					  
	   cliente_ape_seg,				  
	   cliente_ape_casada,			  
	   tipo_persona,				  
	   fecha_aniversario,			  
	   sexo,						  
	   estado_civil,				  
	   telefono1,					  
	   telefono2,					  
	   celular,						  
	   e_mail,						  
	   cod_ocupacion,				  
	   direccion,					  
	   cod_marca,					  
	   cod_modelo,					  
	   cod_color,					  
	   no_chasis,					  
	   placa,						  
	   no_motor,					  
	   vin,							  
	   ano_auto,					  
	   capacidad,					  
	   uso_auto,					  
	   conductor_nom,
	   conductor_ape,				  
	   prima_sin_desc,				  
	   descuento,					  
	   prima_neta,					  
	   porc_impuesto,				  
	   tot_impuesto,				  
	   prima_bruta,					  
	   fecha_registro,				  
	   saldo,						  
	   impuesto_saldo,				  
	   saldo_con_impuesto,			  
	   responsable_cobro,   		  
	   facultativo,					  
	   declarativa,					  
	   coaseguro,					  
	   prima_vida,					  
	   suma_asegurada,				  
	   suma_edificio,				  
	   suma_contenido,				  
	   nom_edificio,				  
	   mercancia_desde,				  
	   mercancia_hasta,				  
	   beneficiario1,				  
	   beneficiario2,				  
	   beneficiario3,				  
	   beneficiario4,				  
	   prima_lesiones_corp,			  
	   limite_lesiones1,			  
	   limite_lesiones2,			  
	   prima_danos,					  
	   limite_danos1,				  
	   limite_danos2,				  
	   prima_gastos_med,			  
	   limite_gastos_med1,			  
	   limite_gastos_med2,			  
	   prima_comprensivo,			  
	   limite_comprensivo1,			  
	   limite_comprensivo2,			  
	   deducible_comprensivo,		  
	   prima_colision,				  
	   limite_colision1,			  
	   limite_colision2,			  
	   deducible_colision,			  
	   otras_cob,					  
	   prima_explosion,				  
	   prima_terremoto,				  
	   prima_vendabal,				  
	   prima_otros_incendio,		  
	   prima_total_transporte,		  
	   prima_total_otros_riesgos,	  
	   porc_descuento,				  
	   porc_desc_tarjeta,			  
	   tarjeta_descuento,			  
	   observaciones,				  
	   renglon						  
  into _cod_ramo,					  
	   v_codsubramo,	
	   _cod_producto,
	   _cod_acreedor,
	   v_codformapago,
	   _cod_perpago,
	   _no_pagos,
	   _fecha_primer_pago,
	   _direccion_cobros,
	   v_vigenciainic,
	   _vigencia_final,
	   _cod_contratante,
	   _cedula_contratante,
	   _cedula,
	   _pasaporte,
	   _ruc,
	   _cliente_nom,
	   _cliente_ape,
	   _cliente_ape_seg,
	   _cliente_ape_casada,
	   _tipo_persona,
	   _fecha_aniversario,
	   _sexo,
	   _estado_civil,
	   _telefono1,
	   _telefono2,
	   _celular,
	   _e_mail,
	   _cod_ocupacion,
	   _direccion,
	   _cod_marca,
	   _cod_modelo,
	   _cod_color,
	   _no_chasis,
	   _placa,
	   _no_motor,
	   _vin,
	   _ano_auto,
	   _capacidad,
	   _uso_auto,													   
	   _conductor_nom,
	   _conductor_ape,													 
	   _prima_sin_desc,
	   _descuento,
	   _prima_neta,
	   _porc_impuesto,
	   _tot_impuesto,
	   _prima_bruta,
	   _fecha_registro,
	   _saldo,
	   _impuesto_saldo,
	   _saldo_con_impuesto,
	   _responsable_cobro,   
	   _facultativo,
	   _declarativa,
	   _coaseguro,
	   _prima_vida,
	   _suma_asegurada,
	   _suma_edificio,
	   _suma_contenido,
	   _nom_edificio,
	   _mercancia_desde,
	   _mercancia_hasta,
	   _beneficiario1,
	   _beneficiario2,
	   _beneficiario3,
	   _beneficiario4,
	   _prima_lesiones_corp,
	   _limite_lesiones1,
	   _limite_lesiones2,
	   _prima_danos,
	   _limite_danos1,
	   _limite_danos2,
	   _prima_gastos_med,
	   _limite_gastos_med1,
	   _limite_gastos_med2,
	   _prima_comprensivo,
	   _limite_comprensivo1,
	   _limite_comprensivo2,
	   _deducible_comprensivo,
	   _prima_colision,
	   _limite_colision1,
	   _limite_colision2,
	   _deducible_colision,
	   _otras_cob,
	   _prima_explosion,
	   _prima_terremoto,
	   _prima_vendabal,
	   _prima_otros_incendio,
	   _prima_total_transporte,
	   _prima_total_otros_riesgos,
	   _porc_descuento,
	   _porc_desc_tarjeta,
	   _tarjeta_descuento,
	   _observaciones,
	   _renglon
  From prdemielctdet
 Where cod_agente	= v_cod_agente
   and num_carga	= v_num_carga
   and no_documento	= v_no_documento
   and renglon = 1
   --and renglon <> 286
 order by renglon

let _unidad = _renglon + 1;
let _no_unidad = '00000';

if _unidad > 9999 then
	let _no_unidad = _unidad;
elif _unidad > 999 then
	let _no_unidad[2,5] = _unidad;
elif _unidad > 99  then
	let _no_unidad[3,5] = _unidad;
elif _unidad > 9  then
	let _no_unidad[4,5] = _unidad;
else
	let _no_unidad[5,5] = _unidad;
end if

let v_fecha_r      = current;
let v_usuario_r    = v_usuario;
 
select emi_periodo 														   
  into _periodo
  from parparam
 where cod_compania  = v_codcompania;

let r_anos = 0;

if r_anos > 0 then
   let r_anos = r_anos - 1;
else
   let r_anos = 0;
end if

let _serie = year(v_vigenciainic);

let _retorna = 0;

let li_mes = month(v_vigenciainic);
let li_dia = day(v_vigenciainic);
let li_ano = year(v_vigenciainic);

if li_dia = 29 and li_mes = 2 then
	let li_dia = 28;
	let v_vigenciainic = MDY(li_mes, li_dia, li_ano);
end if

let li_ano = year(v_vigenciainic) + 1;

If li_mes = 2 Then
	If li_dia > 28 Then
		let li_dia = 28;
	    let _vigencia_final = MDY(li_mes, li_dia, li_ano);
	End If
End If

let v_poliza_nuevo = '924670';

--let _monto      	= _prima_sin_desc;
let _cod_recargo    = null;

{if v_cod_agente = '00035' then
	let _cod_sucursal = '047';
else
	let _cod_sucursal = '004';
end if}

select ramo_sis
  into _ramo_sis
  from prdramo
 where cod_ramo = _cod_ramo;

select meses
  into _meses
  from cobperpa
 where cod_perpago = _cod_perpago;

let _prima_asegurado = 0;

--Quitarle el impuesto a la prima inicial
begin

let v_codtipocalc = '001';
--let v_nopagos     = 1;

if _cod_subramo is null  or _cod_subramo = '' then
	let _cod_subramo = v_codsubramo;
end if

--Forma de pago
if _responsable_cobro = 'Ducruet' then
	let v_codformapago	= '008';
	let _cobra_poliza	= 3;
elif _responsable_cobro in ('Ancon','Aseguradora') then 
	if _tarjeta_credito = 1 then
		let v_codformapago = '003';	--Tarjeta de credito
		let _cobra_poliza	= 4;
	else
		let v_codformapago = '006';	--Ancon
		let _cobra_poliza	= 2;
	end if
elif _responsable_cobro = 'Semusa' then
	let v_codformapago = '008';	--Ancon
	let _cobra_poliza	= 2;
end if

end

SELECT fecha_primer_pago,
       no_pagos,
	   cod_perpago
  INTO ld_fecha_1_pago,
       li_no_pagos,
	   ls_cod_perpago	
  FROM emipomae
 where no_poliza = v_poliza_nuevo;

if li_no_pagos = 1 then

	select meses
	  into li_meses
	  from cobperpa
	 where cod_perpago = ls_cod_perpago;

	let li_mes = month(ld_fecha_1_pago) + li_meses;
	let li_ano = year(ld_fecha_1_pago);
	let li_dia = day(ld_fecha_1_pago);

	If li_mes > 12 Then
		let li_mes = li_mes - 12;
		let li_ano = li_ano + 1;
	End If

	If li_mes = 2 Then
		If li_dia > 28 Then
			let li_dia = 28;
		End If
	Elif li_mes in (4, 6, 9, 11) Then
		If li_dia > 30 Then
			let li_dia = 30;
		End If
	End If

	let ld_fecha_1_pago = MDY(li_mes, li_dia, li_ano);

	update emipomae
	   set fecha_primer_pago = ld_fecha_1_pago
	 where no_poliza         = v_poliza_nuevo;

end if
foreach
select cod_ruta
  into _cod_ruta
  from emigloco
 where no_poliza = v_poliza_nuevo
   and no_endoso = '00000'
exit foreach;
end foreach

{-- Reaseguro Global
foreach
	 select cod_ruta
	   into _cod_ruta
	   from rearumae
	  where cod_compania = v_codcompania
	    and cod_sucursal = "001" 
		and cod_ramo     = _cod_ramo
		and activo = 1
		and v_vigenciainic between vig_inic and vig_final
	 exit foreach;
end foreach

foreach
	select orden,
		   cod_contrato,
		   porc_partic_prima,
		   porc_partic_suma
	  into _orden,
		   _cod_contrato,
		   _porc_partic_prima,
		   _porc_partic_suma
	  from rearucon
	 where cod_ruta = _cod_ruta

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
			v_poliza_nuevo,
			'00000',
			_orden,
			_cod_contrato,
			_porc_partic_prima,
			_porc_partic_suma,
			0.00,
			0.00,
			_cod_ruta);
end foreach}

{--Impuestos
begin

foreach 
 select cod_impuesto
   into _cod_impuesto
   from prdimsub
  where cod_ramo    = _cod_ramo
    and cod_subramo = _cod_subramo

 select factor_impuesto
   into _factor_impuesto
   from	prdimpue
  where cod_impuesto = _cod_impuesto;

   
	insert into emipolim(
	no_poliza,
	cod_impuesto,
	monto
	)
	values (
	v_poliza_nuevo,	   --no_poliza
	_cod_impuesto,	   --cod_impuesto
	_tot_impuesto
	);
end foreach

end}

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
let v_codcliente = '174984';

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
		cont_beneficios	
		)
values	(
        v_poliza_nuevo,		 -- no_poliza
        _no_unidad,		 	 -- no_unidad
		_cod_ruta,			 -- cod_ruta
		_cod_producto,		 -- cod_producto
		v_codcliente,		 -- cod_asegurado	 null
		_suma_asegurada,	 -- suma_asegurada	 0
		_prima_sin_desc,	 -- prima			 0
		_descuento,			 -- descuento
		0,		 			 -- recargo			 0
		_prima_neta,		 -- prima_neta       0
		0,          	     -- impuesto		 0
		0,       			 -- prima_bruta		 0
		0,			         -- reasegurada		 0
		v_vigenciainic,      -- vigencia_inic	 
		_vigencia_final,	 -- vigencia_final	 null
		0,					 -- beneficio_max	 0
		null,		         -- desc_unidad		 null
		1,					 -- activo
		_prima_asegurado,	 -- prima_asegurado	 0
		0,					 -- prima_total		 0
		null,				 -- no_activo_desde	 null
		1,					 -- facturado
		null,				 -- user_no_activo	 null
		0,					 -- perd_total		 0
		0,					 -- impreso			 0
		v_fecha_r,			 -- fecha_emision
		_prima_neta,		 -- prima_suscrita
		_prima_neta,		 -- prima_retenida
		0,					 -- eliminada		 null 0
		null,				 -- suma_aseg_adic	 null 0
		null,				 -- tipo_incendio	 null
		_cont_beneficio
		);


let _deducible = 0;
let ls_ded     = "";

if _cod_acreedor is not null and _cod_acreedor not in ('','0','99999','01279') then
	insert into emipoacr(
			no_poliza,
			no_unidad,
			cod_acreedor,
			limite)
	values	(v_poliza_nuevo,
			_no_unidad,
			_cod_acreedor,
			_suma_asegurada
			);
end if

--Recargo
if _porc_recargo > 0 then
	foreach
		select cod_recargo
		  into _cod_recargo
		  from emirecar

		exit foreach;
	end foreach

	insert into emiunire(
			    no_poliza,
			    no_unidad,
				cod_recargo,
				porc_recargo)
		 values(
				v_poliza_nuevo,
				_no_unidad,
				_cod_recargo,
				_porc_recargo
			   );
end if

--Descuento
if _porc_descuento > 0 then
	
	foreach
		select cod_descuen
		  into _cod_descuento
		  from emidescu
		
		exit foreach;
	end foreach

	insert into emiunide(
			no_poliza,
			no_unidad,
			cod_descuen,
			porc_descuento
			)
	values	(v_poliza_nuevo,
			_no_unidad,
			_cod_descuento,
			_porc_descuento * 100
			);
end if

{select descripcion
  into _descr
  from prddesc
 where cod_producto = _cod_producto;

if _conductor_nom is null then
	let _conductor_nom = '';
end if

if _conductor_ape is null then
	let _conductor_ape = '';
end if

if _conductor_nom <> '' and _conductor_ape <> '' then
	let _descr = _descr || _conductor_nom || _conductor_ape;
end if}

-- Descripcion de la Unidad

Insert into emipode2
		(no_poliza,
		no_unidad,
		descripcion)
 select first 1 v_poliza_nuevo,
		_no_unidad,
		descripcion
   from prddesc
  where cod_producto = _cod_producto;

-- Insercion de las Tablas de Soda y Automovil
if _ramo_sis = 1 then

	let _ano_actual = year(today);
	let _ano_tarifa = _ano_actual - _ano_auto;

	if _ano_tarifa <= 0 then
		let _ano_tarifa = 1;
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
				_ano_auto,
				_no_chasis,
				_vin,
				_placa,
				null,
				_auto_nuevo,
				v_usuario,
				v_fecha_r,
				_capacidad);
	else
		update emivehic
		   set valor_auto = _suma_asegurada
		 where no_motor = _no_motor;
	end if 

	if _uso_auto = 'T' then
		let _uso_auto = 'C';
	end if
	
	if _cod_subramo = '001' then
		let _cod_tipoveh = '005';
	elif _cod_subramo = '002' then
		let _cod_tipoveh = '008';
	elif _cod_subramo = '005' then
		let _cod_tipoveh = '012';
	end if
	
	if _uso_auto = 'P' then
		let _cod_tipoveh = '005';
	else
		if _cod_producto = '02186' then
			let _cod_tipoveh = '008';
		elif _cod_producto = '02186' then
			let _cod_tipoveh = '009';
		elif _cod_producto = '02186' then
			let _cod_tipoveh = '010';
		end if		
	end if
	
	insert into emiauto																						  	
		   (no_poliza,
		   	no_unidad,
		   	cod_tipoveh,
		   	no_motor,
		   	uso_auto,
		   	ano_tarifa,
		   	subir_bo
		   )
	 values(v_poliza_nuevo,
	 		_no_unidad,
	 		_cod_tipoveh,		--??????????
	 		_no_motor,
	 		_uso_auto,
	 		_ano_tarifa,
	 		0);
end if

update prdemielctdet
   set actualizado	= 1,
	   emitir		= 0,
	   no_poliza	= v_poliza_nuevo	
 where cod_agente	= v_cod_agente
   and num_carga	= v_num_carga
   and no_documento	= v_no_documento;
   
select count(*)
  into _cnt_act
  from prdemielctdet
 where cod_agente	= v_cod_agente
   and num_carga	= v_num_carga
   and actualizado	= 0;

if _cnt_act = 0 then
	update prdemielect
	   set error = 2
	 where cod_agente	= v_cod_agente
	   and num_carga	= v_num_carga;
end if

--Cargar el Reaseguro Individual de la Unidad
call sp_sis107a(v_poliza_nuevo)	returning _error,_error_desc;

if _error <> 0 then
	return _error,_error_desc;
end if
--Cargar las Coberturas de la Unidad
call sp_pro368_esp(v_cod_agente, v_num_carga, _renglon, v_poliza_nuevo,_no_unidad) returning _error;

if _error <> 0 then
	return _error,_error_desc;
end if
--Actualizar los valores en las unidades
call sp_proe02(v_poliza_nuevo, "00001", v_codcompania) returning li_return;

if li_return = 0 then
	let li_return = sp_proe03(v_poliza_nuevo,v_codcompania);
	if li_return <> 0 then
		return li_return,_error_desc;
	end if
else
	return li_return,_error_desc;
end if

call sp_proe03(v_poliza_nuevo,'001') returning li_return;

if li_return <> 0 then
	return li_return,'Error al Emitir la Póliza ';
end if

-- Actualización de la Póliza
--call sp_pro374 (v_poliza_nuevo) returning _error,_error_isam,_error_title,_error_desc;
{if _unidad > 4 then
	exit foreach;
end if}

if _error <> 0 then
	return _error,_error_desc;
end if
end foreach
end

return 0,v_poliza_nuevo;
end procedure;
