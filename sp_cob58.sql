-- Procedimiento que Carga la morosidad de las polizas de un Agente
-- Modificado: 19/12/2000 - Autor: Marquelda Valdelamar

-- SIS v.2.0 - DEIVID, S.A.

--DROP PROCEDURE sp_cob58;

CREATE PROCEDURE "informix".sp_cob58(
a_compania          CHAR(3),
a_agencia           CHAR(3),
a_cod_agente        CHAR(5),
a_periodo           CHAR(10), 
a_fecha             DATE,
a_no_poliza         CHAR(10)
) RETURNING DEC(16,2),	-- prima original
			DEC(16,2),	-- saldo
            DEC(16,2),  -- por_vencer
			DEC(16,2),	-- exigible
			DEC(16,2),	-- corriente
			DEC(16,2),	-- monto_30
			DEC(16,2),	-- monto_60
			DEC(16,2);	-- monto_90

DEFINE _prima_orig	 DEC(16,2);
DEFINE _saldo		 DEC(16,2);
DEFINE _por_vencer   DEC(16,2);
DEFINE _exigible	 DEC(16,2);
DEFINE _corriente	 DEC(16,2);
DEFINE _monto_30	 DEC(16,2);
DEFINE _monto_60	 DEC(16,2);
DEFINE _monto_90	 DEC(16,2);

DEFINE v_prima_orig	 DEC(16,2);
DEFINE v_saldo		 DEC(16,2);
DEFINE v_por_vencer  DEC(16,2);
DEFINE v_exigible	 DEC(16,2);
DEFINE v_corriente	 DEC(16,2);
DEFINE v_monto_30	 DEC(16,2);
DEFINE v_monto_60	 DEC(16,2);
DEFINE v_monto_90	 DEC(16,2);

LET v_prima_orig  = 0;
LET v_saldo       = 0;
LET v_por_vencer  = 0;    
LET v_exigible    = 0;    
LET v_corriente   = 0;   
LET v_monto_30    = 0;    
LET v_monto_60    = 0;    
LET v_monto_90    = 0;

SET ISOLATION TO DIRTY READ;

-- Morosidad para un documento
CALL sp_cob01(
	a_no_poliza, 
	a_periodo, 
	a_fecha
   	) RETURNING _prima_orig, 
				_saldo,      
				_por_vencer,    
				_exigible,      
				_corriente,    
				_monto_30,      
				_monto_60,      
				_monto_90;

   LET v_prima_orig = _prima_orig + v_prima_orig;
   LET v_saldo      = _saldo      + v_saldo;
   LET v_por_vencer = _por_vencer + v_por_vencer;
   LET v_exigible   = _exigible   + v_exigible;
   LET v_corriente  = _corriente  + v_corriente;
   LET v_monto_30   = _monto_30   + v_monto_30;
   LET v_monto_60   = _monto_60   + v_monto_60;
   LET v_monto_90   = _monto_90   + v_monto_90;

RETURN  v_prima_orig,
		v_saldo,
		v_por_vencer, 
		v_exigible,      
		v_corriente,    
		v_monto_30,      
		v_monto_60,      
		v_monto_90;
END PROCEDURE;
