-- Procedure que Elimina los comprobantes no utilizados

-- Creado    : 26/09/2004 - Autor: Demetrio Hurtado Almanza 
--
-- SIS v.2.0 - DEIVID, S.A.


--drop procedure sp_sac12;

create procedure sp_sac12();

-- Borrar

delete from cgltrx3
 where trx3_notrx > 7;

delete from cgltrx2
 where trx2_notrx > 7;

delete from cgltrx1
 where trx1_notrx > 7;


update sigman25
   set param_valor    = 7
 where param_comp     = "001"
   and param_apl_id   = "CGL"             
   and param_apl_vers = "03"              
   and param_codigo   = "par_notrx";

end procedure