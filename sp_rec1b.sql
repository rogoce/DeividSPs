-- Reporte de Incurrido Neto Total por Ramo
-- 
-- Creado    : 03/08/2000 - Autor: Demetrio Hurtado Almanza 
-- Modificado: 03/08/2000 - Autor: Demetrio Hurtado Almanza
--
-- SIS v.2.0 - d_sp_rec01b_dw2 - DEIVID, S.A.

DROP PROCEDURE sp_rec01b;

CREATE PROCEDURE "informix".sp_rec01b(
a_compania  CHAR(3), 
a_agencia   CHAR(3), 
a_periodo1  CHAR(7), 
a_periodo2  CHAR(7), 
a_sucursal  CHAR(255) DEFAULT "*",
a_ajustador CHAR(255) DEFAULT "*",
a_agente    CHAR(255) DEFAULT "*"
) RETURNING CHAR(50),
	   		DECIMAL(16,2),
			DECIMAL(16,2),
			DECIMAL(16,2),
			DECIMAL(16,2),
			DECIMAL(16,2),
			DECIMAL(16,2),
			CHAR(50),
			INTEGER,
  		    CHAR(255),
			DECIMAL(16,2),
			DECIMAL(16,2);

DEFINE v_ramo_nombre     CHAR(50);
DEFINE _tipo             CHAR(1);
DEFINE v_saber           CHAR(3);
DEFINE v_doc_reclamo     CHAR(18);
DEFINE v_pagado_total    DECIMAL(16,2);
DEFINE v_pagado_bruto    DECIMAL(16,2);
DEFINE v_pagado_neto     DECIMAL(16,2);
DEFINE v_reserva_bruto   DECIMAL(16,2);
DEFINE v_reserva_neto    DECIMAL(16,2);
DEFINE v_reserva_recup   DECIMAL(16,2);
DEFINE v_incurrido_bruto DECIMAL(16,2);
DEFINE v_incurrido_neto  DECIMAL(16,2);
DEFINE v_compania_nombre,v_agente_nombre CHAR(50);
DEFINE v_cantidad        INTEGER;
DEFINE v_filtros         CHAR(255);
DEFINE _cod_agente       CHAR(5);

DEFINE _no_reclamo,v_codigo      CHAR(10);
DEFINE _no_poliza       CHAR(10);
DEFINE _cod_ramo        CHAR(3);
DEFINE _cod_cliente     CHAR(10);
DEFINE _periodo         CHAR(7);
DEFINE v_doc_poliza     CHAR(20);

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
		pagado_total		DEC(16,2),
		cod_ramo			CHAR(3),
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
'*', 
'*', 
'*', 
a_ajustador, 
'*', 
'*'
); 

FOREACH
 SELECT cod_ramo,		
 		pagado_bruto,
 		pagado_neto,
	    reserva_bruto,
	    reserva_neto,
	    incurrido_bruto,
	    incurrido_neto,
		pagado_total,
		no_poliza,
		no_reclamo,
		numrecla
   INTO	_cod_ramo,			
		v_pagado_bruto, 		
   		v_pagado_neto, 
	    v_reserva_bruto,		
	    v_reserva_neto, 	
	    v_incurrido_bruto,	
	    v_incurrido_neto,
		v_pagado_total,
		_no_poliza,
		_no_reclamo,
		v_doc_reclamo
   FROM tmp_sinis 
  WHERE seleccionado = 1
  ORDER BY cod_ramo

	FOREACH 
		 SELECT cod_agente
		   INTO _cod_agente
		   FROM emipoagt
		  WHERE no_poliza = _no_poliza
	 EXIT FOREACH;
	END FOREACH

	SELECT no_documento
	  INTO v_doc_poliza
	  FROM emipomae
	 WHERE no_poliza = _no_poliza;

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
		no_reclamo,
		pagado_total
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
		_no_reclamo,
		v_pagado_total
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
 SELECT cod_ramo,		
 		SUM(pagado_bruto), 		
 		SUM(pagado_neto), 
	    SUM(reserva_bruto), 	
	    SUM(reserva_neto),		
	    SUM(incurrido_bruto),	
	    SUM(incurrido_neto),
		COUNT(*),
		SUM(pagado_total)
   INTO	_cod_ramo,			
		v_pagado_bruto, 		
   		v_pagado_neto, 
	    v_reserva_bruto,		
	    v_reserva_neto, 	
	    v_incurrido_bruto,	
	    v_incurrido_neto,
		v_cantidad,
		v_pagado_total 		
   FROM tmp_agente
  WHERE seleccionado = 1
  GROUP BY cod_ramo
  ORDER BY cod_ramo

	SELECT nombre
	  INTO v_ramo_nombre
	  FROM prdramo
	 WHERE cod_ramo = _cod_ramo;

	let v_reserva_recup = v_reserva_bruto - v_reserva_neto;

	RETURN v_ramo_nombre,
		   v_pagado_bruto,		
		   v_pagado_neto,	 	
		   v_reserva_bruto,  	
		   v_reserva_neto,
		   v_incurrido_bruto,	
		   v_incurrido_neto,	
		   v_compania_nombre,
		   v_cantidad,
		   v_filtros,
		   v_pagado_total,
		   v_reserva_recup
		   WITH RESUME;

END FOREACH
DROP TABLE tmp_sinis;
DROP TABLE tmp_agente;
END PROCEDURE;
