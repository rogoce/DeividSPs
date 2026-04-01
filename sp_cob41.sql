-- Reporte de Totales de Cuentas para una Remesa
-- 
-- Creado    : 21/09/2000 - Autor: Demetrio Hurtado Almanza 
-- Modificado: 13/12/2000 - Autor: Armando Moreno Montenegro.
--
-- SIS v.2.0 - d_cobr_sp_cob41_dw1 - DEIVID, S.A.

DROP PROCEDURE sp_cob41;

CREATE PROCEDURE "informix".sp_cob41(a_compania CHAR(3), a_periodo1 CHAR(7), a_periodo2 CHAR(7))
RETURNING CHAR(25),	 -- Cuenta
		  CHAR(50),	 -- Nombre Cuenta
		  DEC(16,2), -- Debito
		  DEC(16,2), -- Credito
		  CHAR(50);	 -- Compania

DEFINE v_cuenta			 CHAR(25);	
DEFINE v_nombre_cuenta   CHAR(50);
DEFINE v_debito          DEC(16,2);
DEFINE v_credito         DEC(16,2);
DEFINE v_no_remesa		 CHAR(10);
DEFINE v_compania_nombre CHAR(50); 

DEFINE v_renglon         SMALLINT; 
DEFINE _debito	         DEC(16,2);
DEFINE _credito	         DEC(16,2);
LET v_debito = 0;
LET v_credito = 0;
LET _debito = 0;
LET _credito = 0;

-- Nombre de la Compania

LET  v_compania_nombre = sp_sis01(a_compania); 

CREATE TEMP TABLE tmp_prod(
		cuenta		   	CHAR(25)  ,
		debito      	DECIMAL(16,2),
		credito		    DECIMAL(16,2),
		PRIMARY KEY (cuenta)) WITH NO LOG;

-- Lectura de la Tabla de Remesas detalle

SET ISOLATION TO DIRTY READ;
FOREACH WITH HOLD
	-- Informacion de remesas
	SELECT no_remesa
	  INTO v_no_remesa
	  FROM cobremae
	 WHERE periodo >= a_periodo1 and periodo <= a_periodo2
	 AND   actualizado = 1
	 AND   tipo_remesa = "C"	

FOREACH
	SELECT debito,credito,cuenta
	  INTO v_debito,v_credito,v_cuenta
	  FROM cobasien
	 WHERE no_remesa = v_no_remesa


	IF v_cuenta IS NULL or v_cuenta = "" THEN
		CONTINUE FOREACH;
	END IF
			BEGIN
            ON EXCEPTION IN(-239)
               UPDATE tmp_prod
                      SET debito = debito + v_debito,
						  credito = credito + v_credito
		       WHERE cuenta       = v_cuenta;

            END EXCEPTION;
	-- Insercion / Actualizacion a la tabla temporal tmp_prod

				INSERT INTO tmp_prod(
				cuenta,   debito,	  
			    credito
				)
				VALUES(
				v_cuenta,  v_debito,
       		    v_credito
				);
		  	END
		  	LET v_debito = 0;
		  	LET v_credito = 0;

  END FOREACH
END FOREACH;

FOREACH WITH HOLD
 SELECT cuenta, debito, credito
   INTO v_cuenta, v_debito, v_credito
   FROM tmp_prod
   ORDER BY cuenta

 SELECT nombre
   INTO v_nombre_cuenta
   FROM cglctas
  WHERE cuenta = v_cuenta;

	RETURN v_cuenta,			
		   v_nombre_cuenta,  
		   v_debito,         
		   v_credito,        
		   v_compania_nombre
		   WITH RESUME;	 		

END FOREACH;

DROP TABLE tmp_prod;

END PROCEDURE;

