-- Procedimiento que trae el correo de un corredor

-- Creado    : 15/01/2015 - Autor: Federico Coronado

drop procedure sp_atc3;

create procedure "informix".sp_atc3(a_nombre_corredor char(100))
returning	varchar(100),
			char(200),
			char(200);

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
define _asunto          varchar(100);

on exception set _error, _error_isam, _error_desc
	--rollback work;
	return _error,_error_isam,_error_desc;
end exception

set isolation to dirty read;
--set debug file to "sp_atc3.trc"; 
--trace on;

let _email_cc = '';
let _email_to = '';
let _asunto   = "Carta Declarativa";

select e_mail
  into _email_to
  from agtagent
 where nombre = a_nombre_corredor;

return _asunto,_email_to,_email_cc;
end procedure
