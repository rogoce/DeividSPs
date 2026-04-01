-- Verificacion de la Variacion de Reservas

DROP PROCEDURE sp_par05;

CREATE PROCEDURE "informix".sp_par05(a_compania CHAR(3), a_agencia CHAR(3), a_periodo1 CHAR(7), a_periodo2 CHAR(7)) 
RETURNING CHAR(20),
			DEC(16,2),
			DEC(16,2),
			DEC(16,2);

DEFINE v_numrecla     CHAR(20);
DEFINE v_no_reclamo   CHAR(10); 
DEFINE v_reserva_per1 DEC(16,2);
DEFINE v_reserva_per2 DEC(16,2);
DEFINE v_reserva_vari DEC(16,2);
DEFINE v_filtros      CHAR(255);

SET ISOLATION TO DIRTY READ;

CREATE TEMP TABLE tmp_variacion(
no_reclamo           CHAR(10),
reserva_per1         DEC(16,2),
reserva_per2         DEC(16,2),
reserva_vari         DEC(16,2)
) WITH NO LOG;

--  Reclamos Pendientes Periodo 1

{
CALL sp_rec02(
a_compania,
a_agencia,
a_periodo1
) RETURNING v_filtros;

FOREACH
 SELECT no_reclamo,
		reserva_total
   INTO v_no_reclamo,
        v_reserva_per1
   FROM tmp_sinis
}

FOREACH 
 SELECT no_reclamo,		
        SUM(variacion) 
   INTO v_no_reclamo,	
        v_reserva_per1
   FROM rectrmae 
  WHERE cod_compania = a_compania
    AND periodo     <= a_periodo1 
	AND actualizado  = 1
  GROUP BY no_reclamo
 HAVING SUM(variacion) > 0 

	INSERT INTO tmp_variacion
	VALUES(
	v_no_reclamo,
	v_reserva_per1,
	0,
	0);

END FOREACH

--DROP TABLE tmp_sinis;

--  Reclamos Pendientes Periodo 2
{
CALL sp_rec02(
a_compania,
a_agencia,
a_periodo2
) RETURNING v_filtros;

FOREACH
 SELECT no_reclamo,
		reserva_total
   INTO v_no_reclamo,
        v_reserva_per2
   FROM tmp_sinis
}

FOREACH 
 SELECT no_reclamo,		
        SUM(variacion) 
   INTO v_no_reclamo,	
        v_reserva_per2
   FROM rectrmae 
  WHERE cod_compania = a_compania
    AND periodo     <= a_periodo2 
	AND actualizado  = 1
  GROUP BY no_reclamo
 HAVING SUM(variacion) > 0 

	INSERT INTO tmp_variacion
	VALUES(
	v_no_reclamo,
	0,
	v_reserva_per2,
	0);

END FOREACH

--DROP TABLE tmp_sinis;

-- Incurrido Neto en el Mes

CALL sp_rec01(
a_compania,
a_agencia,
a_periodo2,
a_periodo2
) RETURNING v_filtros;

FOREACH
 SELECT no_reclamo,
		reserva_total
   INTO v_no_reclamo,
        v_reserva_vari
   FROM tmp_sinis

	INSERT INTO tmp_variacion
	VALUES(
	v_no_reclamo,
	0,
	0,
	v_reserva_vari
	);

END FOREACH

DROP TABLE tmp_sinis;

-- Verificacion de Reservas

FOREACH
 SELECT no_reclamo,
		SUM(reserva_per1),
		SUM(reserva_per2),
		SUM(reserva_vari)  
   INTO v_no_reclamo,
        v_reserva_per1,
		v_reserva_per2,
		v_reserva_vari
   FROM tmp_variacion
  GROUP BY no_reclamo

	IF (v_reserva_per2 - v_reserva_per1) <> v_reserva_vari THEN

		SELECT numrecla
		  INTO v_numrecla
		  FROM recrcmae
		 WHERE no_reclamo = v_no_reclamo;

		RETURN v_numrecla,
			   v_reserva_per1,
			   v_reserva_per2,
			   v_reserva_vari
			   WITH RESUME;
			   	
	END IF

END FOREACH

DROP TABLE tmp_variacion;

END PROCEDURE;
