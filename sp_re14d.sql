-- Siniestralidad por Ramo - Detalle Corredor
-- 
-- Creado    : 30/08/2000 - Autor: Demetrio Hurtado Almanza 
-- Modificado: 19/09/2000 - Autor: Demetrio Hurtado Almanza
--
-- SIS v.2.0 - d_recl_sp_rec14d_dw4 - DEIVID, S.A.

DROP PROCEDURE sp_rec14d;

CREATE PROCEDURE sp_rec14d(
a_compania CHAR(3),
a_agencia  CHAR(3),
a_periodo1 CHAR(7),
a_periodo2 CHAR(7),
a_sucursal CHAR(255),
a_ramo     CHAR(255)
) RETURNING CHAR(50),	   -- Agente
			DECIMAL(16,2), -- Prima Suscrita
			DECIMAL(16,2), -- Incurrido Bruto
			DECIMAL(16,2), -- % Siniestralidad 
			DECIMAL(16,2), -- Prima Pagada
			DECIMAL(16,2), -- Sinestros Pagados
			DECIMAL(16,2), -- % Pagado/Cobrado
			CHAR(50),	   -- Ramo
			CHAR(50),	   -- Compania
			CHAR(255);	   -- Filtros

DEFINE v_filtros          CHAR(255);
DEFINE _tipo              CHAR(1);

DEFINE v_agente_nombre    CHAR(50);     
DEFINE v_prima_suscrita   DECIMAL(16,2);
DEFINE v_incurrido_bruto  DECIMAL(16,2);
DEFINE v_porc_siniest     DECIMAL(16,2);
DEFINE v_siniestro_pagado DECIMAL(16,2);
DEFINE v_prima_pagada     DECIMAL(16,2);
DEFINE v_porc_pagado      DECIMAL(16,2);
DEFINE v_ramo_nombre      CHAR(50);     
DEFINE v_compania_nombre  CHAR(50);     

DEFINE _cod_ramo          CHAR(3);      
DEFINE _cod_agente        CHAR(5);      

-- Nombre de la Compania

LET  v_compania_nombre = sp_sis01(a_compania); 

-- Procedimiento que carga la Siniestralidad

CALL sp_rec14(
a_compania,
a_agencia,
a_periodo1,
a_periodo2
);

-- Procesos para Filtros

LET v_filtros = "";

IF a_sucursal <> "*" THEN

	LET v_filtros = TRIM(v_filtros) || " Sucursal: " ||  TRIM(a_sucursal);

	LET _tipo = sp_sis04(a_sucursal);  -- Separa los Valores del String en una tabla de codigos

	IF _tipo <> "E" THEN -- Incluir los Registros

		UPDATE tmp_siniest
		   SET seleccionado = 0
		 WHERE seleccionado = 1
		   AND cod_sucursal NOT IN (SELECT codigo FROM tmp_codigos);

	ELSE		        -- Excluir estos Registros

		UPDATE tmp_siniest
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

		UPDATE tmp_siniest
		   SET seleccionado = 0
		 WHERE seleccionado = 1
		   AND cod_ramo NOT IN (SELECT codigo FROM tmp_codigos);

	ELSE		        -- (E) Excluir estos Registros

		UPDATE tmp_siniest
		   SET seleccionado = 0
		 WHERE seleccionado = 1
		   AND cod_ramo IN (SELECT codigo FROM tmp_codigos);

	END IF

	DROP TABLE tmp_codigos;

END IF

{IF a_cliente <> "*" THEN

	LET v_filtros = TRIM(v_filtros);-- || " Asegurado: " ||  TRIM(a_cliente);

	LET _tipo = sp_sis04(a_cliente);  -- Separa los Valores del String en una tabla de codigos

	IF _tipo <> "E" THEN -- Incluir los Registros

		UPDATE tmp_siniest
		   SET seleccionado = 0
		 WHERE seleccionado = 1
		   AND cod_cliente NOT IN (SELECT codigo FROM tmp_codigos);
	       LET v_saber = "";

	ELSE		        -- Excluir estos Registros

		UPDATE tmp_siniest
		   SET seleccionado = 0
		 WHERE seleccionado = 1
		   AND cod_cliente IN (SELECT codigo FROM tmp_codigos);
	       LET v_saber = " Ex";

	END IF
	DROP TABLE tmp_codigos;

END IF}

-- Tabla Temporal 

CREATE TEMP TABLE tmp_agente(
		cod_agente			CHAR(5)	  NOT NULL,
		no_poliza           CHAR(10)  NOT NULL,
		cod_ramo            CHAR(3)   NOT NULL,
		prima_suscrita      DEC(16,2) NOT NULL,
		incurrido_bruto     DEC(16,2) NOT NULL,
		prima_pagada        DEC(16,2) NOT NULL,
		siniestro_pagado    DEC(16,2) NOT NULL,
		PRIMARY KEY (cod_agente, no_poliza)
		) WITH NO LOG;

