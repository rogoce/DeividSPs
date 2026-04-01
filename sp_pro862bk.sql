
-- Procedimiento para insertar el endoso de pronto pago al momento de recibir remesa
-- RS - 26/08/2009

DROP PROCEDURE sp_pro862bk;

CREATE PROCEDURE sp_pro862bk(a_no_poliza CHAR(10), a_user CHAR(8), a_prima_bruta_end DEC(16,2)) 
	RETURNING SMALLINT,
			  CHAR(100);

DEFINE _no_endoso       	CHAR(5);
DEFINE _no_endoso_ext		CHAR(5);
DEFINE _no_endoso_ent		INTEGER;
DEFINE _cod_endomov     	CHAR(3);
DEFINE _prima_neta			DEC(16,2);
DEFINE _null            	CHAR(1);

DEFINE v_unidad          	CHAR(5);
DEFINE v_prima_bruta		DEC(16,2);
DEFINE v_fecha_actual		DATE;
DEFINE v_factor 			DEC(9,6);
DEFINE v_cobertura       	CHAR(5);
DEFINE v_periodo			CHAR(7);

DEFINE _error     	    	SMALLINT;
DEFINE _error_desc			CHAR(30);

DEFINE	v_prima_suscrita	DEC(16,2);
DEFINE 	v_prima_retenida	DEC(16,2);
DEFINE	v_prima				DEC(16,2);
DEFINE	v_total_descto		DEC(16,2);
DEFINE 	v_porc_recargo		DEC(16,2);
DEFINE	v_prima_neta		DEC(16,2);
DEFINE	v_impuesto			DEC(16,2);
DEFINE	v_prima_br			DEC(16,2);
DEFINE  v_suma_asegurada   	DEC(16,2);
DEFINE  v_gastos			DEC(16,2);
DEFINE	v_existe_end		SMALLINT;
DEFINE	v_mes_actual		SMALLINT;
DEFINE	v_mes_string		CHAR(2);
define  _fecha_hoy          date;
define _vigencia_i          date;
define _fecha_sus           date;
define _dias                integer;
define _cod_ramo            char(3);

SET ISOLATION TO DIRTY READ;

BEGIN

ON EXCEPTION SET _error
 	RETURN _error, 'Error al Actualizar el Endoso ...';
END EXCEPTION

--VERIFICA SI YA SE LE HIZO EL DESCUENTO A LA POLIZA

SET DEBUG FILE TO "sp_pro862bk.trc";
TRACE ON;                                                                 

LET v_existe_end = 0;
let _fecha_hoy = '11/04/2012';

select cod_ramo
  into _cod_ramo
  from emipomae
 where no_poliza = a_no_poliza;

if _cod_ramo = "020" or _cod_ramo = "004" or _cod_ramo = "008" or _cod_ramo = "016" or _cod_ramo = "018" or _cod_ramo = "019" then
	RETURN 0, "Actualización Exitosa... 1";
end if

SELECT count(*)
  INTO v_existe_end
  FROM endedmae
 WHERE ( endedmae.no_poliza = a_no_poliza ) AND
	   ( endedmae.cod_endomov = "024" ) ;

IF v_existe_end > 0 THEN
	RETURN 0, "Actualización Exitosa... 2";
END IF

--REGRESA EL NUEVO NUMERO DE ENDOSO
LET _no_endoso = sp_sis90(a_no_poliza);
LET _no_endoso_ent = _no_endoso + 1;
LET _no_endoso = sp_set_codigo(5, _no_endoso_ent);

LET _cod_endomov   = "024";
LET _no_endoso_ext = _no_endoso;
LET v_fecha_actual = sp_sis26();

--PERIODO
LET v_mes_string = MONTH(v_fecha_actual);
LET v_mes_actual =  LENGTH(v_mes_string);

IF v_mes_actual = 1 THEN
	LET v_mes_string = "0" || MONTH(v_fecha_actual);
ELSE	
	LET v_mes_string = MONTH(v_fecha_actual);
END IF

LET v_periodo = YEAR(v_fecha_actual) || "-" || v_mes_string;

LET _null      = NULL;

--Buscar los dias, se toma la mayor fecha entre la vig ini vs la fecha de suscripcion
select vigencia_inic,
       fecha_suscripcion
  into _vigencia_i,
       _fecha_sus
  from emipomae
 where no_poliza = a_no_poliza;

