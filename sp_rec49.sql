-- Procedimiento que Carga la Siniestralidad Por Poliza en un Periodo 
-- 
-- Creado    : 2001 - Autor: Amado Perez 
-- Modificado: 2001 - Autor: Amado Perez
--
-- SIS v.2.0 - DEIVID, S.A.

DROP PROCEDURE sp_rec49;

CREATE PROCEDURE "informix".sp_rec49(
a_compania CHAR(3),
a_agencia  CHAR(3),
a_periodo1 CHAR(7),
a_periodo2 CHAR(7),
a_fecha1   DATE  
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
DEFINE _periodo      CHAR(7); 

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

SET ISOLATION TO DIRTY READ;

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
		periodo             CHAR(7)	  NOT NULL,
		monto_90			DEC(16,2)
		) WITH NO LOG;

CREATE INDEX xie01_tmp_siniest ON tmp_siniest(no_poliza);

--		PRIMARY KEY (no_poliza)
--CREATE INDEX xie01_tmp_siniest ON tmp_siniest(cod_ramo);
--CREATE INDEX xie02_tmp_siniest ON tmp_siniest(cod_subramo);
--CREATE INDEX xie03_tmp_siniest ON tmp_siniest(cod_grupo);
--CREATE INDEX xie04_tmp_siniest ON tmp_siniest(doc_poliza);
--CREATE INDEX xie05_tmp_siniest ON tmp_siniest(cod_sucursal);

CREATE TEMP TABLE tmp_montos(
		no_poliza           CHAR(10)  NOT NULL,
		prima_suscrita      DEC(16,2) DEFAULT 0 NOT NULL,
		incurrido_bruto     DEC(16,2) DEFAULT 0 NOT NULL,
		siniestro_pagado    DEC(16,2) DEFAULT 0 NOT NULL,
		prima_pagada		DEC(16,2) DEFAULT 0 NOT NULL,
		monto_90			DEC(16,2),
		periodo             CHAR(7) NOT NULL
		) WITH NO LOG;

CREATE INDEX xie01_tmp_montos ON tmp_montos(no_poliza);

CREATE TEMP TABLE tmp_poliza(
        no_poliza           CHAR(10) NOT NULL,
		periodo             CHAR(7)
		) WITH NO LOG;

CREATE INDEX xie01_tmp_poliza ON tmp_poliza(no_poliza);

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



BEGIN

DEFINE _prima_suscrita DECIMAL(16,2);

FOREACH 
 SELECT x.prima_suscrita,		
 		y.no_poliza,
		y.periodo
   INTO	_prima_suscrita,
		_no_poliza,
		_periodo
   FROM endedmae x, emipomae y
  WHERE x.cod_compania = a_compania
    AND x.actualizado  = 1
	AND y.no_poliza = x.no_poliza
	AND y.vigencia_inic >= a_fecha1
	AND y.nueva_renov = 'N'
	AND y.periodo >= a_periodo1
	AND y.periodo <= a_periodo2
	AND y.no_documento[3,4] >= a_periodo1[3,4]
	AND y.no_documento[3,4] <= a_periodo2[3,4]
	AND x.no_endoso = '00000'

--    AND x.fecha_emision >= _fecha_per1 
--    AND x.fecha_emision <= _fecha_per2

	INSERT INTO tmp_montos(
	no_poliza, 
	periodo,          
	prima_suscrita
	)
	VALUES(
	_no_poliza,
	_periodo,
	_prima_suscrita
	);

	INSERT INTO tmp_poliza(
	no_poliza,
	periodo
	)
	VALUES(
	_no_poliza,
	_periodo
	);


END FOREACH

END

-- Endosos de las polizas nuevas

BEGIN
	DEFINE _prima_suscrita DECIMAL(16,2);

	FOREACH
		SELECT no_poliza,
		       periodo 
		  INTO _no_poliza,
		       _periodo
		  FROM tmp_poliza
		FOREACH
			SELECT x.prima_suscrita		
			  INTO _prima_suscrita
			  FROM endedmae x
		     WHERE x.cod_compania = a_compania
			   AND x.no_poliza = _no_poliza
			   AND x.actualizado  = 1
			   AND x.vigencia_inic >= a_fecha1
			   AND x.periodo >= a_periodo1
			   AND x.periodo <= a_periodo2
			   AND x.no_endoso <> '00000'

--		       AND x.fecha_emision >= _fecha_per1 
--			   AND x.fecha_emision <= _fecha_per2

			IF  _prima_suscrita IS NOT NULL  AND _prima_suscrita <> 0 THEN	
				INSERT INTO tmp_montos(
				no_poliza, 
				periodo,          
				prima_suscrita
				)
				VALUES(
				_no_poliza,
				_periodo,
				_prima_suscrita
				);
			END IF
		END FOREACH
	END FOREACH
END


-- Primas Pagadas

BEGIN

DEFINE _no_remesa    CHAR(10);     
DEFINE _prima_pagada DEC(16,2);

FOREACH
 SELECT no_poliza,
  		periodo
   INTO _llave_poliza,
        _periodo
   FROM tmp_poliza

 FOREACH
 SELECT	no_poliza,
        prima_neta
   INTO	_no_poliza,
        _prima_pagada
   FROM cobredet
  WHERE	cod_compania = a_compania
  	AND	actualizado  = 1
    AND tipo_mov IN ('P', 'N')
	AND no_poliza   = _llave_poliza
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
	periodo,          
	prima_pagada
	)
	VALUES(
	_no_poliza,
	_periodo,
	_prima_pagada
	);

