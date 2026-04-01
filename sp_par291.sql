-- Reporte de Totales de Cuentas para una Remesa
-- 
-- Creado    : 21/09/2000 - Autor: Demetrio Hurtado Almanza 
-- Modificado: 21/09/2000 - Autor: Demetrio Hurtado Almanza
--
-- SIS v.2.0 - d_cobr_sp_cob17_dw1 - DEIVID, S.A.

DROP PROCEDURE sp_par291;

CREATE PROCEDURE "informix".sp_par291(a_no_recibo CHAR(10))
RETURNING CHAR(25),	 -- Cuenta
		  CHAR(50),	 -- Nombre Cuenta
		  DEC(16,2), -- Debito
		  DEC(16,2), -- Credito
		  CHAR(50);	 -- Compania

DEFINE v_cuenta			 CHAR(25);	
DEFINE v_nombre_cuenta   CHAR(50);
DEFINE v_debito          DEC(16,2);
DEFINE v_credito         DEC(16,2);
DEFINE v_fecha           DATE;
DEFINE v_periodo		 CHAR(7);
DEFINE v_compania_nombre CHAR(50); 
define a_compania		 char(3);
define _no_remesa		 char(10);
define _renglon			 smallint;

DEFINE _monto	         DEC(16,2);

-- Nombre de la Compania

SET ISOLATION TO DIRTY READ;

let a_compania = "001";
LET v_compania_nombre = sp_sis01(a_compania); 

CREATE TEMP TABLE tmp_prod(
cuenta		   	 CHAR(25),
debito      	 DECIMAL(16,2),
credito		     DECIMAL(16,2)
) WITH NO LOG;

-- Lectura de la Tabla de Remesas

foreach
 SELECT no_remesa,
        renglon
   INTO _no_remesa,
        _renglon
   FROM cobredet
  WHERE no_recibo = a_no_recibo	   	
--    and renglon   = 5

	FOREACH 
	 SELECT SUM(debito),
	        sum(credito),
			cuenta
	   INTO	v_debito,
	        v_credito,	
			v_cuenta	 		
	   FROM cobasien
	  WHERE no_remesa = _no_remesa
	    and renglon   = _renglon
	  GROUP BY cuenta
	  ORDER BY cuenta

		INSERT INTO tmp_prod(
		cuenta,   
		debito,	  
		credito
		)
		VALUES(
		v_cuenta,  
		v_debito,
		v_credito
		);


	END FOREACH

end foreach

FOREACH
 SELECT cuenta, 
        SUM(debito), 
        SUM(credito)
   INTO v_cuenta, 
        v_debito, 
        v_credito
   FROM tmp_prod
  GROUP BY 1
  ORDER BY 1

	SELECT cta_nombre
	  INTO v_nombre_cuenta
	  FROM cglcuentas
	 WHERE cta_cuenta = v_cuenta;

	RETURN v_cuenta,			
		   v_nombre_cuenta,  
		   v_debito,         
		   v_credito,        
		   v_compania_nombre
		   WITH RESUME;	 		

end foreach

DROP TABLE tmp_prod;

END PROCEDURE;

