-- Siniestralidad por Ramo - Detalle Subramo
-- 
-- Creado    : 30/08/2000 - Autor: Demetrio Hurtado Almanza
-- Modificado: 06/07/2001 - Autor: Lic. Amado Perez
-- Modificado: 12/08/2002 - Autor: Amado Perez Mendoza -- Se incluyen la Comision de Prima Suscrita
--                                                        y Comision de Prima Pagada, % de comision de
--                                                        prima suscrita y el % de comision de prima pagada
--
-- SIS v.2.0 - d_recl_sp_rec14b_dw2 - DEIVID, S.A.

DROP PROCEDURE sp_rec14o;


CREATE PROCEDURE sp_rec14o(a_compania CHAR(3),a_agencia CHAR(3),a_periodo1 CHAR(7),a_periodo2 CHAR(7),a_sucursal CHAR(255),a_ramo CHAR(255),a_grupo CHAR(255),a_agente CHAR(255),a_cliente  CHAR(255) DEFAULT '*') 
RETURNING CHAR(50),	     -- Subramo
          DECIMAL(16,2), -- Prima Suscrita
		  DECIMAL(16,2), -- Comision de Prima Suscrita
		  DECIMAL(16,1), -- % Comision de Prima Suscrita
		  DECIMAL(16,2), -- Incurrido Bruto
		  DECIMAL(16,2), -- % Siniestralidad
		  DECIMAL(16,2), -- Prima Pagada
  		  DECIMAL(16,2), -- Comision de Prima Pagada
		  DECIMAL(16,1), -- % Comision de Prima Pagada
		  DECIMAL(16,2), -- Sinestros Pagados
		  DECIMAL(16,2), -- % Pagado/Cobrado
		  CHAR(50),	   -- Ramo
		  CHAR(50),	   -- Compania
		  CHAR(255);   -- Filtros

DEFINE v_filtros          CHAR(255);
DEFINE _tipo              CHAR(1);

DEFINE v_subramo_nombre   CHAR(50); 
DEFINE v_prima_suscrita   DECIMAL(16,2);
DEFINE v_comis_suscrita   DECIMAL(16,2);
DEFINE v_incurrido_bruto  DECIMAL(16,2);
DEFINE v_porc_siniest     DECIMAL(16,2);
DEFINE v_porc_comis_sus   DECIMAL(16,1);
DEFINE v_porc_comis_pag   DECIMAL(16,1);
DEFINE v_siniestro_pagado DECIMAL(16,2);
DEFINE v_prima_pagada     DECIMAL(16,2);
DEFINE v_comis_pagada     DECIMAL(16,2);
DEFINE v_porc_pagado      DECIMAL(16,2);
DEFINE v_ramo_nombre      CHAR(50);
DEFINE v_desc_grupo       CHAR(50);
DEFINE v_compania_nombre  CHAR(50);
DEFINE v_saber			  CHAR(2);
DEFINE v_desc_agente	  CHAR(50);
DEFINE v_codigo			  CHAR(5);
DEFINE v_desc_cliente     CHAR(100);
DEFINE v_prima_dev1       DEC(16,2);

DEFINE _cod_ramo          CHAR(3);
DEFINE _cod_subramo       CHAR(3); 

SET ISOLATION TO DIRTY READ;

-- Nombre de la Compania

LET  v_compania_nombre = sp_sis01(a_compania);

-- Procedimiento que carga la Siniestralidad

CALL sp_rec14(
a_compania,
a_agencia,
a_periodo1,
a_periodo2
);

-- Procedimiento de Primas devengadas
CALL sp_bo084b(a_periodo2);

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

