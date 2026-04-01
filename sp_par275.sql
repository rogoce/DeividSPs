-- Verificacion de la Variacion de Reserva

DROP PROCEDURE sp_par275;

CREATE PROCEDURE "informix".sp_par275() 
RETURNING CHAR(20),
		  CHAR(5),
		  CHAR(50),
		  DEC(16,2),
		  DEC(16,2),
		  CHAR(10);

DEFINE _no_reclamo		CHAR(10);
DEFINE _cod_cobertura	CHAR(5);
DEFINE _numrecla		CHAR(20);
DEFINE _variacion		DEC(16,2);
DEFINE _reserva			DEC(16,2);
DEFINE _nombre			CHAR(50);
DEFINE _fecha			DATE;
DEFINE _ano				SMALLINT;
DEFINE _mes				SMALLINT;

CREATE TEMP TABLE tmp_reserva(
numrecla		CHAR(20),
cod_cobertura	CHAR(5),
nombre			CHAR(50),
ano				SMALLINT,
mes				SMALLINT,
variacion		DEC(16,2),
reserva			DEC(16,2),
no_reclamo		CHAR(10)
) WITH NO LOG;

SET ISOLATION TO DIRTY READ;

FOREACH
 SELECT m.no_reclamo,
        d.cod_cobertura,
		SUM(d.variacion)
   INTO _no_reclamo,
        _cod_cobertura,
		_variacion
   FROM rectrmae m, rectrcob d
  WHERE m.no_tranrec   = d.no_tranrec
    AND m.actualizado  = 1
	and m.sac_asientos = 0
  GROUP BY m.no_reclamo, d.cod_cobertura

	IF _variacion IS NULL THEN
		LET _variacion = 0;
	END IF

	IF _variacion < 0 THEN
		LET _variacion = 0;
	END IF

	SELECT reserva_actual
	  INTO _reserva
	  FROM recrccob
	 WHERE no_reclamo    = _no_reclamo
	   AND cod_cobertura = _cod_cobertura;

	IF _reserva IS NULL THEN
		LET _reserva = 0;
	END IF

	IF _variacion <> _reserva THEN
			

	  	{
	  	UPDATE recrccob
		   SET reserva_actual = _variacion
		 WHERE no_reclamo     = _no_reclamo
		   AND cod_cobertura  = _cod_cobertura;
		--}	 


		SELECT numrecla,
		       fecha_reclamo
		  INTO _numrecla,
			   _fecha	
		  FROM recrcmae
		 WHERE no_reclamo = _no_reclamo;

		if _numrecla[1,2] = "18" then
			continue foreach;
		end if

		SELECT nombre
		  INTO _nombre
		  FROM prdcober
		 WHERE cod_cobertura = _cod_cobertura;


		INSERT INTO tmp_reserva
		VALUES(
		_numrecla,
		_cod_cobertura,
		_nombre,
		YEAR(_fecha),
		MONTH(_fecha),
		_variacion,
		_reserva,
		_no_reclamo
		);

	END IF

END FOREACH

--{
FOREACH
 SELECT m.no_reclamo,
		SUM(m.variacion)
   INTO _no_reclamo,
		_variacion
   FROM rectrmae m
  WHERE m.actualizado  = 1
    and m.numrecla[1,2]  = "18"
--	and m.sac_asientos <> 2
  GROUP BY m.no_reclamo

	IF _variacion IS NULL THEN
		LET _variacion = 0;
	END IF

	IF _variacion < 0 THEN
		LET _variacion = 0;
	END IF

	SELECT reserva_actual
	  INTO _reserva
	  FROM recrcmae
	 WHERE no_reclamo    = _no_reclamo;

	IF _reserva IS NULL THEN
		LET _reserva = 0;
	END IF

	IF _variacion <> _reserva THEN

	   {	UPDATE recrcmae
		   SET reserva_actual = _variacion
		 WHERE no_reclamo     = _no_reclamo; } 
			
		SELECT numrecla,
		       fecha_reclamo
		  INTO _numrecla,
			   _fecha	
		  FROM recrcmae
		 WHERE no_reclamo = _no_reclamo;

		INSERT INTO tmp_reserva
		VALUES(
		_numrecla,
		"",
		"",
		YEAR(_fecha),
		MONTH(_fecha),
		_variacion,
		_reserva,
		_no_reclamo
		);

	END IF

END FOREACH
--}

FOREACH
 SELECT numrecla,
		cod_cobertura,
		nombre,
		variacion,
		reserva,
		ano,
		mes,
		no_reclamo
   INTO	_numrecla,
		_cod_cobertura,
		_nombre,
		_variacion,
		_reserva,
		_ano,
		_mes,
		_no_reclamo
   FROM tmp_reserva
  ORDER BY ano DESC, mes DESC, numrecla[1,2], numrecla

		RETURN _numrecla,
		       _cod_cobertura,
			   _nombre,
			   _variacion,
			   _reserva,
			   _no_reclamo
			   WITH RESUME;

END FOREACH

RETURN "0",
       "0",
	   "",
	   0,
	   0,
	   "0"
	   WITH RESUME;

DROP TABLE tmp_reserva;

END PROCEDURE;
