-- Siniestralidad por Ramo - Detalle Periodo  -- Concurso de Corredores
-- 
-- Creado: 13/08/2001 - Autor: Amado Perez
--
-- SIS v.2.0 - d_recl_sp_rec49a_dw1 - DEIVID, S.A.
-- SIS v.2.0 - d_recl_sp_rec49b_dw2 - DEIVID, S.A.


DROP PROCEDURE sp_rec491a;

CREATE PROCEDURE sp_rec491a(a_compania CHAR(3),a_agencia CHAR(3),a_periodo1 CHAR(7),a_periodo2 CHAR(7),a_fecha1 DATE ,a_sucursal CHAR(255),a_ramo CHAR(255),a_grupo CHAR(255),a_agente CHAR(255)) 
RETURNING CHAR(50),      -- Agente
		  CHAR(50),	     -- Ramo
		  CHAR(50),      -- Subramo
          CHAR(7),	     -- Periodo
		  CHAR(20),      -- v_documento  
		  DATE,		     -- vigencia_inicial
		  DATE,		     -- vigencia_final
          DECIMAL(16,2), -- Prima Suscrita
		  DECIMAL(16,2), -- Incurrido Bruto
		  DECIMAL(16,2), -- Prima Pagada
		  DECIMAL(16,2), -- Saldo Total
		  CHAR(15),		 -- Estatus
		  CHAR(7),		 -- Periodo Cancelacion
		  DECIMAL(16,2), -- Prima cancelacion
		  CHAR(50),	     -- Compania
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
DEFINE v_monto_90         DECIMAL(16,2);
DEFINE v_prima_cancelacion DECIMAL(16,2);
DEFINE v_saldo_tot        DEC(16,2);
DEFINE v_ramo_nombre      CHAR(50);
DEFINE v_desc_grupo       CHAR(50);
DEFINE v_compania_nombre  CHAR(50);
DEFINE v_saber			  CHAR(2);
DEFINE v_desc_agente	  CHAR(50);
DEFINE v_codigo			  CHAR(5);
DEFINE v_documento        CHAR(20);
DEFINE v_vigencia_inicial DATE;
DEFINE v_vigencia_final   DATE;
DEFINE v_fecha_primer_pago DATE;
DEFINE v_estatus          CHAR(15);
DEFINE v_periodo_cancelacion CHAR(7);

DEFINE _no_poliza         CHAR(10);
DEFINE _cod_ramo          CHAR(3);
DEFINE _periodo           CHAR(7); 
DEFINE _cod_subramo       CHAR(3);
DEFINE _cod_agente        CHAR(5);
DEFINE _fecha_cancelacion DATE;
DEFINE _vigencia_final 	  DATE;

SET ISOLATION TO DIRTY READ;

-- Nombre de la Compania

LET  v_compania_nombre = sp_sis01(a_compania);

-- Procedimiento que carga la Siniestralidad

--SET DEBUG FILE TO "\\nemesis\ancon\Store Procedures\Debug\sp_rec49a.trc";-- Nombre de la Compania
--TRACE ON;


CALL sp_rec491(
a_compania,
a_agencia,
a_periodo1,
a_periodo2,
a_fecha1
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

FOREACH
 SELECT cod_agente,
        cod_ramo,
        cod_subramo,
        periodo,
        prima_suscrita, 
		incurrido_bruto,
		siniestro_pagado, 
		prima_pagada,
		no_poliza,
		doc_poliza,
		monto_90,
		saldo_tot
   INTO	_cod_agente,
   		_cod_ramo,
		_cod_subramo,
        _periodo, 
        v_prima_suscrita,
		v_incurrido_bruto, 
		v_siniestro_pagado,
		v_prima_pagada,
		_no_poliza,
		v_documento,
		v_monto_90,
		v_saldo_tot
   FROM	tmp_siniest
  WHERE seleccionado = 1
  ORDER BY cod_agente, cod_ramo, cod_subramo, periodo, doc_poliza

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

	LET _fecha_cancelacion = NULL;

	FOREACH
		SELECT vigencia_inic,
			   vigencia_final,
			   fecha_primer_pago
		  INTO v_vigencia_inicial,
			   v_vigencia_final,
			   v_fecha_primer_pago
		  FROM emipomae
		 WHERE no_documento = v_documento
		 ORDER BY vigencia_inic ASC   
		 EXIT FOREACH;
	END FOREACH

	FOREACH
		SELECT vigencia_final
		  INTO _vigencia_final
		  FROM emipomae
		 WHERE no_documento = v_documento
		 ORDER BY vigencia_final desc   
		 EXIT FOREACH;
	END FOREACH

	SELECT fecha_cancelacion
	  INTO _fecha_cancelacion
	  FROM emipomae
	 WHERE no_poliza = _no_poliza;

	LET v_estatus = 'Vigente';
	LET v_prima_cancelacion = 0;
	LET v_periodo_cancelacion = '';

    IF _fecha_cancelacion IS NOT NULL THEN
	   IF _fecha_cancelacion <= '29/11/2002' THEN
	      LET v_estatus = 'Cancelada';
		  FOREACH
			  SELECT prima_suscrita,
			         periodo
				INTO v_prima_cancelacion,
				     v_periodo_cancelacion
				FROM endedmae
			   WHERE no_poliza = _no_poliza
			     AND cod_endomov = '002'
			  EXIT FOREACH;
		  END FOREACH
	   ELSE
	      IF _vigencia_final < '29/11/2002' THEN
		     LET v_estatus = 'Vencida';
		  END IF
	   END IF
	ELSE
       IF _vigencia_final < '29/11/2002' THEN
	      LET v_estatus = 'Vencida';
	   END IF
	END IF

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

	RETURN v_desc_agente,
		   v_ramo_nombre,
		   v_subramo_nombre,
	       _periodo,
		   v_documento,
		   v_vigencia_inicial,
		   v_vigencia_final,  
	       v_prima_suscrita,
		   v_incurrido_bruto,
		   v_prima_pagada,
		   v_saldo_tot,
		   v_estatus,
		   v_periodo_cancelacion,
		   v_prima_cancelacion,
		   v_compania_nombre,
		   v_filtros
		   WITH RESUME;

END FOREACH

DROP TABLE tmp_siniest;

END PROCEDURE;
