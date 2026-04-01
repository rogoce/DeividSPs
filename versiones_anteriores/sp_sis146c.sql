-- Funcion que Obtiene los Codigos de un String y los
-- Inserta en una tabla temporal (tmp_codigos)
-- Creado    : 17/08/2000 - Autor: Demetrio Hurtado Almanza 
-- Modificado: 17/08/2000 - Autor: Demetrio Hurtado Almanza
--
-- SIS v.2.0 - - DEIVID, S.A.

DROP PROCEDURE sp_sis146c;

CREATE PROCEDURE "informix".sp_sis146c(a_string CHAR(8000)) 
RETURNING CHAR(1);

DEFINE _codigo           VARCHAR(50);      
DEFINE _contador         INTEGER;    
DEFINE _char_1           CHAR(1);      
DEFINE _tipo             CHAR(1);
DEFINE _llave            VARCHAR(50);

CREATE TEMP TABLE tmp_cod_mt(
		codigo VARCHAR(50) NOT NULL,
		monto  DEC(16,2)   DEFAULT 0,
		PRIMARY KEY (codigo)
		) WITH NO LOG;

--SET DEBUG FILE TO "sp_sis146.trc"; 
--trace on;
--let a_string = 
LET _codigo   = "";
FOR _contador = 1 TO 8000

	LET _char_1   = a_string[1, 1];
	LET a_string  = a_string[2, 8000];

	IF _char_1 = ";" OR _char_1 = "*" THEN

		INSERT INTO tmp_cod_mt(
			codigo
			)
			VALUES(
			_codigo
			);

		LET _char_1   = a_string[1, 1];

		EXIT FOR;

	ELSE
		IF _char_1 = "+" THEN
			INSERT INTO tmp_cod_mt(
				codigo
				)
				VALUES(
				_codigo
				);
			LET _llave = _codigo;
			LET _codigo = "";
		ELIF _char_1 = "&" THEN
		    UPDATE tmp_cod_mt SET monto = _codigo WHERE codigo = _llave;
			LET _codigo = "";
		ELSE
			LET _codigo = TRIM(_codigo) || TRIM(_char_1);
		END IF

	END IF

END FOR

RETURN _char_1;

END PROCEDURE;

