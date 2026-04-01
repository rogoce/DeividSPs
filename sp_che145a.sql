-- Reporte Detallado de Pólizas en Adelanto de Comisión
-- Creado    : 18/09/2014 - Autor: Román Gordón
-- SIS v.2.0 -- -- DEIVID, S.A.

drop procedure sp_che145;
create procedure sp_che145(a_cod_agente char(5))
returning	varchar(50) 	as Corredor,
			smallint		as numero_maximo_pagos,
			char(20)		as Poliza,
			dec(16,2)		as Prima_neta,
			char(10)		as No_Recibo,
			date			as Fecha_Pago,
			dec(16,2)		as monto_cobrado,
			dec(16,2)		as prima_neta_cob,
			dec(5,2)		as porc_partic_agt,
			dec(5,2)		as porc_comis_agt,
			dec(16,2)		as comision_pagada,
			dec(16,2)		as comis_devengada,
			dec(16,2)		as comis_saldo;

define _nom_agente			varchar(50);
define _no_doc_verif		char(20);
define _no_documento		char(20);
define _no_recibo			char(10);
define _no_poliza			char(10);
define _no_endoso			char(5);
define _cod_tipoprod		char(3);
define _tipo_mov			char(1);
define _porc_partic_agt		dec(5,2);
define _porc_comis_agt		dec(5,2);
define _comision_adelanto	dec(16,2);
define _comision_ganada		dec(16,2);
define _comision_pagada		dec(16,2);
define _comis_devengada		dec(16,2);
define _prima_neta_cob		dec(16,2);
define _prima_suscrita		dec(16,2);
define _comision_saldo		dec(16,2);
define _monto_cobrado		dec(16,2);
define _comis_saldo			dec(16,2);
define _prima_neta			dec(16,2);
define _adelanto_comis		smallint;
define _cnt_cobadeco		smallint;
define _max_no_pagos		smallint;
define _flag_saldo			smallint;
define _cant_pagos			smallint;
define _fecha_adelanto		date;
define _fecha_inicio		date;
define _fecha_cobro			date;

set isolation to dirty read;

--set debug file to "sp_che145.trc";	 																						 
--trace on;

create temp table tmp_det(
	nom_agente		varchar(50),
	no_pagos		smallint,
	no_documento	char(20),
	prima_neta		dec(16,2),
	no_recibo		char(10),
	date_added		date,
	prima_bruta		dec(16,2),
	prima_neta_cob	dec(16,2),
	porc_partic_agt	dec(5,2),
	porc_comis_agt	dec(5,2),
	comis_pagada	dec(16,2),
	comis_devengada	dec(16,2),
	tipo_mov		char(1)) with no log;
create index idx1_tmp_det on tmp_det(no_documento);
create index idx2_tmp_det on tmp_det(date_added);

select trim(nombre),
	   max_no_pagos
  into _nom_agente,
	   _max_no_pagos
  from agtagent
 where cod_agente = a_cod_agente;

let _no_doc_verif = '';
let _comis_saldo = 0.00;
let _flag_saldo = 0;

