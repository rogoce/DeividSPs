-- Procedimiento que Cambia la Cartera de un Cobrador a Otro
-- 
-- Creado    : 28/04/2003 - Autor: Demetrio Hurtado Almanza 
-- Modificado: 28/04/2003 - Autor: Demetrio Hurtado Almanza
--
-- SIS v.2.0 - DEIVID, S.A.

drop procedure sp_cas010;

create procedure sp_cas010(a_cobrador_ant char(3), a_cobrador_nue char(3), a_activo smallint default 0)
returning smallint,
          char(100);

DEFINE _error	SMALLINT; 

BEGIN

ON EXCEPTION SET _error 
 	RETURN _error, "Error al Cambiar el Cobrador ...";         
END EXCEPTION           

update cascliente
   set cod_cobrador = a_cobrador_nue
 where cod_cobrador = a_cobrador_ant;

update cobcapen
   set cod_cobrador = a_cobrador_nue
 where cod_cobrador = a_cobrador_ant;


update cobcobra
   set activo = a_activo
 where cod_cobrador = a_cobrador_ant;


END

return 0, "Actualizacion Exitosa ...";

end procedure

