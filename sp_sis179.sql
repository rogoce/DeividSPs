-- Procedimiento que carga las coberturas de los prodcutos en el Proceso de Emisiones Electronicas.
--
-- creado    : 28/08/2012 - Autor: Roman Gordon--
-- sis v.2.0 - deivid, s.a.

drop procedure sp_sis179;
create procedure "informix".sp_sis179(a_valor	varchar(150))
returning   varchar(150);   -- _error

define _char_sin_tilde	varchar(150);
define _char			char(1);
define _len_valor		smallint;
define _cant_char		smallint;

begin

--set debug file to "sp_pro368.trc";      
--trace on;

if a_valor is null then
	return null;
end if

let _len_valor	= length(a_valor);
let _char_sin_tilde = '';

for _cant_char	= 1 to _len_valor 
	let _char	= a_valor[1];
	let a_valor	= a_valor[2,30];

	if _char = 'á' then
		let _char = 'a';
	elif _char = 'é' then
		let _char = 'e';
	elif _char = 'í' then
		let _char = 'i';
	elif _char = 'ó' then
		let _char = 'o';
	elif _char ='ú' then
		let _char = 'u';
	elif _char = 'ñ' then
		let _char = 'n';
	end if
	let _char_sin_tilde = _char_sin_tilde || _char;
end for

let _char_sin_tilde = upper(_char_sin_tilde);
return _char_sin_tilde;
end
end procedure
