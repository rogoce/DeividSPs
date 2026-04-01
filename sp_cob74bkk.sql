-- Procedimiento que Genera la Morosidad para un Documento
-- 
-- Creado    : 28/11/2000 - Autor: Amado Perez
-- Igual al sp_cob33 pero se trabaja con la prima neta
-- SIS v.2.0 - DEIVID, S.A.

DROP PROCEDURE sp_cob74bkk;

CREATE PROCEDURE "informix".sp_cob74bkk(
a_compania     CHAR(3), 
a_sucursal     CHAR(3), 
a_no_documento CHAR(20),
a_periodo      CHAR(7),
a_fecha        DATE     
) RETURNING	DEC(16,2),  -- Saldo sin impuesto
			DEC(16,2),	-- Saldo
			DEC(16,2),
			DEC(16,2),
			DEC(16,2),
			DEC(16,2),
			DEC(16,2),
			DEC(16,2);
		  	
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
 SELECT prima_bruta, no_poliza
   INTO _monto_imp, _no_poliza
   FROM endedmae
  WHERE no_documento   = a_no_documento	-- Facturas de la Poliza
    AND actualizado    = 1			    -- Factura este Actualizada
    AND periodo       <= a_periodo	    -- No Incluye Periodos Futuros
	AND activa         = 1

 --LET _prima_bruta     = _prima_bruta     + _monto;
 LET _prima_bruta_imp = _prima_bruta_imp + _monto_imp;

 IF _prima_bruta_imp IS NULL THEN
	LET _prima_bruta_imp = 0;
	LET _prima_bruta = 0;
    LET v_prima_orig_imp = _prima_bruta_imp;
	LET v_prima_orig = _prima_bruta;
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
	 LET _prima_bruta = _prima_bruta_imp / _factor_impuesto_t;

END FOREACH

LET v_prima_orig_imp = _prima_bruta_imp;
LET v_prima_orig     = _prima_bruta;

-- Recibos

LET _monto_recibo     = 0;
LET _monto_recibo_imp = 0;
LET _monto            = 0;
LET _monto_imp        = 0;

FOREACH

	 SELECT prima_neta, monto, no_poliza
	   INTO _monto, _monto_imp, _no_poliza
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
	 LET _monto_recibo      = _monto_recibo_imp / _factor_impuesto_t;

END FOREACH
 
-- Cheques de Devolucion de Primas

LET _monto_devolucion     = 0;
LET _monto_devolucion_imp = 0;


-- Realiza la Verificacion de Montos

--RETURN  0,0,_prima_bruta,_monto_recibo,_monto_devolucion,_prima_bruta_imp,_monto_recibo_imp,_monto_devolucion_imp;   

LET _monto_recibo = _monto_recibo + _monto_devolucion;
LET _prima_bruta  = _prima_bruta  - _monto_recibo;
LET v_saldo       = _prima_bruta;    




LET _monto_recibo_imp = _monto_recibo_imp + _monto_devolucion_imp;
LET _prima_bruta_imp  = _prima_bruta_imp  - _monto_recibo_imp;
LET v_saldo_imp       = _prima_bruta_imp;  
  
IF v_saldo_imp = 0 THEN
   LET v_saldo = 0;
END IF


RETURN  v_saldo,v_saldo_imp,_prima_bruta,_monto_recibo,_monto_devolucion,0,0,0;   
		
END PROCEDURE;
