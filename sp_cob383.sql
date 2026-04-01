-- Procedimiento que Genera la Remesa de los Cobros diarios de Ducruet
-- Creado    : 17/11/2015 - Autor: Roman Gordon
-- SIS v.2.0 - DEIVID, S.A.

drop procedure sp_cob383;
create procedure 'informix'.sp_cob383(a_no_aviso char(10)) 
returning	smallint,
			varchar(255);

define _error_desc			varchar(255);
define _cnt_procesado		smallint;
define _cnt_total			smallint;
define _error_isam			integer;
define _error				integer;

set isolation to dirty read;

--set debug file to 'sp_cob317.trc';
--trace on ;

begin

on exception set _error, _error_isam, _error_desc 
 	return _error, _error_desc;
end exception

select count (*)
  into _cnt_total
  from avisocanc
 where no_aviso = a_no_aviso;
 
if _cnt_total is null then
	let _cnt_total = 0;
end if

select count (*)
  into _cnt_procesado
  from avisocanc
 where no_aviso = a_no_aviso
   and estatus = 'G';

if _cnt_procesado is null then
	let _cnt_procesado = 0;
end if

if _cnt_procesado = _cnt_total then
	return 1, 'La Campaña no ha sido procesada, esta campaña debe ser procesada antes de Reimprimir los Avisos de Cancelación';
end if

return 0, 'Actualizacion Exitosa'; 		
end 
end procedure;