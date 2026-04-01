-- Procedimiento que Realiza la insercion a la tabla de Emision, Proceso de Evaluacion.

-- Creado    : 14/03/2003 - Autor: Amado Perez  

drop procedure sp_sis142;
create procedure sp_sis142(v_usuario char(8), v_no_evaluacion char(10), v_codcompania char(3), v_codagencia char(3))
RETURNING INTEGER;

DEFINE r_anos          smallint;
DEFINE _porc_depre     DEC(5,2);
DEFINE _porc_depre_uni DEC(5,2);
DEFINE _porc_depre_pol DEC(5,2);
DEFINE _no_unidad      CHAR(5); 
DEFINE _cod_cobertura  CHAR(5); 
DEFINE _cod_producto   CHAR(5); 
DEFINE _valor_asignar  CHAR(1); 
DEFINE _periodo		   CHAR(7);
DEFINE _cant_unidades  INTEGER; 
DEFINE _suma_asegurada INTEGER;
DEFINE _no_motor       CHAR(30);
DEFINE _suma_decimal   DEC(16,2);
DEFINE _suma_difer	   DEC(16,2);

DEFINE li_dia		   SMALLINT;
DEFINE li_mes		   SMALLINT;
DEFINE li_ano		   SMALLINT;
DEFINE ld_fecha_1_pago DATE;
DEFINE li_no_pagos	   SMALLINT;
DEFINE ls_cod_perpago  CHAR(3);
DEFINE li_meses		   SMALLINT;
DEFINE _cotizacion     CHAR(10);
DEFINE _cod_impuesto   CHAR(3);
DEFINE _factor_impuesto DEC(5,2);
DEFINE _serie          SMALLINT;
DEFINE _meses          SMALLINT;

