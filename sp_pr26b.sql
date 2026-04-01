-- Reporte de Total de Produccion por Grupo--

-- Creado    : 04/08/2000 - Autor: Lic. Armando Moreno 
-- Modificado: 04/08/2000 - Autor: Lic. Armando Moreno
--
-- SIS v.2.0 d_- DEIVID, S.A.

DROP PROCEDURE sp_pro26b;

CREATE PROCEDURE "informix".sp_pro26b(a_compania CHAR(3),a_agencia  CHAR(3),a_periodo1 CHAR(7),a_periodo2 CHAR(7),a_sucursal CHAR(255) DEFAULT "*",a_ramo CHAR(255) DEFAULT "*",a_grupo CHAR(255) DEFAULT "*", a_usuario  CHAR(255) DEFAULT "*", a_reaseguro CHAR(255) DEFAULT "*", a_agente CHAR(255) DEFAULT "*",a_producto CHAR(255) DEFAULT "*")
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
		            CHAR(255);

DEFINE _cod_grupo     	 CHAR(5);
DEFINE v_nombre     	 CHAR(50);
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
DEFINE _accionista       SMALLINT;	

CREATE TEMP TABLE tmp_prod2(
        cod_grupo            CHAR(5)   NOT NULL,
		nombre   			 CHAR(50)  NOT NULL,
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
		cnt_prima_rev   	 DECIMAL(16,2),
		PRIMARY KEY (cod_grupo)) WITH NO LOG;

-- Nombre de la Compania

LET v_compania_nombre = sp_sis01(a_compania);

LET v_filtros = sp_pr26(
a_compania,
a_agencia, 
a_periodo1,
a_periodo2,
a_sucursal,
a_ramo,
a_grupo, 
a_usuario,
a_reaseguro,
a_agente,
a_producto
);

--Recorre la tabla temporal y asigna valores a variables de salida
FOREACH WITH HOLD
 SELECT cod_grupo,
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
		cnt_prima_rev
   INTO _cod_grupo,
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
		v_cnt_prima_rev
   FROM tmp_prod
  WHERE	seleccionado = 1
 
   BEGIN
	ON EXCEPTION IN(-239)

		UPDATE tmp_prod2
		   SET total_pri_sus   = total_pri_sus + v_total_prima_sus,
			   total_pri_nva   = total_pri_nva + v_total_prima_nva,
			   total_pri_ren   = total_pri_ren + v_total_prima_ren,
			   total_pri_end   = total_pri_end + v_total_prima_end,
			   total_pri_can   = total_pri_can + v_total_prima_can,
			   total_pri_rev   = total_pri_rev + v_total_prima_rev,
			   cnt_prima_sus   = cnt_prima_sus + v_cnt_prima_sus,
			   cnt_prima_nva   = cnt_prima_nva + v_cnt_prima_nva,	
			   cnt_prima_ren   = cnt_prima_ren + v_cnt_prima_ren,	
			   cnt_prima_end   = cnt_prima_end + v_cnt_prima_end,	
			   cnt_prima_can   = cnt_prima_can + v_cnt_prima_can,	
			   cnt_prima_rev   = cnt_prima_rev + v_cnt_prima_rev
		 WHERE cod_grupo = _cod_grupo;

	END EXCEPTION

 
	SELECT 	nombre,
	        accionista
  	INTO 	v_nombre,
	        _accionista
  	FROM 	cligrupo
	WHERE	cod_grupo = _cod_grupo;

    --IF _accionista = 1 THEN
    INSERT INTO tmp_prod2(
    cod_grupo,
    nombre,
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
	cnt_prima_rev
	)
	VALUES(
	_cod_grupo,
	v_nombre,
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
	v_cnt_prima_rev
	);
	--END IF
   END
  END FOREACH;

  FOREACH WITH HOLD
  SELECT nombre,
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
		cnt_prima_rev
   INTO v_nombre,
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
		v_cnt_prima_rev
   FROM tmp_prod2
  

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
			v_filtros
		    WITH RESUME;

END FOREACH

DROP TABLE tmp_prod;
DROP TABLE tmp_prod2;

END PROCEDURE;
