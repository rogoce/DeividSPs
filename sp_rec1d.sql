-- Reporte de Incurrido Neto por Corredor
-- 
-- Creado    : 04/08/2000 - Autor: Demetrio Hurtado Almanza 
-- Modificado: 21/08/2000 - Autor: Demetrio Hurtado Almanza
--
-- SIS v.2.0 - d_sp_rec01d_dw4 - DEIVID, S.A.

DROP PROCEDURE sp_rec01d;

CREATE PROCEDURE "informix".sp_rec01d(
a_compania  CHAR(3), 
a_agencia   CHAR(3), 
a_periodo1  CHAR(7), 
a_periodo2  CHAR(7), 
a_sucursal  CHAR(255) DEFAULT "*", 
a_ramo      CHAR(255) DEFAULT "*", 
a_agente    CHAR(255) DEFAULT "*",
a_ajustador CHAR(255) DEFAULT "*"
) RETURNING CHAR(18), 
			CHAR(100), 
			CHAR(20),
			DATE,
			DECIMAL(16,2),
			DECIMAL(16,2),
			DECIMAL(16,2),
			DECIMAL(16,2),
			DECIMAL(16,2),
			DECIMAL(16,2),
			CHAR(50),
			CHAR(50),
			CHAR(50),
			CHAR(3),
			CHAR(7),
  		    CHAR(255);

DEFINE v_doc_reclamo     CHAR(18);     
DEFINE v_cliente_nombre  CHAR(100);    
DEFINE v_doc_poliza      CHAR(20);     
DEFINE v_fecha_siniestro DATE;         
DEFINE v_pagado_bruto    DECIMAL(16,2);
DEFINE v_pagado_neto     DECIMAL(16,2);
DEFINE v_reserva_bruto   DECIMAL(16,2);
DEFINE v_reserva_neto    DECIMAL(16,2);
DEFINE v_incurrido_bruto DECIMAL(16,2);
DEFINE v_incurrido_neto  DECIMAL(16,2);
DEFINE v_ramo_nombre     CHAR(50);     
DEFINE v_agente_nombre   CHAR(50);     
DEFINE v_compania_nombre CHAR(50);     
DEFINE v_cod_ramo        CHAR(3);      
DEFINE v_periodo         CHAR(7);      
DEFINE v_filtros         CHAR(255);

DEFINE _no_reclamo       CHAR(10);     
DEFINE _no_poliza        CHAR(10);     
DEFINE _cod_cliente      CHAR(10);     
DEFINE _cod_agente       CHAR(5);      
DEFINE _porc_partic      DEC(5,2);      
DEFINE _pagado_bruto     DECIMAL(16,2);
DEFINE _pagado_neto      DECIMAL(16,2);
DEFINE _reserva_bruto    DECIMAL(16,2);
DEFINE _reserva_neto     DECIMAL(16,2);
DEFINE _incurrido_bruto  DECIMAL(16,2);
DEFINE _incurrido_neto   DECIMAL(16,2);
DEFINE _tipo             CHAR(1);
DEFINE _ajust_interno    CHAR(3);

-- Nombre de la Compania

LET v_compania_nombre = sp_sis01(a_compania);

CREATE TEMP TABLE tmp_agente(
		cod_agente			CHAR(5),
		doc_reclamo			CHAR(18),
		cliente_nombre		CHAR(100), 	
		doc_poliza			CHAR(20),		
		fecha_siniestro		DATE, 
		pagado_bruto		DEC(16,2),		
		pagado_neto			DEC(16,2),	 	
		reserva_bruto		DEC(16,2),  	
		reserva_neto		DEC(16,2),
		incurrido_bruto		DEC(16,2),	
		incurrido_neto		DEC(16,2),	
		ramo_nombre			CHAR(50),
		agente_nombre		CHAR(50),
		cod_ramo			CHAR(3),
		periodo				CHAR(7),  
		ajust_interno       CHAR(3),
		seleccionado        SMALLINT  DEFAULT 1 NOT NULL
		) WITH NO LOG;

