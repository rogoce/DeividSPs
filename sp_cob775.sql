--informa que poliza esta vigente con cese
--Creado : 27/06/2019 - Autor: Henry Giron
--SIS v.2.0 - DEIVID, S.A.

drop procedure sp_cob775;
create procedure "informix".sp_cob775(a_no_poliza char(10))
returning smallint;

define _cnt_cese	smallint;
define _error		integer;

set lock mode to wait;

begin
on exception set _error
	return _error;
end exception

foreach
	select count(*)
	  into _cnt_cese
	  from avisocanc
	 where no_poliza = a_no_poliza
	   and cod_ramo in ('002','020') 
	   and estatus = 'Z'

	if _cnt_cese is null then
		let _cnt_cese = 0;
	end if
	
	if _cnt_cese > 0 then
		return 1;
	end if
end foreach

return 0;
end
end procedure;