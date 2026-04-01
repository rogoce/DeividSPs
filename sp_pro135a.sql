-- Perfil de Cartera Colectivo de Vida - Detalle  tomado del programa sp_rec49a
-- 
-- Creado: 15/12/2003 - Autor: Amado Perez
--
-- SIS v.2.0 - d_recl_sp_pro135_dw1 - DEIVID, S.A.


DROP PROCEDURE sp_pro135a;

CREATE PROCEDURE sp_pro135a(a_compania CHAR(3),a_agencia CHAR(3),a_fecha1 DATE) 
RETURNING DECIMAL(16,2), -- Prima Suscrita
		  DECIMAL(16,2), -- Suma Asegurada
		  DECIMAL(16,2), -- Incurrido Bruto
		  DECIMAL(16,2), -- % Siniestralidad
		  DECIMAL(16,2), -- Prima Pagada
		  DECIMAL(16,2), -- Sinestros Pagados
		  DECIMAL(16,2), -- % Pagado/Cobrado
		  CHAR(3),       -- Cod_ramo
		  CHAR(50),	     -- Ramo
		  CHAR(3),	     -- Cod_subramo
		  CHAR(50),      -- Subramo
		  CHAR(50),	     -- Compania
		  CHAR(10),      -- _no_poliza
		  CHAR(20),      -- v_documento  
		  DATE,		     -- vigencia_inicial
		  DATE,		     -- vigencia_final
		  DATE,
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
DEFINE v_monto_90         DECIMAL(16,2);
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
DEFINE v_suma_asegurada   DATE;

DEFINE _no_poliza         CHAR(10);
DEFINE _cod_ramo          CHAR(3);
DEFINE _periodo           CHAR(7); 
DEFINE _cod_subramo       CHAR(3);
DEFINE _cod_agente        CHAR(5);

SET ISOLATION TO DIRTY READ;

-- Nombre de la Compania

LET  v_compania_nombre = sp_sis01(a_compania);
LET  v_filtros = '';

-- Procedimiento que carga la Siniestralidad

--SET DEBUG FILE TO "\\nemesis\ancon\Store Procedures\Debug\sp_rec49a.trc";-- Nombre de la Compania
--TRACE ON;


CALL sp_pro135d(
a_compania,
a_agencia,
a_fecha1
);


FOREACH
 SELECT cod_ramo,
        cod_subramo,
        prima_suscrita, 
		suma_asegurada,
		incurrido_bruto,
		siniestro_pagado, 
		prima_pagada,
		no_poliza,
		doc_poliza,
		monto_90
   INTO	_cod_ramo,
		_cod_subramo,
        v_prima_suscrita,
		v_suma_asegurada,
		v_incurrido_bruto, 
		v_siniestro_pagado,
		v_prima_pagada,
		_no_poliza,
		v_documento,
		v_monto_90
   FROM	tmp_siniest
  WHERE seleccionado = 1
  ORDER BY cod_ramo, cod_subramo, doc_poliza

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

	SELECT vigencia_inic,
	       vigencia_final,
		   fecha_primer_pago
	  INTO v_vigencia_inicial,
	       v_vigencia_final,
		   v_fecha_primer_pago
	  FROM emipomae
	 WHERE no_poliza = _no_poliza;

	-- Porcentaje de Siniestralidad
	LET v_porc_siniest = 0;

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

 	LET v_porc_pagado = 0;

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
	       v_suma_asegurada,
		   v_incurrido_bruto,
		   v_porc_siniest,
		   v_prima_pagada,
		   v_siniestro_pagado,
		   v_porc_pagado,
		   _cod_ramo,
		   v_ramo_nombre,
		   _cod_subramo,
		   v_subramo_nombre,
		   v_compania_nombre,
		   _no_poliza,
		   v_documento,
		   v_vigencia_inicial,
		   v_vigencia_final,  
		   v_fecha_primer_pago,
		   v_monto_90,
		   v_filtros
		   WITH RESUME;

END FOREACH

DROP TABLE tmp_siniest;

END PROCEDURE;
