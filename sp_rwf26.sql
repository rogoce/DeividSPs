-- Consulta de Pagos de una Transaccion

-- Creado    : 25/06/2004 - Autor: Amado Perez M.
-- Modificado: 25/06/2004 - Autor: Amado Perez M.

-- SIS v.2.0 -  - DEIVID, S.A.

DROP PROCEDURE sp_rwf26;

CREATE PROCEDURE sp_rwf26(a_no_tranrec CHAR(10) default "%")
RETURNING char(5),
      	  varchar(50),
		  varchar(20),
          varchar(20);

define v_cod_concepto		char(3);
define v_desc_concepto		varchar(50);
define v_monto       	    dec(16,2);
define v_monto_tot     	    dec(16,2);

--set debug file to "sp_rwf02.trc";

SET ISOLATION TO DIRTY READ;

LET v_monto_tot	= 0;

FOREACH
	SELECT cod_concepto,
	       monto
	  INTO v_cod_concepto,
		   v_monto       	
	  FROM rectrcon 		  
	 WHERE no_tranrec = a_no_tranrec

    LET v_monto_tot	= v_monto_tot +	v_monto;

	SELECT nombre
	  INTO v_desc_concepto
	  FROM recconce
	 WHERE cod_concepto = v_cod_concepto;

	RETURN v_cod_concepto, 
	       v_desc_concepto,
		   v_monto, 
		   v_monto_tot
	 	   WITH RESUME;

END FOREACH

END PROCEDURE;