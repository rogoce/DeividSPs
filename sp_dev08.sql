-- Primas devengadas POLIZAS NUEVAS Y RENOVADAS
-- Procedimiento que actualiza los número de pagos de endosos de pólizas que no han tenido plan pago.
-- Creado: 30/05/2017 - Autor: Román Gordón

drop procedure sp_dev08;
create procedure sp_dev08(a_no_poliza char(10))
returning	smallint		as cod_error;

define a_no_documento 		char(20);
define _prima_diaria_acum	dec(16,2);
define _prima_diaria		dec(16,2);
define _prima_bruta			dec(16,2);
define _dif_prima			dec(16,2);
define _prima_dev_neta      dec(16,2);
define _prima_dia_acum_n    dec(16,2);
define _prima_dn            dec(16,2);
define _dias_vigencia		integer;
define _error_isam			integer;
define _contador			integer;
define _error				integer;
define _vigencia_final		date;
define _vigencia_inic		date;
define _fecha_inicio		date;
define _fecha				date;
define _factor_impuesto     smallint;
define _tiene_impuesto		smallint;

set isolation to dirty read;

begin
on exception set _error	--,_error_isam,_mensaje
return _error;			--,_mensaje,null,null;
end exception

--SET DEBUG FILE TO "sp_dev08.trc"; 
--TRACE ON; 
let _prima_diaria_acum = 0.00;
let _prima_dev_neta    = 0.00;
let _prima_dia_acum_n  = 0.00;

foreach
	select vigencia_inic,
		   vigencia_final,
		   prima_bruta,
		   tiene_impuesto,
		   no_documento
	  into _vigencia_inic,
		   _vigencia_final,
		   _prima_bruta,
		   _tiene_impuesto,
		   a_no_documento
	  from emipomae
	 where no_poliza = a_no_poliza
	   and vigencia_inic >= '01/01/2018'  --A partir de esta vigencia.
	   and actualizado = 1
	   and prima_bruta <> 0
	   
	let _fecha_inicio = _vigencia_inic;
	let _dias_vigencia = _vigencia_final - _vigencia_inic;
	
	if _tiene_impuesto = 1 then
		let _factor_impuesto = 0;

		select sum(factor_impuesto)
		  into _factor_impuesto
		  from emipolim e, prdimpue i
		 where e.cod_impuesto = i.cod_impuesto
		   and e.no_poliza = a_no_poliza;

		if _factor_impuesto is null then
			let _factor_impuesto = 0;
		end if

		let _prima_dev_neta = _prima_bruta / (1 + (_factor_impuesto/100));
	else
		let _prima_dev_neta = _prima_bruta;
	end if
	
	if _dias_vigencia = 0 then
		let _prima_diaria = _prima_bruta;
		let _prima_dn     = _prima_dev_neta;
	else
		let _prima_diaria = _prima_bruta / _dias_vigencia;
		let _prima_dn     = _prima_dev_neta / _dias_vigencia;
	end if
	
	let _prima_diaria_acum = 0.00;
	let _prima_dia_acum_n  = 0.00;
	let _fecha             = _fecha_inicio;

	for _contador = 0 to _dias_vigencia
		
		let _fecha = _fecha_inicio + _contador units day;
		begin
			on exception in (-239,-268)
			
				update devengada
				   set prima_db = prima_db + _prima_diaria,
				       prima_dn = prima_dn + _prima_dn
				 where no_documento = a_no_documento
				   and fecha        = _fecha;

			end exception

			insert into devengada(
					no_documento,
					fecha,
					prima_db,
					prima_dn)
			values(	a_no_documento,
					_fecha,
					_prima_diaria,
					_prima_dn);
		end

		let _prima_diaria_acum = _prima_diaria_acum + _prima_diaria;
		let _prima_dia_acum_n  = _prima_dia_acum_n + _prima_dn;
	end for
	
	if _prima_diaria_acum <> _prima_bruta then
		let _dif_prima = _prima_bruta - _prima_diaria_acum;
		update devengada
		   set prima_db = prima_db + _dif_prima
		 where no_documento = a_no_documento
		   and fecha        = _fecha_inicio;
	end if
	let _dif_prima = 0.00;
	if _prima_dia_acum_n <> _prima_dev_neta then
		let _dif_prima = _prima_dev_neta - _prima_dia_acum_n;
		update devengada
		   set prima_dn = prima_dn + _dif_prima
		 where no_documento = a_no_documento
		   and fecha        = _fecha_inicio;
	end if
end foreach
return 0;
end
end procedure;