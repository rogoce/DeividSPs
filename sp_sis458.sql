-- Procedimiento que crea el registro de notificaciones para el app movil
-- Creado    : 07/05/2018	-- Román Gordón
-- execute procedure sp_sis458('237698','0217-00252-05',2)

drop procedure sp_sis458;
create procedure sp_sis458(a_cod_cliente char(10), a_no_documento char(20), a_tipo_notif smallint)
returning smallint, varchar(30);

define _mensaje				varchar(250);
define _codigo_parametro	char(18);
define _cod_agente			char(5);
define _cod_tipo			char(5);
define _cod_ramo			char(3);
define _exigible			dec(10,2);
define _ramo_sis			smallint;
define _error				smallint;
define _error_isam			smallint;
define _secuencia			integer;
define _secuencia2			integer;
define _fecha_suspension	date;

set isolation to dirty read;
begin
on exception set _error, _error_isam, _mensaje
 	return _error, _mensaje;
end exception

if a_cod_cliente = '237698' then
set debug file to "sp_sis458.trc";
trace on;
end if

select msg_format
  into _mensaje
  from deivid_web:tblTipoNotificaciones
 where IdTipoMensaje = a_tipo_notif;

let _mensaje = replace(trim(_mensaje),'%_no_documento%',trim(a_no_documento));

if a_tipo_notif = 2 then
	select fecha_suspension
	  into _fecha_suspension
	  from emipoliza
	 where no_documento = a_no_documento;

	let _mensaje = replace(trim(_mensaje),'%_fecha_suspension%',trim(cast(_fecha_suspension as char(10))));
end if

insert into deivid_web:tblNotificaciones(
		cod_cliente,
		tipo_mensaje,
		mensaje,
		fecha_creacion)
values(	a_cod_cliente,
		a_tipo_notif,
		_mensaje,
		current);

return 0,'Actualización Exitosa';
end
end procedure;