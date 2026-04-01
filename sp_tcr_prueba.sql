-- Envios masivos de correos por prioridad de envio
-- Creado por :    Roman Gordon		 08/04/2011
-- SIS v.2.0 - DEIVID, S.A.

drop procedure sp_tcr_prueba;

create procedure "informix".sp_tcr_prueba() 
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

--SET DEBUG FILE TO "sp_cob275.trc";
--TRACE ON;


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
	select no_lote,
		   renglon
	  into _no_lote,
	  	   _renglon
	  from cobtatra
	 where procesar = 0
	 
	call sp_cob280(_no_lote,_renglon,'MARILUZ','1') returning _mail_secuencia;
end foreach

return '',0;
end procedure
