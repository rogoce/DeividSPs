-- Endosos de Cancelacion por Periodo de Vigencia
-- 
-- Creado    : 12/08/2003 - Autor: Demetrio Hurtado Almanza
-- Modificado: 12/08/2003 - Autor: Demetrio Hurtado Almanza

drop procedure sp_ger001;

create procedure "informix".sp_ger001(a_compania char(3), a_sucursal char(3), a_periodo char(7))
returning char(7),
          dec(16,2),
          char(3),
          char(50),
          char(50);
  
define _prima_suscrita	dec(16,2);
define _no_poliza		char(10);
define _cod_ramo		char(3);
define _vigencia_inic	date;
define _vigencia_final	date;
define _no_factura		char(10);
define _meses			smallint;
define _prima_mensual	dec(16,2);
define _i_cont			smallint;
define _fecha_suma		date;
define _periodo			char(7);
define _nombre_ramo		char(50);
define _nombre_compania	char(50);

--define _error			integer;

let _nombre_compania = sp_sis01(a_compania);

create temp table tmp_reserva(
	cod_ramo	char(3),
	periodo		char(7),
	prima		dec(16,2)
	) with no log;

{
begin
on exception set _error
	return "",
	       0.00,
		   "",
		   _no_factura,
		   _nombre_compania;
end exception
}

--set debug file to "sp_ger001.trc";
--trace on;

foreach
 select prima_suscrita,
        no_poliza,
		vigencia_inic,
		vigencia_final,
		no_factura
   into	_prima_suscrita,
        _no_poliza,
		_vigencia_inic,
		_vigencia_final,
		_no_factura
   from endedmae
  where actualizado = 1
    and cod_endomov = "002"
	and periodo    >= a_periodo
	and periodo    <= a_periodo
--	and no_factura  = "01-230090"

	select cod_ramo
	  into _cod_ramo
	  from emipomae
	 where no_poliza = _no_poliza;

	let _vigencia_inic  = mdy(month(_vigencia_inic),  1, year(_vigencia_inic));
	let _vigencia_final = mdy(month(_vigencia_final), 1, year(_vigencia_final));

	let _meses = (year(_vigencia_final) * 12 + month(_vigencia_final)) - 
	             (year(_vigencia_inic)  * 12 + month(_vigencia_inic));

	if _meses = 0 then
		let _meses = 1;
	end if

	let _prima_mensual = _prima_suscrita / _meses;
	let _fecha_suma    = _vigencia_inic;

	for _i_cont = 1 to _meses
		
		if month(_fecha_suma) < 10 then
			let _periodo = year(_fecha_suma) || "-0" || month(_fecha_suma);
		else
			let _periodo = year(_fecha_suma) || "-" || month(_fecha_suma);
		end if
				

		insert into tmp_reserva
		values (_cod_ramo, _periodo, _prima_mensual);

		let _fecha_suma = _fecha_suma + 1 units month;

	end for

end foreach

--end 

foreach
 select cod_ramo,
        periodo,
		sum(prima)
   into _cod_ramo,
        _periodo,
		_prima_mensual
   from tmp_reserva
  group by 1, 2
  order by 1, 2

	select nombre
	  into _nombre_ramo
	  from prdramo
	 where cod_ramo = _cod_ramo;

	return _periodo,
	       _prima_mensual,
		   _cod_ramo,
		   _nombre_ramo,
		   _nombre_compania
		   with resume;

end foreach

drop table tmp_reserva;

end procedure;


