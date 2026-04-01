-- Procedure para auditoria interna - Archivo de Reclamo - Leyri Moreno
-- 
-- Creado    : 18/04/2013 - Autor: Amado Perez Mendoza
--
-- SIS v.2.0 - DEIVID, S.A.

drop procedure sp_aud45;		

create procedure "informix".sp_aud45() 
returning integer, integer, varchar(100); 

define _no_requis           char(10);
define _error_cod  			integer;
define _error_desc          varchar(50);
define _error_isam	        integer;

set isolation to dirty read;

begin

on exception set _error_cod, _error_isam, _error_desc
	return _error_cod, _error_isam, trim(_error_desc) || " " || _no_requis;
end exception

--SET DEBUG FILE TO "sp_aud45.trc";
--trace on;

delete from deivid_ttcorp:chqchmae;
delete from deivid_ttcorp:chqchcta;

insert into deivid_ttcorp:chqchmae select * from chqchmae where fecha_impresion >= '01/07/2011' and pagado = 1;

foreach
	select no_requis
	  into _no_requis
	  from deivid_ttcorp:chqchmae

	insert into deivid_ttcorp:chqchcta select * from chqchcta where no_requis = _no_requis;

end foreach
return 0, 0, "Exitoso";

end
end procedure

