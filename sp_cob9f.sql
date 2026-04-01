-- Procedimiento para verificar si la poliza es del producto tcr 10602
--Ajustar el mantenimiento de plan pago, para cuando se trate de Producto Sin Siniestro -10602- (Ramo Automóvil) permita cambiar forma de pago entre ANC y TCR, siempre y cuando, para
-- Caso #12055
-- Creado: 14/11/2024	- Autor: Federico Coronado
-- SIS v.2.0 - DEIVID, S.A.

drop procedure sp_cob9f;
create procedure sp_cob9f(a_no_poliza char(10), a_formanewpago char(3))
returning smallint;

define _error        	smallint;
define _cod_producto 	char(5);
define _cod_perpago 	char(3);
define _cod_formapag 	char(3);
define _no_pagos        integer;
define _return          smallint;

begin
--set debug file to "sp_cob9c.trc";
--trace on;

on exception set _error 
 	return _error;         
end exception
 
let _return = 0;

foreach
	select trim(cod_producto)
	  into _cod_producto
	  from emipouni
	 where no_poliza = a_no_poliza
		exit foreach;
end foreach
/*
if _cod_producto = '10602' then
	if a_formanewpago in('006','003','008')  then
		let _return = 0;
	else
		let _return = 1;
	end if
end if
*/

return _return;
end
end procedure;