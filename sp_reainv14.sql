-- Procedimiento que carga los comprobantes de reaseguro para que se generen los registros contables
-- 
-- Creado    : 18/11/2021 - Autor: Amado Perez 
--
-- SIS v.2.0 - DEIVID, S.A.

drop procedure sp_reainv14;		

create procedure "informix".sp_reainv14()
returning integer, 
          char(100);
		  	
define _no_registro	char(10);
define _contador		smallint;
define _tipo_registro	smallint;
define _sac_notrx       integer;

define _error			integer;
define _error_isam		integer;
define _error_desc		char(50);

set isolation to dirty read;

begin 
on exception set _error, _error_isam, _error_desc
	return _error, _error_desc;
end exception


--set debug file to "sp_sac161cam.trc";
--trace on;

--return 1, "Inicio " || current with resume;

let _contador = 0;

-- produccion y cobros

let _sac_notrx = null;

foreach 
 select sac_notrx
   into _sac_notrx
   from camreatrx

	call sp_sac64cam("001", _sac_notrx, 'informix') returning _error, _error_desc;

	if _error <> 0 then

		if _error_desc is null then
			let _error_desc = "Error en sp_sac64";
		end if

		return _error, _error_desc;
	end if
end foreach

end 
let _error  = 0;
let _error_desc = "Proceso Completado ...";	

return _error, _error_desc;

end procedure;
