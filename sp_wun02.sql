-- Procedimiento que Genera la Remesa de los Cobros de Western Union

-- Creado    : 11/06/2009 - Autor: Itzis Nunez B.
-- Modificado: 11/06/2009 - Autor: Itzis Nunez B.
-- Modificado: 21/07/2015 - Autor: Román Gordón C.	--Verificación de Pronto Pago 21/07/2015
-- SIS v.2.0 - DEIVID, S.A.

drop procedure sp_wun02;
create procedure "informix".sp_wun02() 
returning	smallint,
            char(100),
            char(10);

define _nom_cliente 	char(100);
define _descripcion   	char(100);
define _mensaje         char(100);
define _nombre_agente 	char(50);
define _error_desc		char(50);
define _no_documento 	char(18);
define _cod_pagador     char(10);
define _cod_cliente 	char(10);
define a_no_remesa      char(10);
define a_no_recibo      char(10);
define _cod_agente   	char(10);
define _no_poliza    	char(10); 
define _recibo          char(10);
define _user_added		char(8);
define _periodo			char(7);
define _no_secuencia    char(4);
define _cod_compania	char(3);
define _cod_sucursal	char(3);
define _cod_cobrador    char(3);
define _cod_banco       char(3);
define _banco           char(3);
define _tipo_mov        char(1);
define _null            char(1);
define _porc_partic		dec(5,2);
define _porc_comis		dec(5,2);
define _monto_pago		dec(11,2); 
define _monto_total     dec(16,2);
define _impuesto		dec(16,2);
define _we_itbms		dec(16,2);
define _factor			dec(16,2);
define _we_fee			dec(16,2);
define _prima			dec(16,2);
define _saldo        	dec(16,2);
define _cant_suspe		smallint;
define _cant_tran		smallint;
define _cant_mes		smallint;
define _monto_total_d   integer;
define _monto_pago_d	integer;
define _flag,_flag2	    integer;
define _error_code      integer;
define _error_isam		integer;
define _registro		integer;
define _no_unico		integer;
define _renglon      	integer;  
define _existe          integer;
define _fecha			date;
define _periodo_hoy		char(7);

set isolation to dirty read;

--SET DEBUG FILE TO "sp_wun02.trc";
--TRACE ON ;

begin
on exception set _error_code, _error_isam, _error_desc 
 	return _error_code, _error_desc, _error_desc;
end exception 

select count (*)
  into _registro
  from deivid_cob:wun_historico
 where no_remesa is null;

delete from deivid_cob:wun_historico where cob_comp_nro is null and no_remesa is null;

if _registro = 0 then
	return 0, 'Actualizacion Exitosa, No Hay Registros de Cobros', "00000"; 
end if

let _cod_sucursal = '001';
let _cod_compania = '001';
let _cod_cobrador = "161";
let _user_added = "DEIVID";
let a_no_remesa = '1';  
let _error_code = 0;
let _cod_banco = "";
let _tipo_mov = 'P';
let _periodo = '';
let _existe = 0;
let _null = NULL;

let a_no_remesa = sp_sis13(_cod_compania, 'COB', '02', 'par_no_remesa');

select fecha
  into _fecha
  from cobremae
 where no_remesa = a_no_remesa;

if _fecha is not null then
	return 1, 'El Numero de Remesa Generado Ya Existe, Por Favor Actualice Nuevamente ...', '';
end if

let _fecha = today;

--let _fecha = '28/09/2016';
/*
if month(_fecha) < 10 then
	let _periodo = year(_fecha) || '-0' || month(_fecha);
else
	let _periodo = year(_fecha) || '-' || month(_fecha);
end if
*/
select cob_periodo
  into _periodo
  from deivid:parparam;
  
  call sp_sis39(_fecha) RETURNING _periodo_hoy;
 /*   --ultimo dia del mes del periodo
  if _periodo <> _periodo_hoy then
	--CALL sp_sis36(_periodo) RETURNING _fecha;
	LET _fecha = MDY(_periodo[6,7], 1, _periodo[1,4]);  -- Correción HIRON, 23/08/2018 AMORENO, WUNION remesa 1352240 . \\files01\Imagenes_sis\bk_wunion\IN\WU310718.txt
  end if
 */ 
    --ultimo dia del mes del periodo
  if _periodo <> _periodo_hoy then
		if _periodo < _periodo_hoy then
			CALL sp_sis36(_periodo) RETURNING _fecha;
		else
			CALL sp_sis36bk(_periodo) RETURNING _fecha;
		end if
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

-- Insertar el Maestro de Remesas

