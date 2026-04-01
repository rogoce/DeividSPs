-- Reporte de las Comisiones por Corredor - Detallado
-- Creado    : 07/12/2017 - Autor: Federico Coronado

-- SIS v.2.0 - d_cheq_sp_che03_dw1 - DEIVID, S.A.

DROP PROCEDURE sp_web47;

CREATE PROCEDURE sp_web47(a_compania CHAR(3), a_cod_agente CHAR(5), a_fecha_desde date, a_fecha_hasta date) 
  RETURNING CHAR(20),	-- Poliza
			CHAR(100),	-- Asegurado
			CHAR(50),   -- Cedula ruc
			CHAR(10),	-- Recibo
			DATE,		-- Fecha
			DEC(16,2),	-- Monto
			DEC(16,2),	-- Prima
			DEC(5,2),	-- % Partic
			DEC(5,2),	-- % Comis
			DEC(16,2),	-- Comision
			CHAR(50),   -- Agente
			CHAR(50),   -- Compania
			DATE,		-- Vigencia_inic
			DATE,		-- Vigencia_final
			char(2),    -- Pago directo
			date;

DEFINE _tipo          	CHAR(1);

DEFINE v_cod_agente   	CHAR(5);  
DEFINE v_no_poliza    	CHAR(10); 
DEFINE v_monto        	DEC(16,2);
DEFINE v_no_recibo    	CHAR(10); 
DEFINE v_fecha       	DATE;     
DEFINE v_prima        	DEC(16,2);
DEFINE v_porc_partic  	DEC(5,2); 
DEFINE v_porc_comis   	DEC(5,2); 
DEFINE v_comision     	DEC(16,2);
DEFINE v_nombre_clte  	CHAR(100);
DEFINE v_no_documento 	CHAR(20);
DEFINE v_nombre_agt   	CHAR(50);
DEFINE v_nombre_cia   	CHAR(50);
DEFINE v_vig_desde  	DATE;
DEFINE v_vig_hasta  	DATE;
DEFINE v_fecha_comis   	DATE;
DEFINE _cod_cliente  	CHAR(10);
DEFINE v_cedula_ruc     CHAR(30);
DEFINE v_pago_directo   CHAR(2);
define v_fecha_pagada   date;

--SET DEBUG FILE TO "\\NEMESIS\Ancon\Store Procedures\Debug\sp_che03c.trc";
--TRACE ON;

-- Nombre de la Compania
SET ISOLATION TO DIRTY READ;

LET  v_nombre_cia = sp_sis01(a_compania); 

SET ISOLATION TO DIRTY READ;
	
FOREACH
 /*SELECT	cod_agente,
 		no_poliza,
		no_recibo,
		fecha,
		monto,
		prima,
		porc_partic,
		porc_comis,
		comision,
		nombre,
		no_documento
   INTO	v_cod_agente,
   		v_no_poliza,
		v_no_recibo,
		v_fecha,
		v_monto,
		v_prima,
		v_porc_partic,
		v_porc_comis,
		v_comision,
		v_nombre_agt,
		v_no_documento
   FROM	chqcomis
  WHERE cod_agente   = a_cod_agente
    and fecha  >= a_fecha_desde
    and fecha  <= a_fecha_hasta
  ORDER BY nombre, fecha, no_recibo, no_documento
*/
 SELECT	cod_agente,
		no_poliza, 
		num_recibo,
		fecha,
		monto,
		prima,
		porc_partic, 
		porc_comis,
		comision, 
		nombre, 
		num_poliza,
		fecha_pagada
   INTO	v_cod_agente,
   		v_no_poliza,
		v_no_recibo,
		v_fecha,
		v_monto,
		v_prima,
		v_porc_partic,
		v_porc_comis,
		v_comision,
		v_nombre_clte,
		v_no_documento,
		v_fecha_pagada
   FROM	deivid_web:web_comisiones
  WHERE cod_agente   = a_cod_agente
    and fecha  >= a_fecha_desde
    and fecha  <= a_fecha_hasta
  ORDER BY nombre, fecha, num_recibo, num_poliza


	IF v_no_poliza = '00000' THEN -- Comision Descontada

		LET v_nombre_clte = 'COMISION DESCONTADA ...';
		LET v_cedula_ruc = '';			

	ELSE

		SELECT cod_contratante,
		       vigencia_inic,
			   vigencia_final
		  INTO _cod_cliente,
		       v_vig_desde,
			   v_vig_hasta
		  FROM emipomae
		 WHERE no_poliza = v_no_poliza;
		 
		select nombre
		  into v_nombre_agt
		  from agtagent
         where cod_agente = a_cod_agente;		  
		 

		SELECT cedula
		  INTO v_cedula_ruc
		  FROM cliclien
		 WHERE cod_cliente = _cod_cliente;

	END IF
	let v_pago_directo = "SI";
	RETURN  v_no_documento,
			v_nombre_clte,
			v_cedula_ruc,
			v_no_recibo,
			v_fecha,
			v_monto,
			v_prima,
			v_porc_partic,
			v_porc_comis,
			v_comision,
			v_nombre_agt,
			v_nombre_cia,
			v_vig_desde,
			v_vig_hasta,
			v_pago_directo,
			v_fecha_pagada
			WITH RESUME;
	
END FOREACH

set lock mode to wait;

END PROCEDURE;