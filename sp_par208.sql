-- Procedimiento que Genera los Registros Contables de Cobros por Mes
-- 
-- Creado    : 04/04/2006 - Autor: Demetrio Hurtado Almanza 

-- SIS v.2.0 - DEIVID, S.A.

DROP PROCEDURE sp_par208;		

create procedure "informix".sp_par208(a_periodo char(7))
returning integer,
          char(50);

define _no_remesa	char(10);
define _error		integer;
define _error_desc	char(50);

set isolation to dirty read;

foreach
 select no_remesa
   into _no_remesa
   from cobremae
  where periodo     = a_periodo
    and actualizado = 1

	call sp_par203(_no_remesa) returning _error, _error_desc;
	
	if _error <> 0 then
		return _error, _error_desc;
	end if 	

end foreach

return 0, "Actualizacion Exitosa";

end procedure