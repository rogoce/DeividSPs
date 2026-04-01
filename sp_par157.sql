-- Reporte de Registros Contables de Reclamos de coaseguro minoritario
-- 
-- Creado    : 22/01/2003 - Autor: Demetrio Hurtado Almanza
-- Modificado: 22/01/2003 - Autor: Demetrio Hurtado Almanza
--
-- SIS v.2.0 - d_para_sp_par157_dw1 - DEIVID, S.A.

DROP PROCEDURE sp_par157;

CREATE PROCEDURE "informix".sp_par157(a_compania CHAR(3), a_periodo1 CHAR(7), a_periodo2 CHAR(7))
RETURNING CHAR(25),	 -- Cuenta
		  CHAR(50),	 -- Nombre Cuenta
		  DEC(16,2), -- Debito
		  DEC(16,2), -- Credito
		  CHAR(50),	 -- Compania
		  CHAR(1);	 -- Tipo de comprobante

DEFINE _no_tranrec		 CHAR(10);
define _transaccion		 char(10);
DEFINE v_cuenta			 CHAR(25);	
DEFINE v_nombre_cuenta   CHAR(50);
DEFINE v_debito_val      DEC(16,2);
DEFINE v_credito_val     DEC(16,2);
DEFINE v_debito          DEC(16,2);
DEFINE v_credito         DEC(16,2);
DEFINE v_compania_nombre CHAR(50); 
DEFINE v_tipo_comp       Smallint;
DEFINE v_comprobante     CHAR(25);

LET v_debito  = 0;
LET v_credito = 0;

-- Nombre de la Compania

LET  v_compania_nombre = sp_sis01(a_compania); 

CREATE TEMP TABLE tmp_prod(
		tipo_comprobante CHAR(1),
		cuenta		   	 CHAR(25),
		debito      	 DECIMAL(16,2),
		credito		     DECIMAL(16,2)
		) WITH NO LOG;

-- Lectura de la Tabla de Remesas detalle

SET ISOLATION TO DIRTY READ;

{
foreach
 select transaccion
   into _transaccion
   from coasmin
  WHERE periodo    >= a_periodo1 
    AND periodo    <= a_periodo2
}

foreach
 SELECT no_tranrec
   INTO _no_tranrec
   FROM rectrmae
  where transaccion in (select transaccion from coasmin)
 --	and no_tranrec  = "157852"

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
   INTO v_comprobante,
   		v_cuenta, 
        v_debito, 
        v_credito
   FROM tmp_prod
  GROUP BY 1, 2
  ORDER BY 1, 2

	SELECT cta_nombre
	  INTO v_nombre_cuenta
	  FROM cglcuentas
	 WHERE cta_cuenta = v_cuenta;

	RETURN v_cuenta,			
		   v_nombre_cuenta,  
		   v_debito,         
		   v_credito,        
		   v_compania_nombre,
		   v_comprobante
		   WITH RESUME;	 		

END FOREACH;

DROP TABLE tmp_prod;

END PROCEDURE;

