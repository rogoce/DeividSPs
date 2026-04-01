-- Consulta de Cobertura de un Reclamo

-- Creado    : 25/06/2004 - Autor: Amado Perez M.
-- Modificado: 25/06/2004 - Autor: Amado Perez M.

-- SIS v.2.0 -  - DEIVID, S.A.

DROP PROCEDURE sp_rwf20;

CREATE PROCEDURE sp_rwf20(a_no_reclamo CHAR(10) default "%")
RETURNING char(10),
      	  char(10),
		  char(100),
		  dec(16,2);

define v_no_tranrec     	char(10);
define _cod_cliente 		char(10);
define v_transaccion    	char(10);
define v_monto		        dec(16,2);
define v_nombre          	char(100);

--set debug file to "sp_rwf02.trc";

SET ISOLATION TO DIRTY READ;

FOREACH
	SELECT no_tranrec,
	       cod_cliente,
		   transaccion,
		   monto
	  INTO v_no_tranrec,
		   _cod_cliente,       	
		   v_transaccion,			
		   v_monto	
	  FROM rectrmae 		  
	 WHERE no_reclamo = a_no_reclamo
	   AND actualizado = 1
	 ORDER BY transaccion

	SELECT nombre
	  INTO v_nombre
	  FROM cliclien
	 WHERE cod_cliente = _cod_cliente;

	RETURN v_no_tranrec, 
	       v_transaccion,
		   v_nombre,       	
		   v_monto			
	 	   WITH RESUME;

END FOREACH
END PROCEDURE;