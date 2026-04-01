-- Reporte de Incurrido Neto por Grupo
-- 
-- Creado    : 04/08/2000 - Autor: Demetrio Hurtado Almanza 
-- Modificado: 04/08/2000 - Autor: Demetrio Hurtado Almanza
--
-- SIS v.2.0 - d_sp_rec01c_dw3 - DEIVID, S.A.

--DROP PROCEDURE sp_rec01c;

CREATE PROCEDURE "informix".sp_rec01c(
a_compania  CHAR(3), 
a_agencia   CHAR(3), 
a_periodo1  CHAR(7), 
a_periodo2  CHAR(7), 
a_sucursal  CHAR(255) DEFAULT "*", 
a_grupo     CHAR(255) DEFAULT "*", 
a_ramo      CHAR(255) DEFAULT "*",
a_ajustador CHAR(255) DEFAULT "*",
a_agente 	CHAR(255) DEFAULT "*"
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
  		    CHAR(255);

DEFINE v_doc_reclamo     CHAR(18);
DEFINE _tipo             CHAR(1);
DEFINE v_cliente_nombre  CHAR(100);    
DEFINE v_doc_poliza      CHAR(20);
DEFINE _cod_agente       CHAR(5);
DEFINE v_fecha_siniestro DATE;         
DEFINE v_pagado_bruto    DECIMAL(16,2);
DEFINE v_pagado_neto     DECIMAL(16,2);
DEFINE v_reserva_bruto   DECIMAL(16,2);
DEFINE v_reserva_neto    DECIMAL(16,2);
DEFINE v_incurrido_bruto DECIMAL(16,2);
DEFINE v_incurrido_neto  DECIMAL(16,2);
DEFINE v_ramo_nombre     CHAR(50);     
DEFINE v_grupo_nombre    CHAR(50);     
DEFINE v_compania_nombre CHAR(50);     
DEFINE v_filtros         CHAR(255);
DEFINE v_agente_nombre 	 CHAR(50);
DEFINE _no_reclamo,v_codigo CHAR(10);
DEFINE _no_poliza        CHAR(10);     
DEFINE _cod_ramo,v_saber CHAR(3);      
DEFINE _cod_cliente      CHAR(10);     
DEFINE _periodo          CHAR(7);      
DEFINE _cod_grupo        CHAR(5);      

CREATE TEMP TABLE tmp_agente(
		cod_agente			CHAR(5),
		doc_reclamo			CHAR(18),
		doc_poliza			CHAR(20),		
		pagado_bruto		DEC(16,2),		
		pagado_neto			DEC(16,2),	 	
		reserva_bruto		DEC(16,2),  	
		reserva_neto		DEC(16,2),
		incurrido_bruto		DEC(16,2),	
		incurrido_neto		DEC(16,2),	
		cod_ramo			CHAR(3),
		cod_grupo			CHAR(5),
		periodo				CHAR(7),
		no_reclamo			CHAR(10),
		seleccionado        SMALLINT  DEFAULT 1 NOT NULL
		) WITH NO LOG;
-- Nombre de la Compania

LET v_compania_nombre = sp_sis01(a_compania);

-- Cargar el Incurrido

LET v_filtros = sp_rec01(
a_compania, 
a_agencia, 
a_periodo1, 
a_periodo2,
a_sucursal, 
a_grupo, 
a_ramo, 
'*', 
a_ajustador, 
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
		numrecla,
		cod_grupo
   INTO	_no_reclamo, 		
   		_no_poliza,	   	
   		v_pagado_bruto, 		
   		v_pagado_neto, 
	    v_reserva_bruto,		
	    v_reserva_neto, 	
	    v_incurrido_bruto,	
	    v_incurrido_neto,
		_cod_ramo,			
		_periodo,
		v_doc_reclamo,
		_cod_grupo
   FROM tmp_sinis 
  WHERE seleccionado = 1
  ORDER BY cod_grupo, cod_ramo, periodo, numrecla

	SELECT no_documento
	  INTO v_doc_poliza
	  FROM emipomae
	 WHERE no_poliza = _no_poliza;

	FOREACH 
		 SELECT cod_agente
		   INTO _cod_agente
		   FROM emipoagt
		  WHERE no_poliza = _no_poliza
	 EXIT FOREACH;
	END FOREACH

		INSERT INTO tmp_agente(
		cod_agente,			
		doc_reclamo,			
		doc_poliza,			
		pagado_bruto,		
		pagado_neto,			
		reserva_bruto,		
		reserva_neto,		
		incurrido_bruto,		
		incurrido_neto,		
		cod_ramo,			
		periodo,
		no_reclamo,
		cod_grupo
		)
		VALUES(
		_cod_agente,			
		v_doc_reclamo,			
		v_doc_poliza,			
		v_pagado_bruto,		
		v_pagado_neto,			
		v_reserva_bruto,		
		v_reserva_neto,		
		v_incurrido_bruto,		
		v_incurrido_neto,		
		_cod_ramo,			
		_periodo,
		_no_reclamo,
		_cod_grupo
		);
END FOREACH

-- Filtros para Agente

IF a_agente <> "*" THEN

	LET v_filtros = TRIM(v_filtros) || " Corredor: ";-- ||  TRIM(a_agente);

	LET _tipo = sp_sis04(a_agente);  -- Separa los Valores del String en una tabla de codigos

	IF _tipo <> "E" THEN -- Incluir los Registros

		UPDATE tmp_agente
		   SET seleccionado = 0
		 WHERE seleccionado = 1
		   AND cod_agente NOT IN (SELECT codigo FROM tmp_codigos);
           LET v_saber = "";
	ELSE		        -- Excluir estos Registros
				   
		UPDATE tmp_agente
		   SET seleccionado = 0
		 WHERE seleccionado = 1
		   AND cod_agente IN (SELECT codigo FROM tmp_codigos);
           LET v_saber = " Ex";
	END IF

    FOREACH
		SELECT agtagent.nombre,tmp_codigos.codigo
	      INTO v_agente_nombre,v_codigo
	      FROM agtagent,tmp_codigos
	     WHERE agtagent.cod_agente = codigo
	     LET v_filtros = TRIM(v_filtros) || " " || TRIM(v_codigo) || " " || TRIM(v_agente_nombre) || (v_saber);
    END FOREACH

	DROP TABLE tmp_codigos;

END IF

FOREACH 
 SELECT doc_reclamo,			
		doc_poliza,			
		pagado_bruto,		
		pagado_neto,			
		reserva_bruto,		
		reserva_neto,		
		incurrido_bruto,		
		incurrido_neto,		
		cod_ramo,			
		periodo,
		no_reclamo,
		cod_grupo
   INTO	v_doc_reclamo,			
		v_doc_poliza,			
		v_pagado_bruto,		
		v_pagado_neto,			
		v_reserva_bruto,		
		v_reserva_neto,		
		v_incurrido_bruto,		
		v_incurrido_neto,		
		_cod_ramo,			
		_periodo,
		_no_reclamo,
		_cod_grupo
   FROM tmp_agente
  WHERE seleccionado = 1
  ORDER BY cod_grupo, cod_ramo, periodo, doc_reclamo

	SELECT cod_reclamante,
		   fecha_siniestro
	  INTO _cod_cliente,
	  	   v_fecha_siniestro
	  FROM recrcmae
	 WHERE no_reclamo = _no_reclamo;

	SELECT nombre
	  INTO v_grupo_nombre
	  FROM cligrupo
	 WHERE cod_grupo = _cod_grupo;

	SELECT nombre
	  INTO v_ramo_nombre
	  FROM prdramo
	 WHERE cod_ramo = _cod_ramo;

	SELECT nombre
	  INTO v_cliente_nombre		
	  FROM cliclien 
	 WHERE cod_cliente = _cod_cliente;

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
		   v_grupo_nombre,
		   v_compania_nombre,
		   v_filtros
		   WITH RESUME;
END FOREACH

DROP TABLE tmp_sinis;
DROP TABLE tmp_agente;
END PROCEDURE;
