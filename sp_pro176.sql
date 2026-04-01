-- Procedimiento para Actualizar en la tabla de Cliente - solo correos
-- 
-- creado: 11/10/2006 - Autor: Amado Perez.

DROP PROCEDURE sp_pro176;
CREATE PROCEDURE "informix".sp_pro176(a_documento CHAR(20), a_email VARCHAR(50)) 
			RETURNING SMALLINT, CHAR(50);  


DEFINE _error       		SMALLINT;
DEFINE _no_poliza     		CHAR(10);
DEFINE _cod_cliente			CHAR(10);

SET ISOLATION TO DIRTY READ;
--set debug file to "sp_rwf52.trc";
--trace on;

--SET LOCK MODE TO WAIT;

--begin work;

BEGIN
	ON EXCEPTION SET _error 
		rollback work;
	 	RETURN _error, "Error al actualizar cliclien";         
	END EXCEPTION 

	FOREACH
		SELECT no_poliza
		  INTO _no_poliza
		  FROM emipomae
		 WHERE no_documento = a_documento
   	  ORDER BY no_poliza Desc
	  EXIT FOREACH;
	END FOREACH

	FOREACH
	    SELECT cod_asegurado
		  INTO _cod_cliente
		  FROM emipouni
		 WHERE no_poliza = _no_poliza
	  EXIT FOREACH;
	END FOREACH

    UPDATE cliclien
	   SET e_mail = a_email
	 WHERE cod_cliente = _cod_cliente; 
END

--commit work;
--rollback work;


 RETURN 0, "Actualizacion Exitosa";
END PROCEDURE