-- Actualiza chqchmae YOSEGUROS 02/08/2019

-- Creado: 02/08/2019 - Autor: Amado Perez Mendoza

drop procedure sp_rwf167;

create procedure "informix".sp_rwf167(a_no_requis char(10), a_firma smallint, a_firmante char(20))
returning  smallint, char(50);	--firma

define _error_cod		integer;
define _error_isam		integer;
define _error_desc		char(50);

SET ISOLATION TO DIRTY READ;

--SET DEBUG FILE TO "sp_rec76i.trc";      
--TRACE ON;                                                                     

BEGIN
on exception set _error_cod, _error_isam, _error_desc
	return _error_cod, _error_desc;
end exception

if a_firma = 1 then
	UPDATE chqchmae
	   SET en_firma = 1,
		   fecha_paso_firma = current,
		   firma1 = a_firmante
	 WHERE no_requis = a_no_requis;
else
	UPDATE chqchmae
	   SET firma2 = a_firmante
	 WHERE no_requis = a_no_requis;
end if

END 


return 0, "Actualizacion Exitosa";

end procedure