DEFINE _unidad	       CHAR(5);
DEFINE _unidadcadena   CHAR(5);
DEFINE _unidad_key     CHAR(5);
DEFINE _decnuevo       SMALLINT; 
DEFINE _anoauto        INTEGER; 
DEFINE _codmarca, _cod_ruta, _codproducto CHAR(5);
DEFINE _codmodelo      CHAR(5);
DEFINE _codtipo        CHAR(3);
DEFINE _capacidad      SMALLINT;
DEFINE _peso           CHAR(20);
DEFINE _nromotor       CHAR(50);
DEFINE _anosauto  	   SMALLINT;
DEFINE _valororiginal  DEC(16,2);
DEFINE _valoractual    DEC(16,2);
DEFINE _nrochasis, _observacion  CHAR(50);
DEFINE _placa          CHAR(30); 
DEFINE _usandocar      CHAR(1);
DEFINE _vin            CHAR(30);
DEFINE _codacreedor    CHAR(5);
DEFINE _porcdescbe	   DEC(5,2);
DEFINE _porcdescflota  DEC(5,2);
DEFINE _porcdescesp    DEC(5,2);
DEFINE _porcrecargou   DEC(5,2);
DEFINE _totprimaanual  DEC(16,2);
DEFINE _totprimabruta  DEC(16,2);
DEFINE _totprimaneta   DEC(16,2);
DEFINE _descuentobe	   DEC(16,2);
DEFINE _descuentoflota DEC(16,2);
DEFINE _descuentoesp   DEC(16,2);
DEFINE _impuestos	   DEC(16,2);
DEFINE _desctotal	   DEC(16,2);
DEFINE _recargototal   DEC(16,2);
DEFINE _codcobertura    CHAR(5); 
DEFINE _orden, _aceptadesc  SMALLINT;
DEFINE _tarifa          DEC(9,2);
DEFINE _deducible       dec(16,2);
DEFINE _limite1         DEC(16,2);
DEFINE _limite2		    DEC(16,2);
DEFINE _primaanual, _prima_anual DEC(16,2);
DEFINE _primabruta	   DEC(16,2);
DEFINE _descuento	   DEC(16,2);
DEFINE _recargo		   DEC(16,2);
DEFINE _primaneta, _prima_neta  DEC(16,2);
DEFINE _factorvigencia  DEC(9,2);
DEFINE _desclimite1     VARCHAR(50);
DEFINE _desclimite2	    VARCHAR(50);
DEFINE v_cotizacion_r, _cadena  int;
DEFINE v_fecha_r 	    DATE;
DEFINE v_usuario_r      CHAR(8);
define _error           smallint;
DEFINE _fechainicio		datetime year to minute;
DEFINE _fecha_emision	datetime year to minute;
define _porc_comision	dec(5,2);
define v_vigenciainic   date;
define _tipo_ramo       smallint;
define _indivi_colec    smallint;
define _tarjeta_credito smallint;
define v_codagente      char(5);
define v_codramo        char(3);
define v_codsubramo     char(3);
define v_codformapago   char(3);
define v_codtipocalc    char(3);
define v_nopagos        integer;
define v_poliza_nuevo   char(10);
define _cod_subramo     char(3);
define ls_ded           varchar(50);
define _vigencia_final  date;
define li_ramo_sis		smallint;
define _cod_perpago     char(3);
define _monto          	DEC(16,2);
DEFINE v_codcliente     CHAR(10);
define _no_recibo       char(20);
define _prima_asegurado dec(16,2);
define li_return        smallint;
define _exclusion1		char(5);
define _exclusion2		char(5);
define _exclusion3		char(5);
define _exclusion4		char(5);
define _exclusion5		char(5);
define _tiempo1			smallint;
define _tiempo2,_tiempo5			smallint;
define _tiempo3,_tiempo4			smallint;
define _fecha_excl      date;
define _excl_peso		DEC(16,2);
define _excl_fumador	DEC(16,2);
define _porc_recargo    decimal(5,2);
define _cod_recargo     char(3);
define _grupo           smallint;
define _usuario_eval    char(8);
define _porc_recargod	decimal(5,2);
define _cod_depend      char(10);
define _cod_parentesco	char(3);
define _retorna         smallint;
define _cod_sucursal    char(3);
define _cod_contratante  char(10);
define _tipo_evaluacion  smallint;
define _cont_beneficio   smallint;
define _error_desc       char(50);
define _error_isam	     integer;

--set debug file to  "sp_sis142.trc"; 
--trace on;

SET LOCK MODE TO WAIT;

BEGIN

ON EXCEPTION SET _error, _error_isam, _error_desc
  RETURN _error;
END EXCEPTION

LET v_fecha_r      = current;
LET v_usuario_r    = v_usuario;
LET v_vigenciainic = current;
let _usuario_eval  = "";

Select emi_periodo 
  Into _periodo
  From parparam
 Where cod_compania  = v_codcompania;

Let r_anos = 0;
let _suma_asegurada = 0;

If r_anos > 0 Then
   LET r_anos = r_anos - 1;
Else
   LET r_anos = 0;
End If

LET _serie = Year(v_vigenciainic);

LET _retorna = 0;

let li_mes = month(v_vigenciainic);
let li_dia = day(v_vigenciainic);
let li_ano = year(v_vigenciainic);

if li_dia = 29 and li_mes = 2 then
	let li_dia = 28;
	let v_vigenciainic = MDY(li_mes, li_dia, li_ano);

end if

let li_ano = year(v_vigenciainic) + 1;

let _vigencia_final = MDY(li_mes, li_dia, li_ano);

If li_mes = 2 Then
	If li_dia > 28 Then
		let li_dia = 28;
	    let _vigencia_final = MDY(li_mes, li_dia, li_ano);
	End If
End If

LET v_poliza_nuevo = sp_sis13(v_codcompania, 'PRO', '02', 'par_no_poliza');

let _monto      	= 0.00;
let _no_recibo  	= null;
let _exclusion1		= null;
let _exclusion2		= null;
let _exclusion3		= null;
let _exclusion4		= null;
let _exclusion5		= null;

