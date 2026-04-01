-- Cambiar un Rutero por Otro

-- Creado    : 19/06/2003 - Autor: Demetrio Hurtado Almanza
-- Modificado: 19/06/2003 - Autor: Demetrio Hurtado Almanza

-- SIS v.2.0 - DEIVID, S.A.

drop procedure sp_cas032;	  

create procedure sp_cas032(
a_rutero_ant char(3), 
a_rutero_nue char(3)
) returning integer,
            char(100);

define _error	integer;

begin work;

begin
on exception set _error

	rollback work;
	return _error, "Error Al Actualizar los Registros";

end exception

update gencorr
   set cod_cobrador = a_rutero_nue
 where cod_cobrador = a_rutero_ant;

update cobruter1
   set cod_cobrador = a_rutero_nue
 where cod_cobrador = a_rutero_ant;

update cobruter2
   set cod_cobrador = a_rutero_nue
 where cod_cobrador = a_rutero_ant;

update cobruter
   set cod_cobrador = a_rutero_nue
 where cod_cobrador = a_rutero_ant;

update cobcobra
   set activo       = 0
 where cod_cobrador = a_rutero_ant;

end

commit work;

return 0, "Actualizacion Exitosa";

end procedure
