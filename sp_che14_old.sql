-- Formulario 20 Electronico

-- Creado    : 16/02/2001 - Autor: Demetrio Hurtado Almanza 
-- Modificado: 09/04/2001 - Autor: Demetrio Hurtado Almanza

-- SIS v.2.0 - - DEIVID, S.A.

DROP PROCEDURE sp_che14;

CREATE PROCEDURE sp_che14(
a_compania    CHAR(3),
a_sucursal    CHAR(3)
) RETURNING SMALLINT, CHAR(100);

-- Variable para la Definicion del Informante

DEFINE v_nombre_cia       CHAR(60);
DEFINE _total_reg_char    CHAR(10);
DEFINE _total_reg_int     INTEGER;
DEFINE _total_mon_char    CHAR(20);	
DEFINE _total_mon_dec     INTEGER;

DEFINE _cedula            CHAR(30);
DEFINE _cedula_20         CHAR(20);
DEFINE _digito_ver		  CHAR(2);
DEFINE _nombre			  CHAR(60);
DEFINE _nombre_60		  CHAR(60);
DEFINE _concepto          CHAR(2);
DEFINE _tipo_persona      CHAR(1);
DEFINE _transaccion       CHAR(20); 

-- Otras Variables

DEFINE _fecha             DATE;     
DEFINE _fecha_char_8	  CHAR(8);	
DEFINE _fecha_char_6	  CHAR(6);	
DEFINE _campo1			  CHAR(255);
DEFINE _largo_cedula	  SMALLINT;
DEFINE _error_code        INTEGER;
DEFINE _cantidad          INTEGER;
DEFINE _tab				  CHAR(1);
	
LET _tab = "	";

--SET DEBUG FILE TO "sp_che14.trc"; 
--TRACE ON;                                                                

SET ISOLATION TO DIRTY READ;

BEGIN

ON EXCEPTION SET _error_code 
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

FOREACH
 SELECT fecha
   INTO _fecha
   FROM chqfor20
	EXIT FOREACH;
END FOREACH

IF MONTH(_fecha) < 10 THEN
	LET _fecha_char_6 = '0' || MONTH(_fecha) || YEAR(_fecha);
ELSE
	LET _fecha_char_6 = MONTH(_fecha) || YEAR(_fecha);
END IF

SELECT COUNT(*),
	   SUM(monto)
  INTO _total_reg_int,
       _total_mon_dec
  FROM chqfor20
 WHERE monto > 0;	   	

-- Cantidad de Registros   

LET _total_reg_char = '0000000000';

IF   _total_reg_int > 999999999 THEN
	LET _total_reg_char[1,10]  = _total_reg_int;
ELIF _total_reg_int > 99999999 THEN
	LET _total_reg_char[2,10]  = _total_reg_int;
ELIF _total_reg_int > 9999999 THEN
	LET _total_reg_char[3,10]  = _total_reg_int;
ELIF _total_reg_int > 999999 THEN
	LET _total_reg_char[4,10]  = _total_reg_int;
ELIF _total_reg_int > 99999 THEN
	LET _total_reg_char[5,10]  = _total_reg_int;
ELIF _total_reg_int > 9999 THEN
	LET _total_reg_char[6,10]  = _total_reg_int;
ELIF _total_reg_int > 999 THEN
	LET _total_reg_char[7,10]  = _total_reg_int;
ELIF _total_reg_int > 99 THEN
	LET _total_reg_char[8,10]  = _total_reg_int;
ELIF _total_reg_int > 9 THEN
	LET _total_reg_char[9,10]  = _total_reg_int;
ELSE
	LET _total_reg_char[10,10] = _total_reg_int;
END IF

-- Monto Total a Pagar

LET _total_mon_char = '00000000000000000000';

IF   _total_mon_dec > 999999999 THEN
	LET _total_mon_char[11,20] = _total_mon_dec;
ELIF _total_mon_dec > 99999999 THEN
	LET _total_mon_char[12,20] = _total_mon_dec;
ELIF _total_mon_dec > 9999999 THEN
	LET _total_mon_char[13,20] = _total_mon_dec;
ELIF _total_mon_dec > 999999 THEN
	LET _total_mon_char[14,20] = _total_mon_dec;
ELIF _total_mon_dec > 99999 THEN
	LET _total_mon_char[15,20] = _total_mon_dec;
ELIF _total_mon_dec > 9999 THEN
	LET _total_mon_char[16,20] = _total_mon_dec;
ELIF _total_mon_dec > 999 THEN
	LET _total_mon_char[17,20] = _total_mon_dec;
ELIF _total_mon_dec > 99 THEN
	LET _total_mon_char[18,20] = _total_mon_dec;
