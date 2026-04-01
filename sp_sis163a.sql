-- procedimiento que trae todos los correos de un corredor.
-- creado    : 27/12/2011 - Autor: Roman Gordon

drop procedure sp_sis163a;

create procedure "informix".sp_sis163a(a_cod_agente char(5),a_tipo_correo char(3))
returning	char(384) as mails;

define _error_desc		varchar(100);
define _email_send		char(384);
define _email_agtmail	char(50);
define _email_cobros	char(50);
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
let _email_send = '';


select email_cobros
  into _email_cobros
  from agtagent
 where cod_agente = a_cod_agente
   and email_cobros is not null
   and email_cobros not like '%/%'
   and email_cobros <> ''
   and email_cobros like '%@%'
   and email_cobros like '%.%'
   and email_cobros not like '@%'
   and email_cobros not like '% %'
   and email_cobros not like '%,%'
   and trim(email_cobros) not like '%[^a-z,0-9,@,.]%' and trim(email_cobros) like '%_@_%_.__%';

if _email_cobros is null or _email_cobros = '' then
	let _email_send = '';
else
	let _email_send = trim(_email_cobros) || ';';
end if
	
foreach
	select email
	  into _email_agtmail
	  from agtmail
	 where cod_agente = a_cod_agente
	   and tipo_correo = a_tipo_correo
	   and email is not null
	   and email not like '%/%'
	   and email <> ''
	   and email like '%@%'
	   and email like '%.%'
	   and email not like '@%'
	   and email not like '% %'
	   and email not like '%,%'
	   and trim(email) not like '%[^a-z,0-9,@,.]%' and trim(email) like '%_@_%_.__%'
	 group by email
	
	if trim(_email_agtmail) = '' or _email_agtmail is null then
		continue foreach;
	end if
	if _email_agtmail = _email_cobros then
		continue foreach;
	else
		let _len_email		= length(trim(_email_send)); 
		let _len_climail	= length(trim(_email_agtmail));
		let _len_final		= _len_email + _len_climail;

		if _len_final < _max_length then
			let _email_send = trim(_email_send) || trim(_email_agtmail) || ';';
		end if
	end if
end foreach	

return _email_send;
end procedure;