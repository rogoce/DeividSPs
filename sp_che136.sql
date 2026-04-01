-- Procedure que Inserta las polizas que cumplan con las condiciones de pago anticipado de Comision en la estructra de pago antincipado de comision.
-- 
-- Creado    : 10/10/2012 - Autor: Roman Gordon
--
-- SIS v.2.0 - DEIVID, S.A.

drop procedure sp_che136;		

create procedure "informix".sp_che136(a_no_remesa char(10))
returning integer,	
          char(100);

define _error_desc			char(100);													 
define _no_documento		char(20);													 
define _no_recibo			char(10);										 
define _no_poliza			char(10);
define _cod_agente			char(5);
define _cod_grupo			char(5);
define _no_endoso			char(5);
define _cod_formapag		char(3);
define _cod_perpago			char(3);
define _cod_ramo			char(3);
define _tipo_agente			char(1);
define _status_lic			char(1);
define _comision_cancelada	dec(16,2);			
define _comision_adelanto	dec(16,2);			
define _comision_ganada		dec(16,2);
define _comision_saldo		dec(16,2);
define _prima_neta_cob		dec(16,2);
define _prima_neta_pro		dec(16,2);
define _prima_suscrita		dec(16,2);			
define _monto_recibo		dec(16,2);			
define _comis_saldo			dec(16,2);			
define _prima_neta			dec(16,2);			
define _porc_partic_agt		dec(5,2);			
define _porc_comis_agt		dec(5,2);			
define _poliza_cancelada	smallint;			
define _pago_comis_ade		smallint;			
define _adelanto_comis		smallint;			
define _status_poliza		smallint;
define _cnt_cobredet		smallint;			
define _cnt_existe			smallint;
define _comis_desc			smallint;
define _meses_por			smallint;
define _fronting			smallint;
define _no_pagos			smallint;			
define _aplica				smallint;
define _anio				smallint;
define _dias				smallint;
define _error_isam			integer;
define _vigencia			integer;
define _dif_date			integer;
define _proceso				integer;
define _error				integer;
define _vig_inic_ciclo		date;
define _fecha_proceso		date;
define _vigencia_inic		date;
define _control				interval day to day;


begin
on exception set _error, _error_isam,_error_desc
	return _error, _error_desc;									   
end exception

set isolation to dirty read;

let _no_documento		= '';
let	_no_recibo			= '';
let	_no_poliza			= '';
let _cod_agente			= '';
let _comision_cancelada	= 0.00;
let	_comision_adelanto	= 0.00;
let	_comision_ganada	= 0.00;
let _prima_neta_cob		= 0.00;
let _prima_neta_pro		= 0.00;	
let	_comision_saldo		= 0.00;
let	_prima_suscrita		= 0.00;
let	_monto_recibo		= 0.00;
let	_prima_neta			= 0.00;
let	_porc_partic_agt	= 0.00;	
let	_porc_comis_agt		= 0.00;
let _poliza_cancelada	= 0;
let _pago_comis_ade		= 0;
let	_adelanto_comis		= 0;
let	_status_poliza		= 0;
let	_cnt_existe			= 0;
let	_no_pagos			= 0;
let	_aplica				= 0;

--set debug file to "sp_che136.trc";
--trace on;

