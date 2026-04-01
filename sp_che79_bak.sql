-- Reporte de las Comisiones por Corredor - Totales

-- Creado    : 24/10/2000 - Autor: Demetrio Hurtado Almanza 
-- Modificado: 24/10/2000 - Autor: Demetrio Hurtado Almanza

-- SIS v.2.0 - d_cheq_sp_che04_dw1 - DEIVID, S.A.

DROP PROCEDURE sp_che79;

CREATE PROCEDURE sp_che79(a_compania CHAR(3), a_sucursal CHAR(3), a_periodo CHAR(7), a_verif_tipo_pago SMALLINT DEFAULT 0) 
RETURNING	CHAR(10),	-- Licencia
            CHAR(50),   -- Agente
			DEC(16,2),	-- Vida
			DEC(16,2),	-- Danos
			DEC(16,2),	-- Fianzas
			INT,
			INT,
			INT,
			CHAR(50);	-- Compania

DEFINE v_nombre_agt   CHAR(50);
DEFINE v_monto        DEC(16,2);
DEFINE v_prima        DEC(16,2);
DEFINE v_comision     DEC(16,2);
DEFINE v_nombre_cia   CHAR(50);
DEFINE v_no_licencia  CHAR(10);
DEFINE v_monto_vida   DEC(16,2);
DEFINE v_monto_danos  DEC(16,2);
DEFINE v_monto_fianza DEC(16,2);
DEFINE v_arrastre	  DEC(16,2);
DEFINE _cod_agente    CHAR(5);
DEFINE _fecha_ult_comis DATE;  
DEFINE _tipo_pago     SMALLINT; 
DEFINE _tipo_agente   CHAR(1);  
DEFINE v_comision2    DEC(16,2);
DEFINE v_cnt_vida     SMALLINT;
DEFINE v_cnt_gen      SMALLINT;
DEFINE v_cnt_fian     SMALLINT;
DEFINE _fecha_desde   DATE;
DEFINE _fecha_hasta   DATE;
DEFINE _fecha_desde2  DATE;
DEFINE _fecha_hasta2  DATE;
DEFINE _dia           CHAR(2);
DEFINE _mes           CHAR(2);
DEFINE _ano2          CHAR(4);

SET ISOLATION TO DIRTY READ;

LET _dia = "01";
LET _mes = substring(a_periodo from 6 for 7);
LET _ano2 = substring(a_periodo from 1 for 4);

LET _fecha_desde = date(_dia||"/"||_mes||"/"||_ano2);
LET _fecha_hasta = _fecha_desde + 1 UNITS MONTH - 1 UNITS DAY;

LET _fecha_desde2 = date("16/"||_mes||"/"||_ano2);
LET _fecha_hasta2 = _fecha_desde + 1 UNITS MONTH + 14 UNITS DAY;

-- Nombre de la Compania

LET  v_nombre_cia = sp_sis01(a_compania); 

--DROP TABLE tmp_agente;

CALL sp_che02(
a_compania, 
a_sucursal,
_fecha_desde,
_fecha_hasta,
0,
a_verif_tipo_pago
);

CALL sp_che79b(a_compania, a_sucursal, a_periodo);

--SET DEBUG FILE TO "c:\sp_che04.trc";
--TRACE ON;

FOREACH
 SELECT	SUM(monto),
		SUM(prima),
		SUM(comision),
		SUM(monto_vida),
		SUM(monto_danos),
		SUM(monto_fianza),
		nombre,
		no_licencia,
		cod_agente
   INTO	v_monto,
		v_prima,
		v_comision,
		v_monto_vida,
		v_monto_danos,
		v_monto_fianza,
		v_nombre_agt,
		v_no_licencia,
		_cod_agente
   FROM	tmp_agente
  GROUP BY nombre, no_licencia, cod_agente
  ORDER BY nombre, no_licencia, cod_agente

  

	LET v_cnt_vida = 0;
	LET v_cnt_gen  = 0;
	LET v_cnt_fian = 0;

	SELECT SUM(cnt_vid),
		   SUM(cnt_gen),
		   SUM(cnt_fia)
	  INTO v_cnt_vida,
	       v_cnt_gen,
		   v_cnt_fian
		  FROM tmp_tabla
	 WHERE cod_corredor = _cod_agente;

	RETURN  v_no_licencia,
	        v_nombre_agt,
			v_monto_vida,
			v_monto_danos,
			v_monto_fianza,
			v_cnt_vida,
			v_cnt_gen,
			v_cnt_fian,
			v_nombre_cia
			WITH RESUME;
	
END FOREACH

DROP TABLE tmp_agente;
DROP TABLE tmp_tabla;

END PROCEDURE;