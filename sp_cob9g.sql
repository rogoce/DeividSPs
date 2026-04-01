-- Procedimiento para verificar si la poliza es del producto tcr 10602
--Ajustar el mantenimiento de plan pago, para cuando se trate de Producto Sin Siniestro -10602- (Ramo Automóvil) permita cambiar forma de pago entre ANC y TCR, siempre y cuando, para
-- 1. ANC, la frecuencia de pago = INMEDIATA o ANUAL y No. de pagos = 1
-- 2. TCR la frecuencia de pago = 002 - CADA 30 DIAS y No. de pagos = hasta 11
-- Caso #12055
-- Creado: 14/11/2024	- Autor: Federico Coronado
-- SIS v.2.0 - DEIVID, S.A.
-- return = 0 Abierto para cambiar forma de pago
-- return = 1 Bloqueado para cambiar forma de pago

drop procedure sp_cob9g;
create procedure sp_cob9g(a_no_poliza char(10), a_cod_formapag char(3), a_cod_perpago char(3), a_no_pagos smallint)
returning smallint, varchar(150);

define _error        	smallint;
define _no_poliza    	char(10);
define _cod_producto 	char(5);
define _return          smallint;
define _descripcion     varchar(150);

begin
--set debug file to "sp_cob9c.trc";
--trace on;

on exception set _error 
 	return _error, "";         
end exception
 
let _return = 0;
let _descripcion = "";

foreach
	select trim(cod_producto)
	  into _cod_producto
	  from emipouni
	 where no_poliza = a_no_poliza
		exit foreach;
end foreach
{se quita por caso enviado #12635
if _cod_producto = '10602' then
	if a_cod_formapag in('006','008') then
		if a_cod_perpago in('008','006') and a_no_pagos = 1 then
			let _return = 0;
		else
			let _return = 1;
			let _descripcion = "Para esta póliza la forma de Pago ANC el periodo de pago debe ser (006) INMEDIATA o (008) ANUAL con un máximo de 1 pagos.";
		end if
	elif a_cod_formapag in('003') then
		if a_cod_perpago in('002') and a_no_pagos >= 1 and a_no_pagos <= 11 then
			let _return = 0;
		else
			let _return = 1;
			let _descripcion = "Para esta póliza la forma de Pago TCR el periodo de pago debe ser (002) CADA 30 DIAS con un máximo de 11 pagos.";
		end if
	else
		let _return = 1;
		let _descripcion = "No aplica la forma de pago.";
	end if
end if
}
return _return, _descripcion;
end
end procedure;