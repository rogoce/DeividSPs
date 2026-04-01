-- Procedimiento que verifica si el no_motor tiene guiones
-- creado    : 24/09/2012 - Autor: Roman Gordon--
-- sis v.2.0 - deivid, s.a.

drop procedure sp_sis174a;
create procedure "informix".sp_sis174a(a_valor char(30))
returning   char(30);   -- _error


define _char			char(1);
define _len_valor		smallint;
define _cant_char		smallint;
define _error			smallint;
define _motor_sin_guion	char(30);

on exception set _error
 	return _error;         
end exception

set isolation to dirty read;

--set debug file to "sp_sis174.trc";      
--trace on;

let _len_valor	= length(a_valor);
let _motor_sin_guion = '';


for _cant_char	= 1 to _len_valor 

	let _char	= a_valor[1];
	let a_valor	= a_valor[2,30];

	if _char <> '-' then
		let _motor_sin_guion = trim(_motor_sin_guion) || _char;
	end if
end for

return _motor_sin_guion;

end procedure