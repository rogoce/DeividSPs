
drop procedure sp_cob280a;
create procedure "informix".sp_cob280a(a_user_added	char(8))
returning	integer,
			char(100);


define _html_body		char(512);
define _email			char(200);
define _email_cc		char(200);
define _error_desc		char(100);
define _email_cliente	char(50);
define _email_agt		char(50);
define _no_documento	char(20);
define _no_cuenta		char(17);
define _cod_cliente		char(10);
define _no_poliza		char(10);
define _user_added		char(8);
define _cod_agente		char(5);
define _cod_tipo		char(5);
define _adjunto			smallint;
define _rechazo			smallint;
define _secuencia		integer;
define _secuencia_comp	integer;
define _error			integer;
define _error_isam		integer;
define _mail_err        integer;


on exception set _error, _error_isam, _error_desc
	--rollback work;
	return _error,_error_desc;
end exception

set isolation to dirty read;
--set debug file to "sp_cob280a.trc"; 
--trace on;

let _email_cliente	= '';
let _user_added 	= a_user_added;

foreach
	select cod_pagador,
		   no_documento,
		   no_cuenta
	  into _cod_cliente,
		   _no_documento,
		   _no_cuenta
	  from cobcutmp	 
	 where rechazado = 1

	select e_mail
	  into _email_cliente
	  from cliclien
	 where cod_cliente = _cod_cliente;

	call sp_sis21(_no_documento) returning _no_poliza;

	let _email_cliente = trim(_email_cliente);

	if _email_cliente is null or _email_cliente = '' then
	else
		select count(*)
		  into _rechazo
		  from parmailerr
		 where email = _email_cliente;

		if _rechazo > 0 then
		   continue foreach;
		end if
	end if

	let _email = trim(_email_cliente) || ';';

	foreach
		select email
		  into _email_cliente
		  from climail
		 where cod_cliente = _cod_cliente

		if _email is null then
			let _email = '';
		end if

		if _email_cliente = _email then
			continue foreach;
		end if

		select count(*)
		  into _mail_err
		  from parmailerr
		 where email = _email_cliente;

		if _mail_err > 0 then
		   continue foreach;
		end if
		
		let _email = trim(_email) || trim(_email_cliente) || ';';
	end foreach

	let _secuencia = sp_sis148(); 
	let _cod_tipo = '00023';
	let _html_body = "<html><img src=cid:" ||  _secuencia || ".jpg width=850 height=1100>";

	if _email_cliente is null or _email_cliente = '' or _rechazo > 0 then
	else

		insert into parmailsend(
		cod_tipo,
		email,
		enviado,
		adjunto,
		secuencia,
		html_body,
		sender,
		fecha_envio
		)
		values(
		_cod_tipo,
		_email,
		0,
		1,
		_secuencia,
		_html_body,
		'',
		null
		);

		let _secuencia_comp = sp_sis149();

		insert into parmailcomp (
		secuencia,
		mail_secuencia,
		no_remesa,
		no_documento,
		asegurado,
		renglon,
		fecha
		)
		values(
		_secuencia_comp,
		_secuencia,
		a_user_added,
		_no_documento,
		_no_cuenta,
		2,
		current
		);
	end if

{foreach 
	select cod_agente
	  into _cod_agente
	  from emipoagt
	 where no_poliza = _no_poliza
	 order by porc_partic_agt
	exit foreach;
end foreach

let _email_agt = '';
let _email_cc = '';

foreach
	select email
	  into _email_agt
	  from agtmail
	 where cod_agente = _cod_agente
	   and tipo_correo = 'COB'

	let _email_cc = trim(_email_cc) || trim(_email_agt) || ';';}
end foreach;
return 0,'';

end procedure;