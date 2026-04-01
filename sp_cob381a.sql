-- Creacion de la remesa de Cierre de Caja  

-- Creado    : 01/07/2017 -- Autor: Román Gordón   
--
-- SIS v.2.0 - DEIVID, S.A.
  
drop procedure sp_cob381a;

create procedure sp_cob381a(a_numero char(10), a_recibo_susp char(30), a_user char(8))
returning	integer,
			varchar(100);

define _nom_cliente			varchar(100);
define _error_desc			varchar(100);
define _nombre_agente  		varchar(50);
define _descripcion			varchar(50);
define _nom_cuenta  		varchar(50);
define _cedula				varchar(30);
define _cuenta_caja			char(25);
define _cuenta_cxc			char(25);
define _no_documento		char(20);
define _no_remesa_agt		char(10);
define _cod_cliente			char(10);
define _no_poliza			char(10);
define _no_recibo    		char(10);
define _no_remesa			char(10);
define _user_cierre			char(8);
define _periodo				char(7);
define _cod_agente_duc		char(5);
define _cod_auxiliar		char(5);
define _cod_agente			char(5);
define _cod_cobrador		char(3);
define _cod_chequera 		char(3);
define _cod_compania		char(3);
define _cod_sucursal		char(3);
define _cod_banco			char(3);
define _tipo_remesa			char(1);
define _tipo_mov			char(1);
define _null				char(1);
define _porc_partic_agt		dec(5,2);
define _porc_comis_agt		dec(5,2);
define _monto_descontado	dec(16,2);
define _monto_remesar		dec(16,2);
define _monto_recibo		dec(16,2);
define _monto_total			dec(16,2);
define _total_caja			dec(16,2);
define _monto_calc			dec(16,2);
define _prima_neta			dec(16,2);
define _comis_dif			dec(16,2);
define _impuesto			dec(16,2);
define _factor				dec(16,2);
define _saldo				dec(16,2);
define _monto				dec(16,2);
define _flag_comis_desc		smallint;
define _estatus_poliza		smallint;
define _flag_procesar		smallint;
define _comis_desc			smallint;
define _cnt_pago			smallint;
define _cantidad			smallint;
define _renglon				smallint;
define _cnt_agt				smallint;
define _error_isam			integer;
define _diferencia   		integer;
define _secuencia			integer;
define _error				integer;
define _fecha_cierre		datetime year to second;
define _ubic_pago			smallint;
define _nombre_cliente 		char(80);
define _total_susp			dec(16,2);
define _fecha_recibo		date;
define _doc_remesa	 		char(30);

begin 
on exception set _error, _error_isam, _error_desc
	drop table if exists tmp_cieca;
	return _error, _error_desc;
end exception

call sp_cob212('001','001',a_user,a_numero,a_recibo_susp) returning _error,_error_desc,_no_remesa;

return _error,_error_desc;

drop table if exists tmp_cieca;

create temp table tmp_cieca(
cuenta			char(25),
cod_auxiliar	char(5)		default NULL,
monto			dec(16,2),
nombre			varchar(100)
--primary key(cuenta)
) with no log;


--set debug file to "sp_cob381a.trc";
--trace on;
-- Validaciones Iniciales para la Remesa
let _no_remesa = sp_sis13('001', 'COB', '02', 'par_no_remesa');

select count(*)
  into _cantidad
  from cobremae
 where no_remesa = _no_remesa;

if _cantidad <> 0 then
	return 1, 'El Numero de Remesa Generado Ya Existe, Por Favor Actualize Nuevamente ...';
end if

--let _no_remesa_agt = '7138';
let _cod_cobrador = '339';
let _cod_auxiliar = 'A0035';
let _tipo_remesa = 'C';
let _cod_agente_duc = '00035';
let _cod_agente = '00035';
let _comis_desc = 0;
let _null = null;
let _fecha_cierre = current;

select no_remesa
  into _no_remesa_agt
  from cobpaex0
 where numero = a_numero;

let _no_remesa_agt = sp_set_codigo(4, _no_remesa_agt);

