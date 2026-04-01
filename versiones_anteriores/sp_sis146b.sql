-- Funcion que Obtiene los Codigos de un String y los
-- Inserta en una tabla temporal (tmp_codigos)
-- Creado    : 17/08/2000 - Autor: Demetrio Hurtado Almanza 
-- Modificado: 17/08/2000 - Autor: Demetrio Hurtado Almanza
--
-- SIS v.2.0 - - DEIVID, S.A.

DROP PROCEDURE sp_sis146b;

CREATE PROCEDURE "informix".sp_sis146b(a_string1 CHAR(1255),a_string2 CHAR(1255)) 
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
define _codigo_2           char(25);      
define _char_1_2           char(1);
define _tipo_2             char(1);
define _contador_2         integer;    

drop table if exists tmp_codigos;

create temp table tmp_codigos(
codigo	char(25)  not null,
primary key (codigo)) with no log;

let _codigo   = "";
for _contador = 1 to 1255

	let _char_1   = a_string1[1, 1];
	let a_string  = a_string1[2, 1255];

	if _char_1 = ";" then

		insert into tmp_codigos(codigo)
		values(_codigo);

		let _char_1   = a_string1[1, 1];
		exit for;
	else
		if _char_1 = "," then
			insert into tmp_codigos(codigo)
			values(_codigo);

			let _codigo = "";
		else
			let _codigo = trim(_codigo) || trim(_char_1);
		end if
	end if
end for

LET _codigo2   = "";
FOR _contador2 = 1 TO 1255

	LET _char_1_2   = a_string2[1, 1];
	LET a_string2  = a_string2[2, 1255];

		IF _char_1_2 = "+" THEN
			INSERT INTO tmp_cod_mt(
				codigo
				)
				VALUES(
				_codigo
				);
			LET _llave_2 = _codigo_2;
			LET _codigo_2 = "";
		ELIF _char_1_2 = "&" THEN
		    UPDATE tmp_cod_mt SET monto = _codigo_2 WHERE codigo = _llave_2;
			LET _codigo_2 = "";
		ELSE
			LET _codigo_2 = TRIM(_codigo_2) || TRIM(_char_1_2);
		END IF


END FOR

RETURN _char_1;

END PROCEDURE;

