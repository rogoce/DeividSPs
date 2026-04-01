-- Creacion de Remesa de Comision de Descontada cuando la poliza esta en Pago adelantado de comision y fue cancelada
-- 
-- Creado     : 11/10/2012 - Autor: Roman Gordon

-- SIS v.2.0 - DEIVID, S.A.

drop procedure sp_cob377;

create procedure "informix".sp_cob377()
returning integer		as cod_error,
          char(5)		as Id_Aviso,
          varchar(100)	as Poliza,
		  date			as Fecha_Impresion,
		  date			as Fecha_Cancelacion,
		  date			as Fecha_Cubierto,
		  date			as Vigencia_Inicial,
		  date			as Vigencia_Final,
		  dec(16,2)		as Saldo,
		  dec(16,2)		as Prima_Cobrada,
		  smallint		as No_Pagos;

define _error_desc			varchar(100);
define _no_aviso			char(20);
define _no_documento		char(20);
define _no_poliza			char(10);
define _periodo				char(7);
define _prima_cobrada		dec(16,2);
define _prima_bruta			dec(16,2);
define _por_vencer			dec(16,2);
define _corriente			dec(16,2);
define _exigible			dec(16,2);
define _dias_30				dec(16,2);
define _dias_60				dec(16,2);
define _dias_90				dec(16,2);
define _saldo				dec(16,2);
define _dias_cubiertos		smallint;
define _no_pagos			smallint;
define _cnt_pago			smallint;
define _dias1				smallint;
define _error_isam			integer;
define _error				integer;
define _fecha_imprimir		date;
define _vigencia_final		date;
define _vigencia_inic		date;
define _vig_fin_max			date;
define _fecha_vence			date;
define _fecha_hoy			date;

begin
on exception set _error, _error_isam, _error_desc
	return _error,'', _error_desc,_fecha_hoy,_fecha_hoy,_fecha_hoy,_fecha_hoy,_fecha_hoy,0.00,0.00,0;
end exception

set isolation to dirty read;

let _fecha_hoy = current;
let _periodo = sp_sis39(_fecha_hoy);

foreach
	select no_aviso,
		   no_documento,
		   fecha_imprimir,
		   fecha_vence
	  into _no_aviso,
		   _no_documento,
		   _fecha_imprimir,
		   _fecha_vence
	  from avisocanc
	 where estatus = 'X'
	   and fecha_vence >= '01/01/2015'
	 order by fecha_vence

	if _fecha_vence is null then
		continue foreach;
	end if
	
	if _fecha_imprimir is null then
		continue foreach;
	end if
	
	let _no_poliza = sp_sis21(_no_documento);

	select vigencia_inic,
		   vigencia_final,
		   prima_bruta,
		   no_pagos
	  into _vigencia_inic,
		   _vigencia_final,
		   _prima_bruta,
		   _no_pagos
	  from emipomae
	 where no_poliza   = _no_poliza
	   and actualizado = 1;

	select count(*)
	  into _cnt_pago
	  from cobredet
	 where doc_remesa = _no_documento
	   and tipo_mov in ('P','N')
	   and fecha >= _fecha_imprimir
	   and actualizado = 1;

	if _cnt_pago is null then
		let _cnt_pago = 0;
	end if

	if _cnt_pago = 0 then
		continue foreach;
	end if

	let _dias1 = _vigencia_final - _vigencia_inic;

	call sp_cob33('001','001',_no_documento,_periodo,_fecha_hoy)
	returning	_por_vencer,
				_exigible,
				_corriente,
				_dias_30,
				_dias_60,
				_dias_90,
				_saldo;

	if (_dias_60 + _dias_90) < 5 then
		continue foreach;
	end if
	
	select sum(monto)
	  into _prima_cobrada
	  from cobredet
	 where no_poliza = _no_poliza
	   and actualizado = 1;

	if _prima_cobrada is null then
		let _prima_cobrada = 0.00;
	end if

	let _dias_cubiertos = (_saldo/_prima_bruta) * _dias1;	
	let _vig_fin_max = _vigencia_final - _dias_cubiertos units day;
	
	if _fecha_vence >= _vig_fin_max then
		continue foreach;
	end if

	return	0,
			_no_aviso,
			_no_documento,
			_fecha_imprimir,
			_fecha_vence,
			_vig_fin_max,
			_vigencia_inic,
			_vigencia_final,
			_saldo,
			_prima_cobrada,
			_no_pagos with resume;
end foreach
end
end procedure;