select nombre,
	   cod_banco,
	   cod_chequera,
	   usuario
  into _nombre_agente,
	   _cod_banco,
	   _cod_chequera,
	   _user_cierre	   
  from cobcobra
 where cod_cobrador = _cod_cobrador;

let _periodo = sp_sis39(_fecha_cierre);

select cod_compania,
       cod_sucursal,
	   enlace_cat
  into _cod_compania,
       _cod_sucursal,
	   _cuenta_caja
  from chqchequ
 where cod_banco    = _cod_banco
   and cod_chequera = _cod_chequera;

insert into cobremae(
		no_remesa,   
		cod_compania,   
		cod_sucursal,   
		cod_banco,   
		cod_cobrador,   
		recibi_de,   
		tipo_remesa,   
		fecha,   
		comis_desc,   
		contar_recibos,   
		monto_chequeo,   
		actualizado,   
		periodo,   
		user_added,   
		date_added,   
		user_posteo,   
		date_posteo,
		cod_chequera)
values(	_no_remesa,
		_cod_compania,
		_cod_sucursal,
		_cod_banco,
		null,
		'REMESA DE CUADRE DE COBROS ' || trim(_nombre_agente) || _fecha_cierre,
		_tipo_remesa,
		_fecha_cierre,
		0,
		2,
		0,
		0,
		_periodo,
		_user_cierre,
		_fecha_cierre,
		_user_cierre,
		_fecha_cierre,
		_cod_chequera);

select max(renglon)
  into _renglon
  from cobredet
 where no_remesa = _no_remesa;

if _renglon is null then
	let _renglon = 0;
end if

select cta_nombre
  into _nom_cuenta
  from cglcuentas
 where cta_cuenta = _cuenta_caja;

select cedula
  into _cedula
  from agtagent
 where cod_agente = _cod_agente_duc;
 
let _tipo_mov = 'P';