ELIF _total_mon_dec > 9 THEN
	LET _total_mon_char[19,20] = _total_mon_dec;
ELSE
	LET _total_mon_char[20,20] = _total_mon_dec;
END IF

LET _campo1 = '1' 					 || _tab ||
              _fecha_char_6 		 || _tab ||
			  '20' 					 || _tab ||
			  '00030746-0002-240130' || _tab ||
			  '72' 					 || _tab ||
			  v_nombre_cia 			 || _tab ||
			  _total_reg_char 		 || _tab ||
			  _total_mon_char;
			  
INSERT INTO chqhacie
VALUES(_campo1);

-- Registro Tipo 2 (Datos de los Beneficiarios)
	    
--SET DEBUG FILE TO "sp_che14.trc"; 
--TRACE ON;                                                                

FOREACH
 SELECT	cedula,
        digito_ver,
		nombre,
		concepto,
		tipo_persona,
		monto,
		transaccion,
		fecha
   INTO	_cedula,
        _digito_ver,
		_nombre,
		_concepto,
		_tipo_persona,
		_total_mon_dec,
		_transaccion,
		_fecha
   FROM chqfor20
  WHERE monto > 0
--    AND cedula = "1-12-885"
  ORDER BY nombre, fecha
  
	-- Monto de la Transaccion

	LET _total_mon_char = '00000000000000000000';

	IF   _total_mon_dec > 999999999 THEN
		LET _total_mon_char[11,20] = _total_mon_dec;
	ELIF _total_mon_dec > 99999999 THEN
		LET _total_mon_char[12,20] = _total_mon_dec;
	ELIF _total_mon_dec > 9999999 THEN
		LET _total_mon_char[13,20] = _total_mon_dec;
	ELIF _total_mon_dec > 999999 THEN
		LET _total_mon_char[14,20] = _total_mon_dec;
	ELIF _total_mon_dec > 99999 THEN
		LET _total_mon_char[15,20] = _total_mon_dec;
	ELIF _total_mon_dec > 9999 THEN
		LET _total_mon_char[16,20] = _total_mon_dec;
	ELIF _total_mon_dec > 999 THEN
		LET _total_mon_char[17,20] = _total_mon_dec;
	ELIF _total_mon_dec > 99 THEN
		LET _total_mon_char[18,20] = _total_mon_dec;
	ELIF _total_mon_dec > 9 THEN
		LET _total_mon_char[19,20] = _total_mon_dec;
	ELSE
		LET _total_mon_char[20,20] = _total_mon_dec;
	END IF

	-- Fecha de la Transaccion

	IF DAY(_fecha) < 10 THEN
		LET _fecha_char_8[1,2] = '0' || DAY(_fecha);
	ELSE
		LET _fecha_char_8[1,2] = DAY(_fecha);
	END IF

	IF MONTH(_fecha) < 10 THEN
		LET _fecha_char_8[3,4] = '0' || MONTH(_fecha);
	ELSE
		LET _fecha_char_8[3,4] = MONTH(_fecha);
	END IF

	IF YEAR(_fecha) < 10 THEN
		LET _fecha_char_8[5,8] = '0' || YEAR(_fecha);
	ELSE
		LET _fecha_char_8[5,8] = YEAR(_fecha);
	END IF

	IF _transaccion IS NULL THEN
		LET _transaccion = '                    ';
	END IF

{
	-- Cedula justificado a la Derecha con Ceros a la Izquierda

	LET _largo_cedula = LENGTH(_cedula);
	LET _cedula_20    = '00000000000000000000';

	IF   _largo_cedula > 19 THEN
		LET _cedula_20[1,20] = _cedula;
	ELIF _largo_cedula > 18 THEN
		LET _cedula_20[2,20] = _cedula;
	ELIF _largo_cedula > 17 THEN
		LET _cedula_20[3,20] = _cedula;
	ELIF _largo_cedula > 16 THEN
		LET _cedula_20[4,20] = _cedula;
	ELIF _largo_cedula > 15 THEN
		LET _cedula_20[5,20] = _cedula;
	ELIF _largo_cedula > 14 THEN
		LET _cedula_20[6,20] = _cedula;
	ELIF _largo_cedula > 13 THEN
		LET _cedula_20[7,20] = _cedula;
	ELIF _largo_cedula > 12 THEN
		LET _cedula_20[8,20] = _cedula;
	ELIF _largo_cedula > 11 THEN
		LET _cedula_20[9,20] = _cedula;
	ELIF _largo_cedula > 10 THEN
		LET _cedula_20[10,20] = _cedula;
	ELIF _largo_cedula > 9 THEN
		LET _cedula_20[11,20] = _cedula;
	ELIF _largo_cedula > 8 THEN
		LET _cedula_20[12,20] = _cedula;
	ELIF _largo_cedula > 7 THEN
		LET _cedula_20[13,20] = _cedula;
	ELIF _largo_cedula > 6 THEN
		LET _cedula_20[14,20] = _cedula;
	ELIF _largo_cedula > 5 THEN
		LET _cedula_20[15,20] = _cedula;
	ELIF _largo_cedula > 4 THEN
		LET _cedula_20[16,20] = _cedula;
	ELIF _largo_cedula > 3 THEN
		LET _cedula_20[17,20] = _cedula;
	ELIF _largo_cedula > 2 THEN
		LET _cedula_20[18,20] = _cedula;
	ELIF _largo_cedula > 1 THEN
		LET _cedula_20[19,20] = _cedula;
	END IF
}

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
		LET _cedula_20[1,9] = _cedula;
	ELIF _largo_cedula > 7 THEN
		LET _cedula_20[1,8] = _cedula;
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
	LET _nombre_60    = '                                                            ';
