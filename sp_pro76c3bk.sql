-- Procedimiento que busca las direcciones de correo del cliente, corredor y ejecutivo
-- Aviso de Cambio de Prima por Cambio de Edad	   
-- Carta para enviar cuando un asegurado principal cumple 30, 40, 45, 50, 55, 60, 65 o 70 anos

-- Creado  :02/08/2015 - Autor: Federico Coronado
drop procedure sp_pro76c3bk;

CREATE PROCEDURE "informix".sp_pro76c3bk(a_no_documento  varchar(20))
       RETURNING VARCHAR(50),      -- No_documento
				 varchar(250),     -- para
                 varchar(250);		-- cc
define _no_poliza       		 varchar(10);
define _cod_asegurado   		 varchar(10);
define _nombre_cliente  		 varchar(50);
define _email_corredor  		 varchar(250);	
define _eper_agtmail  		 	 varchar(250);
define _email_ejecutivo 		 varchar(250);
define _cod_agente      		 varchar(10);  
define _cod_vendedor    		 varchar(3); 
define _usuario         		 varchar(8); 
define _email_c         		 varchar(250);		
define _email_agtmail			 varchar(250);  
define _email_persona_corredor   varchar(250); 
define _email_para           	 varchar(250); 
define _email_cc				 varchar(250);
define _e_climail                varchar(250);	
define _email_climail            varchar(250);	    

set isolation to dirty read;

 let _no_poliza = sp_sis21(a_no_documento);
 let _email_corredor 	= 	'';
 let _email_ejecutivo 	= 	'';
 let _email_c         	=	"";
 let _cod_asegurado   	= 	"";
 let _email_agtmail 	= 	"";
 let _eper_agtmail		= 	"";
 let _email_para    	= 	"";
 let _email_cc    		= 	"";
 let _e_climail     	= 	"";
 let _email_climail 	= 	"";
 
 
set debug file to "sp_pro76c3bk.trc";
trace on;
 
 --Seleccion de los Asegurados
	FOREACH
		 SELECT cod_asegurado
		   INTO	_cod_asegurado
		   FROM emipouni
		  WHERE no_poliza = _no_poliza
		   AND  activo    = 1
		exit foreach;
	end foreach
	
	--Datos del Asegurado
    SELECT nombre,
		   e_mail
	  INTO _nombre_cliente,
		   _email_para
	  FROM cliclien 
     WHERE cod_cliente = _cod_asegurado;
   
	foreach
		Select email
		  into _email_climail
		  from climail
		 where cod_cliente = _cod_asegurado
		
			if trim(_email_climail) = '' or _email_climail is null then
				continue foreach;
			end if
				let _e_climail = trim(_email_climail) || ';' || trim(_e_climail);
	end foreach
   
   --Datos del corredor
    foreach
	   select cod_agente
		 into _cod_agente
		 from emipoagt
		where no_poliza =  _no_poliza
		
		select e_mail,
		       email_personas,
		       cod_vendedor
		  into _email_corredor,
			   _email_persona_corredor,
			   _cod_vendedor
		 from agtagent
		where cod_agente = _cod_agente;
		--  and e_mail is not null
		--  and e_mail <> " ";
		  
		foreach
			Select email
			  into _email_agtmail
			  from agtmail
			 where cod_agente = _cod_agente
			   and tipo_correo = 'PER'
			
				if trim(_email_agtmail) = '' or _email_agtmail is null then
					continue foreach;
				end if
					let _eper_agtmail = trim(_email_agtmail) || ';' || trim(_eper_agtmail);
		end foreach
		
		/*Si el corredor tiene el campo de _email_persona_corredor de la tabla agtagent y _email_agtmail de la tabla agtmail tipo_correo 'PER' esta vacio 
		se debe enviar el correo a _email_corredor de  agtagent y a agtmail los que son de tipo COM*/   
		if trim(_email_persona_corredor) = '' and trim(_eper_agtmail) = '' then
				foreach
					Select email
					  into _email_agtmail
					  from agtmail
					 where cod_agente = _cod_agente
					   and tipo_correo = 'COM'
					
						if trim(_email_agtmail) = '' or _email_agtmail is null then
							continue foreach;
						end if
							let _eper_agtmail = trim(_email_agtmail) || ';' || trim(_eper_agtmail);
				end foreach
			let _email_c = trim(_email_corredor) || ';' || trim(_eper_agtmail);
		else
			let _email_c = _email_persona_corredor || ';' || trim(_eper_agtmail);
		end if
	end foreach

	select usuario
	  into _usuario
	  from agtvende
	 where cod_vendedor = _cod_vendedor;

	select e_mail 
	  into _email_ejecutivo
	  from insuser 
	where usuario = _usuario
	  and e_mail is not null
	  and e_mail <> '';	 
	  
	/*
	let _email_para = 'fcoronado@asegurancon.com';
	let _email_cc  = '';
	*/
	
	if _email_cc is null or trim(_email_ejecutivo) = '' then
		let _email_cc = trim(_email_ejecutivo);
	else
		let _email_cc = _email_c || trim(_email_ejecutivo);
	end if
	
	if _email_para is null or trim(_email_para) = '' then
		let _email_para = _e_climail;
	else
		let _email_para = trim(_email_para) || ';' || _e_climail;
	end if
	
		
return _nombre_cliente,
		_email_para,
	   _email_cc;
end procedure
