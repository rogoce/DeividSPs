-- Procedimiento que carga las coberturas de los prodcutos en el Proceso de Envio de Archivos al Agente Externo (Ducruet).
--
-- creado    : 01/10/2012 - Autor: Roman Gordon--
-- sis v.2.0 - deivid, s.a.

drop procedure sp_act_emirenduc;
create procedure "informix".sp_act_emirenduc()
returning   integer,
			char(100);   -- _error

define _error_desc		char(100);
define _no_poliza_ant	char(10);
define _error			smallint;
define _error_isam		smallint;
			
begin
on exception set _error,_error_isam,_error_desc
	drop table tmp_cober2; 
 	return _error,_error_desc;
end exception

set isolation to dirty read;

foreach
	select no_poliza_ant
	  into _no_poliza_ant
	  from emirenduc
	  
	call sp_pro371(_no_poliza_ant) returning _error,_error_desc;
end foreach
end
return 0,'';
end procedure