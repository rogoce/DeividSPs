e-- Cobros Totales por Ramo

-- Creado    : 14/02/2003 - Autor: Amado Perez
-- Modificado: 
--
-- SIS v.2.0 - d_cobr_sp_cob08e_dw5 - DEIVID, S.A.

DROP PROCEDURE sp_cob08g;

CREATE PROCEDURE "informix".sp_cob08g(
a_compania CHAR(3), 
a_agencia  CHAR(3), 
a_periodo1 CHAR(7),
a_periodo2 CHAR(7),
a_sucursal CHAR(255) DEFAULT '*',
a_cobrador CHAR(255) DEFAULT '*',
a_agente   CHAR(255) DEFAULT '*',
a_ramo     CHAR(255) DEFAULT '*',
a_formapago CHAR(255) DEFAULT '*'
) RETURNING CHAR(100), -- Asegurado
			CHAR(20),  -- Poliza	
			CHAR(1),   -- Estatus	
			CHAR(2),   -- Forma Pago
			DATE,      -- Vigencia Inicial
			DATE,      -- Vigencia Final
			DEC(16,2), -- Prima Pagada
			DEC(16,2), -- Por Vencer
			DEC(16,2), -- Exigible
			DEC(16,2), -- Corriente
			DEC(16,2), -- Dias 30
			DEC(16,2), -- Dias 60
			DEC(16,2), -- Dias 90
			CHAR(50),  -- Nombre Agente
			CHAR(50),  -- Nombre Cobrador
			CHAR(50),  -- Nombre Compania
			CHAR(255); -- Filtros

DEFINE v_filtros           CHAR(255);
DEFINE _tipo               CHAR(1);

DEFINE v_nombre_cliente    CHAR(100);
DEFINE v_doc_poliza        CHAR(20); 
DEFINE _no_poliza          CHAR(10); 
DEFINE v_estatus           CHAR(1); 
DEFINE v_forma_pago        CHAR(2);
DEFINE v_vigencia_inic     DATE;     
DEFINE v_vigencia_final    DATE;     
DEFINE v_monto_pagado      DEC(16,2);
DEFINE v_por_vencer        DEC(16,2);
DEFINE v_exigible          DEC(16,2);
DEFINE v_corriente         DEC(16,2);
DEFINE v_monto_30          DEC(16,2);
DEFINE v_monto_60          DEC(16,2);
DEFINE v_monto_90          DEC(16,2);
DEFINE v_nombre_agente     CHAR(50);
DEFINE v_nombre_cobrador   CHAR(50);
DEFINE v_compania_nombre   CHAR(50);

DEFINE _cod_cobrador       CHAR(3);

-- Nombre de la Compania

LET  v_compania_nombre = sp_sis01(a_compania); 

-- Procedimiento que carga la Morosidad por Agente

CALL sp_cob08(
a_compania,
a_agencia,
a_periodo1,
a_periodo2
);

update tmp_moros
   set seleccionado = 0;

update tmp_moros
   set seleccionado = 1
 where cod_sucursal = "002";

update tmp_moros
   set seleccionado = 0
 where cod_agente in ("00801", "00650", "00678", "00687", "00745", "00752", "00133", "00234", "00271", "00821", "00823", "00860", "00875");
        	
-- Procesos para Filtros

LET v_filtros = "";


FOREACH
 SELECT	nombre_cliente, 
		doc_poliza,     
		estatus,        
		forma_pago,     
		vigencia_inic,  
		vigencia_final, 
		monto_pagado,    
		por_vencer,     
		exigible,       
		corriente,     
		monto_30,       
		monto_60,       
		monto_90,
		nombre_agente,
		cod_cobrador,
		no_poliza
   INTO	v_nombre_cliente, 
		v_doc_poliza,     
		v_estatus,        
		v_forma_pago,     
		v_vigencia_inic,  
		v_vigencia_final, 
		v_monto_pagado,    
		v_por_vencer,     
		v_exigible,       
		v_corriente,     
		v_monto_30,       
		v_monto_60,       
		v_monto_90,
		v_nombre_agente,
		_cod_cobrador,
		_no_poliza
   FROM	tmp_moros
  WHERE seleccionado = 1
  ORDER BY cod_cobrador, nombre_agente, nombre_cliente, doc_poliza, vigencia_inic

	SELECT nombre
	  INTO v_nombre_cobrador
	  FROM cobcobra
	 WHERE cod_cobrador = _cod_cobrador;

	IF v_estatus = "2" THEN --cancelada
		SELECT fecha_cancelacion
		  INTO v_vigencia_final
		  FROM emipomae
		 WHERE no_poliza = _no_poliza
		   AND actualizado = 1;
	END IF

	RETURN 	v_nombre_cliente, 
			v_doc_poliza,     
			v_estatus,        
			v_forma_pago,     
			v_vigencia_inic,  
			v_vigencia_final, 
			v_monto_pagado,    
			v_por_vencer,     
			v_exigible,       
			v_corriente,     
			v_monto_30,       
			v_monto_60,       
			v_monto_90,
			v_nombre_agente,
			v_nombre_cobrador,
		    v_compania_nombre,
		    v_filtros
			WITH RESUME;

END FOREACH		 
DROP TABLE tmp_moros;
END PROCEDURE;

