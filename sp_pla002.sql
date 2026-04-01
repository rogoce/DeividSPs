-- Procedure que actualiza los registros de planilla al modulo de cheques

-- Creado    : 13/11/2009 - Autor: Demetrio Hurtado Almanza 
--
-- SIS v.2.0 - DEIVID, S.A.
  
--drop procedure sp_pla002;

create procedure sp_pla002(a_cod_payday char(10))
returning integer,
          char(100);

define _centro_costo	char(3); 
define _cod_ruta		char(3);

define _sac_asientos	smallint;
define _banco			char(3);
define _chequera		char(3);
define a_compania       char(3);
define a_sucursal		char(3);
define _no_requis		char(10);
define _origen_cheque	char(1);
define _tipo_requis		char(1);
define _fecha			date;
define _fecha_cobrado	date;
define _autorizado		smallint;
define _pagado			smallint;
define _cobrado			smallint;
define _nombre			char(100);
define _periodo			char(7);
define _user_added		char(8);
define _no_cheque		char(10);
define _monto_banco		dec(16,2);
define _cuenta_banc		char(25);

define _detalle			char(100);

define _renglon			smallint;
define _cta_auxiliar	char(1);
define _cuenta			char(25);
define _monto			dec(16,2);
define _debito			dec(16,2);
define _credito			dec(16,2);
define _cod_auxiliar	char(5);
define _tipo_pago		char(1);

define _error			integer;
define _error_isam		integer;
define _error_desc		char(100);

begin
on exception set _error, _error_isam, _error_desc
	return _error, _error_desc;
end exception

-- Verificaciones Iniciales

select sac_asientos,
       fecha,
	   user_added
  into _sac_asientos,
       _fecha,
	   _user_added
  from plapayday
 where cod_payday   = a_cod_payday;

if _sac_asientos = 0 then
	return 1, "Esta Planilla tiene Errores";
end if

if _sac_asientos = 2 then
	return 1, "Esta Planilla ya fue Actualizada";
end if

-- Centro de Costos

call sp_sac93("000", 99) returning _error, _error_desc, _centro_costo;

if _error <> 0 then
	return _error, _error_desc;
end if

-- Proceso de Conversion

let banco    	   = "001";
let a_compania     = "001";
let a_sucursal     = "001";
let _origen_cheque = "P";
let _periodo       = sp_sis39(_fecha);

let chequera	   = "013";
let _autorizado    = 0;
let _pagado	       = 0;

foreach
 select no_cheque
   into _no_cheque
   from plapayche
  where cod_payday = a_cod_payday
  group by no_cheque
  order by no_cheque

	foreach
	 select monto_banco,
	        cuenta_banco,
			vendedor,
			detalle,
			tipo_pago
	   into _monto_banco,
	        _cuenta_banc,
			_nombre,
			_detalle,
			_tipo_pago
	   from plapayche
      where cod_payday = a_cod_payday
	    and no_cheque  = _no_cheque
		exit foreach;
	end foreach

	-- Encabezado del Cheque

	let _no_requis = sp_sis13(a_compania, 'CHE', '02', 'par_cheque');
	let _cod_ruta  = null;

	if _no_cheque[1,3] = "ACH" then

		let _tipo_requis   = "A";
		let _no_cheque     = _no_cheque[4,10];
		let _cobrado       = 1;
		let _fecha_cobrado = _fecha;

	else

		let _tipo_requis   = "C";
		let _cobrado       = 0;
		let _fecha_cobrado = null;
		
		if _tipo_pago = "P" then
			let _cod_ruta = "009"; 
		end if
		
	end if

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
	NULL,
	NULL,
	_banco,
	_chequera,
	_cuenta_banc,
	a_compania,
	a_sucursal,
	_origen_cheque,
	_no_cheque,
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
	
	-- Cuentas del Cheque

	let _renglon = 0;

	foreach
	 select cuenta,
	        monto,
			cod_auxiliar
	   into _cuenta,
	        _monto,
			_cod_auxiliar
	   from plapayche
      where cod_payday = a_cod_payday
	    and no_cheque  = _no_cheque
		
		select cta_auxiliar
		  into _cta_auxiliar
		  from cglcuentas
		 where cta_cuenta = _cuenta;

		if _cta_auxiliar = "N" then
			let _cod_auxiliar = null;
		end if

		let _renglon = _renglon + 1;

		if _monto > 0 then
			let _debito  = _monto;
			let _credito = 0.00;
		else
			let _debito  = 0.00;
			let _credito = _monto * - 1;
		end if

		INSERT INTO chqchcta(
		no_requis,
		renglon,
		cuenta,
		debito,
		credito,
		centro_costo,
		cod_auxiliar
		)
		VALUES(
		_no_requis,
		_renglon,
		_cuenta,
		_debito,
		_credito,
		_centro_costo,
		_cod_auxiliar
		);

		if _cta_auxiliar = "S" then

			insert into	chqctaux(
			no_requis,
			renglon,
			cuenta,
			cod_auxiliar,
			debito,
			credito,
			centro_costo
			)
			values(
			a_no_requis,
			_renglon,
			_cuenta,
			_cod_auxiliar,
			_debito,
			_credito,
			_centro_costo
			);

		end if

	end foreach

	-- Cuenta del Banco

	let _renglon = _renglon + 1;

	if _monto > 0 then
		let _debito  = 0.00;
		let _credito = _monto;
	else
		let _debito  = _monto * - 1;
		let _credito = 0.00;
	end if

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
	_renglon,
	_cuenta_banc,
	_debito,
	_credito,
	_centro_costo
	);

end foreach

update plapayday
   set sac_asientos = 2
 where cod_payday   = a_cod_payday;

end

return 0, "Actualizacion Exitosa";

end procedure