CREATE INDEX xie1_tmp_agente ON tmp_agente(cod_agente);

-- Cargar el Incurrido

LET v_filtros = sp_rec01(
a_compania, 
a_agencia, 
a_periodo1, 
a_periodo2,
a_sucursal, 
'*', 
a_ramo, 
a_agente, 
'*', 
'*', 
'*'
); 

FOREACH 
 SELECT no_reclamo,		
 		no_poliza,			
 		pagado_bruto, 		
 		pagado_neto, 
	    reserva_bruto, 	
	    reserva_neto,		
	    incurrido_bruto,	
	    incurrido_neto,
		cod_ramo,		
		periodo,
		numrecla
   INTO	_no_reclamo, 		
   		_no_poliza,	   	
   		_pagado_bruto, 		
   		_pagado_neto, 
	    _reserva_bruto,		
	    _reserva_neto, 	
	    _incurrido_bruto,	
	    _incurrido_neto,
		v_cod_ramo,			
		v_periodo,
		v_doc_reclamo
   FROM tmp_sinis 
  WHERE seleccionado = 1
  ORDER BY cod_ramo,numrecla
 

	SELECT cod_reclamante,		fecha_siniestro,   ajust_interno
	  INTO _cod_cliente,		v_fecha_siniestro, _ajust_interno
	  FROM recrcmae
	 WHERE no_reclamo = _no_reclamo;

	SELECT nombre
	  INTO v_ramo_nombre
	  FROM prdramo
	 WHERE cod_ramo = v_cod_ramo;

	SELECT no_documento
	  INTO v_doc_poliza
	  FROM emipomae
	 WHERE no_poliza = _no_poliza;

	SELECT nombre
	  INTO v_cliente_nombre		
	  FROM cliclien 
	 WHERE cod_cliente = _cod_cliente;

	FOREACH 
	 SELECT cod_agente,
	 		porc_partic_agt
	   INTO _cod_agente,
	   		_porc_partic
	   FROM emipoagt
	  WHERE no_poliza = _no_poliza

		SELECT nombre
		  INTO v_agente_nombre
		  FROM agtagent
		 WHERE cod_agente = _cod_agente;

		LET v_pagado_bruto    = _pagado_bruto    * _porc_partic / 100;
		LET v_pagado_neto     = _pagado_neto     * _porc_partic / 100;
		LET v_reserva_bruto   = _reserva_bruto   * _porc_partic / 100;
		LET v_reserva_neto    = _reserva_neto    * _porc_partic / 100;
		LET v_incurrido_bruto = _incurrido_bruto * _porc_partic / 100;
		LET v_incurrido_neto  = _incurrido_neto  * _porc_partic / 100;

		INSERT INTO tmp_agente(
		cod_agente,			
		doc_reclamo,			
		cliente_nombre,		
		doc_poliza,			
		fecha_siniestro,		
		pagado_bruto,		
		pagado_neto,			
		reserva_bruto,		
		reserva_neto,		
		incurrido_bruto,		
		incurrido_neto,		
		ramo_nombre,			
		agente_nombre,		
		cod_ramo,			
		periodo,
		ajust_interno	   			
		)
		VALUES(
		_cod_agente,			
		v_doc_reclamo,			
		v_cliente_nombre,		
		v_doc_poliza,			
		v_fecha_siniestro,		
		v_pagado_bruto,		
		v_pagado_neto,			
		v_reserva_bruto,		
		v_reserva_neto,		
		v_incurrido_bruto,		
		v_incurrido_neto,		
		v_ramo_nombre,			
		v_agente_nombre,		
		v_cod_ramo,			
		v_periodo,
		_ajust_interno
		);

	END FOREACH

END FOREACH

-- Filtros para Agente

