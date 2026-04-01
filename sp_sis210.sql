-- Procedimiento que Cambia el Reaseguro para un Cobro en cobreaco a partir de las polizas que fueron cambiadas
-- en cambio de reaseguro masivo que se hizo a las polizas de automovil con vig ini >= 01/07/2013 y que se almacenaron en la tabla
-- camrea
-- 
-- Creado    : 01/10/2013 - Autor: Armando Moreno M.
-- Modificado: 01/10/2013 - Autor: Armando Moreno M.


drop procedure sp_sis210;
CREATE PROCEDURE "informix".sp_sis210()
RETURNING char(10), integer;

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


FOREACH
 
 SELECT	no_remesa,renglon
   INTO	_no_remesa,_renglon
   FROM	camcobreaco
   order by no_remesa,renglon
   
   select count(*)
     into _cnt
	 from cobreaco
	where no_remesa = _no_remesa
      and renglon   = _renglon
      and cod_contrato in('00645','00646');
    
	if _cnt is null then
		let _cnt = 0;
	end if
	if _cnt > 0 then
	else
		return _no_remesa,_renglon with resume;
		
		delete from camcobreaco
		where no_remesa = _no_remesa
          and renglon   = _renglon;
	end if
	
end foreach
end

END PROCEDURE;