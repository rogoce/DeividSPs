-- Procedimiento que realiza el cierre de transacciones pendiente de pago

-- Creado    : 10/02/2004 - Autor: Amado Perez  

drop procedure ap_rec79a;

create procedure ap_rec79a(a_periodo char(7)) 
returning integer,
		  char(50);

define v_proveedor			varchar(100);
define _error_desc			char(50);
define v_tipopago			char(50);
define v_numrecla			char(18);
define v_transaccion		char(10);
define _cod_cliente			char(10);
define _periodo_insert		char(7);
define _periodo_ant			char(7);
define _periodo				char(7);
define _cod_tipopago		char(3);
define v_monto				dec(16,2);
define _cantidad			smallint;
define _error				integer;
define _error_isam			integer;
define _fecha_mes_insert	date;
define _fecha_mes_ant		date;
define _fecha_periodo		date;
define v_fecha				date;

--set debug file to "sp_rec79a.trc";
--trace on;

set isolation to dirty read;

begin 
on exception set _error, _error_isam, _error_desc
	return _error, _error_desc;
end exception

--trace off;   
--delete from reccietr where periodo = a_periodo;
-- Transacciones NO Pagadas
foreach
{	select cod_cliente,
		   numrecla,
		   monto,
		   fecha,
		   cod_tipopago,
		   transaccion,
		   periodo
	  into _cod_cliente,
		   v_numrecla,
		   v_monto,
		   v_fecha,
		   _cod_tipopago,
		   v_transaccion,
		   _periodo
	  from rectrmae
	 where cod_compania = "001"
	   and actualizado  = 1
	   and cod_tipotran = "004"
	   and periodo <= a_periodo
	   and pagado = 1
	   and monto <> 0
	   and fecha_pagado >= '01-07-2024'
}	   
	select a.cod_cliente,
		   a.numrecla,
		   a.monto,
		   a.fecha,
		   a.cod_tipopago,
		   a.transaccion,
		   a.periodo
	  into _cod_cliente,
		   v_numrecla,
		   v_monto,
		   v_fecha,
		   _cod_tipopago,
		   v_transaccion,
		   _periodo
	  from rectrmae a, rectrmae b
	 where a.anular_nt = b.transaccion
       and a.cod_compania = "001"
	   and a.actualizado  = 1
	   and a.cod_tipotran = "004"
	   and a.periodo <= '2024-06'
	   and a.pagado = 1
	   and a.monto <> 0
       and a.fecha_anulo >= '01-07-2024'
       and b.periodo = '2024-07'
	   and a.transaccion <> '01-2042416'
		   
	insert into reccietr (cod_cliente, numrecla, monto, fecha, cod_tipopago, transaccion, periodo,periodo_tr)  
	values (_cod_cliente, v_numrecla, v_monto, v_fecha, _cod_tipopago, v_transaccion, a_periodo,_periodo);
end foreach
end 

return 0, "Actualizacion Exitosa";
end procedure;