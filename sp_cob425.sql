-- SP Busca correo del Cliente en todos los correos del Corredor .
-- Creado    : 01/11/2019 - Autor: Henry Giron
-- SIS v.2.0 - - DEIVID, S.A.

drop procedure sp_cob425;

create procedure "informix".sp_cob425(a_no_poliza 	char(10), a_email_cli char(150))
returning	integer;

define _email_com		varchar(50);
define _email_cob		varchar(50);
define _email_rec		varchar(50);
define _email			char(50);
define _cod_agente		char(5);
define _cantidad		integer;

drop table if exists tmp_agtmail;
CREATE TEMP TABLE tmp_agtmail(
emails char(50)) WITH NO LOG;

set isolation to dirty read;

foreach
select cod_agente
  into _cod_agente
  from emipoagt
 where no_poliza = a_no_poliza	   
	   
	let _cantidad = 0;
	let	_email_com	= '';
	let	_email_cob	= '';
	let	_email_rec	= '';

	select e_mail,
		   email_cobros,
		   email_reclamo
	  into _email_com,
		   _email_cob,
		   _email_rec
	  from agtagent
	 where cod_agente = _cod_agente;

	let _email_cob	= trim(_email_cob);
	if _email_cob is not null and _email_cob <> "" then
		INSERT INTO tmp_agtmail(emails)
		values(_email_cob);
	end if
	let	_email_rec	= trim(_email_rec);
	if _email_rec is not null and _email_rec <> "" then
		INSERT INTO tmp_agtmail(emails)
		values(_email_rec);
	end if
	let	_email_com	= trim(_email_com);
	if _email_com is not null and _email_com <> "" then
		INSERT INTO tmp_agtmail(emails)
		values(_email_com);
	end if


	foreach
		select email
		  into _email
		  from agtmail
		 where cod_agente = _cod_agente	  	
		if _email is not null and _email <> "" then
			INSERT INTO tmp_agtmail(emails)
			values(_email);
		end if		
	end foreach
	
	foreach
		select email
		  into _email
		  from agtexcepmail	                 -- 08/11/2019, ENILDA se adiciona listado de email de excepciones corporativos	 
		if _email is not null and _email <> "" then
			INSERT INTO tmp_agtmail(emails)
			values(_email);
		end if		
	end foreach	

	select count(*)
	into _cantidad
	from tmp_agtmail
	where trim(emails) = trim(a_email_cli);  -- si el email del cliente esta dentro de email del corredor

	if _cantidad is null then
		let _cantidad = 0;  -- no es valido
	end if
		
	if _cantidad <> 0 then	
		let _cantidad = 1;  -- es correo del corredor
	end if
	
	if _cantidad = 1 then
	   exit foreach;
	end if

end foreach

if _cantidad = 0 then
	select count(*)
	  into _cantidad
	  from parmailerr
	 where trim(email) = trim(a_email_cli);

		if _cantidad <> 0 then	
			let _cantidad = 1;   -- enivar a 2-Por imrpimir
		end if
end if		

return _cantidad;

end procedure;