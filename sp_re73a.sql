-- Siniestralidad por Ramo - Detalle Periodo  -- Concurso de Corredores
-- 
-- Creado: 13/08/2001 - Autor: Amado Perez
--
-- SIS v.2.0 - d_recl_sp_rec49a_dw1 - DEIVID, S.A.
-- SIS v.2.0 - d_recl_sp_rec49b_dw2 - DEIVID, S.A.


DROP PROCEDURE sp_rec73a;

CREATE PROCEDURE sp_rec73a(a_compania CHAR(3),a_agencia CHAR(3),a_periodo1 CHAR(7),a_periodo2 CHAR(7) ,a_sucursal CHAR(255),a_ramo CHAR(255),a_grupo CHAR(255)) 
RETURNING DECIMAL(16,2), -- Prima Suscrita
		  DECIMAL(16,2), -- Incurrido Bruto
		  DECIMAL(16,2), -- % Siniestralidad
		  DECIMAL(16,2), -- Prima Pagada
		  DECIMAL(16,2), -- Sinestros Pagados
		  DECIMAL(16,2), -- % Pagado/Cobrado
		  CHAR(3),       -- Cod_ramo
		  CHAR(50),	     -- Ramo
		  CHAR(3),	     -- Cod_subramo
		  CHAR(50),      -- Subramo
		  CHAR(50),      -- Agente
		  CHAR(50),	     -- Compania
		  CHAR(10),      -- _no_poliza
		  CHAR(20),      -- v_documento  
		  CHAR(10),
		  CHAR(18),
		  DATE,		     -- vigencia_inicial
		  DATE,		     -- vigencia_final
		  DATE,
		  DECIMAL(16,2), -- Monto a 30 dias
		  DECIMAL(16,2), -- Monto a 60 dias
		  DECIMAL(16,2), -- Monto a 90 dias
		  CHAR(255);     -- Filtros

DEFINE v_filtros          CHAR(255);
DEFINE _tipo              CHAR(1);

DEFINE v_subramo_nombre   CHAR(50); 
DEFINE v_prima_suscrita   DECIMAL(16,2);
DEFINE v_incurrido_bruto  DECIMAL(16,2);
DEFINE v_porc_siniest     DECIMAL(16,2);
DEFINE v_siniestro_pagado DECIMAL(16,2);
DEFINE v_prima_pagada     DECIMAL(16,2);
DEFINE v_porc_pagado      DECIMAL(16,2);
DEFINE v_monto_30         DECIMAL(16,2);
DEFINE v_monto_60         DECIMAL(16,2);
DEFINE v_monto_90         DECIMAL(16,2);
DEFINE v_ramo_nombre      CHAR(50);
DEFINE v_desc_grupo       CHAR(50);
DEFINE v_compania_nombre  CHAR(50);
DEFINE v_saber			  CHAR(2);
DEFINE v_desc_agente	  CHAR(50);
DEFINE v_codigo			  CHAR(5);
DEFINE v_documento        CHAR(20);
DEFINE v_numrecla         CHAR(18);
DEFINE v_vigencia_inicial DATE;
DEFINE v_vigencia_final   DATE;
DEFINE v_fecha_primer_pago DATE;

DEFINE _no_poliza, _no_reclamo  CHAR(10);
DEFINE _cod_ramo          CHAR(3);
DEFINE _periodo           CHAR(7); 
DEFINE _cod_subramo       CHAR(3);
DEFINE _cod_agente        CHAR(5);

SET ISOLATION TO DIRTY READ;

-- Nombre de la Compania

LET  v_compania_nombre = sp_sis01(a_compania);

-- Procedimiento que carga la Siniestralidad

--SET DEBUG FILE TO "\\nemesis\ancon\Store Procedures\Debug\sp_rec49a.trc";-- Nombre de la Compania
--TRACE ON;


CALL sp_rec73(
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

FOREACH
 SELECT cod_agente,
        cod_ramo,
        cod_subramo,
        prima_suscrita, 
		incurrido_bruto,
		siniestro_pagado, 
		prima_pagada,
		no_poliza,
		doc_poliza,
		no_reclamo,
		numrecla,
		monto_30,
		monto_60,
		monto_90
   INTO	_cod_agente,
   		_cod_ramo,
		_cod_subramo,
        v_prima_suscrita,
		v_incurrido_bruto, 
		v_siniestro_pagado,
		v_prima_pagada,
		_no_poliza,
		v_documento,
		_no_reclamo,
		v_numrecla,
		v_monto_30,
		v_monto_60,
		v_monto_90
   FROM	tmp_siniest
  WHERE seleccionado = 1
    AND siniestro_pagado <> 0  
  ORDER BY cod_ramo, cod_subramo, doc_poliza
--	AND (monto_30 <> 0 AND monto_60 <> 0 AND monto_90 <> 0)

--  GROUP BY cod_agente, cod_ramo, cod_subramo

	SELECT nombre
	  INTO v_ramo_nombre
	  FROM prdramo
	 WHERE cod_ramo = _cod_ramo;

	SELECT nombre
	  INTO v_subramo_nombre
	  FROM prdsubra
	 WHERE cod_ramo    = _cod_ramo
	   AND cod_subramo = _cod_subramo;

    SELECT nombre 
	  INTO v_desc_agente
	  FROM agtagent
	 WHERE cod_agente = _cod_agente;

	SELECT vigencia_inic,
	       vigencia_final,
		   fecha_primer_pago
	  INTO v_vigencia_inicial,
	       v_vigencia_final,
		   v_fecha_primer_pago
	  FROM emipomae
	 WHERE no_poliza = _no_poliza;

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
	       LET v_porc_pagado = (v_siniestro_pagado / v_prima_pagada)*100;
		END IF
	END IF

	RETURN v_prima_suscrita,
		   v_incurrido_bruto,
		   v_porc_siniest,
		   v_prima_pagada,
		   v_siniestro_pagado,
		   v_porc_pagado,
		   _cod_ramo,
		   v_ramo_nombre,
		   _cod_subramo,
		   v_subramo_nombre,
		   v_desc_agente,
		   v_compania_nombre,
		   _no_poliza,
		   v_documento,
		   _no_reclamo,
		   v_numrecla,
		   v_vigencia_inicial,
		   v_vigencia_final,  
		   v_fecha_primer_pago,
		   v_monto_30,
		   v_monto_60,
		   v_monto_90,
		   v_filtros
		   WITH RESUME;

END FOREACH

DROP TABLE tmp_siniest;

END PROCEDURE;
