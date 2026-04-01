-- Actualiza el campo subir_bo para las cobros y sus tablas relacionas cuando se actualiza el registro

-- Creado    : 07/07/2007 - Autor: Demetrio Hurtado Almanza 
--
-- SIS v.2.0 - DEIVID, S.A

drop procedure sp_sis95;

create procedure sp_sis95(a_no_remesa char(10))
returning integer,
          char(50);

define _error		integer;
define _error_isam	integer;
define _error_desc	char(50);

begin
on exception set _error, _error_isam, _error_desc
	return _error, _error_desc;
end exception

update cobremae set subir_bo = 1 where no_remesa = a_no_remesa;
update cobredet set subir_bo = 1 where no_remesa = a_no_remesa;

end 

return 0, "Actualizacion Exitosa...";

end procedure