END FOREACH

END FOREACH
END

BEGIN
 --Morosidad
FOREACH
  SELECT no_poliza,
         periodo
	INTO _no_poliza,
	     _periodo
	FROM tmp_poliza
GROUP BY no_poliza, periodo

  SELECT no_documento
	INTO _doc_poliza
	FROM emipomae
   WHERE no_poliza = _no_poliza;

	CALL sp_cob33(
		 a_compania,
		 a_agencia,	
		 _doc_poliza,
		 a_periodo2,
		 _fecha_per2
		 ) RETURNING _por_vencer_tot,       
    				 _exigible_tot,         
    				 _corriente_tot,        
    				 _monto_30_tot,         
    				 _monto_60_tot,         
    				 _monto_90_tot,
					 _saldo_tot;  
					        
	INSERT INTO tmp_montos(
	no_poliza,  
	periodo,         
	monto_90     
	)
	VALUES(
	_no_poliza,
	_periodo,
	_monto_90_tot
	);

END FOREACH
 --
END

-- Incurrido Bruto y Sinestro Pagado

BEGIN

DEFINE _incurrido_bruto   DECIMAL(16,2);
DEFINE _siniestro_pagado  DECIMAL(16,2);

--FOREACH 

--SELECT no_poliza 
--  INTO _llave_poliza
--  FROM tmp_poliza

{LET v_filtros = sp_rec49b(
				a_compania, 					
				a_agencia, 
				a_periodo1, 
				a_periodo2,
				_llave_poliza
				);}
LET v_filtros = sp_rec49c(
				a_compania, 
				a_agencia, 
				a_periodo1, 
				a_periodo2
				);

 FOREACH
	SELECT x.incurrido_bruto,
           x.pagado_bruto,
		   y.no_poliza,
		   y.periodo
   	  INTO _incurrido_bruto,
           _siniestro_pagado,
		   _no_poliza,
		   _periodo
   	  FROM tmp_sinis x, tmp_poliza y
	 WHERE x.no_poliza = y.no_poliza
	   AND seleccionado = 1

	INSERT INTO tmp_montos(
	no_poliza,  
	periodo,         
	incurrido_bruto,     
	siniestro_pagado
	)
	VALUES(
	_no_poliza,
	_periodo,
	_incurrido_bruto,     
	_siniestro_pagado
	);

END FOREACH

DROP TABLE tmp_sinis;
DROP TABLE tmp_poliza;

--END FOREACH


END


BEGIN

DEFINE _incurrido_bruto,  _incurrido_bruto_agt  DECIMAL(16,2);
DEFINE _siniestro_pagado, _siniestro_pagado_agt DECIMAL(16,2);
DEFINE _prima_suscrita,   _prima_suscrita_agt   DECIMAL(16,2);
DEFINE _prima_pagada, _prima_pagada_agt         DECIMAL(16,2);
DEFINE _monto_90, _monto_90_agt                 DECIMAL(16,2);


FOREACH 
 SELECT SUM(prima_suscrita),
        SUM(prima_pagada),		
		SUM(incurrido_bruto),
		SUM(siniestro_pagado),
		SUM(monto_90),
 		no_poliza,
		periodo
   INTO	_prima_suscrita,
		_prima_pagada,
		_incurrido_bruto,
		_siniestro_pagado,
		_monto_90,
		_no_poliza,
		_periodo
   FROM tmp_montos
  GROUP BY no_poliza,periodo
  	
	SELECT cod_ramo,
	       cod_subramo,
		   cod_grupo,
		   no_documento,
		   cod_sucursal
	  INTO _cod_ramo,
	       _cod_subramo,
		   _cod_grupo,
		   _doc_poliza,
		   _cod_sucursal
	  FROM emipomae
	 WHERE no_poliza = _no_poliza;

	FOREACH 
		SELECT cod_agente,
		       porc_partic_agt
		  INTO _cod_agente,
			   _porc_partic_agt
		  FROM emipoagt
		 WHERE no_poliza = _no_poliza

--	    IF _cod_agente IS NULL THEN
--		   LET _cod_agente = '';
--		END IF

        LET _prima_suscrita_agt = 0;
		LET _incurrido_bruto_agt = 0;
        LET _siniestro_pagado_agt = 0;
		LET _prima_pagada_agt = 0;
		LET _monto_90_agt = 0;

		LET _prima_suscrita_agt = _prima_suscrita * _porc_partic_agt / 100;
		LET _incurrido_bruto_agt = _incurrido_bruto * _porc_partic_agt / 100;     
		LET _siniestro_pagado_agt = _siniestro_pagado * _porc_partic_agt / 100;    
		LET _prima_pagada_agt = _prima_pagada * _porc_partic_agt / 100;      
		LET _monto_90_agt = _monto_90 * _porc_partic_agt / 100;        

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
		periodo,
		monto_90        
		)
		VALUES(
		_no_poliza,
		_doc_poliza,           
		_cod_ramo,            
		_cod_subramo,
		_cod_grupo,            
		_prima_suscrita_agt,      
		_incurrido_bruto_agt,     
		_siniestro_pagado_agt,    
		_prima_pagada_agt,      
		_cod_agente,
		_cod_sucursal,
		_periodo,
		_monto_90_agt        
		);

	END FOREACH

END FOREACH

END 

DROP TABLE tmp_montos;

END PROCEDURE;
