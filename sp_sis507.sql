-- Procedimiento que devuelve el ultimo dia del mes dado el periodo
--
-- Creado    : 13/02/2003 - Autor: Demetrio Hurtado Almanza
-- Modificado: 13/02/2003 - Autor: Demetrio Hurtado Almanza

-- SIS v.2.0 - DEIVID, S.A.

drop procedure sp_sis507;
create procedure "informix".sp_sis507() 
returning smallint;

define _email		varchar(50);
define _cod_cliente	char(10);
define _error		smallint;

begin
on exception set _error
    rollback work;
	return	_error;
end exception  

set isolation to dirty read;

foreach
	select p.email,
		   c.cod_cliente
	  into _email,
		   _cod_cliente
	  from parmailerr p, cliclien c,emipomae e
	 where e.cod_pagador = c.cod_cliente
	   and p.email = c.e_mail
	   and (e.estatus_poliza = 1 or (e.estatus_poliza = 3 and e.vigencia_final >= '01/04/2018'))
	   and e.actualizado = 1
	   and p.cod_cliente = '00000'

	insert into parmailerr(
			cod_cliente,
			email)
	values(	_cod_cliente,
			_email);

	delete from parmailerr
	 where cod_cliente = '00000'
	   and email = _email;
end foreach
return 0;
end
end procedure;