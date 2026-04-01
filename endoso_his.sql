DROP PROCEDURE endoso_his;
CREATE PROCEDURE "informix".endoso_his(a_no_poliza CHAR(10))
--}
RETURNING INTEGER;

DEFINE _cod_compania    CHAR(3);  
DEFINE _cod_sucursal    CHAR(3);  
DEFINE _no_documento    CHAR(20); 
DEFINE _no_factura      CHAR(20); 
DEFINE _no_doc_orig     CHAR(20); 
DEFINE _no_fac_orig     CHAR(10); 

DEFINE _no_endoso       CHAR(5);  
DEFINE _cod_endomov     CHAR(3);  
DEFINE _null            CHAR(1);  
DEFINE _nueva_renov     CHAR(1);  
DEFINE _gestion		    CHAR(1);  

DEFINE _cod_formapag    CHAR(3);
DEFINE _cod_origen      CHAR(3);
DEFINE _cod_perpago     CHAR(3);  
DEFINE _tipo_forma      SMALLINT; 
DEFINE _no_tarjeta      CHAR(19); 
DEFINE _tipo_tarjeta    CHAR(1); 
DEFINE _fecha_exp       CHAR(7);  
DEFINE _cod_banco       CHAR(3);  
DEFINE _dia_cobros1     SMALLINT; 
DEFINE _user_added      CHAR(8);  
DEFINE _cod_pagador     CHAR(10); 
DEFINE _nombre_pagad    CHAR(100);
DEFINE _cod_contratante CHAR(10); 
DEFINE _periodo_visa    CHAR(1);
DEFINE _no_pagos  		INTEGER;
DEFINE _monto_visa      DEC(16,2);
DEFINE _prima_bruta     DEC(16,2);
DEFINE _fecha_1_pago    DATE;
DEFINE _no_endoso_ext	CHAR(5);
DEFINE _no_cuenta   	CHAR(17);
DEFINE _tipo_cuenta   	CHAR(1);
DEFINE _cod_tipoprod    CHAR(3);
DEFINE _tipo_produccion SMALLINT;
define _cobra_poliza	char(1);
define _return			smallint;
DEFINE _error     	    SMALLINT; 
DEFINE _cantidad        SMALLINT;
DEFINE _cantidad_uni    SMALLINT;
define _prima_neta		dec(16,2);
define _suma_asegurada	dec(16,2);

SET ISOLATION TO DIRTY READ;

LET _null      = NULL;
LET _no_endoso = '00000';

--SET DEBUG FILE TO "endoso_0.trc";  
--TRACE ON;                                                                 

BEGIN

ON EXCEPTION SET _error 
 	RETURN _error;         
END EXCEPTION           

--SELECT cod_endomov
--  INTO _cod_endomov
--  FROM endtimov
-- WHERE tipo_mov = 11;

LET _cod_endomov = "011";
LET _no_doc_orig = NULL;
LET _no_fac_orig = NULL;

SELECT cod_compania,
	   cod_sucursal,
	   nueva_renov,
	   no_documento,
	   no_factura,
	   no_tarjeta,
	   fecha_exp,
	   cod_banco,
	   user_added,
	   cod_pagador,
	   dia_cobros1,
	   cod_formapag,
	   tipo_tarjeta,
	   cod_perpago,
	   cod_contratante,
	   no_pagos,
	   prima_bruta,
	   fecha_primer_pago,
	   no_cuenta,
	   tipo_cuenta,
	   cod_tipoprod,
	   cod_origen,
	   cobra_poliza
  INTO _cod_compania,
	   _cod_sucursal,
	   _nueva_renov,
	   _no_doc_orig,
	   _no_fac_orig,
	   _no_tarjeta,
	   _fecha_exp,
	   _cod_banco,
	   _user_added,
	   _cod_pagador,
	   _dia_cobros1,
	   _cod_formapag,
	   _tipo_tarjeta,
	   _cod_perpago,
	   _cod_contratante,
	   _no_pagos,
	   _prima_bruta,
	   _fecha_1_pago,
	   _no_cuenta,
	   _tipo_cuenta,
	   _cod_tipoprod,
	   _cod_origen,
	   _cobra_poliza
  FROM emipomae
 WHERE no_poliza = a_no_poliza;

