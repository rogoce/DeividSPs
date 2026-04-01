-- Procedimiento que Carga la Siniestralidad Por Poliza en un Periodo 
-- 
-- Creado    : 2001 - Autor: Amado Perez 
-- Modificado: 2001 - Autor: Amado Perez
--
-- SIS v.2.0 - DEIVID, S.A.

DROP PROCEDURE sp_rec60;

CREATE PROCEDURE "informix".sp_rec60(
a_compania CHAR(3),
a_agencia  CHAR(3),
a_periodo1 CHAR(7),
a_periodo2 CHAR(7)
)

DEFINE _no_poliza, _no_reclamo CHAR(10); 
DEFINE _cod_ramo     CHAR(3);  
DEFINE _cod_subramo  CHAR(3);  
DEFINE _cod_grupo    CHAR(5);  
DEFINE _doc_poliza   CHAR(20); 
DEFINE _numrecla     CHAR(18);
DEFINE _cod_sucursal CHAR(3);  
DEFINE _cod_coasegur CHAR(3);  
DEFINE _porcentaje   DEC(16,4);
DEFINE _cod_agente   CHAR(5); 
DEFINE _periodo      CHAR(7); 
DEFINE _fecha_siniestro DATE;
DEFINE _periodo_siniestro CHAR(7);

DEFINE v_filtros     CHAR(255);
DEFINE _count        INTEGER;
DEFINE _llave_poliza CHAR(10);
DEFINE _mes          CHAR(2);
DEFINE _ano          CHAR(4);

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
		no_poliza           CHAR(10)  NOT NULL,
		no_reclamo          CHAR(10)  NOT NULL,
		doc_poliza			CHAR(20)  NOT NULL,
		numrecla            CHAR(18)  NOT NULL,
		cod_ramo            CHAR(3)   NOT NULL,
		cod_subramo         CHAR(3)   NOT NULL,
		cod_grupo           CHAR(5)   NOT NULL,
		incurrido_bruto     DEC(16,2) NOT NULL,
		siniestro_pagado    DEC(16,2) NOT NULL,
		fronting            SMALLINT  DEFAULT 0 NOT NULL,
		cod_contrato       	CHAR(5),
		seleccionado        SMALLINT  DEFAULT 1 NOT NULL,
		cod_agente       	CHAR(5),
		cod_sucursal        CHAR(3)   NOT NULL,
		periodo             CHAR(7)	  NOT NULL,
		monto_90			DEC(16,2),
		fecha_siniestro   	DATE      NOT NULL
		) WITH NO LOG;

CREATE INDEX xie01_tmp_siniest ON tmp_siniest(no_poliza);

CREATE TEMP TABLE tmp_montos(
		no_poliza           CHAR(10)  NOT NULL,
		no_reclamo          CHAR(10)  NOT NULL,
		fecha_siniestro     DATE,
		incurrido_bruto     DEC(16,2) DEFAULT 0 NOT NULL,
		siniestro_pagado    DEC(16,2) DEFAULT 0 NOT NULL,
		monto_90			DEC(16,2),
		periodo             CHAR(7) NOT NULL
		) WITH NO LOG;

CREATE INDEX xie01_tmp_montos ON tmp_montos(no_poliza);	 

CREATE TEMP TABLE tmp_moros(
		no_poliza           CHAR(10)  NOT NULL,
		no_reclamo          CHAR(10)  NOT NULL,
		monto_90			DEC(16,2)
		) WITH NO LOG;

CREATE INDEX xie01_tmp_moros ON tmp_moros(no_poliza);


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
		SELECT incurrido_bruto,
	           pagado_bruto,
			   no_poliza,
			   no_reclamo,
			   periodo
	   	  INTO _incurrido_bruto,
	           _siniestro_pagado,
			   _no_poliza,
			   _no_reclamo,
			   _periodo
	   	  FROM tmp_sinis 
		 WHERE seleccionado = 1

		SELECT fecha_siniestro
		  INTO _fecha_siniestro
		  FROM recrcmae
		 WHERE no_reclamo = _no_reclamo;

		INSERT INTO tmp_montos(
		no_poliza, 
		no_reclamo, 
		fecha_siniestro,
		periodo,         
		incurrido_bruto,     
		siniestro_pagado
		)
		VALUES(
		_no_poliza,
		_no_reclamo,
		_fecha_siniestro,
		_periodo,
		_incurrido_bruto,     
		_siniestro_pagado
		);

	END FOREACH

	DROP TABLE tmp_sinis;

END

BEGIN

 --Morosidad

