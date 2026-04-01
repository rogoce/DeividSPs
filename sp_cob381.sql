-- Procedimiento que Genera la Remesa de los Cobros diarios de Ducruet 
-- Creado    : 17/11/2015 - Autor: Roman Gordon   
-- SIS v.2.0 - DEIVID, S.A.  

drop procedure sp_cob381;
create procedure 'informix'.sp_cob381() 
returning	smallint,
			char(100),
			char(10);

define _nom_cliente			varchar(100);
define _descripcion			varchar(100);
define _error_desc			varchar(100);
define _nombre_agente		varchar(50);
define _cedula				varchar(30);
define _no_documento		char(20);
define _no_remesa_agt		char(10);
define _cod_cliente			char(10);
define _no_remesa			char(10);
define _no_recibo			char(10);
define _no_poliza			char(10);
define _user_added			char(8);
define _periodo				char(7);
define _cod_agente_duc2		char(5);
define _cod_agente_duc		char(5);
define _cod_agente			char(5);
define _cod_chequera		char(3);
define _cod_compania		char(3);
define _cod_sucursal		char(3);
define _cod_cobrador		char(3);
define _cod_banco			char(3);
define _tipo_mov			char(1);
define _tipo_remesa			char(1);
define _null				char(1);
define _porc_partic_agt		dec(5,2);
define _porc_comis_agt		dec(5,2);
define _monto_descontado	dec(16,2);
define _monto_recibo		dec(16,2);
define _monto_calc			dec(16,2);
define _prima_neta			dec(16,2);
define _comis_dif			dec(16,2);
define _impuesto			dec(16,2);
define _factor				dec(16,2);
define _saldo				dec(16,2);
define _estatus_poliza		smallint;
define _flag_procesar		smallint;
define _comis_desc			smallint;
define _cnt_existe			smallint;
define _secuencia			integer;
define _cnt_agt				smallint;
define _error_code			integer;
define _error_isam			integer;
define _registro			integer;
define _renglon				integer;
define _fecha				date;
define _cod_auxiliar		char(5);

set isolation to dirty read;

--set debug file to 'sp_cob317.trc';
--trace on ;

begin

on exception set _error_code, _error_isam, _error_desc 
 	return _error_code, _error_desc, '00000';
end exception 

select count (*)
  into _registro
  from deivid_cob:duc_cob
 where procesado = 0;

if _registro = 0 then
	return 0, 'Actualizacion Exitosa, No Hay Registros de Cobros', '00000'; 
end if

{create temp table tmp_libretas(
no_recibo	char(10)
) with no log;}
let _cod_auxiliar = 'A0894';
let _cod_cobrador	= '317';
let _cod_sucursal	= '001';
let _cod_compania	= '001';
let _tipo_remesa	= 'C';
let _cod_agente_duc	= '00035';
let _cod_agente_duc2 = '02154';
let _periodo		= '';
let _error_code		= 0;
let _null			= null;

select nombre,
	   cod_banco,
	   cod_chequera,
	   usuario
  into _nombre_agente,
	   _cod_banco,
	   _cod_chequera,
	   _user_added	   
  from cobcobra
 where cod_cobrador = _cod_cobrador;

let _no_remesa = sp_sis13(_cod_compania, 'COB', '02', 'par_no_remesa');

select count(*)
  into _cnt_existe
  from cobremae
 where no_remesa = _no_remesa;

if _cnt_existe is null then
	let _cnt_existe = 0;
end if

if _cnt_existe <> 0 then
	return 1, 'El Numero de Remesa Generado Ya Existe, Por Favor Actualice Nuevamente ...', '';
end if

let _fecha = today;
let _periodo = sp_sis39(_fecha);

select cedula
  into _cedula
  from agtagent
 where cod_agente = _cod_agente_duc;

--------------****************		Insertar el Maestro de Remesas		****************--------------

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
		_cod_cobrador,
		_nombre_agente,
		_tipo_remesa,
		_fecha,
		0,
		3,
		0.00,
		0,
		_periodo,
		_user_added,
		_fecha,
		_user_added,
		_fecha,
		_cod_chequera);