SELECT tipo_forma
  INTO _tipo_forma
  FROM cobforpa
 WHERE cod_formapag = _cod_formapag;

IF _nueva_renov = 'N' THEN

	IF _no_doc_orig IS NULL THEN                                                  
 	 	LET _no_documento = sp_sis19(_cod_compania, _cod_sucursal, a_no_poliza);  
 	ELSE                                                                          
 		LET _no_documento = _no_doc_orig;                                         
 	END IF                                                                        

	let _cobra_poliza = "A";

	if _tipo_forma = 2 then -- Tarjetas de Credito 
		let _cobra_poliza = "T"; 
	end if
	
	if _tipo_forma = 4 THEN -- ACH
		let _cobra_poliza = "H"; 
	end if

	call sp_sis64(_no_documento);

ELSE                                                                           

 	LET _no_documento = _no_doc_orig;                                             

END IF                                                                         

IF _no_fac_orig IS NULL OR _no_fac_orig = 'RENOVADA' THEN                                              
 	LET _no_factura = sp_sis14(_cod_compania, _cod_sucursal, a_no_poliza); 
ELSE                                                                      
 	LET _no_factura = _no_fac_orig;                                        
END IF                                                                    

LET _monto_visa = _prima_bruta / _no_pagos;


IF _tipo_forma = 2 OR  _tipo_forma = 4 THEN -- Tarjetas de Credito/Ach
	LET _gestion = 'A';
ELSE
	LET _gestion = 'P';
END IF

IF _cod_origen IS NULL THEN
	LET _cod_origen = "001";
END IF

{UPDATE emipomae
   SET no_documento      = _no_documento,
       no_factura        = _no_factura,
	   actualizado       = 1,
	   posteado          = '1',
	   fecha_suscripcion = TODAY,
	   fecha_impresion   = TODAY,
	   saldo             = prima_bruta,
	   monto_visa        = _monto_visa,
	   gestion			 = _gestion,
	   cod_origen		 = _cod_origen,
	   cobra_poliza		 = _cobra_poliza
 WHERE no_poliza         = a_no_poliza;
}
-- Verificacion para Tarjetas de Credito y Ach

IF _tipo_forma = 2 THEN -- Tarjetas de Credito

	SELECT nombre
	  INTO _nombre_pagad
	  FROM cobtahab
	 WHERE no_tarjeta = _no_tarjeta;
	
	IF _nombre_pagad IS NULL THEN -- Crear el Maestro de Tarjetas

		SELECT nombre
		  INTO _nombre_pagad
		  FROM cliclien
		 WHERE cod_cliente = _cod_pagador;

		INSERT INTO cobtahab(
		no_tarjeta,
		cod_banco,
		nombre,
		fecha_exp,
		user_added,
		date_added,
		tipo_tarjeta
		)
		VALUES(
		_no_tarjeta,
		_cod_banco,
		_nombre_pagad,
		_fecha_exp,
		_user_added,
		TODAY,
		_tipo_tarjeta
		);

	END IF

	SELECT nombre
	  INTO _nombre_pagad
	  FROM cobtacre
	 WHERE no_tarjeta   = _no_tarjeta
	   AND no_documento = _no_documento;

	IF _nombre_pagad IS NULL THEN -- Crear el Detalle de la Tarjeta
		
		IF _dia_cobros1 > 15 THEN
			LET _periodo_visa = 2;
		ELSE
			LET _periodo_visa = 1;
		END IF

		SELECT nombre
		  INTO _nombre_pagad
		  FROM cliclien
		 WHERE cod_cliente = _cod_contratante;

		INSERT INTO cobtacre(
		no_tarjeta,
		no_documento,
		cod_perpago,
		nombre,
		periodo,
		monto,
		fecha_ult_tran,
		procesar,
		excepcion,
		cargo_especial
		)
		VALUES(
		_no_tarjeta,
		_no_documento,
		_cod_perpago,
		_nombre_pagad,
		_periodo_visa,
		_monto_visa,
		_fecha_1_pago,
		0,
		0,
		0.00
		);

	END IF

END IF

