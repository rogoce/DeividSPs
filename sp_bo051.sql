-- Procedimiento que convierte la tabla de los centros de costos

-- Creado    : 21/11/2008 - Autor: Demetrio Hurtado Almanza

-- SIS v.2.0 - DEIVID, S.A.

DROP PROCEDURE sp_bo051;

create procedure "informix".sp_bo051()
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


delete from sac999:ef_cglcentro;
delete from sac999:cglperiodo;

-- Centros de Costos

insert into sac999:ef_cglcentro    
select cen_codigo,
	   cen_descripcion,
	   "001"
  from sac:cglcentro;

insert into sac999:ef_cglcentro    
select cen_codigo,
	   cen_descripcion,
	   "002"
  from sac001:cglcentro;

insert into sac999:ef_cglcentro    
select cen_codigo,
	   cen_descripcion,
	   "003"
  from sac002:cglcentro;

insert into sac999:ef_cglcentro    
select cen_codigo,
	   cen_descripcion,
	   "007"
  from sac006:cglcentro;

{
let _cia_comp   = sp_bo050("sac003");

insert into sac999:ef_cglcentro    
select cen_codigo,
	   cen_descripcion,
	   _cia_comp
  from sac003:cglcentro;

let _cia_comp   = sp_bo050("sac004");

insert into sac999:ef_cglcentro    
select cen_codigo,
	   cen_descripcion,
	   _cia_comp
  from sac004:cglcentro;

let _cia_comp   = sp_bo050("sac005");

insert into sac999:ef_cglcentro    
select cen_codigo,
	   cen_descripcion,
	   _cia_comp
  from sac005:cglcentro;


let _cia_comp   = sp_bo050("sac007");

insert into sac999:ef_cglcentro    
select cen_codigo,
	   cen_descripcion,
	   _cia_comp
  from sac007:cglcentro;

let _cia_comp   = sp_bo050("sac008");

insert into sac999:ef_cglcentro    
select cen_codigo,
	   cen_descripcion,
	   _cia_comp
  from sac008:cglcentro;
}

-- Periodos

insert into sac999:cglperiodo
select *, per_mes
  from sac:cglperiodo; 

end

return 0, "Actualizacion Exitosa";

end procedure