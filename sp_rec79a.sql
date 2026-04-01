-- Procedimiento que realiza el cierre de transacciones pendiente de pago

-- Creado    : 10/02/2004 - Autor: Amado Perez  

drop procedure sp_rec79a;

create procedure sp_rec79a(a_periodo char(7)) 
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

--Se extrae el primer día del periodo que se va a cargar en reccietr
let _fecha_periodo = mdy(a_periodo[6,7],1,a_periodo[1,4]);
--Se extrae el último día del mes anterior para determinar el periodo anterior
let _fecha_mes_ant = _fecha_periodo - 1 units day;
--Se extrae el primer día del periodo anterior
let _fecha_mes_ant = mdy(month(_fecha_mes_ant),1,year(_fecha_mes_ant));
let _periodo_ant = sp_sis39(_fecha_mes_ant);

delete from reccietr
 where transaccion in ('01-1289504','01-1323577','01-1305177','01-1316833')
   and periodo = _periodo_ant;

--Se determina el penultimo periodo desde el periodo que se va a insertar en recciect
let _fecha_mes_insert = _fecha_mes_ant - 1 units day;
let _periodo_insert = sp_sis39(_fecha_mes_insert);

insert into reccietr
select cod_cliente,numrecla,monto,fecha,cod_tipopago,transaccion,_periodo_ant,periodo_tr
  from reccietr
 where transaccion in ('01-1289504','01-1323577','01-1305177','01-1316833')
   and periodo = _periodo_insert;

--trace off;   
delete from reccietr where periodo = a_periodo;
-- Transacciones NO Pagadas
foreach
	select cod_cliente,
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
	   and pagado = 0
	   and monto <> 0

	insert into reccietr (cod_cliente, numrecla, monto, fecha, cod_tipopago, transaccion, periodo,periodo_tr)  
	values (_cod_cliente, v_numrecla, v_monto, v_fecha, _cod_tipopago, v_transaccion, a_periodo,_periodo);
end foreach
{
foreach
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
	  from rectrmae a, chqchrec b, chqchmae c
	 where a.transaccion = b.transaccion
	   and a.no_requis = b.no_requis
           and a.no_requis = c.no_requis
           and a.cod_compania = "001"
	   and a.actualizado  = 1
	   and a.cod_tipotran = "004"
	   and a.pagado = 1
       and c.pagado = 1
       and c.anulado = 0
       and c.periodo >= '2025-09'
	   and a.periodo <= '2025-08'
	   and a.monto <> 0
	   
	insert into reccietr (cod_cliente, numrecla, monto, fecha, cod_tipopago, transaccion, periodo,periodo_tr)  
	values (_cod_cliente, v_numrecla, v_monto, v_fecha, _cod_tipopago, v_transaccion, a_periodo,_periodo);
end foreach
}
end 

return 0, "Actualizacion Exitosa";
end procedure;