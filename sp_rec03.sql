-- Informe de Reclamos
-- en un Periodo Dado
-- 
-- Creado    : 08/08/2000 - Autor: Demetrio Hurtado Almanza 
-- Modificado: 15/09/2000 - Autor: Demetrio Hurtado Almanza
-- Modificado: 01/03/2002 - Autor: Armando Moreno M. (Sacar la sucursal de la poliza y no de reclamos)
-- Modificado: 21/06/2002 - Autor: Amado Perez M. (Agregando el filtro de Agentes)
--
-- SIS v.2.0 - - DEIVID, S.A.

DROP PROCEDURE sp_rec03;

CREATE PROCEDURE "informix".sp_rec03(
a_compania	CHAR(3), 
a_periodo1	CHAR(7), 
a_periodo2	CHAR(7),
a_sucursal	CHAR(255) DEFAULT "*",
a_grupo     CHAR(255) DEFAULT "*",
a_ramo      CHAR(255) DEFAULT "*",
a_ajustador CHAR(255) DEFAULT "*",
a_agente    CHAR(255) DEFAULT "*",
a_origen    CHAR(3) DEFAULT "%",
a_evento    CHAR(255) DEFAULT "*"
) RETURNING CHAR(255);

DEFINE v_filtros        CHAR(255);
DEFINE _tipo            CHAR(1);

DEFINE v_numrecla        CHAR(18);
DEFINE v_no_poliza       CHAR(20);
DEFINE v_asegurado       CHAR(100);
DEFINE v_fecha_siniestro DATE;     
DEFINE v_fecha_reclamo   DATE; 
DEFINE v_fecha_documento DATE;    
DEFINE v_ramo_nombre     CHAR(50);
DEFINE v_compania_nombre CHAR(50);

DEFINE _ajust_interno    CHAR(3);
DEFINE t_no_reclamo      CHAR(10);
DEFINE t_cod_sucursal    CHAR(3);  
DEFINE t_cod_ramo        CHAR(3);  
DEFINE t_cod_grupo       CHAR(5);  
DEFINE t_periodo         CHAR(7);  

DEFINE _no_poliza        CHAR(10);
DEFINE _cod_cliente      CHAR(10);
DEFINE _cod_agente       CHAR(5);
DEFINE _cod_subramo      CHAR(3);
DEFINE _cod_origen       char(3);
DEFINE _cod_evento       CHAR(3);


-- Tabla Temporal 

CREATE TEMP TABLE tmp_sinis(
		no_reclamo           CHAR(10)  NOT NULL,
		numrecla             CHAR(18)  NOT NULL,
		no_poliza            CHAR(20)  NOT NULL,
		asegurado            CHAR(100) NOT NULL,
		fecha_siniestro      DATE      NOT NULL,
		fecha_reclamo        DATE      NOT NULL,
		fecha_documento      DATE      NOT NULL,
		cod_ramo             CHAR(3)   NOT NULL,
		cod_subramo          CHAR(3)   NOT NULL,
		periodo              CHAR(7)   NOT NULL,
		cod_grupo            CHAR(5)   NOT NULL,
		cod_sucursal         CHAR(3)   NOT NULL,
		ajust_interno        CHAR(3)   NOT NULL,
		seleccionado         SMALLINT  DEFAULT 1 NOT NULL,
		cod_evento           CHAR(3)   NOT NULL,
		PRIMARY KEY (no_reclamo)
		) WITH NO LOG;

CREATE TEMP TABLE tmp_agente(
        no_reclamo            CHAR(10)  NOT NULL,
	    cod_agente            CHAR(5)   NOT NULL,
	    seleccionado		  SMALLINT  DEFAULT 1 NOT NULL
	    ) WITH NO LOG;

CREATE INDEX xie01_tmp_sinis ON tmp_sinis(cod_sucursal);
CREATE INDEX xie02_tmp_sinis ON tmp_sinis(cod_grupo);
CREATE INDEX xie03_tmp_sinis ON tmp_sinis(cod_ramo);
CREATE INDEX xie04_tmp_sinis ON tmp_sinis(ajust_interno);

SET ISOLATION TO DIRTY READ;