--	LET _nombre_60    = '000000000000000000000000000000000000000000000000000000000000';

	IF   _largo_cedula > 59 THEN
		LET _nombre_60[1,60] = TRIM(_nombre);
	ELIF _largo_cedula > 58 THEN
		LET _nombre_60[1,59] = TRIM(_nombre);
	ELIF _largo_cedula > 57 THEN
		LET _nombre_60[1,58] = TRIM(_nombre);
	ELIF _largo_cedula > 56 THEN
		LET _nombre_60[1,57] = TRIM(_nombre);
	ELIF _largo_cedula > 55 THEN
		LET _nombre_60[1,56] = TRIM(_nombre);
	ELIF _largo_cedula > 54 THEN
		LET _nombre_60[1,55] = TRIM(_nombre);
	ELIF _largo_cedula > 53 THEN
		LET _nombre_60[1,54] = TRIM(_nombre);
	ELIF _largo_cedula > 52 THEN
		LET _nombre_60[1,53] = TRIM(_nombre);
	ELIF _largo_cedula > 51 THEN
		LET _nombre_60[1,52] = TRIM(_nombre);
	ELIF _largo_cedula > 50 THEN
		LET _nombre_60[1,51] = TRIM(_nombre);

	ELIF _largo_cedula > 49 THEN
		LET _nombre_60[1,50] = TRIM(_nombre);
	ELIF _largo_cedula > 48 THEN
		LET _nombre_60[1,49] = TRIM(_nombre);
	ELIF _largo_cedula > 47 THEN
		LET _nombre_60[1,48] = TRIM(_nombre);
	ELIF _largo_cedula > 46 THEN
		LET _nombre_60[1,47] = TRIM(_nombre);
	ELIF _largo_cedula > 45 THEN
		LET _nombre_60[1,46] = TRIM(_nombre);
	ELIF _largo_cedula > 44 THEN
		LET _nombre_60[1,45] = TRIM(_nombre);
	ELIF _largo_cedula > 43 THEN
		LET _nombre_60[1,44] = TRIM(_nombre);
	ELIF _largo_cedula > 42 THEN
		LET _nombre_60[1,43] = TRIM(_nombre);
	ELIF _largo_cedula > 41 THEN
		LET _nombre_60[1,42] = TRIM(_nombre);
	ELIF _largo_cedula > 40 THEN
		LET _nombre_60[1,41] = TRIM(_nombre);

	ELIF _largo_cedula > 39 THEN
		LET _nombre_60[1,40] = TRIM(_nombre);
	ELIF _largo_cedula > 38 THEN
		LET _nombre_60[1,39] = TRIM(_nombre);
	ELIF _largo_cedula > 37 THEN
		LET _nombre_60[1,38] = TRIM(_nombre);
	ELIF _largo_cedula > 36 THEN
		LET _nombre_60[1,37] = TRIM(_nombre);
	ELIF _largo_cedula > 35 THEN
		LET _nombre_60[1,36] = TRIM(_nombre);
	ELIF _largo_cedula > 34 THEN
		LET _nombre_60[1,35] = TRIM(_nombre);
	ELIF _largo_cedula > 33 THEN
		LET _nombre_60[1,34] = TRIM(_nombre);
	ELIF _largo_cedula > 32 THEN
		LET _nombre_60[1,33] = TRIM(_nombre);
	ELIF _largo_cedula > 31 THEN
		LET _nombre_60[1,32] = TRIM(_nombre);
	ELIF _largo_cedula > 30 THEN
		LET _nombre_60[1,31] = TRIM(_nombre);

	ELIF _largo_cedula > 29 THEN
		LET _nombre_60[1,30] = TRIM(_nombre);
	ELIF _largo_cedula > 28 THEN
		LET _nombre_60[1,29] = TRIM(_nombre);
	ELIF _largo_cedula > 27 THEN
		LET _nombre_60[1,28] = TRIM(_nombre);
	ELIF _largo_cedula > 26 THEN
		LET _nombre_60[1,27] = TRIM(_nombre);
	ELIF _largo_cedula > 25 THEN
		LET _nombre_60[1,26] = TRIM(_nombre);
	ELIF _largo_cedula > 24 THEN
		LET _nombre_60[1,25] = TRIM(_nombre);
	ELIF _largo_cedula > 23 THEN
		LET _nombre_60[1,24] = TRIM(_nombre);
	ELIF _largo_cedula > 22 THEN
		LET _nombre_60[1,23] = TRIM(_nombre);
	ELIF _largo_cedula > 21 THEN
		LET _nombre_60[1,22] = TRIM(_nombre);
	ELIF _largo_cedula > 20 THEN
		LET _nombre_60[1,21] = TRIM(_nombre);

	ELIF _largo_cedula > 19 THEN
		LET _nombre_60[1,20] = TRIM(_nombre);
	ELIF _largo_cedula > 18 THEN
		LET _nombre_60[1,19] = TRIM(_nombre);
	ELIF _largo_cedula > 17 THEN
		LET _nombre_60[1,18] = TRIM(_nombre);
	ELIF _largo_cedula > 16 THEN
		LET _nombre_60[1,17] = TRIM(_nombre);
	ELIF _largo_cedula > 15 THEN
		LET _nombre_60[1,16] = TRIM(_nombre);
	ELIF _largo_cedula > 14 THEN
		LET _nombre_60[1,15] = TRIM(_nombre);
	ELIF _largo_cedula > 13 THEN
		LET _nombre_60[1,14] = TRIM(_nombre);
	ELIF _largo_cedula > 12 THEN
		LET _nombre_60[1,13] = TRIM(_nombre);
	ELIF _largo_cedula > 11 THEN
		LET _nombre_60[1,12] = TRIM(_nombre);
	ELIF _largo_cedula > 10 THEN
		LET _nombre_60[1,11] = TRIM(_nombre);

	ELIF _largo_cedula > 9 THEN
		LET _nombre_60[1,10] = TRIM(_nombre);
	ELIF _largo_cedula > 8 THEN
		LET _nombre_60[1,9] = TRIM(_nombre);
	ELIF _largo_cedula > 7 THEN
		LET _nombre_60[1,8] = TRIM(_nombre);
	ELIF _largo_cedula > 6 THEN
		LET _nombre_60[1,7] = TRIM(_nombre);
	ELIF _largo_cedula > 5 THEN
		LET _nombre_60[1,6] = TRIM(_nombre);
	ELIF _largo_cedula > 4 THEN
		LET _nombre_60[1,5] = TRIM(_nombre);
	ELIF _largo_cedula > 3 THEN
		LET _nombre_60[1,4] = TRIM(_nombre);
	ELIF _largo_cedula > 2 THEN
		LET _nombre_60[1,3] = TRIM(_nombre);
	ELIF _largo_cedula > 1 THEN
		LET _nombre_60[1,2] = TRIM(_nombre);
	END IF

	LET _nombre_60 = _nombre_60;

	IF _digito_ver IS NULL THEN
		LET _digito_ver = '00';
	END IF

