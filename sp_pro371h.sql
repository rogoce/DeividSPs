-- Procedimiento que carga el archivo de renovaciones para la Cartera Banisi.
-- creado    : 08/03/2021 - Autor: Roman Gordon--
-- sis v.2.0 - deivid, s.a.
-- execute procedure sp_pro371_banisi('2020-10')

drop procedure sp_pro371h;
create procedure "informix".sp_pro371h(a_poliza char(10))
returning   integer,
			char(100);   -- _error

define _error_desc		varchar(100);
define _no_documento	char(20);
define _no_poliza		char(10);
define _periodo			char(7);
define _mes				char(2);
define _error_isam		integer;
define _error			integer;

begin

on exception set _error,_error_isam,_error_desc
 	return _error,_error_desc;
end exception

if a_poliza = '1868297' then
	set debug file to "sp_pro371.trc";
	trace on;
end if

set isolation to dirty read;

let _error = 0;
let _error_desc = "";


call sp_pro371(a_poliza) returning _error, _error_desc;	

end

if _error is null then
	let _error = 0;
end if

if _error_desc is null then
	let _error_desc = "";
end if

return _error, _error_desc;
end procedure;