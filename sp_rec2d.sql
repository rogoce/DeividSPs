-- Reporte de Reclamos Pendientes 'x' Dias sin Movimiento
--
-- Creado    : 08/08/2000 - Autor: Demetrio Hurtado Almanza
-- Modificado: 08/08/2000 - Autor: Demetrio Hurtado Almanza
-- Modificado: 27/06/2002 - Autor: Amado Perez M. (Se incluye filtro de agente)
--
-- SIS v.2.0 - d_sp_rec02d_dw4 - DEIVID, S.A.

DROP PROCEDURE sp_rec02d;

CREATE PROCEDURE "informix".sp_rec02d(a_compania CHAR(03),a_agencia CHAR(03),a_periodo CHAR(07),a_dias SMALLINT,a_sucursal CHAR(255) DEFAULT "*",a_ajustador CHAR(255) DEFAULT "*",a_ramo CHAR(255) DEFAULT "*",a_agente CHAR(255) DEFAULT "*")
RETURNING CHAR(18),CHAR(100),CHAR(20),DATE,DATE,DECIMAL(16,2),DECIMAL(16,2),DECIMAL(16,2),DECIMAL(16,2),DECIMAL(16,2),DECIMAL(16,2),CHAR(50),CHAR(50),CHAR(255);

DEFINE v_filtros         CHAR(255);

DEFINE v_doc_reclamo     CHAR(18);
DEFINE v_cliente_nombre  CHAR(100);
DEFINE v_doc_poliza      CHAR(20);
DEFINE v_fecha_siniestro DATE;
DEFINE v_ultima_fecha    DATE;
DEFINE v_pagado_bruto    DECIMAL(16,2);
DEFINE v_pagado_neto     DECIMAL(16,2);
DEFINE v_reserva_bruto   DECIMAL(16,2);
DEFINE v_reserva_neto    DECIMAL(16,2);
DEFINE v_incurrido_bruto DECIMAL(16,2);
DEFINE v_incurrido_neto  DECIMAL(16,2);
DEFINE v_ramo_nombre     CHAR(50);
DEFINE v_compania_nombre CHAR(50);

DEFINE _no_reclamo       CHAR(10);
DEFINE _no_poliza        CHAR(10);
DEFINE _cod_ramo         CHAR(3);
DEFINE _cod_cliente      CHAR(10);
DEFINE _periodo          CHAR(7); 

DEFINE _periodo1         DATE;
DEFINE _periodo2         DATE; 
DEFINE _mes_char,_ano_char SMALLINT;
DEFINE _dias             CHAR(2);
DEFINE _fecha_final      DATE;
DEFINE _dias_sin_mov     SMALLINT;

-- Obtener el Ultimo Dia del Periodo de Seleccion

LET _mes_char = a_periodo[6,7];
LET _ano_char = a_periodo[1,4];

IF _mes_char = 12 THEN
   LET _ano_char = _ano_char + 1;
ELSE
   LET _mes_char = _mes_char + 1;
END IF;
LET _fecha_final = (MDY(_mes_char,1,_ano_char) -1);

-- Nombre de la Compania

LET  v_compania_nombre = sp_sis01(a_compania);

-- Cargar el Incurrido

CALL sp_rec02(
a_compania, 
a_agencia, 
a_periodo,
a_sucursal,
a_ajustador,
'*',
a_ramo,
a_agente
) RETURNING v_filtros;

SET ISOLATION TO DIRTY READ;
FOREACH
 SELECT no_reclamo,
 		no_poliza,
 		pagado_bruto, 
 		pagado_neto,
	    reserva_bruto,
	    reserva_neto,	
	    incurrido_bruto,
	    incurrido_neto,
		cod_ramo,	
		periodo,
		numrecla,
		ultima_fecha
   INTO	_no_reclamo, 
   		_no_poliza,	
   		v_pagado_bruto, 
   		v_pagado_neto,
	    v_reserva_bruto,
	    v_reserva_neto, 
	    v_incurrido_bruto,
	    v_incurrido_neto,
		_cod_ramo,
		_periodo,
		v_doc_reclamo,
		v_ultima_fecha
   FROM tmp_sinis
  WHERE seleccionado = 1
  ORDER BY cod_ramo,numrecla

	LET _dias_sin_mov = _fecha_final - v_ultima_fecha;

	IF _dias_sin_mov >= a_dias THEN

		SELECT cod_reclamante,		fecha_siniestro
		  INTO _cod_cliente,		v_fecha_siniestro
		  FROM recrcmae
		 WHERE no_reclamo = _no_reclamo;

		SELECT nombre
		  INTO v_ramo_nombre
		  FROM prdramo
		 WHERE cod_ramo = _cod_ramo;

		SELECT no_documento
		  INTO v_doc_poliza
		  FROM emipomae
		 WHERE no_poliza = _no_poliza;

		SELECT nombre
		  INTO v_cliente_nombre
		  FROM cliclien
		 WHERE cod_cliente = _cod_cliente;

		RETURN v_doc_reclamo,
		 	   v_cliente_nombre, 
		 	   v_doc_poliza,	
		 	   v_fecha_siniestro,
			   v_ultima_fecha,
			   v_pagado_bruto,
			   v_pagado_neto,	
			   v_reserva_bruto, 
			   v_reserva_neto,
			   v_incurrido_bruto,	
			   v_incurrido_neto,
			   v_ramo_nombre,
			   v_compania_nombre,
			   v_filtros
			   WITH RESUME;

	END IF

END FOREACH

DROP TABLE tmp_sinis;

END PROCEDURE;
