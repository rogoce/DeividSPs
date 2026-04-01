-- Procedimiento que Carga la Siniestralidad Por Agente en un Periodo 
-- 
-- Creado    : 31/08/2000 - Autor: Demetrio Hurtado Almanza 
-- Modificado: 16/09/2000 - Autor: Demetrio Hurtado Almanza
--
-- SIS v.2.0 - DEIVID, S.A.

DROP PROCEDURE sp_rec16;

CREATE PROCEDURE "informix".sp_rec16(
a_compania CHAR(3),
a_agencia  CHAR(3),
a_periodo1 CHAR(7),
a_periodo2 CHAR(7)
)

DEFINE _cod_agente   CHAR(5);  
DEFINE _no_poliza    CHAR(10); 
DEFINE _cod_sucursal CHAR(3);  
DEFINE _cod_ramo     CHAR(3);  
DEFINE _cod_subramo  CHAR(3);  
DEFINE _cod_grupo    CHAR(5);  
DEFINE _doc_poliza   CHAR(20); 
DEFINE _porc_partic  DEC(16,2);

DEFINE v_filtros     CHAR(255);

DEFINE _count             INTEGER;

LET _count = 0;

-- Tabla Temporal 

CREATE TEMP TABLE tmp_siniest(
		cod_agente          CHAR(5)   NOT NULL,
		no_poliza           CHAR(10)  NOT NULL,
		doc_poliza			CHAR(20)  NOT NULL,
		cod_ramo            CHAR(3)   NOT NULL,
		cod_subramo         CHAR(3)   NOT NULL,
		cod_grupo           CHAR(5)   NOT NULL,
		prima_suscrita      DEC(16,2) NOT NULL,
		incurrido_bruto     DEC(16,2) NOT NULL,
		siniestro_pagado    DEC(16,2) NOT NULL,
		prima_pagada        DEC(16,2) NOT NULL,
		seleccionado        SMALLINT  DEFAULT 1 NOT NULL,
		cod_sucursal        CHAR(3)   NOT NULL,
		PRIMARY KEY (cod_agente, no_poliza)
		) WITH NO LOG;

CREATE INDEX xie01_tmp_siniest ON tmp_siniest(cod_ramo);

-- Primas Suscritas

SET ISOLATION TO DIRTY READ;

BEGIN

DEFINE _prima_susc     DECIMAL(16,2);
DEFINE _prima_susc_agt DECIMAL(16,2);

FOREACH 
 SELECT prima_suscrita,		
 		no_poliza,
 		cod_sucursal			
   INTO	_prima_susc,
		_no_poliza,
		_cod_sucursal	   	
   FROM endedmae
  WHERE cod_compania = a_compania
    AND actualizado  = 1
    AND periodo BETWEEN a_periodo1 AND a_periodo2

--LET _count = _count + 1;
--IF _count > 100 THEN
--	EXIT FOREACH;
--END IF

	SELECT cod_ramo,
	       cod_subramo,
		   cod_grupo,
		   no_documento
	  INTO _cod_ramo,
	       _cod_subramo,
		   _cod_grupo,
		   _doc_poliza
	  FROM emipomae
	 WHERE no_poliza = _no_poliza;

	FOREACH
	 SELECT cod_agente,
			porc_partic_agt
	   INTO	_cod_agente,
	        _porc_partic
	   FROM	emipoagt
	  WHERE	no_poliza = _no_poliza

			LET _prima_susc_agt = _prima_susc / 100 * _porc_partic; 

			BEGIN
			ON EXCEPTION IN(-239)

				UPDATE tmp_siniest
				   SET prima_suscrita = prima_suscrita + _prima_susc_agt
				 WHERE cod_agente = _cod_agente
				   AND no_poliza  = _no_poliza;

			END EXCEPTION

				INSERT INTO tmp_siniest(
				cod_agente,
				no_poliza,           
				doc_poliza,
				cod_ramo,
				cod_subramo,
				cod_grupo,            
				prima_suscrita,      
				incurrido_bruto,     
				siniestro_pagado,    
				prima_pagada,
				cod_sucursal        
				)
				VALUES(
				_cod_agente,
				_no_poliza,
				_doc_poliza,           
				_cod_ramo,            
				_cod_subramo,
				_cod_grupo,            
				_prima_susc_agt,      
				0,     
				0,    
				0,
				_cod_sucursal        
				);

			END

	END FOREACH -- Agentes

