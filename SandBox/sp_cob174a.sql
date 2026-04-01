-- Procedimiento que obtiene el saldo de una poliza a una fecha especifica
-- Autor: Román Gordón C.
-- Creado: 18/07/2017
-- SIS v.2.0 - DEIVID, S.A.

drop procedure sp_cob174a;
create procedure sp_cob174a(a_no_documento char(20), a_fecha_corte date)
returning	dec(16,2)	as monto_facturado,
			dec(16,2)	as monto_cobrado,
			dec(16,2)	as monto_devuelto,
			dec(16,2)	as saldo;

define _fecha_char			char(10);
define _no_requis			char(10);
define _periodo_corte		char(7);
define _monto_facturado		dec(16,2);
define _monto_devuelto		dec(16,2);
define _monto_cobrado		dec(16,2);
define _monto_recibo		dec(16,2);
define _monto_cheque		dec(16,2);
define _prima_bruta			dec(16,2);
define _saldo				dec(16,2);
define _pagado				smallint;
define _fecha_impresion		date;
define _fecha_anulado		date;

--set debug file to "sp_cob174a.trc";
--trace on;

set isolation to dirty read;

let _monto_facturado = 0.00;
let _monto_devuelto = 0.00;
let _monto_cobrado = 0.00;
let _prima_bruta = 0.00;
let _saldo = 0.00;

let _periodo_corte = sp_sis39(a_fecha_corte);

-- facturas
select sum(prima_bruta)
  into _prima_bruta
  from endedmae
 where no_documento = a_no_documento	-- facturas de la poliza
   and actualizado = 1			    -- factura este actualizada
   and periodo <= _periodo_corte
   and fecha_emision <= a_fecha_corte
   and activa = 1;

if _prima_bruta is null then
	let _prima_bruta = 0.00;
end if

let _monto_facturado = _prima_bruta;

-- Recibos
select sum(monto)
  into _monto_recibo
  from cobredet
 where doc_remesa = a_no_documento	-- recibos de la poliza
   and actualizado = 1			    -- recibo este actualizado
   and tipo_mov in ('P', 'N', 'X')		-- Pago de Prima(P) y Notas de Credito(N)
   and periodo <= _periodo_corte
   and fecha <= a_fecha_corte;

if _monto_recibo is null then
	let _monto_recibo = 0.00;
end if

let _monto_cobrado = _monto_recibo;
 
-- Cheques de Devolucion de Primas
foreach
	select monto,
		   no_requis
	  into _monto_cheque,
		   _no_requis	
	  from chqchpol
	 where no_documento = a_no_documento

	select pagado,
		   fecha_impresion,
		   fecha_anulado
	  into _pagado,
	       _fecha_impresion,
		   _fecha_anulado
	  from chqchmae
	 where no_requis = _no_requis;

	if _pagado = 1 then
		if _fecha_impresion > a_fecha_corte then
			let _monto_cheque = 0.00;
		else
			if _fecha_anulado is not null then
				if _fecha_anulado <= a_fecha_corte  then
					let _monto_cheque = 0.00;
				end if
			end if
		end if				
	else
		let _monto_cheque = 0.00;
	end if	

	if _monto_cheque is null then
		let _monto_cheque = 0.00;
	end if

	let _monto_devuelto = _monto_devuelto - _monto_cheque;
end foreach

-- Realiza la Verificacion de Montos
let _monto_recibo = _monto_recibo + _monto_devuelto;
let _prima_bruta = _prima_bruta  - _monto_recibo;
let _saldo = _prima_bruta;    

return	_monto_facturado,
		_monto_cobrado,
		_monto_devuelto,
		_saldo;
end procedure;