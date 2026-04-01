-- Cargando la tabla parmailsend con datos de recrcmae
-- Federico Coronado 15/07/2013 


drop procedure sp_pro534;

create procedure sp_pro534()
RETURNING SMALLINT, CHAR(30);

DEFINE r_error        	integer;
DEFINE r_error_isam   	integer;
DEFINE r_descripcion  	CHAR(30);
Define _html_body		char(512);
define _secuencia       integer;
define _secuencia2      integer;
define ls_e_mail        varchar(50);
define _fecha_actual    date;
define _no_tramite      varchar(10);
define _cod_contratante varchar(10);
define _sender          varchar(100);
define _no_documento    varchar(15);
define _nombre          varchar(100);
define _cantidad        smallint;
define _email_final     char(384);
define _email_climail   varchar(50);
define _user_added 		varchar(8);
define _fecha_siniestro date;
define _no_unidad       char(5);
define _cnt_pma         smallint;

BEGIN
ON EXCEPTION SET r_error, r_error_isam, r_descripcion
 	RETURN r_error, r_descripcion;
END EXCEPTION

set isolation to dirty read;

LET r_error       = 0;
LET r_descripcion = 'Actualizacion Exitosa ...';

--set debug file to "sp_pro534.trc"; 
--trace on;

LET _sender = "";
let _fecha_actual = sp_sis26();
let _fecha_actual = _fecha_actual - 1 units day;
let ls_e_mail = "";
let _email_final = '';
let _email_climail = '';

foreach
	select no_tramite,
	       cod_contratante,
		   b.no_documento,
		   a.user_added, 
		   a.fecha_siniestro,
		   a.no_unidad
	  into _no_tramite,
		   _cod_contratante,
		   _no_documento,
		   _user_added,
		   _fecha_siniestro,
		   _no_unidad
	  from recrcmae a inner join emipomae b on a.no_poliza = b.no_poliza
     where fecha_reclamo = _fecha_actual
	   and cod_ramo in ('020','002','023')
	   and no_tramite is not null
	   
	--Verificamos si el reclamo llego por el archivo txt que envia panama asistencia 
	---*** si es asi el proceso debe realizar el envio por correo de la apertura del reclamo.
	let _cnt_pma = sp_rec206f (_no_documento,_no_unidad, _fecha_siniestro);
	
	if _cnt_pma = 0 then
		continue foreach;
	end if	
	
	select count(*)
	  into _cantidad
	  from parmailcomp
	 where no_remesa = _no_tramite
	   and no_documento = _no_documento;
	 
	if _cantidad = 0 then
		select e_mail,
			   nombre 
		  into ls_e_mail,
			   _nombre 
		  from cliclien 
		 where cod_cliente = _cod_contratante;

		if ls_e_mail <> '' then

			let _email_final = trim(ls_e_mail);

			foreach
				select email
				  into _email_climail
				  from climail
				 where cod_cliente = _cod_contratante

				let _email_climail = trim(_email_climail);
				let ls_e_mail      = trim(ls_e_mail);                
				
				if ls_e_mail <> _email_climail then
					let _email_final   = trim(_email_final) || ';' || trim(_email_climail);
				end if
            end foreach
			-- 00029 tipo nota de apertura email que se envia a los clientes que se les abrio el reclamo
			let _secuencia = sp_par336 ('00029', _email_final, 1);

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
			_nombre,
			_no_tramite,
			0,
			_secuencia);
		end if

	end if
END FOREACH

RETURN r_error, r_descripcion  WITH RESUME;

END
end procedure