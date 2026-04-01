-- Ingreso a parmailsend para ser enviado por correo
-- NOTIFICACION A CLIENTE, CORREDOR Y EJECUTIVO DE COBRO DE LA APLICACION DEL DESCTO. POR PAGO ELECTRONICO

-- Armando Moreno 12/01/2012


--drop procedure sp_cob300;

create procedure sp_cob300(a_no_poliza char(10))
RETURNING SMALLINT, CHAR(30);

DEFINE r_error        	SMALLINT;
DEFINE r_error_isam   	SMALLINT;
DEFINE r_descripcion  	CHAR(30);
Define _html_body		char(512);
define _secuencia       integer;
define _secuencia2      integer;
define _email_parcocue	varchar(100);
define _user_added      char(8);
define ls_e_mail        varchar(200);
define ls_mail_ase      varchar(200);
define _cod_asegurado   char(10);
define _cod_agente      char(5);
define _e_mail_corr     varchar(50);
define _usuario_eval    char(8);
define ls_e_mail_e      char(30);
define _cod_sucursal    char(3);
define ls_e_seg         varchar(30);
define _email_ejec      varchar(200);
define _mail_err        integer;


BEGIN

ON EXCEPTION SET r_error, r_error_isam, r_descripcion
 	RETURN r_error, r_descripcion;
END EXCEPTION

set isolation to dirty read;

LET r_error       = 0;
LET r_descripcion = 'Actualizacion Exitosa ...';
let _cod_agente   = null;
let ls_e_mail     = "";

select cod_pagador
  into _cod_asegurado
  from emipomae
 where no_poliza = a_no_poliza;

select e_mail into ls_mail_ase from cliclien where cod_cliente = _cod_asegurado;

select count(*)
  into _mail_err
  from parmailerr
 where email = ls_mail_ase;

if ls_mail_ase is null or ls_mail_ase = "" or _mail_err > 0 then	--Cliente no tiene email, no debe entrar a proceso de envio
	return 0,"";
end if

Select max(secuencia)
  into _secuencia
  from parmailsend;

if _secuencia is null then
	let _secuencia = 0;
end if

let _secuencia = _secuencia + 1;

let _html_body = "<html><img src=cid:" || _secuencia || ".jpg width=850 height=1100>";

let _e_mail_corr = "";

foreach
	select cod_agente
	  into _cod_agente
	  from emipoagt
	 where no_poliza = a_no_poliza

	exit foreach;

end foreach

if _cod_agente is not null then

	select e_mail
	  into _e_mail_corr
	  from agtagent
	 where cod_agente = _cod_agente;

end if

if _e_mail_corr is null or _e_mail_corr = "" then
else
	let ls_e_mail = trim(ls_e_mail) || trim(_e_mail_corr);	--cc al corredor
end if

let _email_ejec = sp_cob116a(a_no_poliza);
if _email_ejec is null or _email_ejec = "" then
else
    if ls_e_mail = "" then
		let ls_e_mail = _email_ejec;
	else
		let ls_e_mail = ls_e_mail || ";" || _email_ejec;
	end if
end if

insert into parmailsend(
cod_tipo,
email,
enviado,
adjunto,
html_body,
secuencia,
sender)
values(
'00025',
ls_mail_ase,
0,
0,
_html_body,
_secuencia,
ls_e_mail);

Select max(secuencia)
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
values(
_secuencia2,
a_no_poliza,
0,
_secuencia);

				  
RETURN r_error, r_descripcion;

END
end procedure