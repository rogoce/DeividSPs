-- Procedimiento para buscar los reclamos con la ultima transaccion sea cerrar reclamos para completar los incidentes en workflow
-- 
-- creado: 11/05/2005 - Autor: Amado Perez.

DROP PROCEDURE sp_rwf109;

CREATE PROCEDURE "informix".sp_rwf109(a_usuario char(20)) 
			RETURNING CHAR(3);  

DEFINE _cod_perfil_wf_auto		CHAR(3);
DEFINE _cnt                     SMALLINT;


SET ISOLATION TO DIRTY READ;
--set debug file to "sp_rwf43.trc";
--trace on;

LET a_usuario = UPPER(a_usuario);
LET _cnt = 0;

SELECT count(*)
  INTO _cnt
  FROM insuser where windows_user = a_usuario;

IF _cnt = 1 THEN 
	SELECT cod_perfil_wf_auto 
	  INTO _cod_perfil_wf_auto
	 FROM insuser where windows_user = a_usuario; --status = 'A' and
ELIF _cnt > 1 THEN
	SELECT cod_perfil_wf_auto 
	  INTO _cod_perfil_wf_auto
	 FROM insuser where windows_user = a_usuario and status = 'A'; 
ELSE
    LET _cod_perfil_wf_auto = "000";
END IF

	RETURN _cod_perfil_wf_auto;

END PROCEDURE