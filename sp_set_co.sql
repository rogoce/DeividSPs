DROP PROCEDURE sp_set_codigo;

CREATE PROCEDURE sp_set_codigo(a_tamano INTEGER, a_codigo INTEGER)
RETURNING CHAR(10);

DEFINE _valor CHAR(10);

IF a_codigo IS NULL THEN
	LET _valor = NULL;
	RETURN _valor;
END IF

IF a_tamano > 4 THEN
	LET _valor = '00000';
	
	IF a_codigo > 9999 THEN
		LET _valor = a_codigo;
	ELIF a_codigo > 999 THEN
		LET _valor[2,5] = a_codigo;
	ELIF a_codigo > 99 THEN
		LET _valor[3,5] = a_codigo;
	ELIF a_codigo > 9 THEN
		LET _valor[4,5] = a_codigo;
	ELSE
		LET _valor[5,5] = a_codigo;
	END IF

ELIF a_tamano > 3 THEN

	LET _valor = '0000';
	
	IF a_codigo > 999 THEN
		LET _valor = a_codigo;
	ELIF a_codigo > 99 THEN
		LET _valor[2,4] = a_codigo;
	ELIF a_codigo > 9 THEN
		LET _valor[3,4] = a_codigo;
	ELSE
		LET _valor[4,4] = a_codigo;
	END IF

ELIF a_tamano > 2 THEN

	LET _valor = '000';
	
	IF a_codigo > 99 THEN
		LET _valor = a_codigo;
	ELIF a_codigo > 9 THEN
		LET _valor[2,3] = a_codigo;
	ELSE
		LET _valor[3,3] = a_codigo;
	END IF

ELIF a_tamano > 1 THEN

	LET _valor = '00';
	
	IF a_codigo > 9 THEN
		LET _valor = a_codigo;
	ELSE
		LET _valor[2,2] = a_codigo;
	END IF

ELSE

	LET _valor = a_codigo;

END IF

RETURN _valor;

END PROCEDURE;