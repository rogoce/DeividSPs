-- Procedimiento que Realiza la Carga a las tablas de Endoso desde Cotizacion

-- Creado    : 21/07/2003 - Autor: Amado Perez  

drop procedure sp_sis376;

create procedure "informix".sp_sis376(
v_usuario      char(8), 
v_cotizacion   int, 
v_poliza       char(10),
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
DEFINE _li_unidad      INTEGER;

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
DEFINE _primaanual	   DEC(16,2);
DEFINE _primabruta	   DEC(16,2);
DEFINE _descuento	   DEC(16,2);
DEFINE _recargo		   DEC(16,2);
DEFINE _primaneta, _prima_neta  DEC(16,2);
DEFINE _factorvigencia  DEC(9,2);
DEFINE _desclimite1     VARCHAR(50);
DEFINE _desclimite2	   VARCHAR(50);
DEFINE v_cotizacion_r, _cadena  int;
DEFINE v_fecha_r, _vigencia_inic_pol, _vigencia_final_pol   DATE;
DEFINE v_usuario_r     CHAR(8);
define _error smallint; 
DEFINE _no_endoso      CHAR(5);
DEFINE _no_endoso_int  INT;
DEFINE _no_endoso_char CHAR(5);
DEFINE _no_documento   CHAR(20);
				
if v_cotizacion = 233987 then
	SET DEBUG FILE TO "sp_sis376.trc"; 
	trace on;
end if

SET LOCK MODE TO WAIT;

BEGIN

ON EXCEPTION SET _error
  RETURN _error;
END EXCEPTION

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

select vigencia_inic,
       vigencia_final,
	   no_documento,
	   fecha_primer_pago,
	   no_pagos,
	   cod_perpago
  into _vigencia_inic_pol,
       _vigencia_final_pol,
	   _no_documento,
	   ld_fecha_1_pago,
	   li_no_pagos,
	   ls_cod_perpago
  from emipomae
 Where no_poliza = v_poliza;

Select Max(no_endoso)
  Into _no_endoso
  From endedmae 
 Where no_poliza = v_poliza;

LET _no_endoso_int = _no_endoso;
LET _no_endoso_int = _no_endoso_int + 1;

LET _no_endoso_char = '00000';

IF _no_endoso_int > 9999  THEN
	LET _no_endoso_char[1,5] = _no_endoso_int;
ELIF _no_endoso_int > 999 THEN
	LET _no_endoso_char[2,5] = _no_endoso_int;
ELIF _no_endoso_int > 99  THEN
	LET _no_endoso_char[3,5] = _no_endoso_int;
ELIF _no_endoso_int > 9   THEN
	LET _no_endoso_char[4,5] = _no_endoso_int;
ELSE
	LET _no_endoso_char[5,5] = _no_endoso_int;
END IF

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

INSERT INTO endedmae(
	   no_poliza,
	   no_endoso,
	   cod_compania,		 
	   cod_sucursal,
	   cod_tipocalc,
	   cod_formapag,
	   cod_perpago,
	   cod_endomov,
	   no_documento,
	   vigencia_inic,
	   vigencia_final,	 
	   prima,			 
	   descuento,
	   recargo,			 
	   prima_neta,		 
	   impuesto,			 
	   prima_bruta,		 
	   prima_suscrita,
	   prima_retenida,
	   tiene_impuesto,	 
	   fecha_emision,
	   fecha_impresion,	 
	   fecha_primer_pago, 
	   no_pagos,			 
	   actualizado,		 
	   date_added,		 
	   date_changed,
	   interna,
	   periodo,		 
	   user_added,
	   factor_vigencia,	 
	   suma_asegurada,	 
	   posteado,
	   activa,
	   vigencia_inic_pol,
	   vigencia_final_pol,
	   cotizacion,
	   de_cotizacion
	   )
       VALUES(
       v_poliza,				 --no_poliza
	   _no_endoso_char,			 --no_endoso
       v_codcompania,			 --cod_compania		 001
	   v_codagencia,			 --cod_sucursal
	   v_codtipocalc,			 --cod_tipocalc
	   v_codformapago,			 --cod_formapag
	   v_codperpago,			 --cod_perpago
	   '004',					 --cod_endomov
	   _no_documento,
	   v_vigenciainic, 			 --vigencia_inic
	   v_vigenciafinal,			 --vigencia_final	 null
	   0,						 --prima			 0
	   0,						 --descuento
	   0,						 --recargo			 0
	   0,						 --prima_neta		 0
	   0,						 --impuesto			 0
	   0,						 --prima_bruta		 0
	   0,						 --prima_suscrita
	   0,						 --prima_retenida
	   1,						 --tiene_impuesto	 1
	   v_fecha_r,				 --fecha_suscripcion
	   v_fecha_r,				 --fecha_impresion	 today
	   v_vigenciainic,			 --fecha_primer_pago 
	   v_nopagos,				 --no_pagos			 1
	   0,						 --actualizado		 0
	   v_fecha_r,				 --date_added		 today
	   v_fecha_r,	 			 --date_changed		 today
	   0,
	   _periodo,				 --periodo
	   v_usuario,				 --user_added
	   v_factorvigencia,		 --factor_vigencia	 0
	   0,						 --suma_asegurada	 0
	   0,                        --posteado
	   1,						 --activa
	   _vigencia_inic_pol,		 --vigencia_inic_pol
	   _vigencia_final_pol,		 --vigencia_final_pol
	   _cotizacion,
	   1
	   );

 foreach
	 select cod_ruta
	   into _cod_ruta
	   from rearumae
	  where cod_compania = v_codcompania
	    and cod_sucursal = v_codagencia 
		and cod_ramo = v_codramo
		and serie = _serie
	 exit foreach;
 end foreach

{SELECT fecha_primer_pago,
       no_pagos,
	   cod_perpago
  INTO ld_fecha_1_pago,
       li_no_pagos,
	   ls_cod_perpago	
  FROM emipomae
 where no_poliza = v_poliza;}

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
	 where no_poliza = v_poliza;

end if}

