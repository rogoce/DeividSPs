-- Reporte de la Facturacion de Salud

-- Creado    : 26/04/2001 - Autor: Demetrio Hurtado Almanza 
-- Modificado: 26/04/2001 - Autor: Demetrio Hurtado Almanza

-- SIS v.2.0 - d_prod_sp_pro30b_dw1 - DEIVID, S.A.

DROP PROCEDURE sp_pro30b;

CREATE PROCEDURE sp_pro30b(
a_compania 		 CHAR(3), 
a_sucursal 		 CHAR(3),
a_periodo        CHAR(7),
a_fecha_desde	 date,
a_fecha_hasta	 date
) RETURNING CHAR(20),	-- Poliza
			CHAR(10),	-- Factura
			DATE,		-- Vigencia Inicial
			DATE,		-- Vigencia Final
			CHAR(50),	-- Cliente
			DEC(16,2),	-- Prima Neta
			DEC(16,2),	-- Impuesto
			DEC(16,2),	-- Prima bruta
			CHAR(50),	-- Compania
			DEC(16,2);	-- Prima Retenida

DEFINE _no_poliza       CHAR(10); 
DEFINE _no_documento    CHAR(20); 
DEFINE _no_factura      CHAR(10); 
DEFINE _vigencia_inic   DATE;
DEFINE _vigencia_final  DATE;
DEFINE _prima_neta      DEC(16,2);
DEFINE _impuesto        DEC(16,2);
DEFINE _prima_bruta     DEC(16,2);
DEFINE _prima_retenida  DEC(16,2);

DEFINE _cod_endomov     CHAR(3);  
DEFINE _cod_cliente     CHAR(10);
DEFINE _nombre_cliente  CHAR(50);
DEFINE _nombre_compania CHAR(50);

--SET DEBUG FILE TO "\\NEMESIS\Ancon\Store Procedures\Debug\sp_pro30b.trc"; 
--TRACE ON;                                                                

-- Nombre de la Compania

LET _nombre_compania = sp_sis01(a_compania); 

-- Movimiento de Facturacion de Salud

SELECT cod_endomov
  INTO _cod_endomov
  FROM endtimov
 WHERE tipo_mov = 14;

-- Seleccion de las Facturas

FOREACH
 SELECT no_poliza,
 		no_documento,
	    no_factura,
	    vigencia_inic,
	    vigencia_final,
	    prima_neta,
	    impuesto,
	    prima_bruta,
	    prima_retenida
   INTO _no_poliza,
 		_no_documento,
	    _no_factura,
	    _vigencia_inic,
	    _vigencia_final,
	    _prima_neta,
	    _impuesto,
	    _prima_bruta,
	    _prima_retenida
   FROM endedmae
  WHERE cod_compania   = a_compania
    AND periodo        = a_periodo
	AND cod_endomov    = _cod_endomov
	AND actualizado    = 1
	and vigencia_inic >= a_fecha_desde
	and vigencia_inic <= a_fecha_hasta
ORDER BY no_documento, no_factura

	SELECT cod_contratante
	  INTO _cod_cliente
	  FROM emipomae
	 WHERE no_poliza = _no_poliza;

	SELECT nombre
	  INTO _nombre_cliente
	  FROM cliclien
	 WHERE cod_cliente = _cod_cliente;

	RETURN _no_documento,
		   _no_factura,
		   _vigencia_inic,
		   _vigencia_final,
		   _nombre_cliente,
		   _prima_neta,
		   _impuesto,
		   _prima_bruta,
		   _nombre_compania,
		   _prima_retenida
		   WITH RESUME;

END FOREACH

END PROCEDURE;
