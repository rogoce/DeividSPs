-- Reporte de Registros Contables de Reclamos
-- 
-- Creado    : 22/01/2003 - Autor: Demetrio Hurtado Almanza
-- Modificado: 22/01/2003 - Autor: Demetrio Hurtado Almanza
--
-- SIS v.2.0 - d_para_sp_par75_dw1 - DEIVID, S.A.

DROP PROCEDURE sp_par75;

CREATE PROCEDURE "informix".sp_par75(a_compania CHAR(3), a_periodo1 CHAR(7), a_periodo2 CHAR(7))
RETURNING CHAR(25),	 -- Cuenta
		  CHAR(50),	 -- Nombre Cuenta
		  DEC(16,2), -- Debito
		  DEC(16,2), -- Credito
		  CHAR(50),	 -- Compania
		  char(25),	 -- Tipo de comprobante
		  DEC(16,2); -- Credito

DEFINE _no_tranrec		 CHAR(10);
DEFINE v_cuenta			 CHAR(25);	
DEFINE v_nombre_cuenta   CHAR(50);
DEFINE v_debito_val      DEC(16,2);
DEFINE v_credito_val     DEC(16,2);
DEFINE v_debito          DEC(16,2);
DEFINE v_credito         DEC(16,2);
DEFINE v_neto	         DEC(16,2);
DEFINE v_compania_nombre CHAR(50); 
DEFINE v_tipo_comp       Smallint;
DEFINE v_comprobante     char(25);

LET v_debito  = 0;
LET v_credito = 0;

-- Nombre de la Compania

LET  v_compania_nombre = sp_sis01(a_compania); 

CREATE TEMP TABLE tmp_prod(
		tipo_comprobante Smallint,
		cuenta		   	 CHAR(25),
		debito      	 DECIMAL(16,2),
		credito		     DECIMAL(16,2)
		) WITH NO LOG;

-- Lectura de la Tabla de Remesas detalle

SET ISOLATION TO DIRTY READ;

FOREACH 
 SELECT no_tranrec
   INTO _no_tranrec
   FROM rectrmae
  WHERE periodo    >= a_periodo1 
    AND periodo    <= a_periodo2
    AND actualizado = 1
--	and transaccion in ("01-402160")

   FOREACH
	SELECT debito,
		   credito,
		   cuenta,
		   tipo_comp
	  INTO v_debito,
	       v_credito,
	       v_cuenta,
		   v_tipo_comp
	  FROM recasien
	 WHERE no_tranrec = _no_tranrec

		INSERT INTO tmp_prod(
		tipo_comprobante,
		cuenta,   
		debito,	  
	    credito
		)
		VALUES(
		v_tipo_comp,
		v_cuenta,  
		v_debito,
		v_credito
		);

  END FOREACH

END FOREACH;

FOREACH
 SELECT tipo_comprobante,
        cuenta, 
        SUM(debito), 
        SUM(credito)
   INTO v_tipo_comp,
   		v_cuenta, 
        v_debito, 
        v_credito
   FROM tmp_prod
  GROUP BY 1, 2
  ORDER BY 1, 2

	let v_comprobante = sp_sac11(2, v_tipo_comp);

	SELECT cta_nombre
	  INTO v_nombre_cuenta
	  FROM cglcuentas
	 WHERE cta_cuenta = v_cuenta;

	let v_neto = v_debito + v_credito;

	RETURN v_cuenta,			
		   v_nombre_cuenta,  
		   v_debito,         
		   v_credito,        
		   v_compania_nombre,
		   v_comprobante,
		   v_neto
		   WITH RESUME;	 		

END FOREACH;

DROP TABLE tmp_prod;

END PROCEDURE;

