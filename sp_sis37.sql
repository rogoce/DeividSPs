-- Procedimiento que Realiza la Carga a las tablas de Emision desde Cotizacion

-- Creado    : 14/03/2003 - Autor: Amado Perez  
-- Modificado: 02/10/2012 - Autor: Amado Perez, se puedan crear registros cono sin informacion del auto 

drop procedure sp_sis37;

create procedure "informix".sp_sis37(
v_usuario      char(8), 
v_cotizacion   int, 
v_poliza_nuevo char(10),
v_codramo      char(3),
v_codsubramo   char(3),
v_codagente    char(5),
v_codtipocalc  char(3),
v_codtipodesc  char(3),
v_codformapago char(3),
v_codperpago   char(3),
v_factorvigencia dec(5,2),
v_vigenciainic date,
v_vigenciafinal date,
v_nopagos      smallint,
v_codcompania  char(3),
v_codagencia   char(3),
v_codcliente   char(10))
RETURNING INTEGER;

--}

--- Actualizacion de Polizas

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

DEFINE _unidad	       CHAR(5);
DEFINE _unidadcadena   CHAR(5);
DEFINE _unidad_key     CHAR(5);
DEFINE _decnuevo       SMALLINT; 
DEFINE _anoauto       INTEGER; 
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
DEFINE _deducible       VARCHAR(50);
DEFINE _limite1         DEC(16,2);
DEFINE _limite2		   DEC(16,2);
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
define _v               smallint;
define _valor_parametro VARCHAR(50);
define _sum_descuento   dec(16,2);

DEFINE _codcolor        char(3);
DEFINE _transmision     integer;
DEFINE _tipo_motor      varchar(50);
define _tamano          varchar(50);
DEFINE _num_pasajeros   integer;
DEFINE _tipo_auto       integer;
define _frenos          char(3);
define _air_bag         char(3);
define _tam_rines       integer;
define _kilome          integer;
define _nombre_marca    varchar(30);
define _nombre_modelo   varchar(30);
define _cant            smallint;
define _desc_comb       dec(16,2);
define _desc_modelo     dec(16,2);
define _desc_vehic      dec(16,2);
define _desc_edad       dec(16,2);
define _desc_pr_tipov   dec(16,2);

IF v_cotizacion = 233987 THEN 
	SET DEBUG FILE TO "sp_sis37.trc"; 
	trace on;
END IF

SET LOCK MODE TO WAIT;

BEGIN

ON EXCEPTION SET _error
  RETURN _error;
END EXCEPTION

let _codcolor        = '001';
let _transmision     = null;
let _tipo_motor      = null;
let _tamano          = null;
let _num_pasajeros   = null;
let _tipo_auto       = null;
let _frenos          = null;
let _air_bag         = null;
let _tam_rines       = null;
let _kilome          = null;
let _nombre_marca    = null;
let _nombre_modelo   = null;

LET v_cotizacion_r = v_cotizacion;
LET v_fecha_r = current;
LET v_usuario_r = v_usuario;

INSERT INTO wf_cotizallave
VALUES (v_cotizacion_r,
 		v_fecha_r,
		v_usuario_r,
		0
	   );

Select emi_periodo 
  Into _periodo
  From parparam
 Where cod_compania  = v_codcompania;


Let r_anos = 0;
Let _cotizacion = v_cotizacion;


{select x.anos_pagador 
  Into r_anos 
  from prueba x
 where x.no_poliza    = v_poliza;}

If r_anos > 0 Then
   LET r_anos = r_anos - 1;
Else
   LET r_anos = 0;
End If

LET _serie = Year(v_vigenciainic);

If v_codcliente is null or v_codcliente = '' Then
   let v_codcliente = '00348';
Else 
   let v_codcliente = Trim(v_codcliente); 
End If

Select fechainicio,
       fecha_emision
  Into _fechainicio,
	   _fecha_emision
  From wf_db_autos
 Where nrocotizacion = v_cotizacion;

--Agregue esto para que adicionara el nopagos desde cotizacion, siempre ponia 1.  Armando Moreno 25/01/2012
foreach

	select nopagos
	  into v_nopagos
	  from wf_cotizacion
	 Where nrocotizacion = v_cotizacion

	exit foreach;

end foreach

if v_nopagos = 0 then
	let v_nopagos = 1;
end if

let v_codformapago = v_codformapago; 

