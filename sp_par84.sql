-- Procedimiento que Verifica que todas las promotorias esten asignadas

-- Creado    : 02/09/2003 - Autor: Demetrio Hurtado Almanza
-- Modificado: 02/09/2003 - Autor: Demetrio Hurtado Almanza

-- SIS v.2.0 - d_para_agentes_promotoria_parametros - DEIVID, S.A.

--drop procedure sp_par84;

create procedure "informix".sp_par84(
a_cod_agente 	char(5)
) returning smallint;

define _cantidad char(3);

set isolation to dirty read;

 select count(*)
   into _cantidad
   from parpromo
  where cod_agente   = a_cod_agente
    and cod_vendedor is null;

return _cantidad;

end procedure;