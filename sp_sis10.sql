-- PROCEDURE PARA OBTENER EL VALOR EN LA TABLA DE PARCONT
-- 
-- Creado    : 31/08/2000 - Autor: Edgar E. Cano
-- Modificado: 31/08/2000 - Autor: Edgar E. Cano
--
-- SIS v.2.0 - - DEIVID, S.A.

--DROP PROCEDURE sp_sis10;

CREATE PROCEDURE "informix".sp_sis10(a_compania CHAR(3), a_aplicacion CHAR(3), CHAR(255)) 
RETURNING CHAR(1);

DEFINE _codigo           CHAR(10);      
DEFINE _contador         INTEGER;      
DEFINE _char_1           CHAR(1);      
DEFINE _tipo             CHAR(1);

CREATE TEMP TABLE tmp_codigos(
		codigo CHAR(15)  NOT NULL,
		PRIMARY KEY (codigo)
		) WITH NO LOG;

LET _codigo = "";
FOR _contador = 1 TO 255

	LET _char_1   = a_string[1, 1];
	LET a_string  = a_string[2, 255];

	IF _char_1 = ";" THEN

		INSERT INTO tmp_codigos(
			codigo
			)
			VALUES(
			_codigo
			);

		LET _char_1   = a_string[1, 1];

		EXIT FOR;

	ELSE

		IF _char_1 = "," THEN

			INSERT INTO tmp_codigos(
				codigo
				)
				VALUES(
				_codigo
				);
			LET _codigo = "";
		ELSE
			LET _codigo = TRIM(_codigo) || TRIM(_char_1);
		END IF

	END IF

END FOR

RETURN _char_1;

END PROCEDURE;

