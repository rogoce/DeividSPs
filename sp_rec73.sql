-- Procedimiento que Carga la Siniestralidad Por Poliza en un Periodo 
-- 
-- Creado    : 2001 - Autor: Amado Perez 
-- Modificado: 2001 - Autor: Amado Perez
--
-- SIS v.2.0 - DEIVID, S.A.

DROP PROCEDURE sp_rec73;

CREATE PROCEDURE "informix".sp_rec73(
a_compania CHAR(3),
a_agencia  CHAR(3),
a_periodo1 CHAR(7),
a_periodo2 CHAR(7)
)

DEFINE _no_poliza, _no_reclamo  CHAR(10); 
DEFINE _cod_ramo     CHAR(3);  
DEFINE _cod_subramo  CHAR(3);  
DEFINE _cod_grupo    CHAR(5);  
DEFINE _doc_poliza   CHAR(20); 
DEFINE _numrecla     CHAR(18);
DEFINE _cod_sucursal CHAR(3);
DEFINE _tipo_produccion CHAR(1);  
DEFINE _cod_coasegur, _cod_tipoprod CHAR(3);  
DEFINE _porcentaje   DEC(16,4);
DEFINE _cod_agente   CHAR(5); 
DEFINE _periodo      CHAR(7); 
DEFINE _fecha_reclamo DATE;

DEFINE v_filtros     CHAR(255);
DEFINE _count        INTEGER;
DEFINE _llave_poliza CHAR(10);
DEFINE _mes          INT;
DEFINE _fecha_per1, _fecha_per2  DATE;

DEFINE _saldo_tot         DEC(16,2);
DEFINE _por_vencer_tot    DEC(16,2);
DEFINE _exigible_tot      DEC(16,2);
DEFINE _corriente_tot     DEC(16,2);
DEFINE _monto_30_tot      DEC(16,2);
DEFINE _monto_60_tot      DEC(16,2);
DEFINE _monto_90_tot      DEC(16,2);
DEFINE _porc_partic_agt   DEC(5,2);

SELECT par_ase_lider
  INTO _cod_coasegur
  FROM parparam
 WHERE cod_compania = a_compania;
   
-- Tabla Temporal 

CREATE TEMP TABLE tmp_siniest(
		no_reclamo          CHAR(10)  NOT NULL,
		numrecla            CHAR(20)  NOT NULL,
		fecha_reclamo       DATE,
		no_poliza           CHAR(10)  NOT NULL,
		doc_poliza			CHAR(20)  NOT NULL,
		cod_ramo            CHAR(3)   NOT NULL,
		cod_subramo         CHAR(3)   NOT NULL,
		cod_grupo           CHAR(5)   NOT NULL,
		prima_suscrita      DEC(16,2) DEFAULT 0 NOT NULL,
		incurrido_bruto     DEC(16,2) DEFAULT 0 NOT NULL,
		siniestro_pagado    DEC(16,2) DEFAULT 0 NOT NULL,
		prima_pagada		DEC(16,2) DEFAULT 0 NOT NULL,
		fronting            SMALLINT  DEFAULT 0 NOT NULL,
		cod_contrato       	CHAR(5),
		seleccionado        SMALLINT  DEFAULT 1 NOT NULL,
		cod_agente       	CHAR(5),
		cod_sucursal        CHAR(3)   NOT NULL,
		periodo             CHAR(7)	  NOT NULL,
		monto_30			DEC(16,2) DEFAULT 0,
		monto_60			DEC(16,2) DEFAULT 0,
		monto_90			DEC(16,2) DEFAULT 0,
		tipo_produccion     CHAR(1)
		) WITH NO LOG;

CREATE INDEX xie01_tmp_siniest ON tmp_siniest(no_reclamo, no_poliza);

--		PRIMARY KEY (no_poliza)
--CREATE INDEX xie01_tmp_siniest ON tmp_siniest(cod_ramo);
--CREATE INDEX xie02_tmp_siniest ON tmp_siniest(cod_subramo);
--CREATE INDEX xie03_tmp_siniest ON tmp_siniest(cod_grupo);
--CREATE INDEX xie04_tmp_siniest ON tmp_siniest(doc_poliza);
--CREATE INDEX xie05_tmp_siniest ON tmp_siniest(cod_sucursal);

CREATE TEMP TABLE tmp_montos(
        no_reclamo          CHAR(10)  NOT NULL,
		no_poliza           CHAR(10)  NOT NULL,
		prima_suscrita      DEC(16,2) DEFAULT 0 NOT NULL,
		incurrido_bruto     DEC(16,2) DEFAULT 0 NOT NULL,
		siniestro_pagado    DEC(16,2) DEFAULT 0 NOT NULL,
		prima_pagada		DEC(16,2) DEFAULT 0 NOT NULL,
		monto_30            DEC(16,2),
		monto_60            DEC(16,2),
		monto_90			DEC(16,2)
		) WITH NO LOG;

--CREATE INDEX xie01_tmp_montos ON tmp_montos(no_reclamo, no_poliza);


LET _fecha_per1 = MDY(a_periodo1[6,7],'01',a_periodo1[1,4]);

LET _mes = 	a_periodo2[6,7];

IF _mes = 2 THEN
   LET _fecha_per2 = MDY(a_periodo2[6,7],'28',a_periodo2[1,4]);
ELIF _mes = 4  OR	-- Verificaciones para Abril
	 _mes = 6  OR	-- Verificaciones para Junio
	 _mes = 9  OR	-- Verificaciones para Septiembre-- Primas Suscritas
	 _mes = 11 THEN	-- Verificaciones para Noviembre
   LET _fecha_per2 = MDY(a_periodo2[6,7],'30',a_periodo2[1,4]);
