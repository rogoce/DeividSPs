-- Procedimiento para validar si la poliza tiene un producto X
-- Creado     :	28/09/2024 - Autor: Armando Moreno
-- SIS v.2.0 - DEIVID, S.A.

drop procedure sp_emi04;		
create procedure sp_emi04(a_no_poliza char(10),a_cod_producto char(5))
returning smallint;
		  
define _cod_producto   char(5);
define _activo         integer;

set isolation to dirty read;

--SET DEBUG FILE TO "sp_emi04.trc";
--TRACE ON;

let _activo = 0;
 
foreach
	select trim(cod_producto)
	  into _cod_producto
	  from emipouni
	 where no_poliza = a_no_poliza
	 
	if _cod_producto = a_cod_producto then
		let _activo = 1;	--La poliza tiene el producto 10602 EXTRA PLUS 2024 - CLIENTE SIN SINIESTROS
		exit foreach;
	end if
end foreach
return _activo;
end procedure 