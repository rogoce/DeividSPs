-- Consulta de Transacciones por requisicion

-- Creado    : 25/06/2004 - Autor: Amado Perez M.
-- Modificado: 25/06/2004 - Autor: Amado Perez M.

-- SIS v.2.0 -  - DEIVID, S.A.

DROP PROCEDURE sp_cwf4;

CREATE PROCEDURE sp_cwf4(a_no_requis CHAR(10) default "%")
RETURNING char(10),
      	  char(10),
		  char(100),
		  dec(16,2),
		  char(20),
		  char(5),
		  char(8),
		  char(100);

define v_no_tranrec     	char(10);
define _cod_cliente 		char(10);
define _cod_reclamante 		char(10);
define _no_reclamo 			char(10);
define v_transaccion    	char(10);
define v_no_documento       char(20);
define v_no_unidad          char(5);
define v_monto		        dec(16,2);
define v_nombre          	char(100);
define v_reclamante         char(100);
define v_user_added         char(8);

--set debug file to "sp_rwf02.trc";

SET ISOLATION TO DIRTY READ;

FOREACH
    SELECT transaccion
	  INTO v_transaccion
	  FROM chqchrec
	 WHERE no_requis = a_no_requis
  ORDER BY transaccion

	SELECT no_tranrec,
	       cod_cliente,
		   transaccion,
		   monto,
		   no_reclamo,
		   user_added
	  INTO v_no_tranrec,
		   _cod_cliente,       	
		   v_transaccion,			
		   v_monto,
		   _no_reclamo,
		   v_user_added
	  FROM rectrmae 		  
	 WHERE transaccion = v_transaccion
	   AND actualizado = 1;
--	 ORDER BY transaccion;

	SELECT nombre
	  INTO v_nombre
	  FROM cliclien
	 WHERE cod_cliente = _cod_cliente;

    SELECT no_documento,
	       no_unidad,
		   cod_reclamante
	  INTO v_no_documento,
	       v_no_unidad,
		   _cod_reclamante
	  FROM recrcmae
	 WHERE no_reclamo = _no_reclamo;

   SELECT nombre 
     INTO v_reclamante
     FROM cliclien
    WHERE cod_cliente = _cod_reclamante;

	RETURN v_no_tranrec, 
	       v_transaccion,
		   v_nombre,       	
		   v_monto,
		   v_no_documento,
		   v_no_unidad,
		   v_user_added,
		   trim(v_reclamante)
	 	   WITH RESUME;

END FOREACH
END PROCEDURE;