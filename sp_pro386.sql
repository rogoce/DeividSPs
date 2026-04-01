---**********************************************
--- Renovacion Automatica. Proceso de excepciones
---**********************************************
--- Creado 02/03/2009 por Armando Moreno
--- Modificado 17/06/2009 por Armando ejecuto Henry

drop procedure sp_pro386;
create procedure "informix".sp_pro386()
returning integer,char(50);
begin

define _error_desc		varchar(100);
define _no_documento	char(20);
define _no_poliza		char(10);
define _vigencia_inic	date;
define _error_isam		integer;
define _error			integer;

on exception set _error, _error_isam, _error_desc
	if _no_documento is null then
		let _no_documento = '';
	end if

	let _error_desc = _no_documento || ' ' || _error_desc;
	return _error, _error_desc;
end exception

set isolation to dirty read;

foreach
	select tmp.no_documento,
		   pol.vigencia_inic,
		   pol.no_poliza
	  into _no_documento,
		   _vigencia_inic,
		   _no_poliza
	  from deivid_tmp:tmp_ren_ago tmp
	 inner join emipoliza pol on pol.no_documento = tmp.no_documento and pol.vigencia_inic <> tmp.vigencia_final
	 where procesado = 0
	 order by 1

	call sp_pro318a(_no_poliza) returning _error,_error_desc;
	
	if _error = 0 then
		update deivid_tmp:tmp_ren_ago
		   set procesado = 1
		 where no_documento = _no_documento;
	else
		update deivid_tmp:tmp_ren_ago
		   set procesado = -1
		 where no_documento = _no_documento;
	end if	
end foreach

return 0, _error_desc;
end
end procedure;
