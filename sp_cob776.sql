--informa que poliza esta vigente con cese
--Creado : 27/06/2019 - Autor: Henry Giron
--SIS v.2.0 - DEIVID, S.A.

drop procedure sp_cob776;
create procedure "informix".sp_cob776(a_no_poliza char(10),a_renglon integer,a_no_aviso char(10))
returning char(1);

define _email_cli	varchar(100);
define _error		integer;
define _clase		char(1);

set lock mode to wait;

begin
on exception set _error
	return _error;
end exception
	let _clase = '2';

	select trim(email_cli)
	  into _email_cli
	  from avisocanc
	 where no_aviso = a_no_aviso
	   and renglon = a_renglon
	   and no_poliza = a_no_poliza
	   and email_cli is not null
	   and email_cli not like '%/%'
	   and email_cli <> ''
	   and email_cli like '%@%'
	   and email_cli not like '@%'
	   and email_cli not like '% %'
	   and email_cli not like '%,%'
	   and trim(email_cli) not like '%[^a-z,0-9,@,.]%'
	   and trim(email_cli) like '%_@_%_.__%'
	   and lower(trim(email_cli))not like '%asegurancon%'
	   and lower(trim(email_cli))not like '%no%tiene%' ;

	if _email_cli is null then 
		let _email_cli = '';
	end if	

if _email_cli <> '' then  -- se valida el correo
 --     para validar el email del cliente vs email de corredor    -- HG01112019
	call sp_cob425(a_no_poliza, _email_cli) returning _error;
	if _error <> 0 then
		let _clase = '2';
	else
		let _clase = '1';
	end if

else			
	let _clase = '2';
end if

return _clase;
end
end procedure;