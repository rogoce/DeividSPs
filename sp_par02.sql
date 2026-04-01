-- Verificacion de la Variacion de Reserva

DROP PROCEDURE sp_par02;

CREATE PROCEDURE sp_par02() 
RETURNING CHAR(20),
		  CHAR(5),
		  CHAR(50),
		  DEC(16,2),
		  DEC(16,2),
		  CHAR(10),
		  smallint;

DEFINE _no_reclamo		CHAR(10);
DEFINE _no_tranrec		CHAR(10);
DEFINE _cod_cobertura	CHAR(5);
DEFINE _numrecla		CHAR(20);
DEFINE _monto			DEC(16,2);
DEFINE _variacion		DEC(16,2);
DEFINE _reserva			DEC(16,2);
DEFINE _nombre			CHAR(50);
DEFINE _fecha			DATE;
DEFINE _ano				SMALLINT;
DEFINE _mes				SMALLINT;
DEFINE _tipo			SMALLINT;
DEFINE _cantidad		SMALLINT;

define _periodo			char(7);

define _error			integer;
define _error_isam		integer;
define _error_desc		char(50);

{select par_periodo_act
  into _periodo
  from parparam;}
  
select periodo_verifica
  into _periodo
  from emirepar;  

CREATE TEMP TABLE tmp_reserva(
numrecla		CHAR(20),
cod_cobertura	CHAR(5),
nombre			CHAR(50),
ano				SMALLINT,
mes				SMALLINT,
variacion		DEC(16,2),
reserva			DEC(16,2),
no_reclamo		CHAR(10),
tipo			smallint
) WITH NO LOG;

SET ISOLATION TO DIRTY READ;

begin 
on exception set _error, _error_isam, _error_desc

	DROP TABLE tmp_reserva;

	RETURN _error,
		   _error_isam,
		   _error_desc,
		   0,
		   0,
		   "0",
		   999;

end exception

--{
FOREACH
 SELECT no_tranrec,
		variacion,
		no_reclamo,
		monto
   INTO _no_tranrec,
		_variacion,
		_no_reclamo,
		_monto
   FROM rectrmae
  WHERE actualizado = 1
    and periodo     = _periodo
--    and periodo[1,4] >= _periodo[1,4]

	select sum(variacion)
	  into _reserva
	  from rectrcob
	 where no_tranrec = _no_tranrec;

	IF _reserva IS NULL THEN
		LET _reserva = 0;
	END IF

	IF _variacion <> _reserva THEN

		select count(*)
		  into _cantidad
		  from rectrcob
		 where no_tranrec = _no_tranrec;

		if _cantidad = 0 then

			select count(*)
			  into _cantidad
			  from recrccob
			 WHERE no_reclamo = _no_reclamo;

			if _cantidad = 1 then

				select cod_cobertura
				  into _cod_cobertura
				  from recrccob
				 WHERE no_reclamo = _no_reclamo;

				insert into rectrcob (no_tranrec, cod_cobertura, monto, variacion)
				values (_no_tranrec, _cod_cobertura, _monto, _variacion);

			else

			   foreach	
				select cod_cobertura
				  into _cod_cobertura
				  from recrccob
				 WHERE no_reclamo = _no_reclamo
					exit foreach;
				end foreach

				insert into rectrcob (no_tranrec, cod_cobertura, monto, variacion)
				values (_no_tranrec, _cod_cobertura, _monto, _variacion);

			end if

		else

			update rectrmae
			   set variacion  = _reserva
			 where no_tranrec = _no_tranrec;

		end if
		
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
		_no_tranrec,
		1
		);

	END IF

END FOREACH
--}

FOREACH
 SELECT m.no_reclamo,
        d.cod_cobertura,
		SUM(d.variacion)
   INTO _no_reclamo,
        _cod_cobertura,
		_variacion
   FROM rectrmae m, rectrcob d
  WHERE m.no_tranrec  = d.no_tranrec
    AND m.actualizado = 1
  --and m.periodo     = _periodo
	and m.no_reclamo  in (select distinct no_reclamo from rectrmae where periodo = _periodo and actualizado = 1)--= "134320"
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

		insert into recrccob(
		no_reclamo,
		cod_cobertura,	
		estimado,	
		deducible,	
		reserva_inicial,	
		reserva_actual,	
		pagos,	
		salvamento,	
		recupero,	
		deducible_pagado,	
		deducible_devuel,	
		subir_bo
		)
		values(
		_no_reclamo,
		_cod_cobertura,
		0,
		0,
		0,
		0,
		0,
		0,
		0,
		0,
		0,
		1
		);
		
		LET _reserva = 0;

	END IF

	IF _variacion <> _reserva THEN
			
--{

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
		_no_reclamo,
		2
		);

	END IF

END FOREACH

--{
FOREACH
 SELECT m.no_reclamo,
		SUM(m.variacion)
   INTO _no_reclamo,
		_variacion
   FROM rectrmae m, recrcmae a
  WHERE m.no_reclamo = a.no_reclamo
    and m.actualizado = 1
    and a.numrecla[1,2] = "18"
	and m.no_reclamo in (select distinct no_reclamo from rectrmae where periodo = _periodo and actualizado = 1)
--	and a.numrecla <> '18-1015-14839-01'
--    and m.periodo[1,4] >= _periodo[1,4]
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

	   	UPDATE recrcmae
		   SET reserva_actual = _variacion
		 WHERE no_reclamo     = _no_reclamo; 
			
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
		_no_reclamo,
		99
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
		no_reclamo,
		tipo
   INTO	_numrecla,
		_cod_cobertura,
		_nombre,
		_variacion,
		_reserva,
		_ano,
		_mes,
		_no_reclamo,
		_tipo
   FROM tmp_reserva
  ORDER BY tipo, ano DESC, mes DESC, numrecla[1,2], numrecla

		RETURN _numrecla,
		       _cod_cobertura,
			   _nombre,
			   _variacion,
			   _reserva,
			   _no_reclamo,
			   _tipo
			   WITH RESUME;

END FOREACH

end

DROP TABLE tmp_reserva;

RETURN "0",
       "0",
	   "",
	   0,
	   0,
	   "0",
	   999;

END PROCEDURE;
