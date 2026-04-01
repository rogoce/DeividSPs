-- Procedimiento que Carga la Siniestralidad Por Poliza en un Periodo 
-- 
-- Creado    : 2001 - Autor: Amado Perez 
-- Modificado: 2001 - Autor: Amado Perez
--
-- SIS v.2.0 - DEIVID, S.A.

DROP PROCEDURE sp_pro135;

CREATE PROCEDURE "informix".sp_pro135(
a_compania CHAR(3),
a_agencia  CHAR(3),
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
DEFINE _fecha_per1, _fecha_per2, _fecha_cancelacion, _fecha_emision  DATE;

DEFINE _saldo_tot         DEC(16,2);
DEFINE _por_vencer_tot    DEC(16,2);
DEFINE _exigible_tot      DEC(16,2);
DEFINE _corriente_tot     DEC(16,2);
DEFINE _monto_30_tot      DEC(16,2);
DEFINE _monto_60_tot      DEC(16,2);
DEFINE _monto_90_tot      DEC(16,2);
DEFINE _porc_partic_agt   DEC(5,2);
DEFINE _prima_suscrita    DEC(16,2);
DEFINE _suma_asegurada    DEC(16,2);
DEFINE mes 				  SMALLINT;

DEFINE mes1             CHAR(02);
DEFINE ano              CHAR(04);
DEFINE periodo1         CHAR(07);


SET ISOLATION TO DIRTY READ;

LET mes 			 = MONTH(a_fecha1);

IF mes <= 9 THEN
   LET mes1[1,1] = '0';
   LET mes1[2,2] = mes;
ELSE
   LET mes1 = _mes;
END IF

LET ano = YEAR(a_fecha1);
LET periodo1[1,4] = ano;
LET periodo1[5] = "-";
LET periodo1[6,7] = mes1;

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
		prima_suscrita      DEC(16,2) DEFAULT 0 NOT NULL,
		suma_asegurada      DEC(16,2) DEFAULT 0 NOT NULL,
		incurrido_bruto     DEC(16,2) DEFAULT 0 NOT NULL,
		siniestro_pagado    DEC(16,2) DEFAULT 0 NOT NULL,
		prima_pagada		DEC(16,2) DEFAULT 0 NOT NULL,
		fronting            SMALLINT  DEFAULT 0 NOT NULL,
		cod_contrato       	CHAR(5),
		seleccionado        SMALLINT  DEFAULT 1 NOT NULL,
		cod_sucursal        CHAR(3)   NOT NULL,
		monto_90			DEC(16,2),
		PRIMARY KEY (no_poliza)) WITH NO LOG;

--CREATE INDEX xie01_tmp_siniest ON tmp_siniest(no_poliza);

--		PRIMARY KEY (no_poliza)
--CREATE INDEX xie01_tmp_siniest ON tmp_siniest(cod_ramo);
--CREATE INDEX xie02_tmp_siniest ON tmp_siniest(cod_subramo);
--CREATE INDEX xie03_tmp_siniest ON tmp_siniest(cod_grupo);
--CREATE INDEX xie04_tmp_siniest ON tmp_siniest(doc_poliza);
--CREATE INDEX xie05_tmp_siniest ON tmp_siniest(cod_sucursal);

CREATE TEMP TABLE tmp_montos(
		no_poliza           CHAR(10)  NOT NULL,
		prima_suscrita      DEC(16,2) DEFAULT 0 NOT NULL,
		suma_asegurada      DEC(16,2) DEFAULT 0 NOT NULL,
		incurrido_bruto     DEC(16,2) DEFAULT 0 NOT NULL,
		siniestro_pagado    DEC(16,2) DEFAULT 0 NOT NULL,
		prima_pagada		DEC(16,2) DEFAULT 0 NOT NULL,
		monto_90			DEC(16,2),
		PRIMARY KEY (no_poliza)) WITH NO LOG;

--CREATE INDEX xie01_tmp_montos ON tmp_montos(no_poliza);

CREATE TEMP TABLE tmp_poliza(
        no_poliza           CHAR(10) NOT NULL,
		PRIMARY KEY (no_poliza)) WITH NO LOG;

--CREATE INDEX xie01_tmp_poliza ON tmp_poliza(no_poliza);


