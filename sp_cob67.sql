-- Procedimiento que extrae las Polizas con Cero
-- 
-- Creado    : 20/04/2001 - Autor: Armando Moreno
-- Modificado: 20/04/2001 - Autor: Armando Moreno
--
-- SIS v.2.0 - DEIVID, S.A.

DROP PROCEDURE sp_cob67;

CREATE PROCEDURE "informix".sp_cob67(a_corredor CHAR(5)
) RETURNING	CHAR(20),
			CHAR(100),
			DATE,
			DATE,
		    CHAR(1),
			CHAR(10),
			SMALLINT,
			SMALLINT;

DEFINE v_documento        CHAR(20);
DEFINE v_asegurado        CHAR(100);
DEFINE v_vigen_ini        DATE;
DEFINE v_vigen_fin        DATE;
DEFINE v_cobra_poliza     DEC(16,2);
DEFINE _cod_agente        CHAR(5);
DEFINE _no_poliza         CHAR(10);
DEFINE _actualizado		  INT;
DEFINE _cod_cliente       CHAR(10);
DEFINE _cobra_poliza_pol  CHAR(1);
DEFINE _dia1,_dia2        SMALLINT;

CREATE TEMP TABLE tmp_arreglo(
		no_documento	CHAR(20)
		) WITH NO LOG;
FOREACH
 -- Lectura de Emipoagt(Corredores)

	SELECT no_poliza
	  INTO _no_poliza
	  FROM emipoagt
	 WHERE cod_agente = a_corredor

 -- Lectura de Polizas	

	SELECT x.no_documento
	  INTO v_documento
	  FROM emipomae x
	 WHERE x.actualizado = 1
	   AND x.no_poliza = _no_poliza
	   AND (x.estatus_poliza <> 2
	   OR   x.estatus_poliza <> 4);

			INSERT INTO tmp_arreglo(
			no_documento
			)
			VALUES(
			v_documento
		    );
END FOREACH;

FOREACH WITH HOLD
      SELECT no_documento
	    INTO v_documento
        FROM tmp_arreglo
		GROUP BY no_documento
	    ORDER BY no_documento

		LET _no_poliza = sp_sis21(v_documento);
		IF _no_poliza IS NULL THEN
			CONTINUE FOREACH;
		END IF
	--Lectura de Asegurado

	SELECT x.cod_contratante,
		   x.vigencia_inic,
		   x.vigencia_final,
		   x.cobra_poliza,
		   x.dia_cobros1,
		   x.dia_cobros2
	  INTO _cod_cliente,
		   v_vigen_ini,
		   v_vigen_fin,
		   _cobra_poliza_pol,
		   _dia1,
		   _dia2
	  FROM emipomae x
	 WHERE x.actualizado = 1
	   AND x.no_poliza = _no_poliza
--	   AND x.cobra_poliza = "A"
	   AND (x.estatus_poliza <> 2
	   OR   x.estatus_poliza <> 4);

		IF _cod_cliente IS NULL THEN
			CONTINUE FOREACH;
		END IF

	SELECT nombre
	  INTO v_asegurado
	  FROM cliclien
	 WHERE cod_cliente = _cod_cliente;

	RETURN v_documento, 
		   v_asegurado, 
		   v_vigen_ini, 
		   v_vigen_fin, 
		   _cobra_poliza_pol,
		   _no_poliza,
		   _dia1,
		   _dia2
		   WITH RESUME;

END FOREACH;
DROP TABLE tmp_arreglo;
END PROCEDURE