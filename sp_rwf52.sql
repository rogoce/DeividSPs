-- Procedimiento para Actualizar en la tabla de Cliente - solo telefonos
-- 
-- creado: 11/07/2005 - Autor: Amado Perez.

DROP PROCEDURE sp_rwf52;
CREATE PROCEDURE "informix".sp_rwf52(a_doc_atencion CHAR(10), a_telefono1 CHAR(10), a_telefono2 CHAR(10), a_tipo_atencion SMALLINT) 
			RETURNING SMALLINT, CHAR(50);  


DEFINE _error       		SMALLINT;
DEFINE _no_cheque           INTEGER;
DEFINE _no_requis     		CHAR(10);
DEFINE _cod_cliente			CHAR(10);
DEFINE _transaccion    		CHAR(10);

SET ISOLATION TO DIRTY READ;
--set debug file to "sp_rwf52.trc";
--trace on;

--SET LOCK MODE TO WAIT;

--begin work;

IF a_tipo_atencion = 1 THEN
	BEGIN
		ON EXCEPTION SET _error 
			rollback work;
		 	RETURN _error, "Error al actualizar cliclien";         
		END EXCEPTION 

		LET _no_cheque = a_doc_atencion;
		FOREACH
			SELECT no_requis
			  INTO _no_requis
			  FROM chqchmae
			 WHERE no_cheque = _no_cheque
			   AND origen_cheque = "3"
	   	  ORDER BY no_requis Desc
		  EXIT FOREACH;
		END FOREACH

	    FOREACH
			SELECT transaccion
			  INTO _transaccion
			  FROM chqchrec
			 WHERE no_requis = _no_requis

		    EXIT FOREACH;
		END FOREACH

	    SELECT cod_cliente
		  INTO _cod_cliente
		  FROM rectrmae
		 WHERE transaccion = _transaccion;


		    UPDATE cliclien
			   SET telefono1 = a_telefono1,
			       telefono2 = a_telefono2
			 WHERE cod_cliente = _cod_cliente; 
	END
END IF

--commit work;
--rollback work;


 RETURN 0, "Actualizacion Exitosa";
END PROCEDURE