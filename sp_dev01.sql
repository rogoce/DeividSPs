-- Procedimiento que calcula la Prima Devengada

drop procedure sp_dev01;

create procedure sp_dev01(
a_fecha_desde	date,
a_fecha_hasta 	date
) returning integer,
			char(50);
 
define _no_documento		char(20);
define _no_factura			char(10);
define _no_poliza			char(10);
define _vigencia_inic		date;
define _vigencia_final	date;
define _prima_suscrita	dec(16,2);
define _prima_devengada	dec(16,2);
define _prima_diaria		dec(16,6);
define _dias_vigencia		integer;
define _dias_prorrata		integer;
define _cod_ramo			char(3);

define _condicion			integer;

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
);
CREATE INDEX ii_perfil11 ON tmp_prima_devengada(no_documento);

let a_fecha_desde 	= a_fecha_desde - 1;

foreach
 select no_documento,
         no_factura,
		 vigencia_inic,
		 vigencia_final,
		 prima_suscrita,
		 no_poliza
   into _no_documento,
        _no_factura,
		_vigencia_inic,
		_vigencia_final,
		_prima_suscrita,
		_no_poliza
   from endedmae
  where (
			(vigencia_inic <= a_fecha_desde 	and vigencia_final >  a_fecha_desde)	or
			(vigencia_inic >= a_fecha_desde 	and vigencia_final <= a_fecha_hasta)	or
			(vigencia_inic <= a_fecha_hasta	and vigencia_final >= a_fecha_hasta)
		 )
    and actualizado 		= 1
  order by vigencia_inic, vigencia_final		 

		if _prima_suscrita = 0 then
			continue foreach;
		end if
		
		let _dias_vigencia	= _vigencia_final - _vigencia_inic;
		
		if _dias_vigencia <= 0 then
			let _dias_vigencia = 1;
		end if

		let _prima_diaria 	= _prima_suscrita / _dias_vigencia;
		
		if _vigencia_final <= _vigencia_inic then
			let _dias_prorrata	= 1;
			let _condicion		= 1;
		elif _vigencia_inic <= a_fecha_desde and _vigencia_final <= a_fecha_hasta then
			let _dias_prorrata	= _vigencia_final - a_fecha_desde;
			let _condicion		= 2;
		elif _vigencia_inic <= a_fecha_desde and _vigencia_final > a_fecha_hasta then
			let _dias_prorrata	= a_fecha_hasta - a_fecha_desde;
			let _condicion		= 3;
		elif _vigencia_inic > a_fecha_desde and _vigencia_final <= a_fecha_hasta then
			let _dias_prorrata	= _vigencia_final - _vigencia_inic;
			let _condicion		= 4;
		elif _vigencia_inic > a_fecha_desde and _vigencia_final > a_fecha_hasta then
			let _dias_prorrata	= a_fecha_hasta - _vigencia_inic;
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

return 0, "Actualizacion Exitosa";
  
end procedure

