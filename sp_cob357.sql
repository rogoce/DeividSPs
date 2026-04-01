-- Procedimiento para la inserción inicial de registros a las campañas de la nueva ley de seguros (Proceso de Primera Letra)
-- Creado    : 08/04/2015 - Autor: Román Gordón
-- SIS v.2.0 - d_cobr_cobros_x_dia_cte - DEIVID, S.A.

drop procedure sp_cob357;
create procedure sp_cob357()
returning	integer,
			varchar(100);

define _error_desc			varchar(100);
define _no_documento		char(20);
define _no_poliza			char(10);
define _error_isam			integer;
define _error				integer;


--set debug file to "sp_cob357.trc";
--trace on;

set isolation to dirty read;
begin

on exception set _error,_error_isam,_error_desc
	return _error,_error_desc;
end exception 

foreach
	select distinct d.doc_remesa
	  into _no_documento
	  from cobremae m, cobredet d
	 where m.no_remesa = d.no_remesa
	   and m.actualizado = 1
	   and m.tipo_remesa not in ('A','M','C','J','H','T')
	   and d.tipo_mov in ('P','N','X')

	call sp_pro545(_no_documento) returning _error,_error_desc;

	if _error <> 0 then
		rollback work;
		return _error, _error_desc;
	end if

	call sp_cob346a(_no_documento) returning _error,_error_desc;

	if _error <> 0 then
		rollback work;
		return _error, _error_desc;
	end if

	call sp_pro544(_no_documento) returning _error,_error_desc;

	if _error <> 0 then
		rollback work;
		return _error, _error_desc;
	end if

	return 0,_no_documento with resume;
end foreach
end
end procedure;