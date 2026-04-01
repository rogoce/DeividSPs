-- Procedimiento para la conversion de fecha a fecha en letra
--
-- Creado    : 30/01/2000 - Autor: Edgar E. Cano G.
-- Modificado: 30/01/2000 - Autor: Edgar E. Cano G.
--
-- SIS v.2.0 - DEIVID, S.A.

--DROP PROCEDURE sp_sis20;
CREATE PROCEDURE "informix".sp_sis20(a_fecha DATE)
	RETURNING CHAR(60)	  --  ls_fecha_letra

DEFINE ls_fecha_letra		CHAR(60);
DEFINE v_dia				CHAR(2);
DEFINE v_ano				CHAR(4);

BEGIN
   IF MONTH(a_fecha) = 1 THEN
      LET ls_fecha_letra = 'enero';
   ELIF MONTH(a_fecha) = 2 THEN
      LET ls_fecha_letra = 'febrero';
   ELIF MONTH(a_fecha) = 3 THEN
      LET ls_fecha_letra = 'marzo';
   ELIF MONTH(a_fecha) = 4 THEN
      LET ls_fecha_letra = 'abril';
   ELIF MONTH(a_fecha) = 5 THEN
      LET ls_fecha_letra = 'mayo';
   ELIF MONTH(a_fecha) = 6 THEN
      LET ls_fecha_letra = 'junio';
   ELIF MONTH(a_fecha) = 7 THEN
      LET ls_fecha_letra = 'julio';
   ELIF MONTH(a_fecha) = 8 THEN
      LET ls_fecha_letra = 'agosto';
   ELIF MONTH(a_fecha) = 9 THEN
      LET ls_fecha_letra = 'septiembre';
   ELIF MONTH(a_fecha) = 10 THEN
      LET ls_fecha_letra = 'octubre';
   ELIF MONTH(a_fecha) = 11 THEN
      LET ls_fecha_letra = 'noviembre';
   ELIF MONTH(a_fecha) = 12 THEN
      LET ls_fecha_letra = 'diciembre';
   END IF

   LET v_dia = DAY(a_fecha);
   LET v_ano = YEAR(a_fecha);
   LET ls_fecha_letra = TRIM(v_dia)||' de '||TRIM(ls_fecha_letra)||' de '||TRIM(v_ano);

   RETURN ls_fecha_letra;
END
END PROCEDURE