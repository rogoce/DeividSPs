DROP PROCEDURE sp_rwf65;
CREATE PROCEDURE "informix".sp_rwf65()
RETURNING CHAR(10);

DEFINE _no_tranrec_int   INTEGER; 
DEFINE _no_tranrec_char  CHAR(10);

--SET DEBUG FILE TO "\\NEMESIS\Ancon\Store Procedures\Debug\sp_sis12.trc";
--trace on;

-- Lectura del contador de Transacciones (Llave Primaria) 

SELECT valor_parametro
  INTO _no_tranrec_int
  FROM parcont
 WHERE cod_compania    = "001"
   AND aplicacion      = "REC"
   AND version         = "02"
   AND cod_parametro   = "par_cotiza_piez";

IF _no_tranrec_int IS NULL THEN

	LET _no_tranrec_int = 0;

	LET _no_tranrec_int    = _no_tranrec_int + 1;

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

	INSERT INTO parcont(
	cod_compania, 
	aplicacion,   
	version,      
	cod_parametro,
	valor_parametro
	)
	VALUES(
	"001",
	"REC",   
	"02",      
	"par_cotiza_piez",
	_no_tranrec_char
	);

ELSE

	LET _no_tranrec_int    = _no_tranrec_int + 1;

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

	UPDATE parcont
	   SET valor_parametro = _no_tranrec_char
     WHERE cod_compania    = "001"
	   AND aplicacion      = "REC"
	   AND version         = "02"
	   AND cod_parametro   = "par_cotiza_piez";

END IF

RETURN _no_tranrec_char;

END PROCEDURE;
