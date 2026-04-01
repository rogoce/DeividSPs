-- Reporte de Totales de Cuentas para una Remesa
-- 
-- Creado    : 21/09/2000 - Autor: Demetrio Hurtado Almanza 
-- Modificado: 21/09/2000 - Autor: Demetrio Hurtado Almanza
--
-- SIS v.2.0 - d_cobr_sp_cob17_dw1 - DEIVID, S.A.

DROP PROCEDURE sp_cob17;

CREATE PROCEDURE "informix".sp_cob17(a_compania CHAR(3), a_remesa CHAR(10))
RETURNING CHAR(25),	 -- Cuenta
		  CHAR(50),	 -- Nombre Cuenta
		  DEC(16,2), -- Debito
		  DEC(16,2), -- Credito
		  DATE,		 -- Fecha
		  CHAR(7),	 -- Periodo
		  CHAR(50);	 -- Compania

DEFINE v_cuenta			 CHAR(25);	
DEFINE v_nombre_cuenta   CHAR(50);
DEFINE v_debito          DEC(16,2);
DEFINE v_credito         DEC(16,2);
DEFINE v_fecha           DATE;
DEFINE v_periodo		 CHAR(7);
DEFINE v_compania_nombre CHAR(50); 

DEFINE _monto	         DEC(16,2);

-- Nombre de la Compania

LET  v_compania_nombre = sp_sis01(a_compania); 

-- Lectura de la Tabla de Remesas

SELECT fecha,
	   periodo
  INTO v_fecha,
	   v_periodo	
  FROM cobremae
 WHERE no_remesa = a_remesa;	   	

FOREACH 
 SELECT SUM(debito - credito),
		cuenta
   INTO	_monto,	
		v_cuenta	 		
   FROM cobasien
  WHERE no_remesa = a_remesa
  GROUP BY cuenta
  ORDER BY cuenta

	SELECT nombre
	  INTO v_nombre_cuenta
	  FROM cglctas
	 WHERE cuenta = v_cuenta;

	IF v_nombre_cuenta IS NULL THEN
		LET v_nombre_cuenta = '... Cuenta No Definida ...';
	END IF

	IF _monto > 0 THEN
		LET v_debito  = _monto;
		LET v_credito = 0;	
	ELSE
		LET v_debito  = 0;
		LET v_credito = _monto * -1;	
	END IF

	RETURN v_cuenta,			
		   v_nombre_cuenta,  
		   v_debito,         
		   v_credito,        
		   v_fecha,          
		   v_periodo,		
		   v_compania_nombre
		   WITH RESUME;	 		

END FOREACH

END PROCEDURE;

