-- Procedure que Elimina un comprobante

-- Creado    : 26/09/2004 - Autor: Demetrio Hurtado Almanza 
--
-- SIS v.2.0 - DEIVID, S.A.


drop procedure sp_sac36;

create procedure sp_sac36(a_notrx integer)
returning integer,
          char(50);

-- Borrar

delete from cgltrx3
 where trx3_notrx = a_notrx;

delete from cgltrx2
 where trx2_notrx = a_notrx;

delete from cgltrx1
 where trx1_notrx = a_notrx;

return 0, "Actualizacion Exitosa";

end procedure
