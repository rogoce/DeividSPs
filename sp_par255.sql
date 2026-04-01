-- Reporte de Totales de Cuentas para una Remesa
-- 
-- Creado    : 21/09/2000 - Autor: Demetrio Hurtado Almanza 
-- Modificado: 13/12/2000 - Autor: Armando Moreno Montenegro.
--
-- SIS v.2.0 - d_cobr_sp_cob40_dw1 - DEIVID, S.A.

--DROP PROCEDURE sp_par255;

CREATE PROCEDURE "informix".sp_par255()
RETURNING CHAR(25),	 -- Cuenta
		  CHAR(50),	 -- Nombre Cuenta
		  DEC(16,2), -- Debito
		  DEC(16,2);	 -- Tipo de Remesa

DEFINE v_cuenta			 CHAR(25);	
DEFINE v_nombre_cuenta   CHAR(50);
DEFINE v_debito          DEC(16,2);
DEFINE v_credito         DEC(16,2);
DEFINE v_no_remesa		 CHAR(10);

DEFINE v_renglon         SMALLINT; 
DEFINE _debito	         DEC(16,2);
DEFINE _credito	         DEC(16,2);

define _poliza			char(20);

LET v_debito  = 0;
LET v_credito = 0;
LET _debito   = 0;
LET _credito  = 0;


-- Nombre de la Compania

CREATE TEMP TABLE tmp_prod(
		cuenta		   	CHAR(25),
		debito      	DECIMAL(16,2),
		credito		    DECIMAL(16,2)
		) WITH NO LOG;

-- Lectura de la Tabla de Remesas detalle

SET ISOLATION TO DIRTY READ;

foreach 
 select poliza
   into _poliza
   from	deivid_tmp:psc0709

	foreach
	 select	no_remesa,
	        renglon
	   into v_no_remesa,
	        v_renglon
	   from cobredet
	  where doc_remesa  = _poliza
	    and tipo_mov    in ("P", "N")
		and actualizado = 1

	   FOREACH
		SELECT debito,
			   credito,
			   cuenta
		  INTO v_debito,
		       v_credito,
		       v_cuenta
		  FROM cobasien
		 WHERE no_remesa = v_no_remesa
		   and renglon   = v_renglon

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

  END FOREACH

END FOREACH;

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
		   v_credito        
		   WITH RESUME;	 		

END FOREACH;

DROP TABLE tmp_prod;

END PROCEDURE;

