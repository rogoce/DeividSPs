-- Procedimiento que Crea el Historico de Polizas
-- 
-- Creado    : 06/11/2000 - Autor: Demetrio Hurtado Almanza 
-- Modificado: 06/11/2000 - Autor: Demetrio Hurtado Almanza
--
-- SIS v.2.0 - DEIVID, S.A.

DROP PROCEDURE sp_sis17;		

CREATE PROCEDURE "informix".sp_sis17(a_no_poliza CHAR(10))
RETURNING INTEGER;

DEFINE _cod_compania CHAR(3);
DEFINE _cod_sucursal CHAR(3);
DEFINE _no_documento CHAR(20);
DEFINE _no_factura   CHAR(20);
DEFINE _no_doc_orig  CHAR(20);
DEFINE _no_fac_orig  CHAR(10);

DEFINE _no_endoso    CHAR(5);
DEFINE _cod_endomov  CHAR(3);
DEFINE _null         CHAR(1);
DEFINE _nueva_renov  CHAR(1);

DEFINE _error        SMALLINT;

LET _null      = NULL;
LET _no_endoso = '00000';

-- SET DEBUG FILE TO "\\NEMESIS\Ancon\Store Procedures\Debug\sp_sis17.trc";  
-- TRACE ON;                                                                 

BEGIN

ON EXCEPTION SET _error 
 	RETURN _error;         
END EXCEPTION           

SELECT cod_endomov
  INTO _cod_endomov
  FROM endtimov
 WHERE tipo_mov = 11;

LET _no_doc_orig = NULL;
LET _no_fac_orig = NULL;

SELECT cod_compania,
	   cod_sucursal,
	   nueva_renov,
	   no_documento,
	   no_factura
  INTO _cod_compania,
	   _cod_sucursal,
	   _nueva_renov,
	   _no_doc_orig,
	   _no_fac_orig
  FROM emipomae
 WHERE no_poliza = a_no_poliza;

-- IF _nueva_renov = 'N' THEN                                                     
--  	LET _no_documento = sp_sis19(_cod_compania, _cod_sucursal, a_no_poliza);  
-- ELSE                                                                           
-- 	LET _no_documento = _no_doc_orig;                                             
-- END IF                                                                         

-- LET _no_factura   = sp_sis14(_cod_compania, _cod_sucursal, a_no_poliza);

IF _nueva_renov = 'N' THEN                                                     
	IF _no_doc_orig IS NULL THEN                                                  
 	 	LET _no_documento = sp_sis19(_cod_compania, _cod_sucursal, a_no_poliza);  
 	ELSE                                                                          
 		LET _no_documento = _no_doc_orig;                                         
 	END IF                                                                        
ELSE                                                                           
 	LET _no_documento = _no_doc_orig;                                             
END IF                                                                         

IF _no_fac_orig IS NULL OR _no_fac_orig = 'RENOVADA' THEN                                              
 	LET _no_factura = sp_sis14(_cod_compania, _cod_sucursal, a_no_poliza); 
ELSE                                                                      
 	LET _no_factura = _no_fac_orig;                                        
END IF                                                                    

UPDATE emipomae
   SET no_documento      = _no_documento,
       no_factura        = _no_factura,
	   actualizado       = 1,
	   posteado          = '1',
	   fecha_suscripcion = TODAY,
	   saldo             = prima_bruta
 WHERE no_poliza         = a_no_poliza;

-- Eliminar Registros

DELETE FROM endcobde WHERE no_poliza = a_no_poliza AND no_endoso = _no_endoso;
DELETE FROM endcobre WHERE no_poliza = a_no_poliza AND no_endoso = _no_endoso;
DELETE FROM endedcob WHERE no_poliza = a_no_poliza AND no_endoso = _no_endoso;
DELETE FROM endcuend WHERE no_poliza = a_no_poliza AND no_endoso = _no_endoso;
DELETE FROM endmotra WHERE no_poliza = a_no_poliza AND no_endoso = _no_endoso;
DELETE FROM endmoaut WHERE no_poliza = a_no_poliza AND no_endoso = _no_endoso;
DELETE FROM endedde2 WHERE no_poliza = a_no_poliza AND no_endoso = _no_endoso;
DELETE FROM endedacr WHERE no_poliza = a_no_poliza AND no_endoso = _no_endoso;
DELETE FROM endunide WHERE no_poliza = a_no_poliza AND no_endoso = _no_endoso;
DELETE FROM endunire WHERE no_poliza = a_no_poliza AND no_endoso = _no_endoso;
DELETE FROM endeduni WHERE no_poliza = a_no_poliza AND no_endoso = _no_endoso;
DELETE FROM endedimp WHERE no_poliza = a_no_poliza AND no_endoso = _no_endoso;
DELETE FROM endedrec WHERE no_poliza = a_no_poliza AND no_endoso = _no_endoso;
DELETE FROM endeddes WHERE no_poliza = a_no_poliza AND no_endoso = _no_endoso;
DELETE FROM endasien WHERE no_poliza = a_no_poliza AND no_endoso = _no_endoso;
DELETE FROM endmoage WHERE no_poliza = a_no_poliza AND no_endoso = _no_endoso;
DELETE FROM endmoase WHERE no_poliza = a_no_poliza AND no_endoso = _no_endoso;
DELETE FROM endcamco WHERE no_poliza = a_no_poliza AND no_endoso = _no_endoso;
DELETE FROM endedde1 WHERE no_poliza = a_no_poliza AND no_endoso = _no_endoso;
DELETE FROM endedmae WHERE no_poliza = a_no_poliza AND no_endoso = _no_endoso;

-- Endoso(0)

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
activa
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
1
FROM emipomae
WHERE no_poliza = a_no_poliza;

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
prima_retenida
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
prima_retenida
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
cod_viaje,
especiales,
consignado,
tipo_embarque,
clausulas,
contenedor,
sello
)
SELECT
a_no_poliza,
_no_endoso,
no_unidad,
cod_viaje,
especiales,
consignado,
tipo_embarque,
clausulas,
contenedor,
sello
FROM emitrans
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

LET _no_cambio = 0;
LET _no_endoso = '00000';

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
DELETE FROM emihcmd WHERE no_poliza = a_no_poliza AND no_cambio = _no_cambio;

INSERT INTO emihcmm(
no_poliza,
no_cambio,
vigencia_inic,
vigencia_final,
fecha_mov,
no_endoso
)
VALUES( 
a_no_poliza,
_no_cambio,
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
_no_cambio,
cod_coasegur,
porc_partic_coas,
porc_gastos
FROM emicoama
WHERE no_poliza = a_no_poliza;

END

RETURN 0;

END

END PROCEDURE;
