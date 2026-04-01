-- Procedimiento que Genera la Remesa de los ACH

-- ref. sp_cob50;   : 22/02/2001 - Autor: Demetrio Hurtado Almanza 
-- Creado: 29/01/2002 - Autor: Armando Moreno M.

-- SIS v.2.0 - DEIVID, S.A.

drop procedure sp_cob427_am;
create procedure sp_cob427_am(
a_compania	char(3),
a_sucursal	char(3),
a_user		char(8))
returning	smallint,
			char(100),
			char(10);

define _motivo_rechazo_pol	char(100);
define _motivo_rechazo		char(100);
define _nombre_pagador		char(100);
define _nombre_cliente		char(100);
define _descripcion			char(100);
define _nombre_agente		char(50);
define _recibi_de			char(50);
define _mensaje				char(50);
define _no_documento,_no_documento2		char(20); 
define _no_cuenta			char(17);
define _cod_cliente			char(10);
define _cod_pagador			char(10);
define _cod_agente			char(10);
define a_no_remesa			char(10);
define a_no_recibo			varchar(10);
define _no_poliza			char(10); 
define _periodo				char(7);
define _ano_char			char(4);
define _cod_banco_rech		char(3);
define _cod_chequera		char(3);
define _cod_banco			char(3);
define _cod_ramo			char(3);
define _tipo_cuenta			char(1);
define _tipo_mov			char(1);
define _null				char(1);
define _porc_partic			dec(16,2);
define _porc_comis			dec(16,2);
define _monto_rem			dec(16,2);
define _impuesto			dec(16,2);
define _factor				dec(16,2);
define _prima				dec(16,2);
define _cargo				dec(16,2);
define _saldo				dec(16,2);
define _monto				dec(16,2);
define _pronto_pago			smallint;
define _cnt_rechazo			smallint;
define _rechazo_ach			smallint;
define _fec_ano				smallint;
define _fec_mes,_valor		smallint;
define _cnt,_sus_inc		smallint;
define _error_code			integer;
define _renglon				integer;
define _no_tran				integer;
define _error				integer;
define _fec_rec				date;
define _fecha				date;
define _fecha_gestion		datetime year to second;
define _doc_remesa          varchar(30);

begin
on exception set _error_code 

	begin
		on exception in(-255)
		end exception
	end 

 	return _error_code, 'error al actualizar la remesa de ach', '';
end exception           

--SET DEBUG FILE TO "sp_cob83.trc";
--TRACE ON;

let _tipo_mov       = 'P'; 
let a_no_remesa     = '1'; 
let _nombre_cliente = "";
let _mensaje        = "";
let _null           = null;
let _fec_rec        = current;
let _fec_ano        = year(_fec_rec);
let _fec_mes        = month(_fec_rec);
let _sus_inc        = 0;

let a_no_remesa = sp_sis13(a_compania, 'COB', '02', 'par_no_remesa');

select fecha
  into _fecha
  from cobremae
 where no_remesa = a_no_remesa;

if _fecha is not null then
	return 1, 'El Numero de Remesa Generado Ya Existe, Por Favor Actualize Nuevamente ...', '';
end if	

let _fecha = today;

if month(_fecha) < 10 then
	let _periodo = year(_fecha) || '-0' || month(_fecha);
else
	let _periodo = year(_fecha) || '-' || month(_fecha);
end if

-- Numero de Comprobante

let a_no_recibo = 'ACH';	-- ACH

if day(_fecha) < 10 then
	let a_no_recibo = trim(a_no_recibo) || '0' || day(_fecha);
else
	let a_no_recibo = trim(a_no_recibo) || day(_fecha);
end if

if month(_fecha) < 10 then
	let a_no_recibo = trim(a_no_recibo) || '0' || month(_fecha);
else
	let a_no_recibo = trim(a_no_recibo) || month(_fecha);
end if

let _ano_char   = year(_fecha);
let a_no_recibo = trim(a_no_recibo) || _ano_char[3,4];

-- Insertar el Maestro de Remesas

select valor_parametro
  into _cod_banco
  from inspaag
 where codigo_compania  = '001'
   and codigo_agencia   = '001'
   and aplicacion       = 'COB'
   and version          = '02'
   and codigo_parametro = 'caja_caja';

let _cod_banco = trim(_cod_banco);

select valor_parametro
  into _cod_chequera
  from inspaag
 where codigo_compania  = '001'
   and codigo_agencia   = '001'
   and aplicacion       = 'COB'
   and version          = '02'
   and codigo_parametro = 'caja_ach';

let _recibi_de = "REMESA DE ACH: " || a_no_recibo;

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
subir_bo,
cod_chequera
)
values(
a_no_remesa,
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
0,
_cod_chequera
);

let _renglon = 0;

