
DROP PROCEDURE sp_rec04b;
CREATE PROCEDURE "informix".sp_rec04b(
a_compania 		CHAR(3), 
a_agencia 		CHAR(3), 
a_periodo1 		CHAR(7), 
a_periodo2 		CHAR(7), 
a_sucursal 		CHAR(255) DEFAULT "*", 
a_aseguradora	CHAR(255) DEFAULT "*", 
a_ramo 			CHAR(255) DEFAULT "*"
) RETURNING CHAR(18), 	  -- Reclamo
			CHAR(10),	  -- Transaccion
			CHAR(20),	  -- Poliza
			CHAR(100), 	  -- Asegurado
			CHAR(50),	  -- Tipo Transaccion
			DATE,		  -- Fecha Transaccion
			DATE,         -- Fecha Siniestro
			DATE,         -- Vigencia Inicial
			DATE,         -- Vigencia Final
			DEC(16,2),	  -- Monto Total
			DEC(7,4),	  -- Porcentaje
			DEC(16,2),	  -- Monto Cedido
			CHAR(50),	  -- Ramo Nombre
			CHAR(50),	  -- Compania Nombre
			CHAR(50),	  -- Aseguradora Nombre
			CHAR(255);	  -- Filtros	

DEFINE v_filtros         CHAR(255);
DEFINE _tipo             CHAR(1);

DEFINE v_doc_reclamo     CHAR(18);
DEFINE v_transaccion     CHAR(10);
DEFINE v_doc_poliza      CHAR(20);
DEFINE v_cliente_nombre  CHAR(100);
DEFINE v_tipotran_nombre CHAR(50);
DEFINE v_fecha           DATE;
DEFINE v_fecha_siniestro DATE;
DEFINE v_vigencia_inic   DATE;
DEFINE v_vigencia_final  DATE;
DEFINE v_monto_total     DEC(16,2);
DEFINE v_porcentaje      DEC(7,4);
DEFINE v_monto_cedido    DEC(16,2);
DEFINE v_ramo_nombre     CHAR(50);
DEFINE v_compania_nombre CHAR(50);
DEFINE v_coasegur_nombre CHAR(50);

DEFINE _no_reclamo      CHAR(10);
DEFINE _no_poliza       CHAR(10);
DEFINE _cod_sucursal    CHAR(3);
DEFINE _cod_ramo        CHAR(3);
DEFINE _cod_cliente     CHAR(10);
DEFINE _periodo         CHAR(7);
DEFINE _cod_coasegur_li CHAR(3); -- Coasegurador Lider     
DEFINE _cod_coasegur_ce CHAR(3); -- Coasegurador Cedido     
DEFINE _cod_tipoprod    CHAR(3);
DEFINE _tipo_produccion SMALLINT;
DEFINE _cod_tipotran    CHAR(3);

--SET DEBUG FILE TO "\\NEMESIS\Ancon\Store Procedures\Debug\sp_con04b.trc";

-- Nombre de la Compania

LET  v_compania_nombre = sp_sis01(a_compania);
LET _cod_coasegur_li   = sp_sis02(a_compania, a_agencia);

-- Cargar el Incurrido por Transaccion

--DROP TABLE tmp_sinis;
--DROP TABLE tmp_coas;

CALL sp_rec04(a_compania, a_agencia, a_periodo1, a_periodo2); 

CREATE TEMP TABLE tmp_coas(
		nombre_coasegur		 CHAR(50)  NOT NULL,
		numrecla             CHAR(18)  NOT NULL,
		transaccion          CHAR(10)  NOT NULL,
		no_poliza            CHAR(20)  NOT NULL,
		asegurado            CHAR(50)  NOT NULL,
		tipo                 CHAR(50)  NOT NULL,
		fecha                DATE      NOT NULL,
		fecha_siniestro      DATE      NOT NULL,
		vigencia_inic        DATE      NOT NULL,
		vigencia_final       DATE,
		cod_ramo             CHAR(3)   NOT NULL,
		ramo_nombre          CHAR(50)  NOT NULL,
		periodo              CHAR(7)   NOT NULL,
		monto_total          DEC(16,2) NOT NULL,
		porc_partic          DEC(7,4)  NOT NULL,
		monto_cedido         DEC(16,2) NOT NULL,
		cod_sucursal         CHAR(3)   NOT NULL,
		cod_coasegur		 CHAR(3)   NOT NULL,
		seleccionado         SMALLINT  DEFAULT 1 NOT NULL
		) WITH NO LOG;