let _tiempo1		= null;
let _tiempo2		= null;
let _tiempo3		= null;
let _cod_recargo    = null;
let _excl_peso		= 0;
let _excl_fumador	= 0;
let _porc_recargo   = 0;
let _porc_recargod  = 0;
let _tipo_evaluacion = 0;
let _cont_beneficio  = 0;

Select tipo_ramo,
       indivi_colec,
	   tarjeta_credito,
	   cod_asegurado,
	   cod_agente,
	   cod_subramo,
	   plan,
	   cod_perpago,
	   monto,
	   suma_asegurada,
	   no_recibo,
	   exclusion1,
	   exclusion2,
	   exclusion3,
	   tiempo1,
	   tiempo2,
	   tiempo3,
	   excl_peso,
	   excl_fumador,
	   grupo,
	   usuario_eval,
	   cod_sucursal,
	   cod_contratante,
	   tipo_evaluacion,
	   exclusion4,
	   exclusion5,
	   tiempo4,
	   tiempo5
  Into _tipo_ramo,
       _indivi_colec,
	   _tarjeta_credito,
	   v_codcliente,
	   v_codagente,
	   _cod_subramo,
	   _codproducto,
	   _cod_perpago,
	   _monto,
	   _suma_asegurada,
	   _no_recibo,
	   _exclusion1,
	   _exclusion2,
	   _exclusion3,
	   _tiempo1,
	   _tiempo2,
	   _tiempo3,
	   _excl_peso,
	   _excl_fumador,
	   _grupo,
	   _usuario_eval,
	   _cod_sucursal,
	   _cod_contratante,
	   _tipo_evaluacion,
	   _exclusion4,
	   _exclusion5,
	   _tiempo4,
	   _tiempo5
  From emievalu
 Where no_evaluacion = v_no_evaluacion;

if _tipo_evaluacion = 3 then	--cont cobertura
	let _cont_beneficio = 1;
else
	let _cont_beneficio = 0;
end if

if _cod_sucursal = "" or _cod_sucursal is null then
	let _cod_sucursal = "001";
end if

let v_codcliente  = Trim(v_codcliente);

if _excl_peso is null then
	let _porc_recargo = 0;
	let _excl_peso    = 0;
end if
if _excl_fumador is null then
	let _porc_recargo = 0;
	let _excl_fumador = 0;
end if

let _porc_recargo = _excl_peso + _excl_fumador;

if v_codagente is null then
	let v_codagente = '00099';
end if

if _cod_contratante is null then
	let _cod_contratante = v_codcliente;
end if

--Sacar el Ramo	y Subramo
if _tipo_ramo = 1 then	   --salud
	let v_codramo = '018';
 	if _indivi_colec = 1 then   --es colectivo
		let v_codsubramo = '012';
	else
		let v_codsubramo = '008';
	end if
		
elif _tipo_ramo = '2' then	  --vida
	if _indivi_colec = 1 then   --es colectivo
		let v_codramo = '016';
		let v_codsubramo = '006';
	else
		let v_codramo = '019';
		let v_codsubramo = '001';
	end if
elif _tipo_ramo = 3 then

 	let v_codramo = '004';
 	if _indivi_colec = 1 then   --es colectivo
		let v_codsubramo = '008';
	else
		let v_codsubramo = '001';
	end if

end if

select ramo_sis
  into li_ramo_sis
  from prdramo
 where cod_ramo = v_codramo;

select meses
  into _meses
  from cobperpa
 where cod_perpago = _cod_perpago;

let _prima_asegurado = 0;

--Quitarle el impuesto a la prima inicial
begin

foreach 
 select cod_impuesto
   into _cod_impuesto
   from prdimsub
  where cod_ramo    = v_codramo
    and cod_subramo = _cod_subramo

 select factor_impuesto
   into _factor_impuesto
   from	prdimpue
  where cod_impuesto = _cod_impuesto;


 let _monto = _monto / ((_factor_impuesto / 100) + 1);

