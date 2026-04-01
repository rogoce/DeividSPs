-- Informe de Estatus del Reclamo. Encabezado y Detalle de Transacciones
-- Creado    : 17/01/2001 - Autor: Marquelda Valdelamar
-- SIS v.2.0 - DEIVID, S.A.

--DROP PROCEDURE sp_re40c;

CREATE PROCEDURE "informix".sp_re40c(
a_compania     CHAR(3),
a_agencia      CHAR(3),   
a_numrecla     CHAR(18)
)
RETURNING CHAR(18)   -- numrecla
		  		  		         

SET ISOLATION TO DIRTY READ;


RETURN  a_numrecla
		WITH RESUME;
END PROCEDURE;
