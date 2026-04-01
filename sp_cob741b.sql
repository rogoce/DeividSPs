-- Procedimiento que Genera la Morosidad para un Documento
-- 
-- Creado    : 28/11/2000 - Autor: Amado Perez
-- Igual al sp_cob33 pero se trabaja con la prima neta
-- SIS v.2.0 - DEIVID, S.A.

DROP PROCEDURE sp_cob741b;

CREATE PROCEDURE "informix".sp_cob741b(
a_compania     CHAR(3), 
a_sucursal     CHAR(3), 
a_no_documento CHAR(20),
a_periodo      CHAR(7),
a_fecha        DATE     
) RETURNING	DEC(16,2),  -- Saldo sin impuesto
			DEC(16,2);	-- Saldo
		  	
DEFINE v_prima_orig       DEC(16,2);
DEFINE v_prima_orig_imp   DEC(16,2);
DEFINE v_prima_orig_ver   DEC(16,2);
DEFINE v_saldo            DEC(16,2);
DEFINE v_saldo_imp        DEC(16,2);
DEFINE v_saldo_ver        DEC(16,2);

DEFINE _prima_bruta_ver    DEC(16,2);
DEFINE _prima_bruta, _prima_bruta_imp DEC(16,2);
DEFINE _monto_recibo      DEC(16,2);
DEFINE _monto_recibo_imp  DEC(16,2);
DEFINE _monto_recibo_ver  DEC(16,2);
DEFINE _monto_cheque      DEC(16,2);
DEFINE _monto_cheque_imp  DEC(16,2);
DEFINE _monto_cheque_ver  DEC(16,2);
DEFINE _monto_devolucion  DEC(16,2);
DEFINE _monto_devolucion_imp DEC(16,2);
DEFINE _monto_devolucion_ver DEC(16,2);
DEFINE _monto, _monto_imp DEC(16,2);

DEFINE _fecha_primer_pago DATE;     
DEFINE _no_pagos          SMALLINT; 

DEFINE _no_requis, _no_poliza CHAR(10);
DEFINE _periodo_cheque    CHAR(7);
DEFINE _pagado            SMALLINT;
DEFINE _fecha_impresion   DATE;
DEFINE _fecha_anulado     DATE;

DEFINE _cod_perpago, _cod_impuesto CHAR(3);
DEFINE _mes_perpago       SMALLINT;
DEFINE _tipo_periodo      CHAR(1);
DEFINE _dias              INTEGER;
DEFINE _ciclo             INTEGER;
DEFINE _mes_control       SMALLINT;
DEFINE _fecha_char        CHAR(10);
DEFINE _fecha_letra       DATE;
DEFINE _monto_primero     DEC(16,2);
DEFINE _monto_resto       DEC(16,2);
DEFINE _factor_impuesto   DEC(5,2);
DEFINE _factor_impuesto_t DEC(16,2);  
DEFINE _cod_tipoprod      CHAR(3);   
DEFINE _tipo_produccion   SMALLINT;     

DEFINE _no_factura        CHAR(10);

SET ISOLATION TO DIRTY READ;
--SET DEBUG FILE TO "\\NEMESIS\Ancon\Store Procedures\Debug\sp_cob33.trc";
--TRACE ON ;

LET v_prima_orig  = 0;
LET v_saldo       = 0;
LET v_saldo_imp   = 0;   
LET _factor_impuesto = 0;
LET _factor_impuesto_t = 0;

LET _prima_bruta  = 0;
LET _prima_bruta_imp = 0;
LET _prima_bruta_ver = 0;

-- Facturas

LET _monto        = 0;
LET _monto_imp    = 0;       


