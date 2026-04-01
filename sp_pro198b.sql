-- Ingreso a parmailsend para ser enviado por correo
-- NO APROBACION DEL ASEGURADO
-- Armando Moreno 16/12/2010


drop procedure sp_pro198b;

create procedure sp_pro198b(a_no_solicitud char(10))
RETURNING SMALLINT, CHAR(30);

DEFINE r_error        	SMALLINT;
DEFINE r_error_isam   	SMALLINT;
DEFINE r_descripcion  	CHAR(30);
Define _html_body		char(512);
define _secuencia       integer;
define _secuencia2      integer;
define _email_parcocue	varchar(100);
define _email_unido,ls_e varchar(200);
define _user_eval       char(8);
define ls_e_mail        varchar(30);
define _cod_sucursal    char(3);
define ls_e_seg         varchar(30);



BEGIN

ON EXCEPTION SET r_error, r_error_isam, r_descripcion
 	RETURN r_error, r_descripcion;
END EXCEPTION

set isolation to dirty read;

LET r_error       = 0;
LET r_descripcion = 'Actualizacion Exitosa ...';


Select max(secuencia)
  into _secuencia
  from parmailsend;

if _secuencia is null then
	let _secuencia = 0;
end if

let _secuencia = _secuencia + 1;

let _html_body = "<html><img src=cid:" ||  _secuencia || ".jpg width=850 height=1100>";

let _email_unido = "";
let ls_e = "";

foreach

	select email
	  into _email_parcocue
	  from parcocue
	 where cod_correo = '051'
	   and activo     = 1

	let _email_unido = trim(_email_unido) || trim(_email_parcocue) || ";";

end foreach

select usuario_eval,
       cod_sucursal
  into _user_eval,
       _cod_sucursal
  from emievalu
 where no_evaluacion = a_no_solicitud;

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
	   let _email_unido = trim(_email_unido) || trim(ls_e);
   end if

end if

select usuario_eval
  into _user_eval
  from emievalu
 where no_evaluacion = a_no_solicitud;

select e_mail into ls_e_mail from insuser where usuario = _user_eval;
--let ls_e_mail = "adecentella@asegurancon.com;" || ls_e_mail;
insert into parmailsend(
cod_tipo,
email,
enviado,
adjunto,
html_body,
secuencia,
sender)
values(
'00006',	--NO APROBACION DE UNO DE LOS ASPIRANTES
_email_unido,
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