if v_codformapago is null or trim(v_codformapago) = "" or trim(v_codformapago) = "001" then -- Ahora no vendra esta informacion
	let v_codformapago = '006';
end if

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
	   v_codagencia,			 --cod_sucursal
	   v_codagencia,			 --sucursal_origen
	   '00001',					 --cod_grupo
	   v_codperpago,			 --cod_perpago
	   v_codtipocalc,			 --cod_tipocalc
	   v_codramo,   			 --cod_ramo
	   v_codsubramo,			 --cod_subramo
	   v_codformapago,			 --cod_formapag		v_codformapago
	   '005',					 --cod_tipoprod
	   v_codcliente,             --cod_contratante
	   v_codcliente,		     --cod_pagador
	   null,					 --cod_no_renov		 null
	   _serie,	                 --serie
	   null,					 --no_documento		 null
	   null,					 --no_factura		 null
	   0,						 --prima			 0
	   0,						 --descuento
	   0,						 --recargo			 0
	   0,						 --prima_neta		 0
	   0,						 --impuesto			 0
	   0,						 --prima_bruta		 0
	   0,						 --prima_suscrita
	   0,						 --prima_retenida
	   1,						 --tiene_impuesto	 1
	   v_vigenciainic, 			 --vigencia_inic
	   v_vigenciafinal,			 --vigencia_final	 null
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
	   v_usuario,				 --user_added
	   0,						 --ult_no_endoso	 0
	   0,						 --declarativa
	   0,						 --abierta
	   null,					 --fecha_renov		 null
	   null,					 --fecha_no_renov	 null
	   0,						 --no_renovar		 0
	   0,						 --perd_total		 0
	   0,						 --anos_pagador		 0
	   0,						 --saldo_por_unidad	 0
	   v_factorvigencia,		 --factor_vigencia	 0
	   0,						 --suma_asegurada	 0
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
	   null,					 --no_recibo		 null
	   null,					 --no_cuenta		 null
	   null,					 --tipo_cuenta		 null
	   null,					 --gestion			 null
	   null,					 --fecha_gestion	 null
	   null,					 --dia_cobro_anterior 0
	   null,					 --incentivo		 0
	   '001',					 --cod_origen		 null
	   _cotizacion,				 --cotizacion		 null
	   1,						 --de_cotizacion	 0
	   _fechainicio,
	   _fecha_emision						 
	   );


 -- Buscando la Ruta

 select valor_parametro
   into _valor_parametro
   from inspaag	a
  where a.codigo_compania = '001'
    and a.codigo_agencia = '001'
	and a.aplicacion = "PRO"
	and a.version = "02"
	and a.codigo_parametro = "ruta_vigencia"; 

if Trim(_valor_parametro) = "1" then
 foreach
	  SELECT a.cod_ruta   
	    INTO _cod_ruta 
	    FROM rearumae a 
	   WHERE ( a.cod_compania = v_codcompania ) AND  
	         ( a.cod_ramo = v_codramo ) AND  
	         ( v_vigenciainic between a.vig_inic and a.vig_final ) AND  
	         ( a.activo = 1 )   
	   ORDER BY a.cod_ruta ASC   
	exit foreach;
 end foreach
else
 foreach
	 select cod_ruta
	   into _cod_ruta
	   from rearumae
	  where cod_compania = v_codcompania
	    and cod_sucursal = "001" 
		and cod_ramo = v_codramo
		and serie = _serie
	 exit foreach;
 end foreach
end if

SELECT fecha_primer_pago,
       no_pagos,
	   cod_perpago
  INTO ld_fecha_1_pago,
       li_no_pagos,
	   ls_cod_perpago	
  FROM emipomae
 where no_poliza = v_poliza_nuevo;

{if li_no_pagos = 1 then

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
	 where no_poliza = v_poliza_nuevo;

end if
}
-- Buscando el % de comision

LET _porc_comision = sp_pro305(v_codagente, v_codramo);

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

begin

foreach 
 select cod_impuesto
   into _cod_impuesto
   from prdimsub
  where cod_ramo = v_codramo
    and cod_subramo = v_codsubramo

 select factor_impuesto
   into _factor_impuesto
   from	prdimpue
  where cod_impuesto = _cod_impuesto;

  select sum(totprimabruta),
         sum(desctotal),
		 sum(recargototal)
	into _totprimabruta,
		 _desctotal,
		 _recargototal
	from wf_autos
   where nrocotizacion = v_cotizacion;
    
	insert into emipolim(
	no_poliza,
	cod_impuesto,
	monto
	)
	values (
	v_poliza_nuevo,	   --no_poliza
	_cod_impuesto,	   --cod_impuesto
	(_totprimabruta + _recargototal - _desctotal) * _factor_impuesto / 100	--monto   0
	);
