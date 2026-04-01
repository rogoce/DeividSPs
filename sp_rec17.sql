-- Control de Audiencias
-- 
-- Creado    : 02/09/2000 - Autor: Demetrio Hurtado Almanza 
-- Modificado: 18/09/2000 - Autor: Demetrio Hurtado Almanza
--
-- SIS v.2.0 d_recl_sp_rec17_dw1 - DEIVID, S.A.

DROP PROCEDURE sp_rec17;

CREATE PROCEDURE "informix".sp_rec17(
a_compania CHAR(3),
a_agencia  CHAR(3),
a_periodo1 DATE,
a_periodo2 DATE,
a_sucursal CHAR(255),
a_ramo     CHAR(255),
a_lugci    CHAR(255)
) RETURNING	CHAR(18), 	-- Reclamo
			CHAR(20), 	-- Poliza
			CHAR(100),	-- Asegurado
			DATE,    	-- Fecha Siniestro
			DATE,     	-- Fecha Reclamo   
			DATE,     	-- Fecha Audiencia 
			CHAR(50), 	-- Nombre Lugar    
			CHAR(50), 	-- Ramo Nombre         
			CHAR(50),	-- Compania
			CHAR(100),  -- Conductor
			CHAR(30),   -- Cedula
			CHAR(10),   -- Parte policivo
			CHAR(255),	-- Filtros
			datetime hour to second, -- Hora de Audiencia
			char(10),   -- Numero de Recobro
			smallint;	-- Estatus Audiencia

DEFINE v_filtros          CHAR(255);
DEFINE _tipo              CHAR(1);

DEFINE v_doc_reclamo	  CHAR(18); 
DEFINE v_doc_poliza   	  CHAR(20); 
DEFINE v_nombre_asegurado CHAR(100);
DEFINE v_nombre_conductor CHAR(100);
DEFINE v_fecha_siniestro  DATE;     
DEFINE v_fecha_reclamo    DATE;     
DEFINE v_fecha_audiencia  DATE;     
DEFINE v_nombre_lugar     CHAR(50); 
DEFINE v_ramo_nombre      CHAR(50);     
DEFINE v_compania_nombre  CHAR(50);     
DEFINE v_cedula           CHAR(30);
DEFINE v_parte_policivo	  CHAR(10);

DEFINE _no_poliza   	  CHAR(10); 
DEFINE _cod_cliente   	  CHAR(10); 
DEFINE _cod_sucursal      CHAR(3);  
DEFINE _cod_ramo          CHAR(3);  
DEFINE _cod_lugci         CHAR(3);  
DEFINE _periodo           CHAR(7);
DEFINE _cod_conductor     CHAR(10);

DEFINE _hora_audiencia	  datetime hour to second;
DEFINE _no_recobro		  char(10);
DEFINE _no_reclamo   	  CHAR(10); 
DEFINE _estatus_audiencia smallint;
	
set isolation to dirty read;
	
-- Nombre de la Compania

LET  v_compania_nombre = sp_sis01(a_compania); 

-- Tabla Temporal 

--DROP TABLE tmp_audi;

CREATE TEMP TABLE tmp_audi(
		doc_reclamo	  	 CHAR(18),
		doc_poliza   	 CHAR(20), 
		nombre_asegurado CHAR(100),
		nombre_conductor CHAR(100),
		cedula           CHAR(30),
		parte_policivo	 CHAR(10),
		fecha_siniestro  DATE,     
		fecha_reclamo    DATE,     
		fecha_audiencia  DATE,     
		cod_sucursal	 CHAR(3),
		cod_lugci        CHAR(3), 
		cod_ramo         CHAR(3),   
		seleccionado     SMALLINT  DEFAULT 1 NOT NULL,
		hora_audiencia	 datetime hour to second,
		no_recobro		 char(10),
		estatus			 smallint,
		PRIMARY KEY (doc_reclamo)
		) WITH NO LOG;

CREATE INDEX xie01_tmp_audi ON tmp_audi(cod_sucursal);
CREATE INDEX xie02_tmp_audi ON tmp_audi(cod_ramo);
CREATE INDEX xie03_tmp_audi ON tmp_audi(cod_lugci);

FOREACH 
 SELECT numrecla,
		no_poliza,
		fecha_siniestro,
		fecha_reclamo,
		fecha_audiencia,
		cod_lugci,
		periodo,
		cod_sucursal,
		cod_conductor,
		parte_policivo,
		hora_audiencia,
		no_reclamo,
		estatus_audiencia
   INTO	v_doc_reclamo,
   		_no_poliza,
		v_fecha_siniestro,
		v_fecha_reclamo,
		v_fecha_audiencia,
		_cod_lugci,
		_periodo,
		_cod_sucursal,
		_cod_conductor,
		v_parte_policivo,
		_hora_audiencia,
		_no_reclamo,
		_estatus_audiencia
   FROM recrcmae
  WHERE cod_compania = a_compania
    AND actualizado  = 1
    AND fecha_audiencia BETWEEN a_periodo1 AND a_periodo2
  
  	SELECT cod_ramo,
		   no_documento,
		   cod_contratante
	  INTO _cod_ramo,
		   v_doc_poliza,
		   _cod_cliente
	  FROM emipomae
	 WHERE no_poliza = _no_poliza;

	SELECT nombre
	  INTO v_nombre_asegurado
	  FROM cliclien
	 WHERE cod_cliente = _cod_cliente;

	SELECT nombre,
	       cedula
	  INTO v_nombre_conductor,
	       v_cedula
	  FROM cliclien
	 WHERE cod_cliente = _cod_conductor;

	select no_recupero
	  into _no_recobro
	  from recrecup
	 where no_reclamo = _no_reclamo;

	INSERT INTO tmp_audi(
	doc_reclamo,	  	 
	doc_poliza,   	 
	nombre_asegurado, 
    nombre_conductor,
	cedula,
	parte_policivo,
    fecha_siniestro,  
	fecha_reclamo,    
	fecha_audiencia,  
	cod_sucursal,	 
	cod_lugci,        
	cod_ramo,
	hora_audiencia,
	no_recobro,
	estatus
	)
	VALUES(
	v_doc_reclamo,	  	 
	v_doc_poliza,   	 
	v_nombre_asegurado,
	v_nombre_conductor,
	v_cedula,
	v_parte_policivo, 
	v_fecha_siniestro,  
	v_fecha_reclamo,    
	v_fecha_audiencia,  
	_cod_sucursal,	 
	_cod_lugci,        
	_cod_ramo,
	_hora_audiencia,            
	_no_recobro,
	_estatus_audiencia
	);

