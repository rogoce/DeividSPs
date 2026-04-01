-- Reporte de Total de Produccion por Ramo
--
-- Creado    : 04/08/2000 - Autor: Lic. Armando Moreno
-- Modificado: 04/08/2000 - Autor: Lic. Armando Moreno
--
-- SIS v.2.0 d_- DEIVID, S.A.

DROP PROCEDURE ap_pro26c;

CREATE PROCEDURE "informix".ap_pro26c(a_compania CHAR(3),a_agencia  CHAR(3),a_periodo1 CHAR(7),a_periodo2 CHAR(7),a_sucursal CHAR(255) DEFAULT "*",a_ramo CHAR(255) DEFAULT "*",a_grupo CHAR(255) DEFAULT "*", a_usuario  CHAR(255) DEFAULT "*", a_reaseguro CHAR(255) DEFAULT "*", a_agente CHAR(255) DEFAULT "*")
		RETURNING   CHAR(20),
		            DATE,
					DATE,
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
DEFINE _cod_ramo     	 CHAR(3);
DEFINE v_descripcion     CHAR(22); 
DEFINE _no_poliza        CHAR(10);
DEFINE _no_documento     CHAR(20);
DEFINE _vigencia_inic    DATE;
DEFINE _vigencia_final   DATE;

CREATE TEMP TABLE tmp_prod2(
		no_documento	     CHAR(20)  NOT NULL,
		vigencia_inic        DATE,
		vigencia_final       DATE,
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
		PRIMARY KEY (no_documento)) WITH NO LOG;

-- Nombre de la Compania

set isolation to dirty read;

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
'*'
);

--Recorre la tabla temporal y asigna valores a variables de salida
FOREACH WITH HOLD
 SELECT no_poliza,
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
   INTO _no_poliza,
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
  
  SELECT no_documento,
         vigencia_inic,
		 vigencia_final
	INTO _no_documento,
         _vigencia_inic,
		 _vigencia_final
	FROM emipomae
   WHERE no_poliza = _no_poliza;
	    

   BEGIN
	ON EXCEPTION IN(-239)

		UPDATE tmp_prod2
		   SET vigencia_inic   = _vigencia_inic,
		       vigencia_final  = _vigencia_final,
		       total_pri_sus   = total_pri_sus + v_total_prima_sus,
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
		 WHERE no_documento    = _no_documento;

	END EXCEPTION

    INSERT INTO tmp_prod2(
    no_documento,
    vigencia_inic,
	vigencia_final,
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
	_no_documento,
    _vigencia_inic,
	_vigencia_final,
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
   END
END FOREACH;

FOREACH WITH HOLD
  SELECT no_documento,
		 vigencia_inic,
		 vigencia_final,
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
   INTO  _no_documento,
         _vigencia_inic,
	     _vigencia_final,
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
  ORDER BY no_documento

 	RETURN  _no_documento,
            _vigencia_inic,
	        _vigencia_final,
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
