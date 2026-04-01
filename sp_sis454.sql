--Procedimiento para verificar si hay diferentes productos en la unidad
--Armando Moreno M.  01/11/2017

--drop procedure sp_sis454;
create procedure sp_sis454(a_no_poliza char(10))
returning char(15);

define _codigo_super	char(15);
define _cod_producto    char(5);
define _cnt             integer;

let _codigo_super  = '';

select count(distinct cod_producto)
  into _cnt
  from emipouni
 where no_poliza = a_no_poliza;

if _cnt = 1 then
	foreach
	    select cod_producto
		  into _cod_producto
		  from emipouni
		 where no_poliza = a_no_poliza
		exit foreach;
	end foreach
	select codigo_super
	  into _codigo_super
	  from prdprod
	 where cod_producto = _cod_producto;
else
	let _codigo_super = "";
end if
return _codigo_super;
end procedure
