-- Requisicion de Cheque para pago a proveedores de suministros

-- SIS v.2.0 - DEIVID, S.A.
  
drop procedure sp_soc001;

create procedure sp_soc001(a_proveedor char(10), a_cod_entrada dec(16,2))
returning integer,
          char(100);

define _no_requis		char(10);
define _ruc				varchar(30);
define _cod_cliente		char(10);
define _banco			char(3);
define _chequera		char(3);
define _cuenta_banc		char(25);
define a_compania       char(3);
define a_sucursal		char(3);
define _origen_cheque	char(1);
define _periodo			char(7);
define _no_cheque		char(10);
define _autorizado		smallint;
define _pagado			smallint;
define _nombre			varchar(100);
define _cobrado			smallint;
define _fecha_cobrado	date;
define _monto_banco		dec(16,2);
define _tipo_requis		char(1);
define _centro_costo	char(3);
define _cod_ruta		char(3);
define _no_factura      char(10);
define _fecha_factura	date;
define _detalle			char(100);

define _cuenta			char(25);
define _debito			dec(16,2);
define _credito			dec(16,2);
--define _cod_auxiliar	char(5);

define _error			integer;
define _error_isam		integer;
define _error_desc		char(100);
define _fecha			date;
define _user_added      char(8);

begin
on exception set _error, _error_isam, _error_desc
	return _error, _error_desc;
end exception

	let a_compania = "001";
	let a_sucursal = "001";
	let _fecha     = CURRENT;

	--No. Requisicion
	let _no_requis = sp_sis13(a_compania, 'CHE', '02', 'par_cheque');

	--Cod. Cliente
	SELECT ruc,
		   prov_nombre
	  INTO _ruc,
		   _nombre
	  FROM socprov  
     WHERE prov_cod = a_proveedor;

   SELECT cod_cliente
	 INTO _cod_cliente
     FROM cliclien
    WHERE cedula = _ruc;

	--Banco y Chequera
	let _banco    	   = "001";
	let _chequera	   = "001";

	let _origen_cheque = "G";
	let _periodo       = sp_sis39(_fecha);

	let _autorizado    = 0;
	let _pagado	       = 0;

	let _cobrado       = 0;
	let _fecha_cobrado = null;

	let _tipo_requis   = "C";
	let _cod_ruta  = null;

	--Datos de la entrada
	  SELECT monto_total,   
			 user_changed,
			 no_factura,
			 fecha_factura
		INTO _monto_banco,
		     _user_added,
			 _no_factura,
			 _fecha_factura
		FROM psuminentm  
	   WHERE cod_entrada = a_cod_entrada;

	--Centro de costo
	call sp_sac93("000", 99) returning _error, _error_desc, _centro_costo;

	--Cuenta del banco
	LET _cuenta_banc = sp_sis15("BACHEQL","02",_banco,_chequera);

	insert into chqchmae(
	no_requis,
	cod_cliente,
	cod_agente,
	cod_banco,
	cod_chequera,
	cuenta,
	cod_compania,
	cod_sucursal,
	origen_cheque,
	no_cheque,
	fecha_impresion,
	fecha_captura,
	autorizado,
	pagado,
	a_nombre_de,
	cobrado,
	fecha_cobrado,
	anulado,
	fecha_anulado,
	anulado_por,
	monto,
	periodo,
	user_added,
	autorizado_por,
	tipo_requis,
	impreso_ok,
	centro_costo,
	cod_ruta
	)
	VALUES(
	_no_requis,
	_cod_cliente,
	NULL,
	_banco,
	_chequera,
	_cuenta_banc,
	a_compania,
	a_sucursal,
	_origen_cheque,
	0,
	_fecha,
	_fecha,
	_autorizado,
	_pagado,
	_nombre,
	_cobrado,
	_fecha_cobrado,
	0,
	NULL,
	NULL,
	_monto_banco,
	_periodo,
	_user_added,
	_user_added,
	_tipo_requis,
	1,
	_centro_costo,
	_cod_ruta
	);

	let _detalle = "PARA PAGAR FACTURA: " || trim(_no_factura) || " DEL: " || _fecha_factura || " CORRESPONDIENTE A SUMINISTROS.";

	-- Descripcion del Cheque
	insert into chqchdes(
	no_requis,
	renglon,
	desc_cheque
	)
	values(
	_no_requis,
	1,
	_detalle
	);

	if _monto_banco > 0 then
		let _debito  = _monto_banco;
		let _credito = 0.00;
	else
		let _debito  = 0.00;
		let _credito = _monto_banco * - 1;
	end if

	let _cuenta = sp_sis15("SAINVCXP");

	INSERT INTO chqchcta(
	no_requis,
	renglon,
	cuenta,
	debito,
	credito,
	centro_costo
	)
	VALUES(
	_no_requis,
	1,
	_cuenta,
	_debito,
	_credito,
	_centro_costo
	);

end

return 0, "Actualizacion Exitosa";

end procedure