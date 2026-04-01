-- Procedimiento que Carga de Perdidas Totales
-- en un Periodo Dado
-- 
-- Creado    : 10/08/2000 - Autor: Amado Perez Mendoza 
-- Modificado: 11/08/2000 - Autor: Amado Perez Mendoza
--
-- SIS v.2.0 - DEIVID, S.A.

DROP PROCEDURE sp_rec05;

CREATE PROCEDURE "informix".sp_rec05(a_compania CHAR(3),a_agencia CHAR(3),a_periodo1 CHAR(7),a_periodo2 CHAR(7),a_sucursal CHAR(255) DEFAULT "*",a_ramo CHAR(255) DEFAULT "*",a_grupo CHAR(255) DEFAULT "*",a_cliente CHAR(255) DEFAULT "*")
  RETURNING CHAR(18),
		    CHAR(20), 
		    CHAR(100), 
		    CHAR(50), 
		    CHAR(30),
		    CHAR(50),
		    CHAR(50),
		    CHAR(4),
		    CHAR(50),
		    DEC(16,2),
			CHAR(50),
			CHAR(50),
			CHAR(50),
			CHAR(255);

DEFINE v_numrecla        CHAR(18);
DEFINE v_no_documento    CHAR(20);
DEFINE v_asegurado       CHAR(100);
DEFINE v_grupo           CHAR(50);
DEFINE v_no_motor        CHAR(30);
DEFINE v_marca           CHAR(50);
DEFINE v_modelo          CHAR(50);
DEFINE v_ano			 CHAR(4);
DEFINE v_uso             CHAR(50);
DEFINE v_monto_pagado    DEC(16,2);
DEFINE v_tipo_siniestro  CHAR(50);
DEFINE v_nombre_ramo	 CHAR(50);
DEFINE v_compania_nombre CHAR(50);
DEFINE v_filtros         CHAR(255);

DEFINE _cod_ramo        CHAR(3);
DEFINE _cod_sucursal    CHAR(3);
DEFINE _no_reclamo      CHAR(10);      
DEFINE _no_poliza       CHAR(10);
DEFINE _no_unidad       INT;
DEFINE _cod_evento      CHAR(3);
DEFINE _cod_contratante CHAR(10);
DEFINE _cod_grupo		CHAR(5);
DEFINE _cod_marca       CHAR(5);
DEFINE _cod_modelo      CHAR(5);
DEFINE _cod_tipoveh     CHAR(3);
DEFINE _tipo            CHAR(1);

set isolation to dirty read;

-- Nombre de la Compania

LET v_compania_nombre = sp_sis01(a_compania);


CREATE TEMP TABLE tmp_perd_total(
		numrecla             CHAR(18)  NOT NULL,
		documento            CHAR(20)  NOT NULL,
		asegurado            CHAR(100) NOT NULL,
		ano					 CHAR(4),
		monto_pagado         DEC(16,2) NOT NULL,
		cod_ramo             CHAR(3)   NOT NULL,
		cod_grupo            CHAR(5)   NOT NULL,
		cod_sucursal		 CHAR(3)   NOT NULL,
		cod_tipoveh          CHAR(3),
		cod_evento           CHAR(3),
		cod_marca      		 CHAR(5),
		cod_modelo     		 CHAR(5),
		no_motor			 CHAR(30),
		cod_contratante		 CHAR(10),
		seleccionado         SMALLINT  DEFAULT 1 NOT NULL
		) WITH NO LOG;

