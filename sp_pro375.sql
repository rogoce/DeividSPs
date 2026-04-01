-- Proceso que elimina las Renovaciones de Ducruet ( Soda) del Pool de Renovaciones que tengan 2 periodos de antiguedad 
-- Creado    : 25/04/2013 - Autor: Roman Gordon
-- SIS v.2.0 - DEIVID, S.A.

drop procedure sp_pro375;

create procedure "informix".sp_pro375()
returning integer,
          char(50);
		  
define _error_desc		char(50);
define _no_documento	char(20);
define _no_poliza		char(10);
define _periodo			char(7);
define _cod_agente		char(5);
define _ano_char		char(4);
define _cod_ramo		char(3);
define _mes_char		char(2);
define _dia_char		char(2);
define _mes				smallint;
define _ano				smallint;
define _dia				smallint;
define _error_isam		integer;
define _error			integer;
define _fecha_hasta		date;
define _fecha_desde		date;
define _fecha_hoy		date;

--set debug file to "sp_pro375.trc";
--trace on;

set isolation to dirty read;

begin
on exception set _error,_error_isam,_error_desc
	return _error,_error_desc;
end exception

let _cod_agente	= '00035';
let _fecha_hoy = current;
let _dia = 1;
let _ano = year(_fecha_hoy);
let _mes = month(_fecha_hoy);
let _mes = _mes - 2;

if _mes < 1 then
	let _mes = _mes + 12;
	let _ano = _ano - 1;
end if

let _ano_char = _ano;

if _mes < 10 then
	let _mes_char = '0'|| _mes;
else
	let _mes_char = _mes;
end if

let _periodo  = _ano_char || "-" || _mes_char;

call sp_sis36(_periodo) returning _fecha_hasta;
let _fecha_desde = mdy(_mes,_dia,_ano);

foreach
	select no_poliza
	  into _no_poliza
	  from emirepol
	 where cod_agente = _cod_agente
	   and vigencia_final > _fecha_desde
	   and vigencia_final < _fecha_hasta
	
	select no_documento,
		   cod_ramo
	  into _no_documento,
		   _cod_ramo
	  from emipomae
	 where no_poliza = _no_poliza;
	 
	if _cod_ramo <> '020' then
		continue foreach;
	end if
	
	call sp_sis61d(_no_poliza) returning _error;
	
	if _error <> 0 then
		return _error,'Error al Eliminar las tablas temporales de la póliza: ' || _no_documento || ', Verifique';
	end if
	
	delete from emirepol
	 where no_poliza = _no_poliza;
end foreach

return 0,'Eliminación Exitosa';
end 
end procedure