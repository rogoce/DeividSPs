-- Procedimiento para procesar los valores en las tablas de DEIVID y emitir las polizas de ducruet
-- Creado    : 17/05/2019 - Autor: Federico Coronado

-- SIS v.2.0 - DEIVID, S.A.

drop procedure sp_emite06;

create procedure "informix".sp_emite06(a_poliza char(10), a_endoso char(5), a_idpoliza integer, a_idendoso integer) 
returning	smallint,varchar(200);


define _error           smallint;
define _error_desc		varchar(200);
define _error_isam		smallint;
define _no_documento    varchar(20);

	begin
	on exception set _error,_error_isam,_error_desc
		return _error,_error_desc;         
	end exception

	set isolation to dirty read;
	--set debug file to "sp_emite01.trc"; 
	--trace on;

 -- Actualización del Endoso
	--call sp_pro43(a_poliza, a_endoso) returning _error,_error_desc;

--	if _error <> 0 then
--		return _error,_error_desc;
--	end if
	
	select no_documento
	  into _no_documento
	  from endedmae
	 where no_poliza = a_poliza
	   and no_endoso = a_endoso;
	--Insert tabla deivid_integrapol
					insert into deivid_integrapol (
						no_poliza,
						no_endoso,
						idpoliza,
						idendoso,
						no_documento)
				values(	a_poliza,
						a_endoso,
						a_idpoliza,
						a_idendoso,
						_no_documento);
	
	
	return 0,"Actualización Exitosa";
	end
end procedure