

DROP PROCEDURE sp_sis21;
CREATE PROCEDURE sp_sis21(a_no_documento CHAR(20)) RETURNING CHAR(10);

DEFINE _no_poliza		CHAR(10);
DEFINE _vigencia_inic	DATE;
DEFINE _fecha_hoy 		DATE;

SET ISOLATION TO DIRTY READ;

LET _no_poliza = NULL;
let _fecha_hoy = today;

FOREACH
	select no_poliza,
		   vigencia_inic
	  into _no_poliza,
		   _vigencia_inic
	  from emipomae
	 where no_documento = a_no_documento
	   and actualizado = 1
	 order by vigencia_final desc

	--if _vigencia_inic <= _fecha_hoy then
		exit foreach;
	--end if
END FOREACH

RETURN _no_poliza;

END PROCEDURE 
                                                                                                                                                                                    


END PROCEDURE;