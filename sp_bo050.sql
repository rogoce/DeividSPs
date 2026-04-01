-- Procedimiento que crea las tablas para la carga de los estados financieros

-- Creado    : 14/10/2005 - Autor: Demetrio Hurtado Almanza

-- SIS v.2.0 - DEIVID, S.A.

--drop procedure sp_bo050;

create procedure "informix".sp_bo050(a_cia_bda_codigo char(18))
returning char(3);

define _cia_comp	char(3);

set isolation to dirty read;

select cia_comp
  into _cia_comp
  from sigman02
 where cia_bda_codigo = a_cia_bda_codigo;

return _cia_comp;

end procedure