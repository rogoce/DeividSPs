-- Verificacion de Facturas que no Aparecen en CXC

DROP PROCEDURE sp_par07;

CREATE PROCEDURE "informix".sp_par07(a_periodo CHAR(7)) 
RETURNING CHAR(20),
		  CHAR(10),
		  CHAR(10),
		  CHAR(5),
		  DATE,
		  DEC(16,2),
		  CHAR(100);

DEFINE _no_poliza		CHAR(10);
DEFINE _no_endoso		CHAR(5);
DEFINE _cod_tipoprod	CHAR(3);
DEFINE _tipo_produccion	SMALLINT;
DEFINE _no_factura		CHAR(10);
DEFINE _no_documento	CHAR(20);
DEFINE _fecha			DATE;
DEFINE _prima_bruta		DEC(16,2);
DEFINE _prima_suscrita	DEC(16,2);
DEFINE _activa          SMALLINT;
DEFINE _cod_endomov		CHAR(3);

--SET DEBUG FILE TO "\\NEMESIS\Ancon\Store Procedures\Debug\sp_par07.trc";
--trace on;

SET ISOLATION TO DIRTY READ;

FOREACH
 SELECT no_poliza,
		no_endoso,
		prima_bruta,
		no_factura,
		fecha_emision,
		activa,
		prima_suscrita,
		cod_endomov
   INTO _no_poliza,
		_no_endoso,
		_prima_bruta,
		_no_factura,
		_fecha,
		_activa,
		_prima_suscrita,
		_cod_endomov
   FROM endedmae
  WHERE actualizado = 1
    AND periodo     >= '1996-07'
--    AND periodo     = a_periodo
  ORDER BY no_factura

	SELECT cod_tipoprod,
	       no_documento
	  INTO _cod_tipoprod,
		   _no_documento	
	  FROM emipomae
	 WHERE no_poliza = _no_poliza;

	SELECT tipo_produccion
	  INTO _tipo_produccion
	  FROM emitipro
	 WHERE cod_tipoprod = _cod_tipoprod;

	IF _tipo_produccion = 4 THEN
		CONTINUE FOREACH;
	END IF

	IF _prima_bruta <> 0.00 AND
	   _activa      =  0    THEN
		RETURN _no_documento,
		       _no_factura,
		       _no_poliza,
		       _no_endoso,
		       _fecha,
		       _prima_bruta,
		       'Prima Bruta Diferente de Cero y Esta Inactiva'
		       WITH RESUME;
	END IF	   	

	IF _cod_endomov <> '017' THEN

		IF _prima_bruta    = 0.00  AND
		   _prima_suscrita <> 0.00 THEN
			RETURN _no_documento,
			       _no_factura,
			       _no_poliza,
			       _no_endoso,
			       _fecha,
			       _prima_bruta,
			       'Prima Bruta en Cero y Tiene Prima Suscrita'
			       WITH RESUME;
		END IF	   	

	END IF

END FOREACH

END PROCEDURE;
