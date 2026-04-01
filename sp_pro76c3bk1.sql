-- Procedimiento que busca las direcciones de correo del cliente, corredor y ejecutivo
-- Aviso de Cambio de Prima por Cambio de Edad	   
-- Carta para enviar cuando un asegurado principal cumple 30, 40, 45, 50, 55, 60, 65 o 70 anos

-- Creado  :02/08/2015 - Autor: Federico Coronado
drop procedure sp_pro76c3bk1;

CREATE PROCEDURE "informix".sp_pro76c3bk1(a_no_documento  varchar(20))
       RETURNING VARCHAR(50),      -- No_documento
                 varchar(250);
define _no_poliza       		 varchar(10);
define _cod_asegurado   		 varchar(10);
define _nombre_cliente  		 varchar(50);
define _email           		 varchar(50);
define _email_corredor  		 varchar(250);	
define _email_personas  		 varchar(250);
define _email_ejecutivo 		 varchar(250);
define _cod_agente      		 varchar(10);  
define _cod_vendedor    		 varchar(3); 
define _usuario         		 varchar(8); 
define _email_c         		 varchar(250);		
define _email_agtmail			 varchar(250);  
define _email_persona_corredor   varchar(250);  		    

set isolation to dirty read;

 let _no_poliza = sp_sis21(a_no_documento);
 let _email_corredor = '';
 let _email_ejecutivo = '';
 let _email_c         ="";
 let _cod_asegurado   = "";
 
-- set debug file to "sp_pro76c3.trc";
-- trace on;
 
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
		   _email
	  FROM cliclien 
     WHERE cod_cliente = _cod_asegurado;
   
	if _email is null or trim(_email) = "" then
		let _email_personas = null;
	else 
		let _email_personas = trim(_email);
	end if
	
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
		  
		if _email_persona_corredor is null or trim(_email_persona_corredor) = '' then
			foreach
				Select email
				  into _email_agtmail
				  from agtmail
				 where cod_agente = _cod_agente
				   and tipo_correo = 'PER'
				
					if trim(_email_agtmail) = '' or _email_agtmail is null then
						continue foreach;
					end if
						let _email_personas = trim(_email_personas) || ';' || trim(_email_agtmail);
			end foreach
		   
			let _email_c = trim(_email_corredor) || ';' || _email_c;
		else
			let _email_c = trim(_email_persona_corredor) || ';' || trim(_email_corredor)|| ';';
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
	
	if _email_c is null or trim(_email_c) = "" then
		if _email_personas is null or trim(_email_personas) = "" then
			let _email_personas = trim(_email_ejecutivo);
		else
			let _email_personas = trim(_email_personas) || ';' || trim(_email_ejecutivo);
		end if
	else
		if _email_personas is null or trim(_email_personas) = "" then
			let _email_personas = trim(_email_c) || trim(_email_ejecutivo);
		else
			let _email_personas = trim(_email_c) || trim(_email_personas) || ';' || trim(_email_ejecutivo);
		end if
		
	end if
	
	--let _email_personas = 'fcoronado@asegurancon.com';     /*'fcoronado@asegurancon.com';*/
	
return _nombre_cliente,
	   _email_personas;
end procedure
