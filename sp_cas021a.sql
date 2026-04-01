-- Verificacion de Numero de Celular
-- Creado    : 27/10/2010 - Autor: Roman Gordon

-- SIS v.2.0 - DEIVID, S.A.

drop procedure sp_cas021a;

create procedure "informix".sp_cas021a(a_telefono char(10))
returning smallint;

set isolation to dirty read;

if a_telefono is null or trim(a_telefono) = "" then
	return 0;
end if

if a_telefono[1]  <> "6" or
   a_telefono[2] not between "0" and "9" or 
   a_telefono[3] not between "0" and "9" or
   a_telefono[4] not between "0" and "9" or
   a_telefono[5]  <> "-" or
   a_telefono[6] not between "0" and "9" or
   a_telefono[7] not between "0" and "9" or
   a_telefono[8] not between "0" and "9" or
   a_telefono[9] not between "0" and "9" or
   a_telefono[10]  <> " " then
	if a_telefono[1] not between "0" and "9" or
	   a_telefono[2] not between "0" and "9" or 
	   a_telefono[3] not between "0" and "9" or
	   a_telefono[4]  <> "-" or
	   a_telefono[5] not between "0" and "9" or
	   a_telefono[6] not between "0" and "9" or
	   a_telefono[7] not between "0" and "9" or
	   a_telefono[8] not between "0" and "9" or
	   a_telefono[9]  <> " " or
	   a_telefono[9]  <> " " then
			return 1;
	end if
end if

return 0;

end procedure
