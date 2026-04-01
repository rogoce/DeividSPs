-- Verificador del Numero de Tarjeta de Credito

-- Creado    : 05/03/2001 - Autor: Demetrio Hurtado Almanza 
-- Modificado: 05/03/2001 - Autor: Demetrio Hurtado Almanza

-- SIS v.2.0 - DEIVID, S.A.

--{
DROP PROCEDURE sp_sis22_prueba;

CREATE PROCEDURE "informix".sp_sis22_prueba(a_no_tarjeta CHAR(19)) RETURNING SMALLINT;
--}

{
DROP PROCEDURE sp_sis22;

CREATE PROCEDURE "informix".sp_sis22(a_no_tarjeta CHAR(19)) RETURNING SMALLINT;
--}

DEFINE _dv  INTEGER;
DEFINE _ch2 CHAR(2);
DEFINE _acu INTEGER;
DEFINE _ch3 CHAR(3);

DEFINE _c01 INTEGER;
DEFINE _c02 INTEGER;
DEFINE _c03 INTEGER;
DEFINE _c04 INTEGER;
DEFINE _c05 INTEGER;
DEFINE _c06 INTEGER;
DEFINE _c07 INTEGER;
DEFINE _c08 INTEGER;
DEFINE _c09 INTEGER;
DEFINE _c10 INTEGER;
DEFINE _c11 INTEGER;
DEFINE _c12 INTEGER;
DEFINE _c13 INTEGER;
DEFINE _c14 INTEGER;
DEFINE _c15 INTEGER;
 
--SET DEBUG FILE TO "sp_sis22.trc"; 
--TRACE ON;                                                                

LET _dv  = a_no_tarjeta[19];

IF a_no_tarjeta[1]  NOT BETWEEN "0" AND "9" THEN
	RETURN 1;
END IF
IF a_no_tarjeta[2]  NOT BETWEEN "0" AND "9" THEN
	RETURN 1;
END IF
IF a_no_tarjeta[3]  NOT BETWEEN "0" AND "9" THEN
	RETURN 1;
END IF
IF a_no_tarjeta[4]  NOT BETWEEN "0" AND "9" THEN
	RETURN 1;
END IF
IF a_no_tarjeta[5]  <> "-" THEN
	RETURN 1;
END IF
IF a_no_tarjeta[6]  NOT BETWEEN "0" AND "9" THEN
	RETURN 1;
END IF
IF a_no_tarjeta[7]  NOT BETWEEN "0" AND "9" THEN
	RETURN 1;
END IF
IF a_no_tarjeta[8]  NOT BETWEEN "0" AND "9" THEN
	RETURN 1;
END IF
IF a_no_tarjeta[9]  NOT BETWEEN "0" AND "9" THEN
	RETURN 1;
END IF
IF a_no_tarjeta[10]  <> "-" THEN
	RETURN 1;
END IF
IF a_no_tarjeta[11] NOT BETWEEN "0" AND "9" THEN
	RETURN 1;
END IF
IF a_no_tarjeta[12] NOT BETWEEN "0" AND "9" THEN
	RETURN 1;
END IF
IF a_no_tarjeta[13] NOT BETWEEN "0" AND "9" THEN
	RETURN 1;
END IF
IF a_no_tarjeta[14] NOT BETWEEN "0" AND "9" THEN
	RETURN 1;
END IF
IF a_no_tarjeta[15]  <> "-" THEN
	RETURN 1;
END IF
IF a_no_tarjeta[16] NOT BETWEEN "0" AND "9" THEN
	RETURN 1;
END IF
IF a_no_tarjeta[17] NOT BETWEEN "0" AND "9" THEN
	RETURN 1;
END IF
IF a_no_tarjeta[18] NOT BETWEEN "0" AND "9" THEN
	RETURN 1;
END IF

--TRACE ON;

