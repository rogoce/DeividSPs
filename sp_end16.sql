-- Procedimiento que calcula el descuento por: Vehiculos Clasificados

-- Creado:	12/01/2017 - Autor: Amado Perez M

-- SIS v.2.0 - DEIVID, S.A.

drop procedure sp_end16;
 
create procedure sp_end16(a_poliza CHAR(10), a_unidad CHAR(5), a_endoso CHAR(5))
returning dec(16,2);

define _no_motor	char(50);
define _ano_tarifa	smallint;
define _cod_modelo	char(5);
define _porc_desc	dec(16,2);
define _max_ano		smallint;
define _cod_grupo   char(5);
define _grupo       char(5);
define _vigencia_ini	date;
define _nueva_renov     char(1);
define _fecha_nueva    	date;
define _fecha_renov    	date;

--set debug file to "sp_end16.trc";
--trace on;

set isolation to dirty read;

delete from endcobde Where no_poliza = a_poliza and no_endoso = a_endoso and no_unidad = a_unidad;
delete from endedcob Where no_poliza = a_poliza and no_endoso = a_endoso and no_unidad = a_unidad;

return 0;

end procedure
