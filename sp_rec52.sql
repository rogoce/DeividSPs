-- Procedimiento que Carga la Siniestralidad Por Poliza en un Periodo 
-- 
-- Creado    : 25/08/2000 - Autor: Demetrio Hurtado Almanza 
-- Modificado: 12/07/2001 - Autor: Armando Moreno M.
--
-- SIS v.2.0 - DEIVID, S.A.

DROP PROCEDURE sp_rec52;

CREATE PROCEDURE "informix".sp_rec52(
a_compania CHAR(3),
a_agencia  CHAR(3),
a_periodo1 CHAR(7),
a_periodo2 CHAR(7)
)

DEFINE _no_poliza    CHAR(10); 
DEFINE _cod_ramo     CHAR(3);  
DEFINE _cod_subramo  CHAR(3);  
DEFINE _cod_grupo    CHAR(5);  
DEFINE _doc_poliza   CHAR(20); 
DEFINE _cod_sucursal CHAR(3);  
DEFINE _cod_coasegur CHAR(3);  
DEFINE _porcentaje   DEC(16,4);
DEFINE _cod_agente   CHAR(5);
DEFINE _cod_producto CHAR(5);
DEFINE _cod_cliente  CHAR(10); 

DEFINE v_filtros     CHAR(255);
DEFINE _count        INTEGER;
DEFINE _contador     INT;

SELECT par_ase_lider
  INTO _cod_coasegur
  FROM parparam
 WHERE cod_compania = a_compania;
   
-- Tabla Temporal 

CREATE TEMP TABLE tmp_siniest(
		no_poliza           CHAR(10)  NOT NULL,
		doc_poliza			CHAR(20)  NOT NULL,
		cod_ramo            CHAR(3)   NOT NULL,
		cod_subramo         CHAR(3)   NOT NULL,
		cod_grupo           CHAR(5)   NOT NULL,
		prima_suscrita      DEC(16,2) NOT NULL,
		incurrido_bruto     DEC(16,2) NOT NULL,
		siniestro_pagado    DEC(16,2) NOT NULL,
		prima_pagada		DEC(16,2) NOT NULL,
		fronting            SMALLINT  DEFAULT 0 NOT NULL,
		cod_contrato       	CHAR(5),
		seleccionado        SMALLINT  DEFAULT 1 NOT NULL,
		cod_agente       	CHAR(5),
		cod_sucursal        CHAR(3)   NOT NULL,
		cod_cliente			CHAR(10),
		cod_producto		CHAR(5)	  NOT NULL
		) WITH NO LOG;

CREATE INDEX xie01_tmp_siniest ON tmp_siniest(no_poliza);

CREATE TEMP TABLE tmp_montos(
		no_poliza           CHAR(10)  NOT NULL,
		prima_suscrita      DEC(16,2) DEFAULT 0 NOT NULL,
		incurrido_bruto     DEC(16,2) DEFAULT 0 NOT NULL,
		siniestro_pagado    DEC(16,2) DEFAULT 0 NOT NULL,
		prima_pagada		DEC(16,2) DEFAULT 0 NOT NULL
		) WITH NO LOG;

CREATE INDEX xie01_tmp_montos ON tmp_montos(no_poliza);

-- Primas Suscritas

BEGIN

DEFINE _prima_suscrita DECIMAL(16,2);

FOREACH 
 SELECT prima_suscrita,		
 		no_poliza
   INTO	_prima_suscrita,
		_no_poliza
   FROM endedmae
  WHERE cod_compania = a_compania
    AND actualizado  = 1
    AND periodo     >= a_periodo1 
    AND periodo     <= a_periodo2

	INSERT INTO tmp_montos(
	no_poliza,           
	prima_suscrita
	)
	VALUES(
	_no_poliza,
	_prima_suscrita
	);
END FOREACH
END

-- Primas Pagadas

BEGIN

DEFINE _no_remesa    CHAR(10);     
DEFINE _prima_pagada DEC(16,2);

