-- Procedimiento para retorna la ultima secuencia de parmailsend
--
-- Creado    : 23/03/2011 - Autor: Demetrio Hurtado Almanza
--
-- SIS v.2.0 - DEIVID, S.A.

--drop procedure sp_sis148;

create procedure "informix".sp_sis148()
returning integer;

define _secuencia	integer;

select max(secuencia)
  into _secuencia
  from deivid:parmailsend;

if _secuencia is null then
	let _secuencia = 0;
end if

let _secuencia = _secuencia + 1;

return _secuencia;

end procedure