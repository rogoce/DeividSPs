-- Generacion del Archivo de transacciones para Multi Credit Bank
-- Creado    : 22/02/2001 - Autor: Demetrio Hurtado Almanza 
-- Modificado: 26/12/2001 - Autor: Armando Moreno Montenegro

-- SIS v.2.0 - DEIVID, S.A.

--DROP PROCEDURE sp_cob80;

CREATE PROCEDURE "informix".sp_cob80(
a_compania		CHAR(3),
a_sucursal		CHAR(3),
a_fecha			DATE,
a_periodo		CHAR(1),
a_user			CHAR(8)
) RETURNING SMALLINT,
            CHAR(100);

DEFINE _campo			CHAR(81);
DEFINE _cedula		    CHAR(15);
DEFINE _cod_banco       CHAR(3);
DEFINE _cod_pagador     CHAR(10);
DEFINE _fecha_char      CHAR(8);
DEFINE _tipo_cuenta     CHAR(1);
DEFINE _dia_char,_mes_char        CHAR(2);
DEFINE _tipo_transaccion CHAR(1);
DEFINE _no_cuenta		CHAR(17);
DEFINE _codigo          CHAR(2);
DEFINE _monto,_cargo_especial,_monto_ach,_cargo_especial_tmp,_monto_poliza,_saldo	DEC(16,2);
DEFINE _monto_char      CHAR(11);
DEFINE _ruta_char       CHAR(9);
DEFINE _no_documento	CHAR(20);
DEFINE _nombr,_nombre_pagador			CHAR(100);
DEFINE _cod_cliente		CHAR(10);
DEFINE i,_max		INTEGER;
DEFINE _cant_tran_char  CHAR(3);
DEFINE _adenda			CHAR(80);
DEFINE _aseg_resultado  CHAR(22);
DEFINE _max_por_lote	INTEGER;
DEFINE _max_por_tran	INTEGER;
DEFINE _cant_tran		INTEGER;
DEFINE _cant_lote       INTEGER;
DEFINE _no_lote_char	CHAR(5);

DEFINE _error_code,_tipo_monto,_cnt_trans    SMALLINT;
DEFINE _ruta_numero,_mes,_ano,_van,_cnt		 INTEGER;

--SET DEBUG FILE TO "c:\sp_cob80.trc";
--trace on;

BEGIN

ON EXCEPTION SET _error_code 
 	RETURN _error_code, 'Error al Actualizar las Transacciones para el Banco. Cuenta:'||_no_cuenta;
END EXCEPTION           

DELETE FROM cobcuban;

let _max_por_lote = 99;
LET _max_por_tran = 999;

SELECT COUNT(*)
  INTO _cant_tran
  FROM cobcutas
 WHERE periodo = a_periodo;

IF _cant_tran IS NULL THEN
	LET _cant_tran = 0; 
END IF

IF _cant_tran = 0 THEN
	RETURN 1, 'No Existen Cuentas de Ach para Procesar en esta Quincena ... '; 
END IF

IF _cant_tran > (_max_por_lote * _max_por_tran) THEN
	RETURN 1, 'Cantidad de Transacciones Excede el Maximo Permitido por el Banco ...'; 
END IF

LET _cant_lote = 0;
LET _cant_tran = 0;

DELETE FROM cobcutmp;
DELETE FROM cobculot;

LET _cant_lote    = _cant_lote + 1;
LET _no_lote_char = sp_set_codigo(5, _cant_lote);

INSERT INTO cobculot
VALUES(
_no_lote_char,
a_fecha,
0,
0,
a_user,
'',
a_sucursal,
1      
);	

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

-- Selecciona los Lotes

LET _monto_char = '00000000000';
LET _ruta_char  = '000000000';


FOREACH
	SELECT h.no_cuenta,
	   	   c.monto,
	   	   c.cargo_especial,
		   c.no_documento
	  INTO _no_cuenta,
		   _monto,
		   _cargo_especial,
		   _no_documento	
	  FROM cobcutas c, cobcuhab h
	 WHERE c.no_cuenta = h.no_cuenta
	   AND c.periodo   in (a_periodo, "3")
	   AND c.procesar  = 1
	   AND c.excepcion = 0
	 ORDER BY h.no_cuenta