-- Nombre de la Compania

LET  v_compania_nombre = sp_sis01(a_compania);

FOREACH
 SELECT no_reclamo,
		numrecla,
		no_poliza,
		fecha_siniestro,
		fecha_reclamo,
		fecha_documento,
		periodo,
		ajust_interno,
		cod_evento
   INTO t_no_reclamo,
		v_numrecla,
		_no_poliza,
		v_fecha_siniestro,
		v_fecha_reclamo,
		v_fecha_documento,
		t_periodo,
		_ajust_interno,
		_cod_evento
   FROM recrcmae 
  WHERE cod_compania = a_compania
    AND periodo      >= a_periodo1 
    AND periodo      <= a_periodo2 
	AND actualizado  = 1

	-- Informacion de Polizas

	SELECT no_documento,	
		   cod_ramo,		
		   cod_contratante,
		   cod_grupo,
		   cod_sucursal,
		   cod_subramo,
		   cod_origen
	  INTO v_no_poliza,		
	       t_cod_ramo,		
	       _cod_cliente,
		   t_cod_grupo,
		   t_cod_sucursal,
		   _cod_subramo,
		   _cod_origen
	  FROM emipomae
	 WHERE no_poliza = _no_poliza;
	 
	IF a_origen <> "%" THEN
		IF _cod_origen <> a_origen THEN
			CONTINUE FOREACH;
		END IF
	END IF

	-- Informacion del Cliente

	SELECT nombre
	  INTO v_asegurado
	  FROM cliclien 
	 WHERE cod_cliente = _cod_cliente;

	-- Actualizacion del Movimiento

	INSERT INTO tmp_sinis(
	no_reclamo,      
	numrecla,        
	no_poliza,       
	asegurado,       
	fecha_siniestro, 
	fecha_reclamo,  
	fecha_documento, 
	cod_ramo,        
	periodo,
	cod_grupo,
	cod_sucursal,
	ajust_interno,
	cod_subramo,
	cod_evento
	)
	VALUES(
	t_no_reclamo,      
	v_numrecla,        
	v_no_poliza,       
	v_asegurado,       
	v_fecha_siniestro, 
	v_fecha_reclamo, 
	v_fecha_documento,  
	t_cod_ramo,        
	t_periodo,
	t_cod_grupo,
	t_cod_sucursal,
	_ajust_interno,
	_cod_subramo,
	_cod_evento
	);

    BEGIN
		FOREACH
			SELECT cod_agente
			  INTO _cod_agente
			  FROM emipoagt
			 WHERE no_poliza = _no_poliza

			INSERT INTO tmp_agente(
			no_reclamo,   
			cod_agente,   
			seleccionado 
			)
			VALUES(
			t_no_reclamo,      
			_cod_agente, 
			1       
			);
		END FOREACH
	END

END FOREACH

-- Procesos para Filtros

LET v_filtros = "";

IF a_sucursal <> "*" THEN

	LET v_filtros = TRIM(v_filtros) || " Sucursal: " ||  TRIM(a_sucursal);

	LET _tipo = sp_sis04(a_sucursal);  -- Separa los Valores del String en una tabla de codigos

	IF _tipo <> "E" THEN -- Incluir los Registros

		UPDATE tmp_sinis
		   SET seleccionado = 0
		 WHERE seleccionado = 1
		   AND cod_sucursal NOT IN (SELECT codigo FROM tmp_codigos);

	ELSE		        -- Excluir estos Registros

		UPDATE tmp_sinis
		   SET seleccionado = 0
		 WHERE seleccionado = 1
		   AND cod_sucursal IN (SELECT codigo FROM tmp_codigos);

	END IF

	DROP TABLE tmp_codigos;

END IF

IF a_grupo <> "*" THEN

	LET v_filtros = TRIM(v_filtros) || " Grupo: " ||  TRIM(a_grupo);

	LET _tipo = sp_sis04(a_grupo);  -- Separa los Valores del String en una tabla de codigos

	IF _tipo <> "E" THEN -- Incluir los Registros

		UPDATE tmp_sinis
		   SET seleccionado = 0
		 WHERE seleccionado = 1
		   AND cod_grupo NOT IN (SELECT codigo FROM tmp_codigos);

	ELSE		        -- Excluir estos Registros

		UPDATE tmp_sinis
		   SET seleccionado = 0
		 WHERE seleccionado = 1
		   AND cod_grupo IN (SELECT codigo FROM tmp_codigos);

	END IF

	DROP TABLE tmp_codigos;

