-- Procedimiento para generacion de Orden de Compra y de Reparacion
-- 
-- creado: 20/12/2004 - Autor: Amado Perez.

DROP PROCEDURE trsincli;
CREATE PROCEDURE "informix".trsincli() 
			RETURNING CHAR(10),CHAR(10),CHAR(18),CHAR(10);  

DEFINE _transaccion 		CHAR(10);
DEFINE _cod_cliente			CHAR(10);
DEFINE _no_tranrec			CHAR(10);
DEFINE _numrecla			CHAR(18);
DEFINE _cod_cliente2		CHAR(10);

--SET ISOLATION TO DIRTY READ;
--set debug file to "sp_rwf43.trc";
--trace on;
--begin work;


FOREACH WITH HOLD

	SELECT no_tranrec,
	       transaccion,
		   numrecla,
		   cod_cliente
	  INTO _no_tranrec,
		   _transaccion,
		   _numrecla,
		   _cod_cliente
	  FROM rectrmae
	 WHERE actualizado = 1

	LET _cod_cliente2 = NULL;

	SELECT cod_cliente
	  INTO _cod_cliente2
	  FROM cliclien
	 WHERE cod_cliente = _cod_cliente; 

    IF _cod_cliente2 IS NULL OR _cod_cliente2 = "" THEN 
		RETURN _no_tranrec, _transaccion, _numrecla, _cod_cliente WITH RESUME;
	END IF
END FOREACH
END PROCEDURE