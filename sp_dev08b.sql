-- Primas devengadas ENDOSOS
-- Procedimiento que actualiza los número de pagos de endosos de pólizas que no han tenido plan pago.

drop procedure sp_dev08b;
create procedure sp_dev08b(a_no_poliza char(10),a_no_endoso char(10))
returning	smallint		as cod_error;

define _mensaje				varchar(100);
define _no_factura			char(10);
define a_no_documento       char(20);
define _no_poliza			char(10);
define _cod_endomov			char(3);
define _cod_ramo			char(3);
define _prima_diaria_acum	dec(16,2);
define _monto_devolucion	dec(16,2);
define _monto_cobrado		dec(16,2);
define _prima_diaria		dec(16,2);
define _prima_bruta			dec(16,2);
define _dif_prima			dec(16,2);
define _ajuste				dec(16,2);
define _prima_neta          dec(16,2);
define _pri_dia_net_acum    dec(16,2);
define _prima_dn            dec(16,2);
define _dias_vigencia		integer;
define _error_isam			integer;
define _contador			integer;
define _error				integer;
define _vigencia_inic_pol	date;
define _fecha_suspension	date;
define _cubierto_hasta		date;
define _vigencia_final		date;
define _vigencia_inic		date;
define _fecha_emision		date;
define _max_vigencia		date;
define _fecha_inicio		date;
define _fecha				date;

set isolation to dirty read;

begin
on exception set _error
return _error;
end exception

let _prima_diaria_acum = 0.00;
let _pri_dia_net_acum  = 0.00;

foreach
	select cod_endomov,
		   vigencia_inic,
		   vigencia_final,
		   fecha_emision,
		   prima_bruta,
		   no_documento,
		   prima_neta
	  into _cod_endomov,
		   _vigencia_inic,
		   _vigencia_final,
		   _fecha_emision,
		   _prima_bruta,
		   a_no_documento,
		   _prima_neta
	  from endedmae
	 where no_poliza = a_no_poliza
	   and no_endoso = a_no_endoso
	   and actualizado = 1
	   and prima_bruta <> 0
	   and activa = 1

	if _cod_endomov in ('001','019') then	--Aumento y Disminucion de vigencia respectivamente
		select vigencia_inic
		  into _vigencia_inic_pol
		  from emipomae
		 where no_poliza = a_no_poliza;

		let _vigencia_inic = _vigencia_inic_pol;
	end if
	
	if _fecha_emision > _vigencia_inic and (_prima_bruta > 0 and _cod_endomov <> '025') then	--Reversar descuento pronto pago
		let _fecha_inicio = _fecha_emision;
		let _dias_vigencia = _vigencia_final - _fecha_emision;
	else
		let _fecha_inicio = _vigencia_inic;
		let _dias_vigencia = _vigencia_final - _vigencia_inic;
	end if

	if _dias_vigencia = 0 then
		let _prima_diaria = _prima_bruta;
		let _prima_dn     = _prima_neta;
	else
		let _prima_diaria = _prima_bruta / _dias_vigencia;
		let _prima_dn     = _prima_neta / _dias_vigencia;
	end if
	
	let _prima_diaria_acum = 0.00;
	let _pri_dia_net_acum  = 0.00;
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
		let _pri_dia_net_acum  = _pri_dia_net_acum  + _prima_dn;
	end for
	
	if _prima_diaria_acum <> _prima_bruta then
		let _dif_prima = _prima_bruta - _prima_diaria_acum;
		update devengada
		   set prima_db = prima_db + _dif_prima
		 where no_documento = a_no_documento
		   and fecha        = _fecha_inicio;
	end if
	let _dif_prima = 0.00;
	if _pri_dia_net_acum <> _prima_neta then
		let _dif_prima = _prima_neta - _pri_dia_net_acum;
		update devengada
		   set prima_dn = prima_dn + _dif_prima
		 where no_documento = a_no_documento
		   and fecha        = _fecha_inicio;
	end if
end foreach
return 0;
end
end procedure;