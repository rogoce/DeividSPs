-- Informe FUD

-- 
-- Creado    : 25/08/2011 - Autor: Amado Perez
-- Modificado: 25/08/2011 - Autor: Amado Perez
--
-- SIS v.2.0 - DEIVID, S.A.

DROP PROCEDURE sp_rec187;

CREATE PROCEDURE "informix".sp_rec187(a_compania CHAR(3), a_fecha_desde DATE, a_fecha_hasta DATE, a_agencia CHAR(255) DEFAULT "*", a_ajustador CHAR(255) DEFAULT "*", a_ramo CHAR(255) DEFAULT "*", a_estatus CHAR(255) DEFAULT "*", a_abogado CHAR(255) DEFAULT "*") 
			RETURNING   CHAR(18),  --NUMRECLA
			            CHAR(20),  --NO DOCUMENTO
			            VARCHAR(100), --ASEGURADO
						DATE,	      --FECHA SINIESTRO
						DATE,	      --FECHA RECLAMO
						SMALLINT,	  --ESTATUS DE AUDIENCIA
						VARCHAR(20),  --ESTATUS DE AUDIENCIA
			            VARCHAR(100), --CONDUCTOR
						VARCHAR(50),  --ABOGADO
			  		    CHAR(50),
			  		    CHAR(255);


DEFINE v_numrecla     	   CHAR(18);
DEFINE v_no_documento	   CHAR(20);
DEFINE _cod_asegurado	   CHAR(10);
DEFINE _cod_conductor	   CHAR(10);
DEFINE _cod_abogado        CHAR(3);
DEFINE v_fecha_siniestro   DATE;	 	
DEFINE v_fecha_reclamo	   DATE;  	
DEFINE v_estatus_audiencia SMALLINT;
DEFINE _cod_sucursal	   CHAR(3);
DEFINE _ajust_interno      CHAR(3);
DEFINE _no_poliza          CHAR(10);
DEFINE _cod_ramo           CHAR(3);
DEFINE v_compania_nombre   CHAR(50); 
DEFINE v_asegurado    	   VARCHAR(100);
DEFINE v_conductor         VARCHAR(100);
DEFINE v_ajustador_nombre  VARCHAR(50);
DEFINE v_abogado_nombre    VARCHAR(50);
DEFINE v_abogado   		   VARCHAR(50);
DEFINE v_desc_estatus      VARCHAR(20);

DEFINE v_filtros           CHAR(255);
DEFINE v_codigo            CHAR(10);
DEFINE v_saber		       CHAR(3);
DEFINE _tipo               CHAR(1);

CREATE TEMP TABLE tmp_reclamo(
		numrecla     	  CHAR(18),
		no_documento	  CHAR(20),
		cod_asegurado	  CHAR(10),		
		cod_conductor	  CHAR(10),		
		fecha_siniestro  DATE,	 	
		fecha_reclamo	  DATE,  	
		estatus_audiencia SMALLINT,
		cod_sucursal	  CHAR(3),
		ajust_interno     CHAR(3),
		cod_ramo          CHAR(3),
		cod_abogado       CHAR(3),	
		seleccionado      SMALLINT DEFAULT 1 NOT NULL
		) WITH NO LOG;


SET ISOLATION TO DIRTY READ;

-- Nombre de la Compania

LET v_compania_nombre = sp_sis01(a_compania);

LET v_asegurado = "";
LET v_conductor = "";
LET v_desc_estatus = "";

FOREACH
  SELECT numrecla,
         no_documento,
		 cod_asegurado,
		 cod_conductor,
		 fecha_siniestro,
		 fecha_reclamo,
		 estatus_audiencia,
		 cod_sucursal,
		 ajust_interno,
		 no_poliza,
		 cod_abogado
	INTO v_numrecla,     	  	
		 v_no_documento,	  	
		 _cod_asegurado,	  	
		 _cod_conductor,	  
		 v_fecha_siniestro, 
		 v_fecha_reclamo,	  	
		 v_estatus_audiencia,
		 _cod_sucursal,
		 _ajust_interno,
		 _no_poliza,
		 _cod_abogado	  	
	FROM recrcmae
   WHERE actualizado = 1
     AND fecha_siniestro >= a_fecha_desde
     AND fecha_siniestro <= a_fecha_hasta
ORDER BY 1

    SELECT cod_ramo
	  INTO _cod_ramo
	  FROM emipomae
	 WHERE no_poliza = _no_poliza;

    IF v_estatus_audiencia is null then
		LET v_estatus_audiencia = 0;
	END IF

    IF _cod_abogado is null then
		LET _cod_abogado = "";
	END IF

	INSERT INTO tmp_reclamo(
	numrecla,     	 
	no_documento,	 	
	cod_asegurado,	 
	cod_conductor,	 
	fecha_siniestro, 	
	fecha_reclamo,	 
	estatus_audiencia,
	cod_sucursal,
	ajust_interno,
	cod_ramo,
	cod_abogado	 	
	)
	VALUES(
	v_numrecla,     	  	
	v_no_documento,	  	
	_cod_asegurado,	  	
	_cod_conductor,	  
	v_fecha_siniestro, 	
	v_fecha_reclamo,	  	
	v_estatus_audiencia,
	_cod_sucursal,
	_ajust_interno,
	_cod_ramo,
	_cod_abogado	  		
	);