end foreach

--Quitarle el recargo a la prima inicial

if _porc_recargo > 0 then
	let _monto = _monto / ((_porc_recargo / 100) + 1);
end if


If li_ramo_sis = 5 Then	   --Las Polizas de Salud No Pueden Tener Vigencia Despues del 28
	If li_dia > 28 Then
		let li_dia = 28;
	    let _vigencia_final = MDY(li_mes, li_dia, li_ano);
	End If

	if _meses = 0 or _meses = 1 then --30 dias
		let li_mes = li_mes + 1;
	elif _meses = 2 then  --60 dias
		let li_mes = li_mes + 2;
	elif _meses = 3 then  --90 dias
		let li_mes = li_mes + 3;
	elif _meses = 4 then  --120 dias
		let li_mes = li_mes + 4;
	elif _meses = 6 then  --semestral
		let li_mes = li_mes + 6;
	end if

	if li_mes < 13 then
		let li_ano = year(v_vigenciainic);

	else
		let li_mes = li_mes - 12;
		let li_ano = year(v_vigenciainic) + 1;
	end if

    let _vigencia_final = MDY(li_mes, li_dia, li_ano);
	let _prima_asegurado = _monto;

End If

--Forma de pago
if _tarjeta_credito = 1 then
	let v_codformapago = '003';	--Tarjeta de credito
else
	let v_codformapago = '006';	--Ancon
end if
let v_codtipocalc = '001';
let v_nopagos     = 1;

if _cod_subramo is null then
	let _cod_subramo = v_codsubramo;
end if

--Sacarle el impuesto a la prima inicial

end

INSERT INTO emipomae(
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
	   ind_fecha_aprob	 
	   )
       VALUES(
       v_poliza_nuevo,			 --no_poliza
       v_codcompania,			 --cod_compania		 001
	   _cod_sucursal,			 --cod_sucursal
	   _cod_sucursal,			 --sucursal_origen
	   '00001',					 --cod_grupo
	   _cod_perpago,			 --cod_perpago
	   v_codtipocalc,			 --cod_tipocalc
	   v_codramo,   			 --cod_ramo
	   _cod_subramo,			 --cod_subramo
	   v_codformapago,			 --cod_formapag
	   '005',					 --cod_tipoprod
	   _cod_contratante,         --cod_contratante
	   _cod_contratante,	     --cod_pagador
	   null,					 --cod_no_renov		 null
	   _serie,	                 --serie
	   null,					 --no_documento		 null
	   null,					 --no_factura		 null
	   _monto,					 --prima			 0
	   0,						 --descuento
	   0,						 --recargo			 0
	   _monto,					 --prima_neta		 0
	   0,						 --impuesto			 0
	   0,						 --prima_bruta		 0
	   _monto,					 --prima_suscrita
	   0,						 --prima_retenida
	   1,						 --tiene_impuesto	 1
	   v_vigenciainic, 			 --vigencia_inic
	   _vigencia_final,	 		 --vigencia_final	 null
	   v_fecha_r,				 --fecha_suscripcion
	   v_fecha_r,				 --fecha_impresion	 today
	   null,					 --fecha_cancelacion null
	   v_nopagos,				 --no_pagos			 1
	   0,						 --impreso			 0
	   'N',						 --nueva_renov
	   1,						 --estatus_poliza	 1
	   1,						 --direc_cobros
	   0,						 --por_certificado
	   0,						 --actualizado		 0
	   0,						 --dia_cobros1		 0
	   0,						 --dia_cobros2		 0
	   v_vigenciainic,			 --fecha_primer_pago 
	   null,					 --no_poliza_coaseg	 null
	   v_fecha_r,	 			 --date_changed		 today
	   0,						 --renovada			 0
	   v_fecha_r,				 --date_added		 today
	   _periodo,				 --periodo
	   0,						 --carta_aviso_canc	 
	   0,						 --carta_prima_gan	 
	   0,						 --carta_vencida_sal 
	   0,						 --carta_recorderis	 
	   null,					 --fecha_aviso_canc	 null
	   null,					 --fecha_prima_gan	 null
	   null,					 --fecha_vencida_sal null
	   null,					 --fecha_recorderis	 null
	   'E',						 --cobra_poliza		 E
	   'EVALUACI',				 --user_added
	   0,						 --ult_no_endoso	 0
	   0,						 --declarativa
	   0,						 --abierta
	   null,					 --fecha_renov		 null
	   null,					 --fecha_no_renov	 null
	   0,						 --no_renovar		 0
	   0,						 --perd_total		 0
	   0,						 --anos_pagador		 0
	   0,						 --saldo_por_unidad	 0
	   1,						 --factor_vigencia	 0
	   _suma_asegurada,			 --suma_asegurada	 0
	   0,						 --incobrable		 0
	   0,						 --saldo			 0
	   null,					 --fecha_ult_pago	 null
	   null,					 --reemplaza_poliza	 null
	   null,					 --user_no_renov	 null
	   0,					     --posteado			 0
	   null,					 --no_tarjeta		 null
	   null,					 --fecha_exp		 null
	   null,					 --cod_banco		 null
	   null,					 --monto_visa		 null
	   null,					 --tipo_tarjeta		 null
	   _no_recibo, 				 --no_recibo		 null
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
	   null
	   );

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

