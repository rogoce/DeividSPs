--
-- SIS v.2.0 - DEIVID, S.A.

drop procedure sp_prueba_parmailsend;

create procedure "informix".sp_prueba_parmailsend() returning integer,
            char(50);

define _no_documento		char(20);
define _tmp					char(1);
define _cod_sucursal		char(3);
define _cod_formapag		char(3);
define _cod_pagador			char(10);
define _cod_asegurado		char(10);
define _email				char(512);
define _email_agt			char(50);
define _e_mail_send			char(200);
define _nombre_aseg			char(100);

define _por_vencer			dec(16,2);
define _exigible			dec(16,2);      
define _corriente			dec(16,2);    
define _monto_30			dec(16,2);
define _monto_60			dec(16,2);      
define _monto_90			dec(16,2);
define _saldo				dec(16,2);   
define _monto_60_mas		dec(16,2);
define _prima_mensual		dec(16,2);      

define _periodo				char(7);
define _fecha				date;
define _fecha_gestion		datetime year to second;
define _desc_gestion		varchar(250);
define _secuencia			integer;
define _secuencia_comp		integer;
define _html_body			char(512);
define _cod_tipo			char(5);

define _cod_agente			char(5);
define _cod_cobrador		char(5);
define _cod_supervisor		char(5);
define _cod_vendedor		char(3);
define _usuario_vende		char(8);
define _usuario_cob			char(8);
define _usuario_supervisor	char(8);	

define _error				integer;
define _error_isam			integer;
define i					integer;
define _error_desc			char(50);

set isolation to dirty read;

--SET DEBUG FILE TO "sp_prueba_parmailsend.trc";
--TRACE ON;

begin 
on exception set _error, _error_isam, _error_desc
	return _error, _error_desc;
end exception

foreach
	select secuencia,
		   email
	  into _secuencia,
	  	   _email		   
	  from parmailsend
	 where cod_tipo = '00018'
	   and enviado = 0

		for i = 1 to 512
			
			let _tmp	= _email[1,1];
			let _email	= _email[2,512];

			if _tmp = ';' then
				update parmailsend
				   set email = _email
				 where secuencia = _secuencia;
				exit for;
			end if
		end for;
end foreach
return 0,'';
end 
end procedure


