-- Procedimiento que trae todos los correos de un corredor para el envio de informacion de cobros 	

-- Creado    : 15/11/2010 - Autor: Roman Gordon

drop procedure sp_cob292;

create procedure "informix".sp_cob292(a_no_documento char(20))
returning	char(5),
			char(200),
			char(200);

define _secuencia		integer;
define _secuencia_comp	integer;
define _error			integer;
define _error_isam		integer;
define _secuencia_orig	integer;
define _adjunto			smallint;
define _existe			smallint;
define _tipo_tran		smallint;
define _email_cc		char(200);
define _error_desc		char(100);
define _email_to		char(200);
define _email_send		char(200);
define _email_cli		char(50);
define _cod_agente		char(5);
define _cod_tipo		char(5);
define _email_cobros	char(50);
define _email_agtmail	char(50);
define _email_cliclien	char(20);
define _no_tarjeta		char(20);
define _cod_cliente		char(10);
define _no_poliza		char(10);
define _cod_pagador		char(10);

on exception set _error, _error_isam, _error_desc
	--rollback work;
	return _error,_error_isam,_error_desc;
end exception

set isolation to dirty read;
--set debug file to "sp_cob292.trc"; 
--trace on;

let _email_cc = '';
let _email_to = '';

call sp_sis21(a_no_documento) returning _no_poliza;

select cod_pagador
  into _cod_pagador
  from emipomae
 where no_poliza = _no_poliza;

Select e_mail
  into _email_cli
  from cliclien
 where cod_cliente = _cod_pagador;
	
if _email_cli is null or _email_cli = '' then
else
	let _email_to 	=	trim(_email_cli) || ';';
end if

foreach
	Select email
	  into _email_cli
	  from climail
	 where cod_cliente = _cod_pagador
	
	if trim(_email_cli) = '' or _email_cli is null then
		continue foreach;
	end if
 	if _email_cli = _email_to then
 		continue foreach;
 	else
		let _email_to = trim(_email_to) || trim(_email_cli) || ';';
	end if
end foreach 


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
	
if _email_cobros is null or _email_cobros = '' then
else
	let _email_cc 	=	trim(_email_cobros) || ';';
end if

foreach
	Select email
	  into _email_agtmail
	  from agtmail
	 where cod_agente = _cod_agente
	   and tipo_correo = 'COB'
	
	if trim(_email_agtmail) = '' or _email_agtmail is null then
		continue foreach;
	end if
 	if _email_agtmail = _email_cobros then
 		continue foreach;
 	else
		let _email_cc = trim(_email_cc) || trim(_email_agtmail) || ';';
	end if
end foreach 

return _cod_agente,_email_to,_email_cc;
end procedure