-- Buscando el % de comision

LET _porc_comision = sp_pro305(v_codagente, v_codramo, _cod_subramo);

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
v_codagente,		--cod_agente
v_poliza_nuevo,		--no_poliza
100,			    --porc_partic_agt
_porc_comision,		--porc_comis_agt
100					--porc_produc
);

foreach
	 select cod_ruta
	   into _cod_ruta
	   from rearumae
	  where cod_compania = v_codcompania
	    and cod_sucursal = "001" 
		and cod_ramo     = v_codramo
		and activo = 1
		and v_vigenciainic between vig_inic and vig_final
	 exit foreach;
end foreach

--impuestos
begin

foreach 
 select cod_impuesto
   into _cod_impuesto
   from prdimsub
  where cod_ramo    = v_codramo
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
	_monto * (_factor_impuesto / 100)
	);
end foreach

end

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
        values (
        v_poliza_nuevo,		 -- no_poliza
        '00001',		 	 -- no_unidad
		_cod_ruta,			 -- cod_ruta
		_codproducto,		 -- cod_producto
		v_codcliente,		 -- cod_asegurado	 null
		_suma_asegurada,	 -- suma_asegurada	 0
		_monto,		 		 -- prima			 0
		0,					 -- descuento
		0,		 			 -- recargo			 0
		_monto,				 -- prima_neta       0
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
		0,					 -- prima_suscrita
		0,					 -- prima_retenida
		0,					 -- eliminada		 null 0
		null,				 -- suma_aseg_adic	 null 0
		null,				 -- tipo_incendio	 null
		_cont_beneficio
		);


let _deducible = 0;
let ls_ded     = "";

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
		   porc_recargo
		   )	
	       values (
	        v_poliza_nuevo,
	        '00001',		 	
	        _cod_recargo,		
	        _porc_recargo       		
			);
end if

