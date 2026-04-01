-- Reporte de las Comisiones por Corredor - Detallado

-- Creado    : 23/10/2000 - Autor: Demetrio Hurtado Almanza 
-- Modificado: 24/10/2000 - Autor: Demetrio Hurtado Almanza

-- SIS v.2.0 - d_cheq_sp_che03_dw1 - DEIVID, S.A.

DROP PROCEDURE sp_che35b;

CREATE PROCEDURE sp_che35b(a_fecha_desde DATE, a_fecha_hasta DATE, a_cod_agente CHAR(5), a_no_requis char(10))
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

DEFINE _tipo_pago    smallint;
DEFINE _cod_cliente  CHAR(10);

--SET DEBUG FILE TO "\\NEMESIS\Ancon\Store Procedures\Debug\sp_che03c.trc";
--TRACE ON;

-- Nombre de la Compania
SET ISOLATION TO DIRTY READ;

--LET  v_nombre_cia = sp_sis01(a_compania); 
{
CALL sp_che02(
"001", 
"001",
a_fecha_desde,
a_fecha_hasta
);
--}

--DELETE FROM chqcomis WHERE fecha_desde = a_fecha_desde;

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
  WHERE cod_agente = a_cod_agente
  ORDER BY nombre, fecha, no_recibo, no_documento

   SELECT tipo_pago
     INTO _tipo_pago
	 FROM agtagent
	WHERE cod_agente = v_cod_agente;

--  IF _tipo_pago <> 1 THEN
--	CONTINUE FOREACH;
--  END IF
  BEGIN
	ON EXCEPTION IN(-239, -268)
		UPDATE chqcomis
		   SET no_requis    = a_no_requis		 
		 WHERE cod_agente   = a_cod_agente
		   AND no_poliza    = v_no_poliza
		   AND no_recibo    = v_no_recibo
		   AND fecha        = v_fecha;
	END EXCEPTION

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
		 no_requis
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
		 1,
		 a_fecha_desde,
		 a_fecha_hasta,
		 current,
		 a_no_requis 
		 );
   END
END FOREACH
{
FOREACH
   SELECT no_requis,
          cod_agente
     INTO _no_requis,
		  v_cod_agente
     FROM chqchmae
    WHERE origen_cheque in (2,7)
      AND fecha_captura = '01/06/2006'
      
   UPDATE chqcomis
      SET no_requis = _no_requis
	WHERE fecha_genera = '02/06/2006'
	  AND cod_agente = v_cod_agente;
      	
END FOREACH
--}
--return 0;

END PROCEDURE;