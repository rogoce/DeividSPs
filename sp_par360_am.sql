-- Procedimiento correos de envio del carta de bienvenida - renovacion 	
-- Creado    : 27/04/2017 - Autor: Henry Giron
-- execute procedure sp_par360('0216-00182-02')

drop procedure sp_par360_am;
create procedure sp_par360_am(a_cod_agente char(5))
returning varchar(100),varchar(100),varchar(100),varchar(200);

define _email_cc		char(200);
define _cod_vendedor,_cod_vendedor2,_cod_cobrador char(3);
define _n_usuario_v1,_n_usuario_v2,_n_usuario_c1 char(8);
define _e_mail_v1,_e_mail_v2,_e_mail_c1		varchar(100);
define _cantidad        smallint;
define _email_agtmail,_email_cobros	char(50);

set isolation to dirty read; 
--set debug file to "sp_par360_am.trc";
--trace on; 

let _email_cc   = '';

select cod_vendedor,
       cod_vendedor2,
	   cod_cobrador,
	   email_cobros
  into _cod_vendedor,
       _cod_vendedor2,
	   _cod_cobrador,
	   _email_cobros
  from agtagent
 where cod_agente = a_cod_agente;

select usuario 
  into _n_usuario_v1
  from agtvende
 where cod_vendedor = _cod_vendedor;
 
 select usuario 
  into _n_usuario_v2
  from agtvende
 where cod_vendedor = _cod_vendedor2;
 
 select usuario 
  into _n_usuario_c1
  from cobcobra
 where cod_cobrador = _cod_cobrador;
 
 let _e_mail_v1 = null;
 select e_mail
   into _e_mail_v1
   from insuser
  where usuario = _n_usuario_v1;
  
  let _e_mail_v2 = null;
  select e_mail
   into _e_mail_v2
   from insuser
  where usuario = _n_usuario_v2;
  
  let _e_mail_c1 = null;
  select e_mail
   into _e_mail_c1
   from insuser
  where usuario = _n_usuario_c1;

let _email_cc = trim(_email_cobros) || ';';
  
foreach
	Select distinct email
	  into _email_agtmail
	  from agtmail
	 where cod_agente = a_cod_agente
	   and tipo_correo = 'COB'
	
	if trim(_email_agtmail) = '' or _email_agtmail is null then
		continue foreach;
	end if

	if trim(_email_cobros) = trim(_email_agtmail) then
		continue foreach;
	end if

	let _email_cc = trim(_email_cc) || trim(_email_agtmail) || ';';

end foreach
let _e_mail_v1 = trim(_e_mail_v1);
let _e_mail_v2 = trim(_e_mail_v2);
let _e_mail_c1 = "cobroscorporativo@asegurancon.com";	--trim(_e_mail_c1);
let _email_cc  = trim(_email_cc);

return _e_mail_v1,_e_mail_v2,_e_mail_c1,_email_cc;

end procedure



