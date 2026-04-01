-- procedimiento que trae todos los correos de un cliente.
-- creado    : 27/12/2011 - Autor: Roman Gordon

drop procedure sp_sis163;

create procedure "informix".sp_sis163(a_cod_cliente char(10)) 
returning	char(384) as mails;

define _error_desc		varchar(100);
define _email			char(384);
define _email_climail	char(50);
define _len_climail		smallint;
define _max_length		smallint;
define _len_email		smallint;
define _len_final		smallint;
define _cantidad		smallint;
define _error			integer;
define _error_isam		integer;

on exception set _error, _error_isam, _error_desc
	--rollback work;
	return _error_desc;
end exception


set isolation to dirty read;
--set debug file to "sp_par310.trc"; 
--trace on;

let _max_length = 384;
let _email = '';
	
select trim(e_mail)
  into _email
  from cliclien
 where cod_cliente = a_cod_cliente;

if _email is null then
	let _email = '';
end if

foreach
	select distinct email
	  into _email_climail
	  from climail
	 where cod_cliente = a_cod_cliente
	   and email is not null
	   and email not like '%/%'
	   and email <> ''
	   and email like '%@%'
	   and email like '%.%'
	   and email not like '@%'
	   and email not like '% %'
	   and email not like '%,%'

	if _email = _email_climail then
		continue foreach;
	end if

	let _len_email		= length(_email); 
	let _len_climail	= length(_email_climail);
	let _len_final		= _len_email + _len_climail;

	if _len_email < _max_length then 
		let _email = trim(_email) || ';' || trim(_email_climail);
	end if
end foreach

if _email <> '' then
	let _email = trim(_email) || ';';
end if
return _email;
end procedure;