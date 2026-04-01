

DROP PROCEDURE sp_sis266;
CREATE PROCEDURE sp_sis266(a_cod_cliente CHAR(10))
RETURNING CHAR(50);

DEFINE _email		CHAR(50);

SET ISOLATION TO DIRTY READ;

let _email = null;

select e_mail
  into _email
  from cliclien
 where cod_cliente = a_cod_cliente
   and e_mail is not null
   and e_mail not like '%/%'
   and e_mail <> ''
   and e_mail <> 'actualiza@asegurancon.com'
   and e_mail <> 'actualizaciones@asegurancon.com'
   and e_mail like '%@%'
   and e_mail not like '@%'
   and e_mail not like '% %'
   and e_mail not like '%,%';

RETURN _email;

END PROCEDURE;