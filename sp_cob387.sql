-- SIS v.2.0 - DEIVID, S.A.

drop procedure sp_cob387a;
create procedure "informix".sp_cob387a(a_no_remesa_reversar char(10)) 
returning	smallint,
			char(100),
			char(10);

define _nom_cliente 	char(100);
define _descripcion   	char(100);
define _motivo_rechazo  char(100);
define _error_desc		char(100);
define _nombre_agente 	char(50);
define _no_cuenta	 	char(30);
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
define _fecha_gestion	datetime year to second;

set isolation to dirty read;

--set debug file to "sp_cob317.trc";
--trace on ;

begin

on exception set _error_code, _error_isam, _error_desc 
 	return _error_code, _error_desc, _error_desc;
end exception 


{create temp table tmp_libretas(
no_recibo	char(10)
) with no log;}

let _cod_cobrador	= "266";
let _cod_chequera	= '023';
let _cod_sucursal	= '001';
let _cod_compania	= '001';
let _no_remesa_d	= '';
let _user_added		= "DEIVID";
let _cod_banco		= "";
let _periodo		= '';
let _null			= null;
let _error_code		= 0;
let _renglon_d		= 0;
let _fecha_gestion  = current year to second;	
let _motivo_rechazo = "RECHAZO FUERA DE HORA BANCO GENERAL";

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
let _fecha = '04/10/2016';

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
		'311',
		_motivo_rechazo,
		'C',
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
	select cuenta,
		   no_documento,
		   monto * -1
	  into _no_cuenta,
		   _no_documento,
		   _monto_recibo
	  from tmp_rechazos

	{select doc_remesa,
		   monto * -1
	  into _no_documento,
		   _monto_recibo
	  from cobredet
	 where no_remesa = a_no_remesa_reversar}

	let _renglon = _renglon + 1;
	let _no_poliza =  sp_sis21(_no_documento);

	-- impuestos de la poliza
	select sum(i.factor_impuesto)
	  into _factor
	  from prdimpue i, emipolim p
	 where i.cod_impuesto = p.cod_impuesto
	   and p.no_poliza    = _no_poliza;

	if _factor is null then
		let _factor = 0;
	end if

	let _saldo = 0.00;
	let _factor   = 1 + _factor / 100;
	let _prima    = _monto_recibo / _factor;
	let _impuesto = _monto_recibo - _prima;
	let _saldo    = _saldo - _monto_recibo;

	select cod_pagador
	  into _cod_cliente
	  from emipomae
	 where no_poliza = _no_poliza;

	select nombre
	  into _nom_cliente
	  from cliclien
	 where cod_cliente = _cod_cliente;

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
	
	let _descripcion = trim(_nom_cliente) || "/" || trim(_nombre_agente);
	
	if _descripcion is null then
		let _descripcion = trim(_nombre_agente);
	end if

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
	values( _no_remesa,
			_renglon,
			'001',
			'001',
			'RACH250917',
			_no_documento,
			'N',
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
	
	let _fecha_gestion  = _fecha_gestion + 1 units second;

	insert into cobgesti(
			no_poliza,
			fecha_gestion,
			desc_gestion,
			user_added,
			no_documento,
			fecha_aviso,
			tipo_aviso,
			cod_pagador)
	values(	_no_poliza,
			_fecha_gestion,
			_motivo_rechazo,
			'DEIVID',
			_no_documento,
			NULL,
			0,
			_cod_cliente);
	
	update cobcutas
	   set rechazada = 1
	 where no_cuenta = _no_cuenta
	   and no_documento = _no_documento;
end foreach

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

return 0, 'Actualizacion Exitosa, Remesa # ' || _no_remesa, _no_remesa; 		
end 
end procedure; 
