-- Morosidad Total por Ramo
-- 
-- Creado    : 09/09/2000 - Autor: Demetrio Hurtado Almanza 
-- Modificado: 09/09/2001 - Autor: Demetrio Hurtado Almanza 
--
-- SIS v.2.0 - d_cobr_sp_cob05a_dw1 - DEIVID, S.A.

DROP PROCEDURE sp_cob05c;

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

create temp table tmp_dife(
no_poliza		char(10),
saldo1			dec(16,2),
saldo2			dec(16,2)
) with no log;

-- Procedimiento que carga la Morosidad por Ramo

CALL sp_cob05(
a_compania,
a_agencia,
a_periodo
);

LET v_cantidad = 1;

FOREACH
 SELECT no_poliza,
		saldo         
   INTO _no_poliza,
		v_saldo
   FROM	tmp_moros
  WHERE tipo_produccion = "Cartera"

	insert into tmp_dife
	values(
	_no_poliza,
	v_saldo,
	0);

END FOREACH
					 
DROP TABLE tmp_moros;

-- Procedimiento que carga la Morosidad por Agente

CALL sp_cob03(
a_compania,
a_agencia,
a_periodo
);

FOREACH
 SELECT no_poliza,
		sum(saldo)         
   INTO _no_poliza,
		v_saldo
   FROM	tmp_moros
  GROUP BY no_poliza

	insert into tmp_dife
	values(
	_no_poliza,
	0,
	v_saldo);

END FOREACH
					 
DROP TABLE tmp_moros;

foreach
 select no_poliza,
		sum(saldo1),
		sum(saldo2)
   into _no_poliza,
        v_prima_bruta,
		v_saldo
   from tmp_dife	
  group by no_poliza

	if v_prima_bruta <> v_saldo then
       
		SELECT no_documento
		  INTO _no_documento
		  FROM emipomae
		 WHERE no_poliza = _no_poliza;

		RETURN 	_no_documento,
				v_cantidad,
				v_prima_bruta,    
				v_saldo,          
				0.00,     
				0.00,       
				0.00,     
				0.00,       
				0.00,       
				0.00,
				"Cartera",
				v_compania_nombre        
				WITH RESUME;

	end if

END FOREACH

DROP TABLE tmp_dife;

END PROCEDURE;

