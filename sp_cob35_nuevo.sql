-- Procedimiento que Genera la Morosidad para un Documento
-- 
-- Creado    : 20/02/2001 - Autor: Marquelda Valdelamar
-- 
-- SIS v.2.0 - DEIVID, S.A.

DROP PROCEDURE sp_cob35;

CREATE PROCEDURE "informix".sp_cob35(
a_compania     CHAR(3), 
a_sucursal     CHAR(3), 
a_no_documento CHAR(20),
a_periodo      CHAR(7),
a_fecha        DATE     
) RETURNING	DEC(16,2),	-- Por Vencer
			DEC(16,2),	-- Exigible
			DEC(16,2),	-- Corriente
			DEC(16,2),	-- 30 Dias
			DEC(16,2),	-- 60 Dias
			DEC(16,2),	-- 90 Dias
			DEC(16,2),	-- Saldo
			CHAR(20);   -- no_documento
		  	
DEFINE v_por_vencer       DEC(16,2);
DEFINE v_exigible         DEC(16,2);
DEFINE v_corriente        DEC(16,2);
DEFINE v_monto_30         DEC(16,2);
DEFINE v_monto_60         DEC(16,2);
DEFINE v_monto_90         DEC(16,2);
DEFINE v_saldo            DEC(16,2);

DEFINE _por_vencer       DEC(16,2);
DEFINE _exigible         DEC(16,2);
DEFINE _corriente        DEC(16,2);
DEFINE _monto_30         DEC(16,2);
DEFINE _monto_60         DEC(16,2);
DEFINE _monto_90         DEC(16,2);
DEFINE _saldo            DEC(16,2);

LET v_por_vencer = 0;
LET v_exigible   = 0;
LET v_corriente  = 0;
LET v_monto_30   = 0;
LET v_monto_60   = 0;
LET v_monto_90   = 0;
LET v_saldo      = 0;


--SET DEBUG FILE TO "\\NEMESIS\Ancon\Store Procedures\Debug\sp_cob33.trc";
--TRACE ON ;
CALL sp_cob33(
	a_compania, 
	a_sucursal, 
	a_no_documento,
	a_periodo,
	a_fecha
   	) RETURNING _por_vencer, 
				_exigible,      
				_corriente,    
				_monto_30,      
				_monto_60,      
				_monto_90,
				_saldo;
    
   LET v_por_vencer = _por_vencer + v_por_vencer;
   LET v_exigible   = _exigible   + v_exigible;
   LET v_corriente  = _corriente  + v_corriente;
   LET v_monto_30   = _monto_30   + v_monto_30;
   LET v_monto_60   = _monto_60   + v_monto_60;
   LET v_monto_90   = _monto_90   + v_monto_90;
   LET v_saldo      = _saldo      + v_saldo;

RETURN  v_por_vencer,    
		v_exigible,      
		v_corriente,    
		v_monto_30,      
		v_monto_60,      
		v_monto_90,
		v_saldo,
		a_no_documento;   
END PROCEDURE;
