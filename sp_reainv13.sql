-- Procedimiento que carga los comprobantes de reaseguro para que se generen los registros contables
-- 
-- Creado    : 18/11/2021 - Autor: Amado Perez 
--
-- SIS v.2.0 - DEIVID, S.A.

drop procedure sp_reainv13;		

create procedure "informix".sp_reainv13()
returning integer, 
          char(100);
		  	
define _no_registro	char(10);
define _contador		smallint;
define _tipo_registro	smallint;
define _sac_notrx       integer;
define _no_remesa       char(10);
define _renglon         integer;

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

-- Corrigiendo distribución de reaseguro en remesas	
foreach
	select no_remesa,
		   renglon
	  into _no_remesa,
		   _renglon
	  from cobredet
	 where no_poliza = '1656427'
	   and tipo_mov   in ('P','N')
	   and periodo >= '2021-06'
	 order by renglon
  
	call sp_sis171bk(_no_remesa, _renglon) returning _error, _error_desc; --Procedure que crea el reaseguro cobreaco
	
	if _error = 0 then
		 FOREACH
			select distinct sac_notrx 
			  into _sac_notrx
			from sac999:reacompasie where no_registro in (
			select no_registro from sac999:reacomp 
			 where no_remesa     = _no_remesa
			   and renglon       = _renglon
			   and tipo_registro = 2)
			   
			call sp_sac77a(_sac_notrx) returning _error, _error_desc;   
			if _error <> 0 THEN
				exit foreach;
			end if
		 END FOREACH
	end if		

   
end foreach

end 
let _error  = 0;
let _error_desc = "Proceso Completado ...";	

return _error, _error_desc;

end procedure;