END IF

IF a_ramo <> "*" THEN

	LET v_filtros = TRIM(v_filtros) || " Ramo: " ||  TRIM(a_ramo);

	LET _tipo = sp_sis04(a_ramo);  -- Separa los Valores del String en una tabla de codigos

	IF _tipo <> "E" THEN -- (I) Incluir los Registros

		UPDATE tmp_sinis
		   SET seleccionado = 0
		 WHERE seleccionado = 1
		   AND cod_ramo NOT IN (SELECT codigo FROM tmp_codigos);

	ELSE		        -- (E) Excluir estos Registros

		UPDATE tmp_sinis
		   SET seleccionado = 0
		 WHERE seleccionado = 1
		   AND cod_ramo IN (SELECT codigo FROM tmp_codigos);

	END IF

	DROP TABLE tmp_codigos;

END IF

IF a_ajustador <> "*" THEN

	LET v_filtros = TRIM(v_filtros) || " Ajustador: " ||  TRIM(a_ajustador);

	LET _tipo = sp_sis04(a_ajustador);  -- Separa los Valores del String en una tabla de codigos

	IF _tipo <> "E" THEN -- Incluir los Registros

		UPDATE tmp_sinis
		   SET seleccionado = 0
		 WHERE seleccionado = 1
		   AND ajust_interno NOT IN (SELECT codigo FROM tmp_codigos);

	ELSE		        -- Excluir estos Registros

		UPDATE tmp_sinis
		   SET seleccionado = 0
		 WHERE seleccionado = 1
		   AND ajust_interno IN (SELECT codigo FROM tmp_codigos);

	END IF

	DROP TABLE tmp_codigos;

END IF

IF a_agente <> "*" THEN

	LET v_filtros = TRIM(v_filtros) || " Agente: " ||  TRIM(a_agente);

	LET _tipo = sp_sis04(a_agente);  -- Separa los Valores del String en una tabla de codigos

	IF _tipo <> "E" THEN -- Incluir los Registros

		UPDATE tmp_agente
		   SET seleccionado = 0
		 WHERE seleccionado = 1
		   AND cod_agente NOT IN (SELECT codigo FROM tmp_codigos);

		UPDATE tmp_sinis
		   SET seleccionado = 0
		 WHERE seleccionado = 1
		   AND no_reclamo IN (SELECT no_reclamo FROM tmp_agente WHERE seleccionado = 0);

	ELSE		        -- Excluir estos Registros

		UPDATE tmp_agente
		   SET seleccionado = 0
		 WHERE seleccionado = 1
		   AND cod_agente IN (SELECT codigo FROM tmp_codigos);

		UPDATE tmp_sinis
		   SET seleccionado = 0
		 WHERE seleccionado = 1
		   AND no_reclamo IN (SELECT no_reclamo FROM tmp_agente WHERE seleccionado = 0);

	END IF

	DROP TABLE tmp_codigos;

END IF

IF a_evento <> "*" THEN

	LET v_filtros = TRIM(v_filtros) || " Evento: " ||  TRIM(a_evento);

	LET _tipo = sp_sis04(a_evento);  -- Separa los Valores del String en una tabla de codigos

	IF _tipo <> "E" THEN -- Incluir los Registros

		UPDATE tmp_sinis
		   SET seleccionado = 0
		 WHERE seleccionado = 1
		   AND cod_evento NOT IN (SELECT codigo FROM tmp_codigos);

	ELSE		        -- Excluir estos Registros

		UPDATE tmp_sinis
		   SET seleccionado = 0
		 WHERE seleccionado = 1
		   AND cod_evento IN (SELECT codigo FROM tmp_codigos);

	END IF

	DROP TABLE tmp_codigos;

END IF

DROP TABLE tmp_agente;
RETURN v_filtros;
END PROCEDURE;
