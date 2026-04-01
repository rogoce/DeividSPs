-- Procedimiento que retorna el nombre del mes
--
-- Creado    : 29/09/2004 - Autor: Demetrio Hurtado A.
--
-- SIS v.2.0 - DEIVID, S.A.

--DROP PROCEDURE sp_sac18;

CREATE PROCEDURE "informix".sp_sac18(a_mes smallint)
RETURNING CHAR(10);

DEFINE _nombre	CHAR(10);

IF a_mes = 1 THEN
  LET _nombre = 'ENERO';
ELIF a_mes = 2 THEN
  LET _nombre = 'FEBRERO';
ELIF a_mes = 3 THEN
  LET _nombre = 'MARZO';
ELIF a_mes = 4 THEN
  LET _nombre = 'ABRIL';
ELIF a_mes = 5 THEN
  LET _nombre = 'MAYO';
ELIF a_mes = 6 THEN
  LET _nombre = 'JUNIO';
ELIF a_mes = 7 THEN
  LET _nombre = 'JULIO';
ELIF a_mes = 8 THEN
  LET _nombre = 'AGOSTO';
ELIF a_mes = 9 THEN
  LET _nombre = 'SEPTIEMBRE';
ELIF a_mes = 10 THEN
  LET _nombre = 'OCTUBRE';
ELIF a_mes = 11 THEN
  LET _nombre = 'NOVIEMBRE';
ELIF a_mes = 12 THEN
  LET _nombre = 'DICIEMBRE';
ELSE
  LET _nombre = 'PERIODO ' || a_mes;
END IF

RETURN _nombre;

END PROCEDURE