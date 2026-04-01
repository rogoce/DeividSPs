-- Siniestralidad por Fronting 
-- 
-- Creado    : 12/09/2000 - Autor: Demetrio Hurtado Almanza 
-- Modificado: 16/09/2000 - Autor: Demetrio Hurtado Almanza
--
-- SIS v.2.0 - d_recl_sp_rec14h_dw8 - DEIVID, S.A.

DROP PROCEDURE sp_rec14h;

CREATE PROCEDURE "informix".sp_rec14h(
a_compania CHAR(3),
a_agencia  CHAR(3),
a_periodo1 CHAR(7),
a_periodo2 CHAR(7),
a_sucursal CHAR(255)
) RETURNING CHAR(50),	   -- Contrato
			DECIMAL(16,2), -- Prima Suscrita
			DECIMAL(16,2), -- Incurrido Bruto
			DECIMAL(16,2), -- % Siniestralidad 
			DECIMAL(16,2), -- Prima Pagada
			DECIMAL(16,2), -- Sinestros Pagados
			DECIMAL(16,2), -- % Pagado/Cobrado
			CHAR(50),	   -- Compania
			CHAR(255);	   -- Filtros

DEFINE v_filtros          CHAR(255);
DEFINE _tipo              CHAR(1);

DEFINE v_contrato_nombre  CHAR(50);     
DEFINE v_prima_suscrita   DECIMAL(16,2);
DEFINE v_incurrido_bruto  DECIMAL(16,2);
DEFINE v_porc_siniest     DECIMAL(16,2);
DEFINE v_siniestro_pagado DECIMAL(16,2);
DEFINE v_prima_pagada     DECIMAL(16,2);
DEFINE v_porc_pagado      DECIMAL(16,2);
DEFINE v_compania_nombre  CHAR(50);     

DEFINE _no_poliza         CHAR(10);
DEFINE _cod_contrato      CHAR(5);
DEFINE _tipo_contrato     SMALLINT;

-- Nombre de la Compania

LET  v_compania_nombre = sp_sis01(a_compania); 

-- Procedimiento que carga la Siniestralidad

--DROP TABLE tmp_siniest;

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

FOREACH
 SELECT	no_poliza
   INTO	_no_poliza
   FROM	tmp_siniest
  WHERE seleccionado = 1

	FOREACH
	 SELECT	cod_contrato
	   INTO	_cod_contrato
	   FROM	emifacon
	  WHERE no_poliza = _no_poliza
	    AND no_endoso = 0

		SELECT tipo_contrato
		  INTO _tipo_contrato
		  FROM reacomae
		 WHERE cod_contrato = _cod_contrato;

		IF _tipo_contrato = 2 THEN

			UPDATE tmp_siniest
			   SET cod_contrato = _cod_contrato,
			       fronting     = 1
			WHERE no_poliza     = _no_poliza;

			EXIT FOREACH;		

		END IF

	END FOREACH

END FOREACH

FOREACH
 SELECT cod_contrato, 
        SUM(prima_suscrita),   
		SUM(incurrido_bruto),  
		SUM(siniestro_pagado), 
		SUM(prima_pagada)     
   INTO	_cod_contrato, 
        v_prima_suscrita,   
		v_incurrido_bruto,  
		v_siniestro_pagado, 
		v_prima_pagada     
   FROM	tmp_siniest
  WHERE seleccionado = 1
    AND fronting     = 1
  GROUP BY cod_contrato
  ORDER BY cod_contrato

	SELECT nombre
	  INTO v_contrato_nombre
	  FROM reacomae
	 WHERE cod_contrato = _cod_contrato;

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

	RETURN v_contrato_nombre,
	       v_prima_suscrita,
		   v_incurrido_bruto,
		   v_porc_siniest,
		   v_prima_pagada,
		   v_siniestro_pagado,
		   v_porc_pagado,
		   v_compania_nombre,
		   v_filtros
		   WITH RESUME;

END FOREACH

DROP TABLE tmp_siniest;

END PROCEDURE;
