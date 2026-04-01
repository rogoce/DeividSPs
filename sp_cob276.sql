-- Insercion de los correos para el envio del Informe de Morosidad en forma masiva 
-- Creado por :    Roman Gordon	04/04/2011
-- SIS v.2.0 - DEIVID, S.A.

drop procedure sp_cob276;
create procedure "informix".sp_cob276()
returning	integer,
            char(50);				

define _html_body			char(512);
define _email_send	 		char(384);
define _email_agtmail		char(50);		 
define _email_cobros		char(50);
define _e_mail				char(50);
define _error_desc			char(50);
define _usuario_supervisor	char(8);
define _usuario_vende		char(8);
define _usuario_cob			char(8);
define _cod_supervisor		char(5);
define _cod_cobrador		char(5);
define _cod_agente			char(5);
define _cod_tipo			char(5);
define _cod_vendedor		char(3);
define _saldo60_mas			dec(16,2);
define _emi_periodo_cerrado	smallint;
define _cob_periodo_cerrado smallint;
define _count				smallint;
define _secuencia_comp		integer;
define _error_isam			integer;
define _secuencia			integer;
define _error				integer;
define _mail_err            integer;
define _cnt_moro            integer;


SET ISOLATION TO DIRTY READ;

begin 
on exception set _error, _error_isam, _error_desc
	return _error, _error_desc;
end exception

--SET DEBUG FILE TO "sp_cob276.trc";
--TRACE ON;
----------------------------------

let _cod_tipo  = "00019"; 
foreach
	Select cod_agente
	  into _cod_agente
	  from agtagent
--	  where cod_agente = '03254'

	SELECT count(*)
	  into _cnt_moro
	  FROM deivid_web:web_poliza
	 where cod_agente = _cod_agente 
	   and saldo > 0;
	
	if _cnt_moro > 0 then

		let _email_send = sp_sis163a(_cod_agente,'COB');

		select cod_vendedor,
			   cod_cobrador
		  into _cod_vendedor,
			   _cod_cobrador
		  from agtagent
		 where cod_agente = _cod_agente;
		 
		select usuario
		  into _usuario_vende
		  from agtvende
		 where cod_vendedor = _cod_vendedor;

		select usuario,
			   cod_supervisor
		  into _usuario_cob,
			   _cod_supervisor
		  from cobcobra
		 where cod_cobrador = _cod_cobrador;
		
		select usuario
		  into _usuario_supervisor
		  from cobcobra
		 where cod_cobrador = _cod_supervisor;

		foreach
			select e_mail
			  into _e_mail
			  from insuser
			 where usuario in(_usuario_vende,_usuario_cob,_usuario_supervisor)
			   and (status = 'A' or status = 'I' and fvac_out is not null)

			let _email_send = trim(_email_send) || trim(_e_mail) || ";";
		end foreach

		call sp_sis455a(_cod_tipo,_email_send,'','',_cod_agente,0,'','',0.00,0.00,0.00,null) returning _error,_error_desc;

		if _error <> 0 then
			return _error,_error_desc;
		end if
	end if
end foreach
return 0,'Insecion Exitosa';
end
end procedure;