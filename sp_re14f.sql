-- Siniestralidad por Grupo - Detalle Ramo
-- 
-- Creado    : 30/08/2000 - Autor: Demetrio Hurtado Almanza 
-- Modificado: 16/09/2000 - Autor: Demetrio Hurtado Almanza
--
-- SIS v.2.0 - d_recl_sp_rec14f_dw6 - DEIVID, S.A.

DROP PROCEDURE sp_rec14f;

CREATE PROCEDURE "informix".sp_rec14f(
a_compania CHAR(3),
a_agencia  CHAR(3),
a_periodo1 CHAR(7),
a_periodo2 CHAR(7),
a_sucursal CHAR(255),
a_grupo    CHAR(255),
a_agente CHAR(255) DEFAULT '*'
) RETURNING CHAR(50),	   -- Ramo
			DECIMAL(16,2), -- Prima Suscrita
			DECIMAL(16,2), -- Incurrido Bruto
			DECIMAL(16,2), -- % Siniestralidad 
			DECIMAL(16,2), -- Prima Pagada
			DECIMAL(16,2), -- Sinestros Pagados
			DECIMAL(16,2), -- % Pagado/Cobrado
			CHAR(50),	   -- Grupo
			CHAR(50),	   -- Compania
			CHAR(255);	   -- Filtros

DEFINE v_filtros          CHAR(255);
DEFINE _tipo              CHAR(1);

DEFINE v_grupo_nombre     CHAR(50);
DEFINE v_prima_suscrita   DECIMAL(16,2);
DEFINE v_incurrido_bruto  DECIMAL(16,2);
DEFINE v_porc_siniest     DECIMAL(16,2);
DEFINE v_siniestro_pagado DECIMAL(16,2);
DEFINE v_prima_pagada     DECIMAL(16,2);
DEFINE v_porc_pagado      DECIMAL(16,2);
DEFINE v_ramo_nombre      CHAR(50);
DEFINE v_compania_nombre  CHAR(50);
DEFINE v_desc_agente	  CHAR(50);
DEFINE v_codigo			  CHAR(10);
DEFINE _cod_ramo,v_saber  CHAR(3);      
DEFINE _cod_grupo         CHAR(5);      

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

IF a_grupo <> "*" THEN

	LET v_filtros = TRIM(v_filtros) || " Grupo: " ||  TRIM(a_grupo);

	LET _tipo = sp_sis04(a_grupo);  -- Separa los Valores del String en una tabla de codigos

	IF _tipo <> "E" THEN -- (I) Incluir los Registros

		UPDATE tmp_siniest
		   SET seleccionado = 0
		 WHERE seleccionado = 1
		   AND cod_grupo NOT IN (SELECT codigo FROM tmp_codigos);

	ELSE		        -- (E) Excluir estos Registros

		UPDATE tmp_siniest
		   SET seleccionado = 0
		 WHERE seleccionado = 1
		   AND cod_grupo IN (SELECT codigo FROM tmp_codigos);

	END IF

	DROP TABLE tmp_codigos;

END IF

IF a_agente <> "*" THEN

	LET v_filtros = TRIM(v_filtros) || " Corredor: ";-- ||  TRIM(a_agente);

	LET _tipo = sp_sis04(a_agente);  -- Separa los Valores del String en una tabla de codigos

	IF _tipo <> "E" THEN -- (I) Incluir los Registros

		UPDATE tmp_siniest
		   SET seleccionado = 0
		 WHERE seleccionado = 1
		   AND cod_agente NOT IN (SELECT codigo FROM tmp_codigos);
	       LET v_saber = "";
	ELSE		        -- (E) Excluir estos Registros

		UPDATE tmp_siniest
		   SET seleccionado = 0
		 WHERE seleccionado = 1
		   AND cod_agente IN (SELECT codigo FROM tmp_codigos);
	       LET v_saber = "Ex";
	END IF

	 FOREACH
		SELECT agtagent.nombre,tmp_codigos.codigo
          INTO v_desc_agente,v_codigo
          FROM agtagent,tmp_codigos
         WHERE agtagent.cod_agente = codigo
         LET v_filtros = TRIM(v_filtros) || " " || TRIM(v_codigo) || " " || TRIM(v_desc_agente) || TRIM(v_saber);
	 END FOREACH

	DROP TABLE tmp_codigos;

END IF

FOREACH
 SELECT cod_ramo,
        cod_grupo, 
        SUM(prima_suscrita),   
		SUM(incurrido_bruto),  
		SUM(siniestro_pagado), 
		SUM(prima_pagada)     
   INTO	_cod_ramo,
        _cod_grupo, 
        v_prima_suscrita,   
		v_incurrido_bruto,  
		v_siniestro_pagado, 
		v_prima_pagada     
   FROM	tmp_siniest
  WHERE seleccionado = 1
  GROUP BY cod_grupo, cod_ramo
  ORDER BY cod_grupo, cod_ramo

	SELECT nombre
	  INTO v_ramo_nombre
	  FROM prdramo
	 WHERE cod_ramo = _cod_ramo;

	SELECT nombre
	  INTO v_grupo_nombre
	  FROM cligrupo
	 WHERE cod_grupo = _cod_grupo;

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
    		LET	v_porc_siniest = (v_incurrido_bruto / v_prima_suscrita)*100;
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
	    IF v_siniestro_pagado < 0 THEN
			LET v_porc_pagado = 0;
		ELSE
		  	LET	v_porc_pagado = (v_siniestro_pagado / v_prima_pagada)*100;
		END IF
	END IF

	RETURN v_ramo_nombre,
		   v_prima_suscrita,
		   v_incurrido_bruto,
		   v_porc_siniest,
		   v_prima_pagada,
		   v_siniestro_pagado,
		   v_porc_pagado,
		   v_grupo_nombre,
		   v_compania_nombre,
		   v_filtros
		   WITH RESUME;

END FOREACH

DROP TABLE tmp_siniest;

END PROCEDURE;
