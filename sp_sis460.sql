-- Fecha ultimo de Cese de cobertura para mostrar en Pantalla Unica
-- Creado    : 20/08/2019 - Autor: Henry Giron
-- SIS v.2.0 - DEIVID, S.A.

DROP PROCEDURE sp_sis460;
CREATE PROCEDURE "informix".sp_sis460(a_no_documento CHAR(20)) RETURNING date as fecha_cese;

DEFINE _no_poliza		CHAR(10);
DEFINE _fecha_cese	    DATE;
DEFINE _fecha_hoy 		DATE;
DEFINE _fecha_quitar	DATE;

SET ISOLATION TO DIRTY READ;

LET _no_poliza = NULL;
let _fecha_hoy = today;
LET _fecha_cese = NULL;
LET _fecha_quitar = NULL;

FOREACH
	select no_poliza,
		   fecha_marcar
	  into _no_poliza,
		   _fecha_cese
	  from avisocanc
	 where no_documento = a_no_documento
	   and estatus not in ('Z','Y','R','G')
     order by vigencia_final desc, no_aviso desc

	exit foreach;
END FOREACH

if _fecha_cese is not null then 
    let _fecha_quitar = _fecha_cese + 15 units day;
	call sp_sis388b(_fecha_quitar) returning _fecha_quitar;
	let _fecha_cese = _fecha_quitar;
end if

RETURN _fecha_cese;

END PROCEDURE;