ELSE
   LET _fecha_per2 = MDY(a_periodo2[6,7],'31',a_periodo2[1,4]);
END IF





-- Incurrido Bruto y Sinestro Pagado

BEGIN

DEFINE _incurrido_bruto   DECIMAL(16,2);
DEFINE _siniestro_pagado  DECIMAL(16,2);

LET v_filtros = sp_rec73c(
				a_compania, 
				a_agencia, 
				a_periodo1, 
				a_periodo2
				);

 FOREACH
	SELECT x.no_reclamo,
	       x.incurrido_bruto,
           x.pagado_bruto,
		   x.no_poliza
   	  INTO _no_reclamo,
   	       _incurrido_bruto,
           _siniestro_pagado,
		   _no_poliza
   	  FROM tmp_sinis x
	 WHERE seleccionado = 1
	   AND pagado_bruto <> 0

	INSERT INTO tmp_montos(
	no_reclamo,
	no_poliza,  
	incurrido_bruto,     
	siniestro_pagado
	)
	VALUES(
	_no_reclamo,
	_no_poliza,
	_incurrido_bruto,     
	_siniestro_pagado
	);

END FOREACH

--DROP TABLE tmp_sinis;

--END FOREACH


END

BEGIN
 --Morosidad
FOREACH
  SELECT no_reclamo,
         no_poliza,
         fecha_reclamo,
		 periodo
	INTO _no_reclamo,
	     _no_poliza,
	     _fecha_reclamo,
		 _periodo
	FROM tmp_sinis
   WHERE seleccionado = 1
     AND pagado_bruto <> 0

--GROUP BY no_reclamo, no_poliza

  SELECT no_documento
	INTO _doc_poliza
	FROM emipomae
   WHERE no_poliza = _no_poliza;

	CALL sp_cob33(
		 a_compania,
		 a_agencia,	
		 _doc_poliza,
		 _periodo,
		 _fecha_reclamo
		 ) RETURNING _por_vencer_tot,       
    				 _exigible_tot,         
    				 _corriente_tot,        
    				 _monto_30_tot,         
    				 _monto_60_tot,         
    				 _monto_90_tot,
					 _saldo_tot;  
					        
	INSERT INTO tmp_montos(
	no_reclamo,
	no_poliza,  
	monto_30,
	monto_60,
	monto_90     
	)
	VALUES(
	_no_reclamo,
	_no_poliza,
	_monto_30_tot,
	_monto_60_tot,
	_monto_90_tot
	);

END FOREACH
 --
DROP TABLE tmp_sinis;


END


BEGIN

DEFINE _incurrido_bruto,  _incurrido_bruto_agt  DECIMAL(16,2);
DEFINE _siniestro_pagado, _siniestro_pagado_agt DECIMAL(16,2);
DEFINE _prima_suscrita,   _prima_suscrita_agt   DECIMAL(16,2);
DEFINE _prima_pagada, _prima_pagada_agt         DECIMAL(16,2);
DEFINE _monto_30, _monto_30_agt                 DECIMAL(16,2);
DEFINE _monto_60, _monto_60_agt                 DECIMAL(16,2);
DEFINE _monto_90, _monto_90_agt                 DECIMAL(16,2);

FOREACH 
 SELECT SUM(prima_suscrita),
        SUM(prima_pagada),		
		SUM(incurrido_bruto),
		SUM(siniestro_pagado),
		SUM(monto_30),
		SUM(monto_60),
		SUM(monto_90),
 		no_poliza,
		no_reclamo
   INTO	_prima_suscrita,
		_prima_pagada,
		_incurrido_bruto,
		_siniestro_pagado,
		_monto_30,
		_monto_60,
		_monto_90,
		_no_poliza,
		_no_reclamo
   FROM tmp_montos
  GROUP BY no_reclamo, no_poliza
  	
	SELECT cod_ramo,
	       cod_subramo,
		   cod_grupo,
		   no_documento,
		   cod_sucursal,
		   cod_tipoprod
	  INTO _cod_ramo,
	       _cod_subramo,
		   _cod_grupo,
		   _doc_poliza,
		   _cod_sucursal,
		   _cod_tipoprod
	  FROM emipomae
	 WHERE no_poliza = _no_poliza;

    SELECT tipo_produccion	
      INTO _tipo_produccion
      FROM emitipro
     WHERE cod_tipoprod = _cod_tipoprod;

	IF _tipo_produccion = '4' THEN
		CONTINUE FOREACH;
	END IF

	SELECT numrecla,
	       periodo
	  INTO _numrecla,
	       _periodo
	  FROM recrcmae
	 WHERE no_reclamo = _no_reclamo;

		INSERT INTO tmp_siniest(
		no_reclamo,
		numrecla,
		no_poliza,           
		doc_poliza,
		cod_ramo,
		cod_subramo,
		cod_grupo,            
		prima_suscrita,      
		incurrido_bruto,     
		siniestro_pagado,    
		prima_pagada,
		cod_sucursal,
		periodo,
		monto_30,        
		monto_60,        
		monto_90,
		tipo_produccion        
		)
		VALUES(
		_no_reclamo,
		_numrecla,
		_no_poliza,
		_doc_poliza,           
		_cod_ramo,            
		_cod_subramo,
		_cod_grupo,            
		_prima_suscrita,      
		_incurrido_bruto,     
		_siniestro_pagado,    
		_prima_pagada,      
		_cod_sucursal,
		_periodo,
		_monto_30,
		_monto_60,        
		_monto_90,
		_tipo_produccion        
		);

--	END FOREACH

END FOREACH

END 

DROP TABLE tmp_montos;

END PROCEDURE;