end foreach
end

let _v = 0;
/**/
 select count(*)
   into _cant
   FROM insp_cot_pend
  where no_cotizacion = cast(v_cotizacion as varchar(10));
	if _cant = 1 then
		SELECT cod_marca,
			   nombre_marca,
			   cod_modelo,
			   nombre_modelo, 
			   ano, 
			   no_motor, 
			   placa,
			   no_chasis,
			   cod_color,
			   transmision,
			   tipo_motor,
			   tamano,
			   num_pasajeros,
			   tipo_auto,
			   frenos, 
			   air_bag, 
			   tam_rines, 
			   kilome
		  into _codmarca,
			   _nombre_marca,
			   _codmodelo,
			   _nombre_modelo,
			   _anoauto,
			   _nromotor,
			   _placa,
			   _nrochasis,
			   _codcolor,
			   _transmision,
			   _tipo_motor,
			   _tamano,
			   _num_pasajeros,
			   _tipo_auto,
			   _frenos, 
			   _air_bag, 
			   _tam_rines, 
			   _kilome
		  FROM insp_cot_pend
		 where no_cotizacion = cast(v_cotizacion as varchar(10));
		 
		 if _codcolor is null or trim(_codcolor) = "" then
			let _codcolor = '001';
		 end if
		 
		 update wf_autos
			set codmarca  = _codmarca,
				marca     = _nombre_marca,
				codmodelo = _codmodelo,
				modelo    = _nombre_modelo,
				anoauto   = _anoauto,
				nromotor  = _nromotor,
				placa     = _placa,
				nrochasis = _nrochasis,
				capacidad = _num_pasajeros
		  WHERE nrocotizacion = v_cotizacion;
	end if
/**/
begin
foreach
 select unidad,
        decnuevo,
		anoauto,
		codmarca,
		codmodelo,
		codtipo,
		capacidad,
		peso,
		nromotor,
		anosauto,
		valororiginal,
		valoractual,
		nrochasis,
		placa,
		usandocar,
		vin,
		codacreedor,
		porcdescbe,
		porcdescflota,
		porcdescesp,
		porcrecargou,
		totprimaanual,
		totprimabruta,
		totprimaneta,
		descuentobe,
		descuentoflota,
		descuentoesp,
		impuestos,
		desctotal,
		recargototal,
		observacion
   INTO _unidad,
		_decnuevo,
		_anoauto,
		_codmarca,
		_codmodelo,
		_codtipo,
		_capacidad,
		_peso,
		_nromotor,
		_anosauto,
		_valororiginal,
		_valoractual,
		_nrochasis,
		_placa,
		_usandocar,
		_vin,
		_codacreedor,
		_porcdescbe,
		_porcdescflota,
		_porcdescesp,
		_porcrecargou,
		_totprimaanual,
		_totprimabruta,
		_totprimaneta,
		_descuentobe,
		_descuentoflota,
		_descuentoesp,
		_impuestos,
		_desctotal,
		_recargototal,
		_observacion
	FROM wf_autos
   WHERE nrocotizacion = v_cotizacion

   if v_cotizacion = 66593 then
	   if _v = 0 then
		   let _v = 1;
	   else
		 exit foreach;
	   end if
   end if
 if _valororiginal is null then
 	let _valororiginal = 0;
 end if

 if _valoractual is null then
 	let _valoractual = 0;
 end if
 if _porcdescbe is null then
 	let _porcdescbe = 0;
 end if

 if _porcdescflota is null then
 	let _porcdescflota = 0;
 end if
 
 if _porcdescesp is null then
 	let _porcdescesp = 0;
 end if

 if _porcrecargou is null then
 	let _porcrecargou = 0;
 end if
 
 if _totprimaanual is null then
 	let _totprimaanual = 0;
 end if
 
 if _totprimabruta is null then
 	let _totprimabruta = 0;
 end if

 if _totprimaneta is null then
 	let _totprimaneta = 0;
 end if

 if _descuentobe is null then
 	let _descuentobe = 0;
 end if

 if _descuentoflota is null then
 	let _descuentoflota = 0;
 end if

 if _descuentoesp is null then
 	let _descuentoesp = 0;
 end if

 if _impuestos is null then
 	let _impuestos = 0;
 end if

 if _desctotal is null then
 	let _desctotal = 0;
 end if

 if _recargototal is null then
 	let _recargototal = 0;
 end if

 if _capacidad is null then
 	let _capacidad = 0;
 end if


 let _cadena = _unidad;
 let _unidadcadena = "00000";

 if _cadena > 9999  then
	let _unidadcadena[1,5] = _cadena;
 elif _cadena > 999 then
	let _unidadcadena[2,5] = _cadena;
 elif _cadena > 99  then
	let _unidadcadena[3,5] = _cadena;
 elif _cadena > 9   then
	let _unidadcadena[4,5] = _cadena;
 else
	let _unidadcadena[5,5] = _cadena;
 end if

 let _unidad_key = TRIM(_unidadcadena);

 foreach
	 select codproducto
	   into _codproducto
	   from wf_coberturas
	  where nrocotizacion = v_cotizacion
	    and nrounidad = _unidad
	 exit foreach;
 end foreach

