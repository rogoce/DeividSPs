--Procedimiento para hacer pruebas con cadenas

DROP PROCEDURE sp_sis21bbb;
CREATE PROCEDURE "informix".sp_sis21bbb()
RETURNING decimal(16,2),decimal(16,2);

define _fecha 			date;
define _dia   			smallint;
define _prima_mensual   dec(16,2);
define _prima_neta,_prima_cobrada      dec(16,2);
define _cnt_pago        smallint;

SET ISOLATION TO DIRTY READ;

{let _fecha = sp_sis26();
let _dia = day(_fecha);
if _dia = 31 then
	let _fecha = mdy(month(_fecha), 30, year(_fecha));
end if	
let _fecha = _fecha + 1 units month;
RETURN _fecha;}
	select sum(a.prima_neta)
	  into _prima_cobrada
	  from cobredet a
	  where a.periodo >= '2018-08'
		and a.tipo_mov in ('P','N')
		and a.actualizado  = 1 		
		and a.doc_remesa   = '1918-00186-01';
		
let _cnt_pago = 12;
let _prima_neta = 2360.25;
let _prima_mensual = trunc(_prima_neta/_cnt_pago,2);
--let _prima_mensual = truncate(_prima_mensual,2);
return _prima_mensual,_prima_cobrada;

END PROCEDURE;