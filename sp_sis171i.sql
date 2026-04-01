-- Procedimiento que Cambia el Reaseguro para un Reclamo en recreaco / rectrrea, a partir de las polizas que fueron cambiadas
-- en cambio de reaseguro masivo que se hizo a las polizas de automovil con vig ini >= 01/07/2013 y que se almacenaron en la tabla
-- camrea
-- 
-- Creado    : 01/10/2013 - Autor: Armando Moreno M.
-- Modificado: 01/10/2013 - Autor: Armando Moreno M.


drop procedure sp_sis171i;
create procedure "informix".sp_sis171i()
returning integer, char(250);

define _mensaje			char(250);
define _error		    integer;

define _no_reclamo      char(10);
define _no_poliza       char(10);
define _periodo         char(7);
define _no_unidad       char(5);
define _renglon         smallint;
define _error_isam		integer;


set isolation to dirty read;

--set debug file to "sp_sis171g.trc";
--trace on;

let _periodo = '2015-07';

begin

on exception set _error,_error_isam,_mensaje
	let _mensaje = trim(_mensaje) || 'Verificar el Reclamo: ' || trim(_no_reclamo);
	rollback work;
 	return _error,_mensaje;
end exception

foreach with hold
	select no_poliza,
		   no_unidad
	  into _no_poliza,
		   _no_unidad
	  from camrea
	group by no_poliza,no_unidad
	order by no_poliza,no_unidad

	begin work;

	let _no_reclamo = null;

	foreach
		select no_reclamo
		  into _no_reclamo
		  from recrcmae
		 where periodo     >= _periodo
		   and no_poliza   = _no_poliza
		   and no_unidad   = _no_unidad
		   and actualizado = 1

		if _no_reclamo is null then
		else
		   call sp_sis18bk(_no_reclamo) returning _error,_mensaje;

		   if _error <> 0 then
		   		return _error, _mensaje;
		   end if
		end if
	end foreach

	commit work;
end foreach

let _mensaje = 'Actualizacion Exitosa ...';
return 0, _mensaje;
end

end procedure;