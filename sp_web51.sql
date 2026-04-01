-- Procedimiento que saca el periodo y la fecha para actualizar una remesa
-- Creado     :	28/12/2018 - Autor: Federico Coronado
-- SIS v.2.0 - DEIVID, S.A.

drop procedure sp_web51;		
create procedure "informix".sp_web51()
returning char(7),
		  date;
		  
define _periodo 	    char(7);
define _fecha		 	date;
define _periodo_hoy     char(7);

set isolation to dirty read;

--SET DEBUG FILE TO "sp_web51.trc";
--TRACE ON;

	let _fecha = today;

	select cob_periodo
	  into _periodo
	  from deivid:parparam;
	  
	call sp_sis39(_fecha) RETURNING _periodo_hoy;
		--ultimo dia del mes del periodo
	if _periodo <> _periodo_hoy then
		if _periodo < _periodo_hoy then
			CALL sp_sis36(_periodo) RETURNING _fecha;
		else
			CALL sp_sis36bk(_periodo) RETURNING _fecha;
		end if
	end if
	return _periodo, _fecha;
end procedure 