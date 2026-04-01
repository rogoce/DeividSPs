-- Procedimiento que verifica si la póliza estaba en suspensión de cobertura para una fecha dada.
-- Creado: 17/10/2017 - Autor: Román Gordón
--execute procedure sp_ley002('',1)
drop procedure sp_ley002;
create procedure sp_ley002(a_no_documento char(20),a_origen smallint)
returning	integer			as cod_error,
			varchar(100)	as mensaje;

define _mensaje				varchar(100);
define _excepcion			smallint;
define _error_isam			integer;
define _error				integer;
define _fecha_suspension	date;
define _cubierto_hasta		date;
define _fecha_hoy			date;
define _cod_grupo,_no_poliza   char(10);

set isolation to dirty read;

--set debug file to "sp_ley002.trc";
--trace on;

begin
on exception set _error,_error_isam,_mensaje
return _error,_mensaje;
end exception

--Procedimiento de verificación de excepciones
call sp_ley003(a_no_documento,2) returning _excepcion,_mensaje;
if _excepcion <> 0 then
	return _excepcion,_mensaje;
end if

let _no_poliza = sp_sis21(a_no_documento);

select cod_grupo
  into _cod_grupo
  from emipomae
 where no_poliza = _no_poliza;
 
if _cod_grupo in('78033','78032','78034') then
	return 1,'El Grupo no aplica';
end if
 
let _fecha_hoy = current;

--Procedimiento que retorna la fecha hasta donde esta cubierta la póliza
call sp_dev06(a_no_documento,_fecha_hoy) returning _error,_mensaje,_cubierto_hasta,_fecha_suspension;

if _error <> 0 then
	let _mensaje = _mensaje || ' ' || trim(a_no_documento);
	return _error,_mensaje;
end if

if _cubierto_hasta is not null then

	--Cerrar el último ciclo de suspensión de cobertura
	if _cubierto_hasta > _fecha_hoy then
		update leysuscob
		   set fecha_hasta = _fecha_hoy,
			   activo = 0,
			   last_update = current
		 where no_documento = a_no_documento
		   and activo = 1;
	end if

	--Actualizar la fecha hasta donde esta cubierta la póliza.
	update emipoliza
	   set fecha_cubierto = _cubierto_hasta,
		   fecha_suspension = _fecha_suspension,
		   flag_cubierto = 1
	 where no_documento = a_no_documento;

	if _cubierto_hasta <= _fecha_hoy then
		--Endosos
		if a_origen = 1 then
		--El endoso va a dejar a la póliza en suspensión de cobertura
		
			--return 1,'El endoso dejaría a la póliza en suspensión de cobertura desde el ' || cast(_cubierto_hasta as char(11));
		end if
	end if
end if
return 0,'Exito';
end
end procedure;