-- Procedimiento que Genera la Remesa de las Tarjetas de Credito
-- Creado    : 22/02/2001 - Autor: Demetrio Hurtado Almanza 
-- Modificado: 28/06/2001 - Autor: Demetrio Hurtado Almanza
-- SIS v.2.0 - DEIVID, S.A.
-- execute procedure sp_cob50('001','001','MARILUZ','V')

drop procedure hg_cob50;



create procedure "informix".hg_cob50(
a_compania		char(3),
a_sucursal		char(3),
a_user			char(8),
a_tipo          char(1))
returning	smallint,
            char(100),
            char(10);

define _descripcion		char(100);
define _error_desc		char(100);
define _nombre_cliente	char(50);
define _motivo_rechazo	char(50);
define _nombre_agente	char(50);
define _recibi_de		char(50);
define _mensaje			char(50);
define _no_tarjeta		char(19);
define _no_documento	char(18); 
define _cod_pagador		char(10);
define _no_remesa		char(10);
define _no_recibo		char(10);
define _cod_agente		char(10);
define _no_poliza		char(10); 
define _periodo			char(7);
define _ano_char		char(4);
define _cod_chequera	char(3);  
define _cod_cobrador	char(3);
define _cod_banco		char(3);
define _cod_ramo		char(3);
define _tipo_tarjeta	char(1);
define _tipo_mov		char(1);
define _null			char(1);
define _porc_partic		dec(5,2);
define _porc_comis		dec(5,2);
define _cargo_especial	dec(16,2);
define _por_vencer		dec(16,2);
define _saldo_mor		dec(16,2);
define _corriente		dec(16,2);
define _exigible		dec(16,2);
define _monto_30		dec(16,2);
define _monto_60		dec(16,2);
define _monto_90		dec(16,2);
define _impuesto		dec(16,2);
define _factor			dec(16,2);
define _monto			dec(16,2);
define _prima			dec(16,2);
define _saldo			dec(16,2);
define _pronto_pago		smallint;
define cnt_flag			smallint;
define _fec_ano			smallint;
define _fec_mes			smallint;
define _dia_hoy			smallint;
define _dia_esp			smallint;
define _dia_sig			smallint;
define _dia				smallint;
define _cnt				smallint;
define _error_code		integer;
define _renglon			integer;
define _error			integer;
define _fecha_sig		date;
define _fecha_inicio	date;
define _fecha_hasta		date;
define _fec_rec			date;
define _fecha			date;
define _fecha_gestion	datetime year to second;

--set debug file to "sp_cob50.trc"; 
--trace on;                                                                

set isolation to dirty read;

begin
on exception set _error_code
	begin
		on exception in(-255)
		end exception
		rollback work;
	end 

 	return _error_code, 'Error al Actualizar la Remesa de Tarjetas de Credito', '';         
end exception           

let _no_remesa	= '1';
let _tipo_mov   = 'P'; 
let _fec_rec    = current;
let _fecha_sig = _fec_rec + 1 units day;
let _fec_ano    = year(_fec_rec);
let _fec_mes    = month(_fec_rec);
let _null       = null;

let _no_remesa = sp_sis13(a_compania, 'COB', '02', 'par_no_remesa');

select fecha
  into _fecha
  from cobremae
 where no_remesa = _no_remesa;

if _fecha is not null then
	return 1, 'El Numero de Remesa Generado Ya Existe, Por Favor Actualize Nuevamente ...', '';
end if	

let _fecha = today;
let _dia_hoy = day(_fecha);

if month(_fecha) < 10 then
	let _periodo = year(_fecha) || '-0' || month(_fecha);
else
	let _periodo = year(_fecha) || '-' || month(_fecha);
end if

-- Numero de Comprobante

let _no_recibo = 'VC';	-- Visa Cargo

if day(_fecha) < 10 then
	let _no_recibo = trim(_no_recibo) || '0' || day(_fecha);
else
	let _no_recibo = trim(_no_recibo) || day(_fecha);
end if

if month(_fecha) < 10 then
	let _no_recibo = trim(_no_recibo) || '0' || month(_fecha);