{insert into emipoagt
values (v_codagente,		--cod_agente
        v_poliza,		    --no_poliza
		100,			    --porc_partic_agt
		0,					--porc_comis_agt
		100					--porc_product
		);}

begin

foreach 
 select cod_impuesto
   into _cod_impuesto
   from emipolim
  where no_poliza = v_poliza

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
	from wf_db_autos
   where nrocotizacion = v_cotizacion;
    
	insert into endedimp
	values (v_poliza,	   --no_poliza
	        _no_endoso_char,
	        _cod_impuesto,	   --cod_impuesto
			(_totprimabruta + _recargototal - _desctotal) * _factor_impuesto / 100	--monto   0
		   );
end foreach
end

Select Max(no_unidad)
  Into _li_unidad
  From endeduni 
 Where no_poliza = v_poliza;

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

 let _cadena = _unidad + _li_unidad;
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
	   		
insert into endeduni
values (v_poliza,		 -- no_poliza
		_no_endoso_char,
        _unidad_key,		 -- no_unidad
		_cod_ruta,			 -- cod_ruta
		_codproducto,		 -- cod_producto
		v_codcliente,		 -- cod_asegurado	 null
		_valoractual,		 -- suma_asegurada	 0
		_totprimabruta,		 -- prima			 0
		_descuentobe + _descuentoflota + _descuentoesp,	-- descuento
		_recargototal,		 -- recargo			 0
		_totprimabruta + _recargototal - (_descuentobe + _descuentoflota + _descuentoesp), -- prima_neta   0
		_impuestos,          -- impuesto		 0
		_totprimaneta,       -- prima_bruta		 0
		0,			         -- reasegurada		 0
		v_vigenciainic,      -- vigencia_inic	 
		v_vigenciafinal,	 -- vigencia_final	 null
		0,					 -- beneficio_max	 0
		_observacion,		 -- desc_unidad		 null
		0,					 -- prima_suscrita
		0,					 -- prima_retenida
		null,				 -- suma_aseg_adic	 null 0
		null				 -- tipo_incendio	 null
		);

