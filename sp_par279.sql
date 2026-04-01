-- Verificacion de digitos en campos de ceduta tomo y asiento
--
-- Creado    : 21/01/2009 - Autor: Armando Moreno
-- Modificado: 21/01/2009 - Autor: Armando Moreno

-- SIS v.2.0 - DEIVID, S.A.

drop procedure sp_par279;

create procedure "informix".sp_par279(a_tipo char(1), a_valor char(7))
returning smallint;

define i integer;
define _cant integer;
define _char1 char(1);

set isolation to dirty read;

let a_valor = trim(a_valor);
let _cant   = length(a_valor);

if a_tipo = 'N' then

  for i = 1 to _cant

		let _char1  = a_valor[1,1];
		LET a_valor = a_valor[2,7];

		if _char1 not between "0" and "9" then
			return 1;
		end if
  end for
  	
else

  for i = 1 to _cant

	let _char1  = a_valor[1,1];
	let a_valor = a_valor[2,7];

	if (_char1 not between "0" and "9") and (_char1 not between "A" and "Z") then
	   return 1;
	end if

  end for

end if

return 0;

end procedure