IF _tipo_forma = 4 THEN -- Ach

	SELECT nombre
	  INTO _nombre_pagad
	  FROM cobcuhab
	 WHERE no_cuenta = _no_cuenta;
	 
	IF _nombre_pagad IS NULL THEN -- Crear el Maestro de Cuentas

		SELECT nombre
		  INTO _nombre_pagad
		  FROM cliclien
		 WHERE cod_cliente = _cod_pagador;

		INSERT INTO cobcuhab(
		no_cuenta,
		cod_banco,
		nombre,
		user_added,
		date_added,
		tipo_cuenta,
		tipo_transaccion,
		cod_pagador,
		monto_ach
		)
		VALUES(
		_no_cuenta,
		_cod_banco,
		_nombre_pagad,
		_user_added,
		TODAY,
		_tipo_cuenta,
		'D',
		_cod_pagador,
		_monto_visa
		);
	ELSE	--sumarle al monto del ach, el monto de la nueva poliza que se incorpora a la misma cuenta.
	  IF _nueva_renov = 'N' THEN
		UPDATE cobcuhab
		   SET monto_ach = monto_ach + _monto_visa
		 WHERE no_cuenta = _no_cuenta;

		  IF _dia_cobros1 > 15 THEN
		  	LET _periodo_visa = 2;
		  ELSE
		  	LET _periodo_visa = 1;
		  END IF

		  SELECT nombre
		    INTO _nombre_pagad
		    FROM cliclien
		   WHERE cod_cliente = _cod_contratante;

		  INSERT INTO cobcutas(
			no_cuenta,
			no_documento,
			cod_per_pago,
			nombre,
			periodo,
			monto,
			fecha_ult_tran,
			procesar,
			excepcion,
			cargo_especial
			)
			VALUES(
			_no_cuenta,
			_no_documento,
			_cod_perpago,
			_nombre_pagad,
			_periodo_visa,
			_monto_visa,
			_fecha_1_pago,
			0,
			0,
			0.00
			);
	  END IF
	END IF

	SELECT nombre
	  INTO _nombre_pagad
	  FROM cobcutas
	 WHERE no_cuenta    = _no_cuenta
	   AND no_documento = _no_documento;

	IF _nombre_pagad IS NULL THEN -- Crear el Detalle de la cuenta
		
		IF _dia_cobros1 > 15 THEN
			LET _periodo_visa = 2;
		ELSE
			LET _periodo_visa = 1;
		END IF

		SELECT nombre
		  INTO _nombre_pagad
		  FROM cliclien
		 WHERE cod_cliente = _cod_contratante;

		INSERT INTO cobcutas(
		no_cuenta,
		no_documento,
		cod_per_pago,
		nombre,
		periodo,
		monto,
		fecha_ult_tran,
		procesar,
		excepcion,
		cargo_especial
		)
		VALUES(
		_no_cuenta,
		_no_documento,
		_cod_perpago,
		_nombre_pagad,
		_periodo_visa,
		_monto_visa,
		_fecha_1_pago,
		0,
		0,
		0.00
		);
	END IF

END IF

if _nueva_renov = 'R' and (_tipo_forma = 5 or _tipo_forma = 3) THEN -- se debe insertar en callcenter
--	LET _return	= sp_cas022(a_no_poliza);

end if

-- Eliminar Registros

DELETE FROM endeddes WHERE no_poliza = a_no_poliza AND no_endoso = _no_endoso;
DELETE FROM endedrec WHERE no_poliza = a_no_poliza AND no_endoso = _no_endoso;
DELETE FROM endedimp WHERE no_poliza = a_no_poliza AND no_endoso = _no_endoso;
DELETE FROM endunide WHERE no_poliza = a_no_poliza AND no_endoso = _no_endoso;
DELETE FROM endunire WHERE no_poliza = a_no_poliza AND no_endoso = _no_endoso;
DELETE FROM endedde2 WHERE no_poliza = a_no_poliza AND no_endoso = _no_endoso;
DELETE FROM endedacr WHERE no_poliza = a_no_poliza AND no_endoso = _no_endoso;
DELETE FROM endmoaut WHERE no_poliza = a_no_poliza AND no_endoso = _no_endoso;
DELETE FROM endmotra WHERE no_poliza = a_no_poliza AND no_endoso = _no_endoso;
DELETE FROM endmotrd WHERE no_poliza = a_no_poliza AND no_endoso = _no_endoso;
DELETE FROM endcuend WHERE no_poliza = a_no_poliza AND no_endoso = _no_endoso;
DELETE FROM endcobre WHERE no_poliza = a_no_poliza AND no_endoso = _no_endoso;
DELETE FROM endcobde WHERE no_poliza = a_no_poliza AND no_endoso = _no_endoso;
DELETE FROM endedcob WHERE no_poliza = a_no_poliza AND no_endoso = _no_endoso;
DELETE FROM endcoama WHERE no_poliza = a_no_poliza AND no_endoso = _no_endoso;