if _tipo_ramo = 1 then	--Solo Salud
	if _exclusion1 is not null then

		let li_mes = month(v_vigenciainic);
		let li_dia = day(v_vigenciainic);
		let li_ano = year(v_vigenciainic);

		if li_dia = 31 then
			let li_dia = 30;
		end if

		if _tiempo1 = 1 then 		--Permanente no lleva fecha
			let _fecha_excl = null;
		elif _tiempo1 = 2 then		--Un ano de exclusion
			let li_ano      = year(v_vigenciainic) + 1;
		    let _fecha_excl = MDY(li_mes, li_dia, li_ano);
		elif _tiempo1 = 3 then		--Seis meses de exclusion
			let li_mes = month(v_vigenciainic) + 6;
			if li_mes > 12 then
				let li_mes = li_mes - 12;

				If li_mes = 2 Then
					if li_dia > 28 then
						let li_dia = 28;
					end if
				End If

				let li_ano      = year(v_vigenciainic) + 1;
			    let _fecha_excl = MDY(li_mes, li_dia, li_ano);
			else

				If li_mes = 2 Then
					if li_dia > 28 then
						let li_dia = 28;
					end if
				End If

			    let _fecha_excl = MDY(li_mes, li_dia, li_ano);
			end if 
		end if

		insert into emipreas(
			   no_poliza,
			   no_unidad,
			   cod_procedimiento,
			   fecha,
			   user_added,
			   date_added
			   )	
		       values (
		        v_poliza_nuevo,
		        '00001',		 	
		        _exclusion1,		
		        _fecha_excl,       		
				v_usuario,
				v_fecha_r
				);

	end if
	if _exclusion2 is not null then

		let li_mes = month(v_vigenciainic);
		let li_dia = day(v_vigenciainic);
		let li_ano = year(v_vigenciainic);

		if li_dia = 31 then
			let li_dia = 30;
		end if

		if _tiempo2 = 1 then 		--Permanente no lleva fecha
			let _fecha_excl = null;
		elif _tiempo2 = 2 then		--Un ano de exclusion
			let li_ano      = year(v_vigenciainic) + 1;
		    let _fecha_excl = MDY(li_mes, li_dia, li_ano);
		elif _tiempo2 = 3 then		--Seis meses de exclusion
			let li_mes = month(v_vigenciainic) + 6;
			if li_mes > 12 then
				let li_mes = li_mes - 12;

				If li_mes = 2 Then
					if li_dia > 28 then
						let li_dia = 28;
					end if
				End If

				let li_ano      = year(v_vigenciainic) + 1;
			    let _fecha_excl = MDY(li_mes, li_dia, li_ano);
			else

				If li_mes = 2 Then
					if li_dia > 28 then
						let li_dia = 28;
					end if
				End If

			    let _fecha_excl = MDY(li_mes, li_dia, li_ano);
			end if 
		end if

		insert into emipreas(
			   no_poliza,
			   no_unidad,
			   cod_procedimiento,
			   fecha,
			   user_added,
			   date_added
			   )	
		       values (
		        v_poliza_nuevo,
		        '00001',		 	
		        _exclusion2,		
		        _fecha_excl,       		
				v_usuario,
				v_fecha_r
				);

	end if
	if _exclusion3 is not null then

		let li_mes = month(v_vigenciainic);
		let li_dia = day(v_vigenciainic);
		let li_ano = year(v_vigenciainic);
		if li_dia = 31 then
			let li_dia = 30;
		end if

		if _tiempo3 = 1 then 		--Permanente no lleva fecha
			let _fecha_excl = null;
		elif _tiempo3 = 2 then		--Un ano de exclusion
			let li_ano      = year(v_vigenciainic) + 1;
		    let _fecha_excl = MDY(li_mes, li_dia, li_ano);
		elif _tiempo3 = 3 then		--Seis meses de exclusion
			let li_mes = month(v_vigenciainic) + 6;
			if li_mes > 12 then
				let li_mes      = li_mes - 12;
				If li_mes = 2 Then
					if li_dia > 28 then
						let li_dia = 28;
					end if
				End If
				let li_ano      = year(v_vigenciainic) + 1;
			    let _fecha_excl = MDY(li_mes, li_dia, li_ano);
			else

				If li_mes = 2 Then
					if li_dia > 28 then
						let li_dia = 28;
					end if
				End If

			    let _fecha_excl = MDY(li_mes, li_dia, li_ano);

			end if 
		end if

		insert into emipreas(
			   no_poliza,
			   no_unidad,
			   cod_procedimiento,
			   fecha,
			   user_added,
			   date_added
			   )	
		       values (
		        v_poliza_nuevo,
		        '00001',		 	
		        _exclusion3,		
		        _fecha_excl,       		
				v_usuario,
				v_fecha_r
				);
	end if
	if _exclusion4 is not null then
		let li_mes = month(v_vigenciainic);
		let li_dia = day(v_vigenciainic);
		let li_ano = year(v_vigenciainic);
		if li_dia = 31 then
			let li_dia = 30;
		end if

		if _tiempo4 = 1 then 		--Permanente no lleva fecha
			let _fecha_excl = null;
		elif _tiempo4 = 2 then		--Un ano de exclusion
			let li_ano      = year(v_vigenciainic) + 1;
		    let _fecha_excl = MDY(li_mes, li_dia, li_ano);
		elif _tiempo4 = 3 then		--Seis meses de exclusion
			let li_mes = month(v_vigenciainic) + 6;
			if li_mes > 12 then
				let li_mes      = li_mes - 12;
				If li_mes = 2 Then
					if li_dia > 28 then
						let li_dia = 28;
					end if
				End If
				let li_ano      = year(v_vigenciainic) + 1;
			    let _fecha_excl = MDY(li_mes, li_dia, li_ano);
			else
				If li_mes = 2 Then
					if li_dia > 28 then
						let li_dia = 28;
					end if
				End If
			    let _fecha_excl = MDY(li_mes, li_dia, li_ano);
			end if 
		end if
		insert into emipreas(
			   no_poliza,
			   no_unidad,
			   cod_procedimiento,
			   fecha,
			   user_added,
			   date_added
			   )	
		       values (
		        v_poliza_nuevo,
		        '00001',		 	
		        _exclusion4,		
		        _fecha_excl,       		
				v_usuario,
				v_fecha_r
				);
	end if
	if _exclusion5 is not null then
		let li_mes = month(v_vigenciainic);
		let li_dia = day(v_vigenciainic);
		let li_ano = year(v_vigenciainic);

		if li_dia = 31 then
			let li_dia = 30;
		end if

		if _tiempo5 = 1 then 		--Permanente no lleva fecha
			let _fecha_excl = null;
		elif _tiempo5 = 2 then		--Un ano de exclusion
			let li_ano      = year(v_vigenciainic) + 1;
		    let _fecha_excl = MDY(li_mes, li_dia, li_ano);
		elif _tiempo5 = 3 then		--Seis meses de exclusion
			let li_mes = month(v_vigenciainic) + 6;
			if li_mes > 12 then
				let li_mes      = li_mes - 12;
				If li_mes = 2 Then
					if li_dia > 28 then
						let li_dia = 28;
					end if
				End If
				let li_ano      = year(v_vigenciainic) + 1;
			    let _fecha_excl = MDY(li_mes, li_dia, li_ano);
			else
				If li_mes = 2 Then
					if li_dia > 28 then
						let li_dia = 28;
					end if
				End If
			    let _fecha_excl = MDY(li_mes, li_dia, li_ano);
			end if 
		end if
		insert into emipreas(
			   no_poliza,
			   no_unidad,
			   cod_procedimiento,
			   fecha,
			   user_added,
			   date_added
			   )	
		       values (
		        v_poliza_nuevo,
		        '00001',		 	
		        _exclusion5,		
		        _fecha_excl,       		
				v_usuario,
				v_fecha_r
				);
	end if
	if _grupo = 1 then	--Buscar a los dependientes

		foreach

			select cod_asegurado,
			       cod_parentesco,
				   exclusion1,
				   exclusion2,
				   exclusion3,
				   tiempo1,
				   tiempo2,
				   tiempo3,
				   excl_peso + excl_fumador,
				   exclusion4,
				   exclusion5,
				   tiempo4,
				   tiempo5
			  into _cod_depend,
			       _cod_parentesco,
				   _exclusion1,
				   _exclusion2,
				   _exclusion3,
				   _tiempo1,
				   _tiempo2,
				   _tiempo3,
				   _porc_recargod,
				   _exclusion4,
				   _exclusion5,
				   _tiempo4,
				   _tiempo5
			  from emievade
			 where no_evaluacion = v_no_evaluacion
			   and procesado     = 1

			--Dependientes
			insert into emidepen(
				   no_poliza,
				   no_unidad,
				   cod_cliente,
				   cod_parentesco,
				   activo,
				   prima,
				   user_added,
				   date_added,
				   fecha_efectiva,
				   cont_beneficios,
				   calcula_prima
				   )	
			       values (
			        v_poliza_nuevo,
			        '00001',		 	
			        _cod_depend,		
			        _cod_parentesco,       		
					1,
					0,
					_usuario_eval,
					v_fecha_r,
					v_vigenciainic,
					0,
					0
					);

			--PreExistencia del dependiente.
			let _retorna = sp_sis143(v_poliza_nuevo,'00001',_cod_depend,_exclusion1,_exclusion2,_exclusion3,_tiempo1,_tiempo2,_tiempo3,_usuario_eval,v_vigenciainic,_exclusion4,_exclusion5,
			                         _tiempo4,_tiempo5);

			if _retorna <> 0 then

				Return _retorna;
			else
				if _porc_recargod > 0 then	 --Recargo del dependiente.

					foreach
						select cod_recargo
						  into _cod_recargo
						  from emirecar

						exit foreach;
					end foreach

					let _retorna = sp_sis144(v_poliza_nuevo,'00001',_cod_depend,_cod_recargo,_porc_recargod);

					if _retorna <> 0 then
						Return _retorna;						
					end if

				end if

			end if
		end foreach

	end if