else
	let _no_recibo = trim(_no_recibo) || month(_fecha);
end if

let _ano_char   = year(_fecha);
let _no_recibo = trim(_no_recibo) || _ano_char[3,4];

select valor_parametro
  into _cod_banco
  from inspaag
 where codigo_compania  = '001'
   and codigo_agencia   = '001'
   and aplicacion       = 'COB'
   and version          = '02'
   and codigo_parametro = 'caja_caja';

let _cod_banco = trim(_cod_banco);

foreach
	select no_tarjeta
	  into _no_tarjeta
	  from cobtatra

	select tipo_tarjeta
	  into _tipo_tarjeta
	  from cobtahab
	 where no_tarjeta = _no_tarjeta;

	exit foreach;
end foreach

if _tipo_tarjeta = "4" then
	let a_tipo = "A";
else
	let a_tipo = "V";
end if

if a_tipo = "A" then  --american
	select valor_parametro
	  into _cod_chequera
	  from inspaag
	 where codigo_compania  = '001'
	   and codigo_agencia   = '001'
	   and aplicacion       = 'COB'
	   and version          = '02'
	   and codigo_parametro = 'caja_american';

	let _recibi_de = "REMESA DE TARJETA DE CREDITO AMEX: " || _no_recibo;
else
	select valor_parametro
	  into _cod_chequera
	  from inspaag
	 where codigo_compania  = '001'
	   and codigo_agencia   = '001'
	   and aplicacion       = 'COB'
	   and version          = '02'
	   and codigo_parametro = 'caja_visa';

	let _recibi_de = "REMESA DE TARJETA DE CREDITO: " || _no_recibo;
end if

-- Insertar el Maestro de Remesas
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
		a_compania,
		a_sucursal,
		_cod_banco,
		_null,
		_recibi_de,
		'C',
		_fecha,
		0,
		3,
		0.00,
		0,
		_periodo,
		a_user,
		_fecha,
		a_user,
		_fecha,
		_cod_chequera);

let _renglon = 0;

