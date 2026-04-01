-- Procedimiento que busca el descuento de MotorShow 2015

-- Creado:	23/09/2015 - Autor: Amado Perez

-- SIS v.2.0 - DEIVID, S.A.

--drop procedure sp_proe83;
 
create procedure sp_proe83(a_marca CHAR(5), a_modelo CHAR(5))
returning dec(16,2);

define _porc_desc_feria decimal(16,2);

--set debug file to "sp_proe72.trc";
--trace on;

set isolation to dirty read;
let _porc_desc_feria = 0;

select porc_desc_feria
  into _porc_desc_feria
  from emimodel
 where cod_marca  = a_marca
   and cod_modelo = a_modelo;

return _porc_desc_feria;

end procedure
