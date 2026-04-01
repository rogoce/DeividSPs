-- Consulta de Clientes Global

-- Creado    : 14/06/2001 - Autor: Armando Moreno M.
-- Modificado: 14/06/2001 - Autor: Armando Moreno M.

-- SIS v.2.0 - d_prod_sp_prd67_dw1 - DEIVID, S.A.

DROP PROCEDURE sp_pro67;

CREATE PROCEDURE sp_pro67(a_cod_cliente CHAR(10))
RETURNING CHAR(20),	 -- POLIZA
		  CHAR(5),	 -- UNIDAD
		  DATE,      -- VIG INI
		  DATE,      -- VIG FIN
		  DEC(16,2), -- PRIMA NETA
		  DEC(16,2), -- IMPUESTO
		  DEC(16,2), -- PRIMA BRUTA
		  DEC(16,2), -- SALDO
		  SMALLINT,	 -- ESTATUS POLIZA
		  CHAR(50),	 -- NOMBRE CORREDOR
		  CHAR(50),	 -- NOMBRE RAMO
		  CHAR(100), -- NOMBRE CTE
		  CHAR(15);	 -- TIPO CLIENTE

DEFINE v_cod_cliente  		CHAR(10);  
DEFINE v_nombre_corredor	CHAR(50); 
DEFINE v_documento   		CHAR(20);
DEFINE v_vig_ini			DATE;
DEFINE v_vig_fin			DATE;
DEFINE v_prima_neta			DEC(16,2);
DEFINE v_prima_bruta		DEC(16,2);
DEFINE v_impuesto			DEC(16,2);
DEFINE v_saldo				DEC(16,2);
DEFINE v_estatus_pol	    SMALLINT;
DEFINE v_actualizado	    SMALLINT;
DEFINE v_no_poliza	 	    CHAR(10);
DEFINE v_no_unidad	 	    CHAR(5);
DEFINE v_cod_agente	 	    CHAR(5);
DEFINE v_nombre_ramo		CHAR(50);
DEFINE v_cod_ramo			CHAR(3);
DEFINE v_nombre_cte			CHAR(100);
DEFINE v_tipo_cliente       CHAR(15);
DEFINE v_cant_unidad, v_cant_pol_1, v_cant_pol_2 INT;  

--SET DEBUG FILE TO "sp_pro67.trc";-- Nombre de la Compania
--TRACE ON;

SET ISOLATION TO DIRTY READ;

CREATE TEMP TABLE tmp_poliza(
		no_poliza       CHAR(10)	NOT NULL,
		no_unidad       CHAR(5),
		doc_poliza      CHAR(20),
		estatus         CHAR(1)     NOT NULL,
		vigencia_inic   DATE,
		vigencia_final  DATE,
		prima_neta      DEC(16,2)	DEFAULT 0 NOT NULL,
		impuesto        DEC(16,2)	DEFAULT 0 NOT NULL,
		prima_bruta     DEC(16,2)   DEFAULT 0 NOT NULL,
		saldo           DEC(16,2)	DEFAULT 0 NOT NULL,
		cod_ramo        CHAR(3),
		tipo_cliente    CHAR(15),
		PRIMARY KEY (no_poliza)
		) WITH NO LOG;


--SACAR INFORMACION DE LA POLIZA

 SELECT	nombre
		INTO
		v_nombre_cte
   FROM	cliclien
  WHERE cod_cliente = a_cod_cliente;

-- INICIALIZO VARIABLE EN NULO *AMADO 18/06/2002*
LET v_no_poliza = NULL;
LET v_cant_unidad = 0;
LET v_cant_pol_1 = 0;
LET v_cant_pol_2 = 0;

SELECT COUNT(*) 
  INTO v_cant_unidad
  FROM emipouni 
 WHERE cod_asegurado = a_cod_cliente;

SELECT COUNT(*) 
  INTO v_cant_pol_1
  FROM emipomae 
 WHERE cod_contratante = a_cod_cliente
   AND actualizado = 1;

SELECT COUNT(*) 
  INTO v_cant_pol_2
  FROM emipomae 
 WHERE cod_pagador = a_cod_cliente
   AND actualizado = 1;

IF v_cant_unidad > 0 THEN
	FOREACH
		 SELECT	prima_neta,
				prima_bruta,
				impuesto,
				no_unidad,
				no_poliza
				INTO
		 		v_prima_neta,
				v_prima_bruta,
				v_impuesto,
				v_no_unidad,
				v_no_poliza
		   FROM	emipouni
		  WHERE cod_asegurado = a_cod_cliente

		 SELECT	no_documento,
		 		vigencia_inic,
				vigencia_final,
				saldo,
				estatus_poliza,
				actualizado,
				cod_ramo
				INTO
				v_documento,
		   		v_vig_ini,
				v_vig_fin,
				v_saldo,
				v_estatus_pol,
				v_actualizado,
				v_cod_ramo
		   FROM	emipomae
		  WHERE no_poliza = v_no_poliza;

			  IF v_actualizado IS NULL THEN
				LET v_actualizado = 0;
			  END IF

			  IF v_actualizado <> 1 THEN
				CONTINUE FOREACH;
			  END IF

	    BEGIN
			  ON EXCEPTION IN(-239)
			  END EXCEPTION

			  INSERT INTO tmp_poliza
			  VALUES(v_no_poliza,
			         v_no_unidad,
			         v_documento,
			         v_estatus_pol,
			         v_vig_ini,
			         v_vig_fin,
			         v_prima_neta,
			         v_impuesto,
			         v_prima_bruta,
			         v_saldo,
			         v_cod_ramo,
			         'ASEGURADO');
	    END
	END FOREACH
