-- Procedure que Carga los Reclamos Pagados para PBI

-- Creado:	05/12/2023	Autor: Armando Moreno M.

drop procedure sp_rec135a;
create procedure sp_rec135a(_periodo_trab char(7))
returning integer, char(50);

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

-- Reclamos Pagados

LET _filtros = sp_rec704('001','001', _periodo_trab,_periodo_trab,'*','*', '*','*','*','*','*','*'); 

delete from deivid_bo:recrespa
 where periodo = _periodo_trab;

foreach
	select no_reclamo,
	       pagado_total,
	       pagado_bruto,
	       pagado_neto
	  into _no_reclamo,
	       _pagado_total,
	       _pagado_bruto,
	       _pagado_neto
	  from tmp_sinis

	insert into deivid_bo:recrespa(
	no_reclamo,
	periodo,
	pagado_total,
	pagado_bruto,
	pagado_neto,
	subir_bo
	)
	values(
	_no_reclamo,
	_periodo_trab,
	_pagado_total,
	_pagado_bruto,
	_pagado_neto,
	1
	);

end foreach
drop table tmp_sinis;
end
return 0, "Actualizacion Exitosa";
end procedure