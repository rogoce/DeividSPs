-- Procedimiento que calcula el descuento por: Producto y Tipo Auto

-- Creado:	18/12/2017 - Autor: Amado Perez Mendoza

-- SIS v.2.0 - DEIVID, S.A.

--drop procedure sp_proe88;
 
create procedure sp_proe88(a_producto CHAR(5), a_modelo CHAR(5))
returning dec(16,2);

define _cod_tipo	char(3);
define _porc_desc   decimal(16,2);

--set debug file to "sp_proe72.trc";
--trace on;

set isolation to dirty read;

let _porc_desc       = 0;

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
