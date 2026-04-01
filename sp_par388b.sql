-- Cargando la tabla parmailsend con datos de Red Ancon Premier Care
-- Creado    : 24/07/2024 - Autor: Henry Giron
drop procedure sp_par388b;
create procedure sp_par388b()
RETURNING SMALLINT, CHAR(30);

DEFINE r_error        	integer;
DEFINE r_error_isam   	integer;
DEFINE r_descripcion  	CHAR(30);
Define _html_body		char(512);
define _secuencia       integer;
define _secuencia2      integer;
define ls_e_mail        varchar(100);
define _fecha_actual    date;
define _no_tramite      varchar(10);
define _cod_asegurado   varchar(10);
define _sender          varchar(100);
define _no_documento    varchar(15);
define _nombre          varchar(100);
define _cantidad        smallint;
define _email_final     char(384);
define _email_climail   varchar(100);
define _user_added 		varchar(8);
define _fecha_siniestro date;
define _no_unidad       char(5);
define _cnt_pma         smallint;
define _llave           integer;

BEGIN
ON EXCEPTION SET r_error, r_error_isam, r_descripcion
 	RETURN r_error, r_descripcion;
END EXCEPTION

set isolation to dirty read;

LET r_error       = 0;
LET r_descripcion = 'Actualizacion Exitosa ...';

--set debug file to "sp_par388b.trc"; 
--trace on;


LET _sender = "";
let _fecha_actual = sp_sis26();
let _fecha_actual = _fecha_actual - 1 units day;
let ls_e_mail = "";
let _email_final = '';
let _email_climail = '';

foreach
	select NVL(poliza,''),
	       NVL(cod_asegurado,''),
		   NVL(email_asegurado,''),
		   NVL(email_corredor,''),
		   llave
	  into _no_documento,
		   _cod_asegurado,
		   ls_e_mail,
		   _email_climail,
		   _llave
	  from deivid_tmp:carta_021
     where (secuencia = 0  or secuencia is null )  and enviado = 0
	 --  and poliza in ('1800-00041-01','1898-00013-01')


		if trim(ls_e_mail) <> '' and ls_e_mail is not null then
			let _email_final = trim(ls_e_mail);
		end if

		if trim(_email_climail) <> '' and _email_climail is not null then
			if trim(_email_final) = '' then
				let _email_final = trim(_email_climail);
			else
				let _email_final  = trim(_email_final) || ';' || trim(_email_climail);
			end if	
		end if
		
		if trim(_email_final) <> '' and _email_final is not null then 
		    let _email_final  = trim(_email_final) || ';' ;
		else
		    let _email_final  = "atencionalcliente@asegurancon.com;";
		end if
        
		if trim(_email_final) <> '' and _email_final is not null then 
			let _secuencia = sp_par336 ('00055', _email_final, 0);

			Select max(secuencia)
			  into _secuencia2
			  from parmailcomp;

			if _secuencia2 is null then
				let _secuencia2 = 0;
			end if

			let _secuencia2 = _secuencia2 + 1;

			insert into parmailcomp(
			secuencia,
			no_documento,
			asegurado,
			no_remesa,
			renglon,
			mail_secuencia)
			values(
			_secuencia2,
			_no_documento,
			null,
			_cod_asegurado,
			0,
			_secuencia);
			
			update deivid_tmp:carta_021
			   set secuencia = _secuencia
			 where llave = _llave;
		end if
	
END FOREACH

RETURN r_error, r_descripcion  WITH RESUME;

END
end procedure