FOREACH
 SELECT	no_reclamo,
 		numrecla,
        no_poliza,
		no_unidad,
		no_motor,
		cod_evento
   INTO	_no_reclamo,
   		v_numrecla,
        _no_poliza,
		_no_unidad,
		v_no_motor,
		_cod_evento
   FROM recrcmae
  WHERE cod_compania = a_compania
    AND perd_total   = 1
    AND periodo      BETWEEN a_periodo1 AND a_periodo2

	-- Lectura de Polizas

	SELECT no_documento,
		   cod_contratante,
		   cod_grupo,
		   cod_sucursal,
		   cod_ramo	
	  INTO v_no_documento,
	       _cod_contratante,
		   _cod_grupo,
		   _cod_sucursal,
		   _cod_ramo
	  FROM emipomae
	 WHERE no_poliza = _no_poliza;

	-- Lectura de Contratante

	SELECT nombre
	  INTO v_asegurado
	  FROM cliclien
	 WHERE cod_cliente = _cod_contratante;


    -- Lectura de Vehiculo

	SELECT cod_marca,
		   cod_modelo,
		   ano_auto
	  INTO _cod_marca,
	       _cod_modelo,
		   v_ano
	  FROM emivehic
	 WHERE no_motor = v_no_motor;


    -- Lectura de Uso

    SELECT cod_tipoveh
	  INTO _cod_tipoveh
	  FROM emiauto
	 WHERE no_poliza = _no_poliza
	   AND no_unidad = _no_unidad
	   AND no_motor = v_no_motor;


	-- Monto Pagado

	 SELECT SUM(monto) 
	   INTO v_monto_pagado
	   FROM rectrmae 
	  WHERE no_reclamo   = _no_reclamo
	    AND cod_tipotran IN (4,5,6,7);

	IF v_no_motor IS NULL THEN
		LET v_no_motor = " ";
	END IF 
	
	IF v_ano IS NULL THEN
		LET v_ano = " ";
	END IF 

  	IF v_monto_pagado IS NULL THEN
		LET v_monto_pagado = 0;
	END IF 

	INSERT INTO tmp_perd_total(
	numrecla,          
	documento,         
	asegurado,         
	ano,				  
	monto_pagado,      
	cod_ramo,
	cod_grupo,
	no_motor,
	cod_sucursal,
	cod_tipoveh,
	cod_evento, 
	cod_marca,  
	cod_modelo,
	cod_contratante     
	)
	VALUES(
	v_numrecla,
	v_no_documento,
	v_asegurado,         
	v_ano,				  
	v_monto_pagado,      
	_cod_ramo,
	_cod_grupo,
	v_no_motor,             
	_cod_sucursal,
	_cod_tipoveh,
	_cod_evento, 
	_cod_marca,  
	_cod_modelo,
	_cod_contratante     
	);
END FOREACH;

-- Procesos para Filtros

LET v_filtros = "";

IF a_sucursal <> "*" THEN

	LET v_filtros = TRIM(v_filtros) || " Sucursal: " ||  TRIM(a_sucursal);

	LET _tipo = sp_sis04(a_sucursal);  -- Separa los Valores del String en una tabla de codigos

	IF _tipo <> "E" THEN -- (I) Incluir los Registros

		UPDATE tmp_perd_total
		   SET seleccionado = 0
		 WHERE seleccionado = 1
		   AND cod_sucursal NOT IN (SELECT codigo FROM tmp_codigos);

	ELSE		        -- (E) Excluir estos Registros
				   
		UPDATE tmp_perd_total
		   SET seleccionado = 0
		 WHERE seleccionado = 1
		   AND cod_sucursal IN (SELECT codigo FROM tmp_codigos);

	END IF

	DROP TABLE tmp_codigos;

END IF


IF a_ramo <> "*" THEN

	LET v_filtros = TRIM(v_filtros) || " Ramo: " ||  TRIM(a_ramo);

	LET _tipo = sp_sis04(a_ramo);  -- Separa los Valores del String en una tabla de codigos

	IF _tipo <> "E" THEN -- (I) Incluir los Registros

		UPDATE tmp_perd_total
		   SET seleccionado = 0
		 WHERE seleccionado = 1
		   AND cod_ramo NOT IN (SELECT codigo FROM tmp_codigos);

	ELSE		        -- (E) Excluir estos Registros
				   
		UPDATE tmp_perd_total
		   SET seleccionado = 0
		 WHERE seleccionado = 1
		   AND cod_ramo IN (SELECT codigo FROM tmp_codigos);

	END IF

	DROP TABLE tmp_codigos;

END IF

