-- Ingreso a parmailsend para ser enviado por correo
-- CARTA A CLIENTE DE DECLINACION DEL SEGURO.
-- Armando Moreno 23/12/2010


drop procedure sp_pro198d;

create procedure sp_pro198d(a_no_solicitud char(10))
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
define ls_e             varchar(200);


BEGIN

ON EXCEPTION SET r_error, r_error_isam, r_descripcion
 	RETURN r_error, r_descripcion;
END EXCEPTION

set isolation to dirty read;

LET r_error       = 0;
LET r_descripcion = 'Actualizacion Exitosa ...';
let _cod_agente   = null;

Select max(secuencia)
  into _secuencia
  from parmailsend;

if _secuencia is null then
	let _secuencia = 0;
end if

let _secuencia = _secuencia + 1;

let _html_body = "<html><img src=cid:" || _secuencia || ".jpg width=850 height=1100>";

let _e_mail_corr = "";
let ls_e         = "";

select user_added,
	   cod_asegurado,
	   cod_agente,
	   usuario_eval,
	   cod_sucursal
  into _user_added,
  	   _cod_asegurado,
	   _cod_agente,
	   _usuario_eval,
	   _cod_sucursal
  from emievalu
 where no_evaluacion = a_no_solicitud;

select e_mail into ls_e_mail   from insuser where usuario = _user_added;
select e_mail into ls_e_mail_e from insuser where usuario = _usuario_eval;
select e_mail into ls_mail_ase from cliclien where cod_cliente = _cod_asegurado;

if trim(ls_e_mail_e) = "adecentella@asegurancon.com" then
	let ls_e_mail = trim(ls_e_mail) || ";";
else
	let ls_e_mail = trim(ls_e_mail) || ";" || trim(ls_e_mail_e) || ";";	--cc a la evaluadora
end if	

if _cod_agente is not null then

	select e_mail
	  into _e_mail_corr
	  from agtagent
	 where cod_agente = _cod_agente;

end if

if ls_mail_ase is null then	   --Le pongo el correo del ejecutivo para q le haga llegar el email
	let ls_mail_ase = ls_e_mail;
end if

if _e_mail_corr is null or _e_mail_corr = "" then
else
	let ls_e_mail = trim(ls_e_mail) || trim(_e_mail_corr);	--cc al corredor
end if

let ls_e_mail = "adecentella@asegurancon.com;" || ls_e_mail;

if _cod_sucursal <> "001" and _cod_sucursal is not null then

   foreach

		select e_mail
		  into ls_e_seg
		  from insuser
		 where codigo_agencia    = _cod_sucursal
		   and status            = "A"
		   and correo_evaluacion = 1


		let ls_e = trim(ls_e) || trim(ls_e_seg) || ";";

   end foreach

   if ls_e <> "" then
	   let ls_mail_ase = trim(ls_mail_ase) || ";" || trim(ls_e);
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
'00008',	--CARTA A CLIENTE DE DECLINACION DEL SEGURO
ls_mail_ase,
0,
1,
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