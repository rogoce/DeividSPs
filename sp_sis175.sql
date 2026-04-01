-- Procedimiento que verifica si el no_motor tiene guiones
-- creado    : 24/09/2012 - Autor: Roman Gordon--
-- sis v.2.0 - deivid, s.a.


drop procedure sp_sis175;
create procedure "informix".sp_sis175(a_valor char(30))
returning   varchar(30);   

define _telefono		varchar(30);
define _char			char(1);
define _len_valor		smallint;
define _cant_char		smallint;
define _error			smallint;

on exception set _error
 	return _error;         
end exception

set isolation to dirty read;

--set debug file to "sp_sis174.trc";      
--trace on;

if a_valor is null then
	return '';
end if

let _len_valor	= length(a_valor);
let _telefono	= '';

for _cant_char	= 1 to _len_valor 

	let _char	= a_valor[1];
	let a_valor	= a_valor[2,30];

	if _char <> '-' then
		let _telefono = trim(_telefono) || _char;	
	end if
end for

return _telefono;

end procedure