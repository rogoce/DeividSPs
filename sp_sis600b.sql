-- CASO TBD121 AJUSTAR PRODUCTOS Y SUS COBERTURAS Y TIPOS
-- Creado    : 17/05/2022 - Autor: Armando Moreno M.

DROP PROCEDURE sp_sis600b;
CREATE PROCEDURE sp_sis600b()
returning char(30);

define _no_poliza		char(10);
define _cod_producto 	char(5);
define _no_documento 	char(20);
define _cod_tipo	    char(3);
define _cod_cobertura_n	char(5);
define _cnt		        integer;

{foreach
	select cod_producto,
	       cod_cobertura_v,
	       cod_cobertura_n
	  into _cod_producto,
		   _cod_cobertura_v,
		   _cod_cobertura_n
	  from arm_parte1

	update prdcobpd
	   set cod_cobertura = _cod_cobertura_n
	 where cod_producto = _cod_producto
	   and cod_cobertura = _cod_cobertura_v;
	   
	return "Producto "||_cod_producto|| " Actualizado" with resume;
end foreach
}

foreach
	select cod_producto,
	       cod_tipo
	  into _cod_producto,
		   _cod_tipo
	  from arm_parte2

	delete from prdcobsa
	 where cod_producto = _cod_producto
	   and cod_cobertura = '01163'
	   and cod_tipo = _cod_tipo;
	   
	return "Producto "||_cod_producto|| " Actualizado" with resume;
end foreach

end procedure