if _codacreedor is not null and _codacreedor <> "" and _codacreedor <> "0" THEN
	insert into endedacr
	values (v_poliza,	     -- no_poliza
	        _no_endoso_char, 
	        _unidad_key,	 -- no_unidad
	        _codacreedor,	 -- cod_acreedor
	        0				 -- limite
	        );
end if

if _porcdescbe is not null and _porcdescbe <> 0 THEN
	insert into endeddes
	values (v_poliza,	 -- no_poliza
	        _no_endoso_char,
	        _unidad_key,	 -- no_unidad
	        '001',			 -- cod_descuen
	        _porcdescbe);	 -- 0
end if
if _porcdescflota is not null and _porcdescflota <> 0 THEN
	insert into endeddes
	values (v_poliza,	 -- no_poliza
	        _no_endoso_char,
	        _unidad_key,	 -- no_unidad
	        '002',			 -- cod_descuen
	        _porcdescflota); -- 0
end if
if _porcdescesp is not null and _porcdescesp <> 0 THEN
	insert into endeddes
	values (v_poliza,	 -- no_poliza
	        _no_endoso_char,
	        _unidad_key,	 -- no_unidad
	        '003',			 -- cod_descuen
	        _porcdescesp);	 -- porc_descuen 0
end if
if _porcrecargou is not null and _porcrecargou <> 0 THEN
	insert into endedrec
	values (v_poliza,	 -- no_poliza
	        _no_endoso_char,
	        _unidad_key,	 -- no_unidad
	        '001',			 -- cod_recargo
	        _porcrecargou);	 -- porc_recargo 0
end if

	begin
	on exception in(-239, -268)
	end exception
	insert into emivehic
	values (_nromotor,		 -- no_motor
	        '001',			 -- cod_color
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
			null			 -- date_changed	null
			);
     end


insert into endmoaut
values (v_poliza,		 -- no_poliza
        _no_endoso_char,
        _unidad_key,		 -- no_unidad
        _nromotor,			 -- no_motor
        '013',				 -- cod_tipoveh
        _usandocar,			 -- uso_auto		P
		_nrochasis,		     -- no_chasis		null
        _anosauto			 -- ano_tarifa		0
        );

	foreach
		select codcobertura,
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
			   aceptadesc
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
			   _aceptadesc	  
		  from wf_coberturas
		 where nrocotizacion = v_cotizacion
		   and nrounidad = _unidad

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

		 if _aceptadesc = 1 then
			let _primaneta =  _primabruta + (_primabruta*_porcrecargou/100);
			let _primaneta =  _primaneta - (_primaneta*_porcdescbe/100);
			let _primaneta =  _primaneta - (_primaneta*_porcdescflota/100);
			let _primaneta =  _primaneta - (_primaneta*_porcdescesp/100);
		 end if

		insert into endedcob
		values (v_poliza,		     -- no_poliza
				_no_endoso_char,      -- no_endoso
		        _unidad_key,		 -- no_unidad
		        _codcobertura,		 -- cod_cobertura
		        _orden,       		 -- orden
		        _tarifa,      		 -- tarifa			 0
		        _deducible,   		 -- deducible
		        _limite1,     		 -- limite_1		 0
		        _limite2,			 -- limite_2		 0
		        _prima_neta,	 	 -- prima_anual		 0
		        _prima_neta,	 	 -- prima			 0
		        _descuento,	 		 -- descuento
		        _recargo,			 -- recargo			 0
				_primaneta,     	 -- prima_neta		 0
				v_fecha_r,			 -- date_added		 today
				v_fecha_r,			 -- date_changed	 today
				_desclimite1,   	 -- desc_limite1	 null
				_desclimite2,		 -- desc_limite2	 null
				_factorvigencia,	 -- factor_vigencia	 0
				0
				);	  
	end foreach

end foreach
end

END
RETURN 0;
end procedure;