-- Tablas no Tienen Instrucciones Insert
DELETE FROM endasien WHERE no_poliza = a_no_poliza AND no_endoso = _no_endoso;
DELETE FROM endmoage WHERE no_poliza = a_no_poliza AND no_endoso = _no_endoso;
DELETE FROM endmoase WHERE no_poliza = a_no_poliza AND no_endoso = _no_endoso;
DELETE FROM endcamco WHERE no_poliza = a_no_poliza AND no_endoso = _no_endoso;
DELETE FROM endedde1 WHERE no_poliza = a_no_poliza AND no_endoso = _no_endoso;

DELETE FROM endeduni WHERE no_poliza = a_no_poliza AND no_endoso = _no_endoso;
DELETE FROM endedmae WHERE no_poliza = a_no_poliza AND no_endoso = _no_endoso;

-- Endoso(0)

LET _no_endoso_ext  = sp_sis30(a_no_poliza, _no_endoso);

INSERT INTO endedmae(
no_poliza,
no_endoso,
cod_compania,
cod_sucursal,
cod_tipocalc,
cod_formapag,
cod_tipocan,
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
no_factura,
fact_reversar,
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
no_endoso_ext,
cod_tipoprod,
gastos
)
SELECT
a_no_poliza,
_no_endoso,
cod_compania,
cod_sucursal,
cod_tipocalc,
cod_formapag,
_null,
cod_perpago,
_cod_endomov,
_no_documento,
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
fecha_suscripcion,
fecha_impresion,
fecha_primer_pago,
no_pagos,
actualizado,
no_factura,
_null,
date_added,
date_changed,
0,
periodo,
user_added,
factor_vigencia,
suma_asegurada,
posteado,
1,
vigencia_inic,
vigencia_final,
_no_endoso_ext,
cod_tipoprod,
gastos
FROM emipomae
WHERE no_poliza = a_no_poliza;

SELECT COUNT(*)					--saber si inserto el endoso cero
  INTO _cantidad
  FROM endedmae
 WHERE no_poliza = a_no_poliza;

if _cantidad = 0 then
	return 1;
end if

-- Descuentos

INSERT INTO endeddes(
no_poliza,
no_endoso,
cod_descuen,
porc_descuento
)
SELECT 
a_no_poliza,
_no_endoso,
cod_descuen,
porc_descuento
FROM emipolde
WHERE no_poliza = a_no_poliza;

-- Recargos

INSERT INTO endedrec(
no_poliza,
no_endoso,
cod_recargo,
porc_recargo
)
SELECT 
a_no_poliza,
_no_endoso,
cod_recargo,
porc_recargo
FROM emiporec
WHERE no_poliza = a_no_poliza;

-- Impuestos

INSERT INTO endedimp(
no_poliza,
no_endoso,
cod_impuesto,
monto
)
SELECT 
a_no_poliza,
_no_endoso,
cod_impuesto,
monto
FROM emipolim
WHERE no_poliza = a_no_poliza;

-- Unidades

INSERT INTO endeduni(
no_poliza,
no_endoso,
no_unidad,
cod_ruta,
cod_producto,
cod_cliente,
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
prima_suscrita,
prima_retenida,
suma_aseg_adic,
tipo_incendio,
gastos
)
SELECT
a_no_poliza,
_no_endoso,
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
prima_suscrita,
prima_retenida,
suma_aseg_adic,
tipo_incendio,
gastos
FROM emipouni
WHERE no_poliza = a_no_poliza;

