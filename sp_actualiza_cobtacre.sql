-- Procedimiento para la Insercion Inicial de Polizas para el sistema de Cobros por Campana
-- Creado    : 04/10/2010- Autor: Roman Gordon
-- SIS v.2.0 - DEIVID, S.A.

drop procedure sp_actualiza_cobtacre;

create procedure sp_actualiza_cobtacre()
returning	integer,
			char(100);

define _no_documento	char(21);
define _no_tarjeta		char(21);
define _no_poliza		char(10);
define _nueva_renov		char(1);
define _monto_a_cobrar	dec(16,2);
define _error			smallint;
define _cnt				smallint;

on exception set _error
	return _error, "Error al Ingresar los Registro";
end exception  

--set debug file to "sp_cas113.trc";
--trace on;

set isolation to dirty read;

foreach
	select no_tarjeta,
		   no_documento,
		   monto
	  into _no_tarjeta,
		   _no_documento,
		   _monto_a_cobrar
	  from cobtatra
	 where procesar = 0

	update cobtacre
	   set monto_a_cobrar = _monto_a_cobrar
	 where no_tarjeta = _no_tarjeta
	   and no_documento = _no_documento;	  
end foreach
end procedure;