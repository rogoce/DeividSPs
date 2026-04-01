-- Reporte de la Prima Devengada para una Poliza

--drop procedure sp_dev03;

create procedure sp_dev03(
a_documento	char(20),
a_fecha 		date		default today
) returning integer,
			 char(50);
		   
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

begin 
on exception set _error, _error_isam, _error_desc
	return _error, _error_desc;
end exception

create temp table tmp_prima_devengada(
no_documento		char(20),
no_factura			char(10),
vigencia_inic		date,
vigencia_final		date,
prima_suscrita		dec(16,2),
dias_vigencia		integer,
prima_diaria		dec(16,6),
dias_prorrata		integer,
prima_devengada	dec(16,2),
condicion			integer
) with no log;

select min(vigencia_inic)
  into _fecha_ini
  from emipomae
 where no_documento 	= a_documento
   and actualizado 	= 1;
  
let _cantidad	= 0;

foreach
 select no_documento,
         no_factura,
		 vigencia_inic,
		 vigencia_final,
		 prima_suscrita
   into _no_documento,
        _no_factura,
		_vigencia_inic,
		_vigencia_final,
		_prima_suscrita
   from endedmae
  where (
			(vigencia_inic <= _fecha_ini 	and vigencia_final >  _fecha_ini)	or
			(vigencia_inic >= _fecha_ini 	and vigencia_final <= a_fecha)	or
			(vigencia_inic <= a_fecha		and vigencia_final >= a_fecha)
		 )
    and actualizado 		= 1
	and no_documento		= a_documento
  order by vigencia_inic, vigencia_final		 

		if _prima_suscrita = 0 then
			continue foreach;
		end if
		
		let _cantidad		= _cantidad + 1;
		let _dias_vigencia	= _vigencia_final - _vigencia_inic;
		
		if _dias_vigencia <= 0 then
			let _dias_vigencia = 1;
		end if

		let _prima_diaria 	= _prima_suscrita / _dias_vigencia;
		
		if _vigencia_final <= _vigencia_inic then
			let _dias_prorrata	= 1;
			let _condicion		= 1;
		elif _vigencia_inic <= _fecha_ini and _vigencia_final <= a_fecha then
			let _dias_prorrata	= _vigencia_final - _fecha_ini;
			let _condicion		= 2;
		elif _vigencia_inic <= _fecha_ini and _vigencia_final > a_fecha then
			let _dias_prorrata	= a_fecha - _fecha_ini;
			let _condicion		= 3;
		elif _vigencia_inic > _fecha_ini and _vigencia_final <= a_fecha then
			let _dias_prorrata	= _vigencia_final - _vigencia_inic;
			let _condicion		= 4;
		elif _vigencia_inic > _fecha_ini and _vigencia_final > a_fecha then
			let _dias_prorrata	= a_fecha - _vigencia_inic;
			let _condicion		= 5;
		else
			let _dias_prorrata	= 1;
			let _condicion		= 6;
		end if
		
		let _prima_devengada = _prima_diaria * _dias_prorrata;

		insert into tmp_prima_devengada
		values (_no_documento,
		        _no_factura,
				_vigencia_inic,
				_vigencia_final,
				_prima_suscrita,
				_dias_vigencia,
				_prima_diaria,
				_dias_prorrata,
				_prima_devengada,
				_condicion
				);
				
end foreach

end

return 0, "Actualizacion Exitosa";

end procedure

