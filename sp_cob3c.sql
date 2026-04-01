-- Morosidad por Cobrador - Detallado
-- 
-- Creado    : 09/09/2000 - Autor: Demetrio Hurtado Almanza 
-- Modificado: 19/09/2000 - Autor: Demetrio Hurtado Almanza
-- Modificado: 07/10/2002 - Autor: Armando Moreno M.(filtro de gestion de cobros)
-- SIS v.2.0 - d_cobr_sp_cob03c_dw3 - DEIVID, S.A.

DROP PROCEDURE sp_cob03c;

CREATE PROCEDURE "informix".sp_cob03c(
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
a_tipo_moros CHAR(255) DEFAULT '1',
a_incobrable INT	   DEFAULT 1,
a_gestion    CHAR(255) DEFAULT '*'
) RETURNING CHAR(100), -- Asegurado
			CHAR(20),  -- Poliza	
			CHAR(1),   -- Estatus	
			CHAR(4),   -- Forma Pago
			DATE,      -- Vigencia Inicial
			DATE,      -- Vigencia Final
			DATE,	   -- Fecha Ultimo Pago
			DEC(16,2), -- Monto Ultimo Pago	
			DEC(16,2), -- Prima Original
			DEC(16,2), -- Saldo
			DEC(16,2), -- Por Vencer
			DEC(16,2), -- Exigible
			DEC(16,2), -- Corriente
			DEC(16,2), -- Dias 30
			DEC(16,2), -- Dias 60
			DEC(16,2), -- Dias 90
			CHAR(50),  -- Nombre Agente
			CHAR(10),  -- Telefono
			CHAR(50),  -- Nombre Vendedor
			CHAR(50),  -- Nombre Cobrador
			CHAR(50),  -- Nombre Compania
			CHAR(20),  -- apartado
			CHAR(255), -- Filtros
			CHAR(1),   -- Gestion
			DATE;

DEFINE v_filtros           CHAR(255);
DEFINE _tipo               CHAR(1);

DEFINE v_nombre_cliente    CHAR(100);
DEFINE v_doc_poliza        CHAR(20); 
DEFINE v_estatus,_gestion  CHAR(1); 
DEFINE v_forma_pago        CHAR(4);
DEFINE v_vigencia_inic     DATE;     
DEFINE v_vigencia_final    DATE;     
DEFINE v_fecha_ult_pago    DATE;
DEFINE v_monto_ult_pago    DEC(16,2);
DEFINE v_prima_bruta       DEC(16,2);
DEFINE v_saldo             DEC(16,2);
DEFINE v_por_vencer        DEC(16,2);
DEFINE v_exigible          DEC(16,2);
DEFINE v_corriente         DEC(16,2);
DEFINE v_monto_30          DEC(16,2);
DEFINE v_monto_60          DEC(16,2);
DEFINE v_monto_90          DEC(16,2);
DEFINE v_nombre_agente     CHAR(50);
DEFINE v_telefono          CHAR(10);
DEFINE v_nombre_vendedor   CHAR(50);
DEFINE v_nombre_cobrador,v_desc   CHAR(50);
DEFINE v_compania_nombre   CHAR(50);

DEFINE _cod_cobrador,v_saber       CHAR(3);
DEFINE _cod_vendedor       CHAR(3);
DEFINE _apartado           CHAR(20);
DEFINE v_fecha_cancelacion DATE;
DEFINE _no_poliza,v_codigo		   CHAR(10);
DEFINE _aviso_canc			DATE;

SET ISOLATION TO DIRTY READ;

--SET DEBUG FILE TO "\\NEMESIS\Ancon\Store Procedures\Debug\sp_cob03c.trc";

--DROP TABLE tmp_moros;

-- Nombre de la Compania

LET  v_compania_nombre = sp_sis01(a_compania); 

-- Procedimiento que carga la Morosidad por Agente

