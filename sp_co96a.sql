-- Flujo de caja por Ramo
-- 
-- Creado: 22/01/2003 - Autor: Armando Moreno M.

DROP PROCEDURE sp_co96a;

CREATE PROCEDURE sp_co96a(
a_compania CHAR(3),
a_agencia  CHAR(3),
a_periodo1 CHAR(7),
a_periodo2 CHAR(7),
a_ramo     CHAR(255)
)
RETURNING DECIMAL(16,2), -- Prima Pagada
		  DECIMAL(16,2), -- Sinestros Pagados
		  CHAR(3),       -- Cod_ramo
		  CHAR(50),	     -- Compania
		  DECIMAL(16,2), -- Comision pagada
		  DECIMAL(16,2), -- Gastos Manejo
		  DECIMAL(16,2), -- Gastos Admin.
		  DECIMAL(16,2), -- Total egresos
		  DECIMAL(16,2), -- Flujo Neto
		  CHAR(50),	     -- Ramo
		  CHAR(255),     -- Filtros
		  CHAR(10);		 -- no_poliza	

DEFINE v_filtros          CHAR(255);
DEFINE _tipo              CHAR(1);
DEFINE _gastos_m  		  DECIMAL(16,2);
DEFINE _gastos_a  		  DECIMAL(16,2);
DEFINE v_porc_siniest     DECIMAL(16,2);
DEFINE v_siniestro_pagado DECIMAL(16,2);
DEFINE v_prima_pagada     DECIMAL(16,2);
DEFINE v_porc_pagado      DECIMAL(16,2);
DEFINE _comision,_flujo_neto          DECIMAL(16,2);
DEFINE _total_egresos     DECIMAL(16,2);
DEFINE v_ramo_nombre      CHAR(50);
DEFINE v_desc_grupo       CHAR(50);
DEFINE v_compania_nombre  CHAR(50);
DEFINE v_saber			  CHAR(2);
DEFINE v_codigo			  CHAR(5);
DEFINE v_documento        CHAR(20);
DEFINE v_vigencia_inicial DATE;
DEFINE v_vigencia_final   DATE;
DEFINE v_fecha_primer_pago DATE;
DEFINE _gastos_manejo,_gastos_admin  INT; 
DEFINE _no_poliza         CHAR(10);
DEFINE _cod_ramo          CHAR(3);
DEFINE _periodo           CHAR(7); 
DEFINE _cod_subramo       CHAR(3);
DEFINE _cod_agente        CHAR(5);

SET ISOLATION TO DIRTY READ;

-- Nombre de la Compania

LET  v_compania_nombre = sp_sis01(a_compania);

CALL sp_cob96(
a_compania,
a_agencia,
a_periodo1,
a_periodo2
);

-- Procesos para Filtros

LET v_filtros = "";

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

FOREACH
 SELECT cod_ramo,
		siniestro_pagado,
		prima_pagada,
		no_poliza,
		comision
   INTO	_cod_ramo,
		v_siniestro_pagado,
		v_prima_pagada,
		_no_poliza,
		_comision
   FROM	tmp_siniest
  WHERE seleccionado = 1
  ORDER BY cod_ramo

	SELECT nombre
	  INTO v_ramo_nombre
	  FROM prdramo
	 WHERE cod_ramo = _cod_ramo;

	SELECT gastos_manejo,
		   gastos_admin
	  INTO _gastos_manejo,
		   _gastos_admin
	  FROM cobflura
	 WHERE cod_ramo = _cod_ramo;

	 LET _gastos_m      = v_prima_pagada * _gastos_manejo / 100;
	 LET _gastos_a      = v_prima_pagada * _gastos_admin / 100;
     LET _total_egresos = _comision + v_siniestro_pagado + _gastos_m + _gastos_a;
	 LET _flujo_neto    = v_prima_pagada - _total_egresos;

	RETURN v_prima_pagada,
		   v_siniestro_pagado,
		   _cod_ramo,
		   v_compania_nombre,
		   _comision,
		   _gastos_m,
		   _gastos_a,
		   _total_egresos,
		   _flujo_neto,
		   v_ramo_nombre,
		   v_filtros,
		   _no_poliza
		   WITH RESUME;

END FOREACH

DROP TABLE tmp_siniest;

END PROCEDURE;
