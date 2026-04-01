-- Reporte de Totales de Cuentas para una Remesa
-- 
-- Creado    : 21/09/2000 - Autor: Demetrio Hurtado Almanza 
-- Modificado: 13/12/2000 - Autor: Armando Moreno Montenegro.
--
-- SIS v.2.0 - d_cobr_sp_cob40_dw1 - DEIVID, S.A.

DROP PROCEDURE sp_cob40b;

CREATE PROCEDURE "informix".sp_cob40b(a_compania CHAR(3), a_periodo1 CHAR(7), a_periodo2 CHAR(7))
RETURNING CHAR(10),
          CHAR(25),	 -- Cuenta
		  CHAR(50),	 -- Nombre Cuenta
		  DEC(16,2), -- Debito
		  DEC(16,2), -- Credito
		  CHAR(50),	 -- Compania
		  CHAR(1);	 -- Tipo de Remesa

DEFINE v_cuenta			 CHAR(25);	
DEFINE v_nombre_cuenta   CHAR(50);
DEFINE v_debito          DEC(16,2);
DEFINE v_credito         DEC(16,2);
DEFINE v_no_remesa		 CHAR(10);
DEFINE v_compania_nombre CHAR(50); 

DEFINE v_renglon         SMALLINT; 
DEFINE _debito	         DEC(16,2);
DEFINE _credito	         DEC(16,2);
DEFINE v_tipo_remesa	 CHAR(1);

LET v_debito  = 0;
LET v_credito = 0;
LET _debito   = 0;
LET _credito  = 0;

-- Nombre de la Compania

LET  v_compania_nombre = sp_sis01(a_compania); 

CREATE TEMP TABLE tmp_prod(
		tipo_remesa		CHAR(1),
		cuenta		   	CHAR(25),
		debito      	DECIMAL(16,2),
		credito		    DECIMAL(16,2),
		no_remesa		char(10)
		) WITH NO LOG;

-- Lectura de la Tabla de Remesas detalle

SET ISOLATION TO DIRTY READ;

FOREACH 
 SELECT no_remesa,
        tipo_remesa
   INTO v_no_remesa,
        v_tipo_remesa
   FROM cobremae
  WHERE periodo    >= a_periodo1 
    AND periodo    <= a_periodo2
    AND actualizado = 1
	AND tipo_remesa NOT IN ("A","M")
--	and no_remesa   = "70971"
		
	IF v_tipo_remesa = "A" Or
	   v_tipo_remesa = "M" THEN
	   LET v_tipo_remesa = "R";
	ELSE
	   LET v_tipo_remesa = "C";
	END IF

   FOREACH
	   SELECT debito,
		      credito,
			  cuenta
		 INTO v_debito,
		      v_credito,
		      v_cuenta
		 FROM cobasien
		WHERE no_remesa = v_no_remesa

		INSERT INTO tmp_prod(
		tipo_remesa,
		cuenta,   
		debito,	  
	    credito,
		no_remesa
		)
		VALUES(
		v_tipo_remesa,
		v_cuenta,  
		v_debito,
		v_credito,
		v_no_remesa
		);

   END FOREACH

END FOREACH;

FOREACH
 SELECT no_remesa,
        tipo_remesa,
        cuenta, 
        debito, 
        credito
   INTO v_no_remesa,
        v_tipo_remesa,
   		v_cuenta, 
        v_debito, 
        v_credito
   FROM tmp_prod
  ORDER BY 1, 2

	SELECT cta_nombre
	  INTO v_nombre_cuenta
	  FROM cglcuentas
	 WHERE cta_cuenta = v_cuenta;

	RETURN v_no_remesa,
	       v_cuenta,			
		   v_nombre_cuenta,  
		   v_debito,         
		   v_credito,        
		   v_compania_nombre,
		   v_tipo_remesa
		   WITH RESUME;	 		

END FOREACH;

DROP TABLE tmp_prod;

END PROCEDURE;

