-- Procedimiento que Realiza la Busqueda del NO_HOJA
-- Creado    : 31/08/2011 - Autor: Henry Giron
--DROP PROCEDURE sp_sis392;
CREATE PROCEDURE "informix".sp_sis392(a_poliza CHAR(10), a_endoso CHAR(5))
RETURNING CHAR(20);

DEFINE _no_hoja       CHAR(10);
DEFINE _imp_num		  CHAR(20);

--SET DEBUG FILE TO "sp_sis392.trc"; 
--trace on;

FOREACH WITH HOLD	
	SELECT no_hoja
	  INTO _no_hoja
	  FROM endedmae
	 WHERE no_poliza = a_poliza
	   AND no_endoso = a_endoso

	  CALL sp_log001(_no_hoja) RETURNING _imp_num;

	RETURN _imp_num

	  WITH RESUME;

END FOREACH
END PROCEDURE;