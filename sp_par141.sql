-- Seleccion de Polizas a 90 dias para Ajuste de Reserva
-- 
-- Creado     : 24/10/2002 - Autor: Demetrio Hurtado Almanza
--
-- SIS v.2.0 - DEIVID, S.A.

--drop procedure sp_par141;

create procedure "informix".sp_par141(a_periodo char(7))
returning integer,
          char(50);

define _no_documento	char(20);
define _no_poliza		char(10);
define _fecha			date;
define _error			integer;
define _descripcion		char(50);
define _cantidad		integer;
define _tipo			char(1);
define _cod_tipoprod	char(3);

DEFINE v_saldo          DEC(16,2);
DEFINE v_por_vencer     DEC(16,2);
DEFINE v_exigible       DEC(16,2);
DEFINE v_corriente      DEC(16,2);
DEFINE v_monto_30       DEC(16,2);
DEFINE v_monto_60       DEC(16,2);
DEFINE v_monto_90       DEC(16,2);
DEFINE v_monto_120      DEC(16,2);

--set debug file to "sp_par129.trc";
--trace on;

set isolation to dirty read;

let _cantidad = 0;
let _fecha    = sp_sis36(a_periodo);
 
foreach
 select no_documento
   into _no_documento
   from emipomae
  where actualizado = 1
  group by no_documento

	let _no_poliza = sp_sis21(_no_documento);

	select cod_tipoprod
	  into _cod_tipoprod
	  from emipomae
	 where no_poliza = _no_poliza;

	if _cod_tipoprod = "004" then
		continue foreach;
	end if
	
	call sp_par140(_no_documento, a_periodo, _fecha)
	     returning v_por_vencer,    
				   v_exigible,      
				   v_corriente,    
				   v_monto_30,      
				   v_monto_60,      
				   v_monto_90,
				   v_monto_120,
				   v_saldo;   

	if (v_monto_90 + v_monto_120) = 0.00 then
		continue foreach;
	end if

	if _cod_tipoprod = "002" then
		let _tipo = "2";
	else
		let _tipo = "1";
	end if

	let _cantidad = _cantidad + 1;

	insert into cob90d04
	values (_no_documento, _tipo, (v_monto_90 + v_monto_120), v_monto_90, v_monto_120);

end foreach

return 0, _cantidad || " Registros Procesados"; 

end procedure