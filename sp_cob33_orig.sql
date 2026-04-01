-- Procedimiento que Genera la Morosidad para un Documento
-- 
-- Creado    : 28/11/2000 - Autor: Demetrio Hurtado Almanza
-- modificado: 28/11/2000 - Autor: Demetrio Hurtado Almanza
-- 
-- SIS v.2.0 - DEIVID, S.A.

DROP PROCEDURE sp_cob33;

CREATE PROCEDURE "informix".sp_cob33(
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
			DEC(16,2);	-- Saldo
		  	
DEFINE v_prima_orig       DEC(16,2);
DEFINE v_saldo            DEC(16,2);
DEFINE v_por_vencer       DEC(16,2);
DEFINE v_exigible         DEC(16,2);
DEFINE v_corriente        DEC(16,2);
DEFINE v_monto_30         DEC(16,2);
DEFINE v_monto_60         DEC(16,2);
DEFINE v_monto_90         DEC(16,2);

DEFINE _prima_orig        DEC(16,2);
DEFINE _saldo             DEC(16,2);
DEFINE _por_vencer        DEC(16,2);
DEFINE _exigible          DEC(16,2);
DEFINE _corriente         DEC(16,2);
DEFINE _monto_30          DEC(16,2);
DEFINE _monto_60          DEC(16,2);
DEFINE _monto_90          DEC(16,2);

DEFINE _no_poliza        CHAR(10);

SET DEBUG FILE TO "\\NEMESIS\Ancon\Store Procedures\Debug\sp_cob33.trc";
--TRACE ON;

SET ISOLATION TO DIRTY READ;

LET v_por_vencer = 0;
LET v_exigible   = 0;
LET v_corriente  = 0;
LET v_monto_30   = 0;
LET v_monto_60   = 0;
LET v_monto_90   = 0;
LET v_saldo      = 0;

-- Lectura de Polizas	

FOREACH
 SELECT no_poliza
   INTO _no_poliza
   FROM emipomae
  WHERE no_documento = a_no_documento
    AND actualizado  = 1

	CALL sp_cob01(_no_poliza, a_periodo, a_fecha)
	RETURNING	_prima_orig, 
				_saldo,      
				_por_vencer,    
				_exigible,      
				_corriente,    
				_monto_30,      
				_monto_60,      
				_monto_90;

	LET v_por_vencer = v_por_vencer + _por_vencer;
	LET v_exigible   = v_exigible   + _exigible;  
	LET v_corriente  = v_corriente  + _corriente; 
	LET v_monto_30   = v_monto_30   + _monto_30;  
	LET v_monto_60   = v_monto_60   + _monto_60;  
	LET v_monto_90   = v_monto_90   + _monto_90;  
	LET v_saldo      = v_saldo      + _saldo;

trace '';
trace 'total'       || ' ' ||
       v_por_vencer || ' ' ||
       v_corriente  || ' ' ||
       v_monto_30   || ' ' ||
       v_monto_60   || ' ' ||
       v_monto_90;

END FOREACH

RETURN  v_por_vencer,    
		v_exigible,      
		v_corriente,    
		v_monto_30,      
		v_monto_60,      
		v_monto_90,
		v_saldo;      
		
END PROCEDURE;
