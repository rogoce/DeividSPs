-- Procedimiento Verifica si la cadena sobrepasa el máximo permitido
-- Creado    : 28/05/2013 - Autor: Román Gordón

-- SIS v.2.0 - DEIVID, S.A.

drop procedure sp_sis185;

create procedure "informix".sp_sis185(a_candena varchar(250), a_limite smallint)
returning	varchar(250),
			varchar(250);

define _cadena_result	varchar(250);
define _cadena_acum		varchar(250);
define _cadena			varchar(250);
define _char			char(1);
define _pos_espacio		smallint;
define _len_cadena		smallint;
define _diferencia		smallint;
define _cant_char		smallint;


--set debug file to "sp_sis185.trc"; 
--trace on;

set lock mode to wait;

let _cadena_result	= '';
let _cadena_acum	= '';
let _cadena			= trim(a_candena);
let _len_cadena		= length(_cadena);

if _len_cadena <= a_limite then
	return _cadena,'';
end if

let _diferencia = _len_cadena - a_limite;

for _cant_char	= 1 to a_limite 
	let _char	= _cadena[1];
	let _cadena	= _cadena[2,250];

	if _char = ' ' then
		let _pos_espacio = _cant_char;
	end if
end for

let _cadena	= trim(a_candena);

for _cant_char	= 1 to _len_cadena 
	let _char	= _cadena[1];
	let _cadena	= _cadena[2,250];
	
	if _cant_char < _pos_espacio then
		let _cadena_result = _cadena_result || _char;
	elif _cant_char > _pos_espacio then
		let _cadena_acum = _cadena_acum || _char;
	end if		
end for

return _cadena_result,_cadena_acum;
end procedure
