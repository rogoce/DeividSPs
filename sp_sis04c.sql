-- Funcion que Obtiene los Codigos de un String y los
-- Inserta en una tabla temporal (tmp_codigos_zona)
-- Creado    : 17/08/2000 - Autor: Demetrio Hurtado Almanza 
-- Modificado: 17/08/2000 - Autor: Demetrio Hurtado Almanza
--
-- SIS v.2.0 - - DEIVID, S.A.

DROP PROCEDURE sp_sis04c;

CREATE PROCEDURE "informix".sp_sis04c(a_string CHAR(255)) 
RETURNING CHAR(1);

DEFINE _codigo           CHAR(25);      
DEFINE _contador         INTEGER;    
DEFINE _char_1           CHAR(1);
DEFINE _tipo             CHAR(1);

CREATE TEMP TABLE tmp_codigos_zona(
		codigo CHAR(50)  NOT NULL,
		PRIMARY KEY (codigo)
		) WITH NO LOG;

LET _codigo   = "";
FOR _contador = 1 TO 255

	LET _char_1   = a_string[1, 1];
	LET a_string  = a_string[2, 255];

	IF _char_1 = ";" THEN

		INSERT INTO tmp_codigos_zona(
			codigo
			)
			VALUES(
			_codigo
			);

		LET _char_1   = a_string[1, 1];

		EXIT FOR;

	ELSE

		IF _char_1 = "," THEN

			INSERT INTO tmp_codigos_zona(
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

