-- Procedimiento que Genera la Remesa de los Cobros de Tecnica de Seguros
-- Creado    : 21/01/2013 - Autor: Roman Gordon
-- SIS v.2.0 - DEIVID, S.A.

drop procedure sp_cob317;
create procedure "informix".sp_cob317() 
returning	smallint,
			char(100),
			char(10);

define _nom_cliente 	char(100);
define _descripcion   	char(100);
define _error_desc		char(100);
define _nombre_agente 	char(50);
define _no_documento 	char(18);
define _no_recibo_min	char(10);
define _no_remesa_d		char(10);
define _cod_cliente 	char(10);
define _no_remesa		char(10);
define _no_recibo		char(10);
define _no_poliza    	char(10);
define _user_added		char(8);
define _periodo			char(7);
define _cod_agente   	char(5);
define _no_secuencia    char(4);
define _cod_libreta_n	char(3);
define _cod_chequera	char(3);
define _cod_compania	char(3);
define _cod_sucursal	char(3);
define _cod_cobrador    char(3);
define _cod_libreta		char(3);
define _cod_banco       char(3);
define _banco           char(3);
define _tipo_mov        char(1);
define _null            char(1);
define _porc_partic		dec(5,2);
define _porc_comis		dec(5,2);
define _monto_recibo	dec(16,2);
define _impuesto		dec(16,2);
define _factor			dec(16,2);
define _saldo        	dec(16,2);
define _prima			dec(16,2);
define _cant_suspe		smallint;
define _encontrado		smallint;
define _cnt				smallint;
define _error_code      integer;
define _error_isam		integer;
define _renglon_d		integer;
define _registro		integer;
define _no_unico		integer;
define _renglon      	integer;
define _flag2			integer;
define _flag			integer;
define _fecha			date;

set isolation to dirty read;

--set debug file to "sp_cob317.trc";
--trace on ;

begin

on exception set _error_code, _error_isam, _error_desc 
 	return _error_code, _error_desc, _error_desc;
end exception 

select count (*)
  into _registro
  from tec_historico
 where no_remesa is null;

if _registro = 0 then
	return 0, 'Actualizacion Exitosa, No Hay Registros de Cobros', "00000"; 
end if

{create temp table tmp_libretas(
no_recibo	char(10)
) with no log;}

let _cod_cobrador	= "266";
let _cod_chequera	= '042';
let _cod_sucursal	= '001';
let _cod_compania	= '001';
let _no_remesa_d	= '';
let _user_added		= "DEIVID";
let _cod_banco		= "";
let _periodo		= '';
let _null			= null;
let _error_code		= 0;
let _renglon_d		= 0;

let _no_remesa = sp_sis13(_cod_compania, 'COB', '02', 'par_no_remesa');

select fecha
  into _fecha
  from cobremae
 where no_remesa = _no_remesa;

if _fecha is not null then
	return 1, 'El Numero de Remesa Generado Ya Existe, Por Favor Actualice Nuevamente ...', '';
end if

let _fecha = today;
--let _fecha = today - 1 units day;
--let _fecha = '29/08/2016';

if month(_fecha) < 10 then
	let _periodo = year(_fecha) || '-0' || month(_fecha);
else
	let _periodo = year(_fecha) || '-' || month(_fecha);
end if

--Buscar el banco en parametros
select valor_parametro
  into _banco
  from inspaag
 where codigo_compania  = "001"
   and codigo_agencia   = "001"
   and aplicacion       = "COB"
   and version          = "02"
   and codigo_parametro = "banco_wun";

select cod_libreta
  into _cod_libreta
  from cobcobra
 where cod_cobrador = _cod_cobrador;

--------------****************Insertar el Maestro de Remesas****************--------------
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
		_banco,
		_cod_cobrador,
		"TECNICA DE SEGUROS",
		'A',
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

update tec_historico
   set no_remesa = _no_remesa
 where no_remesa is null;

--ultimo numero de renglon
select max(renglon)
  into _renglon
  from cobredet
 where no_remesa = _no_remesa;

if _renglon is null then
	let _renglon = 0;
end if

foreach
	select no_documento,
		   monto_recibo,
		   no_recibo,
		   tipo_recibo
	  into _no_documento,
		   _monto_recibo,
		   _no_recibo,
		   _tipo_mov
	  from tec_historico
	 where no_remesa = _no_remesa
	 order by no_recibo

	let _encontrado = 0;
  	let _impuesto = 0;
  	let _saldo    = 0;
  	let _prima    = 0;

--------------****************Verificación de Recibos en otras Remesas****************--------------
	foreach
		select no_remesa,
			   renglon 
		  into _no_remesa_d,
			   _renglon_d
		  from cobredet
		 where no_recibo   = _no_recibo
		   and actualizado = 1 
		   and tipo_mov    matches '*' 
		   and no_remesa   <> _no_remesa
		 order by no_remesa, renglon

		let _encontrado = 1;
		exit foreach;
	end foreach

	if _encontrado = 1 then
		let _error_desc = "El Recibo #: " || _no_recibo || " Fue Capturado en la Remesa #: " || trim(_no_remesa_d) || " Renglon #: " || _renglon_d;
		return 1,_error_desc,'';
	end if

