-- Polizas Sin Pagos por Cobrador - Saldo
-- 
-- Creado    : 12/09/2000 - Autor: Demetrio Hurtado Almanza 
-- Modificado: 20/09/2000 - Autor: Demetrio Hurtado Almanza
--
-- SIS v.2.0 - d_cobr_sp_cob11b_dw2 - DEIVID, S.A.

--DROP PROCEDURE sp_cob11b;

CREATE PROCEDURE "informix".sp_cob11b(
a_compania   CHAR(3), 
a_agencia    CHAR(3), 
a_periodo    DATE,
a_sucursal   CHAR(255),
a_cobrador   CHAR(255),
a_ramo       CHAR(255)  DEFAULT '*',
a_formapago	 CHAR(255)  DEFAULT '*',
a_agente     CHAR(255)  DEFAULT '*',
a_dias       INTEGER    DEFAULT 100
) RETURNING CHAR(100), -- Asegurado
			CHAR(20),  -- Poliza	
			CHAR(1),   -- Estatus	
			CHAR(2),   -- Forma Pago
			DATE,      -- Vigencia Inicial
			DATE,      -- Vigencia Final
			DEC(16,2), -- Prima Original
			DEC(16,2), -- Saldo			  
			CHAR(50),  -- Nombre Agente
			CHAR(50),  -- Nombre Cobrador
			CHAR(50),  -- Nombre Compania
			CHAR(255); -- Filtros

DEFINE v_filtros           CHAR(255);
DEFINE _tipo               CHAR(1);

DEFINE v_nombre_cliente    CHAR(100);
DEFINE v_doc_poliza        CHAR(20); 
DEFINE _no_poliza          CHAR(10); 
DEFINE v_estatus           SMALLINT; 
DEFINE v_forma_pago        CHAR(2);
DEFINE v_vigencia_inic     DATE;     
DEFINE v_vigencia_final    DATE;     
DEFINE v_prima_bruta       DEC(16,2);
DEFINE v_saldo             DEC(16,2);
DEFINE v_nombre_agente     CHAR(50);
DEFINE v_nombre_cobrador   CHAR(50);
DEFINE v_compania_nombre   CHAR(50);

DEFINE _cod_cobrador       CHAR(3);

--SET DEBUG FILE TO "\\NEMESIS\Ancon\Store Procedures\Debug\sp_cob03c.trc";

--DROP TABLE tmp_moros;

-- Nombre de la Compania

LET  v_compania_nombre = sp_sis01(a_compania); 

-- Procedimiento que carga la Morosidad por Agente

CALL sp_cob11(
a_compania,
a_agencia,
a_periodo,
a_dias
);

-- Procesos para Filtros

LET v_filtros = "";

IF a_sucursal <> "*" THEN

	LET v_filtros = TRIM(v_filtros) || " Sucursal: " ||  TRIM(a_sucursal);

	LET _tipo = sp_sis04(a_sucursal);  -- Separa los Valores del String en una tabla de codigos

	IF _tipo <> "E" THEN -- Incluir los Registros

		UPDATE tmp_moros
		   SET seleccionado = 0
		 WHERE seleccionado = 1
		   AND cod_sucursal NOT IN (SELECT codigo FROM tmp_codigos);

	ELSE		        -- Excluir estos Registros

		UPDATE tmp_moros
		   SET seleccionado = 0
		 WHERE seleccionado = 1
		   AND cod_sucursal IN (SELECT codigo FROM tmp_codigos);

	END IF

	DROP TABLE tmp_codigos;

END IF

IF a_cobrador <> "*" THEN

	LET v_filtros = TRIM(v_filtros) || " Cobrador: " ||  TRIM(a_cobrador);

	LET _tipo = sp_sis04(a_cobrador);  -- Separa los Valores del String en una tabla de codigos

	IF _tipo <> "E" THEN -- Incluir los Registros

		UPDATE tmp_moros
		   SET seleccionado = 0
		 WHERE seleccionado = 1
		   AND cod_cobrador NOT IN (SELECT codigo FROM tmp_codigos);

	ELSE		        -- Excluir estos Registros

		UPDATE tmp_moros
		   SET seleccionado = 0
		 WHERE seleccionado = 1
		   AND cod_cobrador IN (SELECT codigo FROM tmp_codigos);

	END IF

	DROP TABLE tmp_codigos;

END IF

IF a_agente <> "*" THEN

	LET v_filtros = TRIM(v_filtros) || " Corredor: " ||  TRIM(a_agente);

	LET _tipo = sp_sis04(a_agente);  -- Separa los Valores del String en una tabla de codigos

	IF _tipo <> "E" THEN -- Incluir los Registros

		UPDATE tmp_moros
		   SET seleccionado = 0
		 WHERE seleccionado = 1
		   AND cod_agente NOT IN (SELECT codigo FROM tmp_codigos);

	ELSE		        -- Excluir estos Registros

		UPDATE tmp_moros
		   SET seleccionado = 0
		 WHERE seleccionado = 1
		   AND cod_agente IN (SELECT codigo FROM tmp_codigos);

	END IF

	DROP TABLE tmp_codigos;

END IF

FOREACH
 SELECT	nombre_cliente, 
		doc_poliza,     
		estatus,        
		forma_pago,     
		vigencia_inic,  
		vigencia_final, 
		prima_orig,    
		saldo,          
		nombre_agente,
		cod_cobrador,
		no_poliza
   INTO	v_nombre_cliente, 
		v_doc_poliza,     
		v_estatus,        
		v_forma_pago,     
		v_vigencia_inic,  
		v_vigencia_final, 
		v_prima_bruta,    
		v_saldo,          
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

	IF v_estatus = 2 THEN --cancelada
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
			v_prima_bruta,    
			v_saldo,          
			v_nombre_agente,
			v_nombre_cobrador,
		    v_compania_nombre,
		    v_filtros
			WITH RESUME;

END FOREACH
					 
DROP TABLE tmp_moros;

END PROCEDURE;

