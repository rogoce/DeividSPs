-- Generacion del Archivo HSBC
-- Creado    : 22/02/2001 - Autor: Demetrio Hurtado Almanza 
-- Modificado: 26/12/2001 - Autor: Armando Moreno Montenegro

-- SIS v.2.0 - DEIVID, S.A.

DROP PROCEDURE sp_cob80a;

CREATE PROCEDURE "informix".sp_cob80a(
a_compania		CHAR(3),
a_sucursal		CHAR(3),
a_fecha			DATE,
a_periodo		CHAR(1)
) RETURNING SMALLINT,
            CHAR(100);

DEFINE _campo			CHAR(100);
DEFINE _cedula		    CHAR(15);
DEFINE _cod_banco       CHAR(3);
DEFINE _cod_pagador     CHAR(10);
DEFINE _fecha_char      CHAR(8);
DEFINE _tipo_cuenta     CHAR(1);
DEFINE _dia_char,_mes_char        CHAR(2);
DEFINE _tipo_transaccion CHAR(1);
DEFINE _no_cuenta		CHAR(17);
DEFINE _cargo_especial,_monto_ach,_cargo_especial_tmp,_monto_poliza,_saldo	DEC(16,2);
DEFINE _monto_char      CHAR(10);
DEFINE _ruta_char       CHAR(9);
DEFINE _no_documento	CHAR(20);
DEFINE _nombr			CHAR(100);
define _nombre_pagador  char(22);
DEFINE _cod_cliente		CHAR(10);
DEFINE _cant_tran,i,_max		INTEGER;
DEFINE _cant_tran_char  CHAR(3);
DEFINE _adenda			CHAR(80);
define _monto           dec(16,2);

DEFINE _error_code,_tipo_monto,_cnt_trans    SMALLINT;
DEFINE _ruta_numero,_mes,_ano,_van,_cnt		 INTEGER;
define _tran_code		char(2);
DEFINE _codigo           CHAR(10);      
DEFINE _contador         INTEGER;    
DEFINE _char_1           CHAR(1);      

--SET DEBUG FILE TO "c:\sp_cob80a.trc";
--trace on;

BEGIN

ON EXCEPTION SET _error_code 
 	RETURN _error_code, 'Error al Actualizar las Transacciones para el Banco. Cuenta:'||_no_cuenta;
END EXCEPTION           

DELETE FROM cobcuban;
DELETE FROM cobcutmp;

IF a_periodo = "1" Then
	LET _dia_char = "15";
ELSE
	LET _dia_char = "30";
END IF

LET _mes = MONTH(CURRENT);

IF _mes >= 1 AND _mes <= 9 THEN
   LET _mes_char = "0" || _mes;
ELSE
   LET _mes_char = _mes;
END IF

LET _ano = YEAR(CURRENT);
LET _fecha_char = _ano || _mes_char || _dia_char;

LET _monto_char = '0000000000';
LET _ruta_char  = '000000000';

--DELETE FROM cobcutra;
--DELETE FROM cobcupag;


