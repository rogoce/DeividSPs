-- Procedimiento para buscar si existe la placa en otro numero de motor
--
-- Creado    :18/03/2002 - Amado Perez 
--
-- SIS v.2.0 - DEIVID, S.A.

--DROP PROCEDURE sp_rec68;

CREATE PROCEDURE "informix".sp_rec68(
a_placa   CHAR(10), 
a_motor   CHAR(30))
RETURNING   INTEGER,			 -- _error
			CHAR(30)			 -- ls_motor

DEFINE li_estatus, _error				INTEGER;
DEFINE ls_motor							CHAR(10);

BEGIN

SET ISOLATION TO DIRTY READ;

--SET DEBUG FILE TO "\\NEMESIS\Ancon\Store Procedures\Debug\sp_proe23.trc";      
--TRACE ON;                                                                     

LET _error = 0;

FOREACH
   SELECT no_motor 
     INTO ls_motor 
     FROM emivehic
    WHERE placa    = a_placa

   LET _error = 0;

   IF ls_motor <> a_motor THEN
	  LET _error = 1;
	  EXIT FOREACH;
   END IF

END FOREACH

RETURN _error, ls_motor;

END

END PROCEDURE;