INSERT INTO cobremae(
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
VALUES(	a_no_remesa,
		_cod_compania,
		_cod_sucursal,
		_banco,
		_cod_cobrador,
		"WESTERN UNION",
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
		'024');

update deivid_cob:wun_historico
   set no_remesa = a_no_remesa
 where no_remesa is null;

--ultimo numero de renglon
select max(renglon)
  into _renglon
  from cobredet
 where no_remesa = a_no_remesa;

if _renglon is null then
	let _renglon = 0;
end if

select max(no_unico)
  into _no_unico
  from deivid_cob:wun_historico;

if _no_unico is null then
	let _no_unico = 0;
end if

foreach
	select cob_cliente_nro,
		   cob_cliente_nomb,
		   cob_comp_imp,
		   cob_seq_nro,
		   cob_comp_nro,
		   cob_cobro_imp
	  into _cod_cliente,
		   _nom_cliente,
		   _monto_total_d,
		   _no_secuencia,
		   _no_documento,
		   _monto_pago_d
	  from deivid_cob:wun_historico
	 where no_remesa = a_no_remesa
	 order by cob_seq_nro

	if _nom_cliente is null then
		let _nom_cliente = '';
	end if

	let _monto_total = _monto_pago_d / 100;
	let _monto_pago  = _monto_pago_d  / 100;
	let _no_unico = _no_unico + 1;
 
	-- Numero de Recibo
	let _recibo     = sp_sis79(_no_unico);
	let a_no_recibo = _cod_cobrador || '-' || _recibo;
  
  	let _saldo    = 0;
  	let _prima    = 0;
  	let _impuesto = 0;

	if _tipo_mov = "P" then		--Pago de Prima

		let _no_poliza = sp_sis21(_no_documento);

		if _no_poliza is null then
			let _tipo_mov   = 'E';  --Crear prima en suspenso
			let _nombre_agente  = " ";	
		else
		    call sp_cob115b(_cod_compania,_cod_sucursal,_no_documento,"") returning _saldo;

			if _saldo is null then
				let _saldo = 0;
			end if

			-- Impuestos de la Poliza

			select sum(i.factor_impuesto)
			  into _factor
			  from prdimpue i, emipolim p
			 where i.cod_impuesto = p.cod_impuesto
			   and p.no_poliza    = _no_poliza;

			if _factor is null then
				let _factor = 0;
			end if

			let _factor   = 1 + _factor / 100;
			let _prima    = _monto_pago / _factor;
			let _impuesto = _monto_pago - _prima;
			let _saldo    = _saldo - _monto_pago;

			if _monto_total <= 0 then
				continue foreach;
			end if

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
	end if

	if _tipo_mov = "E" then -- Crear Prima Suspenso

	   	let _nombre_agente  = "-";
	   	let _no_poliza      = null;
	   	let _no_documento   = a_no_recibo;
	
		select count(*)
		  into _cant_suspe
		  from cobsuspe
		 where doc_suspenso = _no_documento;
		 
		if _cant_suspe <> 0 then
			update cobsuspe
			   set monto = monto + _monto_total				  					
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
					_monto_pago,
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

	let _descripcion = trim(_nom_cliente) || "/" || trim(_nombre_agente);

	-- detalle de la remesa
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
	values(	a_no_remesa,
			_renglon,
			_cod_compania,
			_cod_sucursal,
			a_no_recibo,
			_no_documento,
			_tipo_mov,
			_monto_pago,
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

	update deivid_cob:wun_historico
	   set no_renglon   = _renglon,
		   no_unico     = _no_unico
	 where no_remesa    = a_no_remesa
	   and cob_comp_nro = _no_documento;

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
	values(	a_no_remesa,
			_renglon,
			'1',
			'',
			_cod_banco,
			_fecha,
			'',
			'',
			"",
			_monto_pago);
	   
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
		values(	a_no_remesa,
				_renglon,
				_cod_agente,
				0,
				0,
				_porc_comis,
				_porc_partic
				);  
	end foreach
end foreach

-- Impuestos y Fee
select count(*)
  into _cant_mes
  from cobredet
 where cod_compania   = "001"
   and actualizado    = 1
   and tipo_mov       = "P"
   and periodo        = _periodo
   and no_recibo[1,3] = "161";

select count(*)
  into _cant_tran
  from cobredet
 where no_remesa = a_no_remesa;

let _cant_mes = _cant_mes + _cant_tran;

if _cant_mes <= 5000 then
	let _we_fee = 0.75;
elif _cant_mes > 5000 and _cant_mes <= 15000 then
	let _we_fee = 0.70;
else
	let _we_fee = 0.60;
end if

let _we_fee = _we_fee * _cant_tran;
let _we_itbms = _we_fee * 0.07;
let _saldo = _we_fee + _we_itbms;
let _saldo = _saldo * -1;

let _renglon = _renglon + 1;

let _no_documento = "6000184";
let _tipo_mov     = "M";
let a_no_recibo   = "WU-" || a_no_remesa;


select cta_nombre
  into _descripcion
  from cglcuentas
 where cta_cuenta = _no_documento;

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
values(	a_no_remesa,
		_renglon,
		_cod_compania,
		_cod_sucursal,
		a_no_recibo,
		_no_documento,
		_tipo_mov,
		_saldo,
		0.00,
		0.00,
		0,
		0,
		_descripcion,
		0.00,
		_periodo,
		_fecha,
		0,
		null,
		"02503");

-- Monto total de la remesa
select sum(monto)
  into _saldo
  from cobredet
 where no_remesa = a_no_remesa;
	
if _saldo is null then
	let _saldo = 0.00;
end if

update cobremae
   set monto_chequeo = _saldo
 where no_remesa     = a_no_remesa;

-- Actualizacion de la Remesa
call sp_cob29(a_no_remesa, _user_added) returning _error_code, _error_desc;

if _error_code <> 0 then
	return _error_code, _error_desc || " Remesa # " || a_no_remesa, a_no_remesa;
end if

--Verificación de Pronto Pago 21/07/2015
foreach
	select no_poliza
	  into _no_poliza
	  from cobredet
	 where no_remesa = a_no_remesa
	   and tipo_mov in ('P')
	   and actualizado = 1

	call sp_pro863(_no_poliza,0.00,_user_added,a_no_remesa) returning _error_code, _error_desc;

	if _error_code not in (0,1,2) then
		return _error_code, _error_desc || " Remesa # " || a_no_remesa, a_no_remesa;
	end if
end foreach

return 0, 'Actualizacion Exitosa, Remesa # ' || a_no_remesa, a_no_remesa; 

end
end procedure;