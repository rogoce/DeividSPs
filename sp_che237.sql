-- Busqueda del Correo en agentes
-- 
-- Creado    : 04/05/2004 - Autor: Demetrio Hurtado Almanza 
--
-- SIS v.2.0 - - DEIVID, S.A.

DROP PROCEDURE sp_che237;
CREATE PROCEDURE "informix".sp_che237(a_agente CHAR(10), a_tipo char(3))
returning varchar(50) as email;

define _e_mail          varchar(50);

set isolation to dirty read;
--if a_poliza = '267512' then
--	SET DEBUG FILE TO "sp_cwf3.trc"; 
--	trACE ON;
--end if

let _e_mail = null;

if a_tipo = 'COM' then
	select e_mail
	  into _e_mail
	  from agtagent
	 where cod_agente  = a_agente;
	 
	if _e_mail is not null and trim(_e_mail) <> "" then	   
		return _e_mail with resume;
	end if

	FOREACH WITH HOLD		   
		   select email
			 into _e_mail
			 from agtmail
			where cod_agente = a_agente
			  and tipo_correo = a_tipo
			  and email is not null
			  and trim(email) <> ""
			  
			return _e_mail with resume;  

	END FOREACH
	
	return "cod_036@asegurancon.com";

end if  
end procedure