-- Procedimiento que Genera el html body y la secuencia del envio de correos masivos 	

-- Creado    : 15/11/2010 - Autor: Roman Gordon

drop procedure sp_cob280;

create procedure "informix".sp_cob280()
returning	integer;

define _secuencia		integer;
define _secuencia_comp	integer;
define _error			integer;
define _error_isam		integer;
define _secuencia_orig	integer;
define _adjunto			smallint;
define _existe			smallint;
define _tipo_tran		smallint;
define _html_body		char(512);
define _error_desc		char(100);
define _email_cliente	char(50);
define _email_send		char(200);
define _cod_agente		char(5);
define _cod_tipo		char(5);
define _email_cobros	char(50);
define _email_agtmail	char(50);
define _no_documento	char(20);
define _no_tarjeta		char(20);
define _cod_cliente		char(10);
define _no_poliza		char(10);
define _mail_err        integer;

on exception set _error, _error_isam, _error_desc
	--rollback work;
	return 0;
end exception

set isolation to dirty read;
--set debug file to "sp_cob280.trc"; 
--trace on;

select *
  from parmailsend 
 where enviado = 0
   and (cod_tipo = '00021'or cod_tipo = '00023')
into temp tmp_parmailsend;

foreach
	select secuencia,
		   adjunto
	  into _secuencia_orig,
		   _adjunto
	  from tmp_parmailsend 

	select no_documento,
		   asegurado,
		   renglon
	  into _no_documento,
		   _no_tarjeta,
		   _tipo_tran
	  from parmailcomp 
	 where mail_secuencia = _secuencia_orig;

	call sp_sis21(_no_documento) returning _no_poliza;

	foreach
		select cod_agente
		  into _cod_agente
		  from emipoagt
		 where no_poliza = _no_poliza
		 order by porc_partic_agt desc
		exit foreach;
	end foreach

	Select email_cobros
	  into _email_cobros
	  from agtagent
	 where cod_agente = _cod_agente;
		
	select count(*)
	  into _mail_err
	  from parmailerr
	 where email = _email_cobros;
	 
	if _mail_err > 0 then
		continue foreach;	
	end if
	
	if _email_cobros is null or _email_cobros = '' then
		continue foreach;
	else
		let _email_send = trim(_email_cobros) || ';';
	end if
	
	foreach
		Select email
		  into _email_agtmail
		  from agtmail
		 where cod_agente  = _cod_agente
		   and tipo_correo = 'COB'

			select count(*)
			  into _mail_err
			  from parmailerr
			 where email = _email_agtmail;
			 
		   
			if trim(_email_agtmail) = '' or _email_agtmail is null then
				continue foreach;
			end if
			if _mail_err > 0 then
				continue foreach;	
			end if
		 	if _email_agtmail = _email_cobros then
		 		continue foreach;
		 	else
				let _email_send = trim(_email_send) || trim(_email_agtmail) || ';';
			end if
	end foreach 

	select count(*)
	  into _existe
	  from parmailsend
	 where email = _email_send
	   and enviado = 0;

	if _existe = 0 then
		let _secuencia = sp_sis148(); 	
		let _cod_tipo = '00022';
		let _html_body = "<html><img src=cid:" ||  _secuencia || ".jpg width=850 height=1100>";
				
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
		_email_send,
		0,
		1,
		_secuencia,
		_html_body,
		''
		);

		let _secuencia_comp = sp_sis149();

		insert into parmailcomp (
		secuencia,
		asegurado,
		renglon,
		mail_secuencia,
		no_remesa,
		no_documento
		)
		values(
		_secuencia_comp,
		_no_tarjeta,
		_tipo_tran,
		_secuencia,
		_secuencia_orig,
		_no_documento		
		);
	else
		select adjunto,
			   secuencia
		  into _adjunto,
			   _secuencia			  
		  from parmailsend
		 where email = _email_send
	   	   and enviado = 0;

	   {	update parmailsend
		   set adjunto 		= _adjunto + 1
		 where secuencia	= _secuencia;}

		let _secuencia_comp = sp_sis149();

		insert into parmailcomp (
		secuencia,
		asegurado,
		renglon,
		mail_secuencia,
		no_remesa,
		no_documento
		)
		values(
		_secuencia_comp,
		_no_tarjeta,
		_tipo_tran,
		_secuencia,
		_secuencia_orig,
		_no_documento		
		);
	end if
end foreach

drop table tmp_parmailsend;
return _secuencia;


end procedure
