
DROP PROCEDURE sp_sis22;
CREATE PROCEDURE sp_sis22(a_no_tarjeta CHAR(19)) RETURNING SMALLINT;


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

if a_no_tarjeta in('4187-9480-4936-2699','4187-9480-0898-9995','4366-1892-9849-7380','4187-9480-2948-9959','4513-9370-1359-8847','4187-9480-4646-9976','4789-8696-1580-4587','5535-2888-3998-3420','4819-1525-0709-1944','4187-9480-9396-9720','4118-4407-4898-9760','4924-8947-4194-4957','4941-4816-0799-2993','5455-0483-3220-7065','4641-2501-2201-0604','4118-4407-4897-8847','4551-3250-0168-6732',
				   '4548-5694-3509-8996','4557-3350-3108-1099','4999-4801-8109-3948','4271-7837-0699-9997','4548-5694-3509-9630','4076-9357-8939-9449',
                   '4548-5694-3508-9870','4941-4809-4824-5970','4941-4813-6783-9798','4999-4901-9107-3939','5291-4985-9288-4970','4789-8696-1605-4349',
				   '4941-4816-0746-4845','4076-9631-8899-1939','4147-0979-3567-4970','4147-0978-1847-6998','4417-7832-9778-9380','4076-9618-9976-9198','4147-0979-8897-0986','4187-9480-4737-8648') then
	return 0;
end if
if a_no_tarjeta in('0000-0000-0000-0000') then
	return 1;
end if
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
END PROCEDURE


                                                                                                                           
