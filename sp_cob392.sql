-- Proceso que determina los periodos en los que se deben pagar las pólizas con periodos de pagos distintos a Mensual/Anual
-- Creado    : 29/12/2016 - Autor: Román Gordón
-- SIS v.2.0 - DEIVID, S.A.

drop procedure sp_cob392;
create procedure 'informix'.sp_cob392(a_no_documento char(18), a_dia smallint, a_proceso char(3)) 
returning	smallint;

define _error_desc			varchar(100);
define _periodo				char(7);
define _cero				char(1);
define _cnt_periodo			smallint;
define _mes_fecha			smallint;
define _ano_fecha			smallint;
define _error_code			integer;
define _error_isam			integer;
define _fecha				date;

set isolation to dirty read;

--set debug file to 'sp_cob391.trc';
--trace on ;

begin

on exception set _error_code
 	return _error_code;
end exception

if a_proceso = 'TCR' then
	select fecha
	  into _fecha
	  from cobfectar
	 where procesado = 2
	   and day(fecha) = a_dia;
elif a_proceso = 'AME' then
	select fecha
	  into _fecha
	  from cobfectam
	 where procesado = 2
	   and day(fecha) = a_dia;
elif a_proceso = 'ACH' then
	select fecha
	  into _fecha
	  from cobfecach
	 where procesado = 2
	   and day(fecha) = a_dia;	
end if

let _ano_fecha = year(_fecha);
let _mes_fecha = month(_fecha);

let _cero = '';
if _mes_fecha < 10 then
	let _cero = '0';
end if

let _periodo = _ano_fecha || '-' || trim(_cero) ||_mes_fecha;

select count(*)
  into _cnt_periodo
  from tmp_periodos
 where periodo = _periodo;

if _cnt_periodo is null then
	let _cnt_periodo = 0;
end if

if _cnt_periodo = 0 then
	return 0;
end if

return 1;

end
end procedure;