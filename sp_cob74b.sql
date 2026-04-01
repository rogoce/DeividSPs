-- Procedimiento que Genera la Morosidad para un Documento
-- 
-- Creado    : 28/11/2000 - Autor: Amado Perez
-- Igual al sp_cob33 pero se trabaja con la prima neta
-- SIS v.2.0 - DEIVID, S.A.

DROP PROCEDURE sp_cob74b;

CREATE PROCEDURE "informix".sp_cob74b(
a_compania     CHAR(3), 
a_sucursal     CHAR(3), 
a_no_documento CHAR(20),
a_periodo      CHAR(7),
a_fecha        DATE     
) RETURNING	DEC(16,2),  -- Saldo sin impuesto
			DEC(16,2);	-- Saldo
		  	
DEFINE v_prima_orig       DEC(16,2);
DEFINE v_prima_orig_imp   DEC(16,2);
DEFINE v_saldo            DEC(16,2);
DEFINE v_saldo_imp        DEC(16,2);

DEFINE _prima_bruta, _prima_bruta_imp DEC(16,2);
DEFINE _monto_recibo      DEC(16,2);
DEFINE _monto_recibo_imp  DEC(16,2);
DEFINE _monto_cheque      DEC(16,2);
DEFINE _monto_cheque_imp  DEC(16,2);
DEFINE _monto_devolucion  DEC(16,2);
DEFINE _monto_devolucion_imp DEC(16,2);
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

DEFINE _no_factura        CHAR(10);

--SET DEBUG FILE TO "\\NEMESIS\Ancon\Store Procedures\Debug\sp_cob33.trc";
--TRACE ON ;

LET v_prima_orig       = 0;
LET v_saldo            = 0;
LET v_saldo_imp        = 0;   
LET _factor_impuesto   = 0;
LET _factor_impuesto_t = 0;

LET _prima_bruta      = 0;
LET _prima_bruta_imp  = 0;

-- Facturas

LET _monto     = 0;
LET _monto_imp = 0;       

SET ISOLATION TO DIRTY READ;

let _no_poliza = sp_sis21(a_no_documento);

FOREACH

 SELECT prima_bruta
   INTO _monto_imp
   FROM endedmae
  WHERE no_documento   = a_no_documento	-- Facturas de la Poliza
    AND actualizado    = 1			    -- Factura este Actualizada
    AND periodo       <= a_periodo	    -- No Incluye Periodos Futuros
	AND activa         = 1

 LET _prima_bruta_imp = _prima_bruta_imp + _monto_imp;

END FOREACH

-- Recibos

LET _monto_recibo = 0;
LET _monto_recibo_imp = 0;
LET _monto        = 0;
LET _monto_imp    = 0;

FOREACH
 SELECT monto
   INTO _monto_imp
   FROM cobredet
  WHERE doc_remesa   = a_no_documento	-- Recibos de la Poliza
    AND actualizado  = 1			    -- Recibo este actualizado
    AND tipo_mov     IN ('P','N','X')	-- Pago de Prima(P) y Notas de Credito(N)
    AND periodo     <= a_periodo	    -- No Incluye Periodos Futuros

 LET _monto_recibo_imp = _monto_recibo_imp + _monto_imp;

 IF _monto_recibo_imp IS NULL THEN
	LET _monto_recibo_imp = 0;
    LET _monto_recibo     = 0;
	CONTINUE FOREACH;
 END IF

END FOREACH
 
-- Cheques de Devolucion de Primas

LET _monto_devolucion     = 0;
LET _monto_devolucion_imp = 0;

FOREACH
 SELECT monto,
        no_requis
   INTO _monto_cheque_imp,
	    _no_requis
   FROM chqchpol
  WHERE no_documento   = a_no_documento

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

END FOREACH

-----
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

-- Realiza la Verificacion de Montos

{LET _monto_recibo = _monto_recibo + _monto_devolucion;
LET _prima_bruta  = _prima_bruta  - _monto_recibo;
LET v_saldo       = _prima_bruta;}

LET _monto_recibo_imp = _monto_recibo_imp + _monto_devolucion_imp;
LET _prima_bruta_imp  = _prima_bruta_imp  - _monto_recibo_imp;
LET v_saldo_imp       = _prima_bruta_imp;

LET _factor_impuesto_t = 1 + (_factor_impuesto_t / 100);
LET v_saldo            = v_saldo_imp / _factor_impuesto_t;

IF v_saldo_imp = 0 THEN
   LET v_saldo = 0;
END IF

RETURN  v_saldo,
		v_saldo_imp;   
		
END PROCEDURE;