if _fecha_sus >	_vigencia_i then
	let _dias = _fecha_hoy - _fecha_sus;
else
	let _dias = _fecha_hoy - _vigencia_i;	
end if

if _dias > 30 then
	RETURN 0, "Actualización Exitosa...3";
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
DELETE FROM endmotrd WHERE no_poliza = a_no_poliza AND no_endoso = _no_endoso;
DELETE FROM endmotra WHERE no_poliza = a_no_poliza AND no_endoso = _no_endoso;
DELETE FROM endcuend WHERE no_poliza = a_no_poliza AND no_endoso = _no_endoso;
DELETE FROM endcobre WHERE no_poliza = a_no_poliza AND no_endoso = _no_endoso;
DELETE FROM endcobde WHERE no_poliza = a_no_poliza AND no_endoso = _no_endoso;
DELETE FROM endedcob WHERE no_poliza = a_no_poliza AND no_endoso = _no_endoso;
DELETE FROM endcoama WHERE no_poliza = a_no_poliza AND no_endoso = _no_endoso;

-- Tablas no Tienen Instrucciones Insert
DELETE FROM endmoage WHERE no_poliza = a_no_poliza AND no_endoso = _no_endoso;
DELETE FROM endmoase WHERE no_poliza = a_no_poliza AND no_endoso = _no_endoso;
DELETE FROM endcamco WHERE no_poliza = a_no_poliza AND no_endoso = _no_endoso;
DELETE FROM endedde1 WHERE no_poliza = a_no_poliza AND no_endoso = _no_endoso;

DELETE FROM endeduni WHERE no_poliza = a_no_poliza AND no_endoso = _no_endoso;
DELETE FROM endedmae WHERE no_poliza = a_no_poliza AND no_endoso = _no_endoso;
DELETE FROM endedhis WHERE no_poliza = a_no_poliza AND no_endoso = _no_endoso;

--ENDOSO DE PRONTO PAGO
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
"006",
cod_formapag,
_null,
cod_perpago,
_cod_endomov,
no_documento,
vigencia_inic,
vigencia_final,
0,
0,
0,
0,
0,
a_prima_bruta_end,
0,
0,
tiene_impuesto,
fecha_suscripcion,
fecha_impresion,
fecha_primer_pago,
no_pagos,
0,
_null,
_null,
v_fecha_actual,
v_fecha_actual,
0,
v_periodo,
a_user,
factor_vigencia,
0,
posteado,
1,
vigencia_inic,
vigencia_final,
_no_endoso_ext,
cod_tipoprod,
gastos
FROM emipomae
WHERE no_poliza = a_no_poliza;

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

--ACTUALIZACIÓN DE ENDOSO
LET _error = 0;
CALL sp_pro493(a_no_poliza, _no_endoso, 1.00) RETURNING _error, _error_desc;

IF _error = 1 THEN
	RETURN 1, _error_desc;
END IF

SELECT SUM(prima_suscrita),
		SUM(prima_retenida),
		SUM(prima),
		SUM(descuento),
		SUM(recargo),
		SUM(prima_neta),
		SUM(impuesto),
		SUM(prima_bruta),
		SUM(suma_asegurada),
		SUM(gastos)
  INTO  v_prima_suscrita,
		v_prima_retenida,
		v_prima,
		v_total_descto,
		v_porc_recargo,
		v_prima_neta,
		v_impuesto,
		v_prima_br,
		v_suma_asegurada,
		v_gastos
  FROM endeduni
 WHERE no_poliza = a_no_poliza
   AND no_endoso = _no_endoso ;
   
  UPDATE endedmae
     SET prima = v_prima,
         descuento = v_total_descto,
         recargo = v_porc_recargo,
         prima_neta = v_prima_neta,
         impuesto = v_impuesto,
         prima_bruta = v_prima_br,
         prima_suscrita = v_prima_suscrita,   
         prima_retenida = v_prima_retenida  
   WHERE ( endedmae.no_poliza = a_no_poliza ) AND  
         ( endedmae.no_endoso = _no_endoso )   ;

LET _error = 0;
CALL sp_pro43(a_no_poliza, _no_endoso) RETURNING _error, _error_desc;

IF _error = 1 THEN
	RETURN 1, _error_desc;
END IF

RETURN 0, "Actualización Exitosa...";

END
END PROCEDURE;

