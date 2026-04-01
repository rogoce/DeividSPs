-- Procedimiento para calcular saldos de polizas a una fecha
-- 
-- Creado    : 01/07/2004 - Autor: Demetrio Hurtado Almanza
-- 
-- SIS v.2.0 - DEIVID, S.A.

DROP PROCEDURE sp_cob152;

CREATE PROCEDURE "informix".sp_cob152(
a_periodo char(7), 
a_fecha   date
) 

define _compania		char(3);
define _sucursal		char(3);
define _no_documento	char(20);
define _no_poliza		char(10);
define _cod_tipoprod	char(3);
define _saldo			dec(16,2);
define _cantidad		smallint;

let _compania = "001";
let _sucursal = "001";

set isolation to dirty read;

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

	insert into cobcuasa
	values (_no_documento, a_periodo, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00);

	let _saldo = sp_cob151(_compania, _sucursal, _no_documento, a_periodo, a_fecha);	
		
	update cobcuasa
	   set saldo_final  = _saldo
	 where no_documento = _no_documento
	   and periodo      = a_periodo;

end foreach	

end procedure