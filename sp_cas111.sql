-- Envios masivos de correos por prioridad de envio
-- Creado por :    Roman Gordon		 08/04/2011
-- SIS v.2.0 - DEIVID, S.A.

drop procedure sp_cas111;

create procedure "informix".sp_cas111(a_cod_campana char(10)) 
returning	char(100), --_asunto,
			char(512), --_html_body	
			char(250); --_email_supervisor		  	

define _html_body			char(512);
define _email_supervisor	char(250);
define _asunto				char(100);
define _cod_supervisor		char(3);
define _email_sup			char(50);
define _nom_campana			char(50);
define _user_sup			char(10);
define _cnt_supervisor		smallint;

set isolation to dirty read;
-- set debug file to "sp_cas111.trc";
-- trace on;

let _email_supervisor = '';

foreach
	select distinct cod_supervisor
	  into _cod_supervisor
	  from cobcobra
	 where cod_campana = a_cod_campana

	select usuario
	  into _user_sup
	  from cobcobra
	 where cod_cobrador = _cod_supervisor;

	select count(*)
	  into _cnt_supervisor
	  from insuser
	 where usuario = _user_sup;

	if _cnt_supervisor = 0 then
		continue foreach;
	end if
	
	select e_mail
	  into _email_sup
	  from insuser
	 where usuario = _user_sup;

	let _email_supervisor = trim(_email_supervisor) || trim(_email_sup) || ';'; 
	 
end foreach

if _email_supervisor = '' then
	let _email_supervisor = 'cobros@asegurancon.com';
end if  

select nombre
  into _nom_campana
  from cascampana
 where cod_campana = a_cod_campana;

let _html_body	= 'La campaña de nombre: ' || trim(_nom_campana) || ',ha quedado sin registros pendientes.';
let _asunto		= 'Campaña Sin Registro';

return _asunto,
	   _html_body,	
	   _email_supervisor;

end procedure

