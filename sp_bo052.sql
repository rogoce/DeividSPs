-- Procedimiento que crea los centros de costos iniciales

-- Creado    : 25/11/2008 - Autor: Demetrio Hurtado Almanza

-- SIS v.2.0 - DEIVID, S.A.

--DROP PROCEDURE sp_bo052;

create procedure "informix".sp_bo052()
returning integer,
          char(50);

define _error		integer;
define _error_isam	integer;
define _error_desc	char(50);

define _cia_comp	char(3);

set isolation to dirty read;

begin 
on exception set _error, _error_isam, _error_desc
	return _error, _error_desc;
end exception

-- Centros de Costos

let _cia_comp = sp_bo050("sac");

insert into sac:cglcentro
values (_cia_comp, "ADMINISTRACION");

let _cia_comp = sp_bo050("sac001");

insert into sac001:cglcentro
values (_cia_comp, "ADMINISTRACION");

let _cia_comp = sp_bo050("sac002");

insert into sac002:cglcentro
values (_cia_comp, "ADMINISTRACION");

let _cia_comp = sp_bo050("sac003");

insert into sac003:cglcentro
values (_cia_comp, "ADMINISTRACION");

let _cia_comp = sp_bo050("sac004");

insert into sac004:cglcentro
values (_cia_comp, "ADMINISTRACION");

let _cia_comp = sp_bo050("sac005");

insert into sac005:cglcentro
values (_cia_comp, "ADMINISTRACION");

let _cia_comp = sp_bo050("sac006");

insert into sac006:cglcentro
values (_cia_comp, "ADMINISTRACION");

let _cia_comp = sp_bo050("sac007");

insert into sac007:cglcentro
values (_cia_comp, "ADMINISTRACION");

let _cia_comp = sp_bo050("sac008");

insert into sac008:cglcentro
values (_cia_comp, "ADMINISTRACION");

end

return 0, "Actualizacion Exitosa";

end procedure