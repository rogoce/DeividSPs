-- Reporte de Total de Produccion por Corredor
--
-- Creado    : 09/03/2001 - Autor: Amado Perez
-- Modificado: 09/03/2001 - Autor: Amado Perez
--
-- SIS v.2.0 d_- DEIVID, S.A.

DROP PROCEDURE sp_pro26f;

CREATE PROCEDURE "informix".sp_pro26f(a_compania CHAR(3),a_agencia  CHAR(3),a_periodo1 CHAR(7),a_periodo2 CHAR(7),a_sucursal CHAR(255) DEFAULT "*",a_ramo CHAR(255) DEFAULT "*",a_grupo    CHAR(255) DEFAULT "*", a_usuario  CHAR(255) DEFAULT "*", a_reaseguro CHAR(255) DEFAULT "*", a_agente CHAR(255) DEFAULT "*") 
		RETURNING   CHAR(50),
		            DECIMAL(16,2),
					INTEGER,
		            DECIMAL(16,2),
					INTEGER,
		            DECIMAL(16,2), 
					INTEGER,
		            DECIMAL(16,2), 
					INTEGER,
		            DECIMAL(16,2), 
					INTEGER,
		            DECIMAL(16,2),
		            INTEGER,
		            CHAR(50),
		            CHAR(255),
		            CHAR(50);


DEFINE v_nombre          CHAR(50);
DEFINE v_total_prima_sus DECIMAL(16,2);
DEFINE v_total_prima_nva DECIMAL(16,2);
DEFINE v_total_prima_ren DECIMAL(16,2);
DEFINE v_total_prima_end DECIMAL(16,2);
DEFINE v_total_prima_can DECIMAL(16,2);
DEFINE v_total_prima_rev DECIMAL(16,2);
DEFINE v_cnt_prima_sus   INTEGER;
DEFINE v_cnt_prima_nva   INTEGER;
DEFINE v_cnt_prima_ren   INTEGER;
DEFINE v_cnt_prima_end   INTEGER;
DEFINE v_cnt_prima_can   INTEGER;
DEFINE v_cnt_prima_rev   INTEGER;
DEFINE v_compania_nombre CHAR(50); 
DEFINE v_filtros         CHAR(255);
DEFINE v_nombre_vend	 CHAR(50);

DEFINE _cod_agente       CHAR(5);
DEFINE _cod_sucursal     CHAR(3);
DEFINE _cod_ramo         CHAR(3);
DEFINE _cod_vendedor     CHAR(3);
DEFINE _cod_agencia      CHAR(3);


CREATE TEMP TABLE tmp_prod2(
		cod_vendedor         CHAR(3),
		cod_agente 			 CHAR(5),
	   	total_pri_sus        DECIMAL(16,2),
		total_pri_nva        DECIMAL(16,2),
		total_pri_ren        DECIMAL(16,2),
		total_pri_end        DECIMAL(16,2),
		total_pri_can        DECIMAL(16,2),
		total_pri_rev        DECIMAL(16,2),
		cnt_prima_sus    	 DECIMAL(16,2),
 		cnt_prima_nva   	 DECIMAL(16,2),
		cnt_prima_ren   	 DECIMAL(16,2),
		cnt_prima_end   	 DECIMAL(16,2),
		cnt_prima_can   	 DECIMAL(16,2),
		cnt_prima_rev   	 DECIMAL(16,2)
		) WITH NO LOG;

-- Nombre de la Compania

LET v_compania_nombre = sp_sis01(a_compania);

LET v_filtros = sp_pro26(
a_compania,
a_agencia, 
a_periodo1,
a_periodo2,
a_sucursal,
a_ramo,
a_grupo, 
a_usuario,
a_reaseguro,
a_agente
);

--Recorre la tabla temporal y asigna valores a vvriables de salida