END FOREACH -- Facturas

END

-- Incurrido Bruto y Sinestro Pagado

LET _count = 0;

BEGIN

DEFINE _incurrido_bru     DECIMAL(16,2);
DEFINE _siniestro_pag     DECIMAL(16,2);
DEFINE _incurrido_bru_agt DECIMAL(16,2);
DEFINE _siniestro_pag_agt DECIMAL(16,2);

LET v_filtros = sp_rec01(
a_compania, 
a_agencia, 
a_periodo1, 
a_periodo2
); 

FOREACH 
 SELECT	incurrido_bruto,
        pagado_bruto,
		no_poliza,
	    cod_ramo,
        cod_subramo,
	    cod_grupo,
	    doc_poliza,
		cod_sucursal
   INTO	_incurrido_bru,
        _siniestro_pag,
		_no_poliza,
	    _cod_ramo,
        _cod_subramo,
	    _cod_grupo,
	    _doc_poliza,
		_cod_sucursal
   FROM	tmp_sinis

--LET _count = _count + 1;

--IF _count > 100 THEN
--	EXIT FOREACH;
--END IF

	FOREACH
	 SELECT cod_agente,
			porc_partic_agt
	   INTO	_cod_agente,
	        _porc_partic
	   FROM	emipoagt
	  WHERE	no_poliza = _no_poliza

			LET _incurrido_bru_agt = _incurrido_bru / 100 * _porc_partic; 
			LET _siniestro_pag_agt = _siniestro_pag / 100 * _porc_partic; 

			BEGIN
			ON EXCEPTION IN(-239)

				UPDATE tmp_siniest
				   SET incurrido_bruto  = incurrido_bruto  + _incurrido_bru_agt,
				       siniestro_pagado = siniestro_pagado + _siniestro_pag_agt
				 WHERE cod_agente = _cod_agente
				   AND no_poliza  = _no_poliza;

			END EXCEPTION

				INSERT INTO tmp_siniest(
				cod_agente,
				no_poliza,           
				doc_poliza,
				cod_ramo,
				cod_subramo,
				cod_grupo,            
				prima_suscrita,      
				incurrido_bruto,     
				siniestro_pagado,    
				prima_pagada,
				cod_sucursal        
				)
				VALUES(
				_cod_agente,
				_no_poliza,
				_doc_poliza,           
				_cod_ramo,            
				_cod_subramo,
				_cod_grupo,            
				0,      
				_incurrido_bru_agt,     
				_siniestro_pag_agt,    
				0,
				_cod_sucursal        
				);

			END

	END FOREACH

END FOREACH

DROP TABLE tmp_sinis;

END

-- Primas Pagadas

LET _count = 0;

BEGIN

DEFINE _no_remesa        CHAR(10);
DEFINE _renglon          SMALLINT;
DEFINE _prima_pagada     DECIMAL(16,2);
DEFINE _prima_pagada_agt DECIMAL(16,2);

FOREACH
 SELECT	no_remesa, 
 		no_poliza,
        monto,
		renglon,
		cod_sucursal
   INTO	_no_remesa,
   		_no_poliza,
        _prima_pagada,
		_renglon,
		_cod_sucursal
   FROM cobredet
  WHERE	cod_compania = a_compania
    AND actualizado  = 1
    AND tipo_mov IN ('P', 'N')
    AND periodo >= a_periodo1 
    AND periodo <= a_periodo2
    AND renglon <> 0

--LET _count = _count + 1;