--ultimo numero de renglon 
select max(renglon)
  into _renglon
  from cobredet
 where no_remesa = _no_remesa;

if _renglon is null then
	let _renglon = 0;
end if

foreach
	select poliza,
		   monto_cobrado,
		   no_recibo_agt,
		   monto_comis,
		   no_remesa_agt,
		   secuencia
	  into _no_documento,
		   _monto_recibo,
		   _no_recibo,
		   _monto_descontado,
		   _no_remesa_agt,
		   _secuencia
	  from deivid_cob:duc_cob
	 where procesado = 0
	   --and fecha_pago = '06/08/2018'
	 order by secuencia

	let _tipo_mov = 'P';
  	let _comis_desc = 0;
  	let _impuesto = 0;
  	let _saldo    = 0;
  	let _prima_neta    = 0;
	
	if _monto_descontado <> 0 then
		let _comis_desc = 1;
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
	else
		{elif _estatus_poliza in (2,4) then
			let _flag_procesar = 0;
			let _error_desc = 'La Póliza ha sido Cancelada/Anulada.';}	
	
		let _cnt_agt = 0;

		select count(*)
		  into _cnt_agt
		  from emipoagt
		 where no_poliza = _no_poliza
		   and cod_agente in (_cod_agente_duc,_cod_agente_duc2,'02904');

		if _cnt_agt is null then
			let _cnt_agt = 0;
		end if

		if _cnt_agt = 0 then
			let _flag_procesar = 0;
			let _error_desc = 'La Póliza no pertenece al corredor.';	
		end if
	end if

	if _flag_procesar = 0 then
		begin
			on exception in(-268)
				update duc_excep_cob
				   set procesado = 0
				 where no_remesa_agt = _no_remesa_agt
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

		let _factor   = 1 + _factor / 100;
		let _prima_neta    = _monto_recibo / _factor;
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

--------------****************		Detalle de la Remesa		****************--------------
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
			cod_auxiliar)
	values(
			_no_remesa,
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
			_fecha,
			0,
			_no_poliza,
			_cod_auxiliar);

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
			_fecha,
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
	
	if _comis_dif <> 0.00 then
		
		if _comis_desc = 1 then
  
			begin
				on exception in(-268)
					update duc_excep_cob
					   set procesado = 0
					 where no_remesa_agt = _no_remesa_agt
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
						'Monto descontado difiere de cálculo de comisión descontada',
						0);
			end	
			--continue foreach;
			---   comision descontada	
		{else		
			
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
					_comis_dif,
					0.00,
					0.00,
					0.00,
					0,
					'DIFERENCIA DE COMISON DESCONTADA...' || trim(_no_documento),
					0.00,
					_periodo,
					_fecha,
					0,
					_null,
					_cod_agente);}
					---   comision descontada
		end if
	end if
	
	update deivid_cob:duc_cob
	   set no_remesa = _no_remesa,
		   renglon = _renglon,
	       procesado = 1,
		   fecha_procesado = current,
		   fecha_cierre = null
	 where no_remesa_agt = _no_remesa_agt
	   and secuencia = _secuencia;	
end foreach
--------------*************************                                                                                 *************************---------------------
-------------- **************** Monto total de la Remesas ****************--------------
select sum(monto)
  into _saldo
  from cobredet
 where no_remesa = _no_remesa;

if _saldo is null then
	let _saldo = 0.00;
end if

update cobremae
   set monto_chequeo = _saldo
 where no_remesa     = _no_remesa;

-- Actualizacion de la Remesa
call sp_cob29(_no_remesa, _user_added) returning _error_code, _error_desc;
if _error_code <> 0 then
	return _error_code, _error_desc || ' Remesa # ' || _no_remesa, _no_remesa;
end if

return 0, 'Actualizacion Exitosa, Remesa # ' || _no_remesa, _no_remesa; 		
end 
end procedure;