FOREACH
 SELECT cod_agente,
		total_pri_sus,
		total_pri_nva,
		total_pri_ren, 
		total_pri_end, 
		total_pri_can, 
		total_pri_rev, 
		cnt_prima_sus, 
		cnt_prima_nva, 
		cnt_prima_ren, 
		cnt_prima_end, 
		cnt_prima_can, 
		cnt_prima_rev,
		cod_sucursal,
		cod_ramo
   INTO _cod_agente,
		v_total_prima_sus,
		v_total_prima_nva, 
		v_total_prima_ren, 
		v_total_prima_end, 
		v_total_prima_can, 
		v_total_prima_rev, 
		v_cnt_prima_sus, 
		v_cnt_prima_nva, 
		v_cnt_prima_ren, 
		v_cnt_prima_end, 
		v_cnt_prima_can, 
		v_cnt_prima_rev,
		_cod_sucursal,
		_cod_ramo
   FROM tmp_prod
  WHERE	seleccionado = 1

	select sucursal_promotoria
	  into _cod_agencia
	  from insagen
	 where codigo_agencia  = _cod_sucursal
	   and codigo_compania = a_compania;

	select cod_vendedor
 	  into _cod_vendedor
	  from parpromo
	 where cod_agente  = _cod_agente
	   and cod_agencia = _cod_agencia
	   and cod_ramo    = _cod_ramo;

   	INSERT INTO tmp_prod2(
	cod_agente,
	total_pri_sus,
	total_pri_nva,		
	total_pri_ren,	    
	total_pri_end,	
	total_pri_can,		
	total_pri_rev,		
	cnt_prima_sus,
	cnt_prima_nva,		
	cnt_prima_ren,		
	cnt_prima_end,
	cnt_prima_can,	 	
	cnt_prima_rev,		
	cod_vendedor
	)
	VALUES(
	_cod_agente,
	v_total_prima_sus, 
	v_total_prima_nva, 	
	v_total_prima_ren,  
	v_total_prima_end,
	v_total_prima_can,	
	v_total_prima_rev,  
	v_cnt_prima_sus,	
	v_cnt_prima_nva,	
	v_cnt_prima_ren,	
	v_cnt_prima_end,
	v_cnt_prima_can,	
	v_cnt_prima_rev,	
	_cod_vendedor
	);


END FOREACH;

FOREACH
 SELECT sum(total_pri_sus),
		sum(total_pri_nva),
		sum(total_pri_ren),
		sum(total_pri_end), 
		sum(total_pri_can), 
		sum(total_pri_rev), 
		sum(cnt_prima_sus), 
		sum(cnt_prima_nva), 
		sum(cnt_prima_ren), 
		sum(cnt_prima_end), 
		sum(cnt_prima_can), 
		sum(cnt_prima_rev),
		cod_vendedor,
		cod_agente
   INTO v_total_prima_sus, 
		v_total_prima_nva, 
		v_total_prima_ren, 
		v_total_prima_end, 
		v_total_prima_can, 
		v_total_prima_rev, 
		v_cnt_prima_sus, 
		v_cnt_prima_nva, 
		v_cnt_prima_ren, 
		v_cnt_prima_end, 
		v_cnt_prima_can, 
		v_cnt_prima_rev,
		_cod_vendedor,
		_cod_agente
   FROM tmp_prod2
  GROUP BY cod_vendedor, cod_agente
  ORDER BY cod_vendedor, cod_agente

	SELECT nombre
	  INTO v_nombre
	  FROM agtagent
	 WHERE cod_agente = _cod_agente;

	SELECT nombre
	  INTO v_nombre_vend
	  FROM agtvende
     WHERE cod_vendedor = _cod_vendedor;

	if v_nombre_vend is null then
		let v_nombre_vend = " VENDEDOR NO DEFINIDO " || _cod_agente;
	end if

	RETURN  v_nombre,
			v_total_prima_sus,
			v_cnt_prima_sus,
			v_total_prima_nva,
			v_cnt_prima_nva,
			v_total_prima_ren,
			v_cnt_prima_ren,
			v_total_prima_end,
			v_cnt_prima_end,
			v_total_prima_can,
			v_cnt_prima_can,
			v_total_prima_rev,
			v_cnt_prima_rev,
			v_compania_nombre,
			v_filtros,
			v_nombre_vend
		    WITH RESUME;

END FOREACH

DROP TABLE tmp_prod;
DROP TABLE tmp_prod2;


END PROCEDURE;
