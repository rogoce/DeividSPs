-- Formulario 20 Electronico

-- Creado    : 16/02/2001 - Autor: Demetrio Hurtado Almanza
-- Modificado: 09/04/2001 - Autor: Demetrio Hurtado Almanza
-- Modificado: 23/09/2008 - Autor: Amado Perez -- Columnas nuevas de salida _bienes_ser default "1" y _itbm_pagado default "0.00"
                                               -- Modificacion del tamano de otras nombre a char(100), los montos a char(13) con decimales incluidos 
                                               -- Se eliminan otras como tipo de registro y codigo de la informacion
											   -- El formato de fecha ahora es "YYYYMMDD"
											   -- El digito verificador debe llevar 0 por delante cuando es un digito
											   -- No va el registro tipo 1
											   -- Se cambio el orden de las columnas para la generacion del archivo

-- Modificado: 28/10/2008 - Autor: Ricardo Jim‚nez
                                               -- se agrego la columna de itbms
                                               -- se agrego la columna de compras



-- SIS v.2.0 - - DEIVID, S.A.

DROP PROCEDURE sp_che14_new;

CREATE PROCEDURE sp_che14_new(
a_compania    CHAR(3),
a_sucursal    CHAR(3)
) RETURNING SMALLINT, CHAR(100);

-- Variable para la Definicion del Informante

DEFINE v_nombre_cia       CHAR(60);
DEFINE _total_reg_char    CHAR(10);
DEFINE _total_reg_int     INTEGER;
DEFINE _total_mon_char    CHAR(13);	
DEFINE _total_itbms_char  CHAR(13);
DEFINE _total_mon_dec     DEC(16,2);

DEFINE _cedula            CHAR(30);
DEFINE _cedula_20         CHAR(20);
DEFINE _digito_ver		  CHAR(2);
DEFINE _digito_ver2		  CHAR(2);
DEFINE _nombre			  CHAR(60);
DEFINE _nombre_100		  CHAR(100);
DEFINE _concepto          VARCHAR(2);
DEFINE _tipo_persona      CHAR(1);
DEFINE _transaccion       CHAR(20);
DEFINE _bienes_ser        CHAR(1);
DEFINE _itbm_pagado       CHAR(13);

-- Otras Variables

DEFINE _fecha             DATE;
DEFINE _fecha_char_8	  CHAR(8);
DEFINE _fecha_char_6	  CHAR(6);
DEFINE _concepto1         CHAR(1);	
DEFINE _campo1			  CHAR(255);
DEFINE _largo_cedula	  SMALLINT;
DEFINE _error_code        INTEGER;
DEFINE _cantidad          INTEGER;
DEFINE _tab				  CHAR(1);
DEFINE _itbms             DEC(16,2);
	
LET _tab        = "	";
LET _bienes_ser = "1";
LET _itbms      = 0  ;

--SET DEBUG FILE TO "sp_che14.trc"; 
--TRACE ON;                                                                

SET ISOLATION TO DIRTY READ;

BEGIN

ON  EXCEPTION SET _error_code 
    RETURN _error_code, 'Error al Actualizar el Archivo ASCII';
END EXCEPTION

SELECT COUNT(*)
  INTO _cantidad
  FROM chqfor20;

IF _cantidad IS NULL THEN
	LET _cantidad = 0;
END IF

IF _cantidad = 0 THEN
 	RETURN 1, 'No Hay Registros a Procesar, Por Favor Verifique ...';
END IF

LET  v_nombre_cia = sp_sis01(a_compania); 

DELETE FROM chqhacie;

-- Registro Tipo 1 (Datos del Informante)
-- Registro Tipo 2 (Datos de los Beneficiarios)
-- SET DEBUG FILE TO "sp_che14.trc";
-- TRACE ON;