END FOREACH

-- Filtros para Agencia
LET v_filtros = "";

IF a_agencia <> "*" THEN

	LET v_filtros = TRIM(v_filtros) || " Sucursal: " ||  TRIM(a_agencia);

	LET _tipo = sp_sis04(a_agencia);  -- Separa los Valores del String en una tabla de codigos

	IF _tipo <> "E" THEN -- Incluir los Registros

		UPDATE tmp_reclamo
		   SET seleccionado = 0
		 WHERE seleccionado = 1
		   AND cod_sucursal NOT IN (SELECT codigo FROM tmp_codigos);
           LET v_saber = "";
	ELSE		        -- Excluir estos Registros
				   
		UPDATE tmp_reclamo
		   SET seleccionado = 0
		 WHERE seleccionado = 1
		   AND cod_sucursal IN (SELECT codigo FROM tmp_codigos);
           LET v_saber = " Ex";
	END IF

   { FOREACH
		SELECT agtagent.nombre,tmp_codigos.codigo
	      INTO v_agente_nombre,v_codigo
	      FROM agtagent,tmp_codigos
	     WHERE agtagent.cod_agente = codigo
	     LET v_filtros = TRIM(v_filtros) || " " || TRIM(v_codigo) || " " || TRIM(v_agente_nombre) || (v_saber);
    END FOREACH
	}
	DROP TABLE tmp_codigos;

END IF

-- Filtros para Ajustador

IF a_ajustador <> "*" THEN

	LET v_filtros = TRIM(v_filtros) || " Ajustador: ";-- ||  TRIM(a_agencia);

	LET _tipo = sp_sis04(a_ajustador);  -- Separa los Valores del String en una tabla de codigos

	IF _tipo <> "E" THEN -- Incluir los Registros

		UPDATE tmp_reclamo
		   SET seleccionado = 0
		 WHERE seleccionado = 1
		   AND ajust_interno NOT IN (SELECT codigo FROM tmp_codigos);
           LET v_saber = "";
	ELSE		        -- Excluir estos Registros
				   
		UPDATE tmp_reclamo
		   SET seleccionado = 0
		 WHERE seleccionado = 1
		   AND ajust_interno IN (SELECT codigo FROM tmp_codigos);
           LET v_saber = " Ex";
	END IF

    FOREACH
		SELECT recajust.nombre,tmp_codigos.codigo
	      INTO v_ajustador_nombre,v_codigo
	      FROM recajust,tmp_codigos
	     WHERE recajust.cod_ajustador = codigo
	     LET v_filtros = TRIM(v_filtros) || " " || TRIM(v_codigo) || " " || TRIM(v_ajustador_nombre) || (v_saber);
    END FOREACH
	
	DROP TABLE tmp_codigos;

END IF

-- Filtros para Ramos

IF a_ramo <> "*" THEN

	LET v_filtros = TRIM(v_filtros) || " Ramo: " ||  TRIM(a_ramo);

	LET _tipo = sp_sis04(a_ramo);  -- Separa los Valores del String en una tabla de codigos

	IF _tipo <> "E" THEN -- Incluir los Registros

		UPDATE tmp_reclamo
		   SET seleccionado = 0
		 WHERE seleccionado = 1
		   AND cod_ramo NOT IN (SELECT codigo FROM tmp_codigos);
           LET v_saber = "";
	ELSE		        -- Excluir estos Registros
				   
		UPDATE tmp_reclamo
		   SET seleccionado = 0
		 WHERE seleccionado = 1
		   AND cod_ramo IN (SELECT codigo FROM tmp_codigos);
           LET v_saber = " Ex";
	END IF

    {FOREACH
		SELECT recajust.nombre,tmp_codigos.codigo
	      INTO v_ajustador_nombre,v_codigo
	      FROM agtagent,tmp_codigos
	     WHERE agtagent.ajust_interno = codigo
	     LET v_filtros = TRIM(v_filtros) || " " || TRIM(v_codigo) || " " || TRIM(v_ajustador_nombre) || (v_saber);
    END FOREACH
	}
	DROP TABLE tmp_codigos;

END IF

-- Filtros para Estatus Audiencia

