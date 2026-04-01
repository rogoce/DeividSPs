-- Procedimiento que Verifica si la poliza tiene acreedor o Leasing.
-- Creado    : 30/11/2011 - Autor: Roman Gordon
-- SIS v.2.0 - DEIVID, S.A.

drop procedure sp_pro216;

create procedure "informix".sp_pro216(a_no_poliza char(10))
 returning smallint,
		   char(60);

define _error_code      integer;
define _error_isam     	integer;
define _cnt_leasing		smallint;
define _cnt_acreedor	smallint;
define _error_desc 		char(60);

--set debug file to "sp_pro216.trc"; 
--trace on;                                                                

set isolation to dirty read;

begin

on exception set _error_code,_error_isam,_error_desc 
 	return _error_code, _error_desc;         
end exception
end     

select leasing
  into _cnt_leasing
  from emipomae
 where no_poliza = a_no_poliza;

select count(*)
  into _cnt_acreedor
  from emipoacr
 where no_poliza = a_no_poliza;

if _cnt_leasing > 0 and _cnt_acreedor > 0 then
	return 3,'Póliza tiene Acreedor y Leasing, por favor verifique';
elif _cnt_leasing > 0 then
	return 2,'Póliza tiene Leasing, por favor verifique';
elif _cnt_acreedor > 0 then
	return 1,'Póliza tiene Acreedor, por favor verifique';
end if

return 0,'';

end procedure