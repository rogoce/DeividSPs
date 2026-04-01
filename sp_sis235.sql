-- Procedimiento que actualiza los número de pagos de endosos de pólizas que no han tenido plan pago.
-- Creado: 30/05/2017 - Autor: Román Gordón

drop procedure sp_sis235;
create procedure sp_sis235(a_no_poliza char(10))
returning	smallint		as cod_error,
			varchar(100)	as poliza;

define _mensaje				varchar(100);
define _no_poliza			char(10);
define _no_unidad			char(5);
define _porc_proporcion		dec(10,6);
define _prima_total			dec(16,2);
define _prima_neta			dec(16,2);
define _no_pagos_emi		smallint;
define _error_isam			integer;
define _error				integer;
define _date_added			date;

set isolation to dirty read;

--set debug file to "sp_sis235.trc";
--trace on;

--Query para crear la temporal

begin
on exception set _error,_error_isam,_mensaje
end exception

drop table if exists tmp_dist_uni;
create temp table tmp_dist_uni(
no_poliza		char(10),
no_unidad		char(5),
porc_proporcion	dec(10,6)) with no log;

select sum(prima_neta)
  into _prima_total
  from emipouni
 where no_poliza = a_no_poliza;

foreach
	select no_unidad,
		   prima_neta
	  into _no_unidad,
		   _prima_neta
	  from emipouni
	 where no_poliza = a_no_poliza
	   --and activo = 1

	let _porc_proporcion = _prima_neta/_prima_total;

	insert into tmp_dist_uni
	values(a_no_poliza,_no_unidad,_porc_proporcion);
end foreach


return 0,'Actualización Exitosa';
end
end procedure;