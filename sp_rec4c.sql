-- Reporte de Siniestros Incurridos Cedidos - Frontring
-- 
-- Creado    : 25/08/2000 - Autor: Demetrio Hurtado Almanza 
-- Modificado: 15/09/2000 - Autor: Demetrio Hurtado Almanza
--
-- SIS v.2.0 - d_sp_rec04c_dw3 - DEIVID, S.A.

DROP PROCEDURE sp_rec04c;

CREATE PROCEDURE "informix".sp_rec04c(a_compania CHAR(3),a_agencia CHAR(3),a_periodo1 CHAR(7),a_periodo2 CHAR(7),a_sucursal CHAR(255) DEFAULT "*",a_contrato CHAR(255) DEFAULT "*",a_ramo CHAR(255) DEFAULT "*") RETURNING CHAR(18),CHAR(20),CHAR(100),DATE,CHAR(10),DECIMAL(16,2),DECIMAL(16,2),DECIMAL(16,2),CHAR(50),CHAR(50),CHAR(50),CHAR(255);
	

DEFINE v_filtros          CHAR(255);
DEFINE _tipo              CHAR(1);

DEFINE v_doc_reclamo      CHAR(18);     
DEFINE v_doc_poliza       CHAR(20);     
DEFINE v_cliente_nombre   CHAR(100);    
DEFINE v_fecha_siniestro  DATE;         
DEFINE v_transaccion      CHAR(10);     
DEFINE v_pagado_cedido    DECIMAL(16,2);
DEFINE v_reserva_cedido   DECIMAL(16,2);
DEFINE v_incurrido_cedido DECIMAL(16,2);
DEFINE v_ramo_nombre      CHAR(50);     
DEFINE v_contrato_nombre  CHAR(50);     
DEFINE v_compania_nombre  CHAR(50);     

DEFINE _no_reclamo        CHAR(10);     
DEFINE _no_poliza         CHAR(10);     
DEFINE _cod_sucursal      CHAR(3);      
DEFINE _cod_ramo          CHAR(3);      
DEFINE _cod_contrato      CHAR(5);     
DEFINE _cod_cliente       CHAR(10);     
DEFINE _periodo           CHAR(7);      
DEFINE _tipo_contrato     SMALLINT;      
DEFINE _porc_reas         DECIMAL;      

DEFINE _pagado_bruto      DECIMAL(16,2);
DEFINE _reserva_bruto     DECIMAL(16,2);
DEFINE _incurrido_bruto   DECIMAL(16,2);

-- Nombre de la Compania

LET  v_compania_nombre = sp_sis01(a_compania);

-- Cargar el Incurrido

--DROP TABLE tmp_sinis;

CALL sp_rec04(a_compania, a_agencia, a_periodo1, a_periodo2); 

-- Tabla Temporal para los Contratos

CREATE TEMP TABLE tmp_contrato1(
		cod_contrato		 CHAR(5),
		no_reclamo           CHAR(10),
		transaccion			 CHAR(10),
		no_poliza            CHAR(10),
		cod_ramo             CHAR(3),
		periodo              CHAR(7),
		numrecla             CHAR(18),
		ultima_fecha         DATE,
		pagado_bruto         DEC(16,2) NOT NULL,
		reserva_bruto        DEC(16,2) NOT NULL,
		incurrido_bruto      DEC(16,2) NOT NULL,
		cod_sucursal         CHAR(3)   NOT NULL,
		seleccionado         SMALLINT  DEFAULT 1 NOT NULL,
		PRIMARY KEY (cod_contrato, no_reclamo, transaccion)
		) WITH NO LOG;

FOREACH 
 SELECT no_reclamo,		
 		no_poliza,			
 		pagado_bruto, 		
	    reserva_bruto, 	
	    incurrido_bruto,	
		cod_ramo,		
		periodo,
		numrecla,
		fecha,
		transaccion,
		cod_sucursal
   INTO	_no_reclamo, 		
   		_no_poliza,	   	
   		_pagado_bruto, 		
	    _reserva_bruto,		
	    _incurrido_bruto,	
		_cod_ramo,			
		_periodo,
		v_doc_reclamo,
		v_fecha_siniestro,
		v_transaccion,
		_cod_sucursal
   FROM tmp_sinis 

	-- Informacion de Reaseguro para Sacar la Distribucion de
	-- los contratos

	FOREACH
	 SELECT porc_partic_suma,
		    cod_contrato	
	   INTO _porc_reas,
		    _cod_contrato	
	   FROM recreaco
	  WHERE no_reclamo = _no_reclamo

		SELECT tipo_contrato
		  INTO _tipo_contrato
		  FROM reacomae
		 WHERE cod_contrato = _cod_contrato;

		IF _tipo_contrato = 2 THEN	-- Fronting

			IF _porc_reas IS NULL THEN
				LET _porc_reas = 0;
			END IF

			LET v_pagado_cedido    = _pagado_bruto    * _porc_reas / 100;
			LET v_reserva_cedido   = _reserva_bruto   * _porc_reas / 100;
			LET v_incurrido_cedido = _incurrido_bruto * _porc_reas / 100;

			INSERT INTO tmp_contrato1(
			cod_contrato,
			no_reclamo,           
			transaccion,
			no_poliza,           
			cod_ramo,            
			periodo,             
			numrecla,            
			pagado_bruto,        
			reserva_bruto,       
			incurrido_bruto,
			cod_sucursal     
			)
			VALUES(
			_cod_contrato,
			_no_reclamo,
			v_transaccion,           
			_no_poliza,           
			_cod_ramo,            
			_periodo,             
			v_doc_reclamo,            
			v_pagado_cedido,        
			v_reserva_cedido,       
			v_incurrido_cedido,
			_cod_sucursal     
			);

		END IF

	END FOREACH

