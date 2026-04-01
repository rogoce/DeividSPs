-- Procedimiento que carga las transacciones de reclamos para que se generen los registros contables
-- 
-- Creado     : 21/01/2003 - Autor: Demetrio Hurtado Almanza
-- Modificado :	21/01/2003 - Autor: Demetrio Hurtado Almanza
--
-- SIS v.2.0 - DEIVID, S.A.

drop procedure sp_sac60;		

create procedure "informix".sp_sac60()
returning integer, char(100);
		  	
define _no_tranrec      char(10); 
define _error_cod		integer;
define _error_desc		char(100);
define _periodo         char(7);

define _cantidad		integer;

set isolation to dirty read;

let _cantidad = 0;

select periodo_verifica
  into _periodo
  from emirepar;
  
foreach
 select no_tranrec
   into _no_tranrec
   from rectrmae
  where actualizado  = 1
    and sac_asientos = 0
	and periodo      = _periodo

	let _cantidad = _cantidad + 1;
	
	delete from recasiau where no_tranrec = _no_tranrec;
	delete from recasien where no_tranrec = _no_tranrec;

	call sp_par71(_no_tranrec) returning _error_cod, _error_desc;

	if _error_cod <> 0 then
		return _error_cod, _error_desc;
	end if

	update rectrmae
	   set sac_asientos = 1
	 where no_tranrec   = _no_tranrec;

--	if _cantidad >= 1000 then 
--		exit foreach;
--	end if

end foreach;

let _error_cod  = 0;
let _error_desc = "Proceso Completado ...";	
return _error_cod, _error_desc;

end procedure;
