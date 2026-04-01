-- Procedimiento que busca las direcciones de correo del cliente y corredor
-- Aviso de Cambio de Prima por Cambio de Edad	   
-- Carta para enviar cuando un asegurado principal cumple 30, 40, 45, 50, 55, 60, 65 o 70 años
-- Creado  :20/10/2015 - Autor: Federico Coronado

-- 0 = email vacio asegurado
-- 1 = Correcto
-- 2 = email mal escrito cliente 
-- 3 = email mal escrito corredor 
-- 4 = ambos mal escritos

drop procedure sp_pro76c31;

CREATE PROCEDURE "informix".sp_pro76c31(a_no_documento  varchar(20))
       RETURNING smallint;
define _no_poliza       		 varchar(10);
define _cod_asegurado   		 varchar(10);
define _nombre_cliente  		 varchar(50);
define _email_corredor  		 varchar(250);	
define _eper_agtmail  		 	 varchar(250);
define _cod_agente      		 varchar(10);  
define _email_c         		 varchar(250);		
define _email_agtmail			 varchar(250);  
define _email_persona_corredor   varchar(250); 
define _email_para           	 varchar(250); 
define _email_cc				 varchar(250);
define _e_climail                varchar(250);	
define _email_climail            varchar(250);
define _email_vacio              smallint;	    

set isolation to dirty read;

 let _no_poliza = sp_sis21(a_no_documento);
 let _email_corredor 	= 	'';
 let _email_c         	=	"";
 let _cod_asegurado   	= 	"";
 let _email_agtmail 	= 	"";
 let _eper_agtmail		= 	"";
 let _email_para    	= 	"";
 let _email_cc    		= 	"";
 let _e_climail     	= 	"";
 let _email_climail 	= 	"";
 let _email_vacio 		= 1	  ; -- correo lleno
 
 
--set debug file to "sp_pro76c3bk.trc";
--trace on;
 
 --Seleccion de lo Asegurado
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
	
	if _email_para is null or trim(_email_para) = "" then
		let _email_vacio = 0; -- correo vacio asegurado
		return _email_vacio;
	else 
		if _email_para not like '%@%' or _email_para not like '%.%' or _email_para like '%/%' or _email_para like '@%' or _email_para like '% %' then --or _email_para <> '' or _email_para <> 'actualiza@asegurancon.com' or _email_para <> 'actualizaciones@asegurancon.com' or _email_para like '%@%' or _email_para not like '@%' or _email_para not like '% %' or _email_para not like '%,%' then
			let _email_vacio = 2; -- correo mal escrito asegurado
		else
			let _email_vacio = 1; -- correo lleno asegurado
		end if
	end if
   
  
	foreach
		Select email
		  into _email_climail
		  from climail
		 where cod_cliente = _cod_asegurado
		
			if trim(_email_climail) = '' or _email_climail is null then
				continue foreach;
			end if
			
			if _email_climail not like '%@%' or _email_climail not like '%.%' or _email_climail like '%/%' or _email_climail like '@%' or _email_climail like '% %' then
				let _email_vacio = 2; -- correo mal escrito cliente
				--continue foreach;
			end if
	end foreach
  
   --Datos del corredor
    foreach
	   select cod_agente
		 into _cod_agente
		 from emipoagt
		where no_poliza =  _no_poliza
		
		select e_mail,
		       email_personas
		  into _email_corredor,
			   _email_persona_corredor
		 from agtagent
		where cod_agente = _cod_agente;
		
		if _email_persona_corredor is null then
			let _email_persona_corredor = '';
		end if
	
		if _email_corredor is null then
			let _email_corredor = '';
		end if
		
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
		
		if _eper_agtmail is null then
			let _eper_agtmail = '';
		end if
		
		--Si el corredor tiene el campo de _email_persona_corredor de la tabla agtagent y _email_agtmail de la tabla agtmail tipo_correo 'PER' esta vacio 
		--se debe enviar el correo a _email_corredor de  agtagent y a agtmail los que son de tipo COM   
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
				if _email_corredor <> '' then
					let _email_c = trim(_email_corredor) || ';' || trim(_eper_agtmail);
				else
					let _email_c = trim(_eper_agtmail);
				end if
		else
		
			let _email_c = trim(_email_persona_corredor) || ';' || trim(_eper_agtmail);
		end if
	end foreach

	if trim(_email_c) = "" then
		let _email_vacio = 5; -- correo corredor vacio
	else
		if _email_c not like '%@%' or _email_c not like '%.%' or _email_c like '%/%' or _email_c like '@%' or _email_c like '% %' then
			if _email_vacio = 2 then
				let _email_vacio = 4; -- correo mal escrito Corredor Asegurado
			else
				let _email_vacio = 3; -- correo mal escrito Corredor
			end if
			--continue foreach;
		end if
	end if
		
return _email_vacio;
end procedure
