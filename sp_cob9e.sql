-- Procedimiento para verificar si la poliza es del producto tcr 10602
--Ajustar el mantenimiento de plan pago, para cuando se trate de Producto Sin Siniestro -10602- (Ramo Automóvil) permita cambiar forma de pago entre ANC y TCR, siempre y cuando, para
-- 1. ANC, la frecuencia de pago = INMEDIATA o ANUAL y No. de pagos = 1
-- 2. TCR la frecuencia de pago = 002 - CADA 30 DIAS y No. de pagos = hasta 11
-- Caso #12055
-- Creado: 14/11/2024	- Autor: Federico Coronado
-- SIS v.2.0 - DEIVID, S.A.
-- return = 0 Abierto para cambiar forma de pago
-- return = 1 Bloqueado para cambiar forma de pago

drop procedure sp_cob9e;
create procedure sp_cob9e(a_no_documento char(15))
returning smallint;

define _error        	smallint;
define _no_poliza    	char(10);
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

let _no_poliza = sp_sis21(a_no_documento);

select cod_formapag, cod_perpago, no_pagos
  into _cod_formapag, _cod_perpago, _no_pagos
  from emipomae
 where no_poliza = _no_poliza;  

foreach
	select trim(cod_producto)
	  into _cod_producto
	  from emipouni
	 where no_poliza = _no_poliza
		exit foreach;
end foreach
{se quita por caso enviado #12635
if _cod_producto = '10602' then
	if _cod_formapag in('006','008') and _cod_perpago in('008','006') and _no_pagos = 1 then
		let _return = 0;
	elif _cod_formapag in('003') and _cod_perpago in('002') and _no_pagos >= 1 and _no_pagos <= 11  then
		let _return = 0;
	else
		let _return = 1;
	end if
end if
}
return _return;
end
end procedure;