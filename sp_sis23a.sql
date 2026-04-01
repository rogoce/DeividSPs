-- Eliminar la informacion de la Tarjeta de Credito cuando se realiza
-- el cambio de Plan de Pago a una forma que no es tarjeta

-- Creado    : 30/04/2001 - Autor: Demetrio Hurtado Almanza 
-- Modificado: 30/04/2001 - Autor: Demetrio Hurtado Almanza

-- SIS v.2.0 - DEIVID, S.A.

DROP PROCEDURE sp_sis23a;

CREATE PROCEDURE "informix".sp_sis23a(
a_compania	CHAR(3),
a_sucursal	CHAR(3),
a_no_poliza CHAR(10),
a_user		CHAR(8),
a_relac_tar INTEGER,
a_no_cambio	CHAR(3)
) RETURNING INTEGER, CHAR(5), CHAR(5); 

DEFINE _no_tarjeta 		CHAR(19);
DEFINE _cantidad		INTEGER;
DEFINE _no_documento	CHAR(20);
DEFINE _null  			CHAR(1);
DEFINE _error			INTEGER;

DEFINE _cod_endomov		CHAR(3);
DEFINE _periodo			CHAR(7);
DEFINE _vigencia_inic	DATE;  
DEFINE _vigencia_final	DATE;  
DEFINE _no_endoso_char	CHAR(5);
DEFINE _no_endoso_int	INTEGER;
DEFINE _cod_formapag	CHAR(3);
DEFINE _cod_perpago	 	CHAR(3);
DEFINE _no_pagos		INTEGER;
DEFINE _no_unidad       CHAR(5);
DEFINE _no_factura      CHAR(10); 

DEFINE _nombre_pagad	CHAR(100);
DEFINE _cod_pagador		CHAR(10);
DEFINE _fecha_exp		CHAR(7);
DEFINE _cod_banco		CHAR(3);
DEFINE _monto_visa		DEC(16,2);
DEFINE _periodo_tar		CHAR(1);
DEFINE _tipo_tarjeta	CHAR(1);
DEFINE _fecha_1_pago	DATE;
DEFINE _cod_contratante CHAR(10);
DEFINE _no_endoso_ext	CHAR(5);

--SET DEBUG FILE TO "sp_sis23.trc"; 
--TRACE ON;                                                                
SET ISOLATION TO DIRTY READ;

LET _no_endoso_char	= '';
LET _no_unidad   	= '';

BEGIN

ON EXCEPTION SET _error 
 	RETURN _error, _no_endoso_char, _no_unidad;         
END EXCEPTION           

SELECT cod_endomov
  INTO _cod_endomov
  FROM endtimov
 WHERE tipo_mov = 18;

SELECT emi_periodo
  INTO _periodo
  FROM parparam
 WHERE cod_compania = a_compania;
 
LET _null = NULL;

SELECT no_documento,
	   vigencia_inic,
	   vigencia_final,
	   cod_formapag,
	   cod_perpago,
	   no_pagos,
	   cod_contratante
  INTO _no_documento,
	   _vigencia_inic,
	   _vigencia_final,
	   _cod_formapag,
	   _cod_perpago,
	   _no_pagos,
	   _cod_contratante
  FROM emipomae
 WHERE no_poliza = a_no_poliza;

IF a_relac_tar = 1 THEN -- Eliminacion de los Datos de la Tarjeta

	FOREACH
	 SELECT no_tarjeta
	   INTO _no_tarjeta
	   FROM cobtacre
	  WHERE no_documento = _no_documento
		EXIT FOREACH;
	END FOREACH

	UPDATE emipomae
	   SET no_tarjeta    = _null,
	       fecha_exp     = _null,
		   cod_banco     = _null,
		   monto_visa    = 0,
		   tipo_tarjeta  = _null
	 WHERE no_poliza     = a_no_poliza;

	DELETE FROM cobtacre
	 WHERE no_documento = _no_documento;

	SELECT COUNT(*)
	  INTO _cantidad
	  FROM cobtacre
	 WHERE no_tarjeta = _no_tarjeta;

	IF _cantidad IS NULL THEN
		LET _cantidad = 0;
	END IF

	IF _cantidad = 0 THEN
		DELETE FROM cobtahab
		 WHERE no_tarjeta = _no_tarjeta;
	END IF

ELSE

	SELECT cod_pagador,
		   no_tarjeta,
		   fecha_exp,
		   cod_banco,
		   monto_visa,
		   periodo_tar,
		   tipo_tarjeta,
		   cod_perpago,
		   fecha_primer_pago
	  INTO _cod_pagador,
		   _no_tarjeta,
		   _fecha_exp,
		   _cod_banco,
		   _monto_visa,
		   _periodo_tar,
		   _tipo_tarjeta,
		   _cod_perpago,
		   _fecha_1_pago
	  FROM cobcampl
	 WHERE no_documento = _no_documento
	   AND no_cambio    = a_no_cambio; 				

	UPDATE emipomae
	   SET no_tarjeta    = _no_tarjeta,
	       fecha_exp     = _fecha_exp,
		   cod_banco     = _cod_banco,
		   monto_visa    = _monto_visa,
		   tipo_tarjeta  = _tipo_tarjeta
	 WHERE no_poliza     = a_no_poliza;

	SELECT nombre
	  INTO _nombre_pagad
	  FROM cobtahab
	 WHERE no_tarjeta = _no_tarjeta;

	update cobtahab
	   set fecha_exp = _fecha_exp
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
		a_user,
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
		_periodo_tar,
		_monto_visa,
		_fecha_1_pago,
		0,
		0,
		0.00
		);

	END IF

END IF

-- Generacion del Endoso para la Constancia del Cambio

SELECT MAX(no_endoso)
  INTO _no_endoso_int
  FROM endedmae
 WHERE no_poliza = a_no_poliza;

LET _no_endoso_char = sp_set_codigo(5, _no_endoso_int + 1);
LET _no_factura     = sp_sis14(a_compania, a_sucursal, a_no_poliza); 
LET _no_endoso_ext  = sp_sis30(a_no_poliza, _no_endoso_char);

-- Creacion del Endoso

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
no_endoso_ext    
)
VALUES(
a_no_poliza,
_no_endoso_char,
a_compania,
a_sucursal,
'007',
_cod_formapag,
_null,
_cod_perpago,
_cod_endomov,
_no_documento,
_vigencia_inic,
_vigencia_final,
0,
0,
0,
0,
0,
0,
0,
0,
0,
TODAY,
TODAY,
TODAY,
_no_pagos,
1,
_no_factura,
_null,
TODAY,
TODAY,
1,
_periodo,
a_user,
1,
0,
'1',
1,
_vigencia_inic,
_vigencia_final,
_no_endoso_ext    
);

FOREACH 
 SELECT no_unidad
   INTO _no_unidad
   FROM emipouni
  WHERE no_poliza = a_no_poliza
  ORDER BY no_unidad
	EXIT FOREACH;
END FOREACH

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
no_poliza,
_no_endoso_char,
no_unidad,
cod_ruta,
cod_producto,
cod_asegurado,
suma_asegurada,
0,
0,
0,
0,
0,
0,
1,
_vigencia_inic,
_vigencia_final,
0,
'',
0,
0
 FROM emipouni
WHERE no_poliza = a_no_poliza
  AND no_unidad = _no_unidad;

END

RETURN 0, _no_endoso_char, _no_unidad;

END PROCEDURE;
