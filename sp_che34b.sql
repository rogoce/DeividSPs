-- Reporte de las Comisiones por Corredor - Detallado

-- Creado    : 23/10/2000 - Autor: Demetrio Hurtado Almanza 
-- Modificado: 24/10/2000 - Autor: Demetrio Hurtado Almanza

-- SIS v.2.0 - d_cheq_sp_che03_dw1 - DEIVID, S.A.

DROP PROCEDURE sp_che34b;
						 
CREATE PROCEDURE sp_che34b(a_compania CHAR(3), a_cod_agente CHAR(5)) 
  RETURNING CHAR(20),	-- Poliza
			CHAR(100),	-- Asegurado
			CHAR(10),	-- Recibo
			DATE,		-- Fecha
			DEC(16,2),	-- Monto
			DEC(16,2),	-- Prima
			DEC(5,2),	-- % Partic
			DEC(5,2),	-- % Comis
			DEC(16,2),	-- Comision
			CHAR(50),   -- Agente
			CHAR(50),
			DATE,
			DATE,
			DATE;	-- Compania

DEFINE _tipo          CHAR(1);

DEFINE v_cod_agente   CHAR(5);  
DEFINE v_no_poliza    CHAR(10); 
DEFINE v_monto        DEC(16,2);
DEFINE v_no_recibo    CHAR(10); 
DEFINE v_fecha        DATE;     
DEFINE v_prima        DEC(16,2);
DEFINE v_porc_partic  DEC(5,2); 
DEFINE v_porc_comis   DEC(5,2); 
DEFINE v_comision     DEC(16,2);
DEFINE v_nombre_clte  CHAR(100);
DEFINE v_no_documento CHAR(20);
DEFINE v_nombre_agt   CHAR(50);
DEFINE v_nombre_cia   CHAR(50);
DEFINE v_fecha_desde  DATE;
DEFINE v_fecha_hasta  DATE;
DEFINE _fecha_comis   DATE;
DEFINE _cod_cliente  CHAR(10);

--SET DEBUG FILE TO "\\NEMESIS\Ancon\Store Procedures\Debug\sp_che03c.trc";
--TRACE ON;

-- Nombre de la Compania
SET ISOLATION TO DIRTY READ;

select agt_fecha_comis
  into _fecha_comis
  from parparam 
 where cod_compania = a_compania;

LET  v_nombre_cia = sp_sis01(a_compania); 

SET ISOLATION TO DIRTY READ;

FOREACH
 SELECT	cod_agente,
 		no_poliza,
		no_recibo,
		fecha,
		monto,
		prima,
		porc_partic,
		porc_comis,
		comision,
		nombre,
		no_documento,
		fecha_desde,
		fecha_hasta
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
		v_no_documento,
		v_fecha_desde,
		v_fecha_hasta
   FROM	chqcomis
  WHERE cod_agente   = a_cod_agente
    and seleccionado = 0
	and fecha_hasta = _fecha_comis
  ORDER BY nombre, fecha, no_recibo, no_documento

	IF v_no_poliza = '00000' THEN -- Comision Descontada

		LET v_nombre_clte = 'COMISION DESCONTADA ...';	

	ELSE

		SELECT cod_contratante
		  INTO _cod_cliente
		  FROM emipomae
		 WHERE no_poliza = v_no_poliza;

		SELECT nombre
		  INTO v_nombre_clte
		  FROM cliclien
		 WHERE cod_cliente = _cod_cliente;

	END IF

	RETURN  v_no_documento,
			v_nombre_clte,
			v_no_recibo,
			v_fecha,
			v_monto,
			v_prima,
			v_porc_partic,
			v_porc_comis,
			v_comision,
			v_nombre_agt,
			v_nombre_cia,
			v_fecha_desde,
			v_fecha_hasta,
			_fecha_comis
			WITH RESUME;
	
END FOREACH


END PROCEDURE;