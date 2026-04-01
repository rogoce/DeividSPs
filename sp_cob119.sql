-- Consulta de Clientes Global

-- Creado    : 14/06/2001 - Autor: Armando Moreno M.
-- Modificado: 14/06/2001 - Autor: Armando Moreno M.

-- SIS v.2.0 - d_prod_sp_prd67_dw1 - DEIVID, S.A.

DROP PROCEDURE sp_cob119;

CREATE PROCEDURE sp_cob119(a_cod_cliente CHAR(10))
RETURNING CHAR(20),	 -- POLIZA
		  DATE,      -- VIG INI
		  DATE,      -- VIG FIN
		  DEC(16,2), -- SALDO
		  SMALLINT,	 -- ESTATUS POLIZA
		  CHAR(50),	 -- NOMBRE CORREDOR
		  CHAR(50),	 -- NOMBRE RAMO
		  CHAR(100), -- NOMBRE CTE
		  DEC(16,2), -- MONTO
		  CHAR(10);  -- No poliza

DEFINE v_cod_cliente  		CHAR(10);  
DEFINE v_nombre_corredor	CHAR(50); 
DEFINE v_documento   		CHAR(20);
DEFINE v_vig_ini			DATE;
DEFINE v_vig_fin			DATE;
DEFINE v_prima_neta			DEC(16,2);
DEFINE v_prima_bruta		DEC(16,2);
DEFINE v_impuesto			DEC(16,2);
DEFINE v_saldo				DEC(16,2);
DEFINE _monto				DEC(16,2);
DEFINE v_estatus_pol	    SMALLINT;
DEFINE v_actualizado	    SMALLINT;
DEFINE v_no_poliza	 	    CHAR(10);
DEFINE v_no_unidad	 	    CHAR(5);
DEFINE v_cod_agente	 	    CHAR(5);
DEFINE v_nombre_ramo		CHAR(50);
DEFINE v_cod_ramo			CHAR(3);
DEFINE v_nombre_cte			CHAR(100);

--SET DEBUG FILE TO "sp_cob119.trc";-- Nombre de la Compania
--TRACE ON;

SET ISOLATION TO DIRTY READ;

--SACAR INFORMACION DE LA POLIZA

SELECT nombre
  INTO v_nombre_cte
  FROM cliclien
 WHERE cod_cliente = a_cod_cliente;

let _monto = 0;

FOREACH

	 SELECT	no_documento
	   INTO v_documento
	   FROM	emipomae
	  WHERE cod_pagador = a_cod_cliente
		AND actualizado = 1
	  GROUP BY no_documento

	  let v_no_poliza = sp_sis21(v_documento);

	 SELECT	vigencia_inic,
			vigencia_final,
			saldo,
			estatus_poliza,
			actualizado,
			cod_ramo
	   INTO	v_vig_ini,
			v_vig_fin,
			v_saldo,
			v_estatus_pol,
			v_actualizado,
			v_cod_ramo
	   FROM	emipomae
	  WHERE no_poliza = v_no_poliza
	    and actualizado = 1;

	FOREACH
		 SELECT	cod_agente
		   INTO v_cod_agente
		   FROM	emipoagt
		  WHERE no_poliza = v_no_poliza
		  EXIT FOREACH;
	END FOREACH

	SELECT	nombre
	  INTO	v_nombre_corredor
	  FROM	agtagent
	 WHERE cod_agente = v_cod_agente;

    SELECT	nombre
	   INTO	v_nombre_ramo
	   FROM	prdramo
	  WHERE cod_ramo = v_cod_ramo;

	let v_saldo = sp_cob115b("001","001",v_documento,"");

	RETURN  v_documento,
			v_vig_ini,
			v_vig_fin,     
			v_saldo,
			v_estatus_pol,
			v_nombre_corredor,
			v_nombre_ramo,
			v_nombre_cte,
			_monto,
			v_no_poliza
			WITH RESUME;
END FOREACH

--DROP TABLE tmp_tabla;

END PROCEDURE;