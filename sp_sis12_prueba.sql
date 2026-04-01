-- Procedimiento que Genera el Numero Externo de la Transaccion de Reclamos
-- 
-- Creado    : 16/10/2000 - Autor: Demetrio Hurtado Almanza 
-- Modificado: 16/10/2000 - Autor: Demetrio Hurtado Almanza
--
-- SIS v.2.0 - DEIVID, S.A.

--DROP PROCEDURE sp_sis12_pru;		

CREATE PROCEDURE "informix".sp_sis12_pru(
a_sucursal   CHAR(3), 
_no_tran_int INTEGER)
RETURNING CHAR(10);


DEFINE _no_tran_char  CHAR(10);
DEFINE _cod_sucur_int INTEGER;

BEGIN

-- Armar el numero de la transaccion
-- de reclamos

LET _no_tran_char  = '00-0000000';
LET _cod_sucur_int = a_sucursal;

-- Sucursal

IF _cod_sucur_int > 9 THEN
	LET _no_tran_char[1,2] = _cod_sucur_int;
ELSE
	LET _no_tran_char[2,2] = _cod_sucur_int;
END IF

-- Numero de Transaccion

IF _no_tran_int > 9999  THEN
	LET _no_tran_char[4,10] = _no_tran_int;
ELIF _no_tran_int > 999 THEN
	LET _no_tran_char[5,10] = _no_tran_int;
ELIF _no_tran_int > 99  THEN
	LET _no_tran_char[6,10] = _no_tran_int;
ELIF _no_tran_int > 9   THEN
	LET _no_tran_char[7,10] = _no_tran_int;
ELSE
	LET _no_tran_char[8,10] = _no_tran_int;
END IF

RETURN _no_tran_char;

END

END PROCEDURE;
