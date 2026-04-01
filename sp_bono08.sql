
-- 
-- SIS v.2.0 - DEIVID, S.A.


DROP PROCEDURE sp_bono08;

CREATE PROCEDURE "informix".sp_bono08()
RETURNING	char(20),
			DEC(16,2);

DEFINE v_prima_orig       DEC(16,2);
DEFINE v_saldo            DEC(16,2);
DEFINE v_por_vencer       DEC(16,2);
DEFINE v_exigible         DEC(16,2);
DEFINE v_corriente        DEC(16,2);
DEFINE v_monto_30         DEC(16,2);
DEFINE v_monto_60         DEC(16,2);
DEFINE v_monto_90         DEC(16,2);
DEFINE _prima_bruta       DEC(16,2);
DEFINE _monto_recibo      DEC(16,2);
DEFINE _monto_cheque      DEC(16,2);
DEFINE _monto_devolucion  DEC(16,2);
DEFINE _monto             DEC(16,2);
DEFINE _fecha_primer_pago DATE;     
DEFINE _fecha_emision     DATE;     
DEFINE _no_pagos          SMALLINT;
DEFINE _no_requis         CHAR(10);
DEFINE _periodo_cheque    CHAR(7);
DEFINE _pagado            SMALLINT;
DEFINE _fecha_impresion   DATE;
DEFINE _fecha_anulado     DATE;
DEFINE _cod_perpago       CHAR(3);
DEFINE _mes_perpago       SMALLINT;
DEFINE _tipo_periodo      CHAR(1);
DEFINE _dias              INTEGER;
DEFINE _ciclo             INTEGER;
DEFINE _mes_control       SMALLINT;
DEFINE _fecha_char        CHAR(10);
DEFINE _fecha_letra       DATE;
DEFINE _monto_primero     DEC(16,2);
DEFINE _monto_resto       DEC(16,2);
DEFINE _no_factura        CHAR(10);
DEFINE _no_endoso         CHAR(5);
DEFINE _no_documento	  CHAR(20);
DEFINE _cnt               INTEGER;

--SET DEBUG FILE TO "sp_cob33.trc";
--TRACE ON ;

SET ISOLATION TO DIRTY READ;

LET v_prima_orig  = 0;
LET v_saldo       = 0;
LET v_por_vencer  = 0;    
LET v_exigible    = 0;    
LET v_corriente   = 0;   
LET v_monto_30    = 0;    
LET v_monto_60    = 0;    
LET v_monto_90    = 0;

LET _prima_bruta  = 0;

foreach

	select poliza
	  into _no_documento
	  from bonibita
	 where periodo = '2015-10'
	   and descripcion = 'Se excluye Morosidad a mas de 30.'
	   
	select count(*)
      into _cnt
      from bonibita
	 where periodo = '2015-10'
       and poliza = _no_documento;

    if _cnt > 1 then
		continue foreach;
	end if	
 	  
	call sp_cob33e('001','001',_no_documento,'2015-10','31/10/2015') returning v_por_vencer,v_exigible,v_corriente,v_monto_30,v_monto_60,v_saldo;
	if v_monto_30 > 0 then
	else
		return _no_documento,v_monto_30 with resume;
	end if
end foreach
		
END PROCEDURE;
