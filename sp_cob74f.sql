-- Morosidad por Ramo - Totales
-- 
-- Creado    : 09/10/2001 - Autor: Amado Perez 
-- Modificado: 16/01/2002 - Autor: Amado Perez
--
-- SIS v.2.0 - d_cobr_sp_cob74_dw1 - DEIVID, S.A.

DROP PROCEDURE sp_cob74f;

CREATE PROCEDURE "informix".sp_cob74f(
a_compania   CHAR(3), 
a_agencia    CHAR(3), 
a_periodo    DATE
) RETURNING CHAR(50),  -- Nombre Agente
			INTEGER,   -- Cantidad de Polizas
			DEC(16,2), -- 	
			DEC(16,2),
			DEC(16,2), -- Comision
			DEC(16,2), -- Dos porciento
			CHAR(50),  -- Nombre Compania
			CHAR(255); -- Filtros

DEFINE v_filtros           CHAR(255);
DEFINE _tipo               CHAR(1);
DEFINE v_saber			   CHAR(3);
DEFINE v_nombre_agente     CHAR(50);
DEFINE v_codigo			   CHAR(10);
DEFINE v_cantidad          INTEGER;
DEFINE v_prima_bruta       DEC(16,2);
DEFINE v_saldo             DEC(16,2);
DEFINE v_saldo_imp         DEC(16,2);
DEFINE v_por_vencer        DEC(16,2);
DEFINE v_exigible          DEC(16,2);
DEFINE v_corriente         DEC(16,2);
DEFINE v_monto_30          DEC(16,2);
DEFINE v_monto_60          DEC(16,2);
DEFINE v_monto_90          DEC(16,2);
DEFINE v_comision          DEC(16,2);
DEFINE v_dosporciento	   DEC(16,2);
DEFINE _cod_ramo           DEC(16,2);
DEFINE v_nombre_ramo       CHAR(50);
DEFINE v_compania_nombre,v_nombre_prod   CHAR(50);

SET ISOLATION TO DIRTY READ;

--SET DEBUG FILE TO "sp_cob74a.trc";

--DROP TABLE tmp_moros;

-- Nombre de la Compania

LET  v_compania_nombre = sp_sis01(a_compania); 

-- Procedimiento que carga la Morosidad por Agente

CALL sp_cob742b(
a_compania,
a_agencia,
a_periodo
);

let v_filtros = "";

FOREACH
 SELECT	cod_ramo,       
		COUNT(*),
		SUM(saldo_imp),
		SUM(saldo),
		SUM(comis_agt),
		SUM(dos_porciento)
   INTO	_cod_ramo,
		v_cantidad,
		v_saldo_imp,
   		v_saldo,   
   		v_comision,
   		v_dosporciento
   FROM	tmp_moros
  WHERE seleccionado = 1
  GROUP BY cod_ramo
  ORDER BY cod_ramo

 SELECT nombre
   INTO v_nombre_ramo
   FROM prdramo
  WHERE cod_ramo = _cod_ramo;
 
 	
	RETURN 	v_nombre_ramo,
			v_cantidad,
			v_saldo_imp,
			v_saldo,  
			v_comision,
			v_dosporciento,
		    v_compania_nombre,
		    v_filtros
			WITH RESUME;

END FOREACH
					 
DROP TABLE tmp_moros;

END PROCEDURE;

