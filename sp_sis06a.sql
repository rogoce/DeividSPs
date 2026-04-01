-- Validar el monto de cobremae vs la sumatoria del monto en cobredet sea igual

-- Armando Moreno 26/01/2012


--drop procedure sp_sis06a;
create procedure sp_sis06a(a_no_remesa char(10))
RETURNING smallint;

define _cnt     smallint;

set isolation to dirty read;

BEGIN

SELECT count(*)
  INTO _cnt
  FROM cobredet
 WHERE no_remesa = a_no_remesa
   AND tipo_mov  = 'B';
   
if _cnt > 0 then
	return 0;
else
	return 1;
end if

END
end procedure