-- Procedure que actualiza la informacion de ACH en Deivid+	desde el programa de ACH de Multicredit

-- Creado    : 13/06/2006 - Autor: Demetrio Hurtado Almanza 

-- SIS v.2.0 - DEIVID, S.A.

drop procedure sp_cob198;

create procedure "informix".sp_cob198()
returning integer,
          char(7);

define _no_poliza	char(10);

define _no_cuenta   char(17);
define _cod_banco   char(3);
define _cod_pagador	char(10);
define _tipo_cuenta	char(1);
define _monto_visa	dec(16,2);

define _user_added	char(8);

define _error		integer;
define _error_isam	integer;
define _error_desc	char(50);

begin 
on exception set _error, _error_isam, _error_desc
	return _error, _error_desc;
end exception

let _user_added = "informix";

-- Borrar Registros Existentes de ACH

delete from cobcutas;
delete from cobcuhab;

-- Blanquear los campos de polizas

update emipomae
   set cod_formapag = "006",
       no_cuenta    = null,
	   tipo_cuenta  = null,
	   cod_banco    = null,
	   monto_visa   = 0.00
 where cod_formapag = "005";

foreach
 select
   into
   from


	let _no_poliza = sp_sis21(_no_documento);

	update emipomae
	   set cod_formapag = "005"
       	   no_cuenta    = null,
	       tipo_cuenta  = null,
	       cod_banco    = null,
	       monto_visa   = 0.00
	 where no_poliza    = _no_poliza;

	SELECT nombre
	  INTO _nombre_pagad
	  FROM cobcuhab
	 WHERE no_cuenta = _no_cuenta;
	 
	IF _nombre_pagad IS NULL THEN -- Crear el Maestro de Cuentas

		SELECT nombre
		  INTO _nombre_pagad
		  FROM cliclien
		 WHERE cod_cliente = _cod_pagador;

		INSERT INTO cobcuhab(
		no_cuenta,
		cod_banco,
		nombre,
		user_added,
		date_added,
		tipo_cuenta,
		tipo_transaccion,
		cod_pagador,
		monto_ach
		)
		VALUES(
		_no_cuenta,
		_cod_banco,
		_nombre_pagad,
		_user_added,
		TODAY,
		_tipo_cuenta,
		'D',
		_cod_pagador,
		_monto_visa
		);

	ELSE 

		UPDATE cobcuhab
		   SET monto_ach = monto_ach + _monto_visa
		 WHERE no_cuenta = _no_cuenta;

	END IF

	SELECT nombre
	  INTO _nombre_pagad
	  FROM cobcutas
	 WHERE no_cuenta    = _no_cuenta
	   AND no_documento = _no_documento;

	IF _nombre_pagad IS NULL THEN -- Crear el Detalle de la cuenta
		
		IF _dia_cobros1 > 15 THEN
			LET _periodo_visa = 2;
		ELSE
			LET _periodo_visa = 1;
		END IF

		SELECT nombre
		  INTO _nombre_pagad
		  FROM cliclien
		 WHERE cod_cliente = _cod_contratante;

		INSERT INTO cobcutas(
		no_cuenta,
		no_documento,
		cod_per_pago,
		nombre,
		periodo,
		monto,
		fecha_ult_tran,
		procesar,
		excepcion,
		cargo_especial
		)
		VALUES(
		_no_cuenta,
		_no_documento,
		_cod_perpago,
		_nombre_pagad,
		_periodo_visa,
		_monto_visa,
		today,
		0,
		0,
		0.00
		);

	END IF

END IF

end 

end procedure



