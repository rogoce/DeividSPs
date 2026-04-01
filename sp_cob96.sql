--excluye coaseguro minoritario y reaseguro asumido

DROP PROCEDURE sp_cob96;

CREATE PROCEDURE "informix".sp_cob96(
a_compania CHAR(3),
a_agencia  CHAR(3),
a_periodo1 CHAR(7),
a_periodo2 CHAR(7)
)

DEFINE _no_poliza    CHAR(10); 
DEFINE _cod_ramo     CHAR(3);  
DEFINE _cod_coasegur CHAR(3);  
DEFINE _porcentaje   DEC(16,4);
DEFINE _periodo      CHAR(7); 
DEFINE v_filtros     CHAR(255);
DEFINE _porc_comis_agt   DEC(5,2);

SET ISOLATION TO DIRTY READ;

SELECT par_ase_lider
  INTO _cod_coasegur
  FROM parparam
 WHERE cod_compania = a_compania;
   
-- Tabla Temporal 

CREATE TEMP TABLE tmp_siniest(
		no_poliza           CHAR(10)  NOT NULL,
		cod_ramo            CHAR(3)   NOT NULL,
		siniestro_pagado    DEC(16,2) DEFAULT 0 NOT NULL,
		prima_pagada		DEC(16,2) DEFAULT 0 NOT NULL,
		seleccionado        SMALLINT  DEFAULT 1 NOT NULL,
		comision			DEC(16,2) DEFAULT 0 NOT NULL
		) WITH NO LOG;

CREATE INDEX xie01_tmp_siniest ON tmp_siniest(no_poliza);
CREATE INDEX xie03_tmp_siniest ON tmp_siniest(cod_ramo);
CREATE INDEX xie02_tmp_siniest ON tmp_siniest(seleccionado);

CREATE TEMP TABLE tmp_inter(
		no_poliza           CHAR(10)  NOT NULL,
		siniestro_pagado    DEC(16,2) DEFAULT 0 NOT NULL,
		prima_pagada		DEC(16,2) DEFAULT 0 NOT NULL,
		PRIMARY KEY (no_poliza)
		) WITH NO LOG;

-- Primas Pagadas

BEGIN

DEFINE _no_remesa    CHAR(10);
DEFINE _prima_pagada DEC(16,2);
DEFINE v_tipo_produccion,_flag INTEGER;
DEFINE v_cod_tipoprod    CHAR(3);
DEFINE _siniestro_pagado  DECIMAL(16,2);
LET _siniestro_pagado = 0;

FOREACH
    SELECT no_poliza,
	       prima_neta
	  INTO _no_poliza,
	       _prima_pagada
	  FROM cobredet
	 WHERE cod_compania = a_compania
	   AND actualizado  = 1
	   AND tipo_mov IN ('P', 'N', 'X')
	   AND periodo     >= a_periodo1 
	   AND periodo     <= a_periodo2
	   AND renglon     <> 0

	SELECT cod_tipoprod
	  INTO v_cod_tipoprod
	  FROM emipomae
	 WHERE no_poliza = _no_poliza;

    SELECT tipo_produccion
	  INTO v_tipo_produccion
	  FROM emitipro
	 WHERE cod_tipoprod = v_cod_tipoprod;

	 IF v_tipo_produccion = 4 OR   --reaseg asumido
	 	v_tipo_produccion = 3 THEN --coaseguro minoritario
		 CONTINUE FOREACH;
	 END IF

	BEGIN
		ON EXCEPTION IN(-239)

			UPDATE tmp_inter
			   SET prima_pagada  = prima_pagada  + _prima_pagada
			 WHERE no_poliza     = _no_poliza;

			CONTINUE FOREACH;

		END EXCEPTION

		INSERT INTO tmp_inter(
		no_poliza, 
		prima_pagada
		)
		VALUES(
		_no_poliza,
		_prima_pagada
		);
		--busca siniestros pagados
		LET v_filtros = sp_co96b(
						a_compania, 
						a_agencia, 
						a_periodo1, 
						a_periodo2,
						_no_poliza
						);

		SELECT SUM(pagado_bruto)
		  INTO _siniestro_pagado
	      FROM tmp_sinis
		 WHERE no_poliza    = _no_poliza
		   AND seleccionado = 1;

		IF _siniestro_pagado IS NULL THEN
			LET _siniestro_pagado = 0;
		END IF

		UPDATE tmp_inter
		   SET siniestro_pagado = _siniestro_pagado	
		 WHERE no_poliza        = _no_poliza;

		DROP TABLE tmp_sinis;
	END
END FOREACH

END

BEGIN

DEFINE _prima_pagada, _comision_pagada,_siniestro_pagado DECIMAL(16,2);
DEFINE _cod_agente CHAR(5);

FOREACH
 SELECT prima_pagada,
		siniestro_pagado,
 		no_poliza
   INTO	_prima_pagada,
		_siniestro_pagado,
		_no_poliza
   FROM tmp_inter
  	
	SELECT cod_ramo
	  INTO _cod_ramo
	  FROM emipomae
	 WHERE no_poliza = _no_poliza;

	LET _comision_pagada = 0;

	FOREACH 
		SELECT cod_agente,
		       porc_comis_agt
		  INTO _cod_agente,
			   _porc_comis_agt
		  FROM emipoagt
		 WHERE no_poliza = _no_poliza

		LET _comision_pagada = _comision_pagada + (_prima_pagada * _porc_comis_agt / 100);

	END FOREACH

		INSERT INTO tmp_siniest(
		no_poliza,           
		cod_ramo,
		siniestro_pagado,    
		prima_pagada,
		comision
		)
		VALUES(
		_no_poliza,
		_cod_ramo,            
		_siniestro_pagado,
		_prima_pagada,
		_comision_pagada
		);

END FOREACH

DROP TABLE tmp_inter;
END

END PROCEDURE;