FOREACH
 SELECT prima_neta, prima_bruta, no_poliza
   INTO _monto, _monto_imp, _no_poliza
   FROM endedmae
  WHERE no_documento   = a_no_documento	-- Facturas de la Poliza
    AND actualizado    = 1			    -- Factura este Actualizada
    AND periodo       <= a_periodo	    -- No Incluye Periodos Futuros
	AND activa         = 1

 SELECT cod_tipoprod
   INTO _cod_tipoprod
   FROM emipomae
  WHERE no_poliza = _no_poliza;    

 SELECT tipo_produccion
   INTO _tipo_produccion
   FROM emitipro
  WHERE cod_tipoprod = _cod_tipoprod;
 
 LET _prima_bruta_ver = _prima_bruta_ver + _monto_imp;

 IF _tipo_produccion = 2 THEN

	 LET _prima_bruta = _prima_bruta + _monto;
	 LET _prima_bruta_imp = _prima_bruta_imp + _monto_imp;

	 IF _prima_bruta_imp IS NULL THEN
		LET _prima_bruta_imp = 0;
		LET _prima_bruta = 0;
	    LET v_prima_orig_imp = _prima_bruta_imp;
		LET v_prima_orig = _prima_bruta;
--		CONTINUE FOREACH;
	 END IF

 END IF
END FOREACH

LET v_prima_orig_imp = _prima_bruta_imp;
LET v_prima_orig = _prima_bruta;
LET v_prima_orig_ver = _prima_bruta_ver;

-- Recibos

LET _monto_recibo = 0;
LET _monto_recibo_imp = 0;
LET _monto_recibo_ver = 0;
LET _monto        = 0;
LET _monto_imp    = 0;

FOREACH
 SELECT prima_neta, monto, no_poliza
   INTO _monto, _monto_imp, _no_poliza
   FROM cobredet
  WHERE doc_remesa   = a_no_documento	-- Recibos de la Poliza
    AND actualizado  = 1			    -- Recibo este actualizado
    AND tipo_mov     IN ('P', 'N', 'X')		-- Pago de Prima(P) y Notas de Credito(N)
    AND periodo     <= a_periodo	    -- No Incluye Periodos Futuros

 LET _monto_recibo_ver = _monto_recibo_ver + _monto_imp;

 SELECT cod_tipoprod
   INTO _cod_tipoprod
   FROM emipomae
  WHERE no_poliza = _no_poliza;    

 SELECT tipo_produccion
   INTO _tipo_produccion
   FROM emitipro
  WHERE cod_tipoprod = _cod_tipoprod;

 IF _tipo_produccion = 2 THEN

	 LET _monto_recibo_imp = _monto_recibo_imp + _monto_imp;

	 IF _monto_recibo_imp IS NULL THEN
		LET _monto_recibo_imp = 0;
	    LET _monto_recibo = 0;
		CONTINUE FOREACH;
	 END IF

	 LET _factor_impuesto_t = 0;

	 FOREACH
	  SELECT a.cod_impuesto
	    INTO _cod_impuesto
	    FROM emipolim a
	   WHERE a.no_poliza = _no_poliza
	   GROUP BY a.cod_impuesto

	  SELECT factor_impuesto
	    INTO _factor_impuesto
	    FROM prdimpue
	   WHERE cod_impuesto = _cod_impuesto;

	  LET _factor_impuesto_t = _factor_impuesto_t + _factor_impuesto;
	 END FOREACH

	 LET _factor_impuesto_t = 1 + (_factor_impuesto_t / 100);
	 LET _monto_recibo = _monto_recibo_imp / _factor_impuesto_t;

 END IF

 IF _monto_recibo_ver IS NULL THEN
	LET _monto_recibo_ver = 0;
 END IF

END FOREACH
 
-- Cheques de Devolucion de Primas

LET _monto_devolucion = 0;
LET _monto_devolucion_imp = 0;
LET _monto_devolucion_ver = 0;

