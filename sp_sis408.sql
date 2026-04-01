--****************************************************************
-- Procedimiento que verifica las polizas de salud sin cobertura
--****************************************************************

-- Creado    : 12/12/2012 - Autor: Armando Moreno M.
-- Modificado: 12/12/2012 - Autor: Armando Moreno M.

drop procedure sp_sis408;

create procedure "informix".sp_sis408()
RETURNING char(10),char(20),char(7),smallint;

--- Actualizacion de Polizas

define _no_documento   char(20);
define _no_poliza      char(10);
define _periodo        char(7);
define _cnt,_estatus   smallint;


--SET DEBUG FILE TO "sp_pro320c.trc"; 
--trace on;

BEGIN


set isolation to dirty read;


foreach

	select no_poliza,periodo,no_documento,estatus_poliza
	  into _no_poliza,_periodo,_no_documento,_estatus
	  from emipomae
	 where cod_ramo = '018'
	   and actualizado = 1

	select count(*)
	  into _cnt
	  from emipocob
	 where no_poliza = _no_poliza;

	if _cnt = 0 then
		RETURN _no_poliza,_no_documento,_periodo,_estatus with resume;

	end if
end foreach

{foreach
	select a.no_documento,e.no_poliza
	  into _no_documento,_no_poliza
	  from a a, emipomae e
	 where a.no_documento = e.no_documento
	   and e.carta_aviso_canc = 1
	   and e.actualizado = 1

     update emipomae
	    set carta_aviso_canc = 0
	  where no_poliza = _no_poliza;

end foreach}


END
end procedure;