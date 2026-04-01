-- Verificador del Numero de Tarjeta de Credito American Express

-- Creado    : 22/05/2003 - Autor: Demetrio Hurtado Almanza 
-- Modificado: 22/05/2003 - Autor: Demetrio Hurtado Almanza

-- SIS v.2.0 - DEIVID, S.A.

--DROP PROCEDURE sp_sis38;

CREATE PROCEDURE "informix".sp_sis38(a_no_tarjeta CHAR(19)) RETURNING SMALLINT;

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

LET _dv = "";

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
IF a_no_tarjeta[10] NOT BETWEEN "0" AND "9" THEN
	RETURN 1;
END IF
IF a_no_tarjeta[11] NOT BETWEEN "0" AND "9" THEN
	RETURN 1;
END IF
IF a_no_tarjeta[12]  <> "-" THEN
	RETURN 1;
END IF
IF a_no_tarjeta[13] NOT BETWEEN "0" AND "9" THEN
	RETURN 1;
END IF
IF a_no_tarjeta[14] NOT BETWEEN "0" AND "9" THEN
	RETURN 1;
END IF
IF a_no_tarjeta[15] NOT BETWEEN "0" AND "9" THEN
	RETURN 1;
END IF
IF a_no_tarjeta[16] NOT BETWEEN "0" AND "9" THEN
	RETURN 1;
END IF
IF a_no_tarjeta[17] NOT BETWEEN "0" AND "9" THEN
	RETURN 1;
END IF

RETURN 0;

END PROCEDURE;
