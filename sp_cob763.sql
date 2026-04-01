-- Correos Cobros - Solicitud de Analiza
-- Creado por :  Henry Giron
-- Fecha      :  22/07/2011
-- SIS v.2.0 - DEIVID, S.A.	  execute procedure sp_cob763()

DROP PROCEDURE sp_cob763;
CREATE PROCEDURE "informix".sp_cob763()
RETURNING char(5),		
		  char(50),
		  char(50),
		  char(15),
		  char(50);            			

define _cod_agente			char(5);
define _nombre_agente		char(50);
define _zona_cobros         char(50);
define _cod_tipo			char(5);		 
define _email_cobros		char(50);
define _email_agtmail		char(50);
define _e_mail				char(50);
define _email_send	 		char(255);
define _html_body			char(512);
define _secuencia_comp		integer;
define _secuencia			integer;
define _error				integer;
define _error_isam			integer;
define _error_desc			char(50);
define _saldo60_mas			dec(16,2);
define _count				smallint;
define _cod_cobrador		char(5);
define _cod_supervisor		char(5);
define _cod_vendedor		char(3);
define _usuario_vende		char(8);
define _usuario_cob			char(8);
define _usuario_supervisor	char(8);
define _principal			smallint;
define _desc_principal      char(15);

CREATE TEMP TABLE tmp_sp_cob763(
	   cod_agente			char(5),	
	   nombre_agente		char(50),		
	   email_cobros		    char(50),
	   principal			smallint,
	   zona_cobros			char(50)
	) WITH NO LOG;

SET ISOLATION TO DIRTY READ;

begin 
--on exception set _error, _error_isam, _error_desc
--	return _error, _error_desc;
--end exception

--SET DEBUG FILE TO "sp_cob763.trc";
--TRACE ON;
let _email_agtmail "";

foreach
	Select cod_agente,
	       nombre,
		   email_cobros
	  into _cod_agente,
	       _nombre_agente,
		   _email_cobros
	  from agtagent

		select cod_cobrador
		  into _cod_cobrador
		  from agtagent
		 where cod_agente = _cod_agente;

		select nombre
		  into _zona_cobros
		  from cobcobra
		 where cod_cobrador = _cod_cobrador;
		
		if _email_cobros is null or _email_cobros = "" then
			INSERT INTO tmp_sp_cob763(cod_agente,nombre_agente,email_cobros,principal,zona_cobros)
			values(_cod_agente,_nombre_agente,_email_cobros,0,_zona_cobros);
			continue foreach;
		else
			INSERT INTO tmp_sp_cob763(cod_agente,nombre_agente,email_cobros,principal,zona_cobros)
			values(_cod_agente,_nombre_agente,_email_agtmail,1,_zona_cobros);
		end if
		
		foreach
			Select email
			  into _email_agtmail
			  from agtmail
			 where cod_agente = _cod_agente
			   and tipo_correo = 'COB'
			
				if trim(_email_agtmail) = '' or _email_agtmail is null then
					continue foreach;
				end if
			 	if _email_agtmail = _email_cobros then
			 		continue foreach;
			 	else
					INSERT INTO tmp_sp_cob763(cod_agente,nombre_agente,email_cobros,principal,zona_cobros)
					values(_cod_agente,_nombre_agente,_email_agtmail,2,_zona_cobros);
				end if
		end foreach

end foreach

foreach
	Select cod_agente,
		   nombre_agente,
		   email_cobros,
		   principal,
		   zona_cobros
	  into _cod_agente,
	       _nombre_agente,
		   _email_cobros,
		   _principal,
	       _zona_cobros		   
	  from tmp_sp_cob763

	if _principal = 1 then
		let _desc_principal = "No tiene";
	elif _principal = 2 then
		let _desc_principal = "Secundario";
	elif _principal = 0 then
		let _desc_principal = "Principal";
	end if

	RETURN _cod_agente,
	       _nombre_agente,
	 	   _email_cobros,
	 	   _desc_principal,
		   _zona_cobros	
		   WITH RESUME;

END FOREACH

--return 0,'Insecion Exitosa';
end
end procedure