foreach
	select no_poliza,
		   no_recibo,
		   monto,
		   comis_desc,
		   prima_neta
	  into _no_poliza,
	  	   _no_recibo,
	  	   _monto_recibo,
	  	   _comis_desc,
	  	   _prima_neta_cob
	  from cobredet 
	 where no_remesa	= a_no_remesa
	   and tipo_mov		= 'P'

	if _comis_desc <> 0 then	--Clausula 5.1
		continue foreach;
	end if

 	select date_posteo
	  into _fecha_proceso
	  from cobremae
	 where no_remesa = a_no_remesa;  

	select no_documento,
		   no_pagos,
		   cod_ramo,
		   vigencia_inic,
		   cod_perpago
	  into _no_documento,
		   _no_pagos,
		   _cod_ramo,
		   _vigencia_inic,
		   _cod_perpago
	  from emipomae
	 where no_poliza = _no_poliza;	
	
	if _cod_ramo in ('018') then
		let _anio = year(_fecha_proceso);

		if month(_vigencia_inic) > month(_fecha_proceso)  then
			let _anio = _anio - 1;		
		end if	 

		let _vig_inic_ciclo = to_date(to_char(mdy(month(_vigencia_inic),day(_vigencia_inic),_anio),'%d/%m/%Y'),'%d/%m/%Y');

		if month(_fecha_proceso) > month(_vigencia_inic) or (month(_fecha_proceso) < month(_vigencia_inic) and month(_fecha_proceso) = 1 ) then
			let _dias = (_fecha_proceso - _vig_inic_ciclo);

			if _dias > 30 then
				continue foreach;
			end if

			select max(no_endoso)
			  into _no_endoso
			  from endedmae
			 where no_poliza   = _no_poliza
			   and cod_endomov in ('011','014')
			   and actualizado = 1
			   and periodo    >= '2011-01';

			select sum(prima_neta),
			       sum(prima_suscrita)
			  into _prima_neta_pro,
			       _prima_suscrita
			  from endedmae
			 where no_poliza   = _no_poliza
			   and no_endoso   = _no_endoso;
			
			if _cod_perpago = '002' then
				let _meses_por = 12;
			elif _cod_perpago = '003' then
				let _meses_por = 6;
			elif _cod_perpago = '004' then
				let _meses_por = 4;
			elif _cod_perpago = '005' then
				let _meses_por = 3;
			elif _cod_perpago = '006' then
				let _meses_por = 12;
			elif _cod_perpago = '007' then
				let _meses_por = 2;
			elif _cod_perpago = '008' then
				let _meses_por = 1;
			elif _cod_perpago = '009' then
				let _meses_por = 3;
			end if

			let _prima_neta_pro = _prima_neta_pro * _meses_por;
			let _prima_suscrita = _prima_suscrita * _meses_por;			
		else
			continue foreach;
		end if
	else
		select count(*)
		  into _cnt_cobredet
		  from cobredet
		 where no_poliza = _no_poliza
		   and no_remesa <> a_no_remesa
		   and actualizado = 1;

		if _cnt_cobredet <> 0 then
			continue foreach;
		end if
		
		let _dias = (_fecha_proceso - _vigencia_inic);

		if _dias > 30 then
			continue foreach;
		end if

		select sum(prima_neta),
		       sum(prima_suscrita)
		  into _prima_neta_pro,
		       _prima_suscrita
		  from endedmae
		 where no_poliza   = _no_poliza
		   and actualizado = 1;
	end if
		
	foreach	
		select cod_agente,
			   porc_partic_agt,
			   porc_comis_agt
		  into _cod_agente,
		  	   _porc_partic_agt,
		  	   _porc_comis_agt
		  from emipoagt
		 where no_poliza = _no_poliza

		select adelanto_comis
		  into _adelanto_comis
		  from agtagent
		 where cod_agente = _cod_agente;

		if _adelanto_comis = 0 then
			continue foreach;
		end if

		let _comis_saldo = 0.00;

		select comision_saldo
		  into _comis_saldo
		  from cobadeco
		 where cod_agente = _cod_agente
		   and no_documento = _no_documento;

		if abs(_comis_saldo) < 0.50 then
			delete from cobadeco
			 where no_documento = _no_documento;
		end if
			
		call sp_cob309(_no_poliza,_cod_agente) returning _aplica;		--Clausulas 5.3, 5.5, 5.7
		
		if _aplica < 0 then
			return _aplica,'Error al Verificar el Adelanto de comision';
		end if
		
		if _aplica = 0 then
			continue foreach;
		end if

		let _comision_adelanto = _prima_neta_pro * (_porc_partic_agt / 100) * (_porc_comis_agt / 100);
		let _comision_ganada   = _prima_neta_cob * (_porc_partic_agt / 100) * (_porc_comis_agt / 100);
		let _comision_saldo    = _comision_adelanto;-- - _comision_ganada;  

		insert into cobadeco(
				cod_agente,
				no_documento,
				no_recibo,
				fecha,
				monto_recibo,
				prima_suscrita,
				prima_neta,
				comision_adelanto,
				comision_ganada,
				comision_saldo,
				poliza_cancelada,
				comision_cancelada,
				porc_partic_agt,
				porc_comis_agt,
				cant_pagos)
		values(	_cod_agente,						
				_no_documento,						
				_no_recibo,							
				_fecha_proceso,						
				_monto_recibo,						
				_prima_suscrita,					
				_prima_neta_pro,						
				_comision_adelanto,		
				0,		
				_comision_saldo,		
				_poliza_cancelada,		
				_comision_cancelada,	
				_porc_partic_agt,		
				_porc_comis_agt,		
				_no_pagos);				
	end foreach
end foreach

return 0,'Exito';
end
end procedure;