CREATE INDEX xie01_tmp_agente ON tmp_agente(cod_ramo, cod_agente);

-- Seleccionar los agentes de las polizas

BEGIN

DEFINE _no_poliza        CHAR(10);     
DEFINE _porc_partic      DECIMAL(16,2);
DEFINE _prima_suscrita   DECIMAL(16,2);
DEFINE _incurrido_bruto  DECIMAL(16,2);
DEFINE _prima_pagada     DECIMAL(16,2);
DEFINE _siniestro_pagado DECIMAL(16,2);

FOREACH
 SELECT	no_poliza,
		cod_ramo,
        prima_suscrita,   
		incurrido_bruto,  
		prima_pagada,     
		siniestro_pagado 
   INTO	_no_poliza,
		_cod_ramo,
        v_prima_suscrita,   
		v_incurrido_bruto,  
		v_prima_pagada,     
		v_siniestro_pagado 
   FROM	tmp_siniest
  WHERE seleccionado = 1

	FOREACH
	 SELECT cod_agente,
			porc_partic_agt
	   INTO	_cod_agente,
	        _porc_partic
	   FROM	emipoagt
	  WHERE	no_poliza = _no_poliza

			LET _prima_suscrita   = v_prima_suscrita   / 100 * _porc_partic; 
			LET _incurrido_bruto  = v_incurrido_bruto  / 100 * _porc_partic; 
			LET _prima_pagada     = v_prima_pagada     / 100 * _porc_partic; 
			LET _siniestro_pagado = v_siniestro_pagado / 100 * _porc_partic; 

			INSERT INTO tmp_agente(
			cod_agente,		   
			no_poliza,          
			cod_ramo,           
			prima_suscrita,     
			incurrido_bruto,    
			prima_pagada,       
			siniestro_pagado   
			)
			VALUES(
			_cod_agente,		   
			_no_poliza,          
			_cod_ramo,           
			_prima_suscrita,     
		    _incurrido_bruto,    
			_prima_pagada,       
			_siniestro_pagado   
			);

	END FOREACH

END FOREACH

DROP TABLE tmp_siniest;

END

-- Seleccion de los registros a imprimir

FOREACH
 SELECT cod_ramo,
        cod_agente, 
        SUM(prima_suscrita),   
		SUM(incurrido_bruto),  
		SUM(siniestro_pagado), 
		SUM(prima_pagada)     
   INTO	_cod_ramo,
        _cod_agente, 
        v_prima_suscrita,   
		v_incurrido_bruto,  
		v_siniestro_pagado, 
		v_prima_pagada     
   FROM	tmp_agente
  GROUP BY cod_ramo, cod_agente
  ORDER BY cod_ramo, cod_agente

	SELECT nombre
	  INTO v_ramo_nombre
	  FROM prdramo
	 WHERE cod_ramo = _cod_ramo;

	SELECT nombre
	  INTO v_agente_nombre
	  FROM agtagent
	 WHERE cod_agente = _cod_agente;

	-- Porcentaje de Siniestralidad

	IF v_prima_suscrita = 0 THEN
		IF v_incurrido_bruto = 0 THEN
			LET v_porc_siniest = 0;
		ELSE
			LET v_porc_siniest = 100;
		END IF
	ELSE
       IF v_incurrido_bruto < 0 THEN
		  LET v_porc_siniest = 0;
	   ELSE
  	      LET v_porc_siniest = (v_incurrido_bruto / v_prima_suscrita)*100;
	   END IF	  
	END IF

	-- Porcentaje de Pagado

	IF v_prima_pagada = 0 THEN
		IF v_siniestro_pagado = 0 THEN
			LET v_porc_pagado = 0;
		ELSE
			LET v_porc_pagado = 100;
		END IF
	ELSE
	   IF v_incurrido_bruto < 0 THEN
		  LET v_porc_pagado = 0;
	   ELSE 
	      LET v_porc_pagado = (v_siniestro_pagado / v_prima_pagada)*100;
	   END IF
	END IF

	RETURN v_agente_nombre,
	       v_prima_suscrita,
		   v_incurrido_bruto,
		   v_porc_siniest,
		   v_prima_pagada,
		   v_siniestro_pagado,
		   v_porc_pagado,
		   v_ramo_nombre,
		   v_compania_nombre,
		   v_filtros
		   WITH RESUME;

END FOREACH

DROP TABLE tmp_agente;

END PROCEDURE;
