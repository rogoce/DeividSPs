-- Procedure que Incrementa el Contador de Combrobantes por Compania
-- Creado    : 07/07/2009 - Autor: Henry Giron --
-- SIS v.2.0 - DEIVID, S.A.

drop procedure sp_sac108;

create procedure "informix".sp_sac108(a_comp char(3)) 
returning integer;

define _notrx	integer;

SET ISOLATION TO DIRTY READ;

SET LOCK MODE TO WAIT;

--SET DEBUG FILE TO "sp_sac108.trc";  
--TRACE ON;                                                                 

select param_valor
  into _notrx
  from sigman25
 where param_comp     = a_comp
   and param_apl_id   = "CGL"             
   and param_apl_vers = "03"              
   and param_codigo   = "par_notrx";

let _notrx = _notrx + 1;

update sigman25
   set param_valor    = _notrx
 where param_comp     = a_comp
   and param_apl_id   = "CGL"             
   and param_apl_vers = "03"              
   and param_codigo   = "par_notrx";

return _notrx;

end procedure