{   	if _no_cuenta = "01332003127" or _no_cuenta = "01101179408" or _no_cuenta = "06301106371" or _no_cuenta = "19101224034" then
	else
		continue foreach;
	end if	 }

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

	LET _cedula = null;

 	SELECT nombre,
		   cedula
	  INTO _nombre_pagador,
		   _cedula
 	  FROM cliclien                    
 	 WHERE cod_cliente = _cod_pagador;


  IF _cedula IS NULL THEN
	RETURN 1, 'No existe cedula del pagador para la cuenta: ' || _no_cuenta; 
  END IF

  let _aseg_resultado = trim(_nombre_pagador);
  let _cedula = trim(_cedula);

	LET _adenda = 'REF*TXT**POLIZA';


    LET _adenda = trim(_adenda) || trim(_no_documento);

	LET _monto_char = "00000000000";

	IF   _monto > 9999999.99 THEN
		LET _monto_char[1,11] = _monto;
	ELIF _monto > 999999.99 THEN
		LET _monto_char[2,11] = _monto;
	ELIF _monto > 99999.99 THEN
		LET _monto_char[3,11] = _monto;
	ELIF _monto > 9999.99 THEN
		LET _monto_char[4,11] = _monto;
	ELIF _monto > 999.99 THEN
		LET _monto_char[5,11] = _monto;
	ELIF _monto > 99.99 THEN
		LET _monto_char[6,11] = _monto;
	ELIF _monto > 9.99 THEN
		LET _monto_char[7,11] = _monto;
	ELSE
		LET _monto_char[8,11] = _monto;
	END IF

	SELECT ruta_numero
	  INTO _ruta_numero
	  FROM chqbanco
	 WHERE cod_banco = _cod_banco;

	IF   _ruta_numero > 99999999 THEN
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

	LET _cant_tran = _cant_tran + 1;

	IF _cant_tran > _max_por_tran THEN

		LET _cant_tran    = 1;
		LET _cant_lote    = _cant_lote + 1;
		LET _no_lote_char = sp_set_codigo(5, _cant_lote);

		INSERT INTO cobculot
		VALUES(
		_no_lote_char,
		a_fecha,
		0,
		0,
		a_user,
		'               ',
		a_sucursal,
		1      
		);	

	END IF

   	LET _cant_tran_char = sp_set_codigo(3, _cant_tran);

	LET _campo = 'L' || _cedula || _aseg_resultado || TRIM(_monto_char) || TRIM(_ruta_char) || _no_cuenta || _tipo_cuenta || _tipo_transaccion ||
				 ' ' || _cant_tran_char;


	INSERT INTO cobcuban VALUES (_campo);

	LET _campo = 'A' || trim(_adenda);

	INSERT INTO cobcuban VALUES (_campo);

	INSERT INTO cobcutmp
	VALUES (
	_cant_tran,
	_no_cuenta,
	_cod_pagador,
	'',
	_nombre_pagador,
	_monto,
	0,
	0,
	a_periodo,
	'',
	_no_lote_char,
	_no_documento
	);

 	 UPDATE cobcutas
	    SET fecha_ult_tran = a_fecha
	  WHERE no_cuenta      = _no_cuenta
	    AND periodo        in(a_periodo,"3")
	    AND procesar       = 1
	    AND excepcion      = 0;

END FOREACH

FOREACH
 SELECT COUNT(*),
  	    SUM(monto),
	    no_lote
   INTO _cant_tran,
        _monto,
        _no_lote_char
   FROM cobcutmp
  GROUP BY no_lote      

	UPDATE cobculot
	   SET total_transac = _cant_tran,
	       total_monto   = _monto
     WHERE no_lote       = _no_lote_char;
     
END FOREACH


RETURN 0, 'Actualizacion Exitosa ...'; 
END 
END PROCEDURE;