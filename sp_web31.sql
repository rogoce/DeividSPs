--Porcedimiento que resta meses a una fecha, evitando el error
--de la fecha esta fuera de rango.
-- Creado el 13-08-2014
drop procedure sp_web31();

CREATE PROCEDURE "informix".sp_web31()
  returning DATE;

  DEFINE _fecha, _resultado, _res  DATE;
  DEFINE _dia, _mes ,_intervalo INT;

  LET _intervalo = 6;
  LET _fecha = today;
  LET _dia = DAY(_fecha);
  LET _resultado = _fecha - (_dia - 1) UNITS DAY;

  LET _resultado = _resultado - _intervalo UNITS MONTH;
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