-- Cargando la tabla parmailsend con datos de recrcmae
-- Federico Coronado 15/07/2013 


drop procedure sp_pro534c;

create procedure sp_pro534c(a_no_asiges varchar(20), a_no_poliza char(10))
RETURNING SMALLINT, CHAR(30);

DEFINE r_error        	integer;
DEFINE r_error_isam   	integer;
DEFINE r_descripcion  	CHAR(30);
define _secuencia       integer;
define _secuencia2      integer;
define ls_e_mail        varchar(50);
define _cod_contratante varchar(10);
define _no_documento    varchar(15);
define _nombre          varchar(100);
define _cantidad        smallint;
define _email_final     char(384);
define _email_climail   varchar(50);
define _cnt_email       smallint;

BEGIN
ON EXCEPTION SET r_error, r_error_isam, r_descripcion
 	RETURN r_error, r_descripcion;
END EXCEPTION

set isolation to dirty read;

LET r_error       = 0;
LET r_descripcion = 'Actualizacion Exitosa ...';
LET _cnt_email 	  = 0;

--set debug file to "sp_pro534.trc"; 
--trace on;

	select no_documento 
	  into _no_documento
	  from recpanasi
	 where no_asiges = a_no_asiges;
	
	select count(*)
	  into _cantidad
	  from parmailcomp
	 where no_documento = _no_documento
	   and asegurado    = a_no_asiges;
	 
	if _cantidad = 0 then
	
		select cod_contratante
		 into _cod_contratante
		 from emipomae
		where no_poliza = a_no_poliza;
		
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
				
				let _cnt_email = _cnt_email + 1;
				
            end foreach
			-- 00049 tipo Notificacion de reclamo email que se envia a los clientes reclamo no abierto pero enviado por panama asistencia
			if _cnt_email > 0 then
				let _email_final   = trim(_email_final) || ';';
			end if
			let _secuencia = sp_par336 ('00049', _email_final, 1);

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
			mail_secuencia,
			fecha)
			values(
			_secuencia2,
			_no_documento,
			a_no_asiges,
			a_no_poliza,
			0,
			_secuencia,
			today);
		end if

	end if

RETURN r_error, r_descripcion;

END
end procedure