-- Procedimiento que Genera el saldo neto y el saldo bruto 
-- 
-- Creado    : 30/12/2009 - Autor: Demetrio Hurtado Almanza
-- 
-- SIS v.2.0 - DEIVID, S.A.

DROP PROCEDURE sp_cob223;

CREATE PROCEDURE "informix".sp_cob223(
a_compania     CHAR(3), 
a_sucursal     CHAR(3), 
a_no_documento CHAR(20),
a_periodo      CHAR(7),
a_fecha        DATE
) RETURNING	DEC(16,2),	-- Saldo Neto
			DEC(16,2);	-- Saldo Bruto
		  	
DEFINE v_saldo            DEC(16,2);
DEFINE v_saldo_b      	  DEC(16,2);

DEFINE _prima_neta        DEC(16,2);
DEFINE _prima_bruta       DEC(16,2);
DEFINE _monto_recibo      DEC(16,2);
DEFINE _monto_recibo_b    DEC(16,2);
DEFINE _monto_cheque      DEC(16,2);
DEFINE _monto_cheque_b    DEC(16,2);
DEFINE _monto_devolucion  DEC(16,2);
DEFINE _monto_devolucion_b DEC(16,2);
DEFINE _monto             DEC(16,2);
DEFINE _monto_b           DEC(16,2);

DEFINE _fecha_primer_pago DATE;
DEFINE _fecha_emision	  DATE;
DEFINE _no_pagos          SMALLINT; 

DEFINE _no_requis         CHAR(10);
DEFINE _periodo_cheque    CHAR(7);
DEFINE _pagado            SMALLINT;
DEFINE _fecha_impresion   DATE;
DEFINE _fecha_anulado     DATE;

--SET DEBUG FILE TO "\\NEMESIS\Ancon\Store Procedures\Debug\sp_cob33.trc";
--TRACE ON ;

SET ISOLATION TO DIRTY READ;

LET v_saldo       = 0;
LET v_saldo_b     = 0;

-- Facturas

LET _prima_neta   = 0;
LET _prima_bruta  = 0;
LET _monto        = 0;
LET _monto_b      = 0;

FOREACH
 SELECT prima_neta, prima_bruta
   INTO _monto, _monto_b
   FROM endedmae
  WHERE no_documento   = a_no_documento	-- Facturas de la Poliza
    AND actualizado    = 1			    -- Factura este Actualizada
    AND periodo       <= a_periodo	    -- No Incluye Periodos Futuros
	AND activa         = 1
		LET _prima_neta  = _prima_neta + _monto;
		LET _prima_bruta  = _prima_bruta + _monto_b;
END FOREACH

IF _prima_neta IS NULL THEN
	LET _prima_neta = 0;
END IF
IF _prima_bruta IS NULL THEN
	LET _prima_bruta = 0;
END IF

-- Recibos

LET _monto_recibo = 0;
LET _monto        = 0;
LET _monto_recibo_b = 0;
LET _monto_b        = 0;

FOREACH
 SELECT prima_neta, monto
   INTO _monto, _monto_b
   FROM cobredet
  WHERE doc_remesa   = a_no_documento	-- Recibos de la Poliza
    AND actualizado  = 1			    -- Recibo este actualizado
    AND tipo_mov     IN ('P', 'N', 'X')		-- Pago de Prima(P) y Notas de Credito(N)
    AND periodo     <= a_periodo	    -- No Incluye Periodos Futuros
		LET _monto_recibo = _monto_recibo + _monto;
		LET _monto_recibo_b = _monto_recibo_b + _monto_b;
END FOREACH

IF _monto_recibo IS NULL THEN
	LET _monto_recibo = 0;
END IF
IF _monto_recibo_b IS NULL THEN
	LET _monto_recibo_b = 0;
END IF
 
-- Cheques de Devolucion de Primas

LET _monto_devolucion = 0;
LET _monto_devolucion_b = 0;

FOREACH
 SELECT prima_neta,	monto,
        no_requis
   INTO _monto_cheque, _monto_cheque_b,
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
			LET _monto_cheque_b = 0;
		ELSE
			IF _fecha_anulado IS NOT NULL THEN
				IF _fecha_anulado <= a_fecha	THEN
					LET _monto_cheque = 0;
					LET _monto_cheque_b = 0;
				END IF
			END IF
		END IF				
	ELSE
		LET _monto_cheque = 0;
		LET _monto_cheque_b = 0;
	END IF	
	
	IF _monto_cheque IS NULL THEN
		LET _monto_cheque = 0;
	END IF		
	IF _monto_cheque_b IS NULL THEN
		LET _monto_cheque_b = 0;
	END IF		

	LET _monto_devolucion   = _monto_devolucion - _monto_cheque;	
	LET _monto_devolucion_b = _monto_devolucion_b - _monto_cheque_b;	

END FOREACH

-- Realiza la Verificacion de Montos

LET _monto_recibo = _monto_recibo + _monto_devolucion;
LET _prima_neta   = _prima_neta   - _monto_recibo;
LET v_saldo       = _prima_neta;    

LET _monto_recibo_b = _monto_recibo_b + _monto_devolucion_b;
LET _prima_bruta    = _prima_bruta  - _monto_recibo_b;
LET v_saldo_b       = _prima_bruta;    

	
RETURN  v_saldo, v_saldo_b;   

END PROCEDURE;
