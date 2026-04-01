-- Procedimiento Datos para Five09 
-- creado    : 17/05/2021- Autor: Henry Giron
-- sis v.2.0 - d_cobr_cas_res_campana y d_cobr_cas_res_campana_cas

drop procedure sp_sis284a;
create procedure "informix".sp_sis284a(a_valor	CHAR(20) DEFAULT " ")
returning   char(20);

define _char			char(1);
define _len_valor		smallint;
define _cant_char		smallint;
define _error			smallint;
define _valor_sin_guion	char(20);

on exception set _error
 	return _error;         
end exception

set isolation to dirty read;

--set debug file to "sp_sis284a.trc";      
--trace on;

let _len_valor	= length(a_valor);
let _valor_sin_guion = '';
for _cant_char	= 1 to _len_valor 

	let _char	= a_valor[1];
	let a_valor	= a_valor[2,20];

	if _char <> '-' and _char <> ' ' then
		let _valor_sin_guion = trim(_valor_sin_guion) || _char;
	end if
end for

if _valor_sin_guion is null or trim(_valor_sin_guion) = '' then
	let _valor_sin_guion = '';
else
	let _valor_sin_guion = '+507'||trim(_valor_sin_guion);
end if

return trim(_valor_sin_guion);

end procedure