foreach
	select poliza,
		   monto_cobrado,
		   no_recibo_agt,
		   monto_comis,
		   no_remesa_agt,
		   secuencia,
		   monto_remesar
	  into _no_documento,
		   _monto_recibo,
		   _no_recibo,
		   _monto_descontado,
		   _no_remesa_agt,
		   _secuencia,
		   _monto_remesar
	  from deivid_cob:duc_cuadre_cob
	 where procesado = 0
	   and no_remesa_agt = _no_remesa_agt 

	select count(*)
	  into _cnt_pago
	  from deivid_cob:duc_cob
	 where no_remesa_agt = _no_remesa_agt
	   and no_recibo_agt = _no_recibo
	   and poliza =  _no_documento
	   and procesado = 1
	   and (no_remesa_cierre is null or no_remesa_cierre = '');

	if _cnt_pago is null then
		let _cnt_pago = 0;
	end if

	if _cnt_pago = 0 then --No fue enviada por adelantado por lo que se procesa como pago a prima  

		let _comis_desc = 0;
		let _tipo_mov = 'P';
	
		if _monto_descontado <> 0 then
			let _comis_desc = 1;
			let _flag_comis_desc = 1;
		end if

		if _monto_recibo < 0 then
			let _tipo_mov = 'N';
		end if

	--------------****************										****************--------------

		let _flag_procesar = 1;
		call sp_sis21(_no_documento) returning _no_poliza;

		select cod_pagador,
			   estatus_poliza
		  into _cod_cliente,
			   _estatus_poliza
		  from emipomae
		 where no_poliza = _no_poliza;

		if _no_poliza is null then
			let _error_desc = 'No se encuentran registros de la Póliza.';
			let _flag_procesar = 0;
		elif _estatus_poliza in (2,4) then
			let _flag_procesar = 0;
			let _error_desc = 'La Póliza ha sido Cancelada/Anulada.';
		end if

		let _cnt_agt = 0;

		select count(*)
		  into _cnt_agt
		  from emipoagt
		 where no_poliza = _no_poliza
		   and cod_agente = _cod_agente_duc;

		if _cnt_agt is null then
			let _cnt_agt = 0;
		end if

		if _cnt_agt = 0 then
			let _flag_procesar = 0;
			let _error_desc = 'La Póliza no pertenece al corredor.';	
		end if

		if _flag_procesar = 0 then
			begin
			on exception in(-239,-268)
				update deivid_cob:duc_excep_cob
				   set procesado = 0
				 where no_remesa_agt = _no_remesa_agt
				   and poliza = _no_documento
				   and secuencia = _secuencia;
			end exception 	

			insert into deivid_cob:duc_excep_cob(
						no_remesa_agt,
						secuencia,
						poliza,
						monto_cobrado,
						motivo_error,
						procesado)
				values(	_no_remesa_agt,
						_secuencia,
						_no_documento,
						_monto_recibo,
						_error_desc,
						0);
			end	
			let _renglon  = _renglon + 1;
			let _tipo_mov = 'C';

			insert into cobredet(
					no_remesa,
					renglon,
					cod_compania,
					cod_sucursal,
					no_recibo,
					doc_remesa,
					tipo_mov,
					monto,
					prima_neta,
					impuesto,
					monto_descontado,
					comis_desc,
					desc_remesa,
					saldo,
					periodo,
					fecha,
					actualizado,
					no_poliza,
					cod_agente)
			values(	_no_remesa,
					_renglon,
					_cod_compania,
					_cod_sucursal,
					_no_recibo,
					_cedula,
					_tipo_mov,
					_monto_remesar,
					0.00,
					0.00,
					0.00,
					0,
					'MONTO REMESAR...' || trim(_no_documento),
					0.00,
					_periodo,
					_fecha_cierre,
					0,
					_null,
					_cod_agente_duc);						
			continue foreach;
		else
			select nombre
			  into _nom_cliente
			  from cliclien
			 where cod_cliente = _cod_cliente;

			call sp_cob115b(_cod_compania,_cod_sucursal,_no_documento,'') returning _saldo;

			if _saldo is null then
				let _saldo = 0;
			end if

			-- impuestos de la poliza
			select sum(i.factor_impuesto)
			  into _factor
			  from prdimpue i, emipolim p
			 where i.cod_impuesto = p.cod_impuesto
			   and p.no_poliza    = _no_poliza;

			if _factor is null then
				let _factor = 0;
			end if

			let _factor = 1 + _factor / 100;
			let _prima_neta = _monto_recibo / _factor;
			let _impuesto = _monto_recibo - _prima_neta;
			let _saldo    = _saldo - _monto_recibo;

			-- Descripcion de la Remesa
			let _nombre_agente = '';

			foreach
				select cod_agente
				  into _cod_agente
				  from emipoagt
				 where no_poliza = _no_poliza

				select nombre
				  into _nombre_agente
				  from agtagent
				 where cod_agente = _cod_agente;
				exit foreach;
			end foreach
		end if

		let _descripcion = trim(_nom_cliente) || '/' || trim(_nombre_agente);
		let _renglon = _renglon + 1;

		insert into cobredet(
				no_remesa,
				renglon,
				cod_compania,
				cod_sucursal,
				no_recibo,
				doc_remesa,
				tipo_mov,
				monto,
				prima_neta,
				impuesto,
				monto_descontado,
				comis_desc,
				desc_remesa,
				saldo,
				periodo,
				fecha,
				actualizado,
				no_poliza)
		values(	_no_remesa,
				_renglon,
				_cod_compania,
				_cod_sucursal,
				_no_recibo,
				_no_documento,
				_tipo_mov,
				_monto_recibo,
				_prima_neta,
				_impuesto,
				_monto_descontado,
				_comis_desc,
				_descripcion,
				_saldo,
				_periodo,
				_fecha_cierre,
				0,
				_no_poliza);

		insert into cobrepag(
				no_remesa,
				renglon,
				tipo_pago,
				tipo_tarjeta,
				cod_banco,
				fecha,
				no_cheque,
				girado_por,
				a_favor_de,
				importe)
		values(	_no_remesa,
				_renglon,
				'1',
				'',
				_cod_banco,
				_fecha_cierre,
				'',
				'',
				'',
				_monto_recibo);

	--------------****************		Información de Comisiones de Corredor		****************--------------

		let _comis_dif = 0.00;

		foreach
			select cod_agente,
				   porc_partic_agt,
				   porc_comis_agt
			  into _cod_agente,
				   _porc_partic_agt,
				   _porc_comis_agt
			  from emipoagt
			 where no_poliza = _no_poliza

			let _monto_calc = 0.00;

			let _monto_calc = _prima_neta * (_porc_partic_agt/100) * (_porc_comis_agt/100);
			let _comis_dif = _comis_dif + (_monto_calc - _monto_descontado);

			insert into cobreagt(
					no_remesa,
					renglon,
					cod_agente,
					monto_calc,
					monto_man,
					porc_comis_agt,
					porc_partic_agt)
			values(	_no_remesa,
					_renglon,
					_cod_agente,
					_monto_calc,
					_monto_descontado,
					_porc_comis_agt,
					_porc_partic_agt);
		end foreach

		update deivid_cob:duc_cuadre_cob
		   set no_remesa = _no_remesa,
			   renglon = _renglon,
			   procesado = 1,
			   fecha_procesado = _fecha_cierre
		 where no_remesa_agt = _no_remesa_agt
		   and secuencia = _secuencia;

		if _comis_dif <> 0.00 then
			{let _renglon  = _renglon + 1;
			let _tipo_mov = 'C';

			insert into cobredet(
					no_remesa,
					renglon,
					cod_compania,
					cod_sucursal,
					no_recibo,
					doc_remesa,
					tipo_mov,
					monto,
					prima_neta,
					impuesto,
					monto_descontado,
					comis_desc,
					desc_remesa,
					saldo,
					periodo,
					fecha,
					actualizado,
					no_poliza,
					cod_agente)
			values(	_no_remesa,
					_renglon,
					_cod_compania,
					_cod_sucursal,
					_no_recibo,
					_cedula,
					_tipo_mov,
					_comis_dif,
					0.00,
					0.00,
					0.00,
					0,
					'DIFERENCIA DE COMISON DESCONTADA...' || trim(_no_documento),
					0.00,
					_periodo,
					_fecha_cierre,
					0,
					_null,
					_cod_agente);}
		end if
	else
		begin
			on exception in(-239)
				update tmp_cieca
				   set monto = monto + _monto_remesar 
				 where cuenta = _cuenta_caja;
			end exception 	

			{insert into tmp_cieca(
					cuenta,
					monto,
					nombre)
			values(	_cuenta_caja,
					_monto_remesar,
					_nom_cuenta);}

			insert into tmp_cieca(
					cuenta,
					cod_auxiliar,
					monto,
					nombre)
			values(	_cuenta_caja,
					_cod_auxiliar,
					_monto_remesar,
					trim(_nom_cuenta) || ' R: ' || trim(_no_recibo) || ' P:'|| trim(_no_documento));
		end
		--/************************************************************************/
		--/ se adiciona para insertar en cobredet el mono_remesa y monto_descontado
		--/************************************************************************/
		
		call sp_sis21(_no_documento) returning _no_poliza;
		if _no_poliza is null then
			Let _error_desc = 'No se encuentran registros de la Póliza.';

			begin
			on exception in(-239,-268)
				update deivid_cob:duc_excep_cob
				   set procesado = 0
				 where no_remesa_agt = _no_remesa_agt
				   and poliza = _no_documento
				   and secuencia = _secuencia;
			end exception 	

			insert into deivid_cob:duc_excep_cob(
						no_remesa_agt,
						secuencia,
						poliza,
						monto_cobrado,
						motivo_error,
						procesado)
				values(	_no_remesa_agt,
						_secuencia,
						_no_documento,
						_monto_recibo,
						_error_desc,
						0);
			end										
		
			let _renglon  = _renglon + 1;
			let _tipo_mov = 'C';

			insert into cobredet(
					no_remesa,
					renglon,
					cod_compania,
					cod_sucursal,
					no_recibo,
					doc_remesa,
					tipo_mov,
					monto,
					prima_neta,
					impuesto,
					monto_descontado,
					comis_desc,
					desc_remesa,
					saldo,
					periodo,
					fecha,
					actualizado,
					no_poliza,
					cod_agente)
			values(	_no_remesa,
					_renglon,
					_cod_compania,
					_cod_sucursal,
					_no_recibo,
					_cedula,
					_tipo_mov,
					_monto_remesar,
					0.00,
					0.00,
					0.00,
					0,
					'MONTO REMESAR...' || trim(_no_documento),
					0.00,
					_periodo,
					_fecha_cierre,
					0,
					_null,
					_cod_agente_duc);
						
			let _renglon  = _renglon + 1;
			let _tipo_mov = 'C';

			insert into cobredet(
					no_remesa,
					renglon,
					cod_compania,
					cod_sucursal,
					no_recibo,
					doc_remesa,
					tipo_mov,
					monto,
					prima_neta,
					impuesto,
					monto_descontado,
					comis_desc,
					desc_remesa,
					saldo,
					periodo,
					fecha,
					actualizado,
					no_poliza,
					cod_agente)
			values(	_no_remesa,
					_renglon,
					_cod_compania,
					_cod_sucursal,
					_no_recibo,
					_cedula,
					_tipo_mov,
					_monto_recibo,
					0.00,
					0.00,
					0.00,
					0,
					'MONTO DESCONTADO...' || trim(_no_documento),
					0.00,
					_periodo,
					_fecha_cierre,
					0,
					_null,
					_cod_agente_duc);					
			end if			
			
		--/************************************************************************/
		
		update deivid_cob:duc_cob
		   set no_remesa_cierre = _no_remesa,
			   fecha_cierre = _fecha_cierre
		 where no_remesa_agt = _no_remesa_agt
		   and no_recibo_agt = _no_recibo
		   and poliza = _no_documento
		   and procesado = 1
		   and (no_remesa_cierre is null or no_remesa_cierre = '');		   

		update deivid_cob:duc_cuadre_cob
		   set no_remesa = _no_remesa,
			   renglon = _renglon,
			   procesado = 1,
			   fecha_procesado = _fecha_cierre
		 where no_remesa_agt = _no_remesa_agt
		   and secuencia = _secuencia;		   

	end if
