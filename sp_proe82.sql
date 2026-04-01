-- Procedimiento que busca el descuento de MotorShow 2015

-- Creado:	23/09/2015 - Autor: Amado Perez

-- SIS v.2.0 - DEIVID, S.A.

--drop procedure sp_proe82;
 
create procedure sp_proe82(a_poliza CHAR(10), a_unidad CHAR(5))
returning dec(16,2);

define _no_motor	char(50);
define _cod_modelo	char(5);
define _porc_desc_feria decimal(16,2);
define _nuevo       smallint;
define _cod_producto char(5);

--set debug file to "sp_proe72.trc";
--trace on;

set isolation to dirty read;
let _porc_desc_feria = 0;

select cod_producto
  into _cod_producto
  from emipouni
 where no_poliza = a_poliza
   and no_unidad = a_unidad;

select no_motor  
  into _no_motor
  from emiauto
 where no_poliza = a_poliza
   and no_unidad = a_unidad;

select cod_modelo, nuevo
  into _cod_modelo, _nuevo
  from emivehic
 where no_motor = _no_motor;

--if _nuevo = 1 and _cod_producto = '02206' then
 
if _nuevo = 1 and _cod_producto in ('02206','03005','03012', '03013') then
	select porc_desc_feria
	  into _porc_desc_feria
	  from emimodel
	 where cod_modelo = _cod_modelo;
end if

return _porc_desc_feria;

end procedure
