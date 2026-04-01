-- Froma de pago por unidad

-- Creado    : 27/12/2007 - Autor: Armando Moreno M.
--
-- SIS v.2.0 - DEIVID, S.A

drop procedure sp_sis104;

create procedure sp_sis104(a_no_poliza char(10))
returning integer,
          char(50);

define _error		integer;
define _error_isam	integer;
define _error_desc	char(50);

DEFINE _cod_formapag    CHAR(3);
DEFINE _cod_origen      CHAR(3);
DEFINE _cod_perpago     CHAR(3);  
DEFINE _tipo_forma      SMALLINT; 
DEFINE _no_tarjeta      CHAR(19); 
DEFINE _tipo_tarjeta    CHAR(1); 
DEFINE _fecha_exp       CHAR(7);  
DEFINE _cod_banco       CHAR(3);  
DEFINE _dia_cobros1     SMALLINT;
DEFINE _user_added      CHAR(8);  
DEFINE _cod_pagador     CHAR(10); 
DEFINE _nombre_pagad    CHAR(100);
DEFINE _cod_contratante CHAR(10); 
DEFINE _periodo_visa    CHAR(1);
DEFINE _no_pagos  		INTEGER;
DEFINE _monto_visa      DEC(16,2);
DEFINE _prima_bruta     DEC(16,2);
DEFINE _fecha_1_pago    DATE;
DEFINE _no_endoso_ext	CHAR(5);
DEFINE _no_cuenta   	CHAR(17);
DEFINE _tipo_cuenta   	CHAR(1);
DEFINE _cod_tipoprod    CHAR(3);
DEFINE _tipo_produccion SMALLINT;
define _cobra_poliza	char(1);
define _return			smallint;
DEFINE _cantidad        SMALLINT;
DEFINE _cantidad_uni    SMALLINT;
DEFINE _cod_ramo        CHAR(3);  
define _prima_neta		dec(16,2);
define _suma_asegurada	dec(16,2);
define _saldo_x_unidad  smallint;
define _no_unidad       char(5);
define _no_documento    char(20);
DEFINE _nueva_renov     CHAR(1);

begin
on exception set _error, _error_isam, _error_desc
	return _error, _error_desc;
end exception

select nueva_renov
  into _nueva_renov
  from emipomae
 where no_poliza = a_no_poliza;

foreach
	select no_unidad,
		   no_tarjeta,
		   fecha_exp,
		   cod_banco,
		   user_added,
		   cod_pagador,
		   dia_cobros1,
		   cod_formapag,
		   tipo_tarjeta,
		   cod_perpago,
		   cod_contratante,
		   no_pagos,
		   prima_bruta,
		   fecha_primer_pago,
		   no_cuenta,
		   tipo_cuenta
	  into _no_unidad,
	  	   _no_tarjeta,
		   _fecha_exp,
		   _cod_banco,
		   _user_added,
		   _cod_pagador,
		   _dia_cobros1,
		   _cod_formapag,
		   _tipo_tarjeta,
		   _cod_perpago,
		   _cod_contratante,
		   _no_pagos,
		   _prima_bruta,
		   _fecha_1_pago,
		   _no_cuenta,
		   _tipo_cuenta
	  from emipouni
	 where no_poliza = a_no_poliza

	SELECT tipo_forma
	  INTO _tipo_forma
	  FROM cobforpa
	 WHERE cod_formapag = _cod_formapag;


	let _cobra_poliza = "A";

	LET _monto_visa = _prima_bruta / _no_pagos;

	if _nueva_renov = 'R' and (_tipo_forma = 5 or _tipo_forma = 3) THEN -- se debe insertar en callcenter
		LET _return	= sp_cas022(a_no_poliza);
	end if