foreach
	select no_cuenta,
	       cod_pagador,
		   motivo,
		   nombre_pagador,
		   periodo,
		   monto,
		   cargo,
		   no_tran,
		   no_documento,
		   pronto_pago
	  into _no_cuenta,
	       _cod_pagador,
		   _motivo_rechazo,
		   _nombre_pagador,
		   _periodo,
		   _monto,
		   _cargo,
		   _no_tran,
		   _no_documento,
		   _pronto_pago
	  from cobcutmp
	 where rechazado = 0	--transacciones aprobados
	   and no_documento in('1819-00058-01','0218-00146-01','0118-00546-01')
	 order by nombre_pagador

	let _renglon   = _renglon + 1;
	let _no_poliza = sp_sis21(_no_documento);

	foreach		--Leer el detalle de ach
		select nombre
		  into _nombre_cliente
		  from cobcutas
		 where trim(no_cuenta) = trim(_no_cuenta)
		   and no_documento    = _no_documento

		exit foreach;
	end foreach

	if _nombre_cliente is null then
		let _nombre_cliente = "";
	end if

	let _saldo = sp_cob115b('001','001',_no_documento,'');

	if _saldo is null then
		let _saldo = 0;
	end if

	-- Impuestos de la poliza

	select sum(i.factor_impuesto)
	  into _factor
	  from prdimpue i, emipolim p
	 where i.cod_impuesto = p.cod_impuesto
	   and p.no_poliza    = _no_poliza;

	if _factor is null then
		let _factor = 0;
	end if

	let _factor		= 1 + _factor / 100;
	let _prima		= _monto / _factor;
	let _impuesto	= _monto - _prima;
	let _monto_rem	= _monto;
	let _saldo		= _saldo - _monto;
	-- Descripcion de la remesa
	
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

	if _nombre_cliente is null then
		let _nombre_cliente = "";
	end if

	let _descripcion = trim(_nombre_cliente) || "/" || TRIM(_nombre_agente);
	 
		-- insercion de las polizas con pronto pago a la tabla cobpronde
	if _pronto_pago = 1 then
		call sp_cob50c(_no_documento,a_user) returning _error, _mensaje;
	end if
	
	select cod_ramo
	  into _cod_ramo
	  from emipomae
	 where no_poliza = _no_poliza;
	
	--******PROCEDIMIENTO PARA CREAR PAGO EN SUSPENSO SI LA POLIZA ESTA CANCELADA O ANULADA AL MOMENTO DE GENERAR LA REMESA DE ACH.
	let _valor = 0;
	let _valor = sp_sis519(_no_documento,2);
	if _valor = 1 then
		let _tipo_mov = 'E';
		let a_no_recibo = TRIM(a_no_recibo);
		let _doc_remesa = a_no_recibo || '-' || _sus_inc;
		let _doc_remesa = trim(_doc_remesa);
		let _no_documento2 = _no_documento;
		let _no_documento = _doc_remesa;
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
	values(	a_no_remesa,
			_renglon,
			a_compania,
			a_sucursal,
			a_no_recibo,
			_no_documento,
			_tipo_mov,
			_monto_rem,
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
			
		if _tipo_mov = 'E' then
			let _no_documento = _no_documento2;
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
			date_added
			)
			values(
			_doc_remesa,
			a_compania,
			a_sucursal,
			_monto_rem,
			_fecha,
			"",
			_descripcion,
			_no_documento,
			NULL,
			0,
			a_user,
			_fec_rec
			);
			let _tipo_mov = 'P';
			let _sus_inc = _sus_inc + 1;
		end if
	if _valor = 0 then
		foreach
			select cod_agente,
				   porc_partic_agt,
				   porc_comis_agt
			  into _cod_agente,
				   _porc_partic,
				   _porc_comis
			  from emipoagt
			 where no_poliza = _no_poliza

			insert into cobreagt
			values(	a_no_remesa,
					_renglon,
					_cod_agente,
					0,
					0,
					_porc_comis,
					_porc_partic,
					0);
		end foreach
	end if

	-- desmarcar rechazadas a cuentas aprobadas.
	update cobcuhab
	   set rechazada  = 0
	 where trim(no_cuenta) = trim(_no_cuenta);

	update cobcutas
  	   set rechazada = 0,
		   procesar = 0,
		   cnt_rechazo = 0
  	 where trim(no_cuenta) = trim(_no_cuenta)
  	   and no_documento    = _no_documento;

	update emipoliza
	   set motivo_rechazo = ''
	 where no_documento   = _no_documento;

end foreach
	
-- actualizar el detalle de ach, el campo de cargo_especial en cero
foreach  --leer las transacciones
	select no_cuenta
	  into	_no_cuenta
	  from cobcutmp
	 where rechazado = 0	--transacciones aprobadas

	foreach
		--leer el detalle de ach
		select no_documento
		  into _no_documento
		  from cobcutas
		 where trim(no_cuenta) = trim(_no_cuenta)
		   and periodo         = _periodo

		update cobcutas
		   set cargo_especial  = 0.00
		 where trim(no_cuenta) = trim(_no_cuenta)
		   and no_documento    = _no_documento;
	end foreach