CALL sp_cob03(
a_compania,
a_agencia,
a_periodo,
a_tipo_moros
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

IF a_coasegur <> "*" THEN

	LET v_filtros = TRIM(v_filtros) || " Aseguradora: " ||  TRIM(a_coasegur);

	LET _tipo = sp_sis04(a_coasegur);  -- Separa los Valores del String en una tabla de codigos

	IF _tipo <> "E" THEN -- Incluir los Registros

		UPDATE tmp_moros
		   SET seleccionado = 0
		 WHERE seleccionado = 1
		   AND cod_coasegur NOT IN (SELECT codigo FROM tmp_codigos);

	ELSE		        -- Excluir estos Registros

		UPDATE tmp_moros
		   SET seleccionado = 0
		 WHERE seleccionado = 1
		   AND cod_coasegur IN (SELECT codigo FROM tmp_codigos);

	END IF

	DROP TABLE tmp_codigos;

END IF

IF a_ramo <> "*" THEN

	LET v_filtros = TRIM(v_filtros) || " Ramo: " ||  TRIM(a_ramo);

	LET _tipo = sp_sis04(a_ramo);  -- Separa los Valores del String en una tabla de codigos

	IF _tipo <> "E" THEN -- Incluir los Registros

		UPDATE tmp_moros
		   SET seleccionado = 0
		 WHERE seleccionado = 1
		   AND cod_ramo NOT IN (SELECT codigo FROM tmp_codigos);

	ELSE		        -- Excluir estos Registros

		UPDATE tmp_moros
		   SET seleccionado = 0
		 WHERE seleccionado = 1
		   AND cod_ramo IN (SELECT codigo FROM tmp_codigos);

	END IF

	DROP TABLE tmp_codigos;

END IF

IF a_formapago <> "*" THEN

	LET v_filtros = TRIM(v_filtros) || " Forma de Pago: " ||  TRIM(a_formapago);

	LET _tipo = sp_sis04(a_formapago);  -- Separa los Valores del String en una tabla de codigos

	IF _tipo <> "E" THEN -- Incluir los Registros

		UPDATE tmp_moros
		   SET seleccionado = 0
		 WHERE seleccionado = 1
		   AND cod_formapago NOT IN (SELECT codigo FROM tmp_codigos);

	ELSE		        -- Excluir estos Registros

		UPDATE tmp_moros
		   SET seleccionado = 0
		 WHERE seleccionado = 1
		   AND cod_formapago IN (SELECT codigo FROM tmp_codigos);

	END IF

	DROP TABLE tmp_codigos;

END IF

IF a_acreedor <> "*" THEN

	LET v_filtros = TRIM(v_filtros) || " Acreedor: " ||  TRIM(a_acreedor);

	LET _tipo = sp_sis04(a_acreedor);  -- Separa los Valores del String en una tabla de codigos

	IF _tipo <> "E" THEN -- Incluir los Registros

		UPDATE tmp_moros
		   SET seleccionado = 0
		 WHERE seleccionado = 1
		   AND cod_acreedor NOT IN (SELECT codigo FROM tmp_codigos);

	ELSE		        -- Excluir estos Registros

		UPDATE tmp_moros
		   SET seleccionado = 0
		 WHERE seleccionado = 1
		   AND cod_acreedor IN (SELECT codigo FROM tmp_codigos);

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

IF a_incobrable <> 1 THEN

	IF a_incobrable = 2 THEN  -- Sin Incobrables

		LET v_filtros = TRIM(v_filtros) || " Sin Incobrables ";

		UPDATE tmp_moros
		   SET seleccionado = 0
		 WHERE seleccionado = 1
		   AND incobrable   = 1;

	ELSE		        -- Solo Incobrables

		LET v_filtros = TRIM(v_filtros) || " Solo Incobrables ";

		UPDATE tmp_moros
		   SET seleccionado = 0
		 WHERE seleccionado = 1
		   AND incobrable   = 0;

	END IF

END IF

IF a_gestion <> "*" THEN

	LET v_filtros = TRIM(v_filtros) || " Gestion:"; -- ||  TRIM(a_gestion);

	LET _tipo = sp_sis04(a_gestion);  -- Separa los Valores del String en una tabla de codigos

	IF _tipo <> "E" THEN -- Incluir los Registros

		UPDATE tmp_moros
		   SET seleccionado = 0
		 WHERE seleccionado = 1
		   AND gestion NOT IN (SELECT codigo FROM tmp_codigos);
		LET v_saber = "";
	ELSE		        -- Excluir estos Registros

		UPDATE tmp_moros
		   SET seleccionado = 0
		 WHERE seleccionado = 1
		   AND gestion IN (SELECT codigo FROM tmp_codigos);
		LET v_saber = " Ex";
	END IF
	 FOREACH
		SELECT cobgemae.nombre,tmp_codigos.codigo
          INTO v_desc,v_codigo
          FROM cobgemae,tmp_codigos
         WHERE cobgemae.cod_gestion = codigo
         LET v_filtros = TRIM(v_filtros) || " " || TRIM(v_codigo) || " " || TRIM(v_desc) || " " || TRIM(v_saber);
	 END FOREACH
	DROP TABLE tmp_codigos;

END IF

FOREACH
 SELECT	nombre_cliente, 
		doc_poliza,     
		estatus,        
		forma_pago,     
		vigencia_inic,  
		vigencia_final, 
		fecha_ult_pago,
		monto_ult_pago,
		prima_orig,    
		saldo,          
		por_vencer,     
		exigible,       
		corriente,     
		monto_30,       
		monto_60,       
		monto_90,
		nombre_agente,
		telefono,
		cod_cobrador,
		cod_vendedor,
		apartado,
		no_poliza,
		gestion       
   INTO	v_nombre_cliente, 
		v_doc_poliza,     
		v_estatus,        
		v_forma_pago,     
		v_vigencia_inic,  
		v_vigencia_final, 
		v_fecha_ult_pago,
		v_monto_ult_pago,
		v_prima_bruta,    
		v_saldo,          
		v_por_vencer,     
		v_exigible,       
		v_corriente,     
		v_monto_30,       
		v_monto_60,       
		v_monto_90,
		v_nombre_agente,
		v_telefono,
		_cod_cobrador,
		_cod_vendedor,
		_apartado,
		_no_poliza,
		_gestion        
   FROM	tmp_moros
  WHERE seleccionado = 1
  ORDER BY cod_cobrador, nombre_agente, nombre_cliente, doc_poliza, vigencia_inic

	SELECT nombre
	  INTO v_nombre_cobrador
	  FROM cobcobra
	 WHERE cod_cobrador = _cod_cobrador;

	SELECT nombre
	  INTO v_nombre_vendedor
	  FROM agtvende
	 WHERE cod_vendedor = _cod_vendedor;

	
	IF v_estatus = "C" THEN
	let _aviso_canc = '';
	 SELECT	fecha_cancelacion 
	   INTO	v_fecha_cancelacion
	   FROM	emipomae
	  WHERE no_poliza = _no_poliza;
	
	  LET v_vigencia_final = v_fecha_cancelacion;
	ELSE
		let _aviso_canc = '';
		select fecha_aviso_canc
		  into _aviso_canc
		  from emipomae
		 where no_poliza = _no_poliza;
    END IF

	RETURN 	v_nombre_cliente, 
			v_doc_poliza,     
			v_estatus,        
			v_forma_pago,     
			v_vigencia_inic,  
			v_vigencia_final, 
			v_fecha_ult_pago,
			v_monto_ult_pago,
			v_prima_bruta,    
			v_saldo,          
			v_por_vencer,     
			v_exigible,       
			v_corriente,     
			v_monto_30,       
			v_monto_60,       
			v_monto_90,
			v_nombre_agente,
			v_telefono,
			v_nombre_vendedor,
			v_nombre_cobrador,
		    v_compania_nombre,
			_apartado,
		    v_filtros,
			_gestion,
			_aviso_canc
			WITH RESUME;

END FOREACH
					 
DROP TABLE tmp_moros;

END PROCEDURE;

