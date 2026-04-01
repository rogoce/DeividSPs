-- Generacion del Archivo de transacciones para Multi Credit Bank
-- Creado    : 22/02/2001 - Autor: Román Gordón

-- SIS v.2.0 - DEIVID, S.A.

drop procedure sp_arregla_cobadeco;

create procedure 'informix'.sp_arregla_cobadeco()
returning	char(5)		as Corredor,					--_cod_agente,
			char(21)	as Poliza,						--_no_documento,
			char(10)	as Recibo,						--_no_recibo_adeco,
			date		as Fecha_Recibo,				--_fecha_recibo
			dec(16,2)	as Prima_Suscrita,				--_prima_susc_adeco,
			dec(16,2)	as Prima_Neta,					--_prima_neta_adeco,
			dec(16,2)	as Monto_Adelantado,			--_monto_adelanto,
			dec(16,2)	as Comision_Ganada_Adelanto,	--_comis_ganada_adec,
			dec(16,2)	as Saldo_Comision_Adelantada,	--_comis_saldo_adec,
			dec(16,2)	as Comision_Pagada,				--_sum_comision,
			dec(16,2)	as Comision_Ganada,				--_sum_comis_ganada_calc,
			dec(16,2)	as Calculo_Saldo_Comision,		--_saldo_comis_calc
			date		as Fecha_Ult_Pago;				--_fecha_ult_pago
			

define _no_documento		char(21);
define _no_recibo_adeco		char(10);
define _no_recibo_comis		char(10);
define _no_remesa			char(10);
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
define _adelanto_comis		smallint;
define _cnt_cobadecoh		smallint;
define _cnt_ren				smallint;
define _fecha_ult_pago		date;
define _fecha_recibo		date;


--set debug file to 'sp_verif_adeco.trc';
--trace on;

begin

{on exception set _error_code 
 	return _error_code, 'Error al Actualizar las Transacciones para el Banco. Cuenta:'||_no_cuenta;
end exception }

foreach
	select cod_agente,
		   no_documento,
		   no_recibo,
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
		   _monto_adelanto,
		   _comis_ganada_adec,
		   _comis_saldo_adec,
		   _prima_susc_adeco,
		   _prima_neta_adeco,
		   _porc_comis_adeco,
		   _porc_partic_adeco
	  from cobadeco
	 --where no_documento not in ('0213-03738-01','0213-04082-01','0213-04963-01','0214-00145-01','0214-02289-01','0214-02425-01','0114-00545-01','0207-30101-56','0213-16535-82')
	 --where cod_agente = '00270'
	 order by cod_agente,no_documento	
	
	select adelanto_comis
	  into _adelanto_comis
	  from agtagent
	 where cod_agente = _cod_agente;

	if _adelanto_comis = 0 then
		continue foreach;
	end if
	
	select count(*)
	  into _cnt_cobadecoh
	  from cobadecoh
	 where no_documento = _no_documento
	   and poliza_cancelada = 0;
	
	if _cnt_cobadecoh is null then
		let _cnt_cobadecoh = 0;
	end if
	
	if _cnt_cobadecoh > 0 then
		select no_recibo
		  into _no_recibo_adeco
		  from cobadecoh
		 where no_documento = _no_documento
		   and poliza_cancelada = 0;
	end if
	 
	foreach
		select no_remesa
		  into _no_remesa
		  from cobredet
		 where no_recibo = _no_recibo_adeco
		   and doc_remesa = _no_documento
		exit foreach;
	end foreach

	select fecha
	  into _fecha_recibo
	  from cobremae
	 where no_remesa = _no_remesa;

	let _sum_comis_gan_calc = 0.00;
	let _comis_ganada_calc = 0.00;
	let _saldo_comis_calc = 0.00;
	let _sum_comision = 0.00;
	
	select count(*)
	  into _cnt_ren
	  from endedmae
	 where no_documento = _no_documento
	   and date_added >= _fecha_recibo
	   --and cod_endomov not in ('011','014')
	   and cod_endomov in ('024')--,'011')
	   and actualizado = 1;

	if _cnt_ren is null then
		let _cnt_ren = 0;
	end if
	
	if _cnt_ren = 0 then
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
		   --and anticipo_comis = 1
		   and fecha >= _fecha_recibo
		   --and seleccionado = 1
		
		let _comis_ganada_calc = _prima_cobrada * (_porc_partic_comis/100) * (_porc_comis/100);
		let _sum_comision = _sum_comision + _monto_comision;
		let _sum_comis_gan_calc = _sum_comis_gan_calc + _comis_ganada_calc;
	end foreach
	
	let _saldo_comis_calc = _sum_comision - _sum_comis_gan_calc;
	
	--if abs(_sum_comis_gan_calc - _comis_ganada_adec) > 0 then
	--if abs(_sum_comision - _monto_adelanto) > 0 then
	if abs(_saldo_comis_calc - _comis_saldo_adec) > 0.50 
	or abs(_sum_comis_gan_calc - _comis_ganada_adec) > 0.50 
	or abs(_sum_comision - _monto_adelanto) > 0.50  then
		{update cobadeco
		   set comision_ganada = _sum_comis_gan_calc,
			   comision_saldo = comision_adelanto - _sum_comis_gan_calc
		 where no_documento = _no_documento;}
		
		select max(fecha)
		  into _fecha_ult_pago
		  from cobredet d
		 where doc_remesa = _no_documento
		   and actualizado = 1;
		
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
				_saldo_comis_calc,
				_fecha_ult_pago	with resume;
	end if
end foreach
end
end procedure 