FOREACH
  SELECT no_poliza,
         no_reclamo,
         fecha_siniestro,
         periodo
	INTO _no_poliza,
	     _no_reclamo,
	     _fecha_siniestro,
	     _periodo
	FROM tmp_montos

  SELECT no_documento
	INTO _doc_poliza
	FROM emipomae
   WHERE no_poliza = _no_poliza;

   IF MONTH(_fecha_siniestro) >= 10 THEN
   	LET _mes = MONTH(_fecha_siniestro);
   ELSE
   	LET _mes = MONTH(_fecha_siniestro);
	LET _mes = '0'||_mes;
   END IF
   LET _ano = YEAR(_fecha_siniestro);
   LET _periodo_siniestro = _ano||_mes;
   LET _monto_90_tot = 0;

	CALL sp_cob33(
		 a_compania,
		 a_agencia,	
		 _doc_poliza,
		 _periodo_siniestro,
		 _fecha_siniestro
		 ) RETURNING _por_vencer_tot,       
    				 _exigible_tot,         
    				 _corriente_tot,        
    				 _monto_30_tot,         
    				 _monto_60_tot,         
    				 _monto_90_tot,
					 _saldo_tot;  

	INSERT INTO tmp_moros
    VALUES(_no_poliza,
	       _no_reclamo,
		   _monto_90_tot);

END FOREACH	

FOREACH
  SELECT no_poliza,
         no_reclamo,
		 SUM(monto_90)
	INTO _no_poliza,
	     _no_reclamo,
		 _monto_90_tot
    FROM tmp_moros
   GROUP BY no_poliza,no_reclamo

	UPDATE tmp_montos
	SET monto_90 = _monto_90_tot 
	WHERE no_poliza = _no_poliza
	  AND no_reclamo = _no_reclamo;

	LET _monto_90_tot = 0;

END FOREACH
 --
END


BEGIN

DEFINE _incurrido_bruto, _incurrido_bruto_agt   DECIMAL(16,2);
DEFINE _siniestro_pagado, _siniestro_pagado_agt DECIMAL(16,2);
DEFINE _monto_90, _monto_90_agt                 DECIMAL(16,2);

--SET DEBUG FILE TO "sp_rec60.trc";
--TRACE ON;


FOREACH 
 SELECT	SUM(incurrido_bruto),
		SUM(siniestro_pagado),
		SUM(monto_90),
 		no_poliza,
		no_reclamo
   INTO	_incurrido_bruto,
		_siniestro_pagado,
		_monto_90,
		_no_poliza,
		_no_reclamo
   FROM tmp_montos
  GROUP BY no_poliza,no_reclamo
  ORDER BY no_poliza,no_reclamo
  	
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

	SELECT numrecla,
	       periodo,
		   fecha_siniestro
	  INTO _numrecla,
	       _periodo,
		   _fecha_siniestro
	  FROM recrcmae 
	 WHERE no_reclamo = _no_reclamo;

	FOREACH 
		SELECT cod_agente,
		       porc_partic_agt
		  INTO _cod_agente,
			   _porc_partic_agt
		  FROM emipoagt
		 WHERE no_poliza = _no_poliza

		LET _incurrido_bruto_agt = 0;
        LET _siniestro_pagado_agt = 0;
		LET _monto_90_agt = 0;

		LET _incurrido_bruto_agt = _incurrido_bruto * _porc_partic_agt / 100;     
		LET _siniestro_pagado_agt = _siniestro_pagado * _porc_partic_agt / 100;    
		LET _monto_90_agt = _monto_90 * _porc_partic_agt / 100;        

		INSERT INTO tmp_siniest(
		no_poliza,   
		no_reclamo,        
		doc_poliza,
		numrecla,
		cod_ramo,
		cod_subramo,
		cod_grupo,            
		incurrido_bruto,     
		siniestro_pagado,    
		cod_agente,
		cod_sucursal,
		periodo,
		monto_90,
		fecha_siniestro        
		)
		VALUES(
		_no_poliza,
		_no_reclamo,
		_doc_poliza,
		_numrecla,           
		_cod_ramo,            
		_cod_subramo,
		_cod_grupo,            
		_incurrido_bruto_agt,     
		_siniestro_pagado_agt,    
		_cod_agente,
		_cod_sucursal,
		_periodo,
		_monto_90_agt,
		_fecha_siniestro        
		);

	END FOREACH

END FOREACH

END 

DROP TABLE tmp_montos;
DROP TABLE tmp_moros;

END PROCEDURE;