let _sum_descuento = 0.00;

select sum(descuento)
  into _sum_descuento
  from wf_coberturas
 where nrocotizacion = v_cotizacion
   and nrounidad = _unidad;

if _sum_descuento is null then
	let _sum_descuento = 0.00;
end if
	   		
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
		tipo_incendio	
		)
        values (
        v_poliza_nuevo,		 -- no_poliza
        _unidad_key,		 -- no_unidad
		_cod_ruta,			 -- cod_ruta
		_codproducto,		 -- cod_producto
		v_codcliente,		 -- cod_asegurado	 null
		_valoractual,		 -- suma_asegurada	 0
		_totprimabruta,		 -- prima			 0
		_descuentobe + _descuentoflota + _descuentoesp + _sum_descuento,	-- descuento
		_recargototal,		 -- recargo			 0
		_totprimabruta + _recargototal - (_descuentobe + _descuentoflota + _descuentoesp + _sum_descuento), -- prima_neta   0
		_impuestos,          -- impuesto		 0
		_totprimaneta,       -- prima_bruta		 0
		0,			         -- reasegurada		 0
		v_vigenciainic,      -- vigencia_inic	 
		v_vigenciafinal,	 -- vigencia_final	 null
		0,					 -- beneficio_max	 0
		_observacion,		 -- desc_unidad		 null
		1,					 -- activo
		0,					 -- prima_asegurado	 0
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
		null				 -- tipo_incendio	 null
		);

if _codacreedor is not null and _codacreedor <> "" and _codacreedor <> "0" THEN
	insert into emipoacr(
	no_poliza,
    no_unidad,
    cod_acreedor,
	limite
	)
	values (
	v_poliza_nuevo,	 -- no_poliza
	_unidad_key,	 -- no_unidad
	_codacreedor,	 -- cod_acreedor
	0				 -- limite
	);
end if

if _porcdescbe is not null and _porcdescbe <> 0 THEN
	insert into emiunide(
	no_poliza,
    no_unidad,
    cod_descuen,
    porc_descuento
	)
	values (
	v_poliza_nuevo,	 -- no_poliza
	_unidad_key,	 -- no_unidad
	'001',			 -- cod_descuen
	_porcdescbe
	);	 -- 0
end if
if _porcdescflota is not null and _porcdescflota <> 0 THEN
	insert into emiunide(
	no_poliza,
    no_unidad,
    cod_descuen,
    porc_descuento
	)
	values (
	v_poliza_nuevo,	 -- no_poliza
	_unidad_key,	 -- no_unidad
	'002',			 -- cod_descuen
	_porcdescflota); -- 0
end if
if _porcdescesp is not null and _porcdescesp <> 0 THEN
	insert into emiunide(
	no_poliza,
    no_unidad,
    cod_descuen,
    porc_descuento
	)
	values (
	v_poliza_nuevo,	 -- no_poliza
	_unidad_key,	 -- no_unidad
	'003',			 -- cod_descuen
	_porcdescesp);	 -- porc_descuen 0
end if
if _porcrecargou is not null and _porcrecargou <> 0 THEN
	insert into emiunire
	values (v_poliza_nuevo,	 -- no_poliza
	        _unidad_key,	 -- no_unidad
	        '001',			 -- cod_recargo
	        _porcrecargou);	 -- porc_recargo 0
end if

