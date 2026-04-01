-- Procedure que Calcula la prima devuelta de una póliza a una fecha dada
-- Creado    : 28/08/2017 - Autor: Roman Gordon
-- SIS v.2.0 - DEIVID, S.A.

drop procedure sp_che162;
create procedure sp_che162(a_no_documento char(20),a_fecha date)
returning	integer			as cod_error,
			dec(16,2)		as monto_devuelto;

define _no_requis			char(10);
define _monto_devolucion	dec(16,2);
define _monto_cheque		dec(16,2);
define _pagado				smallint;
define _error				integer;
define _fecha_impresion		date;
define _fecha_anulado		date;

begin
on exception set _error
	return _error, 0.00;
end exception

set isolation to dirty read;

--set debug file to "sp_che162.trc";
--trace on;

let _monto_devolucion = 0.00;

foreach
	select no_requis,
		   monto		   
	  into _no_requis,
		   _monto_cheque		   
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
		if _fecha_impresion > a_fecha then
			let _monto_cheque = 0;
		else
			if _fecha_anulado is not null then
				if _fecha_anulado <= a_fecha  then
					let _monto_cheque = 0;
				end if
			end if
		end if				
	else
		let _monto_cheque = 0;
	end if	
	
	if _monto_cheque is null then
		let _monto_cheque = 0;
	end if		

	let _monto_devolucion = _monto_devolucion - _monto_cheque;
end foreach
return 0,_monto_devolucion;
end
end procedure;