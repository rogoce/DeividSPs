-- Ingreso a parmailsend para ser enviado por correo

-- Armando Moreno 08/11/2010


drop procedure sp_pro198;

create procedure sp_pro198(a_no_solicitud char(10))
RETURNING SMALLINT, CHAR(30);

DEFINE r_error        	SMALLINT;
DEFINE r_error_isam   	SMALLINT;
DEFINE r_descripcion  	CHAR(30);
Define _html_body		char(512);
define _secuencia       integer;
define _secuencia2      integer;
define ls_e_mail        varchar(30);
define _user_tecnico    char(8);
define _cnt             smallint;


BEGIN

ON EXCEPTION SET r_error, r_error_isam, r_descripcion
 	RETURN r_error, r_descripcion;
END EXCEPTION

set isolation to dirty read;

LET r_error       = 0;
LET r_descripcion = 'Actualizacion Exitosa ...';
LET	_cnt          = 0;

select count(*)
  into _cnt
  from emievalu
 where no_evaluacion = a_no_solicitud
   and escaneado     = 1;

if _cnt > 0 then	--ya se envio el correo
	RETURN 0, "";
end if

--SET DEBUG FILE TO "sp_pro198.trc"; 
--trace on;

Select max(secuencia)
  into _secuencia
  from parmailsend;

if _secuencia is null then
	let _secuencia = 0;
end if

let _secuencia = _secuencia + 1;

let _html_body = "<html><img src=cid:" ||  _secuencia || ".jpg width=850 height=1100>";

select user_escan
  into _user_tecnico
  from emievalu
 where no_evaluacion = a_no_solicitud;

select e_mail
  into ls_e_mail
  from insuser 
 where usuario = _user_tecnico;

if ls_e_mail is null or ls_e_mail = "" then
	let ls_e_mail = "maysanchez@asegurancon.com";
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
'00002',--OIRTA
'info@apadea.org',
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
a_no_solicitud,
0,
_secuencia);


RETURN r_error, r_descripcion  WITH RESUME;

END
end procedure