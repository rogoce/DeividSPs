-- insercion de los correos para los estados de cuenta de manera masiva en parmailsend
-- creado por :    roman gordon	05/01/2011
-- sis v.2.0 - deivid, s.a.

drop procedure sp_informe_invalidos;

create procedure "informix".sp_informe_invalidos()
returning	char(10), --_nombre,
			char(50), --_cod_cliente
            char(30), --_cedula,				
			char(10), --_celular,
			char(10), --_telefono1
			char(10), --_telefono2
			char(10), --_telefono3
			char(50); --_e_mail

define _cod_cliente		char(10);
define _telefono1		char(10);
define _telefono2		char(10);
define _telefono3		char(10);
define _celular			char(10);
define _cedula          char(30);
define _email			char(50);
define _e_mail			char(50);
define _nombre			char(50);


set isolation to dirty read;
--set debug file to "sp_cob260.trc";
--trace on;

foreach	
	select cod_cliente,
		   email
	  into _cod_cliente,
		   _email
	  from parmailerr
	
	let _telefono1		= '';
	let _telefono2		= '';
	let _telefono3		= '';
	let _celular		= '';
	let _cedula     	= '';
	let _e_mail			= '';
	let _nombre			= '';

	select nombre,
		   cedula,
		   celular,
		   telefono1,
		   telefono2,
		   telefono3,
		   e_mail
	  into _nombre,
		   _cedula,
		   _celular,
		   _telefono1,
		   _telefono2,
		   _telefono3,
		   _e_mail
	  from cliclien
	 where cod_cliente = _cod_cliente;

	let _email = trim(_email);
	let _e_mail = trim (_e_mail);

	if _email <> _e_mail or _e_mail = 'no tiene' or _e_mail = 'NO TIENE' or _e_mail = '#EMPTY' or _e_mail is null then
		continue foreach;
	end if

	return _cod_cliente,
		   _nombre,		   
		   _cedula,
		   _celular,
		   _telefono1,
		   _telefono2,
		   _telefono3,
		   _e_mail with resume;
	 
end foreach
end procedure