foreach
	{select no_documento,
		   no_recibo,
		   fecha,
		   prima_suscrita,
		   prima_neta,
		   comision_adelanto,
		   comision_ganada,
		   comision_saldo,
		   porc_comis_agt,
		   porc_partic_agt,
		   cant_pagos
	  into _no_documento,
		   _no_recibo,
		   _fecha_inicio,
		   _prima_suscrita,
		   _prima_neta,
		   _comision_adelanto,
		   _comision_ganada,
		   _comision_saldo,
		   _porc_comis_agt,
		   _porc_partic_agt,
		   _cant_pagos
	  from cobadeco
	 where cod_agente = a_cod_agente
	 order by fecha,no_documento}

	select distinct no_documento
	  into _no_documento
	  from chqcomis
	 where cod_agente = a_cod_agente
	   and anticipo_comis = 1

	let _cnt_cobadeco = 0;

	select count(*)
	  into _cnt_cobadeco
	  from cobadeco
	 where no_documento = _no_documento;

	if _cnt_cobadeco is null then
		let _cnt_cobadeco = 0;
	end if

	let _prima_neta = 0.00;

	if _cnt_cobadeco <> 0 then
		--continue foreach;
		select prima_neta
		  into _prima_neta
		  from cobadeco
		 where no_documento = _no_documento;
	else
		select count(*)
		  into _cnt_cobadeco
		  from cobadecoh
		 where no_documento = _no_documento;
		
		if _cnt_cobadeco is null then
			let _cnt_cobadeco = 0;
		end if
		
		if _cnt_cobadeco <> 0 then
			select prima_neta
			  into _prima_neta
			  from cobadecoh
			 where no_documento = _no_documento;
		end if
	end if

	if _prima_neta is null then
		let _prima_neta = 0.00;
	end if

	select min(fecha)
	  into _fecha_adelanto
	  from chqcomis
	 where cod_agente = a_cod_agente
	   and no_documento = _no_documento
	   and anticipo_comis = 1;

	let _adelanto_comis = 0;

	foreach
		select no_poliza,
			   fecha,
			   comision,
			   monto_danos + monto_vida,
			   monto,
			   prima,
			   porc_comis,
			   porc_partic,
			   anticipo_comis,
			   no_recibo
		  into _no_poliza,
			   _fecha_cobro,
			   _comision_pagada,
			   _comis_devengada,
			   _monto_cobrado,
			   _prima_neta_cob,
			   _porc_comis_agt,
			   _porc_partic_agt,
			   _adelanto_comis,
			   _no_recibo
		  from chqcomis
		 where cod_agente = a_cod_agente
		   and no_documento = _no_documento
		   and fecha >= _fecha_adelanto
		 order by fecha

		if _adelanto_comis = 0 and _no_poliza <> '00000' then
			continue foreach;
		end if

		if _no_poliza = '00000' then
			let _comis_devengada = 0.00;
		end if

		insert into tmp_det
		values(	_nom_agente,
				_max_no_pagos,
				_no_documento,
				_prima_neta,
				_no_recibo,
				_fecha_cobro,
				_monto_cobrado,
				_prima_neta_cob,
				_porc_partic_agt,
				_porc_comis_agt,
				_comision_pagada,
				_comis_devengada,
				'C');
	end foreach

	let _comision_pagada = 0.00;

	foreach
		select no_poliza,
			   no_endoso,
			   no_factura,
			   date_added,
			   prima_neta,
			   prima_bruta
		  into _no_poliza,
			   _no_endoso,
			   _no_recibo,
			   _fecha_cobro,
			   _prima_neta_cob,
			   _monto_cobrado
		  from endedmae
		 where no_documento = _no_documento
		   and cod_endomov in ('024','025')
		   and date_added >= _fecha_adelanto
		   and actualizado = 1

		select porc_partic_agt,
			   porc_comis_agt
		  into _porc_partic_agt,
			   _porc_comis_agt
		  from endmoage
		 where no_poliza = _no_poliza
		   and no_endoso = _no_endoso
		   and cod_agente = a_cod_agente;

		if _porc_partic_agt is null or _porc_comis_agt is null then
			select porc_partic_agt,
				   porc_comis_agt
			  into _porc_partic_agt,
				   _porc_comis_agt
			  from emipoagt
			 where no_poliza = _no_poliza
			   and cod_agente = a_cod_agente;
		end if

		let _comis_devengada = _prima_neta_cob * (_porc_partic_agt/100) * (_porc_comis_agt/100);
		let _comision_pagada = _comis_devengada;
		let _comis_devengada = 0.00;
		--let _comis_saldo = _comis_saldo + _comision_pagada - _comis_devengada;
		
		insert into tmp_det
		values(	_nom_agente,
				_max_no_pagos,
				_no_documento,
				_prima_neta,
				_no_recibo,
				_fecha_cobro,
				_monto_cobrado,
				_prima_neta_cob,
				_porc_partic_agt,
				_porc_comis_agt,
				_comision_pagada,
				_comis_devengada,
				'P');
	end foreach
end foreach

foreach
	select nom_agente,
		   no_pagos,
		   no_documento,
		   prima_neta,
		   no_recibo,
		   date_added,
		   prima_bruta,
		   prima_neta_cob,
		   porc_partic_agt,
		   porc_comis_agt,
		   comis_pagada,
		   comis_devengada,
		   tipo_mov
	  into _nom_agente,
		   _max_no_pagos,
		   _no_documento,
		   _prima_neta,
		   _no_recibo,
		   _fecha_cobro,
		   _monto_cobrado,
		   _prima_neta_cob,
		   _porc_partic_agt,
		   _porc_comis_agt,
		   _comision_pagada,
		   _comis_devengada,
		   _tipo_mov
	  from tmp_det
	 order by no_documento,date_added
	
	if _no_documento <> _no_doc_verif then
		let _no_doc_verif = _no_documento;
		let _comis_saldo = 0;
	end if

	if _tipo_mov = 'P' and _comis_saldo < 0 then 
		--let _comision_pagada = 0.00;
		--let _comis_devengada = 0.00;
		continue foreach;
	end if
	
	let _comis_saldo = _comis_saldo + _comision_pagada - _comis_devengada;

	return	_nom_agente,
			_max_no_pagos,
			_no_documento,
			_prima_neta,
			_no_recibo,
			_fecha_cobro,
			_monto_cobrado,
			_prima_neta_cob,
			_porc_partic_agt,
			_porc_comis_agt,
			_comision_pagada,
			_comis_devengada,
			_comis_saldo
	with resume;
end foreach

drop table tmp_det;
end procedure;