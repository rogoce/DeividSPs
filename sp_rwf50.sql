-- Procedimiento para Actualizar en la tabla de Atencion al Cliente
-- 
-- creado: 18/05/2005 - Autor: Amado Perez.

DROP PROCEDURE sp_rwf50;
CREATE PROCEDURE "informix".sp_rwf50(a_incidente integer, a_atendido SMALLINT, a_user CHAR(20), a_descripcion CHAR(250)) 
			RETURNING SMALLINT, CHAR(50);  

DEFINE _no_cheque           INTEGER;
DEFINE _cod_cliente			CHAR(10);
DEFINE _no_atencion			CHAR(10);
DEFINE _cod_compania	    CHAR(3);
DEFINE _no_parte    	    CHAR(3);
DEFINE _nombre 				CHAR(100);
DEFINE _telefono1			CHAR(10);
DEFINE _telefono2			CHAR(10);
DEFINE _fecha_in, _fecha_out DATETIME YEAR TO FRACTION (5);

DEFINE _error       		SMALLINT;
DEFINE _descripcion         VARCHAR(50); 

--SET ISOLATION TO DIRTY READ;
--set debug file to "sp_rwf43.trc";
--trace on;

SET LOCK MODE TO WAIT;

begin work;


BEGIN
	ON EXCEPTION SET _error 
		rollback work;
	 	RETURN _error, "Error al actualizar wf_atencion";         
	END EXCEPTION 

    UPDATE wf_atencion
	   SET fecha_out = current,
	       user = a_user,
	       atendido = a_atendido,
		   notas = a_descripcion
	 WHERE incidente = a_incidente; 

END

SELECT fecha_in,
	   fecha_out
  INTO _fecha_in,
       _fecha_out
  FROM wf_atencion
 WHERE incidente = a_incidente;


CALL sp_rwf51(a_user, _fecha_in, _fecha_out) returning _error, _descripcion;

IF _error <> 0 THEN
	rollback work;
	RETURN  _error, "No se pudo insertar en la tabla de wf_bitacora";
END IF


commit work;
--rollback work;


 RETURN 0, "Actualizacion Exitosa";
END PROCEDURE