-- Procedure que Incrementa el Contador de Combrobantes

-- Creado    : 23/09/2004 - Autor: Demetrio Hurtado Almanza 
--
-- SIS v.2.0 - DEIVID, S.A.


drop procedure sp_sac10;

create procedure "informix".sp_sac10() 
returning integer;

define _notrx	integer;

select param_valor
  into _notrx
  from sigman25
 where param_comp     = "001"
   and param_apl_id   = "CGL"             
   and param_apl_vers = "03"              
   and param_codigo   = "par_notrx";

let _notrx = _notrx + 1;

update sigman25
   set param_valor    = _notrx
 where param_comp     = "001"
   and param_apl_id   = "CGL"             
   and param_apl_vers = "03"              
   and param_codigo   = "par_notrx";

return _notrx;

end procedure