FOREACH
 SELECT	cedula,
        digito_ver,
		nombre,
		concepto,
		tipo_persona,
		transaccion,
		fecha, 
		itbms,
		sum(monto)
   INTO	_cedula,
        _digito_ver,
		_nombre,
		_concepto,
		_tipo_persona,
		_transaccion,
		_fecha,
		_itbms,
		_total_mon_dec

   FROM chqfor20
  WHERE monto > 0 
  GROUP BY cedula, digito_ver, nombre, concepto, tipo_persona, transaccion, fecha, itbms 
  ORDER BY nombre, fecha
  
	-- Monto de la Transaccion

	LET _total_mon_char = '0000000000.00';

	IF  _total_mon_dec > 999999999.99 THEN
		LET _total_mon_char[1,13]  = _total_mon_dec;
	ELIF _total_mon_dec > 99999999.99 THEN
		LET _total_mon_char[2,13]  = _total_mon_dec;
	ELIF _total_mon_dec > 9999999.99  THEN
		LET _total_mon_char[3,13]  = _total_mon_dec;
	ELIF _total_mon_dec > 999999.99   THEN
		LET _total_mon_char[4,13]  = _total_mon_dec;
	ELIF _total_mon_dec > 99999.99    THEN
		LET _total_mon_char[5,13]  = _total_mon_dec;
	ELIF _total_mon_dec > 9999.99     THEN
		LET _total_mon_char[6,13]  = _total_mon_dec;
	ELIF _total_mon_dec > 999.99      THEN
		LET _total_mon_char[7,13]  = _total_mon_dec;
	ELIF _total_mon_dec > 99.99       THEN
		LET _total_mon_char[8,13]  = _total_mon_dec;
	ELIF _total_mon_dec > 9.99        THEN
		LET _total_mon_char[9,13]  = _total_mon_dec;
	ELSE
		LET _total_mon_char[10,13] = _total_mon_dec;
	END IF

	-- Itbms de Monto de la Transaccion

	LET _total_itbms_char = '0000000000.00';

	IF  _itbms  > 999999999.99 THEN
		LET _total_itbms_char[1,13]  = _itbms;
	ELIF _itbms > 99999999.99 THEN
		LET _total_itbms_char[2,13]  = _itbms;
	ELIF _itbms > 9999999.99  THEN
		LET _total_itbms_char[3,13]  = _itbms;
	ELIF _itbms > 999999.99   THEN
		LET _total_itbms_char[4,13]  = _itbms;
	ELIF _itbms > 99999.99    THEN
		LET _total_itbms_char[5,13]  = _itbms;
	ELIF _itbms > 9999.99     THEN
		LET _total_itbms_char[6,13]  = _itbms;
	ELIF _itbms > 999.99      THEN
		LET _total_itbms_char[7,13]  = _itbms;
	ELIF _itbms > 99.99       THEN
		LET _total_itbms_char[8,13]  = _itbms;
	ELIF _itbms > 9.99        THEN
		LET _total_itbms_char[9,13]  = _itbms;
	ELSE
		LET _total_itbms_char[10,13] = _itbms;
	END IF


	-- Fecha de la Transaccion

	IF DAY(_fecha) < 10 THEN
		LET _fecha_char_8[7,8] = '0' || DAY(_fecha);
	ELSE
		LET _fecha_char_8[7,8] = DAY(_fecha);
	END IF

	IF MONTH(_fecha) < 10 THEN
	   LET _fecha_char_8[5,6] = '0' || MONTH(_fecha);
	ELSE
	   LET _fecha_char_8[5,6] = MONTH(_fecha);
	END IF

	IF YEAR(_fecha) < 10 THEN
		LET _fecha_char_8[1,4] = '0' || YEAR(_fecha);
	ELSE
		LET _fecha_char_8[1,4] = YEAR(_fecha);
	END IF

	IF _transaccion IS NULL THEN
		LET _transaccion = '                    ';
	END IF

	-- Cedula Justificado a la Izquierda con Espacios en Blanco a la Derecha

	LET _largo_cedula = LENGTH(_cedula);
	LET _cedula_20    = '                    ';

	IF   _largo_cedula > 19 THEN
		LET _cedula_20[1,20] = _cedula;
	ELIF _largo_cedula > 18 THEN
		LET _cedula_20[1,19] = _cedula;
	ELIF _largo_cedula > 17 THEN
		LET _cedula_20[1,18] = _cedula;
	ELIF _largo_cedula > 16 THEN
		LET _cedula_20[1,17] = _cedula;
	ELIF _largo_cedula > 15 THEN
		LET _cedula_20[1,16] = _cedula;
	ELIF _largo_cedula > 14 THEN
		LET _cedula_20[1,15] = _cedula;
	ELIF _largo_cedula > 13 THEN
		LET _cedula_20[1,14] = _cedula;
	ELIF _largo_cedula > 12 THEN
		LET _cedula_20[1,13] = _cedula;
	ELIF _largo_cedula > 11 THEN
		LET _cedula_20[1,12] = _cedula;
	ELIF _largo_cedula > 10 THEN
		LET _cedula_20[1,11] = _cedula;
	ELIF _largo_cedula > 9 THEN
		LET _cedula_20[1,10] = _cedula;
	ELIF _largo_cedula > 8 THEN
		LET _cedula_20[1,9]  = _cedula;
	ELIF _largo_cedula > 7 THEN
		LET _cedula_20[1,8]  = _cedula;
	ELIF _largo_cedula > 6 THEN
		LET _cedula_20[1,7]  = _cedula;
	ELIF _largo_cedula > 5 THEN
		LET _cedula_20[1,6] = _cedula;
	ELIF _largo_cedula > 4 THEN
		LET _cedula_20[1,5] = _cedula;
	ELIF _largo_cedula > 3 THEN
		LET _cedula_20[1,4] = _cedula;
	ELIF _largo_cedula > 2 THEN
		LET _cedula_20[1,3] = _cedula;
	ELIF _largo_cedula > 1 THEN
		LET _cedula_20[1,2] = _cedula;
	END IF

	-- Nombre del Beneficiario

	LET _largo_cedula = LENGTH(_nombre);
	LET _nombre_100    = '                                                                                                    ';

	IF   _largo_cedula > 99 THEN
		LET _nombre_100[1,100] = TRIM(_nombre);
	ELIF _largo_cedula > 98 THEN
		LET _nombre_100[1,99]  = TRIM(_nombre);
	ELIF _largo_cedula > 97 THEN
		LET _nombre_100[1,98]  = TRIM(_nombre);
	ELIF _largo_cedula > 96 THEN
		LET _nombre_100[1,97] = TRIM(_nombre);
	ELIF _largo_cedula > 95 THEN
		LET _nombre_100[1,96] = TRIM(_nombre);
	ELIF _largo_cedula > 94 THEN
		LET _nombre_100[1,95] = TRIM(_nombre);
	ELIF _largo_cedula > 93 THEN
		LET _nombre_100[1,94] = TRIM(_nombre);
	ELIF _largo_cedula > 92 THEN
		LET _nombre_100[1,93] = TRIM(_nombre);
	ELIF _largo_cedula > 91 THEN
		LET _nombre_100[1,92] = TRIM(_nombre);
	ELIF _largo_cedula > 90 THEN
		LET _nombre_100[1,91] = TRIM(_nombre);
	ELIF _largo_cedula > 89 THEN
		LET _nombre_100[1,90] = TRIM(_nombre);
	ELIF _largo_cedula > 88 THEN
		LET _nombre_100[1,89] = TRIM(_nombre);
	ELIF _largo_cedula > 87 THEN
		LET _nombre_100[1,88] = TRIM(_nombre);
	ELIF _largo_cedula > 86 THEN
		LET _nombre_100[1,87] = TRIM(_nombre);
	ELIF _largo_cedula > 85 THEN
		LET _nombre_100[1,86] = TRIM(_nombre);
	ELIF _largo_cedula > 84 THEN
		LET _nombre_100[1,55] = TRIM(_nombre);
	ELIF _largo_cedula > 83 THEN
		LET _nombre_100[1,84] = TRIM(_nombre);
	ELIF _largo_cedula > 82 THEN
		LET _nombre_100[1,83] = TRIM(_nombre);
	ELIF _largo_cedula > 81 THEN
		LET _nombre_100[1,82] = TRIM(_nombre);
	ELIF _largo_cedula > 80 THEN
		LET _nombre_100[1,81] = TRIM(_nombre);
	ELIF  _largo_cedula > 79 THEN
		LET _nombre_100[1,80] = TRIM(_nombre);
	ELIF _largo_cedula > 78 THEN
		LET _nombre_100[1,79] = TRIM(_nombre);
	ELIF _largo_cedula > 77 THEN
		LET _nombre_100[1,78] = TRIM(_nombre);
	ELIF _largo_cedula > 76 THEN
		LET _nombre_100[1,77] = TRIM(_nombre);
	ELIF _largo_cedula > 75 THEN
		LET _nombre_100[1,76] = TRIM(_nombre);
	ELIF _largo_cedula > 74 THEN
		LET _nombre_100[1,75] = TRIM(_nombre);
	ELIF _largo_cedula > 73 THEN
		LET _nombre_100[1,74] = TRIM(_nombre);
	ELIF _largo_cedula > 72 THEN
		LET _nombre_100[1,73] = TRIM(_nombre);
	ELIF _largo_cedula > 71 THEN
		LET _nombre_100[1,72] = TRIM(_nombre);
	ELIF _largo_cedula > 70 THEN
		LET _nombre_100[1,71] = TRIM(_nombre);
	ELIF _largo_cedula > 69 THEN
		LET _nombre_100[1,70] = TRIM(_nombre);
	ELIF _largo_cedula > 68 THEN
		LET _nombre_100[1,69] = TRIM(_nombre);
	ELIF _largo_cedula > 67 THEN
		LET _nombre_100[1,68] = TRIM(_nombre);
	ELIF _largo_cedula > 66 THEN
		LET _nombre_100[1,67] = TRIM(_nombre);
	ELIF _largo_cedula > 65 THEN
		LET _nombre_100[1,66] = TRIM(_nombre);
	ELIF _largo_cedula > 64 THEN
		LET _nombre_100[1,65] = TRIM(_nombre);
	ELIF _largo_cedula > 63 THEN
		LET _nombre_100[1,64] = TRIM(_nombre);
	ELIF _largo_cedula > 62 THEN
		LET _nombre_100[1,63] = TRIM(_nombre);
	ELIF _largo_cedula > 61 THEN
		LET _nombre_100[1,62] = TRIM(_nombre);
	ELIF _largo_cedula > 60 THEN
		LET _nombre_100[1,61] = TRIM(_nombre);
	ELIF _largo_cedula > 59 THEN
		LET _nombre_100[1,60] = TRIM(_nombre);
	ELIF _largo_cedula > 58 THEN
		LET _nombre_100[1,59] = TRIM(_nombre);
	ELIF _largo_cedula > 57 THEN
		LET _nombre_100[1,58] = TRIM(_nombre);
	ELIF _largo_cedula > 56 THEN
		LET _nombre_100[1,57] = TRIM(_nombre);
	ELIF _largo_cedula > 55 THEN
		LET _nombre_100[1,56] = TRIM(_nombre);
	ELIF _largo_cedula > 54 THEN
		LET _nombre_100[1,55] = TRIM(_nombre);
	ELIF _largo_cedula > 53 THEN
		LET _nombre_100[1,54] = TRIM(_nombre);
	ELIF _largo_cedula > 52 THEN
		LET _nombre_100[1,53] = TRIM(_nombre);
	ELIF _largo_cedula > 51 THEN
		LET _nombre_100[1,52] = TRIM(_nombre);
	ELIF _largo_cedula > 50 THEN
		LET _nombre_100[1,51] = TRIM(_nombre);
   	ELIF _largo_cedula > 49 THEN
		LET _nombre_100[1,50] = TRIM(_nombre);
	ELIF _largo_cedula > 48 THEN
		LET _nombre_100[1,49] = TRIM(_nombre);
	ELIF _largo_cedula > 47 THEN
		LET _nombre_100[1,48] = TRIM(_nombre);
	ELIF _largo_cedula > 46 THEN
		LET _nombre_100[1,47] = TRIM(_nombre);
	ELIF _largo_cedula > 45 THEN
		LET _nombre_100[1,46] = TRIM(_nombre);
	ELIF _largo_cedula > 44 THEN
		LET _nombre_100[1,45] = TRIM(_nombre);
	ELIF _largo_cedula > 43 THEN
		LET _nombre_100[1,44] = TRIM(_nombre);
	ELIF _largo_cedula > 42 THEN
		LET _nombre_100[1,43] = TRIM(_nombre);
	ELIF _largo_cedula > 41 THEN
		LET _nombre_100[1,42] = TRIM(_nombre);
	ELIF _largo_cedula > 40 THEN
		LET _nombre_100[1,41] = TRIM(_nombre);
	ELIF _largo_cedula > 39 THEN
		LET _nombre_100[1,40] = TRIM(_nombre);
	ELIF _largo_cedula > 38 THEN
		LET _nombre_100[1,39] = TRIM(_nombre);
	ELIF _largo_cedula > 37 THEN
		LET _nombre_100[1,38] = TRIM(_nombre);
	ELIF _largo_cedula > 36 THEN
		LET _nombre_100[1,37] = TRIM(_nombre);
	ELIF _largo_cedula > 35 THEN
		LET _nombre_100[1,36] = TRIM(_nombre);
	ELIF _largo_cedula > 34 THEN
		LET _nombre_100[1,35] = TRIM(_nombre);
	ELIF _largo_cedula > 33 THEN
		LET _nombre_100[1,34] = TRIM(_nombre);
	ELIF _largo_cedula > 32 THEN
		LET _nombre_100[1,33] = TRIM(_nombre);
	ELIF _largo_cedula > 31 THEN
		LET _nombre_100[1,32] = TRIM(_nombre);
	ELIF _largo_cedula > 30 THEN
		LET _nombre_100[1,31] = TRIM(_nombre);
	ELIF _largo_cedula > 29 THEN
		LET _nombre_100[1,30] = TRIM(_nombre);
	ELIF _largo_cedula > 28 THEN
		LET _nombre_100[1,29] = TRIM(_nombre);
	ELIF _largo_cedula > 27 THEN
		LET _nombre_100[1,28] = TRIM(_nombre);
	ELIF _largo_cedula > 26 THEN
		LET _nombre_100[1,27] = TRIM(_nombre);
	ELIF _largo_cedula > 25 THEN
		LET _nombre_100[1,26] = TRIM(_nombre);
	ELIF _largo_cedula > 24 THEN
		LET _nombre_100[1,25] = TRIM(_nombre);
	ELIF _largo_cedula > 23 THEN
		LET _nombre_100[1,24] = TRIM(_nombre);
	ELIF _largo_cedula > 22 THEN
		LET _nombre_100[1,23] = TRIM(_nombre);
	ELIF _largo_cedula > 21 THEN
		LET _nombre_100[1,22] = TRIM(_nombre);
	ELIF _largo_cedula > 20 THEN
		LET _nombre_100[1,21] = TRIM(_nombre);
	ELIF _largo_cedula > 19 THEN
		LET _nombre_100[1,20] = TRIM(_nombre);
	ELIF _largo_cedula > 18 THEN
		LET _nombre_100[1,19] = TRIM(_nombre);
	ELIF _largo_cedula > 17 THEN
		LET _nombre_100[1,18] = TRIM(_nombre);
	ELIF _largo_cedula > 16 THEN
		LET _nombre_100[1,17] = TRIM(_nombre);
	ELIF _largo_cedula > 15 THEN
		LET _nombre_100[1,16] = TRIM(_nombre);
	ELIF _largo_cedula > 14 THEN
		LET _nombre_100[1,15] = TRIM(_nombre);
	ELIF _largo_cedula > 13 THEN
		LET _nombre_100[1,14] = TRIM(_nombre);
	ELIF _largo_cedula > 12 THEN
		LET _nombre_100[1,13] = TRIM(_nombre);
	ELIF _largo_cedula > 11 THEN
		LET _nombre_100[1,12] = TRIM(_nombre);
	ELIF _largo_cedula > 10 THEN
		LET _nombre_100[1,11] = TRIM(_nombre);
	ELIF _largo_cedula > 9 THEN
		LET _nombre_100[1,10] = TRIM(_nombre);
	ELIF _largo_cedula > 8 THEN
		LET _nombre_100[1,9] = TRIM(_nombre);
	ELIF _largo_cedula > 7 THEN
		LET _nombre_100[1,8] = TRIM(_nombre);
	ELIF _largo_cedula > 6 THEN
		LET _nombre_100[1,7] = TRIM(_nombre);
	ELIF _largo_cedula > 5 THEN
		LET _nombre_100[1,6] = TRIM(_nombre);
	ELIF _largo_cedula > 4 THEN
		LET _nombre_100[1,5] = TRIM(_nombre);
	ELIF _largo_cedula > 3 THEN
		LET _nombre_100[1,4] = TRIM(_nombre);
	ELIF _largo_cedula > 2 THEN
		LET _nombre_100[1,3] = TRIM(_nombre);
	ELIF _largo_cedula > 1 THEN
		LET _nombre_100[1,2] = TRIM(_nombre);
	END IF

	LET _nombre_100 = _nombre_100;

	IF _digito_ver IS NULL THEN
		LET _digito_ver = '00';
    ELSE
		-- DV Justificado a la Derecha con ceros a la Izquierda

		LET _largo_cedula = LENGTH(TRIM(_digito_ver));
		LET _digito_ver2  = '00';

		IF _largo_cedula = 1 THEN
			LET _digito_ver2[2,2] = TRIM(_digito_ver);
		ELSE
			LET _digito_ver2 = trim(_digito_ver);
		END IF

	END IF