IF a_agente <> "*" THEN

	LET v_filtros = TRIM(v_filtros) || " Agente: " ||  TRIM(a_agente);

	LET _tipo = sp_sis04(a_agente);  -- Separa los Valores del String en una tabla de codigos

	IF _tipo <> "E" THEN -- Incluir los Registros

		UPDATE tmp_agente
		   SET seleccionado = 0
		 WHERE seleccionado = 1
		   AND cod_agente NOT IN (SELECT codigo FROM tmp_codigos);

	ELSE		        -- Excluir estos Registros
				   
		UPDATE tmp_agente
		   SET seleccionado = 0
		 WHERE seleccionado = 1
		   AND cod_agente IN (SELECT codigo FROM tmp_codigos);

	END IF

	DROP TABLE tmp_codigos;

END IF

-- Filtros para Ramo

IF a_ramo <> "*" THEN

	LET v_filtros = TRIM(v_filtros) || " Ramo: " ||  TRIM(a_ramo);

	LET _tipo = sp_sis04(a_ramo);  -- Separa los Valores del String en una tabla de codigos

	IF _tipo <> "E" THEN -- Incluir los Registros

		UPDATE tmp_agente
		   SET seleccionado = 0
		 WHERE seleccionado = 1
		   AND cod_ramo NOT IN (SELECT codigo FROM tmp_codigos);

	ELSE		        -- Excluir estos Registros
				   
		UPDATE tmp_agente
		   SET seleccionado = 0
		 WHERE seleccionado = 1
		   AND cod_ramo IN (SELECT codigo FROM tmp_codigos);

	END IF

	DROP TABLE tmp_codigos;

END IF

-- Filtro de Ajustador

IF a_ajustador <> "*" THEN

	LET v_filtros = TRIM(v_filtros) || " Ajustador: " ||  TRIM(a_ajustador);

	LET _tipo = sp_sis04(a_ajustador);  -- Separa los Valores del String en una tabla de codigos

	IF _tipo <> "E" THEN -- Incluir los Registros

		UPDATE tmp_agente
		   SET seleccionado = 0
		 WHERE seleccionado = 1
		   AND ajust_interno NOT IN (SELECT codigo FROM tmp_codigos);

	ELSE		        -- Excluir estos Registros

		UPDATE tmp_agente
		   SET seleccionado = 0
		 WHERE seleccionado = 1
		   AND ajust_interno IN (SELECT codigo FROM tmp_codigos);

	END IF

	DROP TABLE tmp_codigos;

END IF
FOREACH 
 SELECT doc_reclamo,			
		cliente_nombre,		
		doc_poliza,			
		fecha_siniestro,		
		pagado_bruto,		
		pagado_neto,			
		reserva_bruto,		
		reserva_neto,		
		incurrido_bruto,		
		incurrido_neto,		
		ramo_nombre,			
		agente_nombre,		
		cod_ramo,			
		periodo
   INTO	v_doc_reclamo,			
		v_cliente_nombre,		
		v_doc_poliza,			
		v_fecha_siniestro,		
		v_pagado_bruto,		
		v_pagado_neto,			
		v_reserva_bruto,		
		v_reserva_neto,		
		v_incurrido_bruto,		
		v_incurrido_neto,		
		v_ramo_nombre,			
		v_agente_nombre,		
		v_cod_ramo,			
		v_periodo
   FROM tmp_agente
  WHERE seleccionado = 1
  ORDER BY agente_nombre, cod_ramo, periodo, doc_reclamo

		RETURN v_doc_reclamo,
		 	   v_cliente_nombre, 	
		 	   v_doc_poliza,		
		 	   v_fecha_siniestro, 
			   v_pagado_bruto,		
			   v_pagado_neto,	 	
			   v_reserva_bruto,  	
			   v_reserva_neto,
			   v_incurrido_bruto,	
			   v_incurrido_neto,	
			   v_ramo_nombre,
			   v_agente_nombre,
			   v_compania_nombre,
			   v_cod_ramo,
			   v_periodo,
			   v_filtros
			   WITH RESUME;
END FOREACH

DROP TABLE tmp_sinis;
DROP TABLE tmp_agente;

END PROCEDURE;