End If

foreach

	select cod_cobertura,
	       orden,
		   desc_limite1,
		   desc_limite2,
		   deducible
	  into _codcobertura,
	       _orden,
		   _desclimite1,
		   _desclimite2,
		   _deducible
	  from prdcobpd
	 where cod_producto = _codproducto

	 let ls_ded = _deducible;

	insert into emipocob(
		   no_poliza,
		   no_unidad,
		   cod_cobertura,
		   orden,
		   tarifa,			
		   deducible,
		   limite_1,		
		   limite_2,		
		   prima_anual,		
		   prima,			
		   descuento,
		   recargo,			
		   prima_neta,		
		   date_added,		
		   date_changed,	
		   factor_vigencia,
		   desc_limite1,	
		   desc_limite2
		   )	
	       values (
	        v_poliza_nuevo,							-- no_poliza
	        '00001',		 						-- no_unidad
	        _codcobertura,							-- cod_cobertura
	        _orden,       							-- orden
	        0,      		 						-- tarifa			 0
	        ls_ded,   		 						-- deducible
	        0,     		 							-- limite_1		 0
	        0,			 							-- limite_2		 0
	        _monto,	 	 							-- prima_anual		 0
	        _monto,	 	 							-- prima			 0
	        0,	 		 							-- descuento
	        _monto * _porc_recargo / 100,			-- recargo			 0
			_monto + (_monto * _porc_recargo / 100),  -- prima_neta		 0
			v_fecha_r,								-- date_added		 today
			v_fecha_r,								-- date_changed	 today
			1,										-- factor_vigencia	 0
			_desclimite1,   						-- desc_limite1	 null
			_desclimite2							-- desc_limite2	 null
			);
		   let _monto = 0.00;
end foreach

CALL sp_proe02(v_poliza_nuevo, "00001", v_codcompania) RETURNING li_return;

if li_return = 0 then
	let li_return = sp_proe03(v_poliza_nuevo,v_codcompania);

else
	return li_return;
end if

update emievalu
   set no_poliza     = v_poliza_nuevo,
       decicion      = 1
 where no_evaluacion = v_no_evaluacion;

END
RETURN 0;
end procedure;