-- Verificacion para Tarjetas de Credito y Ach

	IF _tipo_forma = 2 THEN -- Tarjetas de Credito
	    update emipouni
		   set monto_visa = _monto_visa
		 where no_poliza  = a_no_poliza
		   and no_unidad  = _no_unidad;

		if _tipo_forma = 2 then -- Tarjetas de Credito 
			let _cobra_poliza = "T"; 
		end if

		SELECT nombre
		  INTO _nombre_pagad
		  FROM cobtahab
		 WHERE no_tarjeta = _no_tarjeta;
		
		IF _nombre_pagad IS NULL THEN -- Crear el Maestro de Tarjetas

			SELECT nombre
			  INTO _nombre_pagad
			  FROM cliclien
			 WHERE cod_cliente = _cod_pagador;

			INSERT INTO cobtahab(
			no_tarjeta,
			cod_banco,
			nombre,
			fecha_exp,
			user_added,
			date_added,
			tipo_tarjeta
			)
			VALUES(
			_no_tarjeta,
			_cod_banco,
			_nombre_pagad,
			_fecha_exp,
			_user_added,
			TODAY,
			_tipo_tarjeta
			);

		END IF

		SELECT nombre
		  INTO _nombre_pagad
		  FROM cobtacre
		 WHERE no_tarjeta   = _no_tarjeta
		   AND no_documento = _no_documento;

		IF _nombre_pagad IS NULL THEN -- Crear el Detalle de la Tarjeta
			
			IF _dia_cobros1 > 15 THEN
				LET _periodo_visa = 2;
			ELSE
				LET _periodo_visa = 1;
			END IF

			SELECT nombre
			  INTO _nombre_pagad
			  FROM cliclien
			 WHERE cod_cliente = _cod_contratante;

			INSERT INTO cobtacre(
			no_tarjeta,
			no_documento,
			cod_perpago,
			nombre,
			periodo,
			monto,
			fecha_ult_tran,
			procesar,
			excepcion,
			cargo_especial,
			no_unidad
			)
			VALUES(
			_no_tarjeta,
			_no_documento,
			_cod_perpago,
			_nombre_pagad,
			_periodo_visa,
			_monto_visa,
			_fecha_1_pago,
			0,
			0,
			0.00,
			_no_unidad
			);

		END IF

		UPDATE cobtacre
		   SET monto = _monto_visa
		 WHERE no_tarjeta   = _no_tarjeta
		   AND no_documento = _no_documento;
	END IF

	IF _tipo_forma = 4 THEN -- Ach
	    update emipouni
		   set monto_visa = _monto_visa
		 where no_poliza  = a_no_poliza
		   and no_unidad  = _no_unidad;

		if _tipo_forma = 4 THEN -- ACH
			let _cobra_poliza = "H"; 
		end if

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
		ELSE	--sumarle al monto del ach, el monto de la nueva poliza que se incorpora a la misma cuenta.
		  IF _nueva_renov = 'N' THEN
			UPDATE cobcuhab
			   SET monto_ach = monto_ach + _monto_visa
			 WHERE no_cuenta = _no_cuenta;

			  IF _dia_cobros1 > 15 THEN
			  	LET _periodo_visa = 2;
			  ELSE
			  	LET _periodo_visa = 1;
			  END IF

			  SELECT nombre
			    INTO _nombre_pagad
			    FROM cliclien
			   WHERE cod_cliente = _cod_contratante;

			  DELETE FROM cobcutas 
			   WHERE no_cuenta    = _no_cuenta
			     and no_documento = _no_documento;

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
				cargo_especial,
				no_unidad
				)
				VALUES(
				_no_cuenta,
				_no_documento,
				_cod_perpago,
				_nombre_pagad,
				_periodo_visa,
				_monto_visa,
				_fecha_1_pago,
				0,
				0,
				0.00,
				_no_unidad
				);
		  ELSE
			  UPDATE cobcutas
				 SET monto = _monto_visa
			   WHERE no_cuenta    = _no_cuenta
			     and no_documento = _no_documento;
		  END IF
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
				cargo_especial,
				no_unidad
				)
				VALUES(
				_no_cuenta,
				_no_documento,
				_cod_perpago,
				_nombre_pagad,
				_periodo_visa,
				_monto_visa,
				_fecha_1_pago,
				0,
				0,
				0.00,
				_no_unidad
				);
			END IF

	END IF
end foreach
end 

return 0, "Actualizacion Exitosa...";

end procedure