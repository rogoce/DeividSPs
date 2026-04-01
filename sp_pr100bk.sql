-- Seguro Obligatorio - APADEA 
-- Creado   :  26/10/2011 - Autor:  Giron Henry 
-- SIS v.2.0 d_- DEIVID, S.A.
-- execute procedure sp_pr100("001","001","2011-01","2011-01","020;")

DROP PROCEDURE sp_pr100;
CREATE PROCEDURE "informix".sp_pr100(
a_compania CHAR(3),
a_agencia  CHAR(3),
a_periodo1 CHAR(7),
a_periodo2 CHAR(7),
a_ramo     CHAR(255) DEFAULT '*'
)
RETURNING char(7),integer,dec(16,2),dec(16,2);

DEFINE _no_poliza    	CHAR(10); 
DEFINE _cod_ramo     	CHAR(3);  
DEFINE _cod_subramo  	CHAR(3);  
DEFINE _cod_grupo    	CHAR(5);  
DEFINE _doc_poliza   	CHAR(20); 
DEFINE _cod_sucursal 	CHAR(3);  
DEFINE _cod_coasegur 	CHAR(3);  
DEFINE _porcentaje   	DEC(16,4);
DEFINE _cod_agente   	CHAR(5);
DEFINE _cod_cliente  	CHAR(10); 
DEFINE _porc_comis_agt 	DEC(5,2);
DEFINE v_filtros     	CHAR(255);
DEFINE _count        	INTEGER;
DEFINE _contador     	INT;
define _cod_tipoprod	char(3);
DEFINE _periodo1        char(7);
DEFINE _periodo         char(7);

SET ISOLATION TO DIRTY READ;
SELECT par_ase_lider
  INTO _cod_coasegur
  FROM parparam
 WHERE cod_compania = a_compania;
   
-- Tabla Temporal
{CREATE TEMP TABLE tmp_siniest(
		no_poliza           CHAR(10)  NOT NULL,
		doc_poliza			CHAR(20)  NOT NULL,
		cod_ramo            CHAR(3)   NOT NULL,
		cod_subramo         CHAR(3)   NOT NULL,
		cod_grupo           CHAR(5)   NOT NULL,
		prima_suscrita      DEC(16,2) NOT NULL,
		comis_suscrita      DEC(16,2) NOT NULL,
		incurrido_bruto     DEC(16,2) NOT NULL,
		siniestro_pagado    DEC(16,2) NOT NULL,
		prima_pagada		DEC(16,2) NOT NULL,
		comis_pagada        DEC(16,2) NOT NULL,
		fronting            SMALLINT  DEFAULT 0 NOT NULL,
		cod_contrato       	CHAR(5),
		seleccionado        SMALLINT  DEFAULT 1 NOT NULL,
		cod_agente       	CHAR(5),
		cod_sucursal        CHAR(3)   NOT NULL,
		cod_cliente			CHAR(10),
		cod_tipoprod		char(3)
		) WITH NO LOG;

CREATE INDEX xie01_tmp_siniest ON tmp_siniest(no_poliza);  }

CREATE TEMP TABLE tmp_montos(
		no_poliza           CHAR(10)  NOT NULL,
		periodo	       		CHAR(7)   NOT NULL,
		prima_suscrita      DEC(16,2) DEFAULT 0 NOT NULL,
		incurrido_bruto     DEC(16,2) DEFAULT 0 NOT NULL,
		siniestro_pagado    DEC(16,2) DEFAULT 0 NOT NULL,
		prima_pagada		DEC(16,2) DEFAULT 0 NOT NULL,
		tipo			    char(1)
		) WITH NO LOG;

CREATE INDEX xie01_tmp_montos ON tmp_montos(no_poliza,periodo);

-- Primas Suscritas
-- SET DEBUG FILE TO "\\nemesis\ancon\Store Procedures\Debug\sp_rec14.trc"; --  Nombre de la Compania
-- TRACE ON;


BEGIN

DEFINE _prima_suscrita DECIMAL(16,2);

LET v_filtros = sp_pro34(a_compania,a_agencia,a_periodo1,a_periodo2,"*","*","*","*",a_ramo,"*",1);
-- a_codsucursal,a_codgrupo,a_codagente,a_codusuario,a_codramo,a_reaseguro, a_tipopol)
-- RETURNING v_filtros;

FOREACH 
 SELECT prima,		
 		no_poliza
   INTO	_prima_suscrita,
		_no_poliza
   FROM temp_det 
  WHERE seleccionado = 1

   select periodo
	 into _periodo
	 from emipomae
	where no_poliza = _no_poliza;

	INSERT INTO tmp_montos(
	no_poliza, 
	periodo,          
	prima_suscrita,
	tipo
	)
	VALUES(
	_no_poliza,
	_periodo,
	_prima_suscrita,
	"1"
	);

END FOREACH

{FOREACH 
 SELECT prima_suscrita,		
 		no_poliza,
		periodo
   INTO	_prima_suscrita,
		_no_poliza,
		_periodo
   FROM endedmae 
  WHERE cod_compania = a_compania
    AND actualizado  = 1
    AND periodo      >= a_periodo1 
    AND periodo      <= a_periodo2

	INSERT INTO tmp_montos(
	no_poliza, 
	periodo,          
	prima_suscrita,
	tipo
	)
	VALUES(
	_no_poliza,
	_periodo,
	_prima_suscrita,
	"1"
	);

END FOREACH	  }

END


-- Incurrido Bruto y Sinestro Pagado

BEGIN

DEFINE _incurrido_bruto  DECIMAL(16,2);
DEFINE _siniestro_pagado DECIMAL(16,2);

LET v_filtros = sp_pro178c(
				a_compania, 
				a_agencia, 
				a_periodo1, 
				a_periodo2,
				'*',
				'*',
				a_ramo
				); 

FOREACH 
 SELECT	incurrido_bruto,
        pagado_bruto,
		no_poliza,
		periodo
   INTO	_incurrido_bruto,
        _siniestro_pagado,
		_no_poliza,
		_periodo
   FROM	tmp_sinis
  WHERE seleccionado = 1


	INSERT INTO tmp_montos(
	no_poliza,  
	periodo,         
	incurrido_bruto,     
	siniestro_pagado,
	tipo
	)
	VALUES(
	_no_poliza,
	_periodo,
	_incurrido_bruto,     
	_siniestro_pagado,
	"2"
	);

END FOREACH
DROP TABLE tmp_sinis;
END

---*****
BEGIN

DEFINE _incurrido_bruto  DECIMAL(16,2);
DEFINE _siniestro_pagado DECIMAL(16,2);
DEFINE _prima_suscrita   DECIMAL(16,2);
DEFINE _prima_pagada     DECIMAL(16,2);
DEFINE _cant_poliza      integer;
DEFINE _periodo          char(7);

--SET DEBUG FILE TO "\\nemesis\ancon\Store Procedures\Debug\sp_rec14.trc";-- Nombre de la Compania
--TRACE ON;

FOREACH 
 SELECT SUM(prima_suscrita),
        SUM(prima_pagada),		
		SUM(incurrido_bruto),
		SUM(siniestro_pagado),
 		COUNT(distinct no_poliza),
		periodo
   INTO	_prima_suscrita,
		_prima_pagada,
		_incurrido_bruto,
		_siniestro_pagado,
		_cant_poliza,
		_periodo
   FROM tmp_montos
  GROUP BY periodo
  ORDER BY periodo asc

 	return _periodo,_cant_poliza,_prima_suscrita,_incurrido_bruto with resume;  	
 
END FOREACH

END 

--DROP TABLE tmp_montos;

END PROCEDURE;