FOREACH
 SELECT prima_neta,
        monto,
        no_requis,
		no_poliza
   INTO _monto_cheque,
        _monto_cheque_imp,
	    _no_requis,
	    _no_poliza	
   FROM chqchpol
  WHERE no_documento   = a_no_documento

 SELECT cod_tipoprod
   INTO _cod_tipoprod
   FROM emipomae
  WHERE no_poliza = _no_poliza;    

 SELECT tipo_produccion
   INTO _tipo_produccion
   FROM emitipro
  WHERE cod_tipoprod = _cod_tipoprod;

 LET _monto_cheque_ver = _monto_cheque_imp;

 IF _tipo_produccion = 2 THEN

	SELECT pagado,
		   periodo,
		   fecha_impresion,
		   fecha_anulado
	  INTO _pagado,
	       _periodo_cheque,
		   _fecha_impresion,
		   _fecha_anulado
	  FROM chqchmae
	 WHERE no_requis = _no_requis;

	IF _pagado = 1 THEN
		IF _fecha_impresion > a_fecha THEN
			LET _monto_cheque = 0;
			LET _monto_cheque_imp = 0;
		ELSE
			IF _fecha_anulado IS NOT NULL THEN
				IF _fecha_anulado <= a_fecha	THEN
					LET _monto_cheque = 0;
					LET _monto_cheque_imp = 0;
				END IF
			END IF
		END IF				
	ELSE
		LET _monto_cheque = 0;
		LET _monto_cheque_imp = 0;
	END IF	
	
	IF _monto_cheque_imp IS NULL THEN
		LET _monto_cheque_imp = 0;
		LET _monto_cheque = 0;
		CONTINUE FOREACH;
	END IF		
	LET _monto_devolucion_imp = _monto_devolucion_imp - _monto_cheque_imp; 	

 	LET _factor_impuesto_t = 0;

	 FOREACH
	  SELECT a.cod_impuesto
	    INTO _cod_impuesto
	    FROM emipolim a
	   WHERE a.no_poliza = _no_poliza
	   GROUP BY a.cod_impuesto

		  SELECT factor_impuesto
		    INTO _factor_impuesto
			FROM prdimpue
		   WHERE cod_impuesto = _cod_impuesto;

		   LET _factor_impuesto_t = _factor_impuesto_t + _factor_impuesto;
	 END FOREACH

	 LET _factor_impuesto_t = 1 + (_factor_impuesto_t / 100);
	 LET _monto_devolucion = _monto_devolucion_imp / _factor_impuesto_t;
  END IF

	SELECT pagado,
		   periodo,
		   fecha_impresion,
		   fecha_anulado
	  INTO _pagado,
	       _periodo_cheque,
		   _fecha_impresion,
		   _fecha_anulado
	  FROM chqchmae
	 WHERE no_requis = _no_requis;

	IF _pagado = 1 THEN
		IF _fecha_impresion > a_fecha THEN
			LET _monto_cheque_ver = 0;
		ELSE
			IF _fecha_anulado IS NOT NULL THEN
				IF _fecha_anulado <= a_fecha	THEN
					LET _monto_cheque_ver = 0;
				END IF
			END IF
		END IF				
	ELSE
		LET _monto_cheque_ver = 0;
	END IF	
	
	IF _monto_cheque_ver IS NULL THEN
		LET _monto_cheque_ver = 0;
	END IF		
	LET _monto_devolucion_ver = _monto_devolucion_ver - _monto_cheque_ver; 	


END FOREACH


-- Realiza la Verificacion de Montos

LET _monto_recibo = _monto_recibo + _monto_devolucion;
LET _prima_bruta  = _prima_bruta  - _monto_recibo;
LET v_saldo       = _prima_bruta;    

LET _monto_recibo_imp = _monto_recibo_imp + _monto_devolucion_imp;
LET _prima_bruta_imp  = _prima_bruta_imp  - _monto_recibo_imp;
LET v_saldo_imp       = _prima_bruta_imp;  
  
LET _monto_recibo_ver = _monto_recibo_ver + _monto_devolucion_ver;
LET _prima_bruta_ver  = _prima_bruta_ver  - _monto_recibo_ver;
LET v_saldo_ver       = _prima_bruta_ver;  

IF v_saldo_ver = 0 THEN
   LET v_saldo = 0;
   LET v_saldo_imp = 0;
END IF

RETURN  v_saldo,
		v_saldo_imp;   
		
END PROCEDURE;
