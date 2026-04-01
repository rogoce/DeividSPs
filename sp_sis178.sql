-- Procedure que verifica si la placa tiene un valor que no sea númerico, y de ser asi la marca como N/C
-- Creado    : 06/02/2013 - Autor: Roman Gordon

drop procedure sp_sis178;
create procedure "informix".sp_sis178(a_valor char(30))
returning   char(30);

define _placa			char(30);
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

let _len_valor	= length(a_valor);
let _placa		= '';

for _cant_char	= 1 to _len_valor
	let _char	= a_valor[1];
	let a_valor	= a_valor[2,30];
    
	--if _char not in ('0','1','2','3','4','5','6','7','8','9') then
	IF _char not in ('A','B','C','D','E','F','G','H','I','J','K','L','M','N','Ñ','O','P','Q','R','S','T','U','V','W','X','Y','Z','0','1','2','3','4','5','6','7','8','9') then
		if _cant_char in(1,2) then
		else
			let _placa = 'N/C';
			exit for;
		end if
	end if
	let _placa = trim(_placa) || _char;
end for

return _placa;

end procedure