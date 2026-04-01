

--DROP PROCEDURE sp_sis21am;
CREATE PROCEDURE sp_sis21am(a_no_documento CHAR(20)) RETURNING CHAR(10);

DEFINE _no_poliza		CHAR(10);
DEFINE _vigencia_inic	DATE;
DEFINE _fecha_hoy 		DATE;
define _flag            smallint;

SET ISOLATION TO DIRTY READ;

LET _no_poliza = NULL;
let _fecha_hoy = today;

let _flag = 0;
FOREACH
	select no_poliza,
		   vigencia_inic
	  into _no_poliza,
		   _vigencia_inic
	  from emipomae
	 where no_documento = a_no_documento
	   and actualizado = 1
	 order by vigencia_final desc

	let _flag = _flag + 1;
	
	if _flag = 2 then
		exit foreach;
	end if	
END FOREACH

RETURN _no_poliza;

END PROCEDURE 
