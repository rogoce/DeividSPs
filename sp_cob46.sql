-- REPORTE DE POLIZAS SIN DIA DE COBRO-- 
--
-- Creado    : 22/02/2001 - Autor: Armando Moreno M.
-- Modificado: 22/02/2001 - Autor: Armando Moreno M.
--
-- SIS v.2.0 - DEIVID, S.A.

DROP PROCEDURE sp_cob46;

CREATE PROCEDURE "informix".sp_cob46(
a_compania CHAR(3), 
a_sucursal CHAR(3), 
a_cobrador CHAR(255) DEFAULT "*")
RETURNING	CHAR(20),	 --POLIZA
			CHAR(100),	 --ASEG
			DATE,		 --VIG INI
			DATE,		 --VIG FIN
			CHAR(50),	 --COBRADOR
			CHAR(50),	 --CIA
			CHAR(50),	 --CORRDOR
			CHAR(50),	 --FORMAPAG
			CHAR(255);   -- Filtros

DEFINE v_documento        CHAR(20);
DEFINE v_asegurado        CHAR(100);
DEFINE v_cobrador         CHAR(50);
DEFINE v_nombre_agente	  CHAR(50);
DEFINE v_nombre_cia       CHAR(50);
DEFINE _formapag          CHAR(50);
DEFINE v_filtros          CHAR(255);
DEFINE v_vigen_ini        DATE;
DEFINE v_vigen_fin        DATE;

DEFINE _tipo,_cobra_poliza CHAR(1);
DEFINE _cobra_poliza_pol   CHAR(1);
DEFINE _cod_agente       CHAR(5);
DEFINE _no_poliza        CHAR(10);
DEFINE _cod_compania	 CHAR(3);
DEFINE _cod_sucursal	 CHAR(3);
DEFINE _cod_cobrador	 CHAR(3);
DEFINE _actualizado		 INT;
DEFINE _cod_formapag     INT;
DEFINE _cod_cliente      CHAR(10);
DEFINE _tipo_forma       SMALLINT;

SET ISOLATION TO DIRTY READ;

LET  v_nombre_cia = sp_sis01(a_compania); 

--DROP TABLE tmp_arreglo;

CREATE TEMP TABLE tmp_arreglo(
		no_poliza       CHAR(10),
		cod_cobrador    CHAR(3) NOT NULL,
		cod_agente      CHAR(5) NOT NULL,
		actualizado	    INT,
		incluir_carta   INT,
		vigen_ini       DATE,
		vigen_fin       DATE,
		no_documento    CHAR(20),
		cod_cliente     CHAR(10),
		formapag        CHAR(50),
		seleccionado   	SMALLINT  DEFAULT 1 NOT NULL
		) WITH NO LOG;   

--CREATE INDEX xie01_tmp_arreglo ON tmp_arreglo(cod_cobrador);
-- Lectura de Polizas	
{	SELECT u.cod_agente,
		   u.cod_cobrador,
	       v.no_poliza,
		   x.cod_compania,
		   x.cod_sucursal,
		   x.actualizado,
		   x.cod_formapag,
		   x.no_documento,
		   x.cod_contratante,
		   x.vigencia_inic,
		   x.vigencia_final	
	  INTO _cod_agente,
		   _cod_cobrador,
	       _no_poliza,
		   _cod_compania,
		   _cod_sucursal,
		   _actualizado,
		   _cod_formapag,
		   v_documento,
		   _cod_cliente,
		   v_vigen_ini,
		   v_vigen_fin	
	  FROM agtagent u, emipoagt v, emipomae x
	 WHERE x.cod_compania = a_compania
	   AND x.cod_sucursal = a_sucursal
	   AND x.saldo        > 0
	   AND (u.cobra_poliza = 'E'
	   OR  (u.cobra_poliza = 'A'
	   AND x.cobra_poliza = 'E'))  
	   AND v.cod_agente = u.cod_agente
	   AND x.no_poliza = v.no_poliza
	   AND x.actualizado = 1
	   AND x.estatus_poliza = 1
	   AND (x.dia_cobros1 = 0
	   OR  x.dia_cobros2 = 0)}

