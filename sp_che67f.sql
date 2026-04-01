
-- Creado    : 16/01/2007 - Autor: Armando Moreno

drop procedure sp_che67f;

create procedure sp_che67f()
 returning integer,integer,integer,char(10),smallint,integer;

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
define _no_cheque,_cant,_recibo1,_recibo2,_contador		integer;
define _fecha_impresion date;
define _cnt,_diferencia,_cheque_falta             integer;

SET ISOLATION TO DIRTY READ;

select cod_banco,
       cod_chequera
  into _cod_banco,
	   _cod_chequera
  from chqbanch
 where cod_ramo = '018';

let _fecha = sp_sis26();
let _no_cheque = 0;
LET _contador = 0;
LET _cnt = 0;
let _cheque_falta = 0;

foreach
 select	no_requis,
		no_cheque,
		fecha_impresion
   into	_no_requis,
		_no_cheque,
		_fecha_impresion
   from	chqchmae
  where cod_banco       = _cod_banco
	and cod_chequera    = _cod_chequera
	and pagado          = 1
	and autorizado      = 1
	and fecha_impresion between "01/07/2008" and "31/07/2008"
	order by no_cheque

	LET _contador = _contador + 1;

	IF _contador = 1 THEN
		LET _recibo1 = _no_cheque;
	END IF				
	LET _recibo2 = _no_cheque;

	IF _recibo1 <> _recibo2 THEN
		LET _diferencia = _recibo2 - _recibo1;
		IF _diferencia <> 1 THEN
			LET _cnt = 1;
			let _cheque_falta = _recibo1 + 1;
			return _recibo1,_recibo2,_no_cheque,_no_requis,_cnt,_cheque_falta with resume;
		else
			LET _cnt = 0;
		END IF
		LET _recibo1 = _no_cheque;
		let _cheque_falta = 0;
	END IF
				  
end foreach

end procedure
