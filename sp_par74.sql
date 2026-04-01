-- Procedimiento que carga las transacciones de reclamos para que se generen los registros contables
-- 
-- Creado     : 21/01/2003 - Autor: Demetrio Hurtado Almanza
-- Modificado :	21/01/2003 - Autor: Demetrio Hurtado Almanza
--
-- SIS v.2.0 - DEIVID, S.A.

drop procedure sp_par74;		

Create Procedure "informix".sp_par74(a_periodo1 CHAR(7), a_periodo2 CHAR(7))
RETURNING INTEGER, CHAR(100);
		  	
Define _no_tranrec        CHAR(10); 
Define _error_cod		  INTEGER;
Define _error_desc		  CHAR(100);

Set Isolation To Dirty Read;

Foreach
 Select no_tranrec
   Into _no_tranrec
   From rectrmae
  Where actualizado = 1
    and periodo    >= a_periodo1
    and periodo    <= a_periodo2

	delete from recasien
	 where no_tranrec = _no_tranrec;

--{
	Call sp_par71(_no_tranrec) RETURNING _error_cod, _error_desc;

	If _error_cod <> 0 then
		return _error_cod, _error_desc;
	end if
--}

End Foreach;

let _error_cod  = 0;
let _error_desc = "Proceso Completado ...";	
return _error_cod, _error_desc;

End Procedure;