IF a_grupo <> "*" THEN

	LET v_filtros = TRIM(v_filtros) || " Grupo: "; --|| TRIM(a_grupo);

	LET _tipo = sp_sis04(a_grupo);  -- Separa los Valores del String en una tabla de codigos

	IF _tipo <> "E" THEN -- (I) Incluir los Registros

		UPDATE tmp_siniest
		   SET seleccionado = 0
		 WHERE seleccionado = 1
		   AND cod_grupo NOT IN (SELECT codigo FROM tmp_codigos);
	       LET v_saber = "";
	ELSE		        -- (E) Excluir estos Registros

		UPDATE tmp_siniest
		   SET seleccionado = 0
		 WHERE seleccionado = 1
		   AND cod_grupo IN (SELECT codigo FROM tmp_codigos);
	       LET v_saber = " Ex";
	END IF
    FOREACH
		SELECT cligrupo.nombre,tmp_codigos.codigo
	      INTO v_desc_grupo,v_codigo
	      FROM cligrupo,tmp_codigos
	     WHERE cligrupo.cod_grupo = codigo
	     LET v_filtros = TRIM(v_filtros) || " " || TRIM(v_codigo) || " " || TRIM(v_desc_grupo) || (v_saber);
    END FOREACH

	DROP TABLE tmp_codigos;

END IF

IF a_agente <> "*" THEN

	LET v_filtros = TRIM(v_filtros) || " Corredor: "; --|| TRIM(a_agente);

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
	       LET v_saber = " Ex";
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

IF a_cliente <> "*" THEN

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

	 FOREACH
		SELECT x.nombre, y.codigo
          INTO v_desc_cliente,v_codigo
          FROM cliclien x,tmp_codigos y
         WHERE x.cod_cliente = codigo
         LET v_filtros = TRIM(v_filtros) || " " || TRIM(v_codigo) || " " || TRIM(v_desc_cliente) || TRIM(v_saber);
	 END FOREACH

	DROP TABLE tmp_codigos;

END IF


FOREACH
 SELECT cod_ramo,
        cod_subramo,
        SUM(prima_suscrita), 
		SUM(comis_suscrita),
		SUM(incurrido_bruto),
		SUM(siniestro_pagado), 
		SUM(prima_pagada),
		SUM(comis_pagada)
   INTO	_cod_ramo,
        _cod_subramo, 
        v_prima_suscrita,
		v_comis_suscrita,
		v_incurrido_bruto, 
		v_siniestro_pagado,
		v_prima_pagada, 
		v_comis_pagada 
   FROM	tmp_siniest
  WHERE seleccionado = 1
  GROUP BY cod_ramo, cod_subramo
  ORDER BY cod_ramo, cod_subramo

	SELECT nombre
	  INTO v_ramo_nombre
	  FROM prdramo
	 WHERE cod_ramo = _cod_ramo;

	SELECT nombre
	  INTO v_subramo_nombre
	  FROM prdsubra
	 WHERE cod_ramo    = _cod_ramo
	   AND cod_subramo = _cod_subramo;

	SELECT SUM(pri_dev_aa)
	  INTO v_prima_dev1
	  FROM tmp_dev1
	 WHERE cod_ramo  = _cod_ramo
	   AND cod_subramo = _cod_subramo;
	   
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

	-- Porcentaje de Comision de Prima Suscrita

	IF v_prima_suscrita = 0 THEN
		IF v_comis_suscrita = 0 THEN
			LET v_porc_comis_sus = 0;
		ELSE
			LET v_porc_comis_sus = 100;
		END IF
	ELSE
        LET	v_porc_comis_sus = (v_comis_suscrita / v_prima_suscrita)*100;
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
	       LET v_porc_pagado = (v_siniestro_pagado / v_prima_pagada)*100;
		END IF
	END IF

	-- Porcentaje de Comision de Prima Pagada

	IF v_prima_pagada = 0 THEN
		IF v_comis_pagada = 0 THEN
			LET v_porc_comis_pag = 0;
		ELSE
			LET v_porc_comis_pag = 100;
		END IF
	ELSE
	    LET	v_porc_comis_pag = (v_comis_pagada / v_prima_pagada)*100;
	END IF
	
		IF v_prima_dev1 IS NULL THEN 
		   LET v_prima_dev1 = 0;
		END IF

	RETURN v_subramo_nombre,
	       v_prima_dev1,
		   v_comis_suscrita,
		   v_porc_comis_sus,
		   v_incurrido_bruto,
		   v_porc_siniest,
		   v_prima_pagada,
		   v_comis_pagada,
		   v_porc_comis_pag,
		   v_siniestro_pagado,
		   v_porc_pagado,
		   v_ramo_nombre,
		   v_compania_nombre,
		   v_filtros
		   WITH RESUME;

END FOREACH

DROP TABLE tmp_siniest;
DROP TABLE tmp_dev1;

END PROCEDURE;