END FOREACH

-- Procesos para Filtros

LET v_filtros = "";

IF a_sucursal <> "*" THEN

	LET v_filtros = TRIM(v_filtros) || " Sucursal: " ||  TRIM(a_sucursal);

	LET _tipo = sp_sis04(a_sucursal);  -- Separa los Valores del String en una tabla de codigos

	IF _tipo <> "E" THEN -- Incluir los Registros

		UPDATE tmp_audi
		   SET seleccionado = 0
		 WHERE seleccionado = 1
		   AND cod_sucursal NOT IN (SELECT codigo FROM tmp_codigos);

	ELSE		        -- Excluir estos Registros

		UPDATE tmp_audi
		   SET seleccionado = 0
		 WHERE seleccionado = 1
		   AND cod_sucursal IN (SELECT codigo FROM tmp_codigos);

	END IF

	DROP TABLE tmp_codigos;

END IF

IF a_ramo <> "*" THEN

	LET v_filtros = TRIM(v_filtros) || " Ramo: " ||  TRIM(a_ramo);

	LET _tipo = sp_sis04(a_ramo);  -- Separa los Valores del String en una tabla de codigos

	IF _tipo <> "E" THEN -- Incluir los Registros

		UPDATE tmp_audi
		   SET seleccionado = 0
		 WHERE seleccionado = 1
		   AND cod_ramo NOT IN (SELECT codigo FROM tmp_codigos);

	ELSE		        -- Excluir estos Registros

		UPDATE tmp_audi
		   SET seleccionado = 0
		 WHERE seleccionado = 1
		   AND cod_ramo IN (SELECT codigo FROM tmp_codigos);

	END IF

	DROP TABLE tmp_codigos;

END IF

IF a_lugci <> "*" THEN

	LET v_filtros = TRIM(v_filtros) || " Lugar: " ||  TRIM(a_lugci);

	LET _tipo = sp_sis04(a_lugci);  -- Separa los Valores del String en una tabla de codigos

	IF _tipo <> "E" THEN -- Incluir los Registros

		UPDATE tmp_audi
		   SET seleccionado = 0
		 WHERE seleccionado = 1
		   AND cod_lugci NOT IN (SELECT codigo FROM tmp_codigos);

	ELSE		        -- Excluir estos Registros

		UPDATE tmp_audi
		   SET seleccionado = 0
		 WHERE seleccionado = 1
		   AND cod_lugci IN (SELECT codigo FROM tmp_codigos);

	END IF

	DROP TABLE tmp_codigos;

END IF

FOREACH 
 SELECT doc_reclamo,
		doc_poliza,
		nombre_asegurado,
		nombre_conductor,
		cedula,
		parte_policivo,
		fecha_siniestro,
		fecha_reclamo,
		fecha_audiencia,
		cod_lugci,        
		cod_ramo,
		hora_audiencia,
		no_recobro,            
		estatus
   INTO	v_doc_reclamo,
		v_doc_poliza,
		v_nombre_asegurado,
		v_nombre_conductor,
		v_cedula,
		v_parte_policivo,
		v_fecha_siniestro,
		v_fecha_reclamo,
		v_fecha_audiencia,
		_cod_lugci,        
		_cod_ramo,
		_hora_audiencia,            
		_no_recobro,            
		_estatus_audiencia
   FROM tmp_audi
  WHERE seleccionado = 1

	SELECT nombre
	  INTO v_ramo_nombre
	  FROM prdramo
	 WHERE cod_ramo = _cod_ramo;

	SELECT nombre
	  INTO v_nombre_lugar
	  FROM reclugci
	 WHERE cod_lugci = _cod_lugci;

	RETURN	v_doc_reclamo,
			v_doc_poliza,
			v_nombre_asegurado,
			v_fecha_siniestro,
			v_fecha_reclamo,
			v_fecha_audiencia,
			v_nombre_lugar,
			v_ramo_nombre,
			v_compania_nombre,
			v_nombre_conductor,
			v_cedula,
			v_parte_policivo,
			v_filtros,
			_hora_audiencia,
			_no_recobro,
			_estatus_audiencia
			WITH RESUME;

END FOREACH

DROP TABLE tmp_audi;

END PROCEDURE;

