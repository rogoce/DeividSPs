-- Creado    : 14/03/2007 - Autor: Armando Moreno

DROP PROCEDURE sp_cob80b;

CREATE PROCEDURE "informix".sp_cob80b(_monto dec(16,2))
RETURNING CHAR(10);

DEFINE _monto_char  CHAR(10);
define _codigo      CHAR(10);
define _char_1      CHAR(1);
define _contador    integer;

LET _monto_char = '0000000000';

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

RETURN _codigo;

END PROCEDURE;