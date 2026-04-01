-- Procedimiento que Cambia el Reaseguro para un Cobro en cobreaco a partir de las polizas que fueron cambiadas
-- en cambio de reaseguro masivo que se hizo a las polizas de automovil con vig ini >= 01/07/2013 y que se almacenaron en la tabla
-- camrea
-- 
-- Creado    : 01/10/2013 - Autor: Armando Moreno M.
-- Modificado: 01/10/2013 - Autor: Armando Moreno M.


drop procedure sp_sis171cobk;
CREATE PROCEDURE "informix".sp_sis171cobk()
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

--let _periodo = '2014-05';
let _cantidad = 0;

begin

on exception set _error,_error_isam,_mensaje
	let _mensaje = trim(_mensaje) || 'Verificar la Remesa: ' || trim(_no_remesa) || ' en el Renglon: ' || trim(cast(_renglon as char(3)));
	rollback work;
 	return _error,_mensaje;
end exception

FOREACH WITH HOLD
 SELECT	no_poliza
   INTO	_no_poliza
   FROM	camrea
  group by no_poliza
  order by no_poliza

	{
	 select count(*)
	   into _cnt
	   from camcobreaco
	  where no_poliza = _no_poliza;

	 if _cnt > 0 then
		continue foreach;
	 end if
	}

	 begin work;

	 let _no_remesa = null;

	foreach
	 select no_remesa,
	        renglon,
			periodo
	   into _no_remesa,
		    _renglon,
			_periodo
	   from cobredet
	  where no_poliza   = _no_poliza
	    and tipo_mov    IN ("P", "N")
	    and actualizado = 1

	   if _no_remesa is null then
			continue foreach;
	   end if

	   call sp_sis171hh(_no_remesa,_renglon) returning _error,_mensaje;

	   if _error <> 0 then
	   		return _error, _mensaje;
	   end if
       if _periodo >= '2015-09' then
		   update cobredet
			  set sac_asientos = 0
			where no_remesa = _no_remesa;

			update sac999:reacomp
			   set sac_asientos = 0
			  where no_remesa = _no_remesa
				and renglon   = _renglon
				and tipo_registro = 2;
       end if	   
	end foreach

   select count(*)
     into _cnt
	 from cobredet
	where no_poliza   = _no_poliza
	  and tipo_mov    IN ("P", "N")
	  and actualizado = 1;

--	if _cnt > 0 then
		let _cantidad = _cantidad + 1;
--	end if

	COMMIT WORK;

--	if _cantidad >= 5000 then
--		exit foreach;
--	end if

END FOREACH

LET _mensaje = 'Actualizacion Exitosa, Registros ' || _cantidad;
RETURN 0, _mensaje;
end

END PROCEDURE;