-- Impuesto pagado
   
   LET _itbm_pagado = '0000000000.00';

-- Concepto de 1
   LET _concepto = REPLACE(_concepto,"0","");
   LET _concepto1 = TRIM(_concepto);


-- LET _nombre = '';


--TRACE ON;                                                                

 LET _campo1 = _tipo_persona      || _tab ||
 				_cedula_20        || _tab ||
 				_digito_ver2      || _tab ||
 				_nombre_100       || _tab ||
 				_transaccion      || _tab ||
 				_fecha_char_8     || _tab ||
 				_concepto1        || _tab ||
 				_bienes_ser	      || _tab ||
 				_total_mon_char   || _tab ||
 				_total_itbms_char ;


  {LET _campo1 = _tipo_persona     ||
  				_cedula_20	      ||
  				_digito_ver2      ||
  				_nombre_100	      ||
  				_transaccion      ||
  				_fecha_char_8     ||
  				_concepto1	      ||
  				_bienes_ser	      ||
  				_total_mon_char	  ||
  				_total_itbms_char ;	}
											  
--TRACE OFF;                                                                

--TRACE _campo1;

 	INSERT INTO chqhacie
	VALUES(_campo1);

--EXIT FOREACH;

END FOREACH

--DELETE FROM chqfor20;

RETURN 0, 'Actualizacion Exitosa ...';

END

END PROCEDURE;