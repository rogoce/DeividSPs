-- Procedimiento para insertar en la tabla de Bitacora
-- 
-- creado: 19/05/2005 - Autor: Amado Perez.

DROP PROCEDURE sp_rwf51;
CREATE PROCEDURE "informix".sp_rwf51(a_user CHAR(20), a_fecha_in DATETIME YEAR TO FRACTION (5), a_fecha_out DATETIME YEAR TO FRACTION (5)) 
			RETURNING SMALLINT, CHAR(50);  

DEFINE _no_cheque           INTEGER;
DEFINE _cod_cliente			CHAR(10);
DEFINE _no_bitacora			CHAR(10);
DEFINE _no_parte    	    CHAR(3);
DEFINE _nombre 				CHAR(100);
DEFINE _telefono1			CHAR(10);
DEFINE _telefono2			CHAR(10);
DEFINE _usuario             CHAR(8);

DEFINE _error       		SMALLINT;

--SET ISOLATION TO DIRTY READ;
--set debug file to "sp_rwf43.trc";
--trace on;
--begin work;

SELECT usuario
  INTO _usuario
  FROM insuser
 WHERE windows_user = a_user;

LET _no_bitacora = sp_sis76();

IF _no_bitacora IS NULL OR _no_bitacora = "" OR _no_bitacora = "00000" THEN
	RETURN 1, "Error al generar # de atencion, verifique...";
END IF	

BEGIN
	ON EXCEPTION SET _error 
	 	RETURN _error, "Error al insertar wf_bitacora";         
	END EXCEPTION 
	INSERT INTO wf_bitacora(
	no_bitacora,
	user,
	fecha_in,
	fecha_out
	)
	VALUES(
	_no_bitacora,
	_usuario,
	a_fecha_in,
	a_fecha_out
	);
END

--commit work;
--rollback work;


 RETURN 0, "Actualizacion Exitosa";
END PROCEDURE