end foreach

let _tipo_mov = 'M';

foreach
	select cuenta,
		   cod_auxiliar,
		   monto,
		   nombre
	  into _cuenta_caja,
		   _cod_auxiliar,
		   _monto,
		   _nom_cuenta
	  from tmp_cieca

	let _renglon = _renglon + 1;

	insert into cobredet(
	no_remesa,
	renglon,
	cod_compania,
	cod_sucursal,
	no_recibo,
	doc_remesa,
	tipo_mov,
	monto,
	prima_neta,
	impuesto,
	monto_descontado,
	comis_desc,
	desc_remesa,
	saldo,
	periodo,
	fecha,
	actualizado,
	no_poliza,
	cod_auxiliar
	)
	values(
	_no_remesa,
	_renglon,
	_cod_compania,
	_cod_sucursal,
	_renglon,
	_cuenta_caja,
	_tipo_mov,
	_monto,
	0.00,
	0.00,
	0.00,
	0,
	_nom_cuenta,
	0.00,
	_periodo,
	_fecha_cierre,
	0,
	null,
	_cod_auxiliar);
end foreach

--Verificacion de pagos reportados en remesas diarias que no fueron enviados en la remesa de cierre.

let _no_remesa_agt = '';
let _no_documento = '';
let _monto_recibo = 0.00;
let _secuencia = 0;
let _tipo_mov = 'C';

