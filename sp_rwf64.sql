-- Consulta de Cobertura de un Reclamo

-- Creado    : 25/06/2004 - Autor: Amado Perez M.
-- Modificado: 25/06/2004 - Autor: Amado Perez M.

-- SIS v.2.0 -  - DEIVID, S.A.

DROP PROCEDURE sp_rwf64;

CREATE PROCEDURE sp_rwf64(a_no_tramite CHAR(10) default "%", a_cod_cobertura CHAR(5), a_deducible DEC(16,2) default 0.00)
RETURNING smallint,
          varchar(50);

define _error		smallint;
define _no_reclamo	char(10);

--set debug file to "sp_rwf64.trc";
--TRACE ON;

SET ISOLATION TO DIRTY READ;

BEGIN
ON EXCEPTION SET _error 
	RETURN _error, "Error al actualizar coberturas";
END EXCEPTION           

SELECT no_reclamo
  INTO _no_reclamo
  FROM recrcmae
 WHERE no_tramite = a_no_tramite;

INSERT INTO recrccob (
    no_reclamo,
    cod_cobertura,
    deducible)
 VALUES (
    _no_reclamo,
    a_cod_cobertura,
    a_deducible
    );
    
END     

RETURN 0, "Actualizacion Exitosa";

END PROCEDURE;