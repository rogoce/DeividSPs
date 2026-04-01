-- Consulta de Clientes Global

-- Creado    : 14/06/2001 - Autor: Armando Moreno M.
-- Modificado: 14/06/2001 - Autor: Armando Moreno M.

-- SIS v.2.0 - d_prod_sp_prd67_dw1 - DEIVID, S.A.

DROP PROCEDURE sp_web21;

CREATE PROCEDURE sp_web21(a_cod_cliente CHAR(10))
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
		  CHAR(100),
		  char(15), -- NOMBRE CTE
		  smallint;

DEFINE v_cod_cliente  		CHAR(10);
DEFINE _cod_ase		  		CHAR(10);
DEFINE v_nombre_corredor	CHAR(50); 
DEFINE v_documento   		CHAR(20);
DEFINE v_vig_ini			DATE;
DEFINE v_vig_fin			DATE;
DEFINE v_prima_neta			DEC(16,2);
DEFINE v_prima_bruta		DEC(16,2);
DEFINE v_impuesto			DEC(16,2);
DEFINE v_saldo				DEC(16,2);
DEFINE v_estatus_pol	    SMALLINT;
DEFINE v_actualizado,_valor SMALLINT;
DEFINE v_no_poliza	 	    CHAR(10);
DEFINE v_no_unidad	 	    CHAR(5);
DEFINE v_cod_agente	 	    CHAR(5);
DEFINE v_nombre_ramo		CHAR(50);
DEFINE v_cod_ramo			CHAR(3);
DEFINE v_nombre_cte			CHAR(100);
define _cantidad			integer;

--SET DEBUG FILE TO "sp_pro67.trc"; 
--trace on;

SET ISOLATION TO DIRTY READ;

--SACAR INFORMACION DE LA POLIZA

 SELECT	nombre
   INTO v_nombre_cte
   FROM	cliclien
  WHERE cod_cliente = a_cod_cliente;

-- INICIALIZO VARIABLE EN NULO *AMADO 18/06/2002*
{LET v_no_poliza = NULL;

SELECT COUNT(*) 
  INTO v_cant_unidad
  FROM emipouni 
 WHERE cod_asegurado = a_cod_cliente;

SELECT COUNT(*) 
  INTO v_cant_pol
  FROM emipomae 
 WHERE cod_contratante = a_cod_cliente;}
let _valor = 0;

FOREACH
	 SELECT	emipouni.prima_neta,
			emipouni.prima_bruta,
			emipouni.impuesto,
			no_unidad,
			emipouni.no_poliza
	   INTO v_prima_neta,
			v_prima_bruta,
			v_impuesto,
			v_no_unidad,
			v_no_poliza
	   FROM	emipouni INNER JOIN emipomae on emipouni.no_poliza = emipomae.no_poliza
	  WHERE cod_asegurado = a_cod_cliente
	  and emipomae.cod_ramo in('018','004')  and estatus_poliza  = 1

	 IF v_no_poliza IS NULL	THEN	 --SI NO ENCUENTRA REGISTROS EN emipouni *AMADO 18/06/2002*
	 	SELECT no_poliza
	 	  INTO v_no_poliza
		  FROM emipomae
	 	 WHERE cod_contratante = a_cod_cliente and cod_ramo in('018','004')  and estatus_poliza  = 1;
	 END IF	     

	 SELECT	no_documento,
	 		vigencia_inic,
			vigencia_final,
			saldo,
			estatus_poliza,
			actualizado,
			cod_ramo
	   INTO	v_documento,
	   		v_vig_ini,
			v_vig_fin,
			v_saldo,
			v_estatus_pol,
			v_actualizado,
			v_cod_ramo
	   FROM	emipomae
	  WHERE no_poliza = v_no_poliza and cod_ramo in('018','004')  and estatus_poliza  = 1;

	  IF v_actualizado IS NULL THEN
		LET v_actualizado = 0;
	  END IF

	  IF v_actualizado <> 1 THEN
		CONTINUE FOREACH;
	  END IF

	FOREACH
		 SELECT	cod_agente
		   INTO	v_cod_agente
		   FROM	emipoagt
		  WHERE no_poliza = v_no_poliza
		  EXIT FOREACH;
	END FOREACH

	SELECT	nombre
	  INTO v_nombre_corredor
	  FROM	agtagent
	 WHERE cod_agente = v_cod_agente;

	SELECT	nombre
	  INTO	v_nombre_ramo
	  FROM	prdramo
	 WHERE cod_ramo = v_cod_ramo;

	 Let v_saldo = sp_cob115b("001", "001", v_documento, "");
	 let _valor  = sp_sis164(v_no_poliza); 

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
			"",
			_valor
			WITH RESUME;
END FOREACH
END PROCEDURE;