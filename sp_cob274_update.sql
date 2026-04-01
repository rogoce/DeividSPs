-- Procedimiento para actualizar el correo en agtagent con la tabla agtmail
--
-- Creado    : 01/04/2011 - Autor: Roman Gordon
--
-- SIS v.2.0 - DEIVID, S.A.

drop procedure sp_cob274;

create procedure "informix".sp_cob274()
returning integer,char(100);

define _cod_agente			char(5);
define _email				char(50);
define _email_cobros		char(50);
define _email_agente		char(50);
define _email_reclamos		char(50);
define _renglon				smallint;
define _cant_email			smallint;
define _cant_email_cobros	smallint;
							
define _error			integer;
define _error_isam		integer;
define _error_desc		char(100);

set isolation to dirty read;

begin 
on exception set _error, _error_isam, _error_desc
	return _error, _error_desc;
end exception

--SET DEBUG FILE TO "sp_cob271.trc";
--TRACE ON;

foreach
	Select email_cobros,
		   cod_agente
	  into _email,
		   _cod_agente
	  from agtagent

		if _email is null or _email = '' then
			foreach
				select count(*)
				  into _cant_email_cobros
				  from agtmail
				 where tipo_correo = 'COB'
				   and cod_agente = _cod_agente
				   
					if _cant_email_cobros = 0 then
						Select e_mail,
							   email_reclamo
						  into _email_agente,
							   _email_reclamos
						  from agtagent
						 where cod_agente = _cod_agente;

						if _email_agente = '' or _email_agente is null then
							if _email_reclamos = '' or _email_reclamos is null then 
								continue foreach;
							else
								update agtagent set _email_reclamos = _email_reclamos where cod_agente = _cod_agente;	
							end if
						else
							update agtagent set email_cobros = _email_agente where cod_agente = _cod_agente;
						end if

					else
						foreach
							select email
							  into _email_cobros
							  from agtmail
							 where tipo_correo = 'COB'
							   and cod_agente = _cod_agente
							 order by renglon
							exit foreach;
						end foreach
						 
						update agtagent
						   set email_cobros = _email_cobros
						 where cod_agente = _cod_agente;
						exit foreach;
					end if
			end foreach

		else
			select count(*)
			  into _cant_email
			  from agtmail
			 where email = _email
			   and cod_agente = _cod_agente
			   and tipo_correo = 'COB';
				--trace on;
				if _cant_email = 0 then
					Select max(renglon)
					  into _renglon
					  from agtmail
					 where cod_agente = _cod_agente
					   and tipo_correo = 'COB';
						
						if _renglon is null then
							let _renglon = 0;
						end if

						let _renglon = _renglon + 1;
					insert into agtmail(cod_agente,tipo_correo,renglon,email)
					values (_cod_agente,'COB',_renglon,_email);

				end if
		end if
end foreach

return 0,'Actualizacion Exitosa';
end 
end procedure


					
