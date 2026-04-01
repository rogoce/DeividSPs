-- Creado   :  06/07/2018 - Autor:  Giron Henry 
-- SIS v.2.0 d_- DEIVID, S.A.
-- execute procedure sp_pro1020("001","001","2011-01","2011-01","001,003;")

DROP PROCEDURE sp_pro1020;
CREATE PROCEDURE "informix".sp_pro1020(
a_compania CHAR(3),
a_agencia  CHAR(3),
a_periodo1 CHAR(7),
a_periodo2 CHAR(7),
a_ramo     CHAR(255) DEFAULT '*'
)
RETURNING char(7) as periodo,
integer as cant_poliza,
dec(16,2) as prima_suscrita,
dec(16,2) as incurrido_bruto,
INTEGER as cant_unidades,
INTEGER as cant_sin_pagado,
char(4) as periodo2,
char(3) as cod_ramo;

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
define _cant_unidades   INTEGER;
define _cant_sin_pagado INTEGER;
DEFINE _no_documento    CHAR(20);

SET ISOLATION TO DIRTY READ;
SELECT par_ase_lider
  INTO _cod_coasegur
  FROM parparam
 WHERE cod_compania = a_compania;
   
-- Tabla Temporal
drop table if exists tmp_datos6;	
CREATE TEMP TABLE tmp_datos6(
		no_poliza           CHAR(10)  NOT NULL,
		no_documento        CHAR(20)  NOT NULL,
		cod_ramo            CHAR(3)   NOT NULL,		
		periodo	       		CHAR(7)   NOT NULL,
		prima_suscrita      DEC(16,2) DEFAULT 0 NOT NULL,
		incurrido_bruto     DEC(16,2) DEFAULT 0 NOT NULL,
		siniestro_pagado    DEC(16,2) DEFAULT 0 NOT NULL,
		prima_pagada		DEC(16,2) DEFAULT 0 NOT NULL,
		tipo			    char(1),
		cant_unidades       INTEGER DEFAULT 0,
		cant_sin_pagado     INTEGER DEFAULT 0 
		) WITH NO LOG;

CREATE INDEX xie01_tmp_datos6 ON tmp_datos6(no_poliza,periodo);

-- Primas Suscritas
-- SET DEBUG FILE TO "\\nemesis\ancon\Store Procedures\Debug\sp_rec14.trc"; --  Nombre de la Compania
-- TRACE ON;


BEGIN

DEFINE _prima_suscrita DECIMAL(16,2);
let _cant_unidades = 0;
let _cant_sin_pagado = 0;

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

   select periodo,no_documento,cod_ramo
	 into _periodo, _no_documento,_cod_ramo
	 from emipomae
	where no_poliza = _no_poliza;
	
    select count(*)
	  into _cant_unidades 
	  from emipouni
	 where no_poliza = _no_poliza;	

	INSERT INTO tmp_datos6(
	no_poliza, no_documento,cod_ramo,
	periodo,          
	prima_suscrita,
	tipo,
	cant_unidades,
	cant_sin_pagado
	)
	VALUES(
	_no_poliza,_no_documento,_cod_ramo,
	_periodo,
	_prima_suscrita,
	"1",
	_cant_unidades,
	_cant_sin_pagado
	);

END FOREACH



END


-- Incurrido Bruto y Sinestro Pagado

BEGIN

DEFINE _incurrido_bruto  DECIMAL(16,2);
DEFINE _siniestro_pagado DECIMAL(16,2);
let _cant_unidades = 0;
let _cant_sin_pagado = 0;
drop table if exists tmp_sinis;	
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
  
     select no_documento,cod_ramo
	 into  _no_documento,_cod_ramo
	 from emipomae
	where no_poliza = _no_poliza;
	
    select count(*)
	  into _cant_sin_pagado 
	  from tmp_sinis
	 where no_poliza = _no_poliza
	  and pagado_bruto > 0;		


	INSERT INTO tmp_datos6(
	no_poliza, no_documento,cod_ramo, 
	periodo,         
	incurrido_bruto,     
	siniestro_pagado,
	tipo,
	cant_unidades,
	cant_sin_pagado
	)
	VALUES(
	_no_poliza,_no_documento,_cod_ramo,
	_periodo,
	_incurrido_bruto,     
	_siniestro_pagado,
	"2",
	_cant_unidades,
	_cant_sin_pagado
	);

END FOREACH
--DROP TABLE tmp_sinis;
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
		sum(cant_unidades),
		sum(cant_sin_pagado),
		periodo,
		cod_ramo
   INTO	_prima_suscrita,
		_prima_pagada,
		_incurrido_bruto,
		_siniestro_pagado,
		_cant_poliza,
		_cant_unidades,
		_cant_sin_pagado,
		_periodo,
		_cod_ramo
   FROM tmp_datos6
  GROUP BY periodo,cod_ramo 
  ORDER BY cod_ramo asc,periodo

 	return _periodo,_cant_poliza,_prima_suscrita,_incurrido_bruto,_cant_unidades,_cant_sin_pagado,a_periodo2[1,4],_cod_ramo with resume;  	
 
END FOREACH

END 

--DROP TABLE tmp_datos6;

END PROCEDURE;