-- Descuentos

INSERT INTO endunide(
no_poliza,
no_endoso,
no_unidad,
cod_descuen,
porc_descuento
)
SELECT 
a_no_poliza,
_no_endoso,
no_unidad,
cod_descuen,
porc_descuento
FROM emiunide
WHERE no_poliza = a_no_poliza;

-- Recargos

INSERT INTO endunire(
no_poliza,
no_endoso,
no_unidad,
cod_recargo,
porc_recargo
)
SELECT 
a_no_poliza,
_no_endoso,
no_unidad,
cod_recargo,
porc_recargo
FROM emiunire
WHERE no_poliza = a_no_poliza;

-- Descripcion

INSERT INTO endedde2(
no_poliza,
no_endoso,
no_unidad,
descripcion
)
SELECT 
no_poliza,
_no_endoso,
no_unidad,
descripcion
FROM emipode2
WHERE no_poliza = a_no_poliza;

-- Acreedores

INSERT INTO endedacr(
no_poliza,
no_endoso,
no_unidad,
cod_acreedor,
limite
)
SELECT 
no_poliza,
_no_endoso,
no_unidad,
cod_acreedor,
limite
FROM emipoacr
WHERE no_poliza = a_no_poliza;

-- Autos

INSERT INTO endmoaut(
no_poliza,
no_endoso,
no_unidad,
no_motor,
cod_tipoveh,
uso_auto,
no_chasis,
ano_tarifa
)
SELECT
a_no_poliza,
_no_endoso,
no_unidad,
no_motor,
cod_tipoveh,
uso_auto,
_null,
ano_tarifa
FROM emiauto
WHERE no_poliza = a_no_poliza;

-- Transporte

INSERT INTO endmotra(
no_poliza,
no_endoso,
no_unidad,
cod_nave,
consignado,
tipo_embarque,
clausulas,
contenedor,
sello,
fecha_viaje,
viaje_desde,
viaje_hasta,
sobre
)
SELECT
a_no_poliza,
_no_endoso,
no_unidad,
cod_nave,
consignado,
tipo_embarque,
clausulas,
contenedor,
sello,
fecha_viaje,
viaje_desde,
viaje_hasta,
sobre
FROM emitrans
WHERE no_poliza = a_no_poliza;

INSERT INTO endmotrd(
no_poliza,
no_endoso,
no_unidad,
especiales
)
SELECT
a_no_poliza,
_no_endoso,
no_unidad,
especiales
FROM emitrand
WHERE no_poliza = a_no_poliza;

-- Cumulos de Incendio

INSERT INTO endcuend(
no_poliza,
no_endoso,
no_unidad,
cod_ubica,
suma_incendio,
suma_terremoto,
prima_incendio,
prima_terremoto
)
SELECT
a_no_poliza,
_no_endoso,
no_unidad,
cod_ubica,
suma_incendio,
suma_terremoto,
prima_incendio,
prima_terremoto
FROM emicupol
WHERE no_poliza = a_no_poliza;

-- Coberturas

INSERT INTO endedcob(
no_poliza,
no_endoso,
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
desc_limite1,
desc_limite2,
factor_vigencia,
opcion
)
SELECT
no_poliza,
_no_endoso,
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
desc_limite1,
desc_limite2,
factor_vigencia,
0
FROM emipocob
WHERE no_poliza = a_no_poliza;

-- Descuentos

INSERT INTO endcobde(
no_poliza,
no_endoso,
no_unidad,
cod_cobertura,
cod_descuen,
porc_descuento
)
SELECT 
no_poliza,
_no_endoso,
no_unidad,
cod_cobertura,
cod_descuen,
porc_descuento
FROM emicobde
WHERE no_poliza = a_no_poliza;

-- Recargos

INSERT INTO endcobre(
no_poliza,
no_endoso,
no_unidad,
cod_cobertura,
cod_recargo,
porc_recargo
)
SELECT 
no_poliza,
_no_endoso,
no_unidad,
cod_cobertura,
cod_recargo,
porc_recargo
FROM emicobre
WHERE no_poliza = a_no_poliza;

BEGIN