FOREACH
 SELECT	no_poliza,
        prima_neta
   INTO	_no_poliza,
        _prima_pagada
   FROM cobredet
  WHERE	cod_compania = a_compania
  	AND	actualizado  = 1
    AND tipo_mov IN ('P', 'N')
    AND periodo     >= a_periodo1 
    AND periodo     <= a_periodo2
	AND renglon     <> 0

	SELECT porc_partic_coas
	  INTO _porcentaje
	  FROM emihcmd
	 WHERE no_poliza    = _no_poliza
	   AND no_cambio    = '000'
	   AND cod_coasegur = _cod_coasegur;
	   
	IF _porcentaje IS NULL THEN
		LET _porcentaje = 100;
	END IF	    

	LET _prima_pagada = _prima_pagada / 100 * _porcentaje;

	INSERT INTO tmp_montos(
	no_poliza,           
	prima_pagada
	)
	VALUES(
	_no_poliza,
	_prima_pagada
	);

END FOREACH

END

-- Incurrido Bruto y Sinestro Pagado

BEGIN

DEFINE _incurrido_bruto  DECIMAL(16,2);
DEFINE _siniestro_pagado DECIMAL(16,2);

LET v_filtros = sp_rec01(
				a_compania, 
				a_agencia, 
				a_periodo1, 
				a_periodo2
				); 

FOREACH 
 SELECT	incurrido_bruto,
        pagado_bruto,
		no_poliza
   INTO	_incurrido_bruto,
        _siniestro_pagado,
		_no_poliza
   FROM	tmp_sinis

	INSERT INTO tmp_montos(
	no_poliza,           
	incurrido_bruto,     
	siniestro_pagado
	)
	VALUES(
	_no_poliza,
	_incurrido_bruto,     
	_siniestro_pagado
	);

END FOREACH

DROP TABLE tmp_sinis;
END

BEGIN

DEFINE _incurrido_bruto  DECIMAL(16,2);
DEFINE _siniestro_pagado DECIMAL(16,2);
DEFINE _prima_suscrita   DECIMAL(16,2);
DEFINE _prima_pagada     DECIMAL(16,2);

FOREACH 
 SELECT SUM(prima_suscrita),
        SUM(prima_pagada),		
		SUM(incurrido_bruto),
		SUM(siniestro_pagado),
 		no_poliza
   INTO	_prima_suscrita,
		_prima_pagada,
		_incurrido_bruto,
		_siniestro_pagado,
		_no_poliza
   FROM tmp_montos
  GROUP BY no_poliza
  	
	SELECT cod_ramo,
	       cod_subramo,
		   cod_grupo,
		   no_documento,
		   cod_sucursal,
		   cod_contratante
	  INTO _cod_ramo,
	       _cod_subramo,
		   _cod_grupo,
		   _doc_poliza,
		   _cod_sucursal,
		   _cod_cliente
	  FROM emipomae
	 WHERE no_poliza = _no_poliza;

	LET	_cod_agente = NULL;
	LET _contador   = 0;

	FOREACH 
	 SELECT	cod_agente
	   INTO	_cod_agente
	   FROM	emipoagt
	  WHERE	no_poliza = _no_poliza
		EXIT FOREACH;
	END FOREACH

	IF _cod_agente IS NULL THEN
		LET _cod_agente = '';
	END IF

	FOREACH 
	 SELECT	cod_producto
	   INTO	_cod_producto
	   FROM	endeduni
	  WHERE	no_poliza = _no_poliza
		EXIT FOREACH;
	END FOREACH

	INSERT INTO tmp_siniest(
	no_poliza,           
	doc_poliza,
	cod_ramo,
	cod_subramo,
	cod_grupo,            
	prima_suscrita,      
	incurrido_bruto,     
	siniestro_pagado,    
	prima_pagada,
	cod_agente,
	cod_sucursal,
	cod_cliente,
	cod_producto
	)
	VALUES(
	_no_poliza,
	_doc_poliza,           
	_cod_ramo,            
	_cod_subramo,
	_cod_grupo,            
	_prima_suscrita,      
	_incurrido_bruto,     
	_siniestro_pagado,    
	_prima_pagada,      
	_cod_agente,
	_cod_sucursal,
	_cod_cliente,
	_cod_producto
	);

END FOREACH

END 

DROP TABLE tmp_montos;

END PROCEDURE;
