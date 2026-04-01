-- Reporte de las Comisiones por Corredor - Detallado

-- Creado    : 23/10/2000 - Autor: Demetrio Hurtado Almanza 
-- Modificado: 24/10/2000 - Autor: Demetrio Hurtado Almanza

-- SIS v.2.0 - d_cheq_sp_che03_dw1 - DEIVID, S.A.

DROP PROCEDURE sp_che35a;

CREATE PROCEDURE sp_che35a(a_fecha_desde DATE, a_fecha_hasta DATE)
 --RETURNING SMALLINT;	-- Compania

{a_compania 		 CHAR(3), 
a_sucursal 		 CHAR(3),
a_fecha_desde    DATE,
a_fecha_hasta    DATE
) RETURNING SMALLINT;	-- Compania
}

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
DEFINE v_monto_vida   DEC(16,2);
DEFINE v_monto_danos  DEC(16,2);
DEFINE v_monto_fianza DEC(16,2);
DEFINE v_no_licencia  CHAR(10); 
DEFINE _no_requis     CHAR(10);
DEFINE _tipo_requis   CHAR(1);

DEFINE _tipo_pago    smallint;
DEFINE _cod_cliente  CHAR(10);

--SET DEBUG FILE TO "\\NEMESIS\Ancon\Store Procedures\Debug\sp_che03c.trc";
--TRACE ON;

-- Nombre de la Compania
SET ISOLATION TO DIRTY READ;

--LET  v_nombre_cia = sp_sis01(a_compania); 

CALL sp_che02(
"001", 
"001",
"16/09/2005",
"30/03/2006"
);


--DELETE FROM chqcomis WHERE fecha_desde = a_fecha_desde;

FOREACH	WITH HOLD
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
		monto_vida,  
		monto_danos, 
		monto_fianza,
		no_licencia
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
		v_monto_vida,  
		v_monto_danos, 
		v_monto_fianza,
		v_no_licencia 
   FROM	tmp_agente
  WHERE cod_agente = "00527"
  ORDER BY nombre, fecha, no_recibo, no_documento

   SELECT tipo_pago
     INTO _tipo_pago
	 FROM agtagent
	WHERE cod_agente = v_cod_agente;

  IF _tipo_pago <> 1 THEN
	LET _tipo_requis = 'C';
  ELSE
	LET _tipo_requis = 'A';
  END IF

	INSERT INTO chqcomis(
	     cod_agente,	
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
		 monto_vida,  
		 monto_danos, 
		 monto_fianza,
		 no_licencia, 
		 seleccionado,
		 fecha_desde,
		 fecha_hasta,
		 fecha_genera,
		 tipo_requis
		 )
		 VALUES(
		 v_cod_agente,
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
		 v_monto_vida,  
		 v_monto_danos, 
		 v_monto_fianza,
		 v_no_licencia,
		 0,
		 a_fecha_desde,
		 a_fecha_hasta,
		 '03/07/2007',
		 _tipo_requis 
		 );
END FOREACH

{FOREACH
   SELECT no_requis,
          cod_agente
     INTO _no_requis,
		  v_cod_agente
     FROM chqchmae
    WHERE origen_cheque IN (2,7)
      AND fecha_captura = '19/04/2006'
      
   UPDATE chqcomis
      SET no_requis = _no_requis
	WHERE fecha_genera = '19/04/2006'
	  AND cod_agente = v_cod_agente;
      	
END FOREACH
}
--return 0;
DROP TABLE tmp_agente;

END PROCEDURE;