-- Cheques pagados a:

-- Creado    : 30/01/2002 - Autor: Amado Perez Mendoza 

-- SIS v.2.0 - - DEIVID, S.A.

DROP PROCEDURE sp_che39;

CREATE PROCEDURE sp_che39(a_a_nombre_de  CHAR(100)) 
RETURNING INT,
          DATE,
          CHAR(100),
          DEC(16,2),
          CHAR(7);

-- Otras Variables

DEFINE v_no_cheque        INT;     
DEFINE v_fecha_impresion  DATE;	
DEFINE v_a_nombre_de   	  CHAR(100);	
DEFINE v_monto   	      DEC(16,2);
DEFINE v_periodo  	      CHAR(7);
	

SET ISOLATION TO DIRTY READ;

let a_a_nombre_de = "%" || trim(a_a_nombre_de) || "%";

FOREACH
  SELECT no_cheque,   
         fecha_impresion,   
         a_nombre_de,   
         monto,   
         periodo  
	INTO v_no_cheque,
	     v_fecha_impresion,
		 v_a_nombre_de,   
		 v_monto,   
		 v_periodo  
    FROM chqchmae  
   WHERE TRIM(a_nombre_de) LIKE TRIM(a_a_nombre_de)
     AND pagado = 1 
     AND anulado = 0  
     AND fecha_impresion >= "01/01/2003" 
     AND fecha_impresion <= today
--	 AND monto           > 400

  RETURN v_no_cheque,
         v_fecha_impresion,
		 v_a_nombre_de,   
		 v_monto,   
		 v_periodo
		 with resume;

END FOREACH

END PROCEDURE;