FOREACH WITH HOLD
  SELECT  a.no_poliza,
          a.fecha_cancelacion,
		  e.prima_suscrita,
		  e.suma_asegurada
     INTO _no_poliza,
          _fecha_cancelacion,
		  _prima_suscrita,
		  _suma_asegurada
         FROM emipomae a, endedmae e
	    WHERE a.cod_compania  = a_compania
	  	  AND a.cod_ramo in ('016')
	      AND (a.vigencia_final >= a_fecha1
		   OR a.vigencia_final IS NULL)
	      AND a.fecha_suscripcion <= a_fecha1
		  AND a.vigencia_inic < a_fecha1
		  AND a.actualizado = 1
		  AND e.no_poliza = a.no_poliza
		  AND e.periodo <= periodo1
		  AND e.fecha_emision <= a_fecha1
		  AND e.actualizado = 1

      LET _fecha_emision = null;

      IF _fecha_cancelacion <= a_fecha1 THEN
	     FOREACH
			SELECT fecha_emision
			  INTO _fecha_emision
			  FROM endedmae
			 WHERE no_poliza = _no_poliza
			   AND cod_endomov = '002'
			   AND vigencia_inic = _fecha_cancelacion
		 END FOREACH

		 IF  _fecha_emision <= a_fecha1 THEN
			CONTINUE FOREACH;
		 END IF
	  END IF

	BEGIN
		ON EXCEPTION IN(-239)
		 UPDATE tmp_montos
		        SET prima_suscrita  = prima_suscrita  + _prima_suscrita,
				    suma_asegurada  = suma_asegurada  + _suma_asegurada
		      WHERE no_poliza       = _no_poliza;
		END EXCEPTION

		INSERT INTO tmp_montos(
		no_poliza, 
		prima_suscrita,
		suma_asegurada
		)
		VALUES(
		_no_poliza,
		_prima_suscrita,
		_suma_asegurada
		);
	END

	BEGIN
		ON EXCEPTION IN(-239)
		END EXCEPTION
		INSERT INTO tmp_poliza(
		no_poliza
		)
		VALUES(
		_no_poliza
		);
	END

	END FOREACH



-- Incurrido Bruto y Sinestro Pagado

BEGIN

DEFINE _incurrido_bruto   DECIMAL(16,2);
DEFINE _siniestro_pagado  DECIMAL(16,2);

LET v_filtros = sp_pro135b(
				a_compania, 
				a_agencia, 
				periodo1, 
				a_fecha1
				);

 FOREACH
	SELECT x.incurrido_bruto,
           x.pagado_bruto,
		   y.no_poliza
   	  INTO _incurrido_bruto,
           _siniestro_pagado,
		   _no_poliza
   	  FROM tmp_sinis x, tmp_poliza y
	 WHERE x.no_poliza = y.no_poliza
	   AND seleccionado = 1

	BEGIN
		ON EXCEPTION IN(-239)
		 UPDATE tmp_montos
		        SET incurrido_bruto  = incurrido_bruto  + _incurrido_bruto,
				    siniestro_pagado = siniestro_pagado  + _siniestro_pagado
		      WHERE no_poliza       = _no_poliza;
		END EXCEPTION

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

	END

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
DEFINE _monto_90,_monto_90_agt,_suma_asegurada  DECIMAL(16,2);


FOREACH 
 SELECT SUM(prima_suscrita),
        SUM(suma_asegurada),
        SUM(prima_pagada),		
		SUM(incurrido_bruto),
		SUM(siniestro_pagado),
		SUM(monto_90),
 		no_poliza
   INTO	_prima_suscrita,
        _suma_asegurada,
		_prima_pagada,
		_incurrido_bruto,
		_siniestro_pagado,
		_monto_90,
		_no_poliza
   FROM tmp_montos
  GROUP BY no_poliza
  	
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

	INSERT INTO tmp_siniest(
	no_poliza,           
	doc_poliza,
	cod_ramo,
	cod_subramo,
	cod_grupo,            
	prima_suscrita,
	suma_asegurada,      
	incurrido_bruto,     
	siniestro_pagado,    
	prima_pagada,
	cod_sucursal,
	monto_90        
	)
	VALUES(
	_no_poliza,
	_doc_poliza,           
	_cod_ramo,            
	_cod_subramo,
	_cod_grupo,            
	_prima_suscrita, 
	_suma_asegurada,     
	_incurrido_bruto,     
	_siniestro_pagado,    
	_prima_pagada,      
	_cod_sucursal,
	_monto_90        
	);


END FOREACH

END 

DROP TABLE tmp_montos;

END PROCEDURE;