--	LET _nombre = '';


--TRACE ON;                                                                

	LET _campo1 = '2'             || _tab ||
				  '20'            || _tab ||
				  _concepto       || _tab ||
				  _cedula_20      || _tab ||
				  _digito_ver     || _tab ||
				  _tipo_persona   || _tab ||
				  _nombre_60      || _tab ||
				  _total_mon_char || _tab ||
				  _transaccion    || _tab ||
				  _fecha_char_8;	

--TRACE OFF;                                                                

{
	LET _campo1[1,1]     = '2';
	LET _campo1[2,3]     = '20';
	LET _campo1[4,5]     = _concepto;
	LET _campo1[6,25]    = _cedula_20;
	LET _campo1[26,27]   = _digito_ver;
	LET _campo1[28,28]   = _tipo_persona;
	LET _campo1[29,88]   = _nombre_60;
	LET _campo1[89,108]  = _total_mon_char;
	LET _campo1[109,128] = _transaccion;
	LET _campo1[129,136] = _fecha_char_8;	
}
--	TRACE _campo1;

 	INSERT INTO chqhacie
	VALUES(_campo1);

--	EXIT FOREACH;

END FOREACH

--DELETE FROM chqfor20;

RETURN 0, 'Actualizacion Exitosa ...';

END 

END PROCEDURE;