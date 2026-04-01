-- PROCEDURE PARA ELIMINAR EL CARACTER | DE UNA CADENA
-- 
-- Creado    : 10/03/2011	Roman Gordon
--
-- SIS v.2.0 - - DEIVID, S.A.

--DROP PROCEDURE sp_sis10a;

CREATE PROCEDURE "informix".sp_sis10a(a_string CHAR(255)) 
RETURNING VARCHAR(80);

DEFINE _codigo           VARCHAR(80);      
DEFINE _contador         INTEGER;      
DEFINE _char_1	         CHAR(1);      


LET _codigo = "";
FOR _contador = 1 TO 80

	LET _char_1   = a_string[1, 1];
	LET a_string  = a_string[2, 255];

	IF _char_1 = ";" THEN
		EXIT FOR;		 
	ELSE

		IF _char_1 = "|" THEN

		ELSE
			LET _codigo = _codigo || _char_1;
		END IF

	END IF

END FOR

RETURN _codigo;

END PROCEDURE;
