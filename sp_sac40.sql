-- Procedure que verifica que hay comprobantes pendientes de postear

-- Creado    : 01/08/2005 - Autor: Demetrio Hurtado Almanza 

-- SIS v.2.0 - DEIVID, S.A.

drop procedure sp_sac40;

create procedure "informix".sp_sac40()
returning integer;

define _cantidad	integer;
define _cant_total	integer;

--set debug file to "sp_sac39.trc";
--trace on;

set isolation to dirty read;

let _cant_total = 0;

select count(*)
  into _cantidad
  from sac:cgltrx1;

let _cant_total = _cant_total + _cantidad;

select count(*)
  into _cantidad
  from sac001:cgltrx1;

let _cant_total = _cant_total + _cantidad;

select count(*)
  into _cantidad
  from sac002:cgltrx1;

let _cant_total = _cant_total + _cantidad;

select count(*)
  into _cantidad
  from sac003:cgltrx1;

let _cant_total = _cant_total + _cantidad;

select count(*)
  into _cantidad
  from sac004:cgltrx1;

let _cant_total = _cant_total + _cantidad;

select count(*)
  into _cantidad
  from sac005:cgltrx1;

let _cant_total = _cant_total + _cantidad;

select count(*)
  into _cantidad
  from sac006:cgltrx1;

let _cant_total = _cant_total + _cantidad;

select count(*)
  into _cantidad
  from sac007:cgltrx1;

let _cant_total = _cant_total + _cantidad;

select count(*)
  into _cantidad
  from sac008:cgltrx1;

let _cant_total = _cant_total + _cantidad;

return _cant_total;

end procedure
