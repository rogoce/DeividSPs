-- Procedimiento que determina las variables para el descuento por siniestralidad

-- Tarifas Agosto 2015

drop procedure sp_rec278;

create procedure "informix".sp_rec278(
a_no_documento		char(20)
) returning dec(16,2), dec(16,2), dec(16,2);

define _no_poliza			char(10);
define _fecha_proceso		date;
define _no_reclamo			char(10);
define _vigencia_inic		date;

define _cant_p				smallint;
define _cant_x_def			smallint;
define _cant_total			smallint;

define _no_sinis_ult		smallint;
define _no_sinis_his		smallint;
define _no_vigencias		dec(16,2);
define _no_sinis_pro		dec(16,2);

define _incurrido_bruto	dec(16,2);
define _prima_devengada	dec(16,2);
define _siniestralidad	dec(16,2);
define _incurrido			dec(16,2);
define _porc_descuento	dec(16,2);
define _tipo           smallint;

define _error				integer;
define _error_isam			integer;
define _error_desc			char(50);

let _fecha_proceso = today;

-- Numero de Siniestros Ultima Vigencia

--SET DEBUG FILE TO "sp_rec278.trc";
--TRACE ON;
--let _no_poliza = sp_sis21(a_no_documento);

	
let _incurrido_bruto = 0;
let _siniestralidad = 0;

foreach
 select no_reclamo
   into _no_reclamo
   from recrcmae
  where no_documento 		= a_no_documento
	and actualizado 		= 1

	let _incurrido 		= sp_rec255(_no_reclamo);
	let _incurrido_bruto	= _incurrido_bruto + _incurrido;
	
end foreach

-- Calculo de la Prima Devengada

call sp_dev03(a_no_documento, _fecha_proceso) returning _error, _error_desc;

select sum(prima_devengada)
  into _prima_devengada
  from tmp_prima_devengada;
  
drop table tmp_prima_devengada;

-- Siniestralidad

let _siniestralidad = (_incurrido_bruto / _prima_devengada) * 100;

--call sp_pro549(_no_sinis_ult, _no_sinis_pro, _siniestralidad) returning _porc_descuento, _tipo;

return _prima_devengada, _incurrido_bruto, _siniestralidad;
		   
end procedure

