--Procedure que graba el cod ramo en la unidad sacado de la relacion producto cobertura reaseguro
--Armando Moreno 14/06/2017
drop procedure sp_sis503a;
create procedure sp_sis503a(a_no_poliza char(10))
returning integer;

define _cod_producto char(10);
define _cod_ramo     char(3);
define _no_unidad    char(5);

set isolation to dirty read;

begin

foreach with hold
	select cod_producto,
	       no_unidad
	  into _cod_producto,
	       _no_unidad
	  from emipouni
	 --where no_poliza = a_no_poliza

    let _cod_ramo = sp_sis502(_cod_producto);
	
	update emipouni
	   set cod_ramo = _cod_ramo
	 where no_poliza = a_no_poliza
       and no_unidad = _no_unidad;
end foreach

return 0;
end
end procedure;