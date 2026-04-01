-- Procedimiento que actualiza la fecha de indicador para los reportes de BO 
-- Creado     :	13/11/2007 - Autor: Demetrio Hurtado Almanza
-- SIS v.2.0 - DEIVID, S.A.

drop procedure sp_par323;
create procedure sp_par323() 
returning integer,
          char(50);

define _error_desc		varchar(50);
define _no_poliza		char(10);
define _periodo			char(7);
define _no_endoso		char(5);
define _fecha_emision	date;
define _fecha_indicador	date;
define _error_isam		smallint;
define _cantidad		integer;
define _error			smallint;

begin 
on exception set _error, _error_isam, _error_desc
	return _error, _error_desc;
end exception

let _cantidad = 0;

foreach
	select no_poliza,
		   no_endoso,
		   fecha_emision,
		   periodo
	  into _no_poliza,
		   _no_endoso,
		   _fecha_emision,
		   _periodo
	  from endedmae
	 where actualizado     = 1
	   and fecha_indicador is null

	let _cantidad = _cantidad + 1;
	let _fecha_indicador = sp_sis156(_fecha_emision, _periodo);

	update endedmae
	   set fecha_indicador = _fecha_indicador
	 where no_poliza       = _no_poliza
	   and no_endoso	   = _no_endoso;
end foreach
end 
return _cantidad, "Registros Procesados";
end procedure;