DEFINE _vigencia_inic  DATE;
DEFINE _vigencia_final DATE;
DEFINE _no_cambio      SMALLINT;
DEFINE _no_endoso      CHAR(5);
DEFINE _no_unidad      CHAR(5);
DEFINE _cod_cober_reas CHAR(3);
DEFINE _no_cambio_coas CHAR(3);
DEFINE _cantidad       SMALLINT;

LET _no_cambio      = 0;
LET _no_endoso      = '00000';
LET _no_cambio_coas = '000';
{
DELETE FROM emireagf WHERE no_poliza = a_no_poliza AND no_cambio = _no_cambio;
DELETE FROM emireagc WHERE no_poliza = a_no_poliza AND no_cambio = _no_cambio;
DELETE FROM emireagm WHERE no_poliza = a_no_poliza AND no_cambio = _no_cambio;

DELETE FROM emireafa WHERE no_poliza = a_no_poliza AND no_cambio = _no_cambio;
DELETE FROM emireaco WHERE no_poliza = a_no_poliza AND no_cambio = _no_cambio;
DELETE FROM emireama WHERE no_poliza = a_no_poliza AND no_cambio = _no_cambio;

SELECT vigencia_inic,
       vigencia_final
  INTO _vigencia_inic,
       _vigencia_final
  FROM emipomae
 WHERE no_poliza = a_no_poliza;

-- Actualizacion de las Vigencias en las Unidades

UPDATE emipouni
   SET vigencia_inic  = _vigencia_inic,
       vigencia_final = _vigencia_final,
	   fecha_emision  = TODAY,
	   prima_bruta    = prima_bruta + gastos
 WHERE no_poliza      = a_no_poliza;

UPDATE emidepen
   SET date_added     = TODAY,
	   user_added     = _user_added
 WHERE no_poliza      = a_no_poliza;

UPDATE emipreas
   SET date_added     = TODAY,
	   user_added     = _user_added
 WHERE no_poliza      = a_no_poliza;

UPDATE emiprede
   SET date_added     = TODAY,
	   user_added     = _user_added
 WHERE no_poliza      = a_no_poliza;

UPDATE endeduni
   SET vigencia_inic  = _vigencia_inic,
       vigencia_final = _vigencia_final,
	   prima_bruta    = prima_bruta + gastos
 WHERE no_poliza      = a_no_poliza
   AND no_endoso      = _no_endoso;

select count(*)
  into _cantidad_uni
  from emipouni
 where no_poliza = a_no_poliza;

if _cantidad_uni > 1 then

	update emipomae
	   set colectiva = "C"
     where no_poliza = a_no_poliza;

end if

-- Historico de Reaseguro Global

INSERT INTO emireagm(
no_poliza,
no_cambio,
vigencia_inic,
vigencia_final
)
VALUES( 
a_no_poliza,
_no_cambio,
_vigencia_inic,
_vigencia_final
);

INSERT INTO emireagc(
no_poliza,
no_cambio,
orden,
cod_contrato,
porc_partic_suma,
porc_partic_prima
)
SELECT 
a_no_poliza, 
_no_cambio,
orden,
cod_contrato,
porc_partic_suma,
porc_partic_prima
FROM emigloco
WHERE no_poliza = a_no_poliza
  AND no_endoso = _no_endoso;

INSERT INTO emireagf(
no_poliza,
no_cambio,
orden,
cod_contrato,
cod_coasegur,
porc_partic_reas,
porc_comis_fac,
porc_impuesto
)
SELECT 
a_no_poliza, 
_no_cambio,
orden,
cod_contrato,
cod_coasegur,
porc_partic_reas,
porc_comis_fac,
porc_impuesto
FROM emiglofa
WHERE no_poliza = a_no_poliza
  AND no_endoso = _no_endoso;

FOREACH
 SELECT	no_unidad,
        cod_cober_reas
   INTO	_no_unidad,
        _cod_cober_reas
   FROM	emifacon
  WHERE	no_poliza = a_no_poliza
    AND no_endoso = _no_endoso
  GROUP BY no_unidad, cod_cober_reas

	INSERT INTO emireama(
	no_poliza,
	no_unidad,
	no_cambio,
	cod_cober_reas,
	vigencia_inic,
	vigencia_final
	)
	VALUES(
	a_no_poliza, 
	_no_unidad,
	_no_cambio,
	_cod_cober_reas,
	_vigencia_inic,
	_vigencia_final
	);

END FOREACH

INSERT INTO emireaco(
no_poliza,
no_unidad,
no_cambio,
cod_cober_reas,
orden,
cod_contrato,
porc_partic_suma,
porc_partic_prima
)
SELECT 
a_no_poliza, 
no_unidad,
_no_cambio,
cod_cober_reas,
orden,
cod_contrato,
porc_partic_suma,
porc_partic_prima
FROM emifacon
WHERE no_poliza = a_no_poliza
  AND no_endoso = _no_endoso;

INSERT INTO emireafa(
no_poliza,
no_unidad,
no_cambio,
cod_cober_reas,
orden,
cod_contrato,
cod_coasegur,
porc_partic_reas,
porc_comis_fac,
porc_impuesto
)
SELECT 
a_no_poliza, 
no_unidad,
_no_cambio,
cod_cober_reas,
orden,
cod_contrato,
cod_coasegur,
porc_partic_reas,
porc_comis_fac,
porc_impuesto
FROM emifafac
WHERE no_poliza = a_no_poliza
  AND no_endoso = _no_endoso;

-- Coaseguros 

DELETE FROM emihcmm WHERE no_poliza = a_no_poliza AND no_cambio = _no_cambio;
DELETE FROM emihcmd WHERE no_poliza = a_no_poliza AND no_cambio = _no_cambio; }

