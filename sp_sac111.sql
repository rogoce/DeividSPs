-- Procedure que actualiza los saldos de todo un año

-- Creado    : 13/09/2007 - Autor: Demetrio Hurtado Almanza

-- SIS v.2.0 - DEIVID, S.A.

drop procedure sp_sac111;

create procedure sp_sac111(
a_ano_eval	smallint
) returning integer,
            char(50);

define _error			integer;
define _error_isam		integer;
define _error_desc		char(50);

define _i				smallint;

set isolation to dirty read;

begin 
on exception set _error, _error_isam, _error_desc
	return _error, _error_desc;
end exception

for _i = 1 to 14 

	call sp_sac100(a_ano_eval, _i) returning _error, _error_desc;
	
	if _error <> 0 then
	
		return _error, _error_desc;
		
	end if
		
end for

end 

call sp_sac101(a_ano_eval) returning _error, _error_desc;

if _error <> 0 then
	return _error, _error_desc;
end if

return 0, "Actualizacion Exitosa"; 

end procedure