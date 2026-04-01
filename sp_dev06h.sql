-- Procedimiento que actualiza los número de pagos de endosos de pólizas que no han tenido plan pago.
-- Creado: 30/05/2017 - Autor: Román Gordón
-- execute procedure sp_dev06h('01/01/2025','31/08/2025');

drop procedure sp_dev06h;
create procedure sp_dev06h(a_fecha_desde date, a_fecha_hasta date)
returning	char(20)		as poliza,
			date			as fecha_desde,
			date			as fecha_hasta,
			date			as vigencia_final,
			date			as date_added,
			date			as fecha_cancelacion,
			smallint		as activo,
			date			as min_fecha_creacion,
			date			as last_update;

define _mensaje				varchar(100);
define _no_documento			char(20);
define _no_poliza				char(10);
define _cod_endomov			char(3);
define _prima_diaria_acum	dec(16,2);
define _monto_devolucion		dec(16,2);
define _monto_cobrado			dec(16,2);
define _prima_diaria			dec(16,2);
define _prima_bruta			dec(16,2);
define _dif_prima				dec(16,2);
define _dias_vigencia			integer;
define _error_isam			integer;
define _contador				integer;
define _error					integer;
define _activo					smallint;
define _min_fecha_creacion	date;
define _fecha_cancelacion	date;
define _fecha_suspension		date;
define _vigencia_final		date;
define _fecha_desde			date;
define _fecha_hasta			date;
define _date_added			date;
define _update					date;
define _null					date;
define _fecha_hoy				datetime year to second;

set isolation to dirty read;

--set debug file to "sp_dev06h.trc";
--trace on;

--Query para crear la temporal

let _null = null;

begin
on exception set _error,_error_isam,_mensaje
return _mensaje,
		_null,
		_null,
		_null,
		_null,
		_null,
		_error,
		_null,
		_null;
end exception

foreach
	select ley.no_documento,
		    ley.fecha_desde,
			max(ley.fecha_hasta),
			pol.vigencia_fin,
			max(ley.date_added),
			ley.fecha_cancelacion,
			ley.activo,
			min(ley.date_added),
			max(ley.last_update)
	  into _no_documento,
		    _fecha_desde,
			_fecha_hasta,
			_vigencia_final,
			_date_added,
			_fecha_cancelacion,
			_activo,
			_min_fecha_creacion,
			_update
	  from leysuscob ley
	 inner join emipoliza pol on pol.no_documento = ley.no_documento
	 where date(date_added) between a_fecha_desde and a_fecha_hasta
	 group by ley.no_documento,ley.fecha_desde,ley.fecha_cancelacion,ley.activo,pol.vigencia_fin

	return	_no_documento,
		    _fecha_desde,
			_fecha_hasta,
			_vigencia_final,
			_date_added,
			_fecha_cancelacion,
			_activo,
			_min_fecha_creacion,
			_update with resume;
end foreach
end
end procedure;