-- Recuperos Nuevos que se Cobran por el Call Center
--
-- Creado    : 15/03/2006 - Autor: Armando Moreno M.
-- Modificado: 15/03/2006 - Autor: Armando Moreno M.

-- SIS v.2.0 - DEIVID, S.A.

drop procedure sp_rec116;

create procedure "informix".sp_rec116(a_cod_pagador char(10),a_numrecla char(18))
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
define _apagar			dec(16,2);

set isolation to dirty read;

begin
on exception set _error
	return _error;
end exception

select count(*)
  into _cantidad
  from cascliente 
 where cod_cliente = a_cod_pagador;

if _cantidad = 0 then

	let _cod_cobrador   = "001"; --sp_cas006(_cod_sucursal, 1);
	let _cliente_nuevo  = 0;
	let _ultima_gestion = "RECOBRO NUEVO - PRIMERA GESTION ...";

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
	a_cod_pagador,
	0,
	0,
	_cod_cobrador,
	0,
	today,
	null,
	0,
	null,
	_ultima_gestion
	);

	--call sp_cas001(_cod_pagador);

else

	let _cliente_nuevo = 0;

end if

select count(*)
  into _cantidad
  from caspoliza
 where no_documento = a_numrecla;

if _cantidad = 0 then

	if _cliente_nuevo = 0 then

		update cascliente
		   set ultima_gestion = "RECOBRO NUEVO PARA GESTION, NUMERO: " || a_numrecla
		 where cod_cliente    = a_cod_pagador;

	end if

	let _apagar = 0.00;

	select monto_arreglo/no_pagos
	  into _apagar
	  from recrecup
	 where numrecla = a_numrecla;

	 if _apagar = 0 or _apagar is null then
		return 1;
	 end if

	insert into caspoliza(
	no_documento,
	cod_cliente,
	dia_cobros1,
	dia_cobros2,
	tipo_mov,
	a_pagar
	)
	values(
	a_numrecla,
	a_cod_pagador,
	0,
	0,
	'R',
	_apagar
	);

end if

end

return 0;
end procedure
