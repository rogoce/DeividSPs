-- Procedimiento que Genera la Remesa de Creación de pago en Suspenso.
-- para emisión de pagos a través de Panama Asistencia por venta de seguro de asitencia de viaje.

-- Creado    : 15/05/2018 - Autor: Armando Moreno M.

--drop procedure sp_cob411;
create procedure "informix".sp_cob411(
a_compania		char(3),
a_sucursal		char(3),
a_monto         dec(16,2)
) returning smallint,
            char(100),
            char(10);

define _descripcion			char(100);
define _nombre_cliente		char(50);
define _nombre_agente		char(50);
define _error_desc			char(50);
define _no_documento		char(18);
define a_no_remesa			char(10);
define a_no_recibo			char(10);
define _no_poliza			char(10);
define _recibo				char(10);
define _periodo,_periodo_hoy char(7);
define _cod_cobrador		char(3);
define _cod_chequera		char(3);
define _banco				char(3);
define _tipo_mov			char(1);
define _null				char(1);
define _impuesto			dec(16,2);
define _prima				dec(16,2);
define _saldo				dec(16,2);
define _monto				dec(16,2);
define _cant_suspe			smallint;
define _error_code			integer;
define _error_isam			integer;
define _renglon				integer;  
define _fecha				date;
define a_user               char(8);
define _ramo                varchar(50);

set isolation to dirty read;

begin

on exception set _error_code, _error_isam, _error_desc 
 	return _error_code, _error_desc, _error_desc;
end exception           

--SET DEBUG FILE TO "sp_cob184.trc"; 
--trace on;

let _error_code	= 0;
let a_no_remesa	= '1';  
let _tipo_mov	= 'P';
let _periodo	= '';
let _fecha		= null;
let _null		= null;
let _ramo       = null;

--Buscar el banco en parametros
let _banco        = '146';
let _cod_chequera = '035';
let a_user        = 'DEIVID';
let _cod_cobrador = "232";

-- Numero de Recibo

let a_no_remesa = sp_sis13(a_compania, 'COB', '02', 'par_no_remesa');

select fecha
  into _fecha
  from cobremae
 where no_remesa = a_no_remesa;

if _fecha is not null theN
	return 1, 'El Numero de Remesa Generado Ya Existe, Por Favor Actualice Nuevamente ...', '';
end if

let _fecha = today;

select cob_periodo
  into _periodo
  from deivid:parparam;
  
call sp_sis39(_fecha) RETURNING _periodo_hoy;

-- Ultimo dia del mes del periodo
if _periodo <> _periodo_hoy then
	if _periodo < _periodo_hoy then
		CALL sp_sis36(_periodo) RETURNING _fecha;
	else
		CALL sp_sis36bk(_periodo) RETURNING _fecha;
	end if

end if

let _monto = a_monto;
let _nombre_cliente = 'COLOCAR EL NOMBRE DEL CLIENTE';

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
values(	a_no_remesa,
		a_compania,
		a_sucursal,
		_banco,
		_cod_cobrador,
		_null,
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

	--ultimo numero de renglon
	select max(renglon)
	  into _renglon
	  from cobredet
	 where no_remesa = a_no_remesa;

	if _renglon is null then
		let _renglon = 0;
	end if

    let _renglon  = _renglon + 1;

    let _tipo_mov = 'E'; --Creacion de pago en suspenso

	let _saldo    = 0;
	let _prima    = 0;
	let _impuesto = 0;
	let _nombre_agente  = " "; --Aqui debes colocar el nombre del corredor Fede.

	let _nombre_agente  = "-";
	let _no_poliza      = null;
	let a_no_recibo     = 'PRUEBA';
	LET _ramo           = 'ACCIDENTES PERSONALES';
	let _no_documento   = a_no_recibo; --Aqui deberia ir el identificador unico.

	select count(*)
	  into _cant_suspe
	  from cobsuspe
	 where doc_suspenso = _no_documento;
	 
	if _cant_suspe <> 0 then

		update cobsuspe
		   set monto        = monto + _monto				  					
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
		date_added
		)
		values(
		_no_documento,
		a_compania,
		a_sucursal,
		_monto,
		_fecha,
		"",
		_nombre_cliente,
		_no_documento,
		_ramo,
		0,
		a_user,
		_fecha
		);

	end if

	let _descripcion = TRIM(_nombre_cliente) || "/" || TRIM(_nombre_agente);
		 
    -- Detalle de la Remesa
	INSERT INTO cobredet(
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
	no_poliza
	)
	VALUES(
	a_no_remesa,
	_renglon,
	a_compania,
	a_sucursal,
	a_no_recibo,
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
	_no_poliza
	);

	SELECT SUM(monto)
	  INTO _saldo
	  FROM cobredet
	 WHERE no_remesa = a_no_remesa;
		
	if _saldo is null then
		let _saldo = 0.00;
	end if

	UPDATE cobremae
	   SET monto_chequeo = _saldo
	 WHERE no_remesa     = a_no_remesa;

-- Actualizacion de la Remesa
call sp_cob29(a_no_remesa, a_user) returning _error_code, _error_desc;

if _error_code <> 0 then
	return _error_code, _error_desc || " Remesa # " || a_no_remesa, a_no_remesa;
end if

return 0, 'Actualizacion Exitosa, Remesa # ' || a_no_remesa, a_no_remesa;
end 
end procedure;