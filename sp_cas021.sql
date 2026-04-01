-- Verificacion de Numero de Telefono
--
-- Creado    : 26/05/2003 - Autor: Demetrio Hurtado Almanza
-- Modificado: 26/05/2003 - Autor: Demetrio Hurtado Almanza

-- SIS v.2.0 - DEIVID, S.A.

drop procedure sp_cas021;

create procedure sp_cas021(a_telefono char(10))
returning smallint;

set isolation to dirty read;

if a_telefono is null or trim(a_telefono) = "" then
	return 0;
end if

if a_telefono[1] not between "0" and "9" or 
   a_telefono[2] not between "0" and "9" or
   a_telefono[3] not between "0" and "9" or

   a_telefono[4] not in ("-",'0','1','2','3','4','5','6','7','8','9') or
   a_telefono[5] not between "0" and "9" or
   a_telefono[6] not between "0" and "9" or
   a_telefono[7] not between "0" and "9" or
   --a_telefono[8] not between "0" and "9" or
   a_telefono[8] not in (" ",'0','1','2','3','4','5','6','7','8','9') or
   a_telefono[9]  <> " " or
   a_telefono[10] <> " " then
	return 1;
end if

if a_telefono[1] = "0" and
   a_telefono[2] = "0" and
   a_telefono[3] = "0" and
   a_telefono[4] = "-" and
   a_telefono[5] = "0" and
   a_telefono[6] = "0" and
   a_telefono[7] = "0" and
   a_telefono[8] = "0" then
	return 1;
end if

return 0;

end procedure
