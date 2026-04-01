-- Procedimiento que verifica si la póliza estaba en suspensión de cobertura para una fecha dada.
-- Creado: 17/10/2017 - Autor: Román Gordón
--
drop procedure sp_ley01;
create procedure sp_ley01(a_no_documento char(20), a_fecha_verifica date)
returning	smallint		as cod_error,
			varchar(100)	as poliza,
			date			as cubierto_hasta;

define _mensaje				varchar(100);
define _error_isam			integer;
define _error				integer;
define _fecha_suspension	date;

set isolation to dirty read;

--set debug file to "sp_ley01.trc";
--trace on;

--Query para crear la temporal

begin
on exception set _error,_error_isam,_mensaje
return _error,_mensaje,null;
end exception

foreach
	select fecha_desde
	  into _fecha_suspension
	  from leysuscob
	 where no_documento = a_no_documento
	   and a_fecha_verifica between fecha_desde and fecha_hasta

	return 1,a_no_documento,_fecha_suspension;
end foreach

return 0,'Exito',null;

end
end procedure;