--Procedimiento para verificar si hay diferentes productos en la unidad
--Armando Moreno M.  01/11/2017

--drop procedure sp_sis454a;
create procedure sp_sis454a(a_no_poliza char(10),a_no_unidad char(5))
returning char(15);

define _codigo_super	char(15);
define _cod_producto    char(5);
define _cnt             integer;

let _codigo_super  = '';

select cod_producto
  into _cod_producto
  from emipouni
 where no_poliza = a_no_poliza
   and no_unidad = a_no_unidad;
	   
select codigo_super
  into _codigo_super
  from prdprod
 where cod_producto = _cod_producto;

return _codigo_super;

end procedure