end foreach

select sum(monto)
  into _saldo
  from cobredet
 where no_remesa = a_no_remesa;

update cobremae
   set monto_chequeo = _saldo
 where no_remesa     = a_no_remesa;

--****************************************************
-- Actualizacion de la Gestion para los ACH Rechazados
--****************************************************

let _fecha_gestion  = current year to second;	

foreach
	select no_cuenta,
		   motivo,
		   periodo,
		   no_documento
	  into _no_cuenta,
		   _motivo_rechazo,
		   _periodo,
		   _no_documento
	  from cobcutmp
	 where rechazado = 1	--transacciones rechazados

	update cobcuhab
	   set rechazada  = 1
	 where no_cuenta = _no_cuenta;

	select cod_banco,
		   tipo_cuenta
	  into _cod_banco_rech,
		   _tipo_cuenta
	  from cobcuhab
	 where no_cuenta = _no_cuenta;

	select rechazo_ach
	  into _rechazo_ach
	  from chqbanco
	 where cod_banco = _cod_banco_rech;

	if _motivo_rechazo is null then
		let _motivo_rechazo = "";
	end if

	--  este update es para marcar la poliza como rechazada.	
	let _cnt_rechazo = 0;

	if _rechazo_ach = 1 then
		--Para Banco General y Multibank solo se deben tomar las cuentas corrientes
		if _cod_banco_rech in ('003','005') then
			if _tipo_cuenta = 'D' then
				let _cnt_rechazo = 1;
			end if
		else
			let _cnt_rechazo = 1;
		end if
	end if

	let _motivo_rechazo_pol = TRIM(_motivo_rechazo[5,54]);
	
-- Se uso en comentario ya que no va en el nuevo formato
{	if _motivo_rechazo[1,3] = 'R01' then
		let _motivo_rechazo_pol = 'Fondos Insuficientes';
	elif _motivo_rechazo[1,3] = 'R02' then
		let _motivo_rechazo_pol = 'Cuenta Cerrada';
		let _cnt_rechazo = 1;
	elif _motivo_rechazo[1,3] = 'R03' then
		let _motivo_rechazo_pol = 'Cuenta no Existe';
	elif _motivo_rechazo[1,3] = 'R04' then
		let _motivo_rechazo_pol = 'Número de Cuenta Invalido';
		let _cnt_rechazo = 1;
	elif _motivo_rechazo[1,3] = 'R09' then
		let _motivo_rechazo_pol = 'Fondos Girados contra Producto';
	elif _motivo_rechazo[1,3] = 'R10' then
		let _motivo_rechazo_pol = 'No Existe Autorización';
	elif _motivo_rechazo[1,3] = 'R16' then
		let _cnt_rechazo = 1;
		let _motivo_rechazo_pol = 'Cuenta Bloqueada';
	elif _motivo_rechazo[1,3] = 'R17' then
		let _motivo_rechazo_pol = 'Falta de Autorización';
	else
		let _motivo_rechazo_pol = '';
	end if
}

	update cobcutas
	   set rechazada	= 1,
		   cnt_rechazo  = cnt_rechazo + _cnt_rechazo 
	 where trim(no_cuenta) = trim(_no_cuenta)
	   and no_documento    = _no_documento;

	let _no_poliza      = sp_sis21(_no_documento);
	let _motivo_rechazo = "RECHAZO ACH: " || trim(_motivo_rechazo);
	let _fecha_gestion  = _fecha_gestion + 1 units second;	

	update emipoliza
	   set motivo_rechazo = _motivo_rechazo_pol
	 where no_documento	  = _no_documento;

	select count(*)
	  into _cnt
	  from cobgesti
	 where no_poliza            = _no_poliza
	   and year(fecha_gestion)  = _fec_ano
	   and month(fecha_gestion) = _fec_mes
	   and desc_gestion[1,4]    = 'RECH';

	if _cnt = 9 then
		update emipoliza
		   set cant_rechazo = cant_rechazo + 1
		 where no_documento	= _no_documento;
	end if

	begin
		on exception in(-239)
		end exception
		insert into cobgesti(
				no_poliza,
				fecha_gestion,
				desc_gestion,
				user_added,
				no_documento,
				fecha_aviso,
				tipo_aviso)
		values(	_no_poliza,
				_fecha_gestion,
				_motivo_rechazo,
				a_user,
				_no_documento,
				_null,
				0);
	end	 
end foreach

update cobfecach
   set procesado = 1
 where procesado = 2;

return 0, 'Actualizacion Exitosa, Remesa # ' || a_no_remesa, a_no_remesa; 

end
end procedure;