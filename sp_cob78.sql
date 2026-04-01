-- Verificacion de los registros a generar para el banco

-- Creado    : 22/02/2001 - Autor: Demetrio Hurtado Almanza 
-- Modificado: 15/11/2001 - Autor: Armando Moreno M. ref. sp_cob43

-- SIS v.2.0 - DEIVID, S.A.

--DROP PROCEDURE sp_cob78;

CREATE PROCEDURE "informix".sp_cob78(
a_compania		CHAR(3),
a_sucursal		CHAR(3),
a_fecha			DATE,
a_periodo		CHAR(1),
a_user			CHAR(8)
) RETURNING SMALLINT,
            CHAR(100);


DEFINE _no_cuenta		CHAR(17);
DEFINE _no_poliza       CHAR(10);
DEFINE _cod_pagador     CHAR(10);
DEFINE _codigo          CHAR(2);
DEFINE _monto			DEC(16,2);
DEFINE _cargo_especial  DEC(16,2);
DEFINE _monto_ach    	DEC(16,2);
DEFINE _monto_visa   	DEC(16,2);
DEFINE _no_documento	CHAR(20);
DEFINE _cant_tran		INTEGER;
DEFINE _tipo_monto		SMALLINT;
DEFINE _procesar        SMALLINT;
DEFINE _error_code      SMALLINT;
DEFINE _cuantos         SMALLINT;

BEGIN

ON EXCEPTION SET _error_code
 	RETURN _error_code, 'Error al Actualizar los Registros';
END EXCEPTION

SELECT COUNT(*)
  INTO _cant_tran
  FROM cobcutas
 WHERE periodo in (a_periodo, "3");

IF _cant_tran IS NULL THEN
	LET _cant_tran = 0; 
END IF

IF _cant_tran = 0 THEN
	RETURN 1, 'No Existen Ach para Procesar en esta Quincena ... '; 
END IF

FOREACH
 SELECT h.no_cuenta,
		SUM(c.monto),
		SUM(c.cargo_especial)
   INTO _no_cuenta,
		_monto,
		_cargo_especial
   FROM cobcutas c, cobcuhab h
  WHERE c.no_cuenta = h.no_cuenta
    AND c.periodo   in (a_periodo, "3")
	AND c.procesar  = 1
	AND c.excepcion = 0
  GROUP BY h.no_cuenta
  ORDER BY h.no_cuenta

 {SELECT cod_pagador
   INTO _cod_pagador
   FROM cobcuhab
  WHERE no_cuenta = _no_cuenta;

 SELECT count(no_cuenta)
   INTO _cuantos
   FROM cobcuhab
  WHERE cod_pagador = _cod_pagador;

  IF _cuantos > 1 THEN
   	RETURN 1, 'Error, Hay mas de una cuenta con un mismo pagador.' || _cod_pagador;
  END IF}

 	SELECT tipo_monto,
		   monto_ach
 	  INTO _tipo_monto,
		   _monto_ach
 	  FROM cobcuhab
 	 WHERE no_cuenta = _no_cuenta;

	 IF _monto = 0 THEN
		CONTINUE FOREACH;
	 END IF

	IF _tipo_monto IS NULL THEN
		LET _tipo_monto = 3;
	END IF

	IF _tipo_monto = 0 THEN --Monto Fijo
		IF _monto <> _monto_ach THEN
	    	RETURN 1, 'Error en Monto de la cuenta No.'|| _no_cuenta;
		END IF

		IF _cargo_especial > 0 THEN
			RETURN 1, 'Tipo de Monto es Fijo, Cargo Especial debe ser cero para la cuenta No.'|| _no_cuenta;
		END IF
	END IF
	IF _tipo_monto = 1 THEN --Monto Variable Maximo
		IF _monto > _monto_ach THEN
			RETURN 1, 'Sumatoria del Monto no puede ser mayor al monto del Ach para la cuenta No.'|| _no_cuenta;
		END IF

		IF _cargo_especial > 0 THEN
			IF _cargo_especial > _monto_ach THEN
				RETURN 1, 'Sumatoria del Cargo Especial no puede ser mayor al monto del Ach para la cuenta No.'|| _no_cuenta;
			END IF
		END IF
	END IF
	IF _tipo_monto = 3 THEN
		RETURN 1, 'Debe ingresar el TIPO DE MONTO de la cuenta No.'|| _no_cuenta;
	END IF

END FOREACH

RETURN 0, 'Verificacion Exitosa ...'; 

END 

END PROCEDURE;
