DROP PROCEDURE sp_sis110;

CREATE PROCEDURE "informix".sp_sis110(a_compania CHAR(3), a_aplicacion CHAR(3), a_version CHAR(2), a_cod_parametro CHAR(50)) RETURNING CHAR(10);

DEFINE _no_tranrec_int   INTEGER; 
DEFINE _no_tranrec_char  CHAR(10);

SET DEBUG FILE TO "sp_sis110.trc";
trace on;

-- Lectura del contador de Transacciones (Llave Primaria) 


SELECT valor_parametro
  INTO _no_tranrec_int
  FROM parcont
 WHERE cod_compania    = a_compania
   AND aplicacion      = a_aplicacion
   AND version         = a_version
   AND cod_parametro   = a_cod_parametro;

BEGIN WORK;


IF _no_tranrec_int IS NULL THEN

	LET _no_tranrec_int = 1;

	INSERT INTO parcont(
	cod_compania, 
	aplicacion,   
	version,      
	cod_parametro,
	valor_parametro
	)
	VALUES(
	a_compania,
	a_aplicacion,   
	a_version,      
	a_cod_parametro,
	_no_tranrec_int
	);

ELSE

	LET _no_tranrec_int    = _no_tranrec_int + 1;

	UPDATE parcont
	   SET valor_parametro = _no_tranrec_int
     WHERE cod_compania    = a_compania
	   AND aplicacion      = a_aplicacion
	   AND version         = a_version
	   AND cod_parametro   = a_cod_parametro;

END IF

COMMIT WORK;

-- Numero de Transaccion

LET _no_tranrec_char  = '00000';

IF _no_tranrec_int > 9999 THEN
	LET _no_tranrec_char = _no_tranrec_int;
ELIF _no_tranrec_int > 999 THEN
	LET _no_tranrec_char[2,5] = _no_tranrec_int;
ELIF _no_tranrec_int > 99  THEN
	LET _no_tranrec_char[3,5] = _no_tranrec_int;
ELIF _no_tranrec_int > 9  THEN
	LET _no_tranrec_char[4,5] = _no_tranrec_int;
ELSE
	LET _no_tranrec_char[5,5] = _no_tranrec_int;
END IF

RETURN _no_tranrec_char;

END PROCEDURE;
