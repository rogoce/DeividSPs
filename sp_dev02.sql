-- Procedimiento que calcula la Prima Devengada para una Poliza

drop procedure sp_dev02;

create procedure sp_dev02(
a_documento	char(20),
a_fecha 		date		default today
) returning char(20),
           char(10),
		   date,
		   date,
		   dec(16,2),
		   integer,
		   dec(16,6),
		   integer,
		   dec(16,2),
		   integer;
		   
define _no_documento		char(20);
define _no_factura			char(10);
define _vigencia_inic		date;
define _vigencia_final	date;
define _prima_suscrita	dec(16,2);
define _prima_devengada	dec(16,2);
define _prima_diaria		dec(16,6);
define _dias_vigencia		integer;
define _dias_prorrata		integer;

define _fecha_ini			date;
define _cantidad			integer;
define _condicion			integer;

define _error				integer;
define _error_isam			integer;
define _error_desc			char(50);

let _cantidad = 0;

call sp_dev03(a_documento, a_fecha) returning _error, _error_desc;

select min(vigencia_inic)
  into _fecha_ini
  from tmp_prima_devengada;
  
foreach
 select no_documento,
		no_factura,
		vigencia_inic,
		vigencia_final,
		prima_suscrita,
		dias_vigencia,
		prima_diaria,
		dias_prorrata,
		prima_devengada,
		condicion
   into _no_documento,
		_no_factura,
		_vigencia_inic,
		_vigencia_final,
		_prima_suscrita,
		_dias_vigencia,
		_prima_diaria,
		_dias_prorrata,
		_prima_devengada,
		_condicion
   from tmp_prima_devengada

		let _cantidad = _cantidad + 1;

		return _no_documento,
				_no_factura,
				_vigencia_inic,
				_vigencia_final,
				_prima_suscrita,
				_dias_vigencia,
				_prima_diaria,
				_dias_prorrata,
				_prima_devengada,
				_condicion
				with resume;
				
end foreach

drop table tmp_prima_devengada;

return "",
		"",
		_fecha_ini,
		a_fecha,
		0,
		0,
		0,
		0,
		0,
		_cantidad
		with resume;
  
end procedure

