-- Impresion del Cheque
--
-- Creado    : 29/09/2000 - Autor: Lic. Armando Moreno 
-- Modificado: 29/09/2000 - Autor: Lic. Armando Moreno
-- Modificado: 30/10/2000 - Autor: Demetrio Hurtado ALmanza
--
-- SIS v.2.0 d_- DEIVID, S.A.

--DROP PROCEDURE sp_ammm01;

CREATE PROCEDURE "informix".sp_ammm01()
  RETURNING DATE,
			CHAR(100),
		    DECIMAL(16,2), 
			CHAR(250);

DEFINE v_monto        DECIMAL(16,2);
DEFINE v_monto_letras CHAR(250);    
	let v_monto = 500;
	LET v_monto_letras = sp_sis11(v_monto);

	RETURN  TODAY,
			"TESORO NACINAL. (5%PRIMAS DE INCENDIO) RUC.30746-0002-240130 DV 720123123456789812345678991234567891",
			v_monto,
			v_monto_letras
			WITH RESUME;

END PROCEDURE;
