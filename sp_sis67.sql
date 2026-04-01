-- Procedure que controla que cuentas se pueden afectar 

-- Creado    : 17/11/2004 - Autor: Demetrio Hurtado Almanza
--
-- SIS v.2.0 - DEIVID, S.A.

--drop procedure sp_sis67;

create procedure "informix".sp_sis67(a_cuenta char(25))
returning smallint;

define _se_puede	smallint;

let _se_puede = 1;

if a_cuenta[1,3] = "131" then
	let _se_puede = 0;
elif a_cuenta[1,3] = "144" then
	let _se_puede = 0;
end if

return _se_puede;

end procedure