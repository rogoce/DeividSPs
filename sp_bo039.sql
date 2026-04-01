-- Procedimiento que crea las tablas para la carga de los estados financieros
-- Los Auxliliares de SAC

-- Creado    : 14/10/2005 - Autor: Demetrio Hurtado Almanza

-- SIS v.2.0 - DEIVID, S.A.

DROP PROCEDURE sp_bo039;

create procedure "informix".sp_bo039()
returning integer,
          char(50);

define _error		integer;
define _error_isam	integer;
define _error_desc	char(50);

define _enlace 		char(10);
define _cuenta		char(12);
define _recibe  	char(1);
define _cia_comp	char(3);

set isolation to dirty read;

begin 
on exception set _error, _error_isam, _error_desc
	return _error, _error_desc;
end exception

-- Conversion de los Saldos de todas las companias

-- Terceros y Auxiliares

delete from ef_cglterceros;
delete from ef_saldoaux;

let _cia_comp = sp_bo050("sac");

insert into ef_saldoaux    
select *, "001", _cia_comp
  from sac:cglsaldoaux1;

insert into ef_cglterceros
select ter_codigo, ter_descripcion, ter_contacto, ter_cedula, ter_telefono, ter_fax, ter_apartado, ter_observacion, ter_limites, ter_codcliente, _cia_comp
  from sac:cglterceros;

let _cia_comp = sp_bo050("sac001");

insert into ef_saldoaux    
select *, "001", _cia_comp    
  from sac001:cglsaldoaux1;

insert into ef_cglterceros
select *, _cia_comp
  from sac001:cglterceros;

let _cia_comp = sp_bo050("sac002");

insert into ef_saldoaux    
select *, "001", _cia_comp
  from sac002:cglsaldoaux1;

insert into ef_cglterceros
select *, _cia_comp
  from sac002:cglterceros;

let _cia_comp = sp_bo050("sac006");

insert into ef_saldoaux    
select *, "001", _cia_comp
  from sac006:cglsaldoaux1;

insert into ef_cglterceros
select *, _cia_comp
  from sac006:cglterceros;

{
let _cia_comp = sp_bo050("sac003");

insert into ef_saldoaux    
select *, "001", _cia_comp
  from sac003:cglsaldoaux1;

let _cia_comp = sp_bo050("sac004");

insert into ef_saldoaux    
select *, "001", _cia_comp
  from sac004:cglsaldoaux1;

let _cia_comp = sp_bo050("sac005");

insert into ef_saldoaux    
select *, "001", _cia_comp
  from sac005:cglsaldoaux1;


let _cia_comp = sp_bo050("sac007");

insert into ef_saldoaux    
select *, "001", _cia_comp
  from sac007:cglsaldoaux1;

let _cia_comp = sp_bo050("sac008");

insert into ef_saldoaux    
select *, "001", _cia_comp
  from sac008:cglsaldoaux1;
}

end

return 0, "Actualizacion Exitosa";

end procedure