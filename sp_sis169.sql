-- Procedimiento que borra los registros de una cotizacion

-- Creado    : 29/05/2012 - Autor: Amado Perez M.
-- Modificado: 29/05/2012 - Autor: Amado Perez M.

-- SIS v.2.0 - DEIVID, S.A.

DROP PROCEDURE sp_sis169;

CREATE PROCEDURE "informix".sp_sis169(a_cotizacion	integer, a_de_emision SMALLINT DEFAULT 0) 
 RETURNING INT,
           CHAR(100);


--SET DEBUG FILE TO "sp_cob185.trc"; 
--TRACE ON;                                                                

DEFINE _cotizacion VARCHAR(10);
DEFINE _error_code INTEGER;

SET ISOLATION TO DIRTY READ;

BEGIN

ON EXCEPTION SET _error_code 
 	RETURN _error_code, 'Error al borrar los datos de la cotizacion';
END EXCEPTION           

LET _cotizacion = a_cotizacion;

DELETE FROM wf_db_autos WHERE nrocotizacion = a_cotizacion;
DELETE FROM wf_autos WHERE nrocotizacion = a_cotizacion;
DELETE FROM wf_coberturas WHERE nrocotizacion = a_cotizacion;
DELETE FROM wf_cotizacion WHERE nrocotizacion = a_cotizacion;
DELETE FROM wf_cotizallave WHERE no_cotiza = a_cotizacion;

IF a_de_emision = 0 THEN
	DELETE FROM emipomae WHERE cotizacion = _cotizacion AND actualizado = 0 AND nueva_renov = "N";
END IF

RETURN 0, 'Eliminacion Exitosa'; 

END 

END PROCEDURE;
