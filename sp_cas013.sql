-- Procedimiento que retorna la cantidad de registros a procesar
-- Creado    : 08/05/2003 - Autor: Demetrio Hurtado Almanza
-- Modificado: 08/05/2003 - Autor: Demetrio Hurtado Almanza
-- SIS v.2.0 - DEIVID, S.A.

drop procedure sp_cas013;
create procedure sp_cas013(a_cobrador CHAR(3))
returning smallint,
		  smallint,
		  smallint,
		  smallint,
		  smallint,
		  smallint;

define _total		smallint; 
define _atendidos	smallint; 
define _pendientes	smallint; 
define _atrazados	smallint;
define _nuevos		smallint;
define _extra		smallint;
define _fecha		date;

set isolation to dirty read;

select fecha_ult_pro
  into _fecha
  from cobcobra
 where cod_cobrador = a_cobrador
   and activo = 1;

select total, 
	   atendidos, 
	   pendientes, 
	   nuevos, 
	   atrazados,
	   extra
  into _total, 
	   _atendidos, 
	   _pendientes, 
	   _nuevos, 
	   _atrazados,
	   _extra
  from cobcadate
 where cod_cobrador = a_cobrador
   and fecha        = _fecha;

return _total, 
	   _atendidos, 
	   _pendientes, 
	   _nuevos, 
	   _atrazados,
	   _extra;
end procedure;