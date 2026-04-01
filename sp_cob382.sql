-- Procedimiento que actualiza los registros en excepción
-- Creado    : 20/11/2015 - Autor: Roman Gordon
-- SIS v.2.0 - DEIVID, S.A.  

drop procedure sp_cob382;
create procedure 'informix'.sp_cob382() 
returning	smallint,
			char(100);

define _error_desc			varchar(100);
define _error_code			integer;
define _error_isam			integer;

set isolation to dirty read;

--set debug file to 'sp_cob317.trc';
--trace on ;

begin

on exception set _error_code, _error_isam, _error_desc 
 	return _error_code, _error_desc;
end exception

delete from ducruet_cob
 where procesado = 0;

update duc_excep_cob
   set procesado = 1
 where procesado = 0;

 
return 0,'Actualización Exitosa';
end
end procedure;