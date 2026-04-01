-- Procedimiento para retorna la ultima secuencia de parmailcomp
--
-- Creado    : 23/03/2011 - Autor: Demetrio Hurtado Almanza
--
-- SIS v.2.0 - DEIVID, S.A.

--drop procedure sp_sis149;

create procedure "informix".sp_sis149()
returning integer;

define _secuencia	integer;

select max(secuencia)
  into _secuencia
  from parmailcomp;

if _secuencia is null then
	let _secuencia = 0;
end if

let _secuencia = _secuencia + 1;

return _secuencia;

end procedure