IF a_estatus <> "*" THEN

	LET v_filtros = TRIM(v_filtros) || " Estatus Audiencia: " ||  TRIM(a_estatus);

	LET _tipo = sp_sis04(a_estatus);  -- Separa los Valores del String en una tabla de codigos

	IF _tipo <> "E" THEN -- Incluir los Registros

		UPDATE tmp_reclamo
		   SET seleccionado = 0
		 WHERE seleccionado = 1
		   AND estatus_audiencia NOT IN (SELECT codigo FROM tmp_codigos);
           LET v_saber = "";
	ELSE		        -- Excluir estos Registros
				   
		UPDATE tmp_reclamo
		   SET seleccionado = 0
		 WHERE seleccionado = 1
		   AND estatus_audiencia IN (SELECT codigo FROM tmp_codigos);
           LET v_saber = " Ex";
	END IF

    {FOREACH
		SELECT recajust.nombre,tmp_codigos.codigo
	      INTO v_ajustador_nombre,v_codigo
	      FROM agtagent,tmp_codigos
	     WHERE agtagent.ajust_interno = codigo
	     LET v_filtros = TRIM(v_filtros) || " " || TRIM(v_codigo) || " " || TRIM(v_ajustador_nombre) || (v_saber);
    END FOREACH
	}
	DROP TABLE tmp_codigos;

END IF

-- Filtros para Abogado

IF a_abogado <> "*" THEN

	LET v_filtros = TRIM(v_filtros) || " Abogado: ";-- ||  TRIM(a_agencia);

	LET _tipo = sp_sis04(a_abogado);  -- Separa los Valores del String en una tabla de codigos

	IF _tipo <> "E" THEN -- Incluir los Registros

		UPDATE tmp_reclamo
		   SET seleccionado = 0
		 WHERE seleccionado = 1
		   AND cod_abogado NOT IN (SELECT codigo FROM tmp_codigos);
           LET v_saber = "";
	ELSE		        -- Excluir estos Registros
				   
		UPDATE tmp_reclamo
		   SET seleccionado = 0
		 WHERE seleccionado = 1
		   AND cod_abogado IN (SELECT codigo FROM tmp_codigos);
           LET v_saber = " Ex";
	END IF

    FOREACH
		SELECT recaboga.nombre_abogado,tmp_codigos.codigo
	      INTO v_abogado_nombre,v_codigo
	      FROM recaboga,tmp_codigos
	     WHERE recaboga.cod_abogado = codigo
	     LET v_filtros = TRIM(v_filtros) || " " || TRIM(v_codigo) || " " || TRIM(v_abogado_nombre) || (v_saber);
    END FOREACH
	
	DROP TABLE tmp_codigos;

END IF

LET v_filtros = TRIM(v_filtros);

FOREACH	WITH HOLD
	SELECT numrecla,     	  
		   no_documento,	 
		   cod_asegurado,	 
		   cod_conductor,	 
		   fecha_siniestro, 
		   fecha_reclamo,	 
		   estatus_audiencia,
		   cod_abogado
	  INTO v_numrecla,     	
		   v_no_documento,	  	
		   _cod_asegurado,	  	
		   _cod_conductor,	  
		   v_fecha_siniestro, 
		   v_fecha_reclamo,	
		   v_estatus_audiencia,
		   _cod_abogado
	  FROM tmp_reclamo
	 WHERE seleccionado = 1

	SELECT nombre
	  INTO v_asegurado
	  FROM cliclien
	 WHERE cod_cliente = _cod_asegurado;

	SELECT nombre
	  INTO v_conductor
	  FROM cliclien
	 WHERE cod_cliente = _cod_conductor;

	SELECT nombre_abogado
	  INTO v_abogado
	  FROM recaboga
	 WHERE cod_abogado = _cod_abogado;

    IF v_estatus_audiencia = 0 THEN
		LET v_desc_estatus = 'Perdido';
    ELIF v_estatus_audiencia = 1 THEN
		LET v_desc_estatus = 'Ganado';
    ELIF v_estatus_audiencia = 2 THEN
		LET v_desc_estatus = 'Por Definir';
    ELIF v_estatus_audiencia = 3 THEN
		LET v_desc_estatus = 'Proceso Penal';
    ELIF v_estatus_audiencia = 4 THEN
		LET v_desc_estatus = 'Proceso Civil';
    ELIF v_estatus_audiencia = 5 THEN
		LET v_desc_estatus = 'Apelacion';
    ELIF v_estatus_audiencia = 6 THEN
		LET v_desc_estatus = 'Resuelto';
    ELIF v_estatus_audiencia = 7 THEN
		LET v_desc_estatus = 'FUT - Ganado';
    ELIF v_estatus_audiencia = 8 THEN
		LET v_desc_estatus = 'FUT - Responsable';
	ELSE
	    LET v_desc_estatus = 'Sin Estatus';
	END IF

    RETURN v_numrecla,    
		   v_no_documento,
		   v_asegurado,
		   v_fecha_siniestro,
		   v_fecha_reclamo,
		   v_estatus_audiencia,
		   v_desc_estatus,
		   v_conductor, 
		   v_abogado,
		   v_compania_nombre,
		   v_filtros		   
		   WITH RESUME;

END FOREACH

DROP TABLE tmp_reclamo;

END PROCEDURE;