-- Siniestralidad por Agente - Detalle Ramo
-- 
-- Creado    : 31/08/2000 - Autor: Demetrio Hurtado Almanza 
-- Modificado: 16/09/2000 - Autor: Demetrio Hurtado Almanza
--
-- SIS v.2.0 - d_recl_sp_rec16b_dw2 - DEIVID, S.A.

DROP PROCEDURE sp_rec16c;

CREATE PROCEDURE "informix".sp_rec16c(
a_compania CHAR(3),
a_agencia  CHAR(3),
a_periodo1 CHAR(7),
a_periodo2 CHAR(7),
a_sucursal CHAR(255),
a_agente   CHAR(255)
) RETURNING CHAR(50),	   -- Ramo
			DECIMAL(16,2), -- Prima Suscrita
			DECIMAL(16,2), -- Incurrido Bruto
			DECIMAL(16,2), -- % Siniestralidad 
			DECIMAL(16,2), -- Prima Pagada
			DECIMAL(16,2), -- Sinestros Pagados
			DECIMAL(16,2), -- % Pagado/Cobrado
			CHAR(50),	   -- Agente
			CHAR(50),	   -- Compania
			CHAR(255);	   -- Filtros

DEFINE v_filtros          CHAR(255);
DEFINE _tipo              CHAR(1);

DEFINE v_ramo_nombre      CHAR(50);     
DEFINE v_prima_suscrita   DECIMAL(16,2);
DEFINE v_incurrido_bruto  DECIMAL(16,2);
DEFINE v_porc_siniest     DECIMAL(16,2);
DEFINE v_siniestro_pagado DECIMAL(16,2);
DEFINE v_prima_pagada     DECIMAL(16,2);
DEFINE v_porc_pagado      DECIMAL(16,2);
DEFINE v_agente_nombre    CHAR(50);     
DEFINE v_compania_nombre  CHAR(50);  
DEFINE v_prima_devengada  DECIMAL(16,2);
DEFINE v_prima_dev_a      DECIMAL(16,2);
DEFINE v_prima_dev1       DECIMAL(16,2);
DEFINE v_perido	          CHAR(50);  
	 
   

DEFINE _cod_agente        CHAR(5);      
DEFINE _cod_ramo          CHAR(3);
DEFINE _no_poliza         CHAR(20);
DEFINE _no_documento      CHAR(20);      

-- Nombre de la Compania
LET  v_compania_nombre = sp_sis01(a_compania); 

-- Procedimiento que carga la Siniestralidad
-- por Agente

set isolation to dirty read;

CALL sp_rec16(
a_compania,
a_agencia,
a_periodo1,
a_periodo2
);

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

IF a_agente <> "*" THEN

	LET v_filtros = TRIM(v_filtros) || " Corredor: " ||  TRIM(a_agente);

	LET _tipo = sp_sis04(a_agente);  -- Separa los Valores del String en una tabla de codigos

	IF _tipo <> "E" THEN -- (I) Incluir los Registros

		UPDATE tmp_siniest
		   SET seleccionado = 0
		 WHERE seleccionado = 1
		   AND cod_agente NOT IN (SELECT codigo FROM tmp_codigos);

	ELSE		        -- (E) Excluir estos Registros

		UPDATE tmp_siniest
		   SET seleccionado = 0
		 WHERE seleccionado = 1
		   AND cod_agente IN (SELECT codigo FROM tmp_codigos);

	END IF

	DROP TABLE tmp_codigos;

END IF

FOREACH
 SELECT cod_agente, 
		cod_ramo,
        SUM(prima_suscrita),   
		SUM(incurrido_bruto),  
		SUM(siniestro_pagado), 
		SUM(prima_pagada)     
   INTO	_cod_agente, 
		_cod_ramo,
        v_prima_suscrita,   
		v_incurrido_bruto,  
		v_siniestro_pagado, 
		v_prima_pagada     
   FROM	tmp_siniest
  WHERE seleccionado = 1
  GROUP BY cod_agente, cod_ramo
  ORDER BY cod_agente, cod_ramo

	SELECT nombre
	  INTO v_agente_nombre
	  FROM agtagent
	 WHERE cod_agente = _cod_agente;

	 SELECT nombre
	  INTO v_ramo_nombre
	  FROM prdramo
	 WHERE cod_ramo = _cod_ramo;

	SELECT SUM(pri_dev_aa)
	  INTO v_prima_dev1
	  FROM tmp_dev1
	 WHERE cod_ramo   = _cod_ramo
	   AND cod_agente = _cod_agente;
	
	 -- Porcentaje de Siniestralidad

	IF v_prima_dev1 = 0 THEN
		IF v_incurrido_bruto = 0 THEN
			LET v_porc_siniest = 0;
		ELSE
			LET v_porc_siniest = 1;
		END IF
	ELSE
	   --LET v_porc_siniest = v_incurrido_bruto / v_prima_suscrita;
	   --LET v_porc_siniest = (v_incurrido_bruto / v_prima_suscrita)*100;
	   LET v_porc_siniest = (v_incurrido_bruto / v_prima_dev1) * 100;
	END IF

	-- Porcentaje de Pagado

	IF v_prima_pagada = 0 THEN
		IF v_siniestro_pagado = 0 THEN
			LET v_porc_pagado = 0;
		ELSE
			LET v_porc_pagado = 1;
		END IF
	ELSE
		--LET	v_porc_pagado = v_siniestro_pagado / v_prima_pagada;
		LET v_porc_pagado = (v_siniestro_pagado / v_prima_pagada) * 100;
	END IF
	
	RETURN v_ramo_nombre,
	       v_prima_dev1,
		   v_incurrido_bruto,
		   v_porc_siniest,
		   v_prima_pagada,
		   v_siniestro_pagado,
		   v_porc_pagado,
		   v_agente_nombre,
		   v_compania_nombre,
		   v_filtros
		   WITH RESUME;

END FOREACH

DROP TABLE tmp_siniest;
DROP TABLE tmp_dev1;

END PROCEDURE;

