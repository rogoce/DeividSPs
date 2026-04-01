-- Ingreso a parmailsend para ser enviado por correo --> CON ANCON SIEMPRE GANAS

-- Amado Perez 25/10/2012


drop procedure sp_atc19;

create procedure sp_atc19()
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

FOREACH
	SELECT email
	  INTO _sender_c
	  FROM parcocue
	 WHERE cod_correo = '065' --> CON ANCON SIEMPRE GANAS (ENVIO MASIVO CC)
	   AND activo = 1

	IF TRIM(_sender_c) <> "" AND _sender_c IS NOT NULL THEN
		LET _sender = _sender || TRIM(_sender_c) || ";"; 
	END IF
END FOREACH

{FOREACH					-- Ya termino la tombola lo pongo en comentario orden de Marissa 16/04/2013
	select no_boleto, e_mail	  
	  into _no_boleto, ls_e_mail
	  from atcacbdd
	 where enviado = 0

	let _adjunto = 1;


    For _contador = 1 to _adjunto
		let _secuencia = sp_par310('00026', trim(ls_e_mail), 1);
		Update parmailsend 
		   set sender   	= _sender
		 where secuencia	= _secuencia;
	end for

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
	_no_boleto,
	0,
	_secuencia);

    UPDATE atcacbdd SET enviado = 1 WHERE no_boleto = _no_boleto;

END FOREACH
}


UPDATE atcacbdd SET enviado = 1;

RETURN r_error, r_descripcion  WITH RESUME;

END
end procedure