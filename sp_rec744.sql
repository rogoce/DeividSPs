
-- Programa que devuelve las direcciones de correos para enviar las declinaciones DEIVID GESTION
-- Amado Perez 10/06/2019            

drop procedure sp_rec744;

create procedure sp_rec744(a_no_tranrec CHAR(10))
returning integer, varchar(255);

define ls_e_mail        varchar(255);
define _email          	varchar(200);
define _email_agt       varchar(50);
define r_descripcion  	char(30);
define _cod_cliente     char(10);
define r_error_isam   	integer;
define r_error        	integer;
define _no_poliza       char(10);
define _cod_agente      char(10);
define _no_reclamo      char(10);
define _cantidad        smallint;

begin

on exception set r_error, r_error_isam, r_descripcion
 	return r_error, r_descripcion;
end exception

set isolation to dirty read;

let r_error       = 0;
let r_descripcion = 'Actualizacion Exitosa ...';

--set debug file to "sp_rec744.trc"; 
--trace on;

let ls_e_mail = "";
let _email_agt = "";

-- Declinación del Reclamo
foreach
	select no_reclamo,
           cod_cliente		   
	  into _no_reclamo,
		   _cod_cliente
	  from rectrmae
	 where no_tranrec = a_no_tranrec
	   
		let ls_e_mail = "";

		select e_mail
		  into ls_e_mail
		  from cliclien 
		 where cod_cliente = _cod_cliente;

		if ls_e_mail is null then
			let ls_e_mail = "";
		end if 

		select count(*)
		  into _cantidad 
		  from climail 
		 where cod_cliente = _cod_cliente;

		if _cantidad > 0 then
			foreach
				select email 
				  into _email 
				  from climail 
				 where cod_cliente = _cod_cliente

				if trim(_email) <> "" and _email is not null then
					let ls_e_mail = trim(ls_e_mail) || ";" || trim(_email);
				end if
			end foreach
		end if

		let _email = "";
		
		-- Enviando copia a Agente			 
			select no_poliza
			  into _no_poliza
			  from recrcmae
			 where no_reclamo = _no_reclamo;
						 
			foreach
				select cod_agente
				  into _cod_agente
				  from emipoagt
				 where no_poliza = _no_poliza
				
				if _cod_agente = '00035' then
					let _email_agt = 'saludindividual@unityducruet.com';
				else
				    select email_reclamo
					  into _email_agt
					  from agtagent
					 where cod_agente = _cod_agente;
				end if
				
				if trim(_email_agt) <> "" and _email_agt is not null then
					let ls_e_mail = trim(ls_e_mail) || ";" || trim(_email_agt);
				end if
			end foreach      		 
		
		if ls_e_mail is not null and trim(ls_e_mail) <> "" then
			let ls_e_mail = trim(ls_e_mail) || ";";		
		end if
END FOREACH

return r_error, ls_e_mail  ;

end
end procedure;