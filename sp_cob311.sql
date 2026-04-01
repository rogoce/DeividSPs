-- Simulacion del Pago Adelantado de Comision
-- 
-- Creado     : 16/10/2012 - Autor: Demetrio Hurtado Almanza

-- SIS v.2.0 - DEIVID, S.A.

drop procedure sp_cob311;

create procedure "informix".sp_cob311()
returning smallint,
          char(50);

define _no_remesa			char(10);
define _renglon				smallint;
define _no_documento		char(20);
define _no_recibo			char(10);
define _fecha				date;
define _monto				dec(16,2);
define _periodo				char(7);
define _monto_descontado	dec(16,2);

define _no_poliza			char(10);
define _no_endoso			char(5);
define _cod_ramo			char(3);
define _ramo				char(50);
define _cod_formapag		char(3);
define _forma_pago			char(50);
define _cod_perpago			char(3);
define _per_pago			char(50);
define _vigencia_inic		date;
define _meses_por			smallint;

define _prima_suscrita		dec(16,2);
define _prima_neta_pro		dec(16,2);
define _prima_neta_cob		dec(16,2);
define _comision_adelanto	dec(16,2);
define _comision_ganada		dec(16,2);
define _comision_saldo		dec(16,2);

define _cod_agente			char(5);
define _tipo_agente			char(1);
define _estatus_licencia	char(1);
define _porc_comis_agt   	dec(5,2);
define _porc_partic_agt	 	dec(5,2);

define _aplica 				smallint;
define _cantidad			smallint;
define _cantidad_NC			smallint;
define _insertar			smallint;

define _no_pagos			smallint;
define _mes_ingreso			smallint;
define _mes_vigencia		smallint;
define _ano_vigencia		smallint;

set isolation to dirty read;

{
drop table tmp_cobadeflu;

create table tmp_cobadeflu( 
cod_agente			char(5),
no_documento		char(20),
periodo				char(7),
prima_neta			dec(16,2)	not null default 0,
comision_ganada		dec(16,2)	not null default 0,
flujo_caja			dec(16,2)	not null default 0,
prima_neta_n		dec(16,2)	not null default 0,
comision_ganada_n	dec(16,2)	not null default 0,
flujo_caja_n		dec(16,2)	not null default 0,
ramo				char(50),
forma_pago			char(50),
per_pago			char(50)
);
--}

-- Inicio del Proceso

delete from tmp_cobadeflu;

