-- Procedure que Carga los Reclamos Pendientes para BO

-- Creado:	06/12/2006	Autor: Demetrio Hurtado Almanza

drop procedure sp_rec135;

create procedure sp_rec135(_periodo_trab char(7))
returning integer,
          char(50);

define _periodo_cerrado	smallint;
define _filtros     	char(255);

define _no_reclamo		char(10);
define _pagado_total	dec(16,2);
define _pagado_bruto	dec(16,2);
define _pagado_neto		dec(16,2);
define _reserva_total	dec(16,2);
define _reserva_bruto	dec(16,2);
define _reserva_neto	dec(16,2);
define _incurrido_total	dec(16,2);
define _incurrido_bruto	dec(16,2);
define _incurrido_neto	dec(16,2);

define _error			integer;
define _error_isam		integer;
define _error_desc		char(50);

set isolation to dirty read;

begin
on exception set _error, _error_isam, _error_desc
	return _error, _error_desc;
end exception

-- Reclamos Pendintes

call sp_rec02("001", "001", _periodo_trab) returning _filtros;

delete from deivid_bo:recrespe
 where periodo = _periodo_trab;

foreach
 select no_reclamo,
		pagado_total,
		pagado_bruto,
		pagado_neto,
		reserva_total,
		reserva_bruto,
		reserva_neto,
		incurrido_total,
		incurrido_bruto,
		incurrido_neto
   into _no_reclamo,
		_pagado_total,
		_pagado_bruto,
		_pagado_neto,
		_reserva_total,
		_reserva_bruto,
		_reserva_neto,
		_incurrido_total,
		_incurrido_bruto,
		_incurrido_neto
   from tmp_sinis

	insert into deivid_bo:recrespe(
	no_reclamo,
	periodo,
	pagado_total,
	pagado_bruto,
	pagado_neto,
	reserva_total,
	reserva_bruta,
	reserva_neta,
	incurrido_total,
	incurrido_bruto,
	incurrido_neto,
	subir_bo
	)
	values(
	_no_reclamo,
	_periodo_trab,
	_pagado_total,
	_pagado_bruto,
	_pagado_neto,
	_reserva_total,
	_reserva_bruto,
	_reserva_neto,
	_incurrido_total,
	_incurrido_bruto,
	_incurrido_neto,
	1
	);

end foreach
drop table tmp_sinis;
end
return 0, "Actualizacion Exitosa";
end procedure