if v_codramo = '002' AND _nromotor is not null AND TRIM(_nromotor) <> "" Then -- Habra cotizaciones sin valor del automovil
	begin
	on exception in(-239, -268)
	end exception
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
	user_changed,	
	date_changed,
	capacidad,
    transmision, 
	motor, 
	tamano, 
	tipo, 
	frenos, 
	air_bag, 
	rines, 
	km	
	)
	values (
	_nromotor,		 -- no_motor
	_codcolor,		 -- cod_color
	_codmarca,		 -- cod_marca
	_codmodelo,		 -- cod_modelo
	_valoractual,	 -- valor_auto		0
	_valororiginal,	 -- valor_original	0
	_anoauto,		 -- ano_auto		null
	_nrochasis,		 -- no_chasis		null
	_vin,			 -- vin
	_placa,			 -- placa
	null,			 -- placa_taxi      null
	_decnuevo,		 -- nuevo			1
	v_usuario,		 -- user_added		convers
	v_fecha_r,		 -- date_added		today
	null,			 -- user_changed	null
	null,			 -- date_changed	null
	_capacidad,
	_transmision,
    _tipo_motor,
    _tamano,
    _tipo_auto,
    _frenos, 
    _air_bag, 
    _tam_rines, 
    _kilome
	);
    end


	insert into emiauto(
    no_poliza,
    no_unidad,
    cod_tipoveh,
    no_motor,
    uso_auto,
    ano_tarifa
	)
	values (
	v_poliza_nuevo,		 -- no_poliza
	_unidad_key,		 -- no_unidad
	'013',				 -- cod_tipoveh
	_nromotor,			 -- no_motor
	_usandocar,			 -- uso_auto		P
	_anosauto			 -- ano_tarifa		0
	);
