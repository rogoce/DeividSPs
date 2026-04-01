-- Procedimiento que suma meses a una fecha
-- Creado    : 22/11/2024 - Autor: Federico Coronado
--
-- SIS v.2.0 - - DEIVID, S.A.
drop procedure sp_cob9h;

CREATE PROCEDURE "informix".sp_cob9h(a_fecha date, a_intervalo smallint)
  returning DATE;

  DEFINE _resultado, _res  DATE;
  DEFINE _dia, _mes int;

  --LET _intervalo = 6;
  --LET _fecha = today;
  LET _dia = DAY(a_fecha);
  LET _resultado = a_fecha - (_dia - 1) UNITS DAY;

  LET _resultado = _resultado + a_intervalo UNITS MONTH;
  LET _mes = MONTH(_resultado + (_dia - 1) UNITS DAY);

  IF _mes <> MONTH(_resultado) THEN
    LET _resultado = _resultado + (_dia - 1) UNITS DAY;
    LET _dia = DAY(_resultado);
    LET _resultado = _resultado - _dia UNITS DAY;
  ELSE
    LET _resultado = _resultado + (_dia - 1) UNITS DAY;
  END IF

  RETURN _resultado;

END PROCEDURE