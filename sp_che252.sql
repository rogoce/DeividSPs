-- Ingreso a parmailsend para ser enviado por correo
-- Amado Perez 17/08/2023

drop procedure sp_che252;

create procedure sp_che252(a_no_cheque integer)
returning smallint, char(30);

define ls_e_mail        char(384);
define _sender          varchar(100);
define _sender_c        varchar(100);
define _email          	varchar(200);
define _html_body		char(512);
define r_descripcion  	char(30);
define _cod_cliente     char(10);
define _transaccion     char(10);
define _no_requis       char(10);
define _user_tecnico    char(8);
define _cod_chequera	char(3);
define _cod_tipopago    char(3);
define _ramo            char(2);
define r_error_isam   	integer;
define _secuencia2      integer;
define _secuencia       integer;
define _cantidad        integer;
define _contador        integer;
define _adjunto         integer;
define r_error        	integer;
define _cnt             integer;

define _numrecla        char(20);
define _no_poliza       char(10);
define _cod_ramo        char(3);
define _cod_agente      char(10);
define _cod_ajustador   char(8);

define _es_auto         smallint;

define _cod_banco       char(3);


begin

on exception set r_error, r_error_isam, r_descripcion
 	return r_error, r_descripcion;
end exception

set isolation to dirty read;

let r_error       = 0;
let r_descripcion = 'Actualizacion Exitosa ...';
let	_cnt          = 0;
let _es_auto      = 0;

--if a_no_cheque = 2840 then
--	set debug file to "sp_che252.trc"; 
--	trace on;
--end if

let _sender = "";
let _sender_c = "";
{
foreach
	select email
	  into _sender_c
	  from parcocue
	 where cod_correo = '062' --> ach pago de reclamos (envio masivo cc)
	   and activo = 1

	if trim(_sender_c) <> "" and _sender_c is not null then
		let _sender = _sender || trim(_sender_c) || ";"; 
	end if
end foreach
}
foreach
	select no_requis,
		   cod_cliente,
           cod_banco,
           cod_chequera		   
	  into _no_requis,
		   _cod_cliente,
           _cod_banco,
           _cod_chequera		   
	  from chqchmae
	 where no_cheque = a_no_cheque
	   and tipo_requis = 'A'

	let _adjunto = 0;

	let ls_e_mail = "";
	
	select e_mail
	  into ls_e_mail
	  from cliclien 
	 where cod_cliente = _cod_cliente;

	if ls_e_mail is null then
		let ls_e_mail = "";
	end if 

	select count(*)
	  into _cantidad 
	  from climail 
	 where cod_cliente = _cod_cliente;

	if _cantidad > 0 then
		foreach
			select email 
			  into _email 
			  from climail 
			 where cod_cliente = _cod_cliente

			if _email is null then
				let _email = '';
			end if

			if _email = '' then
				continue foreach;
			end if

			let ls_e_mail = trim(ls_e_mail) || ";" || trim(_email);
		end foreach
	end if
	
	let _email = '';
	
	if trim(_email) <> "" then
		let ls_e_mail = trim(ls_e_mail) || ";" || trim(_email);
	end if

	if ls_e_mail = '' then
		continue foreach;
	end if	
	
	let ls_e_mail = trim(ls_e_mail) || ";contabilidad@asegurancon.com;";
	
	let _secuencia = sp_par336('00048', ls_e_mail, 0);-- Amado - se cambia para que solo envie la primera imagen - 18/06/2013
		
	update parmailsend 
	   set sender   	= _sender
	 where secuencia	= _secuencia;

	select max(secuencia)
	  into _secuencia2
	  from parmailcomp;

	if _secuencia2 is null then
		let _secuencia2 = 0;
	end if

	let _secuencia2 = _secuencia2 + 1;

	insert into parmailcomp(
			secuencia,
			no_remesa,
			renglon,
			mail_secuencia)
	values(	_secuencia2,
			_no_requis,
			0,
			_secuencia);
END FOREACH

return r_error, r_descripcion  with resume;

end
end procedure;