{INSERT INTO emihcmm(
no_poliza,
no_cambio,
vigencia_inic,
vigencia_final,
fecha_mov,
no_endoso
)
VALUES( 
a_no_poliza,
_no_cambio_coas,
_vigencia_inic,
_vigencia_final,
TODAY,
_no_endoso
);

INSERT INTO emihcmd(
no_poliza,
no_cambio,
cod_coasegur,
porc_partic_coas,
porc_gastos
)
SELECT 
a_no_poliza,
_no_cambio_coas,
cod_coasegur,
porc_partic_coas,
porc_gastos
FROM emicoama
WHERE no_poliza = a_no_poliza;

SELECT COUNT(*)
  INTO _cantidad
  FROM emihcmd
 WHERE no_poliza = a_no_poliza;

-- Verifica si el tipo de produccion "Coaseg. Mayoritario" no ha sido cambiado. *Amado*

SELECT tipo_produccion
  INTO _tipo_produccion
  FROM emitipro
 WHERE cod_tipoprod = _cod_tipoprod;

IF _cantidad IS NULL THEN
	LET _cantidad = 0;
END IF
									 
IF _cantidad = 0 THEN

	DELETE FROM emihcmm
     WHERE no_poliza = a_no_poliza;

END IF

IF _tipo_produccion <> 2 THEN

	DELETE FROM emihcmd
     WHERE no_poliza = a_no_poliza;

	DELETE FROM emihcmm
     WHERE no_poliza = a_no_poliza;

	DELETE FROM emicoama
     WHERE no_poliza = a_no_poliza;

END IF

-- Guarda el Historico de Coaseguro

select prima_neta,
       suma_asegurada
  into _prima_neta,
       _suma_asegurada
  from emipomae
 where no_poliza = a_no_poliza;

INSERT INTO endcoama(
	   no_poliza,
	   no_endoso,
	   cod_coasegur,
	   porc_partic_coas,
	   porc_gastos,
	   prima,
	   suma
	   )
SELECT no_poliza,
       _no_endoso,
       cod_coasegur,
       porc_partic_coas,
       porc_gastos,
	   (_prima_neta      * porc_partic_coas / 100),
	   (_suma_asegurada  * porc_partic_coas / 100)
  FROM emicoama
 WHERE no_poliza = a_no_poliza;	 }

--CALL sp_pro100(a_no_poliza, _no_endoso); -- Historico de endedmae (endedhis)
--CALL sp_sis70(a_no_poliza, _no_endoso);	 -- Historico de emipoagt (endmoage)

END

RETURN 0;

END

END PROCEDURE                                                                                                                                              
