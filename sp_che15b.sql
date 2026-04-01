-- Reporte de Saldos de Banco
-- 
-- Creado    : 09/05/2001 - Autor: Demetrio Hurtado Almanza 
-- Modificado: 09/05/2001 - Autor: Demetrio Hurtado Almanza
--
-- SIS v.2.0 - d_cheq_sp_che15b_dw1 -- DEIVID, S.A.

DROP PROCEDURE sp_che15b;

CREATE PROCEDURE "informix".sp_che15b(a_compania CHAR(3), a_sucursal CHAR(3), a_fecha DATE)
RETURNING CHAR(50),	 --banco
		  DEC(16,2), --saldo anterior
		  DEC(16,2), --db
		  DEC(16,2), --cr
		  DEC(16,2), --saldo
		  CHAR(50);	 --cia

DEFINE v_cod_banco,v_cod_banco1	  CHAR(3);
DEFINE v_nombre	      CHAR(50);
DEFINE v_nombre_banco CHAR(50);
DEFINE v_debito  	  DEC(16,2);
DEFINE v_credito	  DEC(16,2);
DEFINE v_saldo	      DEC(16,2);
DEFINE v_nombre_cia	  CHAR(50);
DEFINE v_flujo_monto_actual	DEC(16,2);
DEFINE v_cero	      DEC(16,2);

--SET DEBUG FILE TO "\\NEMESIS\Ancon\Store Procedures\Debug\sp_che15a.trc";
--TRACE ON;

SET ISOLATION TO DIRTY READ;

LET  v_nombre_cia = sp_sis01(a_compania); 

-- Flujo de Caja del Dia

CALL sp_che15(
a_compania,
a_sucursal,
a_fecha,
a_fecha
);

FOREACH
	SELECT nombre,
		   flujo_monto_act,
		   cod_banco
	  INTO v_nombre_banco,
		   v_flujo_monto_actual,
		   v_cod_banco
	  FROM chqbanco

	 SELECT SUM(db),
			SUM(cr)
	   INTO v_debito,
			v_credito
	   FROM tmp_flujo
      WHERE	banco = v_cod_banco;

   	   LET v_saldo = 0;

	   IF v_flujo_monto_actual IS NULL  THEN
		   LET v_flujo_monto_actual = 0;
	   END IF
	   IF v_debito IS NULL  THEN
		   LET v_debito = 0;
	   END IF

	   IF v_credito IS NULL  THEN
		   LET v_credito = 0;
	   END IF

	   {LET v_debito  = v_debito  * -1; 
	   LET v_credito = v_credito * -1;}
	   LET v_cero  = 0;
	   LET v_saldo = v_flujo_monto_actual + v_debito + v_credito;
	   LET v_cero  = v_saldo + v_flujo_monto_actual + v_debito + v_credito;
	   IF v_cero = 0 THEN
			CONTINUE FOREACH;
	   END IF

	RETURN v_nombre_banco,
		   v_flujo_monto_actual,
		   v_debito,
		   v_credito,
		   v_saldo,
		   v_nombre_cia
		   WITH RESUME;
END FOREACH	

DROP TABLE tmp_flujo;
		
END PROCEDURE;