-- Procedimiento que realiza el cierre de transacciones pendiente de pago

-- Creado    : 10/02/2004 - Autor: Amado Perez  

drop procedure sp_rec79b;

create procedure "informix".sp_rec79b(a_periodo char(7)) 
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
where transaccion in ('47-09747',
'10-309347',
'10-310236',
'06-14985',
'10-310595',
'01-1499698',
'01-1502246',
'01-1507536',
'01-1506730',
'01-1502497',
'01-1502495',
'01-1507501',
'01-1507506',
'02-12628',
'10-313012',
'10-313363',
'07-13202',
'10-317232',
'01-1515633',
'06-16524',
'01-1514641',
'01-1514642',
'01-1518030',
'01-1518029',
'01-1516174',
'01-1517835',
'01-1512293',
'01-1513037',
'01-1513036',
'01-1508736',
'01-1508732',
'01-1515226',
'06-16316',
'10-318153',
'10-318479',
'10-317780',
'10-317965',
'01-1524420',
'01-1524428',
'01-1524429',
'01-1518534',
'01-1520095',
'01-1520094',
'01-1519008',
'01-1520067',
'01-1522619',
'01-1524061',
'01-1524367',
'01-1524411',
'01-1524423',
'01-1519525',
'01-1521792',
'10-323979')

	insert into reccietr (cod_cliente, numrecla, monto, fecha, cod_tipopago, transaccion, periodo,periodo_tr)  
	values (_cod_cliente, v_numrecla, v_monto, v_fecha, _cod_tipopago, v_transaccion, a_periodo,_periodo);
end foreach
end 

return 0, "Actualizacion Exitosa";
end procedure;