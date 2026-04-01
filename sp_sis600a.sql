-- CASO TBD121 AJUSTAR PRODUCTOS Y SUS COBERTURAS Y TIPOS
-- Creado    : 17/05/2022 - Autor: Armando Moreno M.

DROP PROCEDURE sp_sis600a;
CREATE PROCEDURE sp_sis600a()
returning char(20);

define _no_poliza		char(10);
define _cod_producto 	char(5);
define _no_documento 	char(20);
define _cod_cobertura_v	char(5);
define _cod_cobertura_n	char(5);
define _cnt		        integer;

foreach
	select cod_producto,
	       cod_cobertura
	  into _cod_producto,
		   _cod_cobertura_n
	  from arm_parte3

    foreach
		select no_poliza
		  into _no_poliza
		  from emipouni
		 where cod_producto = _cod_producto

		select no_documento
		  into _no_documento
		  from emipomae
		 where no_poliza = _no_poliza;
			 
			return _no_documento with resume;
    end foreach
end foreach
end procedure