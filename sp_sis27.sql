-- Procedimiento Para Crear registros para Reimprimir
-- 
-- Creado    : 06/11/2000 - Autor: Edgar E. Cano
-- Modificado: 29/03/2001 - Autor: Edgar E. Cano
--
-- SIS v.2.0 - DEIVID, S.A.

DROP PROCEDURE sp_sis27;

CREATE PROCEDURE "informix".sp_sis27(a_no_poliza CHAR(10), a_accion INTEGER)
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

DEFINE _cod_formapag    CHAR(3);  
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
DEFINE _error     	    SMALLINT; 

LET _null      = NULL;
LET _no_endoso = '00000';

--SET DEBUG FILE TO "sp_sis27.trc";  
--TRACE ON;                                                                 

SET ISOLATION TO DIRTY READ;

BEGIN

ON EXCEPTION SET _error 
 	RETURN _error;         
END EXCEPTION           

IF a_accion = 1 THEN
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
		   fecha_primer_pago
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
		   _fecha_1_pago
	  FROM emipomae
	 WHERE no_poliza = a_no_poliza;

	IF _no_doc_orig IS NULL THEN
	   LET _no_documento = 'PRELIMINAR';
	ELSE
	   LET _no_documento = _no_doc_orig;
	END IF 

	LET _no_factura = 'PRELIMINAR';
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
	DELETE FROM endcobde WHERE no_poliza = a_no_poliza AND no_endoso = _no_endoso;
	DELETE FROM endcobre WHERE no_poliza = a_no_poliza AND no_endoso = _no_endoso;
	DELETE FROM endedcob WHERE no_poliza = a_no_poliza AND no_endoso = _no_endoso;
	DELETE FROM endcoama WHERE no_poliza = a_no_poliza AND no_endoso = _no_endoso;

	-- Tablas no Tienen Instrucciones Insert
	--DELETE FROM endasien WHERE no_poliza = a_no_poliza AND no_endoso = _no_endoso;
	DELETE FROM endmoage WHERE no_poliza = a_no_poliza AND no_endoso = _no_endoso;
	DELETE FROM endmoase WHERE no_poliza = a_no_poliza AND no_endoso = _no_endoso;
	DELETE FROM endcamco WHERE no_poliza = a_no_poliza AND no_endoso = _no_endoso;
	DELETE FROM endedde1 WHERE no_poliza = a_no_poliza AND no_endoso = _no_endoso;

	DELETE FROM endeduni WHERE no_poliza = a_no_poliza AND no_endoso = _no_endoso;
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
	activa,
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
	_no_factura,
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
	gastos
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
	prima_retenida,
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
	prima_bruta + gastos,
	reasegurada,
	vigencia_inic,
	vigencia_final,
	beneficio_max,
	desc_unidad,
	prima_suscrita,
	prima_retenida,
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

	-- Guarda el Historico de Coaseguro

	INSERT INTO endcoama(
		   no_poliza,
		   no_endoso,
		   cod_coasegur,
		   porc_partic_coas,
		   porc_gastos
		   )
	SELECT no_poliza,
	       _no_endoso,
	       cod_coasegur,
	       porc_partic_coas,
	       porc_gastos
	  FROM emicoama
	 WHERE no_poliza = a_no_poliza;
ELSE
-- BORRAR TODOS LOS REGISTROS NUEVOS
    LET a_no_poliza = a_no_poliza;
    LET _no_endoso  = _no_endoso;

	DELETE FROM endcoama WHERE no_poliza = a_no_poliza AND no_endoso = _no_endoso; --1
	DELETE FROM endcobre WHERE no_poliza = a_no_poliza AND no_endoso = _no_endoso; --2
	DELETE FROM endcobde WHERE no_poliza = a_no_poliza AND no_endoso = _no_endoso; --3
	DELETE FROM endedcob WHERE no_poliza = a_no_poliza AND no_endoso = _no_endoso; --4
	DELETE FROM endcuend WHERE no_poliza = a_no_poliza AND no_endoso = _no_endoso; --5
	DELETE FROM endmotrd WHERE no_poliza = a_no_poliza AND no_endoso = _no_endoso; --6
	DELETE FROM endmotra WHERE no_poliza = a_no_poliza AND no_endoso = _no_endoso; --7
	DELETE FROM endmoaut WHERE no_poliza = a_no_poliza AND no_endoso = _no_endoso; --8
	DELETE FROM endedacr WHERE no_poliza = a_no_poliza AND no_endoso = _no_endoso; --9
	DELETE FROM endedde2 WHERE no_poliza = a_no_poliza AND no_endoso = _no_endoso; --10
	DELETE FROM endunire WHERE no_poliza = a_no_poliza AND no_endoso = _no_endoso; --11
	DELETE FROM endunide WHERE no_poliza = a_no_poliza AND no_endoso = _no_endoso; --12
	DELETE FROM endedimp WHERE no_poliza = a_no_poliza AND no_endoso = _no_endoso; --13
	DELETE FROM endedrec WHERE no_poliza = a_no_poliza AND no_endoso = _no_endoso; --14
	DELETE FROM endeddes WHERE no_poliza = a_no_poliza AND no_endoso = _no_endoso; --15

	-- Tablas no Tienen Instrucciones Insert
	--DELETE FROM endasien WHERE no_poliza = a_no_poliza AND no_endoso = _no_endoso;
	DELETE FROM endmoage WHERE no_poliza = a_no_poliza AND no_endoso = _no_endoso;
	DELETE FROM endmoase WHERE no_poliza = a_no_poliza AND no_endoso = _no_endoso;
	DELETE FROM endcamco WHERE no_poliza = a_no_poliza AND no_endoso = _no_endoso;
	DELETE FROM endedde1 WHERE no_poliza = a_no_poliza AND no_endoso = _no_endoso;

	DELETE FROM endeduni WHERE no_poliza = a_no_poliza AND no_endoso = _no_endoso;
	DELETE FROM endedmae WHERE no_poliza = a_no_poliza AND no_endoso = _no_endoso;

END IF
RETURN 0;
END

END PROCEDURE;
