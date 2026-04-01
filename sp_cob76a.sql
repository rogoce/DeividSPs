-- Reporte de los Saldos por Dia
-- 
-- Creado    : 29/10/2001 - Autor: Demetrio Hurtado Almanza 
-- Modificado: 29/10/2001 - Autor: Demetrio Hurtado Almanza 
--
-- SIS v.2.0 - d_cobr_sp_cob76a_dw1 - DEIVID, S.A.

--DROP PROCEDURE sp_cob76a;

CREATE PROCEDURE "informix".sp_cob76a(
a_compania   CHAR(3), 
a_agencia    CHAR(3), 
a_periodo    DATE
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

--SET DEBUG FILE TO "\\NEMESIS\Ancon\Store Procedures\Debug\sp_cob03b.trc";

--DROP TABLE tmp_moros;

-- Nombre de la Compania

LET  v_compania_nombre = sp_sis01(a_compania); 

CALL sp_cob76(
a_compania,
a_agencia,
a_periodo
);

FOREACH
 SELECT	tipo_produccion,
 		cod_ramo,       
		COUNT(*),
 		SUM(prima_orig),    
		SUM(saldo),          
		SUM(por_vencer),     
		SUM(exigible),       
		SUM(corriente),     
		SUM(monto_30),       
		SUM(monto_60),       
		SUM(monto_90)
   INTO	v_tipo_produccion,
 		_cod_ramo,       
		v_cantidad,
   		v_prima_bruta,    
		v_saldo,          
		v_por_vencer,     
		v_exigible,       
		v_corriente,     
		v_monto_30,       
		v_monto_60,       
		v_monto_90
   FROM	tmp_moros
  GROUP BY tipo_produccion, cod_ramo
  ORDER BY tipo_produccion, cod_ramo

	IF v_tipo_produccion = 'Coaseguro' THEN

		SELECT nombre
		  INTO v_nombre_ramo
		  FROM emicoase
		 WHERE cod_coasegur = _cod_ramo;

	ELSE

		SELECT nombre
		  INTO v_nombre_ramo
		  FROM prdramo
		 WHERE cod_ramo = _cod_ramo;

	END IF

	LET v_monto_90 = v_monto_60 + v_por_vencer - v_exigible + v_corriente - v_monto_30 - v_saldo;

	RETURN 	v_nombre_ramo,
			v_cantidad,
			v_prima_bruta,    
			v_saldo,          
			v_por_vencer,     
			v_exigible,       
			v_corriente,     
			v_monto_30,       
			v_monto_60,       
			v_monto_90,
			v_tipo_produccion,
			v_compania_nombre        
			WITH RESUME;

END FOREACH
					 
DROP TABLE tmp_moros;

END PROCEDURE;