END IF


IF v_cant_pol_1 > 0 THEN
	FOREACH
		 SELECT	no_documento,
		 		vigencia_inic,
				vigencia_final,
				saldo,
				estatus_poliza,
				actualizado,
				cod_ramo,
				prima_neta,
				prima_bruta,
				impuesto,
				no_poliza
				INTO
				v_documento,
		   		v_vig_ini,
				v_vig_fin,
				v_saldo,
				v_estatus_pol,
				v_actualizado,
				v_cod_ramo,
				v_prima_neta,
				v_prima_bruta,
				v_impuesto,
				v_no_poliza
		   FROM	emipomae
          WHERE cod_contratante = a_cod_cliente

			  IF v_actualizado IS NULL THEN
				LET v_actualizado = 0;
			  END IF

			  IF v_actualizado <> 1 THEN
				CONTINUE FOREACH;
			  END IF

	    BEGIN
			  ON EXCEPTION IN(-239)
			  END EXCEPTION

			  INSERT INTO tmp_poliza
			  VALUES(v_no_poliza,
			         NULL,
			         v_documento,
			         v_estatus_pol,
			         v_vig_ini,
			         v_vig_fin,
			         v_prima_neta,
			         v_impuesto,
			         v_prima_bruta,
			         v_saldo,
			         v_cod_ramo,
			         'ASEGURADO');
	    END
	END FOREACH
END IF

IF v_cant_pol_2 > 0 THEN
	FOREACH
		 SELECT	no_documento,
		 		vigencia_inic,
				vigencia_final,
				saldo,
				estatus_poliza,
				actualizado,
				cod_ramo,
				prima_neta,
				prima_bruta,
				impuesto,
				no_poliza
				INTO
				v_documento,
		   		v_vig_ini,
				v_vig_fin,
				v_saldo,
				v_estatus_pol,
				v_actualizado,
				v_cod_ramo,
				v_prima_neta,
				v_prima_bruta,
				v_impuesto,
				v_no_poliza
		   FROM	emipomae
          WHERE cod_pagador = a_cod_cliente

			  IF v_actualizado IS NULL THEN
				LET v_actualizado = 0;
			  END IF

			  IF v_actualizado <> 1 THEN
				CONTINUE FOREACH;
			  END IF

	    BEGIN
			  ON EXCEPTION IN(-239)
			  END EXCEPTION

			  INSERT INTO tmp_poliza
			  VALUES(v_no_poliza,
			         NULL,
			         v_documento,
			         v_estatus_pol,
			         v_vig_ini,
			         v_vig_fin,
			         v_prima_neta,
			         v_impuesto,
			         v_prima_bruta,
			         v_saldo,
			         v_cod_ramo,
			         'CONTRATANTE');
	    END
	END FOREACH
END IF

FOREACH WITH HOLD
	SELECT no_poliza,     
		   no_unidad,     
		   doc_poliza,    
		   estatus,       
		   vigencia_inic, 
		   vigencia_final,
		   prima_neta,    
		   impuesto,      
		   prima_bruta,   
		   saldo,         
		   cod_ramo,
		   tipo_cliente
	  INTO v_no_poliza,
	  	   v_no_unidad,
	  	   v_documento,
	  	   v_estatus_pol,
	  	   v_vig_ini,
	  	   v_vig_fin,
	  	   v_prima_neta,
	  	   v_impuesto,
	  	   v_prima_bruta,
	  	   v_saldo,
	  	   v_cod_ramo,
		   v_tipo_cliente
	  FROM tmp_poliza

	FOREACH
		 SELECT	cod_agente
				INTO
				v_cod_agente
		   FROM	emipoagt
		  WHERE no_poliza = v_no_poliza
		  EXIT FOREACH;
	END FOREACH

		 SELECT	nombre
				INTO
				v_nombre_corredor
		   FROM	agtagent
		  WHERE cod_agente = v_cod_agente;

		 SELECT	nombre
				INTO
				v_nombre_ramo
		   FROM	prdramo
		  WHERE cod_ramo = v_cod_ramo;

	RETURN  v_documento,
			v_no_unidad,		 
			v_vig_ini,
			v_vig_fin,     
			v_prima_neta, 
			v_impuesto,
			v_prima_bruta,
			v_saldo,
			v_estatus_pol,
			v_nombre_corredor,
			v_nombre_ramo,
			v_nombre_cte,
			v_tipo_cliente
			WITH RESUME;
END FOREACH

DROP TABLE tmp_poliza;

END PROCEDURE;
