-- Procedimiento para verificar si la poliza es del producto tcr 10602
-- Creado: 04/09/2024	- Autor: Federico Coronado
-- SIS v.2.0 - DEIVID, S.A.

drop procedure sp_cob9c;
create procedure sp_cob9c(a_no_documento char(15))
returning smallint;

define _error        smallint;
define _no_poliza    char(10);
define _cod_producto char(5);

begin
--set debug file to "sp_cob9c.trc";
--trace on;

on exception set _error 
 	return _error;         
end exception 

let _no_poliza = sp_sis21(a_no_documento);
-- Verifica si el producto es 10602 creado para los corredores con la forma de pago tcr 003 no deben aplicar el descuento 5% ya que tienen un 20% de descuento en la cotizacion #Fcoronado 03/09/2024
foreach
	select trim(cod_producto)
	  into _cod_producto
	  from emipouni
	 where no_poliza = _no_poliza
		exit foreach;
end foreach
if _cod_producto = '10602' then
	return 1;
end if

return 0;
end
end procedure;