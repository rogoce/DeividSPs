-- Ingreso a parmailsend para ser enviado por correo --> CON ANCON SIEMPRE GANAS

-- Amado Perez 25/10/2012


drop procedure sp_cob327;

create procedure sp_cob327()
RETURNING SMALLINT, CHAR(30);

DEFINE r_error        	integer;
DEFINE r_error_isam   	integer;
DEFINE r_descripcion  	CHAR(30);
Define _html_body		char(512);
define _secuencia       integer;
define _secuencia2      integer;
define ls_e_mail        varchar(50);
define _user_tecnico    char(8);
define _cnt             integer;
define _no_boleto       char(10);
define _cod_cliente     char(10);
define _cod_chequera	char(3);
define _adjunto         integer;
define _ramo            char(2);
define _transaccion     char(10);
define _cod_tipopago    char(3);
define _cantidad        integer;
define _contador        integer;
define _sender          varchar(100);
define _sender_c        varchar(100);
define _email          	varchar(100);

define _no_devleg       char(10);
define _no_requis       char(10);
define _pagado			smallint;
define _anulado         smallint;


BEGIN

ON EXCEPTION SET r_error, r_error_isam, r_descripcion
 	RETURN r_error, r_descripcion;
END EXCEPTION

set isolation to dirty read;

LET r_error       = 0;
LET r_descripcion = 'Actualizacion Exitosa ...';
LET	_cnt          = 0;

--set debug file to "sp_atc19.trc"; 
--trace on;

LET _sender = "";
LET _sender_c = "";

{FOREACH
	SELECT email
	  INTO _sender_c
	  FROM parcocue
	 WHERE cod_correo = '065' --> CON ANCON SIEMPRE GANAS (ENVIO MASIVO CC)
	   AND activo = 1

	IF TRIM(_sender_c) <> "" AND _sender_c IS NOT NULL THEN
		LET _sender = _sender || TRIM(_sender_c) || ";"; 
	END IF
END FOREACH}

FOREACH				   
	select no_devleg, e_mail, no_requis	  
	  into _no_devleg, ls_e_mail, _no_requis
	  from cobdevleg
	 where envio_email = 0

  --  let ls_e_mail = "aperez@asegurancon.com";

    select pagado, anulado
	  into _pagado, _anulado
	  from chqchmae
	 where no_requis = _no_requis;

    if _pagado = 0 or _anulado = 1 then
		continue foreach;
	end if

	let _secuencia = sp_par310('00027', trim(ls_e_mail), 0);

  -- 	Update parmailsend 			   --Aqui se actualiza el correo de la copia
  --	   set sender   	= _sender
  --	 where secuencia	= _secuencia;

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
	_no_devleg,
	0,
	_secuencia);

    UPDATE cobdevleg SET envio_email = 1 WHERE no_devleg = _no_devleg;

END FOREACH


RETURN r_error, r_descripcion  WITH RESUME;

END
end procedure