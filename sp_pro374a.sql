-- Proceso que genera la información del Archivo de Pólizas Nuevas y Renovaciones de Ducruet (Excepto Auto, Soda y Fianzas)
-- Creado    : 15/02/2013 - Autor: Roman Gordon
-- SIS v.2.0 - DEIVID, S.A.

drop procedure sp_pro374a;

create procedure "informix".sp_pro374a()
returning integer,
		  smallint,
		  char(30),
          char(120);


define _error_title	varchar(30);
define _error_desc	char(100);
define _no_poliza	char(10);
define _error_isam	integer;
define _error		integer;

--set debug file to "sp_pro374a.trc"; 
--trace on;
		  
foreach
	select no_poliza
	  into _no_poliza
	  from emipomae 
	 where no_poliza in (select no_poliza 
						   from prdemielctdet
						  where num_carga in ('00134','00136','00137','00138')
						    and actualizado = 1)
	   and no_documento not in ('0213-91596-47','0213-91584-47','0213-17157-47','0213-91589-47')
	   and actualizado = 0
	   
	call sp_pro374 (_no_poliza) returning _error,_error_isam,_error_title,_error_desc;
	return _error,_error_isam,_error_title,_error_desc with resume;
end foreach
end procedure