
-- Creado    : 16/01/2007 - Autor: Armando Moreno

--drop procedure sp_che67d;

create procedure sp_che67d(a_no_cheque	integer)
returning integer;

define _no_requis		char(10);
define _cod_cliente		char(10);
define _nom_tipopago	char(50);
define _monto			dec(16,2);
define _cod_tipopago    char(3);
define _periodo_pago    smallint;
define _cod_banco       char(3);
define _cod_chequera    char(3);
define _a_nombre_de		char(100);
define _nom_recla		char(100);
define _nom_aseg		char(100);
define _firma1			char(8);
define _firma2			char(8);
define _cod_asegurado	char(10);
define _cod_reclamante	char(10);
define _no_reclamo		char(10);
define _monto_tran		dec(16,2);
define _fecha			date;
define _transaccion		char(10);
define _reclamo			char(18);
define _no_cheque,_cant		integer;
define _fecha_impresion date;

SET ISOLATION TO DIRTY READ;

select cod_banco,
       cod_chequera
  into _cod_banco,
	   _cod_chequera
  from chqbanch
 where cod_ramo = '018';

let _fecha = sp_sis26();

foreach
 select	no_requis,
		cod_cliente,
		monto,
		a_nombre_de,
		periodo_pago,
		firma1,
		firma2,
		no_cheque,
		fecha_impresion
   into	_no_requis,
		_cod_cliente,
		_monto,
		_a_nombre_de,
		_periodo_pago,
		_firma1,
		_firma2,
		_no_cheque,
		_fecha_impresion
   from	chqchmae
  where anulado         = 0
    and autorizado      = 1
	and cod_banco       = _cod_banco
	and cod_chequera    = _cod_chequera
	and pagado			= 1
	and en_firma        = 2
	and fecha_impresion = _fecha
	and no_cheque       > a_no_cheque

   	update chqchmae
	   set impreso_ok = 0
	 where no_requis = _no_requis;

end foreach

return 0;
end procedure
