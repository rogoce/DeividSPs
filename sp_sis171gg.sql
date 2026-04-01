-- Procedimiento que Cambia el Reaseguro para un Cobro en cobreaco a partir de las polizas que fueron cambiadas
-- en cambio de reaseguro masivo que se hizo a las polizas de automovil con vig ini >= 01/07/2013 y que se almacenaron en la tabla
-- camrea
-- 
-- Creado    : 01/10/2013 - Autor: Armando Moreno M.
-- Modificado: 01/10/2013 - Autor: Armando Moreno M.


drop procedure sp_sis171gg;
CREATE PROCEDURE "informix".sp_sis171gg()
RETURNING char(10),smallint;

--RETURNING date, char(10),char(20),CHAR(10),smallint;

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
define _no_documento    char(20);
define _fecha date;
define _valor decimal;


SET ISOLATION TO DIRTY READ;


--SET DEBUG FILE TO "sp_sis171g.trc";
--TRACE ON;

let _periodo = '2013-07';
let _cantidad = 0;
let _valor = 0;
begin


FOREACH


    select distinct c.no_remesa,c.renglon
	  into _no_remesa,_renglon
	  from cobreaco c, cobredet s
	 where c.no_remesa = s.no_remesa
	   and c.renglon   = s.renglon
	   and s.periodo   >= '2013-07'
	   and s.actualizado = 1
	   and c.porc_proporcion = 0

	call sp_sis171h(_no_remesa,_renglon) returning _error,_mensaje;
	
	if _error <> 0 then
		return _error,_mensaje;
	end if	

	return _no_remesa,_renglon with resume;


END FOREACH

{FOREACH


	select s.doc_remesa,s.no_poliza,s.fecha,c.no_remesa,c.renglon
	  into _no_documento,_no_poliza,_fecha,_no_remesa,_renglon
	  from cobreaco c, cobredet s
	 where c.no_remesa = s.no_remesa
	   and c.renglon   = s.renglon
	   and s.periodo   >= '2013-07'
	   and s.actualizado = 1
	   and c.porc_proporcion = 0
	  order by s.fecha

    select sum(porc_proporcion)
	  into _valor
	  from cobreaco
	 where no_remesa = _no_remesa
	   and renglon   = _renglon;

    if _valor = 0 then

		return _fecha,_no_poliza,_no_documento,_no_remesa,_renglon with resume;

	end if

END FOREACH	}

end

END PROCEDURE;