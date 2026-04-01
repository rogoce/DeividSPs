-- Polizas Nuevas que se Pagan por el Call Center, pero para polizas con saldo por unidad
--
-- Creado    : 09/01/2008 - Autor: Armando Moreno
-- Modificado: 09/01/2008 - Autor: Armando Moreno
-- Modificado: 28/10/2010 - Autor: Roman Gordon

-- SIS v.2.0 - DEIVID, S.A.

drop procedure sp_cas022abk;

create procedure "informix".sp_cas022abk(a_no_poliza char(10),a_no_unidad char(5))
returning smallint;

define _cod_pagador		char(10);
define _cod_tipoprod    char(3);
define _dia_cobros1		smallint;
define _dia_cobros2		smallint;
define _cod_cobrador	char(3);
define _cod_sucursal	char(3);
define _sucursal_origen	char(3);
define _no_documento	char(20);
define _estatus_poliza	char(1);
define _cantidad		smallint;
define _cliente_nuevo	smallint;
define _error			smallint;
define _dia_cobros4     smallint;
define _ultima_gestion  char(100);

set isolation to dirty read;

begin
on exception set _error
	return _error;
end exception

select sucursal_origen,
	   no_documento,
	   cod_tipoprod,
	   estatus_poliza
  into _sucursal_origen,
	   _no_documento,
	   _cod_tipoprod,
	   _estatus_poliza
  from emipomae
 where no_poliza = a_no_poliza;

if _cod_tipoprod = "002" or	_cod_tipoprod = "004" then
	return 0;
end if

select cod_pagador,
	   dia_cobros1,
	   dia_cobros2,
	   day(fecha_primer_pago)
  into _cod_pagador,
	   _dia_cobros1,
	   _dia_cobros2,
	   _dia_cobros4
  from emipouni
 where no_poliza = a_no_poliza
   and no_unidad = a_no_unidad;

if _sucursal_origen = "002" then
	let _cod_sucursal = _sucursal_origen;
elif _sucursal_origen = "003" then
	let _cod_sucursal = _sucursal_origen;
else
	let _cod_sucursal = "001";
end if

select count(*)
  into _cantidad
  from cascliente 
 where cod_cliente = _cod_pagador;

if _cantidad = 0 then

	if _dia_cobros1 = 0 then
		let _dia_cobros1 = _dia_cobros4;
	end if 

	if _estatus_poliza = 2 or _estatus_poliza = 3 then		--cancelada,vencida
		let _cod_cobrador  = sp_cas006(_cod_sucursal, 11);
		let _cliente_nuevo = 0;
		let _ultima_gestion = "PLAN DE PAGO ...";
	else
		let _cod_cobrador  = sp_cas006(_cod_sucursal, 1);
		let _cliente_nuevo = 1;
		let _ultima_gestion = "PAGADOR NUEVO - PRIMERA GESTION ...";
	end if

	insert into cascliente(
	cod_cliente,
	dia_cobros1,
	dia_cobros2,
	cod_cobrador,
	procesado,
	fecha_ult_pro,
	cod_gestion,
	dia_cobros3,
	cod_cobrador_ant,
	ultima_gestion,
	cod_campana
	)
	values(
	_cod_pagador,
	_dia_cobros1,
	_dia_cobros2,
	null,
	0,
	today,
	null,
	0,
	null,
	_ultima_gestion,
	'00001'
	);

	call sp_cas001(_cod_pagador);

else

	let _cliente_nuevo = 0;

end if

select count(*)
  into _cantidad
  from caspoliza
 where no_documento = _no_documento;

if _cantidad = 0 then

	if _cliente_nuevo = 0 then

		update cascliente
		   set ultima_gestion = "POLIZA NUEVA PARA GESTION, NUMERO: " || _no_documento
		 where cod_cliente    = _cod_pagador;

	end if

	insert into caspoliza(
	no_documento,
	cod_cliente,
	dia_cobros1,
	dia_cobros2,
	cod_campana
	)
	values(
	_no_documento,
	_cod_pagador,
	_dia_cobros1,
	_dia_cobros2,
	'0000l'
	);

end if

end

return 0;

end procedure