FOREACH 
 SELECT no_reclamo,		
 		no_poliza,			
 		pagado_total, 		
		cod_ramo,		
		periodo,
		numrecla,
		fecha,
		fecha_siniestro,
		transaccion,
		cod_tipotran,
		cod_sucursal
   INTO	_no_reclamo, 		
   		_no_poliza,	   	
   		v_monto_total, 		
		_cod_ramo,			
		_periodo,
		v_doc_reclamo,
		v_fecha,
		v_fecha_siniestro,
		v_transaccion,
		_cod_tipotran,
		_cod_sucursal
   FROM tmp_sinis 
  WHERE pagado_total <> 0

	SELECT no_documento,	
		   cod_tipoprod,
		   vigencia_inic,
		   vigencia_final 
	  INTO v_doc_poliza,
	       _cod_tipoprod,
		   v_vigencia_inic, 
		   v_vigencia_final
	  FROM emipomae
	 WHERE no_poliza = _no_poliza;

	SELECT tipo_produccion
	  INTO _tipo_produccion
	  FROM emitipro
	 WHERE cod_tipoprod = _cod_tipoprod;

--	IF _tipo_produccion = 2 THEN -- Coaseguro Mayoritario	

		SELECT cod_reclamante
		  INTO _cod_cliente
		  FROM recrcmae
		 WHERE no_reclamo = _no_reclamo;

		SELECT nombre
		  INTO v_cliente_nombre		
		  FROM cliclien 
		 WHERE cod_cliente = _cod_cliente;

		SELECT nombre
		  INTO v_ramo_nombre
		  FROM prdramo
		 WHERE cod_ramo = _cod_ramo;

		FOREACH
		 SELECT	cod_coasegur,		porc_partic_coas
		   INTO	_cod_coasegur_ce,	v_porcentaje
		   FROM	reccoas
		  WHERE no_reclamo   = _no_reclamo
		    AND cod_coasegur <> _cod_coasegur_li

			SELECT nombre
			  INTO v_coasegur_nombre
			  FROM emicoase
			 WHERE cod_coasegur = _cod_coasegur_ce;

			SELECT nombre
			  INTO v_tipotran_nombre
			  FROM rectitra
			 WHERE cod_tipotran = _cod_tipotran;

			LET v_monto_cedido = v_monto_total * v_porcentaje / 100;

			INSERT INTO tmp_coas(
			nombre_coasegur,
			numrecla,       
			transaccion,    
			no_poliza,      
			asegurado,      
			fecha,
			fecha_siniestro,
			vigencia_inic, 
			vigencia_final,
			cod_ramo,       
			ramo_nombre,
			periodo,        
			monto_total,    
			porc_partic,    
			monto_cedido,
			tipo,
			cod_sucursal,
			cod_coasegur
			)
			VALUES(
			v_coasegur_nombre,
			v_doc_reclamo,
			v_transaccion,
			v_doc_poliza,
			v_cliente_nombre,
			v_fecha,
			v_fecha_siniestro,
			v_vigencia_inic, 
			v_vigencia_final,
			_cod_ramo,
			v_ramo_nombre,
			_periodo,
			v_monto_total,
			v_porcentaje,
			v_monto_cedido,
			v_tipotran_nombre,
			_cod_sucursal,
			_cod_coasegur_ce
			);

		END FOREACH

--	END IF

END FOREACH

-- Procesos para Filtros

LET v_filtros = "";