foreach
	select poliza,
		   no_remesa_agt,
		   secuencia,
		   monto_cobrado
	  into _no_documento,
		   _no_remesa_agt,
		   _secuencia,
		   _monto_recibo
	  from deivid_cob:duc_cob
	 where no_remesa_cierre is null
	   and procesado = 1
	   and no_remesa_agt = _no_remesa_agt 

	let _renglon = _renglon + 1;
	
	insert into cobredet(
			no_remesa,
			renglon,
			cod_compania,
			cod_sucursal,
			no_recibo,
			doc_remesa,
			tipo_mov,
			monto,
			prima_neta,
			impuesto,
			monto_descontado,
			comis_desc,
			desc_remesa,
			saldo,
			periodo,
			fecha,
			actualizado,
			no_poliza,
			cod_agente)
	values(	_no_remesa,
			_renglon,
			_cod_compania,
			_cod_sucursal,
			_no_recibo,
			_cedula,
			_tipo_mov,
			_monto_recibo,
			0.00,
			0.00,
			0.00,
			0,
			'PAGO NO REMESADO... ' || trim(_no_remesa_agt) || trim(_no_documento),
			0.00,
			_periodo,
			_fecha_cierre,
			0,
			_null,
			_cod_agente_duc);

	update deivid_cob:duc_cob
	   set no_remesa_cierre = _no_remesa,
		   fecha_cierre = _fecha_cierre,
		   procesado = 2
	 where no_remesa_agt = _no_remesa_agt
	   and secuencia = _secuencia
	   and poliza = _no_documento
	   and procesado = 1
	   and (no_remesa_cierre is null or no_remesa_cierre = '');
