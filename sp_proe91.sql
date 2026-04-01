-- Procedimiento que calcula el descuento por: Cobertura y Suma Asegurada

-- Creado:	25/09/2018 - Autor: Amado Perez Mendoza

-- SIS v.2.0 - DEIVID, S.A.

--drop procedure sp_proe91;
 
create procedure sp_proe91(a_cobertura CHAR(5), a_suma DEC(16,2))
returning dec(16,2);

define _cod_tipo   char(3);
define _porc_desc  decimal(16,2);
define a_producto  char(5);
define a_modelo    char(5);
define _no_motor   char(30);

--set debug file to "sp_proe91.trc";
--trace on;

set isolation to dirty read;

let _porc_desc       = 0;

select cod_producto
  into a_producto
  from emipouni
 where no_poliza = a_poliza
   and no_unidad = a_unidad;

select no_motor
  into _no_motor
  from emiauto
 where no_poliza = a_poliza
   and no_unidad = a_unidad;

select cod_modelo
  into a_modelo
  from emivehic
 where no_motor = _no_motor;
   
select cod_tipoauto
  into _cod_tipo
  from emimodel
 where cod_modelo = a_modelo;
 
 select porc_descuento
   into _porc_desc
   from prddesti
  where cod_tipoauto = _cod_tipo
    and cod_producto = a_producto;
  
if _porc_desc is null then
	let _porc_desc = 0;
end if

return _porc_desc;

end procedure