IF a_sucursal <> "*" THEN

	LET v_filtros = TRIM(v_filtros) || " Sucursal: " ||  TRIM(a_sucursal);

	LET _tipo = sp_sis04(a_sucursal);  -- Separa los Valores del String en una tabla de codigos

	IF _tipo <> "E" THEN -- Incluir los Registros

		UPDATE tmp_coas
		   SET seleccionado = 0
		 WHERE seleccionado = 1
		   AND cod_sucursal NOT IN (SELECT codigo FROM tmp_codigos);

	ELSE		        -- Excluir estos Registros

		UPDATE tmp_coas
		   SET seleccionado = 0
		 WHERE seleccionado = 1
		   AND cod_sucursal IN (SELECT codigo FROM tmp_codigos);

	END IF

	DROP TABLE tmp_codigos;

END IF

IF a_aseguradora <> "*" THEN

	LET v_filtros = TRIM(v_filtros) || " Aseguradora: " ||  TRIM(a_aseguradora);

	LET _tipo = sp_sis04(a_aseguradora);  -- Separa los Valores del String en una tabla de codigos

	IF _tipo <> "E" THEN -- Incluir los Registros

		UPDATE tmp_coas
		   SET seleccionado = 0
		 WHERE seleccionado = 1
		   AND cod_coasegur NOT IN (SELECT codigo FROM tmp_codigos);

	ELSE		        -- Excluir estos Registros

		UPDATE tmp_coas
		   SET seleccionado = 0
		 WHERE seleccionado = 1
		   AND cod_coasegur IN (SELECT codigo FROM tmp_codigos);

	END IF

	DROP TABLE tmp_codigos;

END IF

IF a_ramo <> "*" THEN

	LET v_filtros = TRIM(v_filtros) || " Ramo: " ||  TRIM(a_ramo);

	LET _tipo = sp_sis04(a_ramo);  -- Separa los Valores del String en una tabla de codigos

	IF _tipo <> "E" THEN -- (I) Incluir los Registros

		UPDATE tmp_coas
		   SET seleccionado = 0
		 WHERE seleccionado = 1
		   AND cod_ramo NOT IN (SELECT codigo FROM tmp_codigos);

	ELSE		        -- (E) Excluir estos Registros

		UPDATE tmp_coas
		   SET seleccionado = 0
		 WHERE seleccionado = 1
		   AND cod_ramo IN (SELECT codigo FROM tmp_codigos);

	END IF

	DROP TABLE tmp_codigos;

END IF

FOREACH 
 SELECT nombre_coasegur,
		numrecla,       
		transaccion,    
		no_poliza,      
		asegurado,      
		fecha, 
		fecha_siniestro, 
		vigencia_inic,
		vigencia_final,        
		ramo_nombre,
		periodo,        
		monto_total,    
		porc_partic,    
		monto_cedido,
		tipo,
		cod_ramo
   INTO	v_coasegur_nombre,
		v_doc_reclamo,
		v_transaccion,
		v_doc_poliza,
		v_cliente_nombre,
		v_fecha,
		v_fecha_siniestro,
		v_vigencia_inic,
		v_vigencia_final,
		v_ramo_nombre,
		_periodo,
		v_monto_total,
		v_porcentaje,
		v_monto_cedido,
		v_tipotran_nombre,
		_cod_ramo
   FROM	tmp_coas
  WHERE seleccionado = 1
  ORDER BY nombre_coasegur,cod_ramo,numrecla,transaccion

	RETURN v_doc_reclamo,
		   v_transaccion,
	 	   v_doc_poliza,		
	 	   v_cliente_nombre, 	
		   v_tipotran_nombre,
		   v_fecha,
		   v_fecha_siniestro,
		   v_vigencia_inic,
		   v_vigencia_final,
		   v_monto_total,
		   v_porcentaje,
		   v_monto_cedido,
		   v_ramo_nombre,
		   v_compania_nombre,
		   v_coasegur_nombre,
		   v_filtros
		   WITH RESUME;

END FOREACH

DROP TABLE tmp_sinis;
DROP TABLE tmp_coas;

END PROCEDURE                                                                                                                                                                                                                                                           