IF a_grupo <> "*" THEN

	LET v_filtros = TRIM(v_filtros) || " Grupo: " ||  TRIM(a_grupo);

	LET _tipo = sp_sis04(a_grupo);  -- Separa los Valores del String en una tabla de codigos

	IF _tipo <> "E" THEN -- (I) Incluir los Registros

		UPDATE tmp_perd_total
		   SET seleccionado = 0
		 WHERE seleccionado = 1
		   AND cod_grupo NOT IN (SELECT codigo FROM tmp_codigos);

	ELSE		        -- (E) Excluir estos Registros
				   
		UPDATE tmp_perd_total
		   SET seleccionado = 0
		 WHERE seleccionado = 1
		   AND cod_grupo IN (SELECT codigo FROM tmp_codigos);

	END IF

	DROP TABLE tmp_codigos;

END IF

IF a_cliente <> "*" THEN

	LET v_filtros = TRIM(v_filtros) || " Asegurado: " ||  TRIM(a_cliente);

	LET _tipo = sp_sis04(a_cliente);  -- Separa los Valores del String en una tabla de codigos

	IF _tipo <> "E" THEN -- (I) Incluir los Registros

		UPDATE tmp_perd_total
		   SET seleccionado = 0
		 WHERE seleccionado = 1
		   AND cod_contratante NOT IN (SELECT codigo FROM tmp_codigos);

	ELSE		        -- (E) Excluir estos Registros
				   
		UPDATE tmp_perd_total
		   SET seleccionado = 0
		 WHERE seleccionado = 1
		   AND cod_contratante IN (SELECT codigo FROM tmp_codigos);

	END IF

	DROP TABLE tmp_codigos;

END IF


--Recorre la tabla temporal y asigna valores a variables de salida
FOREACH WITH HOLD
 SELECT numrecla,    
 		documento,   
 		asegurado,   
 		ano,			
 		monto_pagado,
 		cod_ramo,
 		cod_grupo,
 		no_motor,
 		cod_sucursal,
 		cod_tipoveh,
 		cod_evento, 
 		cod_marca,  
 		cod_modelo   
   INTO v_numrecla,
   		v_no_documento,
   		v_asegurado,   
   		v_ano,			
   		v_monto_pagado,
   		_cod_ramo,
   		_cod_grupo,
   		v_no_motor,    
   		_cod_sucursal,
   		_cod_tipoveh,
   		_cod_evento, 
   		_cod_marca,  
		_cod_modelo    
   FROM tmp_perd_total
  WHERE seleccionado = 1
  ORDER BY cod_ramo, numrecla

	--Selecciona los nombres de Ramos
	SELECT 	nombre
  	  INTO 	v_nombre_ramo
  	  FROM 	prdramo
	 WHERE	cod_ramo = _cod_ramo;

    -- Lectura de Grupo

    SELECT nombre
	  INTO v_grupo
	  FROM cligrupo
	 WHERE cod_grupo = _cod_grupo;

    -- Lectura de Marca

    SELECT nombre
	  INTO v_marca
	  FROM emimarca
	 WHERE cod_marca = _cod_marca;

	-- Lectura de Modelo

    SELECT nombre
	  INTO v_modelo
	  FROM emimodel
	 WHERE cod_marca = _cod_marca
	   AND cod_modelo = _cod_modelo;

	-- Lectura del uso

    SELECT nombre
	  INTO v_uso
	  FROM emitiveh
	 WHERE cod_tipoveh = _cod_tipoveh;

    -- Lectura del Evento

     SELECT nombre
	  INTO  v_tipo_siniestro
	  FROM recevent
	 WHERE cod_evento = _cod_evento;


	RETURN 	v_numrecla,
			v_no_documento,
			v_asegurado,      
			v_grupo,          
			v_no_motor,       
			v_marca,          
			v_modelo,         
			v_ano,
			v_uso,            
			v_monto_pagado,
			v_tipo_siniestro,
			v_nombre_ramo,
			v_compania_nombre,
			v_filtros
		    WITH RESUME;

END FOREACH

DROP TABLE tmp_perd_total;
END PROCEDURE;