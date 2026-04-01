-- Registros Contables de Cheques de Devolucion de Primas
-- 
-- Creado    : 28/08/2002 - Autor: Demetrio Hurtado Almanza 
-- Modificado: 28/08/2002 - Autor: Demetrio Hurtado Almanza 
--
-- SIS v.2.0 - d_cheq_sp_che19_dw1 DEIVID, S.A.

DROP PROCEDURE sp_che19;

CREATE PROCEDURE "informix".sp_che19(a_compania CHAR(3), a_periodo1 CHAR(7), a_periodo2 CHAR(7))
RETURNING CHAR(25),	 -- Cuenta
		  CHAR(50),	 -- Nombre Cuenta
		  DEC(16,2), -- Debito
		  DEC(16,2), -- Credito
		  CHAR(50),	 -- Compania
		  CHAR(1);   -- Tipo de Remesa

DEFINE _no_requis		 CHAR(10);	
DEFINE v_cuenta			 CHAR(25);	
DEFINE v_debito          DEC(16,2);
DEFINE v_credito         DEC(16,2);

DEFINE _tipo_cheque      CHAR(1);
DEFINE _fecha_anulado1	 DATE;
DEFINE _fecha_anulado2	 DATE;

DEFINE v_nombre_cuenta   CHAR(50);
DEFINE v_compania_nombre CHAR(50); 

DEFINE _no_poliza        CHAR(10); 
DEFINE _cod_tipoprod     CHAR(3);  
DEFINE _tipo_produccion  SMALLINT; 
DEFINE _cantidad         INTEGER;

--SET DEBUG FILE TO "sp_che19.trc"; 

LET  v_compania_nombre = sp_sis01(a_compania); 

CREATE TEMP TABLE tmp_prod(
	tipo_cheque		CHAR(1),
	cuenta		   	CHAR(25),
	debito      	DECIMAL(16,2),
	credito		    DECIMAL(16,2)
	) WITH NO LOG;

SET ISOLATION TO DIRTY READ;

-- Cheques Pagados

FOREACH
 SELECT no_requis
   INTO _no_requis
   FROM chqchmae m
  WHERE m.pagado        = 1
    AND m.periodo      >= a_periodo1
    AND m.periodo      <= a_periodo2
	AND m.origen_cheque = "6"

	LET _tipo_cheque = "1";

   FOREACH	
	SELECT no_poliza
	  INTO _no_poliza
	  FROM chqchpol
	 WHERE no_requis = _no_requis

		SELECT cod_tipoprod
		  INTO _cod_tipoprod
		  FROM emipomae
		 WHERE no_poliza = _no_poliza;

		SELECT tipo_produccion
		  INTO _tipo_produccion
		  FROM emitipro
		 WHERE cod_tipoprod = _cod_tipoprod;
		 
		 IF _tipo_produccion = 4 THEN
			LET _tipo_cheque = "3";
		 	CONTINUE FOREACH;
		 END IF 	

	END FOREACH


   FOREACH
	SELECT debito,
		   credito,
		   cuenta
	  INTO v_debito,
	       v_credito,
	       v_cuenta
	  FROM chqchcta
	 WHERE no_requis   = _no_requis
	   AND cuenta[1,3] IN ("144", "131")

		LET v_credito = 0.00;

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


END FOREACH

-- Cheques Anulados

LET _fecha_anulado1 = MDY(a_periodo1[6,7], 1, a_periodo1[1,4]);

IF a_periodo2[6,7] = 12 THEN
	LET _fecha_anulado2 = MDY(1, 1, a_periodo2[1,4] + 1);
ELSE
	LET _fecha_anulado2 = MDY(a_periodo2[6,7] + 1, 1, a_periodo2[1,4]);
END IF

FOREACH
 SELECT no_requis
   INTO _no_requis
   FROM chqchmae m
  WHERE m.pagado        = 1
    AND m.fecha_anulado >= _fecha_anulado1
    AND m.fecha_anulado < _fecha_anulado2
	AND m.origen_cheque = "6"
	AND m.anulado       = 1

	LET _tipo_cheque = "2";

   FOREACH	
	SELECT no_poliza
	  INTO _no_poliza
	  FROM chqchpol
	 WHERE no_requis = _no_requis

		SELECT cod_tipoprod
		  INTO _cod_tipoprod
		  FROM emipomae
		 WHERE no_poliza = _no_poliza;

		SELECT tipo_produccion
		  INTO _tipo_produccion
		  FROM emitipro
		 WHERE cod_tipoprod = _cod_tipoprod;
		 
		 IF _tipo_produccion = 4 THEN

--trace "poliza " || _no_poliza || " requis " || _no_requis;

			LET _tipo_cheque = "4";
		 	CONTINUE FOREACH;
		 END IF 	

	END FOREACH

	SELECT COUNT(*)
	  INTO _cantidad
	  FROM chqchcta
	 WHERE no_requis = _no_requis
	   AND cuenta[1,3] IN ("144", "131")
	   AND credito   <> 0.00;

	IF _cantidad = 0 THEN
		IF _tipo_cheque = "2" THEN
			LET _tipo_cheque = "5";
		ELSE
			LET _tipo_cheque = "6";
		END IF
	END IF

   FOREACH
	SELECT debito,
		   credito,
		   cuenta
	  INTO v_debito,
	       v_credito,
	       v_cuenta
	  FROM chqchcta
	 WHERE no_requis   = _no_requis
	   AND cuenta[1,3] IN ("144", "131")

		IF _cantidad = 0 THEN
			LET v_credito = v_debito;
		END IF

		LET v_debito = 0.00;

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

{	LET _monto = v_debito - v_credito;

	IF _monto >= 0.00 THEN
		LET v_debito  = _monto;
		LET v_credito = 0.00;
	ELSE
		LET v_debito  = 0.00;
		LET v_credito = _monto * -1;
	END IF
}
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
