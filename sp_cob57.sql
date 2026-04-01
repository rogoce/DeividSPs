-- Reporte de Seguimiento de la Gestion de Cobros

-- Creado    : 04/04/2001 - Autor: Demetrio Hurtado Almanza 
-- Modificado: 04/04/2001 - Autor: Demetrio Hurtado Almanza

-- SIS v.2.0 - DEIVID, S.A.

DROP PROCEDURE sp_cob57;

CREATE PROCEDURE "informix".sp_cob57(
a_compania     CHAR(3), 
a_sucursal     CHAR(3), 
a_fecha_inicio DATE,    
a_fecha_final  DATE,    
a_cod_cobrador CHAR(255) DEFAULT '*',
a_tipo_aviso   CHAR(255) DEFAULT '*' 
) RETURNING DATE,
			CHAR(20),
			CHAR(250),
			CHAR(8),
			DATE,
            CHAR(50),
			SMALLINT,
            CHAR(50),
            CHAR(255),
            CHAR(10),
            CHAR(30);

DEFINE v_filtros         CHAR(255);
DEFINE _tipo             CHAR(1);

DEFINE _no_documento     CHAR(20);
DEFINE _desc_gestion     CHAR(250);
DEFINE _user_added       CHAR(8);
DEFINE _fecha_aviso		 DATE;
DEFINE _tipo_aviso       SMALLINT;
DEFINE _fecha_gestion    DATE;

DEFINE _no_poliza		 CHAR(10);
DEFINE _cod_agente		 CHAR(5);
DEFINE _cod_cobrador     CHAR(3);
DEFINE _nombre           CHAR(50);	
DEFINE v_compania_nombre CHAR(50); 

DEFINE v_telefono		 CHAR(10);
DEFINE v_no_tarjeta		 CHAR(30);

DEFINE _cod_cliente		 CHAR(10);

SET ISOLATION TO DIRTY READ;

-- Nombre de la Compania

LET _cod_cliente = '';
LET v_compania_nombre = sp_sis01(a_compania); 

--DROP TABLE tmp_gestion;

CREATE TEMP TABLE tmp_gestion(
fecha_aviso   DATE,     
no_documento  CHAR(20), 
desc_gestion  CHAR(250),
user_added    CHAR(8),  
fecha_gestion DATE,    
cod_cobrador  CHAR(50), 
tipo_aviso    CHAR(2),
seleccionado  SMALLINT,
no_poliza     CHAR(10)   
) WITH NO LOG;

FOREACH 
 SELECT no_documento,
		desc_gestion,
		user_added,
		fecha_aviso,
		tipo_aviso,
		fecha_gestion,
		no_poliza
   INTO	_no_documento,
		_desc_gestion,
		_user_added,
		_fecha_aviso,
		_tipo_aviso,
		_fecha_gestion,
		_no_poliza
   FROM cobgesti
  WHERE fecha_aviso >= a_fecha_inicio
    AND fecha_aviso <= a_fecha_final
	AND tipo_aviso  <> 0

	FOREACH
	 SELECT cod_agente
	   INTO _cod_agente
	   FROM emipoagt
	  WHERE no_poliza = _no_poliza
	  	EXIT FOREACH;
	 END FOREACH
	 
	SELECT cod_cobrador
	  INTO _cod_cobrador
	  FROM agtagent
	 WHERE cod_agente = _cod_agente;  	

	INSERT INTO tmp_gestion
	VALUES(
	_fecha_aviso,
	_no_documento,
	_desc_gestion,
	_user_added,
	_fecha_gestion,
	_cod_cobrador,
	_tipo_aviso,
	1,
	_no_poliza
	);

END FOREACH

-- Filtros

LET v_filtros = "";

