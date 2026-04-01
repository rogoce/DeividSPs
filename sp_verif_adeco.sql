-- Generacion del Archivo de transacciones para Multi Credit Bank
-- Creado    : 22/02/2001 - Autor: Román Gordón

-- SIS v.2.0 - DEIVID, S.A.

drop procedure sp_verif_adeco;

create procedure "informix".sp_verif_adeco()
returning	char(5),	--_cod_agente,
			char(21),	--_no_documento,
			char(10),	--_no_recibo_adeco,
			date,
			dec(16,2),	--_prima_susc_adeco,
			dec(16,2),	--_prima_neta_adeco,
			dec(16,2),	--_monto_adelanto,
			dec(16,2),	--_comis_ganada_adec,
			dec(16,2),	--_comis_saldo_adec,
			dec(16,2),	--_sum_comision,
			dec(16,2),	--_sum_comis_ganada_calc,
			dec(16,2);	--_saldo_comis_calc

define _no_documento		char(21);
define _no_recibo_adeco		char(10);
define _no_recibo_comis		char(10);
define _cod_agente			char(5);
define _porc_partic_adeco	dec(5,2);
define _porc_partic_comis	dec(5,2);
define _porc_comis_adeco	dec(5,2);
define _porc_comis			dec(5,2);
define _sum_comis_gan_calc	dec(16,2);
define _comis_ganada_adec	dec(16,2);
define _comis_ganada_calc	dec(16,2);
define _comis_saldo_adec	dec(16,2);
define _prima_susc_adeco	dec(16,2);
define _prima_neta_adeco	dec(16,2);
define _saldo_comis_calc	dec(16,2);
define _monto_comision		dec(16,2);
define _monto_adelanto		dec(16,2);
define _prima_cobrada		dec(16,2);
define _sum_comision		dec(16,2);
define _monto_pagado		dec(16,2);
define _cnt_ren				smallint;
define _fecha_recibo		date;


--set debug file to "sp_verif_adeco.trc";
--trace on;

begin

{on exception set _error_code 
 	return _error_code, 'Error al Actualizar las Transacciones para el Banco. Cuenta:'||_no_cuenta;
end exception }

foreach
	select cod_agente,
		   no_documento,
		   no_recibo,
		   fecha,
		   comision_adelanto,
		   comision_ganada,
		   comision_saldo,
		   prima_suscrita,
		   prima_neta,
		   porc_comis_agt,
		   porc_partic_agt
	  into _cod_agente,
		   _no_documento,
		   _no_recibo_adeco,
		   _fecha_recibo,
		   _monto_adelanto,
		   _comis_ganada_adec,
		   _comis_saldo_adec,
		   _prima_susc_adeco,
		   _prima_neta_adeco,
		   _porc_comis_adeco,
		   _porc_partic_adeco
	  from cobadeco
	 order by cod_agente,no_documento
	
	let _sum_comis_gan_calc = 0.00;
	let _comis_ganada_calc = 0.00;
	let _saldo_comis_calc = 0.00;
	let _sum_comision = 0.00;
	
	select count(*)
	  into _cnt_ren
	  from endedmae
	 where no_documento = _no_documento
	   and fecha_impresion >= _fecha_recibo
	   and cod_endomov = '011'
	   and actualizado = 1;

	if _cnt_ren is null then
		let _cnt_ren = 0;
	end if
	
	if _cnt_ren > 0 then
		continue foreach;
	end if
	
	foreach
		select no_recibo,
			   monto,
			   prima,
			   porc_partic,
			   porc_comis,
			   comision
		  into _no_recibo_comis,
			   _monto_pagado,
			   _prima_cobrada,
			   _porc_partic_comis,
			   _porc_comis,
			   _monto_comision
		  from chqcomis
		 where cod_agente = _cod_agente
		   and no_documento = _no_documento
		   and anticipo_comis = 1
		   --and fecha >= _fecha_recibo
		   and seleccionado = 1
		
		let _comis_ganada_calc = _prima_cobrada * (_porc_partic_comis/100) * (_porc_comis/100);
		let _sum_comision = _sum_comision + _monto_comision;
		let _sum_comis_gan_calc = _sum_comis_gan_calc + _comis_ganada_calc;
	end foreach
	
	let _saldo_comis_calc = _sum_comision - _sum_comis_gan_calc;
	
	if _saldo_comis_calc <> 0 then	
		return	_cod_agente,
				_no_documento,
				_no_recibo_adeco,
				_fecha_recibo,
				_prima_susc_adeco,
				_prima_neta_adeco,
				_monto_adelanto,
				_comis_ganada_adec,
				_comis_saldo_adec,
				_sum_comision,
				_sum_comis_gan_calc,
				_saldo_comis_calc with resume;
	end if
end foreach

end
end procedure 