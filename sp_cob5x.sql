-- Morosidad Total por Ramo
-- 
-- Creado    : 09/09/2000 - Autor: Demetrio Hurtado Almanza 
-- Modificado: 09/09/2001 - Autor: Demetrio Hurtado Almanza 
--
-- SIS v.2.0 - d_cobr_sp_cob05a_dw1 - DEIVID, S.A.

--DROP PROCEDURE sp_cob05a;

CREATE PROCEDURE "informix".sp_cob05c(
a_compania   CHAR(3), 
a_agencia    CHAR(3), 
a_periodo    DATE,
a_sucursal   CHAR(255) DEFAULT '*',
a_coasegur   CHAR(255) DEFAULT '*',
a_ramo       CHAR(255) DEFAULT '*',
a_formapago  CHAR(255) DEFAULT '*',
a_acreedor   CHAR(255) DEFAULT '*',
a_agente     CHAR(255) DEFAULT '*',
a_cobrador   CHAR(255) DEFAULT '*',
a_incobrable INT       DEFAULT 1
) RETURNING CHAR(50),  -- Nombre Ramo
			INTEGER,   -- Cantidad de Polizas	
			DEC(16,2), -- Prima Original
			DEC(16,2), -- Saldo
			DEC(16,2), -- Por Vencer
			DEC(16,2), -- Exigible
			DEC(16,2), -- Corriente
			DEC(16,2), -- Dias 30
			DEC(16,2), -- Dias 60
			DEC(16,2), -- Dias 90
			CHAR(10),  -- Tipo Produccion
			CHAR(50);  -- Nombre Compania

DEFINE v_tipo_produccion   CHAR(10);
DEFINE v_nombre_ramo       CHAR(50);
DEFINE v_cantidad          INTEGER;
DEFINE v_prima_bruta       DEC(16,2);
DEFINE v_saldo             DEC(16,2);
DEFINE v_por_vencer        DEC(16,2);
DEFINE v_exigible          DEC(16,2);
DEFINE v_corriente         DEC(16,2);
DEFINE v_monto_30          DEC(16,2);
DEFINE v_monto_60          DEC(16,2);
DEFINE v_monto_90          DEC(16,2);
DEFINE v_compania_nombre   CHAR(50);
DEFINE v_filtros           CHAR(255);
DEFINE _tipo               CHAR(1);

DEFINE _cod_ramo           CHAR(3); 
DEFINE _no_poliza		   CHAR(10);	
DEFINE _cantidad           INTEGER;
DEFINE _suma			   DEC(16,2);
DEFINE _no_documento       CHAR(50);
	
--SET DEBUG FILE TO "\\NEMESIS\Ancon\Store Procedures\Debug\sp_cob03b.trc";

--DROP TABLE tmp_moros;

-- Nombre de la Compania

LET  v_compania_nombre = sp_sis01(a_compania); 

-- Procedimiento que carga la Morosidad por Agente

CALL sp_cob05(
a_compania,
a_agencia,
a_periodo
);

LET v_cantidad = 1;

FOREACH
 SELECT no_poliza,
 		prima_orig,    
		saldo,          
		por_vencer,     
		exigible,       
		corriente,     
		monto_30,       
		monto_60,       
		monto_90
   INTO _no_poliza,
   		v_prima_bruta,    
		v_saldo,          
		v_por_vencer,     
		v_exigible,       
		v_corriente,     
		v_monto_30,       
		v_monto_60,       
		v_monto_90
   FROM	tmp_moros
  WHERE tipo_produccion = "Cartera"

	SELECT no_documento
	  INTO _no_documento
	  FROM emipomae
	 WHERE no_poliza = _no_poliza;

	SELECT COUNT(*)
	  INTO _cantidad
	  FROM emipoagt
	 WHERE no_poliza = _no_poliza;

	IF _cantidad IS NULL THEN
		LET _cantidad = 0;
	END IF
	
	IF _cantidad = 0 THEN
		RETURN 	_no_documento,
				v_cantidad,
				v_prima_bruta,    
				v_saldo,          
				v_por_vencer,     
				v_exigible,       
				v_corriente,     
				v_monto_30,       
				v_monto_60,       
				v_monto_90,
				"Cartera",
				v_compania_nombre        
				WITH RESUME;
	END IF
	
	SELECT SUM(porc_partic_agt)
	  INTO _suma
	  FROM emipoagt
	 WHERE no_poliza = _no_poliza;
		  	
	IF _suma IS NULL THEN
		LET _suma = 0;
	END IF
	
	IF _suma <> 100 THEN
		RETURN 	_no_documento,
				v_cantidad,
				v_prima_bruta,    
				v_saldo,          
				v_por_vencer,     
				v_exigible,       
				v_corriente,     
				v_monto_30,       
				v_monto_60,       
				v_monto_90,
				"Cartera",
				v_compania_nombre        
				WITH RESUME;
	END IF


END FOREACH
					 
DROP TABLE tmp_moros;

END PROCEDURE;

