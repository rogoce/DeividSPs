-- Procedimiento que genera el detalle de las cuentas afectadas en SAC
-- 
-- Creado     : 24/12/2004 - Autor: Marquelda Valdelamar
--
-- SIS v.2.0 - DEIVID, S.A.

DROP PROCEDURE sp_sac28;		

CREATE PROCEDURE "informix".sp_sac28(a_periodo1 char(7), a_periodo2 char(7), a_cuenta char(25))
returning char(20),
	      char(10),
		  dec(16,2),
		  dec(16,2),
		  smallint,
		  char(25);

define _no_documento	char(20);
define _no_factura		char(10);

define _debito			dec(16,2);
define _credito			dec(16,2);
define _origen			char(3);
define _tipo_comp		smallint;			
define _cuenta			char(25);

let a_cuenta = trim(a_cuenta) || "%";

set isolation to dirty read;

foreach
 select e.no_documento,
		e.no_factura,
		a.debito,
		a.credito,
		a.tipo_comp,
		a.cuenta
   into	_no_documento,
		_no_factura,
		_debito,
		_credito,
		_tipo_comp,
		_cuenta
   from endedmae e, endasien a
  where e.periodo   >= a_periodo1
    and e.periodo   <= a_periodo2
	and e.no_poliza = a.no_poliza
	and e.no_endoso = a.no_endoso
	and a.cuenta    like a_cuenta
	and e.cod_tipocan = "013"

	return _no_documento,
	       _no_factura,
		   _debito,
		   _credito,
		   _tipo_comp,
		   _cuenta
		   with resume;

end foreach

end procedure