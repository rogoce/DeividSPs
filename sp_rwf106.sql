-- Deducible

-- Creado    : 20/04/2004 - Autor: Amado Perez M.
-- Modificado: 20/04/2004 - Autor: Amado Perez M.

-- SIS v.2.0 - d_prod_sp_prd67_dw1 - DEIVID, S.A.

DROP PROCEDURE sp_rwf106;

CREATE PROCEDURE sp_rwf106(a_cod_correo CHAR(3))
RETURNING VARCHAR(100);

DEFINE v_correo VARCHAR(100);

--set debug file to "sp_rwf02.trc";

let v_correo = "";

SET ISOLATION TO DIRTY READ;

FOREACH   
    SELECT email
	  INTO v_correo
	  FROM parcocue
	 WHERE cod_correo = a_cod_correo
	   AND activo = 1

	RETURN trim(v_correo) WITH RESUME;

END FOREACH



--drop table tmp_polizas;

END PROCEDURE;