end if
	foreach
		select distinct codcobertura,
		       orden,
			   tarifa,
			   deducible,
			   limite1,
			   limite2,
			   primaanual,
			   primabruta,
			   descuento,
			   recargo,
			   primaneta,
			   factorvigencia,
			   desclimite1,
			   desclimite2,
			   aceptadesc,
			   desc_comb,
			   desc_modelo,
			   desc_vehic,
			   desc_edad,
			   desc_pr_tipov
		  into _codcobertura,  
			   _orden,         
			   _tarifa,        
			   _deducible,     
			   _limite1,       
			   _limite2,		  
			   _primaanual,	  
			   _primabruta,	  
			   _descuento,	  
			   _recargo,		  
			   _prima_neta,	  
			   _factorvigencia,
			   _desclimite1,   
			   _desclimite2,
			   _aceptadesc,
               _desc_comb,
               _desc_modelo,
               _desc_vehic,
               _desc_edad,
               _desc_pr_tipov			   
		  from wf_coberturas
		 where nrocotizacion = v_cotizacion
		   and nrounidad = _unidad

		 select desc_limite1,
                desc_limite2
           into _desclimite1,
                _desclimite2
           from prdcobpd
          where cod_producto = _codproducto
            and cod_cobertura = _codcobertura;		  
		   
		 if _orden is null then
		 	let _orden = 0;
		 end if

		 if _tarifa is null then
		 	let _tarifa = 0;
		 end if

		 if _deducible is null then
		 	let _deducible = '';
		 else
		    let _deducible =  _deducible||'.00';
		 end if

		 if _limite1 is null then
		 	let _limite1 = 0;
		 end if

		 if _limite2 is null then
		 	let _limite2 = 0;
		 end if

		 if _primaanual is null then
		 	let _primaanual = 0;
		 end if

		 if _primabruta is null then
		 	let _primabruta = 0;
		 end if

		 if _descuento is null then
		 	let _descuento = 0;
		 end if

		 if _recargo is null then
		 	let _recargo = 0;
		 end if

		 if _factorvigencia is null then
		 	let _factorvigencia = 0;
		 end if
		 
		 if _desc_comb is null then
		 	let _desc_comb = 0;
		 end if
		 
		 if _desc_modelo is null then
		 	let _desc_modelo = 0;
		 end if
		 
		 let _primaneta = 0; 

		 if _aceptadesc = 1 then
	     	let _primaneta =  _prima_neta + (_prima_neta*_porcrecargou/100);
		    let _recargo   =  _recargo    + (_prima_neta*_porcrecargou/100);
			let _descuento =  _descuento + (_primaneta*_porcdescbe/100);
			let _primaneta =  _primaneta - (_primaneta*_porcdescbe/100);
			let _descuento =  _descuento + (_primaneta*_porcdescflota/100);
			let _primaneta =  _primaneta - (_primaneta*_porcdescflota/100);
			let _descuento =  _descuento + (_primaneta*_porcdescesp/100);
			let _primaneta =  _primaneta - (_primaneta*_porcdescesp/100);
		 else
		    let _primaneta =  _prima_neta;
		 end if

		 if _primaneta is null then
		 	let _primaneta = 0;
		 end if

		begin

 			ON EXCEPTION IN(-239,-268)                     
                                                      
 			END EXCEPTION                             

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
			        v_poliza_nuevo,		 -- no_poliza
			        _unidad_key,		 -- no_unidad
			        _codcobertura,		 -- cod_cobertura
			        _orden,       		 -- orden
			        _tarifa,      		 -- tarifa			 0
			        _deducible,   		 -- deducible
			        _limite1,     		 -- limite_1		 0
			        _limite2,			 -- limite_2		 0
			        _primaanual,	 	 -- prima_anual		 0
			        _primabruta,	 	 -- prima			 0
			        _descuento,	 		 -- descuento
			        _recargo,			 -- recargo			 0
					_primaneta,     	 -- prima_neta		 0
					v_fecha_r,			 -- date_added		 today
					v_fecha_r,			 -- date_changed	 today
					_factorvigencia,	 -- factor_vigencia	 0
					_desclimite1,   	 -- desc_limite1	 null
					_desclimite2		 -- desc_limite2	 null
					);
		end	  
		
		if _desc_comb is not null and _desc_comb <> 0 THEN
			begin

				ON EXCEPTION IN(-239,-268)                     
														  
				END EXCEPTION                             
				insert into emicobde(
				no_poliza,
				no_unidad,
				cod_cobertura,
				cod_descuen,
				porc_descuento
				)
				values (
				v_poliza_nuevo,	 -- no_poliza
				_unidad_key,	 -- no_unidad
				_codcobertura,
				'004',			 -- cod_descuen
				_desc_comb);	 -- porc_descuen 0
			end
		end if
		
		if _desc_modelo is not null and _desc_modelo <> 0 THEN
			begin

				ON EXCEPTION IN(-239,-268)                     
														  
				END EXCEPTION                             
				insert into emicobde(
				no_poliza,
				no_unidad,
				cod_cobertura,
				cod_descuen,
				porc_descuento
				)
				values (
				v_poliza_nuevo,	 -- no_poliza
				_unidad_key,	 -- no_unidad
				_codcobertura,
				'005',			 -- cod_descuen
				_desc_modelo);	 -- porc_descuen 0
			end
		end if

		if _desc_vehic is not null and _desc_vehic <> 0 THEN
			begin

				ON EXCEPTION IN(-239,-268)                     
														  
				END EXCEPTION                             
				insert into emicobde(
				no_poliza,
				no_unidad,
				cod_cobertura,
				cod_descuen,
				porc_descuento
				)
				values (
				v_poliza_nuevo,	 -- no_poliza
				_unidad_key,	 -- no_unidad
				_codcobertura,
				'007',			 -- cod_descuen
				_desc_vehic);	 -- porc_descuen 0
			end
		end if

		if _desc_edad is not null and _desc_edad <> 0 THEN
			begin

				ON EXCEPTION IN(-239,-268)                     
														  
				END EXCEPTION                             
				insert into emicobde(
				no_poliza,
				no_unidad,
				cod_cobertura,
				cod_descuen,
				porc_descuento
				)
				values (
				v_poliza_nuevo,	 -- no_poliza
				_unidad_key,	 -- no_unidad
				_codcobertura,
				'008',			 -- cod_descuen
				_desc_edad);	 -- porc_descuen 0
			end
		end if
		
		if _desc_pr_tipov is not null and _desc_pr_tipov <> 0 THEN
			begin

				ON EXCEPTION IN(-239,-268)                     
														  
				END EXCEPTION                             
				insert into emicobde(
				no_poliza,
				no_unidad,
				cod_cobertura,
				cod_descuen,
				porc_descuento
				)
				values (
				v_poliza_nuevo,	 -- no_poliza
				_unidad_key,	 -- no_unidad
				_codcobertura,
				'009',			 -- cod_descuen
				_desc_pr_tipov);	 -- porc_descuen 0
			end
		end if
	end foreach

end foreach
end

END
RETURN 0;
end procedure;