IF a_cod_cobrador <> "*" THEN

	LET v_filtros = TRIM(v_filtros) || " Cobrador: " ||  TRIM(a_cod_cobrador);

	LET _tipo = sp_sis04(a_cod_cobrador);  -- Separa los Valores del String en una tabla de codigos

	IF _tipo <> "E" THEN -- (I) Incluir los Registros

		UPDATE tmp_gestion
		   SET seleccionado = 0
		 WHERE seleccionado = 1
		   AND cod_cobrador NOT IN (SELECT codigo FROM tmp_codigos);

	ELSE		        -- (E) Excluir estos Registros

		UPDATE tmp_gestion
		   SET seleccionado = 0
		 WHERE seleccionado = 1
		   AND cod_cobrador IN (SELECT codigo FROM tmp_codigos);

	END IF

	DROP TABLE tmp_codigos;

END IF

IF a_tipo_aviso <> "*" THEN

	LET v_filtros = TRIM(v_filtros) || " Tipo Aviso: " ||  TRIM(a_tipo_aviso);

	LET _tipo = sp_sis04(a_tipo_aviso);  -- Separa los Valores del String en una tabla de codigos

	IF _tipo <> "E" THEN -- (I) Incluir los Registros

		UPDATE tmp_gestion
		   SET seleccionado = 0
		 WHERE seleccionado = 1
		   AND tipo_aviso NOT IN (SELECT codigo FROM tmp_codigos);

	ELSE		        -- (E) Excluir estos Registros

		UPDATE tmp_gestion
		   SET seleccionado = 0
		 WHERE seleccionado = 1
		   AND a_tipo_aviso IN (SELECT codigo FROM tmp_codigos);

	END IF

	DROP TABLE tmp_codigos;

END IF

FOREACH 
 SELECT no_documento,
		desc_gestion,
		user_added,
		fecha_aviso,
		tipo_aviso,
		fecha_gestion,
		cod_cobrador,
		no_poliza
   INTO	_no_documento,
		_desc_gestion,
		_user_added,
		_fecha_aviso,
		_tipo_aviso,
		_fecha_gestion,
		_cod_cobrador,
		_no_poliza
   FROM tmp_gestion
  WHERE seleccionado = 1

	SELECT nombre
	  INTO _nombre
	  FROM cobcobra
	 WHERE cod_cobrador = _cod_cobrador;  

	SELECT cod_contratante
	  INTO _cod_cliente
	  FROM emipomae
	 WHERE no_poliza = _no_poliza;

	SELECT telefono1
	  INTO v_telefono
	  FROM emidirco
	 WHERE no_poliza = _no_poliza;

	IF v_telefono IS NULL THEN

		SELECT telefono1
		  INTO v_telefono
		  FROM cliclien
		 WHERE cod_cliente = _cod_cliente;

		IF v_telefono IS NULL THEN
			LET v_telefono = '';
		END IF

	END IF

	LET v_no_tarjeta = '';

	IF _tipo_aviso = 3 THEN -- Cargos Visa

		LET v_no_tarjeta = NULL;

		FOREACH
		 SELECT no_tarjeta
		   INTO v_no_tarjeta
		   FROM cobtacre
		  WHERE no_documento = _no_documento
			EXIT FOREACH;
		END FOREACH

		IF v_no_tarjeta IS NULL THEN
			LET v_no_tarjeta = '';
		END IF

	END IF

	IF _tipo_aviso = 5 THEN -- Cargos ACH

		SELECT cedula 
		  INTO v_no_tarjeta
		  FROM cliclien
		 WHERE cod_cliente = _cod_cliente;

		IF v_no_tarjeta IS NULL THEN
			LET v_no_tarjeta = '';
		END IF

	END IF

	RETURN _fecha_aviso,
		   _no_documento,
		   _desc_gestion,
		   _user_added,
		   _fecha_gestion,
		   _nombre,
		   _tipo_aviso,
		   v_compania_nombre,
		   v_filtros,
		   v_telefono,
		   v_no_tarjeta
		   WITH RESUME;

END FOREACH

DROP TABLE tmp_gestion;

END PROCEDURE