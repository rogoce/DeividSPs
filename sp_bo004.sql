-- Cobros por Seccion para Subir a BO
-- 
-- Creado    : 23/06/2004 - Autor: Demetrio Hurtado Almanza 
-- Modificado: 23/06/2004 - Autor: Demetrio Hurtado Almanza
--

drop procedure sp_bo004;

create procedure "informix".sp_bo004(a_periodo char(7))
returning char(1),
          char(100);

foreach
 select periodo,
        count(*)
   from recrcmae
  where actualizado = 1


end procedure
