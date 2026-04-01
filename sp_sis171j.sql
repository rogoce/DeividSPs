-- Procedimiento que Determina el Reaseguro para un Cobro
-- 
-- Creado    : 02/08/2012 - Autor: Armando Moreno M.
-- Modificado: 02/08/2012 - Autor: Armando Moreno M.


drop PROCEDURE sp_sis171j;

CREATE PROCEDURE "informix".sp_sis171j()
RETURNING smallint, CHAR(250);

define _mensaje		char(250);
DEFINE _no_remesa	CHAR(10);
DEFINE _renglon		SMALLINT;
define _error		smallint;

SET ISOLATION TO DIRTY READ;

--SET DEBUG FILE TO "sp_sis171.trc";
--TRACE ON;

-- Lectura del Detalle de la Remesa

foreach
	select distinct no_remesa,
		   renglon
	  into _no_remesa,
		   _renglon
	  from cobreaco 
	 where porc_proporcion = 0 
	   and cod_cober_reas in ('001','021')
	
	call sp_sis171h(_no_remesa,_renglon) returning _error,_mensaje;
	
	if _error <> 0 then
		return _error,_mensaje;
	end if	
	return _renglon, _no_remesa with resume;
end foreach


LET _mensaje = 'Actualizacion Exitosa ...';
return 0, _mensaje;

end procedure;
