-- Determina la cantidad de Registros a trabajar por cada Gestor
-- 
-- Creado    : 23/06/2003 - Autor: Demetrio Hurtado Almanza 
-- Modificado: 23/06/2003 - Autor: Demetrio Hurtado Almanza
--
-- SIS v.2.0 - DEIVID, S.A.

--drop procedure sp_cas045;

create procedure sp_cas045(
a_cod_cobrador	char(3),
a_dia			smallint
) returning smallint;

define _cantidad	smallint;

select count(*)
  into _cantidad
  from cascliente
 where cod_cobrador = a_cod_cobrador
   and ( dia_cobros1 = a_dia or 
         dia_cobros2 = a_dia or 
         dia_cobros3 = a_dia );

return _cantidad;

end procedure