--IF _count > 100 THEN
--	EXIT FOREACH;
--END IF

	SELECT cod_ramo,
	       cod_subramo,
		   cod_grupo,
		   no_documento
	  INTO _cod_ramo,
	       _cod_subramo,
		   _cod_grupo,
		   _doc_poliza
	  FROM emipomae
	 WHERE no_poliza = _no_poliza;

	FOREACH
	 SELECT cod_agente,
			porc_partic_agt
	   INTO	_cod_agente,
	        _porc_partic
	   FROM	cobreagt
	  WHERE	no_remesa = _no_remesa
	    AND renglon   = _renglon

			LET _prima_pagada_agt = _prima_pagada / 100 * _porc_partic; 

			BEGIN
			ON EXCEPTION IN(-239)

				UPDATE tmp_siniest
				   SET prima_pagada = prima_pagada + _prima_pagada_agt
				 WHERE cod_agente = _cod_agente
				   AND no_poliza  = _no_poliza;

			END EXCEPTION

				INSERT INTO tmp_siniest(
				cod_agente,
				no_poliza,
				doc_poliza,           
				cod_ramo,            
				cod_subramo,
				cod_grupo,            
				prima_suscrita,      
				incurrido_bruto,     
				siniestro_pagado,    
				prima_pagada,
				cod_sucursal        
				)
				VALUES(
				_cod_agente,
				_no_poliza,
				_doc_poliza,           
				_cod_ramo,            
				_cod_subramo,
				_cod_grupo,            
				0,
				0,
				0,
				_prima_pagada_agt,
				_cod_sucursal      
				);

			END

	END FOREACH -- Agentes

END FOREACH	-- Renglones de la Remesa

END

-- Cheques de Devolucion de Primas

BEGIN

DEFINE _no_requis        CHAR(10);     
DEFINE _prima_pagada     DECIMAL(16,2);
DEFINE _prima_pagada_agt DECIMAL(16,2);

FOREACH
 SELECT	no_requis,
		cod_sucursal
   INTO	_no_requis,
		_cod_sucursal
   FROM chqchmae
  WHERE	cod_compania  = a_compania 
    AND pagado        = 1 -- Cheque Pagado
	AND anulado       = 0 -- Cheque no este anulado
	AND origen_cheque = 6 -- Devolucion de Primas
    AND periodo BETWEEN a_periodo1 AND a_periodo2

	FOREACH
	 SELECT	no_poliza,
	        monto
	   INTO	_no_poliza,
			_prima_pagada
	   FROM	chqchpol
	  WHERE	no_requis = _no_requis

		SELECT cod_ramo,
		       cod_subramo,
			   cod_grupo,
			   no_documento
		  INTO _cod_ramo,
		       _cod_subramo,
			   _cod_grupo,
			   _doc_poliza
		  FROM emipomae
		 WHERE no_poliza = _no_poliza;

		LET _prima_pagada = _prima_pagada * -1;

		FOREACH
		 SELECT cod_agente,
				porc_partic_agt
		   INTO	_cod_agente,
		        _porc_partic
		   FROM	chqchpoa
		  WHERE	no_requis    = _no_requis
		    AND no_documento = _doc_poliza

				LET _prima_pagada_agt = _prima_pagada / 100 * _porc_partic; 

				BEGIN
				ON EXCEPTION IN(-239)

					UPDATE tmp_siniest
					   SET prima_pagada = prima_pagada + _prima_pagada_agt
					 WHERE cod_agente = _cod_agente
					   AND no_poliza  = _no_poliza;

				END EXCEPTION

					INSERT INTO tmp_siniest(
					cod_agente,
					no_poliza,  
					doc_poliza,         
					cod_ramo,            
					cod_subramo,
					cod_grupo,            
					prima_suscrita,      
					incurrido_bruto,     
					siniestro_pagado,    
					prima_pagada,
					cod_sucursal        
					)
					VALUES(
					_cod_agente,
					_no_poliza,
					_doc_poliza,           
					_cod_ramo,            
					_cod_subramo,
					_cod_grupo,            
					0,
					0,
					0,
					_prima_pagada_agt,
					_cod_sucursal
					);

				END

		END FOREACH -- Agentes

	END FOREACH	-- Polizas en el Cheque

END FOREACH	-- Cheques

END

END PROCEDURE;