end foreach

-------------- **************** Monto total de la Remesas ****************--------------
select sum(monto)
  into _monto_total
  from cobredet
 where no_remesa = _no_remesa;

if _monto_total is null then
	let _monto_total = 0.00;
end if

update cobremae
   set monto_chequeo = _monto_total,
	   comis_desc = _flag_comis_desc
 where no_remesa     = _no_remesa;
 
 -----------------------------ADICION DE PAGO EN SUSPENSO-----------------------------
 select ubicacion_pago
  into _ubic_pago
  from cobforpaexm
 where cod_agente = _cod_agente_duc
   and tipo_formato = 1;
   
 if _ubic_pago = 1 then
  --if _ubic_pago = 2 then  -- se cambia para adicionar pago en suspenso HGIRON 22/02/2018
	let a_recibo_susp = trim(a_recibo_susp);
	--let a_recibo_susp = 'GB110112-01';

	if a_recibo_susp = '' or a_recibo_susp is null then
		let a_recibo_susp = _no_recibo;
	end if

	call sp_sis138b(a_recibo_susp) 
	returning	_nombre_cliente,
				_total_susp,
				_renglon,
				_fecha_recibo,
				_doc_remesa;

	if _renglon = 1 then
		drop table temp_gasto;
		return 1, 'no se encontro la prima en suspenso.';
	end if
	
	select max(renglon)
	  into _renglon
	  from cobredet
	 where no_remesa = _no_remesa;

	let _renglon = _renglon + 1;
	let _tipo_mov = 'A';
   	let _descripcion = trim(_nombre_cliente);

	{select sum(monto),
		   sum(monto_descontado)
	  into _monto_cob,
	  	   _monto_descontado
	  from cobredet
	 where no_remesa = _no_remesa
	   and tipo_mov = 'P';}

	let _total_susp = -1 * _total_susp; --(_monto_cob - _monto_descontado); 

	-- detalle de la remesa
	insert into cobredet(
			no_remesa,
			renglon,
			cod_compania,
			cod_sucursal,
			no_recibo,
			doc_remesa,
			tipo_mov,
			monto,
			prima_neta,
			impuesto,
			monto_descontado,
			comis_desc,
			desc_remesa,
			saldo,
			periodo,
			fecha,
			actualizado,
			no_poliza,
			cod_agente)
	values(	_no_remesa,
			_renglon,
			_cod_compania,
			_cod_sucursal,
			_no_recibo,
			_doc_remesa,
			_tipo_mov,
			_total_susp,
			0,
			0,
			0,
			0,
			_descripcion,
			0,
			_periodo,
			_fecha_cierre,
			0,
			null,
			_cod_agente_duc);
	
end if

update cobpaex0
   set no_remesa_ancon = _no_remesa
 where numero = a_numero;
 -----------------------------ADICION DE PAGO EN SUSPENSO-----------------------------

{call sp_cob29(_no_remesa, _user_cierre) returning _error, _error_desc; 

if _error <> 0 then
	return _error, _error_desc;
end if}

return 0, 'Actualizacion Exitosa, Remesa: ' || _no_remesa;
end
end procedure 