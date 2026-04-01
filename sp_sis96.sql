-- Actualiza el campo subir_bo para las polizas y sus tablas relacionas cuando se actualiza el registro

-- Creado    : 07/07/2007 - Autor: Demetrio Hurtado Almanza 
--
-- SIS v.2.0 - DEIVID, S.A

drop procedure sp_sis96;

create procedure sp_sis96(a_tipo smallint, a_no_reclamo char(10), a_no_tranrec char(10))
returning integer,
          char(50);

define _error		integer;
define _error_isam	integer;
define _error_desc	char(50);

set isolation to dirty read;

begin
on exception set _error, _error_isam, _error_desc
	return _error, _error_desc;
end exception

set lock mode to wait 60;

if a_tipo = 1 then -- Reclamo

	update recrcmae set subir_bo = 1 where no_reclamo = a_no_reclamo;
	update recrccob set subir_bo = 1 where no_reclamo = a_no_reclamo;
	update reccoas  set subir_bo = 1 where no_reclamo = a_no_reclamo;
	update recreaco set subir_bo = 1 where no_reclamo = a_no_reclamo;

end if

update rectrmae set subir_bo = 1 where no_tranrec = a_no_tranrec;
update rectrcob set subir_bo = 1 where no_tranrec = a_no_tranrec;
update rectrrea set subir_bo = 1 where no_tranrec = a_no_tranrec;
update rectrcon set subir_bo = 1 where no_tranrec = a_no_tranrec;

set isolation to dirty read;

end

return 0, "Actualizacion Exitosa..."; 

end procedure