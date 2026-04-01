-- Ingreso a parmailsend para ser enviado por correo
-- carta de pago a tarjeta de credito
-- ANGEL TELLO 27/06/2014


drop procedure sp_cob867;

create procedure sp_cob867(a_periodo char(7))
returning	smallint,
			char(30);

define _email_unido		varchar(250);
define ls_e				varchar(250);
define _email_parcocue	varchar(100);
define ls_e_seg			varchar(30);
define _e_mail		    char(384);
define _html_body		char(512);
define r_descripcion	char(30);
define _user_eval		char(8);
define _cod_sucursal	char(3);
define _cod_contratante char(10);
define _no_documento    char(20);
define _secuencia2		integer;
define _secuencia		integer;
define r_error_isam		smallint;
define r_error			smallint;
define v_tipo_envio		char(10);
define _email_climail	char(50);
define _len_email		smallint;
define _len_climail		smallint;
define _mail_err		integer;
define _cod_ramo		char(3);
define _fronting	    smallint;
define _corredor        char(5);
define _band    	    integer;
define _carta_bienv		smallint;
define _cod_cliente     char(10);
define _periodo1        char(7);
define _periodo2        char(7);
define _mes				integer;
define _no_tarjeta		char(100);	
define _no_poliza 		char(25);
define _periodo_ex		char(7);
define _count			integer;



begin

on exception set r_error, r_error_isam, r_descripcion
 	return r_error, r_descripcion;
end exception

--SET DEBUG FILE TO "sp_cob867.trc";
--trace on;

set isolation to dirty read;

LET r_error       = 0;
LET r_descripcion = 'Actualizacion Exitosa ...';
LET _band = 0;
 -- Periodo 1
 LET _periodo1 = a_periodo[6,7] || '-'|| a_periodo[1,4];
 
 -- Periodo 2
 LET _mes = a_periodo[6];
 
	IF _mes = 0 THEN 
		LET _mes = a_periodo[7] + 1;
		LET _periodo2 = '0'|| _mes || '-'|| a_periodo[1,4];
    ELSE 
		LET _mes = a_periodo[6,7] + 1;
		
		IF _mes < 13 THEN
			LET _periodo2 = _mes || '-'|| a_periodo[1,4];
		ELSE
			LET _periodo2 = '01' || '-'|| a_periodo[1,4];
		END IF
	END IF
	
	Select max(secuencia)
	  into _secuencia
	  from parmailsend;

if _secuencia is null then
	let _secuencia = 0;
end if


FOREACH
		 SELECT no_tarjeta
		   INTO _no_tarjeta
		   FROM cobtahab
		  WHERE fecha_exp = _periodo1
	
	FOREACH
		 SELECT no_documento
		   INTO _no_documento
		   FROM cobtacre
		  WHERE no_tarjeta  = _no_tarjeta

	  exit foreach;
	END FOREACH

	LET _no_poliza = sp_sis21(_no_documento);
		
	SELECT cod_contratante
	   INTO	_cod_cliente
	   FROM	emipomae
	  WHERE	no_poliza = _no_poliza
	    AND actualizado  = 1;

  select e_mail
    into _e_mail
    from cliclien
   where cod_cliente = _cod_cliente;
   
   foreach
		select email
		  into _email_climail
		  from climail
		 where cod_cliente = _cod_cliente
			let _len_email = length(_e_mail); 
			let _len_climail = length(_email_climail);
			let _e_mail = trim(_e_mail) || ';' || trim(_email_climail);
   end foreach

	select count(*)
	  into _mail_err
	  from parmailerr
	 where email = _e_mail;

	if _e_mail is null or _e_mail = '' or _mail_err > 0 then
		continue foreach;
	end if
   
   
   --SECUENCIA DE EMAIL
		let _secuencia = _secuencia + 1;
		let _html_body = "<html><img src=cid:" ||  _secuencia || ".jpg width=850 height=1100>";

	INSERT INTO parmailsend(cod_tipo, 
							email, 
							enviado, 
							adjunto, 
							secuencia, 
							html_body, 
							sender) 
					VALUES('00032', 
							_e_mail, 
							0, 
							1,
							_secuencia,
							_html_body, 
							'');
	
	Select max(secuencia)
	  into _secuencia2
	  from parmailcomp;

	if _secuencia2 is null then
		let _secuencia2 = 0;
	end if

		let _secuencia2 = _secuencia2 + 1;
		
	INSERT INTO parmailcomp(no_remesa,
							renglon,
							no_documento, 
							secuencia, 
							mail_secuencia) 
					VALUES( 0,
							0,	
							_no_tarjeta,
							_secuencia2, 
							_secuencia);
							
	
END FOREACH		  

--periodo 2
FOREACH
		 SELECT no_tarjeta
		   INTO _no_tarjeta
		   FROM cobtahab
		  WHERE fecha_exp = _periodo2
	
	FOREACH
	 SELECT no_documento
	   INTO _no_documento
	   FROM cobtacre
	  WHERE no_tarjeta  = _no_tarjeta

	  exit foreach;
	END FOREACH

	LET _no_poliza = sp_sis21(_no_documento);
		
	SELECT cod_contratante
	   INTO	_cod_cliente
	   FROM	emipomae
	  WHERE	no_poliza = _no_poliza
	    AND actualizado  = 1;

  select e_mail
    into _e_mail
    from cliclien
   where cod_cliente = _cod_cliente;
   
   foreach
	select email
	  into _email_climail
	  from climail
	 where cod_cliente = _cod_cliente
		let _len_email = length(_e_mail); 
		let _len_climail = length(_email_climail);
		let _e_mail = trim(_e_mail) || ';' || trim(_email_climail);
   end foreach



	select count(*)
	  into _mail_err
	  from parmailerr
	 where email = _e_mail;

	if _e_mail is null or _e_mail = '' or _mail_err > 0 then
		continue foreach;
	end if
   
   
   --SECUENCIA DE EMAIL
		let _secuencia = _secuencia + 1;
		let _html_body = "<html><img src=cid:" ||  _secuencia || ".jpg width=850 height=1100>";

	INSERT INTO parmailsend(cod_tipo, 
							email, 
							enviado, 
							adjunto, 
							secuencia, 
							html_body, 
							sender) 
					VALUES('00032', 
							_e_mail, 
							0, 
							1,
							_secuencia,
							_html_body, 
							'');
	
	Select max(secuencia)
	  into _secuencia2
	  from parmailcomp;

	if _secuencia2 is null then
		let _secuencia2 = 0;
	end if

		let _secuencia2 = _secuencia2 + 1;
		
	INSERT INTO parmailcomp(no_remesa,
							renglon,
							no_documento, 
							secuencia, 
							mail_secuencia) 
					VALUES( 0,
							0,	
							_no_tarjeta,
							_secuencia2, 
							_secuencia);
							
	
END FOREACH

RETURN r_error, r_descripcion;

END
end procedure