LET _c01 = a_no_tarjeta[1] * 2;
LET _c02 = a_no_tarjeta[2];
LET _c03 = a_no_tarjeta[3] * 2;
LET _c04 = a_no_tarjeta[4];
LET _c05 = a_no_tarjeta[6] * 2;
LET _c06 = a_no_tarjeta[7];
LET _c07 = a_no_tarjeta[8] * 2;
LET _c08 = a_no_tarjeta[9];
LET _c09 = a_no_tarjeta[11] * 2;
LET _c10 = a_no_tarjeta[12];
LET _c11 = a_no_tarjeta[13] * 2;
LET _c12 = a_no_tarjeta[14];
LET _c13 = a_no_tarjeta[16] * 2;
LET _c14 = a_no_tarjeta[17];
LET _c15 = a_no_tarjeta[18] * 2;

LET _acu = 0;

LET _ch2  = _c01;
IF _ch2 > 9 THEN
	LET _acu = _acu + _ch2[1] + _ch2[2];  
ELSE
	LET _acu = _acu + _ch2[1];  
END IF

LET _ch2  = _c02;
IF _ch2 > 9 THEN
	LET _acu = _acu + _ch2[1] + _ch2[2];  
ELSE
	LET _acu = _acu + _ch2[1];  
END IF

LET _ch2  = _c03;
IF _ch2 > 9 THEN
	LET _acu = _acu + _ch2[1] + _ch2[2];  
ELSE
	LET _acu = _acu + _ch2[1];  
END IF

LET _ch2  = _c04;
IF _ch2 > 9 THEN
	LET _acu = _acu + _ch2[1] + _ch2[2];  
ELSE
	LET _acu = _acu + _ch2[1];  
END IF

LET _ch2  = _c05;
IF _ch2 > 9 THEN
	LET _acu = _acu + _ch2[1] + _ch2[2];  
ELSE
	LET _acu = _acu + _ch2[1];  
END IF

LET _ch2  = _c06;
IF _ch2 > 9 THEN
	LET _acu = _acu + _ch2[1] + _ch2[2];  
ELSE
	LET _acu = _acu + _ch2[1];  
END IF

LET _ch2  = _c07;
IF _ch2 > 9 THEN
	LET _acu = _acu + _ch2[1] + _ch2[2];  
ELSE
	LET _acu = _acu + _ch2[1];  
END IF

LET _ch2  = _c08;
IF _ch2 > 9 THEN
	LET _acu = _acu + _ch2[1] + _ch2[2];  
ELSE
	LET _acu = _acu + _ch2[1];  
END IF

LET _ch2  = _c09;
IF _ch2 > 9 THEN
	LET _acu = _acu + _ch2[1] + _ch2[2];  
ELSE
	LET _acu = _acu + _ch2[1];  
END IF

LET _ch2  = _c10;
IF _ch2 > 9 THEN
	LET _acu = _acu + _ch2[1] + _ch2[2];  
ELSE
	LET _acu = _acu + _ch2[1];  
END IF

LET _ch2  = _c11;
IF _ch2 > 9 THEN
	LET _acu = _acu + _ch2[1] + _ch2[2];  
ELSE
	LET _acu = _acu + _ch2[1];  
END IF

LET _ch2  = _c12;
IF _ch2 > 9 THEN
	LET _acu = _acu + _ch2[1] + _ch2[2];  
ELSE
	LET _acu = _acu + _ch2[1];  
END IF

LET _ch2  = _c13;
IF _ch2 > 9 THEN
	LET _acu = _acu + _ch2[1] + _ch2[2];  
ELSE
	LET _acu = _acu + _ch2[1];  
END IF

LET _ch2  = _c14;
IF _ch2 > 9 THEN
	LET _acu = _acu + _ch2[1] + _ch2[2];  
ELSE
	LET _acu = _acu + _ch2[1];  
END IF

LET _ch2  = _c15;
IF _ch2 > 9 THEN
	LET _acu = _acu + _ch2[1] + _ch2[2];  
ELSE
	LET _acu = _acu + _ch2[1];  
END IF

LET _ch3 = _acu + 10;

IF _acu > 99 THEN
	LET _ch3 = _ch3[1,2] || "0";
ELSE
	LET _ch3 = _ch3[1] || "0";
END IF

LET _c01 = _ch3 - _acu;	

IF _c01 = 10 THEN
	LET _c01 = _c01 - 10;
END IF
	 
IF _c01 = _dv THEN
	RETURN 0;
ELSE
	RETURN 1;
END IF
END PROCEDURE;
