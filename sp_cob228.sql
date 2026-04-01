-- Informe de Caja

-- Creado    : 30/01/2010 - Autor: Demetrio Hurtado Almanza 
--
-- SIS v.2.0 - DEIVID, S.A.
  
--drop procedure sp_cob228;

create procedure sp_cob228(a_cod_chequera char(3)) 
returning integer,
          char(100);

define _no_remesa	char(10);

foreach
 select no_remesa
   into _no_remesa
   from cobremae
  where cod_chequera = a_cod_chequera

end foreach



end procedure 
