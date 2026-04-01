-- Morosidad por Agente - Detallado
-- 
-- Creado    : 08/09/2000 - Autor: Demetrio Hurtado Almanza 
-- Modificado: 24/07/2001 - Autor: ARMANDO MORENO
-- Modificado: 21/01/2003 -adicion de filtro polizas vencidas - Autor: Armando Moreno
-- Modificado: 15/05/2007 -adicion de filtro de grupos        - Por  : Rub‚n Dar¡o Arn ez 
-- SIS v.2.0 - d_cobr_sp_cob03a_dw1 - DEIVID, S.A.

DROP PROCEDURE sp_leyri01;

CREATE PROCEDURE "informix".sp_leyri01(
a_compania     CHAR(3), 
a_agencia      CHAR(3), 
a_periodo      DATE,    
a_sucursal     CHAR(255) DEFAULT '*',
a_coasegur     CHAR(255) DEFAULT '*',
a_ramo         CHAR(255) DEFAULT '*',
a_formapago    CHAR(255) DEFAULT '*',
a_acreedor     CHAR(255) DEFAULT '*',
a_agente       CHAR(255) DEFAULT '*',
a_cobrador     CHAR(255) DEFAULT '*',
a_tipo_moros   CHAR(255) DEFAULT '1', 
a_incobrable   INT 	     DEFAULT 1,
a_producto     CHAR(255) DEFAULT '*',
a_gestion      CHAR(255) DEFAULT '*',
a_polizas_vencidas    CHAR(1) DEFAULT '0',
a_grupo        CHAR(255) DEFAULT '*'
) RETURNING CHAR(20),  -- Poliza
			DATE,      -- Vigencia Inicial
			DATE,      -- Vigencia Final
			CHAR(10),   -- Estatus
			CHAR(100), -- Asegurado
			CHAR(50),
			SMALLINT,
			CHAR(4),   -- Forma Pago
			DATE,	   -- Fecha Ultimo Pago
			DEC(16,2), -- Monto Ultimo Pago	
			DATE,
			varchar(50),
			CHAR(5),
			CHAR(50),  -- Nombre Agente
			VARCHAR(50),  -- Nombre RAMO
			DEC(16,2), -- Prima Original
			DEC(16,2), -- Saldo
			DEC(16,2), -- Por Vencer
			DEC(16,2), -- Exigible
			DEC(16,2), -- Corriente
			DEC(16,2), -- Dias 30
			DEC(16,2), -- Dias 60
			DEC(16,2), -- Dias 90
			VARCHAR(50),
			date;

DEFINE v_filtros           CHAR(255);
DEFINE _tipo               CHAR(1);
define v_nombre_perpago	   char(50);
DEFINE v_nombre_cliente    CHAR(100);
DEFINE v_doc_poliza        CHAR(20); 
DEFINE _gestion            CHAR(1); 
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
DEFINE v_telefono,v_codigo,_no_poliza CHAR(10);
DEFINE v_nombre_vendedor   CHAR(50);
DEFINE v_cod_agente		   CHAR(5);	
DEFINE v_compania_nombre, v_nombre_prod,v_desc   CHAR(50);
DEFINE v_fecha_cancelacion DATE;
DEFINE _cod_vendedor,v_saber CHAR(3);
DEFINE _apartado           	 CHAR(20);
define _estado             char(10);
define _n_acreedor,_n_motivo_noren  varchar(50);
define _cod_ramo        char(3);
define _no_pagos        smallint;
define _cod_perpago,_cod_no_renov     char(3);
define v_nombre_ramo   char(50);
define _cod_acreedor   char(5);
define v_estatus       smallint;
define _fecha_ult_gestion date;

--SET DEBUG FILE TO "sp_cob03a.trc";
--trace on;

--DROP TABLE tmp_moros;

-- Nombre de la Compania

SET ISOLATION TO DIRTY READ;

-- Procedimiento que carga la Morosidad por Agente

IF a_polizas_vencidas = '0' THEN
	CALL sp_leyri02(
	a_compania,
	a_agencia,
	a_periodo,
	a_tipo_moros
	);
ELSE
END IF

--trace on;

-- Procesos para Filtros

LET v_filtros = "";
let _cod_acreedor = null;

--trace off;

FOREACH
 SELECT	nombre_cliente, 
		doc_poliza,     
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
		cod_vendedor,
		apartado,
		cod_agente,
		no_poliza,
		cod_ramo,
		no_pagos
   INTO	v_nombre_cliente, 
		v_doc_poliza,     
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
		_cod_vendedor,
		_apartado,
		v_cod_agente,
		_no_poliza,
		_cod_ramo,
		_no_pagos
   FROM	tmp_moros
  WHERE seleccionado = 1
  ORDER BY nombre_agente, nombre_cliente, doc_poliza, vigencia_inic

	 SELECT	fecha_aviso_canc,
	        cod_perpago,
			cod_no_renov,
			estatus_poliza
	   INTO	v_fecha_cancelacion,
	        _cod_perpago,
			_cod_no_renov,
			v_estatus
	   FROM	emipomae
	  WHERE no_poliza = _no_poliza;

	if v_estatus = 2 then
		let _estado = 'Cancelada';
	elif v_estatus = 1 then
		let _estado = 'Vigente';
	elif v_estatus = 3 then
		let _estado = 'Vencida';
	else
		let _estado = '';
	end if

	 if _cod_no_renov is not null then

		select nombre
		  into _n_motivo_noren
		  from eminoren
		 where cod_no_renov = _cod_no_renov;
	 else
		  let _n_motivo_noren = '';
	 end if

	SELECT nombre
	  INTO v_nombre_ramo
	  FROM prdramo
	 WHERE cod_ramo = _cod_ramo;

	SELECT nombre
	  INTO v_nombre_perpago
	  FROM cobperpa
	 WHERE cod_perpago = _cod_perpago;

	foreach

	 	SELECT cod_acreedor
		  INTO _cod_acreedor
		  FROM emipoacr
		 WHERE no_poliza = _no_poliza

		exit foreach;

	end foreach

	let _fecha_ult_gestion = null;

	foreach

	 	SELECT date(fecha_gestion)
		  INTO _fecha_ult_gestion
		  FROM cobgesti
		 WHERE no_documento = v_doc_poliza
		 order by fecha_gestion desc

		exit foreach;

	end foreach

 	SELECT nombre
	  INTO _n_acreedor
	  FROM emiacre
	 WHERE cod_acreedor = _cod_acreedor;

	RETURN v_doc_poliza,
		   v_vigencia_inic,  
		   v_vigencia_final,
		   _estado,
		   v_nombre_cliente,
		   v_nombre_perpago,
		   _no_pagos,        
		   v_forma_pago,     
		   v_fecha_ult_pago,
		   v_monto_ult_pago,
		   v_fecha_cancelacion,
		   _n_acreedor,
		   v_cod_agente,
		   v_nombre_agente,
		   v_nombre_ramo,
		   v_prima_bruta,
		   v_saldo,          
		   v_por_vencer,     
		   v_exigible,       
		   v_corriente,     
		   v_monto_30,       
		   v_monto_60,       
		   v_monto_90,
		   _n_motivo_noren,
		   _fecha_ult_gestion
		   WITH RESUME;

END FOREACH
					 
DROP TABLE tmp_moros;

END PROCEDURE;

