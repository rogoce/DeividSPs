-- Envios masivos de correos por prioridad de envio
-- Creado por :    Roman Gordon		 08/04/2011
-- SIS v.2.0 - DEIVID, S.A.

drop procedure sp_parmailsend;

create procedure "informix".sp_parmailsend() 
returning	char(20),  --_email,
			integer  --_enviado, 
		   		  																  
																				  
define _asunto			char(100);												  
define _email			char(200);												  
define _email_agt		char(50);
define _email_ant		char(50);
define _email_cliente	char(50);
define _email_cc		char(200);
define _sender_send		char(100);
define _sender_tipo		char(50);
define _enviado			char(20);
define _html_body		char(512);
define _cod_tipo		char(5);
define _secuencia		integer;
define _mail_secuencia	integer;
define _no_lote				char(5);
define _renglon				smallint;
define _tipo_transaccion char(1);
define _no_documento		char(20);
define _cod_agente			char(5);
define _no_poliza			char(10);
define _cod_pagador			char(10);




set isolation to dirty read;

let	_email			= '';
let	_sender_tipo	= '';
let	_html_body		= '';
let _sender_send	= '';
let	_enviado		= 0;
let	_secuencia		= 0;
let _email_cc		= '';
let _email_agt		= '';
let _email_cliente	= '';



foreach
	select secuencia,
		   email
	  into _mail_secuencia,
		   _email_ant
	  from parmailsend
	 where enviado = 0
	   and cod_tipo = '00021'

	foreach
		Select secuencia
		  into _secuencia
	  	  from parmailcomp
		 where mail_secuencia = _mail_secuencia


		select no_remesa,
			   renglon,
			   asegurado
		  into _no_lote,
		  	   _renglon,
			   _tipo_transaccion
		  from parmailcomp
		 where secuencia = _secuencia;

		if _tipo_transaccion = '1' then					-----------------------Rechazo TCR
			select no_documento
			  into _no_documento														   		  	  										   
			  from cobtatra												  
			 where no_lote = _no_lote									  
			   and renglon = _renglon;

			call sp_sis21(_no_documento) returning _no_poliza;
			let _email_cc		= '';
			let _email_agt		= '';
			let _email_cliente	= '';
			let _cod_agente		= '';
			let _email			= '';

			foreach 
				select cod_agente
				  into _cod_agente
				  from emipoagt
				 where no_poliza = _no_poliza
				 order by porc_partic_agt
				exit foreach;
			end foreach

			foreach
				select email
				  into _email_agt
				  from agtmail
				 where cod_agente = _cod_agente
				   and tipo_correo = 'COB'

				let _email_cc = trim(_email_cc) || trim(_email_agt) || ';';
			end foreach;

			select cod_pagador 
			  into _cod_pagador
			  from emipomae
			 where no_poliza = _no_poliza;

			foreach
				select email
				  into _email_cliente
				  from climail
				 where cod_cliente = _cod_pagador

				if _email_ant = _email_cliente then
					continue foreach;
				end if

				let _email = trim(_email) || trim(_email_cliente) || ';';
			end foreach
			let _email = trim(_email_ant) || trim(_email_cliente) || ';';
			
			update parmailsend
			   set email = _email,
			   	   sender = _email_cc
			 where secuencia = _mail_secuencia;
			  				   
		end if
	end foreach
end foreach

return '',0;
end procedure
