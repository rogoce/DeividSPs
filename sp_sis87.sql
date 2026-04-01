-- Verificacion de Tomo, Folio o Asiento
--
-- Creado    : 14/03/2006 - Autor: Amado Perez Mendoza
-- Modificado: 14/03/2006 - Autor: Amado Perez Mendoza

-- SIS v.2.0 - DEIVID, S.A.

--drop procedure sp_sis87;

create procedure "informix".sp_sis87(a_cedula char(6))
returning smallint;

define _largo integer;

set isolation to dirty read;

if a_cedula is null or trim(a_cedula) = "" then
	return 0;
end if

let _largo = length(trim(a_cedula));

FOR _contador = 1 TO _largo
	if a_cedula[1] not between "1" and "9" and
	   _contador = 1 then
	   return 2;
	end if 

	if a_cedula[_contador] not between "0" and "9" then
		return 1;
	end if

END FOR


return 0;

end procedure
