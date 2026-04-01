-- Siniestralidad por Ramo - Detalle Subramo
-- 
-- Creado    : 30/08/2000 - Autor: Demetrio Hurtado Almanza
-- Modificado: 16/09/2000 - Autor: Demetrio Hurtado Almanza
--
-- SIS v.2.0 - d_recl_sp_rec14b_dw2 - DEIVID, S.A.

--DROP PROCEDURE sp_rec14l;

CREATE PROCEDURE sp_rec14l(a_compania CHAR(3),a_agencia CHAR(3),a_periodo1 CHAR(7),a_periodo2 CHAR(7),a_sucursal CHAR(255),a_ramo CHAR(255),a_grupo CHAR(255),a_agente CHAR(255)) 
RETURNING CHAR(50),	   -- Subramo
          CHAR(20),    -- Doc_poliza
		  CHAR(100),   -- Asegurado
		  DECIMAL(16,2), -- Prima Pagada
		  DECIMAL(16,2), -- Sinestros Pagados
		  DECIMAL(16,2), -- Comision
		  DECIMAL(16,2), -- % Comision
		  CHAR(50),	   -- Ramo
		  CHAR(50),	   -- Compania
		  CHAR(255);   -- Filtros

DEFINE v_filtros          CHAR(255);
DEFINE _tipo              CHAR(1);

DEFINE v_subramo_nombre   CHAR(50); 
DEFINE v_prima_suscrita   DECIMAL(16,2);
DEFINE v_incurrido_bruto  DECIMAL(16,2);
DEFINE v_porc_siniest     DECIMAL(16,2);
DEFINE v_siniestro_pagado DECIMAL(16,2);
DEFINE v_prima_pagada     DECIMAL(16,2);
DEFINE v_porc_pagado      DECIMAL(16,2);
DEFINE v_ramo_nombre      CHAR(50);
DEFINE v_desc_grupo       CHAR(50);
DEFINE v_compania_nombre  CHAR(50);
DEFINE v_saber			  CHAR(2);
DEFINE v_desc_agente	  CHAR(50);
DEFINE v_codigo			  CHAR(5);
DEFINE v_doc_poliza       CHAR(20);
DEFINE v_asegurado        CHAR(100);
DEFINE v_porc_comis_agt	  DEC(16,2);
DEFINE v_comision         DEC(16,2);
define l_cant             int;
define _leasing           smallint;


DEFINE _cod_ramo          CHAR(3);
DEFINE _cod_subramo       CHAR(3); 
DEFINE _cod_agente        CHAR(5);
DEFINE _no_poliza         CHAR(10);
DEFINE _cod_pagador       CHAR(10);
DEFINE _porc_partic_agt   DEC(16,2);

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
 SELECT cod_ramo,
        cod_subramo,
		cod_agente,
		no_poliza,
		doc_poliza,
        prima_suscrita, 
		incurrido_bruto,
		siniestro_pagado, 
		prima_pagada
   INTO	_cod_ramo,
        _cod_subramo, 
		_cod_agente,
		_no_poliza,
		v_doc_poliza,
        v_prima_suscrita,
		v_incurrido_bruto, 
		v_siniestro_pagado,
		v_prima_pagada 
   FROM	tmp_siniest
  WHERE seleccionado = 1
  ORDER BY cod_ramo, cod_subramo, doc_poliza

	SELECT nombre
	  INTO v_ramo_nombre
	  FROM prdramo
	 WHERE cod_ramo = _cod_ramo;

	SELECT nombre
	  INTO v_subramo_nombre
	  FROM prdsubra
	 WHERE cod_ramo    = _cod_ramo
	   AND cod_subramo = _cod_subramo;

    -- Asegurado

	SELECT cod_pagador, leasing
	  INTO _cod_pagador, _leasing
	  FROM emipomae
	 WHERE no_poliza = _no_poliza;

    {if _leasing = 1 then  -- especial de sabish
	   let l_cant = 0;
	   select count(*)
	     into l_cant
		 from emipouni
	    WHERE no_poliza = _no_poliza
	      and cod_asegurado = '84250'; -- Pacific leasing
	   if l_cant = 0 then
	   	continue foreach;
	   end if
    else
	   	continue foreach;
	end if 
	}
	SELECT nombre
	  INTO v_asegurado
	  FROM cliclien
	 WHERE cod_cliente = _cod_pagador;

    -- Comision y % de comision


	SELECT porc_partic_agt,
	       porc_comis_agt
	  INTO _porc_partic_agt,
		   v_porc_comis_agt
	  FROM emipoagt
	 WHERE cod_agente = _cod_agente
	   AND no_poliza = _no_poliza;

	 LET v_comision = v_prima_pagada * _porc_partic_agt / 100 * v_porc_comis_agt / 100;

	RETURN v_subramo_nombre,
	       v_doc_poliza,
		   v_asegurado,
		   v_prima_pagada,
		   v_siniestro_pagado,
		   v_comision,
		   v_porc_comis_agt,
		   v_ramo_nombre,
		   v_compania_nombre,
		   v_filtros
		   WITH RESUME;

END FOREACH

DROP TABLE tmp_siniest;

END PROCEDURE;
