-- Procedimiento que genera el calendario de pagos semanales de comision
-- 
-- Creado    : 03/05/2001 - Autor: Armando Moreno Montenegro
-- Modificado: 03/05/2001 - Autor: Armando Moreno Montenegro
--
-- SIS v.2.0 - DEIVID, S.A.

drop procedure sp_che80;
create procedure "informix".sp_che80(a_fecha_lim date)
returning 	smallint		as cod_error,
			varchar(100)	as desc_error;

define _error_desc	varchar(100);
define _error_isam	smallint;
define _semana		smallint;
define _error		smallint;
define _fecha_desde	date;
define _fecha_hasta	date;

--set isolation to dirty read;
set lock mode to wait;

begin
on exception set _error,_error_isam,_error_desc
	return _error,_error_desc;
end exception

select max(fecha_desde),
       max(fecha_hasta),
	   max(semana)
  into _fecha_desde,
       _fecha_hasta,
	   _semana
  from chqpagco;

while _fecha_desde <= a_fecha_lim
    let _semana = _semana + 1; 
	let _fecha_desde = _fecha_desde + 7 units day;
	let _fecha_hasta = _fecha_hasta + 7 units day;

	insert into chqpagco(
			fecha_desde,
			fecha_hasta,
			semana)
	values(	_fecha_desde,
			_fecha_hasta,
			_semana);
end while

return 0,'Actualización Exitosa';

end
end procedure;