--{
foreach
 select no_poliza,
        cod_ramo,
		cod_formapag,
	    cod_perpago,
		vigencia_inic,
		no_documento
   into _no_poliza,
        _cod_ramo,
		_cod_formapag,
	    _cod_perpago,
		_vigencia_inic,
		_no_documento
   from emipomae
  where actualizado    = 1
	and estatus_poliza = 1
--  and periodo        >= "2012-01"
--	and cod_ramo       <> "018"
--    and no_documento   = "0400-00001-02"
--    and no_documento   = "1800-00003-01"

	let _aplica = sp_cob309(_no_poliza);
--	let _aplica = 1;

	if _aplica = 0 then
		continue foreach;
	end if

	select nombre 
	  into _ramo
	  from prdramo
	 where cod_ramo = _cod_ramo;

	select nombre
	  into _forma_pago
	  from cobforpa
	 where cod_formapag = _cod_formapag;

	{
	select nombre
	  into _per_pago
	  from cobperpa
	 where cod_perpago = _cod_perpago;
	}

	foreach
	 select cod_agente,
	 		porc_comis_agt,
			porc_partic_agt
	   into _cod_agente,
	        _porc_comis_agt,
			_porc_partic_agt
	   from emipoagt
	  where no_poliza = _no_poliza

		exit foreach;

	end foreach

	select tipo_agente,
	       estatus_licencia
	  into _tipo_agente,
		   _estatus_licencia
	  from agtagent
	 where cod_agente = _cod_agente;

	if _tipo_agente <> "A" then -- Agente 
		continue foreach;
	end if

	if _estatus_licencia <> "A" then -- Activas
		continue foreach;
	end if

	let _mes_vigencia = month(_vigencia_inic);
	let _ano_vigencia = year(_vigencia_inic);

	if _cod_ramo = "018" then

		let _mes_ingreso  = 11;
		let _ano_vigencia = 2012;

		select max(no_endoso)
		  into _no_endoso
		  from endedmae
		 where no_poliza   = _no_poliza
		   and cod_endomov = "014"
		   and actualizado = 1
		   and periodo    >= "2012-01";

		select sum(prima_neta),
		       sum(prima_suscrita)
		  into _prima_neta_pro,
		       _prima_suscrita
		  from endedmae
		 where no_poliza   = _no_poliza
		   and no_endoso   = _no_endoso;

		if _prima_neta_pro is null then

			select prima_neta
			  into _prima_neta_pro
			  from emipomae
			 where no_poliza = _no_poliza;

		end if
				
		if _cod_perpago = "002" then
			let _meses_por = 12;
		elif _cod_perpago = "003" then
			let _meses_por = 6;
		elif _cod_perpago = "004" then
			let _meses_por = 4;
		elif _cod_perpago = "005" then
			let _meses_por = 3;
		elif _cod_perpago = "006" then
			let _meses_por = 12;
		elif _cod_perpago = "007" then
			let _meses_por = 2;
		elif _cod_perpago = "008" then
			let _meses_por = 1;
		elif _cod_perpago = "009" then
			let _meses_por = 3;
		end if

		let _prima_neta_pro = _prima_neta_pro * _meses_por;
		let _prima_suscrita = _prima_suscrita * _meses_por;
					

	else
	
		let _mes_ingreso = 7;

		select sum(prima_neta),
		       sum(prima_suscrita)
		  into _prima_neta_pro,
		       _prima_suscrita
		  from endedmae
		 where no_poliza   = _no_poliza
		   and actualizado = 1;

	end if

	-- Adelanto de Comision

	let _comision_adelanto = _prima_neta_pro * (_porc_partic_agt / 100) * (_porc_comis_agt / 100);
	let _prima_neta_cob    = _prima_neta_pro / (_mes_ingreso + 1);

	if _mes_vigencia in (10, 11, 12) then
		
		let _periodo = _ano_vigencia || "-" || _mes_vigencia;

	else

		let _periodo = _ano_vigencia || "-0" || _mes_vigencia;
	
	end if

	let _per_pago = _periodo;

	insert into tmp_cobadeflu(
	cod_agente, 
	no_documento, 
	periodo,
	prima_neta, 
	comision_ganada, 
	prima_neta_n,
	comision_ganada_n,
	flujo_caja_n,
	ramo,
	forma_pago,
	per_pago
	)
	values (
	_cod_agente, 
	_no_documento, 
	_periodo, 
	_prima_neta_pro, 
	_comision_adelanto,
	_prima_neta_cob,
	_comision_adelanto, 
	_prima_neta_cob - _comision_adelanto,
	_ramo,
	_forma_pago,
	_per_pago
	);

	let _comision_adelanto = 0;

	for _no_pagos = 1 to _mes_ingreso

		if _mes_vigencia = 12 then
		
			let _mes_vigencia = 1;
			let _ano_vigencia = _ano_vigencia + 1;
			
		else

			let _mes_vigencia = _mes_vigencia + 1;
		
		end if 

		if _mes_vigencia in (10, 11, 12) then
			
			let _periodo = _ano_vigencia || "-" || _mes_vigencia;

		else

			let _periodo = _ano_vigencia || "-0" || _mes_vigencia;
		
		end if

		insert into tmp_cobadeflu(
		cod_agente, 
		no_documento, 
		periodo,
		prima_neta_n,
		comision_ganada_n,
		flujo_caja_n,
		ramo,
		forma_pago,
		per_pago
		)
		values (
		_cod_agente, 
		_no_documento, 
		_periodo, 
		_prima_neta_cob, 
		_comision_adelanto, 
		_prima_neta_cob - _comision_adelanto,
		_ramo,
		_forma_pago,
		_per_pago
		);

	end for

end foreach

return 0, "Actualizacion Exitosa";

end procedure
