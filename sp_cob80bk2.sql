-- Generacion del Archivo de transacciones para Multi Credit Bank
-- Creado    : 22/02/2001 - Autor: Demetrio Hurtado Almanza 
-- Modificado: 26/12/2001 - Autor: Armando Moreno Montenegro

-- SIS v.2.0 - DEIVID, S.A.

--DROP PROCEDURE sp_cob80bk2;

CREATE PROCEDURE "informix".sp_cob80bk2(
a_compania		CHAR(3),
a_sucursal		CHAR(3),
a_fecha			DATE,
a_periodo		CHAR(1),
a_user			CHAR(8)
) RETURNING SMALLINT,
            CHAR(100);

DEFINE _campo			CHAR(81);
DEFINE _cedula		    CHAR(5);
--define _char_1          char(10);
DEFINE _aseg_resultado  CHAR(22);
DEFINE _monto_char      CHAR(11);
DEFINE _ruta_char       CHAR(9);
DEFINE _no_cuenta		CHAR(17);
DEFINE _tipo_cuenta     CHAR(1);
DEFINE _tipo_transaccion CHAR(1);
define _char_2          char(1);
define _char_3          char(3);
DEFINE _cod_banco       CHAR(3);
DEFINE _cod_pagador     CHAR(10);
DEFINE _fecha_char      CHAR(8);
DEFINE _dia_char,_mes_char        CHAR(2);
define _per             char(1);

DEFINE _codigo          CHAR(2);
DEFINE _monto,_cargo_especial,_monto_ach,_cargo_especial_tmp,_monto_poliza,_saldo	DEC(16,2);
DEFINE _no_documento	CHAR(20);
DEFINE _nombr,_nombre_pagador			CHAR(100);
DEFINE _cod_cliente		CHAR(10);
DEFINE i,_max		INTEGER;
DEFINE _cant_tran_char  CHAR(3);
DEFINE _adenda			CHAR(80);

DEFINE _max_por_lote	INTEGER;
DEFINE _max_por_tran	INTEGER;
DEFINE _cant_tran		INTEGER;
DEFINE _cant_lote       INTEGER;
DEFINE _no_lote_char	CHAR(5);
DEFINE _fecha_hoy		date;
define _periodo2        char(1);
define _periodo         char(1);
DEFINE _fecha_hasta     DATE;
DEFINE v_por_vencer      DEC(16,2);
DEFINE v_exigible        DEC(16,2);
DEFINE v_corriente       DEC(16,2);
DEFINE v_monto_30        DEC(16,2);
DEFINE v_monto_60        DEC(16,2);
DEFINE v_monto_90        DEC(16,2);
define v_periodo         char(7);
define v_fecha           date;
define _orden            char(6);
DEFINE _error_code,_tipo_monto,_cnt_trans    SMALLINT;
DEFINE _ruta_numero,_mes,_ano,_van,_cnt		 INTEGER;
DEFINE _ult_pago        DEC(16,2);
DEFINE _pronto_pago		SMALLINT;
define _valor			SMALLINT;
define _mensaje			char(50);


--SET DEBUG FILE TO "c:\sp_cob80.trc";
--trace on;

BEGIN

ON EXCEPTION SET _error_code 
 	RETURN _error_code, 'Error al Actualizar las Transacciones para el Banco. Cuenta:'||_no_cuenta;
END EXCEPTION           

DELETE FROM cobcuban;

LET v_fecha = TODAY;

IF MONTH(v_fecha) < 10 THEN
	LET v_periodo = YEAR(v_fecha) || '-0' || MONTH(v_fecha);
ELSE
	LET v_periodo = YEAR(v_fecha) || '-' || MONTH(v_fecha);
END IF 


let _fecha_hoy    = today;
let _max_por_lote = 99;
LET _max_por_tran = 99999;
let _char_3 = '   ';
--let _char_1 = '          ';
let _char_2 = ' ';
let _per = '';

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

--DELETE FROM cobcutmp;
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

foreach
	select periodo
	  into _per
	  from cobcutmp
	 where rechazado = 1

	exit foreach;
end foreach

if _per = "" or _per is null then
	let _per = a_periodo;
end if

DELETE FROM cobcutmp;

FOREACH
	SELECT h.no_cuenta,
	   	   c.monto,
	   	   c.cargo_especial,
		   c.no_documento,
		   c.periodo,
		   c.periodo2,
  		   c.fecha_hasta
	  INTO _no_cuenta,
		   _monto,
		   _cargo_especial,
		   _no_documento,
		   _periodo,
		   _periodo2,
		   _fecha_hasta	
	  FROM cobcutas c, cobcuhab h
	 WHERE c.no_cuenta = h.no_cuenta
	   AND c.periodo   in (a_periodo,_per ,"3")
	   AND c.procesar  = 1
	   AND c.excepcion = 0
	 ORDER BY h.no_cuenta

--Esto es para el cargo adicional.

	if _periodo2 is null then
		let _periodo2 = "0";
	end if

	if _fecha_hasta is not null then

		if _fecha_hasta > _fecha_hoy then  -- tiene cargo adicional
			if _periodo = _periodo2 then   -- se debe sumar el cargo al monto
				let _monto = _monto + _cargo_especial;
			else
				if a_periodo = _periodo2 then
					if _cargo_especial > 0 then
						let _monto = _cargo_especial;
					end if
				end if
			end if
		end if
	end if

	CALL sp_cob33(a_compania, a_sucursal, _no_documento, v_periodo, v_fecha)
		RETURNING   v_por_vencer,
					v_exigible,
					v_corriente,
					v_monto_30,
					v_monto_60,
					v_monto_90,
					_saldo;

    if _monto > _saldo THEN	      --CARGO MAYOR AL SALDO
	   LET _monto = _saldo;
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

	IF _monto > 9999999.99 THEN
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

	let _ruta_char = "000000000";

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

	if _monto = 0 then
		continue foreach;
	end if

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

   	LET _cedula = sp_set_codigo(5, _cant_tran);

    let _campo[1,1]   = 'L';
    let _campo[2,16]  = _cedula;
	let _campo[17,38] =	_aseg_resultado;
	let _campo[39,49] =	trim(_monto_char);
	let _campo[50,58] =	trim(_ruta_char);
	let _campo[59,75] =	trim(_no_cuenta);
	let _campo[76,76] =	trim(_tipo_cuenta);
	let _campo[77,77] =	trim(_tipo_transaccion);
	let _campo[78,78] =	' ';
	let _campo[79,81] =	'   ';

	let _orden = _cedula;

	INSERT INTO cobcuban VALUES (_campo,_orden);

	LET _campo = 'A' || trim(_adenda);
	let _orden = _cedula || 'A';

	INSERT INTO cobcuban VALUES (_campo,_orden);

    let _ult_pago    = 0;
	let _pronto_pago = 0;
	call sp_sis395(_no_documento) returning _valor, _mensaje,_ult_pago;

	if _valor = 0 then
		let _pronto_pago = 1;
		let _monto       = _ult_pago;
	else
		let _pronto_pago = 0;		
	end if

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
	_no_documento,
	_pronto_pago
	);

 	 UPDATE cobcutas
	    SET fecha_ult_tran = a_fecha
	  WHERE no_cuenta      = _no_cuenta
	    AND periodo        in(a_periodo,_per,"3")
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