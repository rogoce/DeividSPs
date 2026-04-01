--Procedure que graba el cod ramo en la unidad del endoso a insertar, sacado de la relacion producto cobertura reaseguro
--Armando Moreno 04/07/2017

--drop procedure sp_sis505;		
create procedure "informix".sp_sis505(a_no_poliza char(10), a_no_endoso char(10))
returning integer;

define _cod_producto char(10);
define _cod_ramo     char(3);
define _no_unidad    char(5);

set isolation to dirty read;

begin

foreach
	select cod_producto,
	       no_unidad
	  into _cod_producto,
	       _no_unidad
	  from endeduni
	 where no_poliza = a_no_poliza
	   and no_endoso = a_no_endoso

    let _cod_ramo = sp_sis502(_cod_producto);

	update endeduni
	   set cod_ramo = _cod_ramo
	 where no_poliza = a_no_poliza
	   and no_endoso = a_no_endoso
       and no_unidad = _no_unidad;
	
end foreach

return 0;
end
end procedure;