--------------****************                                                                         ****************--------------
	call sp_sis21(_no_documento) returning _no_poliza;

	if _no_poliza is null and _tipo_mov <> 'B' then
		let _nombre_agente  = " ";
		let _nom_cliente	= '';
		let _tipo_mov		= 'E';  --Crear prima en suspenso
	else
		select cod_pagador
		  into _cod_cliente
		  from emipomae
		 where no_poliza = _no_poliza;

		select nombre
		  into _nom_cliente
		  from cliclien
		 where cod_cliente = _cod_cliente;

		call sp_cob115b(_cod_compania,_cod_sucursal,_no_documento,"") returning _saldo;
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
		let _prima    = _monto_recibo / _factor;
		let _impuesto = _monto_recibo - _prima;
		let _saldo    = _saldo - _monto_recibo;

		-- Descripcion de la Remesa
		let _nombre_agente = " ";

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

	let _descripcion = trim(_nom_cliente) || "/" || trim(_nombre_agente);
	
	if _descripcion is null then
		let _descripcion = trim(_nombre_agente);
	end if

--------------****************Movimiento de Pago en Suspenso****************--------------
	if _tipo_mov = "E" then -- Crear Prima Suspenso
		let _nombre_agente  = "-";
		let _no_poliza      = null;
		let _nom_cliente	= '';

		select count(*)
		  into _cant_suspe
		  from cobsuspe
		 where doc_suspenso = _no_documento;

		if _cant_suspe <> 0 then
			update cobsuspe
			   set monto        = monto + _monto_recibo				  					
			 where doc_suspenso = _no_documento;
		else
			insert into cobsuspe(
					doc_suspenso,
					cod_compania,
					cod_sucursal,
					monto,
					fecha,
					coaseguro,
					asegurado,
					poliza,
					ramo,
					actualizado,
					user_added,
					date_added)
			values(	_no_documento,
					_cod_compania,
					_cod_sucursal,
					_monto_recibo,
					_fecha,
					"",
					_nom_cliente,
					_no_documento,
					_null,
					0,
					_user_added,
					_fecha);		
		end if
	end if
--------------****************                                                                         ****************--------------	 
--------------****************Detalle de la Remesa 				****************--------------
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
	values(
			_no_remesa,
			_renglon,
			_cod_compania,
			_cod_sucursal,
			_no_recibo,
			_no_documento,
			_tipo_mov,
			_monto_recibo,
			_prima,
			_impuesto,
			0,
			0,
			_descripcion,
			_saldo,
			_periodo,
			_fecha,
			0,
			_no_poliza);

	update tec_historico
	   set no_renglon   = _renglon
	 where no_remesa    = _no_remesa
	   and no_documento = _no_documento;

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
			'2',			--se cambia de efectivo = 1 a cheque = 2 08/07/2016
			'',
			_cod_banco,
			_fecha,
			'',
			'',
			"",
			_monto_recibo);

--------------****************Movimiento de Recibo Anulado****************--------------
	if _tipo_mov = 'B' then

		update cobredet
		   set monto            = 0,
			   prima_neta       = 0,
			   impuesto		    = 0,
			   monto_descontado = 0,
			   desc_remesa      = "Anula Recibo " || _no_recibo,
			   saldo            = 0,
			   tipo_mov         = "B"
		 where no_remesa        = _no_remesa
		   and renglon			= _renglon;

		update cobrepag
		   set importe = 0
		 where no_remesa	= _no_remesa
		   and renglon		= _renglon;
	else
		foreach
			select cod_agente,
				   porc_partic_agt,
				   porc_comis_agt
			  into _cod_agente,
				   _porc_partic,
				   _porc_comis
			  from emipoagt
			 where no_poliza = _no_poliza

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
					0,
					0,
					_porc_comis,
					_porc_partic);  
		end foreach
	end if	
end foreach

--------------*************************                                                                                 *************************---------------------
--------------*************************Verifiación de Recibos y Cambio de Libretas*************************---------------------
foreach
	select no_recibo	
	  into _no_recibo_min
	  from cobredet
	 where no_remesa = _no_remesa
	 order by no_recibo
	exit foreach;
end foreach

foreach
	select no_recibo	
	  into _no_recibo
	  from cobredet
	 where no_remesa = _no_remesa
	 order by no_recibo

	if (_no_recibo - _no_recibo_min) > 1 then
		select count(*)
		  into _cnt
		  from coblibre
		 where rango_recibo1 = _no_recibo;

		if _cnt > 0 then
			select count(*)
			  into _cnt
			  from coblibre
			 where rango_recibo2 = _no_recibo_min;
			if _cnt > 0 then
				select cod_libreta
				  into _cod_libreta_n
				  from coblibre
				 where rango_recibo1 = _no_recibo;

				update coblibre
				   set ult_no_recibo		= _no_recibo_min,
					   fecha_fin_libreta	= _fecha,
					   usada = 1
				 where cod_libreta = _cod_libreta;				  

				let _cod_libreta = _cod_libreta_n;
				
				update coblibre
				   set ult_no_recibo	= _no_recibo
				 where cod_libreta		= _cod_libreta;
				 
				update cobcobra
				   set cod_libreta	= _cod_libreta_n
				 where cod_cobrador	= _cod_cobrador;
			else
				let _no_recibo_min = _no_recibo_min + 1;
				let _flag = 1;
				exit foreach;
			end if
		else
			let _no_recibo_min = _no_recibo_min + 1;
			let _flag = 1;
			exit foreach;
		end if
	else
		update coblibre
		   set ult_no_recibo	= _no_recibo
		 where cod_libreta		= _cod_libreta;	 
	end if
	let _no_recibo_min = _no_recibo;	
end foreach

--------------*****************                                                  ****************--------------
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
	return _error_code, _error_desc || " Remesa # " || _no_remesa, _no_remesa;
end if

return 0, 'Actualizacion Exitosa, Remesa # ' || _no_remesa, _no_remesa; 		
end 
end procedure;