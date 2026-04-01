-- Procedimiento que Realiza la insercion a la tabla de Emision, Proceso de Evaluacion.

-- Creado    : 14/10/2011 - Autor: Armando Moreno

drop procedure sp_sis336;

create procedure "informix".sp_sis336(a_banco char(3), a_chequera char(3))
RETURNING INTEGER;

define _error            smallint;
define _cod_contratante  char(10);
define _no_cheque        integer;


--SET DEBUG FILE TO "sp_sis336.trc"; 
--trace on;

SET LOCK MODE TO WAIT;

BEGIN

ON EXCEPTION SET _error
  RETURN _error;
END EXCEPTION


SELECT cont_no_cheque
  INTO _no_cheque
  FROM chqchequ
 WHERE cod_banco    = a_banco
   AND cod_chequera = a_chequera;

let _no_cheque = _no_cheque + 1;

UPDATE chqchequ
   SET cont_no_cheque = _no_cheque
 WHERE cod_banco      = a_banco
   AND cod_chequera   = a_chequera;


END
RETURN 0;
end procedure;