FOREACH
	SELECT no_cuenta
	  INTO _no_cuenta
	  FROM cobcuhab
	 ORDER BY no_cuenta

    foreach
		SELECT no_cuenta,
			   SUM(monto),
		   	   SUM(cargo_especial)
		  INTO _no_cuenta,
		  	   _monto,
			   _cargo_especial	
		  FROM cobcutas
		 WHERE no_cuenta = _no_cuenta
		   AND periodo   in (a_periodo, "3")
		   AND procesar  = 1
		   AND excepcion = 0
		 group by 1
		 order by 1

		if _no_cuenta is null then
			continue foreach;
		end if

		SELECT cod_pagador,
			   tipo_monto,
			   monto_ach,
			   cnt_trans,
			   cod_banco,
			   tipo_cuenta,
			   tipo_transaccion
	      INTO _cod_pagador,
		       _tipo_monto,
			   _monto_ach,
			   _cnt_trans,
			   _cod_banco,
			   _tipo_cuenta,
			   _tipo_transaccion
	      FROM cobcuhab
	     WHERE no_cuenta = _no_cuenta;

	  LET _cedula          = null;

	  if _tipo_cuenta = "S" then --ahorro
	  	let _tran_code = '37';
	  else
	  	let _tran_code = '27';
	  end if

	  SELECT cedula,
			 nombre
	    INTO _cedula,
			 _nombre_pagador
	    FROM cliclien
	   WHERE cod_cliente = _cod_pagador;

	  IF _cedula IS NULL THEN
		RETURN 1, 'No existe cedula del pagador para la cuenta: ' || _no_cuenta; 
	  END IF

	  SELECT ruta_numero
	    INTO _ruta_numero
	    FROM chqbanco
	   WHERE cod_banco = _cod_banco;

	  SELECT count(*)
	    INTO _cnt
	    FROM cobcutas
	   WHERE no_cuenta = _no_cuenta;

		LET _monto_char = "0000000000";

		IF _monto > 999999.99 THEN
			LET _monto_char[1,10] = _monto;
		ELIF _monto > 99999.99 THEN
			LET _monto_char[2,10] = _monto;
		ELIF _monto > 9999.99 THEN
			LET _monto_char[3,10] = _monto;
		ELIF _monto > 999.99 THEN
			LET _monto_char[4,10] = _monto;
		ELIF _monto > 99.99 THEN
			LET _monto_char[5,10] = _monto;
		ELIF _monto > 9.99 THEN
			LET _monto_char[6,10] = _monto;
		ELSE
			LET _monto_char[7,10] = _monto;
		END IF

		LET _codigo = "0";
		let _char_1 = "";

		FOR _contador = 1 TO 10

			LET _char_1     = _monto_char[1 , 1];
			LET _monto_char = _monto_char[2 , 10];

			IF _char_1 <> "." THEN

				LET _codigo = TRIM(_codigo) || TRIM(_char_1);

			END IF

		END FOR

		IF _ruta_numero > 99999999 THEN
			LET _ruta_char[1,9] = _ruta_numero;
		ELIF _ruta_numero > 9999999 THEN
			LET _ruta_char[2,9] = _ruta_numero;
		ELIF _ruta_numero > 999999 THEN
			LET _ruta_char[3,9] = _ruta_numero;
		ELIF _ruta_numero > 99999 THEN
			LET _ruta_char[4,9] = _ruta_numero;
		ELIF _ruta_numero > 9999 THEN
			LET _ruta_char[5,9] = _ruta_numero;
		ELIF _ruta_numero > 999 THEN
			LET _ruta_char[6,9] = _ruta_numero;
		ELIF _ruta_numero > 99 THEN
			LET _ruta_char[7,9] = _ruta_numero;
		ELSE
			LET _ruta_char[8,9] = _ruta_numero;
		END IF

	   	SELECT MAX(no_tran) + 1
		  INTO _max
		  FROM cobcutmp;

		IF _max IS NULL THEN
			LET _max = 1;
		END IF

		INSERT INTO cobcutmp
		VALUES (
		_max,
		_no_cuenta,
		_cod_pagador,
		'',
		_nombre_pagador,
		_monto,
		_cargo_especial,
		0,
		a_periodo
		);

		LET _campo = _cedula || _nombre_pagador || _no_cuenta || _ruta_char || _codigo || _tran_code || _max;

	   	INSERT INTO cobcuban
		VALUES (_campo);

	 	 UPDATE cobcutas
		    SET fecha_ult_tran = a_fecha
		  WHERE no_cuenta      = _no_cuenta
		    AND periodo        in(a_periodo,"3")
		    AND procesar       = 1
		    AND excepcion      = 0;
   end foreach

END FOREACH

RETURN 0, 'Actualizacion Exitosa ...'; 
END 
END PROCEDURE;