foreach with hold
	select no_documento,
		   monto,
		   nombre,
		   no_tarjeta,
		   pronto_pago
	  into _no_documento,
		   _monto,
		   _nombre_cliente,
		   _no_tarjeta,
		   _pronto_pago
	  from cobtatra
	 where procesar = 1	 --tarjetas aprobadas
	 order by nombre

	begin
		on exception in(-535)

		end exception 	
		begin work;
	end

	-- desmarcar rechazadas a tarjetas aprobadas.
	update cobtahab
	   set rechazada  = 0
	 where no_tarjeta = _no_tarjeta;

	let _renglon   = _renglon + 1;
	let _no_poliza = sp_sis21(_no_documento);

	select dia_especial,
		   fecha_inicio,
		   fecha_hasta,
		   dia
	  into _dia_esp,
		   _fecha_inicio,
		   _fecha_hasta,
		   _dia
	  from cobtacre
	 where no_tarjeta = _no_tarjeta
	   and no_documento = _no_documento;

	select cod_ramo
	  into _cod_ramo
	  from emipomae
	 where no_poliza = _no_poliza;

	if _cod_ramo = '018' then
		call sp_cob353(_no_tarjeta,_no_documento,_monto,'TCR') returning _error,_error_desc;
	end if

	-- este update es para marcar la poliza como NO rechazada.
	update cobtacre
	   set rechazada    = 0
	 where no_tarjeta   = _no_tarjeta
	   and no_documento = _no_documento;

	update emipoliza
	   set motivo_rechazo = ''
	 where no_documento   = _no_documento;

	let _saldo = sp_cob115b('001','001',_no_documento,'');

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
	let _prima    = _monto / _factor;
	let _impuesto = _monto - _prima;

	-- Descripcion de la Remesa	
	let _nombre_agente = "";

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

	let _descripcion = trim(_nombre_cliente) || "/" || trim(_nombre_agente);

	-- insercion de las polizas con pronto pago a la tabla cobpronde
	if _pronto_pago = 1 then
		call sp_cob50c(_no_documento,a_user) returning _error, _mensaje;
	end if

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
			no_poliza)
	values(	_no_remesa,
			_renglon,
			a_compania,
			a_sucursal,
			_no_recibo,
			_no_documento,
			_tipo_mov,
			_monto,
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
	
	commit work;
end foreach

begin
	on exception in(-535)

	end exception 	
	begin work;
end

select sum(monto)
  into _saldo
  from cobredet
 where no_remesa = _no_remesa;

update cobremae
   set monto_chequeo = _saldo
 where no_remesa     = _no_remesa;

--*******************************************************************************
-- actualizacion de la gestion para las tarjetas rechazadas*
--*******************************************************************************
let _fecha_gestion  = current year to second;	

foreach
	select no_documento,
		   motivo_rechazo,
		   no_tarjeta
	  into _no_documento,
		   _motivo_rechazo,
		   _no_tarjeta
	  from cobtatra
	 where procesar = 0

	let _no_poliza      = sp_sis21(_no_documento);
	let _motivo_rechazo = "RECHAZO VISA: " || trim(_motivo_rechazo);
	let _fecha_gestion  = _fecha_gestion + 1 units second;

	select cod_pagador
  	  into _cod_pagador
      from emipomae
     where no_poliza = _no_poliza;

	--Este update es para marcar la poliza como rechazada.
	update cobtacre
	   set rechazada    = 1
	 where no_tarjeta   = _no_tarjeta
	   and no_documento = _no_documento;

	select dia_especial,
		   fecha_inicio,
		   fecha_hasta
	  into _dia_esp,
		   _fecha_inicio,
		   _fecha_hasta
	  from cobtacre
	 where no_tarjeta = _no_tarjeta
	   and no_documento = _no_documento;

	{if _fecha >= _fecha_inicio and _fecha <= _fecha_hasta then
		let _dia_sig = day(_fecha_sig);
		
		if _dia_hoy = _dia_esp then
			update cobtacre
			   set dia_especial = _dia_sig,
				   fecha_inicio = _fecha_sig,
				   fecha_hasta = _fecha_sig
			 where no_tarjeta = _no_tarjeta
			   and no_documento = _no_documento;
		end if
	end if}

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
			a_user,
			_no_documento,
			_null,
			0,
			_cod_pagador);

	select count(*)
	  into _cnt
	  from cobgesti
	 where no_poliza            = _no_poliza
	   and year(fecha_gestion)  = _fec_ano
	   and month(fecha_gestion) = _fec_mes
	   and desc_gestion[1,4]    = 'RECH';

	update emipoliza
	   set motivo_rechazo = _motivo_rechazo
	 where no_documento	  = _no_documento;

	if _cnt = 9 then  --cada 9 rechazos en el mes equivale a 1 rechazo para la poliza.
		update emipoliza
		   set cant_rechazo = cant_rechazo + 1
		 where no_documento	= _no_documento;
	end if
end foreach

foreach
	select no_documento,
		   no_tarjeta
	  into _no_documento,
		   _no_tarjeta
	  from cobtatra

	update cobtacre
	   set procesar = 0
	 where trim(no_tarjeta)   = trim(_no_tarjeta)
	   and trim(no_documento) = trim(_no_documento);
end foreach

let cnt_flag = 0;

if a_tipo = "A" then  --american

	select count(*)
	  into cnt_flag
	  from cobfectam
	  where procesado = 2;

	if cnt_flag is null then
		let cnt_flag = 0;
	end if

	if cnt_flag < 1 then
		return 1,'No se encontraron los dÃ­as pendientes a procesar.',null;
	end if
	
	update cobfectam
	   set procesado = 1
	 where procesado = 2;
else
	select count(*)
	  into cnt_flag
	  from cobfectar
	  where procesado = 2;

	if cnt_flag is null then
		let cnt_flag = 0;
	end if

	if cnt_flag < 1 then
		return 1,'No se encontraron los dÃ­as pendientes a procesar.',null;
	end if
	
	update cobfectar
	   set procesado = 1
	 where procesado = 2;
end if

return 0, 'Actualizacion Exitosa, Remesa # ' || _no_remesa, _no_remesa;
end
end procedure 
                                      
