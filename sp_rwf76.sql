-- Actualizacion de los casos
-- 
-- Creado    : 03/08/2004 - Autor: Demetrio Hurtado Almanza 
--
-- SIS v.2.0 - - ASEGURADORA ANCON, S.A.

DROP PROCEDURE sp_rwf76;

create procedure "informix".sp_rwf76(
a_incident 		integer, 
a_factura 		char(10), 
a_proveedor 	char(10), 
a_concepto 		char(10), 
a_monto 		dec(18,2), 
a_usuario 		char(30), 
a_cod_cliente 	char(10), 
a_cuenta 		char(12), 
a_fecha_pago 	date)
returning     integer;

define _error	integer;

--SET DEBUG FILE TO "sp_rwf62.trc";
--TRACE ON ;

set lock mode to wait 60;

begin
on exception set _error
	return _error;
end exception

delete from	wf_opago where incident = a_incident;

insert into wf_opago(
	incident,
	factura,
	proveedor,
	concepto,
	monto,
	usuario,
	cod_cliente,
	cuenta,
	fecha_pago
	)
values(
	a_incident,   
   	a_factura, 	 
	a_proveedor,	 
	a_concepto,   
	a_monto,	     
	a_usuario,    
	a_cod_cliente,
	a_cuenta,	 
	a_fecha_pago
	); 

end

return 0;

end procedure
