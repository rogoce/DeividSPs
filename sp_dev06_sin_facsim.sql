-- Procedimiento que actualiza los número de pagos de endosos de pólizas que no han tenido plan pago.
-- Creado: 30/05/2017 - Autor: Román Gordón

drop procedure sp_dev06_sin_facsim;
create procedure sp_dev06_sin_facsim(a_no_documento char(20),a_fecha_calculo date)
returning	smallint		as cod_error,
			varchar(100)	as poliza,
			char(10)		as remesa,
			smallint		as renglon,
			char(1)         as tipo_mov;

define _mensaje				varchar(100);
define _no_factura			char(10);
define _no_poliza			char(10);
define _no_remesa           char(10);
define _tipo_mov           char(1);
define _cod_endomov			char(3);
define _cod_ramo			char(3);
define _prima_diaria_acum	dec(16,2);
define _monto_devolucion	dec(16,2);
define _monto_cobrado		dec(16,2);
define _prima_diaria		dec(16,2);
define _prima_bruta			dec(16,2);
define _dif_prima			dec(16,2);
define _ajuste				dec(16,2);
define _prima_neta_sin      dec(16,2);
define _prima_neta_cr  		dec(16,2);
define _dias_vigencia		integer;
define _error_isam			integer;
define _contador			integer;
define _error,_cnt				integer;
define _vigencia_inic_pol	date;
define _fecha_suspension	date;
define _cubierto_hasta		date;
define _vigencia_final		date;
define _vigencia_inic		date;
define _fecha_emision		date;
define _max_vigencia		date;
define _fecha_inicio		date;
define _fecha				date;
define _renglon             integer;

set isolation to dirty read;

begin
on exception set _error,_error_isam,_mensaje
return _error,_mensaje,null,null,'';
end exception

let _prima_diaria_acum = 0.00;

--Total de Prima Cobrada
let _monto_cobrado = 0;
foreach
	select no_remesa,
		   renglon,tipo_mov
	  into _no_remesa,
		   _renglon,_tipo_mov
	  from cobredet
	 where doc_remesa = a_no_documento
	   and actualizado = 1
	   and tipo_mov in ('P','N','X')
	   and fecha <= a_fecha_calculo

	let _prima_neta_sin = 0;
	let _prima_neta_cr  = 0;
	
	select count(*)
	  into _cnt
	  from cobreaco
	 where no_remesa = _no_remesa
       and renglon   = _renglon;

	if _cnt is null then
		let _cnt = 0;
	end if
	if _cnt = 0 then
	    if _tipo_mov in('P','N') then
			call sp_sis171bk(_no_remesa, _renglon) returning _error,_mensaje;
			let _tipo_mov = 'L';
		else
			let _tipo_mov = '';
		end if
		--return 1,a_no_documento,_no_remesa,_renglon,_tipo_mov;
	else
		let _tipo_mov = '';
		continue foreach;
	end if
	
end foreach
return 0,a_no_documento,'','',_tipo_mov;

end
end procedure;