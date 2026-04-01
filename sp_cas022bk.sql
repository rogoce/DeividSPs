-- Polizas Nuevas que se Pagan por el Call Center
--
-- Creado    : 27/05/2003 - Autor: Demetrio Hurtado Almanza
-- Modificado: 27/05/2003 - Autor: Demetrio Hurtado Almanza
-- Modificado: 28/10/2010 - Autor: Roman Gordon  * Adaptacion a Cobros por Campaña las cuales seran asignadas a la campaña "Polizas Nuevas"
-- SIS v.2.0 - DEIVID, S.A.

drop procedure sp_cas022bk;

create procedure "informix".sp_cas022bk(a_no_poliza char(10))
returning smallint;

define _cod_pagador		char(10);
define _cobra_poliza	char(1);
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
define _modo_callcenter char(1);

set isolation to dirty read;

begin
on exception set _error
	return _error;
end exception

select cod_pagador,
       cobra_poliza,
	   dia_cobros1,
	   dia_cobros2,
	   sucursal_origen,
	   no_documento,
	   day(fecha_primer_pago),
	   cod_tipoprod,
	   estatus_poliza
  into _cod_pagador,
       _cobra_poliza,
	   _dia_cobros1,
	   _dia_cobros2,
	   _sucursal_origen,
	   _no_documento,
	   _dia_cobros4,
	   _cod_tipoprod,
	   _estatus_poliza
  from emipomae
 where no_poliza = a_no_poliza;

{if _cobra_poliza <> "E" Then
	return 0;
end if}

if _cod_tipoprod = "002" or	_cod_tipoprod = "004" then
	return 0;
end if
--se asigna suc 001 si es colon y chiriqui, para que sean trabajados por gestores de casa matriz. armando 18/11/2008
if _sucursal_origen = "002" then
--	let _cod_sucursal = _sucursal_origen;
	let _cod_sucursal = '001';
elif _sucursal_origen = "003" then
--	let _cod_sucursal = _sucursal_origen;
	let _cod_sucursal = '001';
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
	ultima_gestion
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
	_ultima_gestion
	);

	call sp_cas001(_cod_pagador);

	select modo_callcenter
	  into _modo_callcenter
	  from parparam
	 where cod_compania = '001';

	if _modo_callcenter = "1" then --por morosidad
		
		insert into cobcapen(
		cod_cliente,
		cod_cobrador,
		nuevo,
		por_vencer,
		exigible,
		corriente,
		monto_30,
		monto_60,
		monto_90,
		saldo
		)
		values (
		_cod_pagador,
		_cod_cobrador,
		1,
		0,
		0,  
		0,
		0,  
		0,  
		0,
		0
		);

	end if

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
		 where cod_cliente    = _cod_pagador
		   and cod_campana	  = '00001' ;

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
	'00001'
	);

end if

end

return 0;

end procedure
