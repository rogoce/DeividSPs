-- Busca sucursal para cotizacion de poliza de auto del usuario 

-- Creado    : 19/12/2006 - Autor: Armando Moreno

--drop procedure sp_rwf83;

create procedure sp_rwf83(a_usuario CHAR(20))
 returning   char(3);

define _usuario         char(8);
define _sucursal        char(3);

SET ISOLATION TO DIRTY READ;

select usuario 
  into _usuario
  from insuser
 where windows_user = TRIM(a_usuario)
   and status = 'A';

select codigo_agencia
  into _sucursal 
  from insusco  
 where usuario = _usuario 
   and status = 'A';

IF _sucursal IS NULL OR TRIM(_sucursal) = "" THEN
	LET _sucursal = '001';
END IF 

RETURN TRIM(_sucursal);

end procedure
