-- Procedimiento que Genera el html body y la secuencia del envio de correos masivos 	

-- Creado    : 15/11/2010 - Autor: Roman Gordon

drop procedure sp_cob280bamm;
create procedure sp_cob280bamm(a_user_added	char(8))
returning	integer,
			char(100);

define _html_body		char(512);
define _email_cc		char(200);
define _email			char(250);
define _error_desc		char(100);
define _email_cliente	char(50);
define _email_agt		char(50);
define _no_documento	char(20);
define _no_tarjeta		char(20);
define _cod_cliente		char(10);
define _no_poliza		char(10);
define _user_added		char(8);
define _cod_agente		char(5);
define _cod_tipo		char(5); 
define _cnt_existe		smallint;
define _cnt_mail		smallint;
define _adjunto			smallint;
define _rechazo			smallint;
define _flag_corr		smallint;
define _secuencia		integer;
define _secuencia_corr	integer;
define _secuencia_comp	integer;
define _error			integer;
define _error_isam		integer;
define _mail_err        integer;

on exception set _error, _error_isam, _error_desc
	--rollback work;
	return _error,_error_desc;
end exception

set isolation to dirty read;
--set debug file to "sp_cob280b.trc"; 
--trace on;

--return 0,'Actualización Exitosa';
let _email_cliente	= '';
let _user_added 	= a_user_added;
let _email_cc		= '';

foreach
	select no_tarjeta,
		   no_documento
	  into _no_tarjeta,
	  	   _no_documento
	  from cobtatra
	 where no_documento = '0222-01003-03'

	call sp_sis21(_no_documento) returning _no_poliza;

	select cod_pagador
	  into _cod_cliente
	  from emipomae
	 where no_poliza = _no_poliza;

	let _email_cliente	= '';

	select e_mail
	  into _email_cliente
	  from cliclien
	 where cod_cliente = _cod_cliente;

	let _email_cliente = trim(_email_cliente);

	if _email_cliente is null or _email_cliente = '' then
		let _rechazo = 1;
	else
		select count(*)
		  into _rechazo
		  from parmailerr
		 where email = _email_cliente;
	end if

	if _rechazo = 0 then	
		let _email = trim(_email_cliente) || ';';

		foreach
			select email
			  into _email_cliente
			  from climail
			 where cod_cliente = _cod_cliente

			select count(*)
			  into _mail_err
			  from parmailerr
			 where email = _email_cliente;

			if _mail_err > 0 then
			   continue foreach;
			end if
			 
			if _email_cliente = _email then
				continue foreach;
			end if
			
			let _email = trim(_email) || trim(_email_cliente) || ';';
		end foreach

		let _cod_tipo = '00021';

		select count(*)
		  into _cnt_mail
		  from parmailsend
		 where email = _email
		   and cod_tipo = _cod_tipo
		   and enviado = 0;

		if _cnt_mail is null then
			let _cnt_mail = 0;
		end if

		if _cnt_mail > 0 then
			select count(*)
			  into _cnt_existe
			  from parmailcomp
			 where mail_secuencia in (select secuencia from parmailsend where email = _email and cod_tipo = _cod_tipo and enviado = 0);

			if _cnt_existe is null then
				let _cnt_existe = 0;
			end if
			
			if _cnt_existe > 0 then
				continue foreach;
			end if
		end if

		let _secuencia = sp_sis148(); 
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
			sender
			)
			values(
			_cod_tipo,
			_email,
			0,
			1,
			_secuencia,
			_html_body,
			''
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
			_no_tarjeta,
			1,
			today);
		end if
	end if
{
	let _email_cc = '';
	let _email_agt = '';
	let _cod_agente = '';

	foreach 
		select cod_agente
		  into _cod_agente
		  from emipoagt
		 where no_poliza = _no_poliza
		 order by porc_partic_agt desc
		exit foreach;
	end foreach

	foreach
		select email
		  into _email_agt
		  from agtmail
		 where cod_agente = _cod_agente
		   and tipo_correo = 'COB'

		let _email_cc = trim(_email_cc) || trim(_email_agt) || ';';
	end foreach

	select count(*)
	  into _flag_corr
	  from parmailsend
	 where cod_tipo = '00022'
	   and enviado	= 0
	   and email 	= _email_cc;
	
	if _flag_corr = 0 then
		if _email_cc is null or _email_cc = '' then
		else
			let _secuencia_corr	= sp_sis148(); 	
			let _cod_tipo		= '00022';
			let _html_body		= "<html><img src=cid:" ||  _secuencia_corr || ".jpg width=850 height=1100>";
			insert into parmailsend(
			cod_tipo,
			email,
			enviado,
			adjunto,
			secuencia,
			html_body,
			sender
			)
			values(
			_cod_tipo,
			_email_cc,
			0,
			1,
			_secuencia_corr,
			_html_body,
			''
			);
			let _email_agt = '';
			let _email_cc = '';

			let _secuencia_comp = sp_sis149();	

			insert into parmailcomp (
			secuencia,
			mail_secuencia,
			no_documento,
			asegurado,
			renglon,
			no_remesa
			)
			values(
			_secuencia_comp,
			_secuencia_corr,
			_no_documento,
			_no_tarjeta,
			2,
			_cod_agente
			);
		end if
	else
		select secuencia
		  into _secuencia_corr
		  from parmailsend
		 where cod_tipo = '00022'
		   and enviado	= 0
		   and email 	= _email_cc;
		   
		let _secuencia_comp = sp_sis149();	

		insert into parmailcomp (
			secuencia,
			mail_secuencia,
			no_documento,
			asegurado,
			renglon,
			no_remesa
			)
		values(
			_secuencia_comp,
			_secuencia_corr,
			_no_documento,
			_no_tarjeta,
			2,
			_cod_agente
			); 
	end if}
end foreach;
return 0,'';
end procedure
