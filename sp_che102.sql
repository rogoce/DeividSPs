-- Reporte de las Exclusiones Fidelidad / Rentabilidad

-- Creado    : 09/07/2009 - Autor: Demetrio Hurtado Almanza
-- Modificado: 09/07/2009 - Autor: Demetrio Hurtado Almanza

-- SIS v.2.0 - d_cheq_sp_che102_dw1 - DEIVID, S.A.

--DROP PROCEDURE sp_che102;

CREATE PROCEDURE sp_che102(a_compania CHAR(3), a_cod_agente CHAR(255) default '*', a_periodo char(7), a_exclusion char(1))
  RETURNING CHAR(20),	-- Poliza
			CHAR(200),	-- Agentes
			CHAR(100),	-- Descripción
			CHAR(50);   -- Nombre Compania

DEFINE v_no_poliza    CHAR(20);
DEFINE v_nombre_agt   CHAR(200);
DEFINE v_nombre_cia   CHAR(50);
DEFINE v_descripcion  CHAR(100);
DEFINE _exclusion	  smallint;
DEFINE _no_poliza	  CHAR(10);
DEFINE _nombre_ag	  CHAR(200);
DEFINE _nombre_ag_acum CHAR(200);
DEFINE _verifica_agt  smallint;
DEFINE _tipo          CHAR(1);

-- Nombre de la Compania
SET ISOLATION TO DIRTY READ;

LET  v_nombre_cia = sp_sis01(a_compania);

SET ISOLATION TO DIRTY READ;

if a_exclusion = "F" then --Fidelidad
	let _exclusion = 1;
end if

if a_exclusion = "R" then --Rentabilidad
	let _exclusion = 2;
end if

LET _no_poliza = "";

if a_cod_agente = "*" then --Todos los Agentes

	FOREACH
	   SELECT bonibita.poliza,
			 bonibita.descripcion
		INTO v_no_poliza,
			 v_descripcion
		FROM bonibita
	   WHERE ( bonibita.periodo = a_periodo) AND
			 ( bonibita.tipo = _exclusion )

		LET _no_poliza = sp_sis21(v_no_poliza);

		--AGENTES DE LA POLIZA
		LET _nombre_ag = "";
		LET _nombre_ag_acum = "";

		FOREACH
			  SELECT TRIM(agtagent.nombre)
				INTO _nombre_ag
				FROM agtagent,
					emipoagt
				WHERE ( emipoagt.cod_agente = agtagent.cod_agente ) and
					  ( emipoagt.no_poliza = _no_poliza )

			LET _nombre_ag_acum = trim(_nombre_ag_acum) || " " || trim(_nombre_ag) ;
		END FOREACH

		RETURN  v_no_poliza,
					_nombre_ag_acum,
					v_descripcion,
					v_nombre_cia
				WITH RESUME;
	END FOREACH

else

	LET _tipo = sp_sis04(a_cod_agente);  -- Separa los Valores del String en una tabla de codigos

	IF _tipo <> "E" THEN -- Incluir los Registros

		FOREACH

			SELECT bonibita.poliza,
				 bonibita.descripcion
			INTO v_no_poliza,
				 v_descripcion
			FROM bonibita
		   WHERE ( bonibita.periodo = a_periodo) AND
				 ( bonibita.tipo = _exclusion )

			LET _no_poliza = sp_sis21(v_no_poliza);
			LET _verifica_agt = 0;

		  SELECT COUNT(*)
			INTO _verifica_agt
			FROM emipoagt
			WHERE emipoagt.no_poliza = _no_poliza AND
				  emipoagt.cod_agente IN (SELECT codigo FROM tmp_codigos)  ;

			if _verifica_agt > 0 then

				--AGENTES DE LA POLIZA
				LET _nombre_ag = "";
				LET _nombre_ag_acum = "";

				FOREACH
				  SELECT TRIM(agtagent.nombre)
					INTO _nombre_ag
					FROM agtagent,
						emipoagt
					WHERE ( emipoagt.cod_agente = agtagent.cod_agente ) and
						  ( emipoagt.no_poliza = _no_poliza )

					LET _nombre_ag_acum = trim(_nombre_ag_acum) || " " || trim(_nombre_ag) ;

				END FOREACH

				RETURN  v_no_poliza,
					_nombre_ag_acum,
					v_descripcion,
					v_nombre_cia
				WITH RESUME;

			end if

		END FOREACH

	ELSE		        -- Excluir estos Registros

	  FOREACH

			SELECT bonibita.poliza,
				 bonibita.descripcion
			INTO v_no_poliza,
				 v_descripcion
			FROM bonibita
		   WHERE ( bonibita.periodo = a_periodo) AND
				 ( bonibita.tipo = _exclusion )

			LET _no_poliza = sp_sis21(v_no_poliza);
			LET _verifica_agt = 0;

		  SELECT COUNT(*)
			INTO _verifica_agt
			FROM emipoagt
			WHERE emipoagt.no_poliza = _no_poliza AND
				  emipoagt.cod_agente NOT IN (SELECT codigo FROM tmp_codigos)  ;

			if _verifica_agt > 0 then

				--AGENTES DE LA POLIZA
				LET _nombre_ag = "";
				LET _nombre_ag_acum = "";

				FOREACH
				  SELECT TRIM(agtagent.nombre)
					INTO _nombre_ag
					FROM agtagent,
						emipoagt
					WHERE ( emipoagt.cod_agente = agtagent.cod_agente ) and
						  ( emipoagt.no_poliza = _no_poliza )

					LET _nombre_ag_acum = trim(_nombre_ag_acum) || " " || trim(_nombre_ag) ;

				END FOREACH

				RETURN  v_no_poliza,
					_nombre_ag_acum,
					v_descripcion,
					v_nombre_cia
				WITH RESUME;

			end if

		END FOREACH

	END IF

	DROP TABLE tmp_codigos;

end if

END PROCEDURE;