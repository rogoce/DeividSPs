-- Reporte de Registros Contables de Produccion
-- 
-- Creado    : 29/10/2002 - Autor: Marquelda Valdelamar
-- Modificado: 29/10/2002 - Autor: Marquelda Valdelamar.
--
-- SIS v.2.0 - d_cobr_sp_cob61_dw1 - DEIVID, S.A.

DROP PROCEDURE sp_par125;

CREATE PROCEDURE "informix".sp_par125()
RETURNING CHAR(25),	 -- Cuenta
		  CHAR(50),	 -- Nombre Cuenta
		  DEC(16,2), -- Debito
		  DEC(16,2), -- Credito
		  CHAR(50),	 -- Compania
		  CHAR(1),	 -- Tipo de comprobante
		  DEC(16,2); -- Diferencia

DEFINE v_cuenta			 CHAR(25);	
DEFINE v_nombre_cuenta   CHAR(50);
DEFINE v_debito          DEC(16,2);
DEFINE v_credito         DEC(16,2);
DEFINE v_compania_nombre CHAR(50); 
DEFINE v_tipo_comp       Smallint;
DEFINE v_comprobante     CHAR(25);
define _diferencia		 dec(16,2);

LET v_debito  = 0;
LET v_credito = 0;

-- Nombre de la Compania

SET ISOLATION TO DIRTY READ;

LET  v_compania_nombre = sp_sis01("001"); 

FOREACH
 SELECT tipo_comp,
        cod_cuenta, 
        SUM(debito), 
        SUM(credito)
   INTO v_comprobante,
   		v_cuenta, 
        v_debito, 
        v_credito
   FROM cobincas
  GROUP BY 1, 2
  ORDER BY 1, 2

	let _diferencia = v_debito + v_credito;

	SELECT cta_nombre
	  INTO v_nombre_cuenta
	  FROM cglcuentas
	 WHERE cta_cuenta = v_cuenta;

	RETURN v_cuenta,			
		   v_nombre_cuenta,  
		   v_debito,         
		   v_credito,        
		   v_compania_nombre,
		   v_comprobante,
		   _diferencia
		   WITH RESUME;	 		

END FOREACH;

END PROCEDURE;

