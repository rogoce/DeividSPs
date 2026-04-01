-- Procedimiento que Cambia el Reaseguro para un Cobro en cobreaco a partir de las polizas que fueron cambiadas
-- en cambio de reaseguro masivo que se hizo a las polizas de automovil con vig ini >= 01/07/2013 y que se almacenaron en la tabla
-- camrea
-- 
-- Creado    : 01/10/2013 - Autor: Armando Moreno M.
-- Modificado: 01/10/2013 - Autor: Armando Moreno M.


--drop procedure sp_sis171cobk1;
CREATE PROCEDURE "informix".sp_sis171cobk1()
RETURNING INTEGER, CHAR(250);

DEFINE _mensaje			CHAR(250);
DEFINE _error		    INTEGER;

DEFINE _no_poliza       CHAR(10);
DEFINE _renglon         SMALLINT;
DEFINE _no_unidad       CHAR(5);
define _no_remesa       char(10);
define _error_isam		integer;
define _periodo         char(7);
define _cantidad        integer;
define _cnt             integer;
define _periodo2        char(7);


SET ISOLATION TO DIRTY READ;


--SET DEBUG FILE TO "sp_sis171co.trc";
--TRACE ON;


let _cantidad = 0;

begin

on exception set _error,_error_isam,_mensaje
	let _mensaje = trim(_mensaje) || 'Verificar la Remesa: ' || trim(_no_remesa) || ' en el Renglon: ' || trim(cast(_renglon as char(3)));
	rollback work;
 	return _error,_mensaje;
end exception

	 begin work;

	 let _no_remesa = null;

	foreach
	 select no_remesa,
	        renglon
	   into _no_remesa,
		    _renglon
	   from camcobreaco
	  
     select periodo
	   into _periodo
	   from cobredet
	  where no_remesa = _no_remesa
		and renglon   = _renglon; 

       if _periodo >= '2015-09' then

			update sac999:reacomp
			   set sac_asientos = 0
			  where no_remesa = _no_remesa
				and renglon   = _renglon
				and tipo_registro = 2;
       end if	   
	end foreach


LET _mensaje = 'Actualizacion Exitosa, Registros ' || _cantidad;
RETURN 0, _mensaje;
end

END PROCEDURE;