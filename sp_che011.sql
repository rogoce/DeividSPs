-- Procedimiento que trae el correo de un corredor

-- Creado    : 15/01/2015 - Autor: Federico Coronado

drop procedure sp_che011;

create procedure sp_che011(a_cod_corredor char(5))
returning	varchar(200);

define _error			integer;
define _error_isam		integer;
define _cnt   			smallint;
define _email_cc		char(200);
define _error_desc		char(100);
define _email_to		char(200);
define _email_send		char(200);

set isolation to dirty read;
--set debug file to "sp_che011.trc"; 
--trace on;

let _email_cc = '';
let _email_to = '';

select count(*)
  into _cnt
  from agtmail
 where cod_agente = a_cod_corredor;
 if _cnt > 0 then
	 foreach
		select email
		  into _email_to
		  from agtmail
		 where cod_agente = a_cod_corredor
		   and tipo_correo = 'COM'
		 let _email_cc = trim(_email_to)||';'||trim(_email_cc);
	end foreach
else 
	let _email_cc = ''; 
end if
return _email_cc;
end procedure