FOREACH
	SELECT x.actualizado,
		   x.cod_formapag,
		   x.no_documento,
		   x.cod_contratante,
		   x.no_poliza,
		   x.vigencia_inic,
		   x.vigencia_final,
		   x.cobra_poliza	
	  INTO _actualizado,
		   _cod_formapag,
		   v_documento,
		   _cod_cliente,
		   _no_poliza,
		   v_vigen_ini,
		   v_vigen_fin,	
		   _cobra_poliza_pol
	  FROM emipomae x
	 WHERE x.cod_compania   = a_compania
	   AND x.cod_sucursal   = a_sucursal
	   AND x.saldo          > 0
	   AND x.actualizado    = 1
	   AND x.estatus_poliza = 1
	   AND (x.dia_cobros1   = 0
	   OR   x.dia_cobros2   = 0)

	SELECT tipo_forma,
		   nombre
	  INTO _tipo_forma,
		   _formapag
	  FROM cobforpa
	 WHERE cod_formapag = _cod_formapag;

	IF _tipo_forma = 2 OR 
	   _tipo_forma = 4 THEN	
		CONTINUE FOREACH;
	END IF

   FOREACH	
	SELECT cod_agente
	  INTO _cod_agente
	  FROM emipoagt
	 WHERE no_poliza = _no_poliza
	 EXIT FOREACH;
   END FOREACH

   SELECT cobra_poliza,
   		  cod_cobrador
     INTO _cobra_poliza,
     	  _cod_cobrador
     FROM agtagent
    WHERE cod_agente = _cod_agente;

	IF _cobra_poliza = "C" THEN	
		CONTINUE FOREACH;
	END IF

	IF _cobra_poliza = "A" THEN	
		IF _cobra_poliza_pol = "C" OR 
		   _cobra_poliza_pol = "A" THEN
			CONTINUE FOREACH;
		END IF
	END IF

	INSERT INTO tmp_arreglo(
	no_poliza,
	cod_cobrador,	   	
	cod_agente,      
	actualizado,
	vigen_ini,
	vigen_fin,
	no_documento,
	cod_cliente,
	formapag,
	seleccionado	
	)
	VALUES(
	_no_poliza,
	_cod_cobrador,
	_cod_agente,	 
	_actualizado,
	v_vigen_ini,
	v_vigen_fin,
	v_documento,
	_cod_cliente,
	_formapag,
	1	
    );
END FOREACH;

LET v_filtros = "";

IF a_cobrador <> "*" THEN
	LET v_filtros = TRIM(v_filtros) || " Cobrador: " ||  TRIM(a_cobrador);

	LET _tipo = sp_sis04(a_cobrador);  -- Separa los Valores del String en una tabla de codigos

	IF _tipo <> "E" THEN -- Incluir los Registros

		UPDATE tmp_arreglo
		   SET seleccionado = 0
		 WHERE seleccionado = 1
		   AND cod_cobrador NOT IN (SELECT codigo FROM tmp_codigos);
	ELSE		        -- Excluir estos Registros

		UPDATE tmp_arreglo
		   SET seleccionado = 0
		 WHERE seleccionado = 1
		   AND cod_cobrador IN (SELECT codigo FROM tmp_codigos);
	END IF

	DROP TABLE tmp_codigos;
END IF

FOREACH
 SELECT no_poliza,
        cod_cobrador,
        cod_agente,  
	    actualizado,
	    vigen_ini,
	    vigen_fin,
	    no_documento,
	    cod_cliente,
	    formapag
   INTO _no_poliza,
        _cod_cobrador,
	    _cod_agente,	
	    _actualizado,
	    v_vigen_ini,
	    v_vigen_fin,
	    v_documento,
	    _cod_cliente,
	    _formapag
   FROM tmp_arreglo
  WHERE seleccionado = 1
		
		--Lectura de Asegurado
		SELECT nombre
		  INTO v_asegurado
		  FROM cliclien
		 WHERE cod_cliente = _cod_cliente;

		--Lectura de Cobrador
		SELECT nombre
		  INTO v_cobrador
		  FROM cobcobra
		 WHERE cod_cobrador = _cod_cobrador;

		--Lectura de Corredor
		LET v_nombre_agente = "";
		FOREACH
			SELECT nombre
			  INTO v_nombre_agente
			  FROM agtagent
			 WHERE cod_agente = _cod_agente
			EXIT FOREACH;
		END FOREACH

		RETURN v_documento, 
			   v_asegurado, 
			   v_vigen_ini, 
			   v_vigen_fin, 
			   v_cobrador,
			   v_nombre_cia,
			   v_nombre_agente,
			   _formapag,
			   v_filtros
			   WITH RESUME;
END FOREACH;

DROP TABLE tmp_arreglo;

END PROCEDURE

