

DROP PROCEDURE sp_actualiza_recargo_vida;
CREATE PROCEDURE sp_actualiza_recargo_vida()
RETURNING smallint,char(10);

DEFINE _no_poliza		CHAR(10);
define _flag,_valor            smallint;
define _suma            dec(16,2);

SET ISOLATION TO DIRTY READ;

LET _no_poliza = NULL;

let _suma = 0;
let _flag = 0;
FOREACH
	select no_poliza,
		   suma_asegurada
	  into _no_poliza,
		   _suma
	  from recargo_vida_tmp
	 where procesado = 0
	 

	let _valor = sp_proe04_vida(_no_poliza,'00001',"",_suma,'001');
	if _valor <> 0 then
		let _flag = _valor;
		exit foreach;
	end if
	let _flag = _flag + 1;

	update recargo_vida_tmp
	   set procesado = 1
	 where no_poliza = _no_poliza;
	 
	if _flag = 15 then
		exit foreach;
	end if
	
END FOREACH

RETURN _flag,_no_poliza;

END PROCEDURE 