END FOREACH

-- Procesos para Filtros

LET v_filtros = "";

IF a_sucursal <> "*" THEN

	LET v_filtros = TRIM(v_filtros) || " Sucursal: " ||  TRIM(a_sucursal);

	LET _tipo = sp_sis04(a_sucursal);  -- Separa los Valores del String en una tabla de codigos

	IF _tipo <> "E" THEN -- Incluir los Registros

		UPDATE tmp_contrato1
		   SET seleccionado = 0
		 WHERE seleccionado = 1
		   AND cod_sucursal NOT IN (SELECT codigo FROM tmp_codigos);

	ELSE		        -- Excluir estos Registros

		UPDATE tmp_contrato1
		   SET seleccionado = 0
		 WHERE seleccionado = 1
		   AND cod_sucursal IN (SELECT codigo FROM tmp_codigos);

	END IF

	DROP TABLE tmp_codigos;

END IF

IF a_contrato <> "*" THEN

	LET v_filtros = TRIM(v_filtros) || " Contrato: " ||  TRIM(a_contrato);

	LET _tipo = sp_sis04(a_contrato);  -- Separa los Valores del String en una tabla de codigos

	IF _tipo <> "E" THEN -- Incluir los Registros

		UPDATE tmp_contrato1
		   SET seleccionado = 0
		 WHERE seleccionado = 1
		   AND cod_contrato NOT IN (SELECT codigo FROM tmp_codigos);

	ELSE		        -- Excluir estos Registros

		UPDATE tmp_contrato1
		   SET seleccionado = 0
		 WHERE seleccionado = 1
		   AND cod_contrato IN (SELECT codigo FROM tmp_codigos);

	END IF

	DROP TABLE tmp_codigos;

END IF

IF a_ramo <> "*" THEN

	LET v_filtros = TRIM(v_filtros) || " Ramo: " ||  TRIM(a_ramo);

	LET _tipo = sp_sis04(a_ramo);  -- Separa los Valores del String en una tabla de codigos

	IF _tipo <> "E" THEN -- (I) Incluir los Registros

		UPDATE tmp_contrato1
		   SET seleccionado = 0
		 WHERE seleccionado = 1
		   AND cod_ramo NOT IN (SELECT codigo FROM tmp_codigos);

	ELSE		        -- (E) Excluir estos Registros

		UPDATE tmp_contrato1
		   SET seleccionado = 0
		 WHERE seleccionado = 1
		   AND cod_ramo IN (SELECT codigo FROM tmp_codigos);

	END IF

	DROP TABLE tmp_codigos;

END IF

FOREACH
SELECT
	cod_contrato,
	no_reclamo,           
	transaccion,
	no_poliza,           
	cod_ramo,            
	periodo,             
	numrecla,            
	pagado_bruto,        
	reserva_bruto,       
	incurrido_bruto     
INTO
	_cod_contrato,
	_no_reclamo,
	v_transaccion,           
	_no_poliza,           
	_cod_ramo,            
	_periodo,             
	v_doc_reclamo,            
	v_pagado_cedido,        
	v_reserva_cedido,       
	v_incurrido_cedido     
 FROM tmp_contrato1
WHERE seleccionado = 1

	SELECT nombre
	  INTO v_contrato_nombre
	  FROM reacomae
	 WHERE cod_contrato = _cod_contrato;

	SELECT fecha_siniestro
	  INTO v_fecha_siniestro
	  FROM recrcmae
	 WHERE no_reclamo = _no_reclamo;

	SELECT nombre
	  INTO v_ramo_nombre
	  FROM prdramo
	 WHERE cod_ramo = _cod_ramo;

	SELECT no_documento,
		   cod_contratante	
	  INTO v_doc_poliza,
	       _cod_cliente
	  FROM emipomae
	 WHERE no_poliza = _no_poliza;

	SELECT nombre
	  INTO v_cliente_nombre		
	  FROM cliclien 
	 WHERE cod_cliente = _cod_cliente;

	RETURN v_doc_reclamo,
	       v_doc_poliza,
	 	   v_cliente_nombre, 
	 	   v_fecha_siniestro, 
		   v_transaccion,
		   v_pagado_cedido,		
		   v_reserva_cedido,  	
		   v_incurrido_cedido,	
		   v_ramo_nombre,
		   v_contrato_nombre,
		   v_compania_nombre,
		   v_filtros
		   WITH RESUME;

END FOREACH

DROP TABLE tmp_sinis;
DROP TABLE tmp_contrato1;

END PROCEDURE;
