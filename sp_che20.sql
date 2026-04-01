-- Registros Contables de Cheques de Devolucion de Primas 
-- Anulados en Periodos siguientes al periodo del cheque
-- 
-- Creado    : 06/09/2002 - Autor: Demetrio Hurtado Almanza 
-- Modificado: 06/09/2002 - Autor: Demetrio Hurtado Almanza 
--
-- SIS v.2.0 - d_cheq_sp_che20_dw1 DEIVID, S.A.

DROP PROCEDURE sp_che20;

CREATE PROCEDURE "informix".sp_che20(a_compania CHAR(3), a_fecha_anulado1 DATE, a_fecha_anulado2 DATE)
RETURNING CHAR(25),	 -- Cuenta
		  CHAR(50),	 -- Nombre Cuenta
		  DEC(16,2), -- Debito
		  DEC(16,2), -- Credito
		  CHAR(50),	 -- Compania
		  INTEGER;  -- Tipo de Remesa

DEFINE _no_requis		 CHAR(10);	
DEFINE v_cuenta			 CHAR(25);	
DEFINE v_debito          DEC(16,2);
DEFINE v_credito         DEC(16,2);

DEFINE _tipo_cheque      INTEGER;

DEFINE v_nombre_cuenta   CHAR(50);
DEFINE v_compania_nombre CHAR(50); 

DEFINE _cantidad         INTEGER;

--SET DEBUG FILE TO "sp_che19.trc"; 

LET  v_compania_nombre = sp_sis01(a_compania); 

CREATE TEMP TABLE tmp_prod(
	tipo_cheque		INTEGER,
	cuenta		   	CHAR(25),
	debito      	DECIMAL(16,2),
	credito		    DECIMAL(16,2)
	) WITH NO LOG;

SET ISOLATION TO DIRTY READ;

-- Cheques Anulados

FOREACH
 SELECT no_requis,
        no_cheque
   INTO _no_requis,
        _tipo_cheque
   FROM chqchmae m
  WHERE m.pagado        = 1
    AND m.fecha_anulado >= a_fecha_anulado1
    AND m.fecha_anulado <= a_fecha_anulado2
	AND m.origen_cheque = "6"
	AND m.anulado       = 1

	SELECT COUNT(*)
	  INTO _cantidad
	  FROM chqchcta
	 WHERE no_requis = _no_requis
	   AND cuenta[1,3] IN ("144", "131")
	   AND credito   <> 0.00;

	LET _tipo_cheque = 1;
	--LET v_credito = v_debito;
	--LET v_debito = 0.00;

	IF _cantidad = 0 THEN


	   FOREACH
		SELECT debito,
			   credito,
			   cuenta
		  INTO v_debito,
		       v_credito,
		       v_cuenta
		  FROM chqchcta
		 WHERE no_requis   = _no_requis
--		   AND cuenta[1,3] IN ("144", "131")


			INSERT INTO tmp_prod(
			tipo_cheque,
			cuenta,   
			debito,	  
		    credito
			)
			VALUES(
			_tipo_cheque,
			v_cuenta,  
			v_debito,
			v_credito
			);


		END FOREACH

	END IF

END FOREACH

FOREACH
 SELECT tipo_cheque,
 		cuenta, 
        SUM(debito), 
        SUM(credito)
   INTO _tipo_cheque,
   		v_cuenta, 
        v_debito, 
        v_credito
   FROM tmp_prod
  GROUP BY 1, 2
  ORDER BY 1, 2

	 SELECT nombre
	   INTO v_nombre_cuenta
	   FROM cglctas
	  WHERE cuenta = v_cuenta;

	RETURN v_cuenta,			
		   v_nombre_cuenta,  
		   v_debito,         
		   v_credito,        
		   v_compania_nombre,
		   _tipo_cheque
		   WITH RESUME;	 		

END FOREACH;

DROP TABLE tmp_prod;

END PROCEDURE;
