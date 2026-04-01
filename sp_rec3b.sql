---    LISTADO DE RECLAMOS POR GRUPO     
---           
---  Yinia M. Zamora - agosto 2000 - YMZM
--   Modificado: 15/09/2000 - Autor: Demetrio Hurtado Almanza
---  Ref. Power Builder - dw_rec03b

DROP PROCEDURE sp_rec03b;

CREATE PROCEDURE "informix".sp_rec03b(
cod_compania  CHAR(3),
periodo_desde CHAR(7),
periodo_hasta CHAR(7),
a_sucursal    CHAR(255) DEFAULT "*", 
a_grupo       CHAR(255) DEFAULT "*", 
a_ramo        CHAR(255) DEFAULT "*",
a_ajustador   CHAR(255) DEFAULT "*",
a_agente      CHAR(255) DEFAULT "*",
a_origen      CHAR(3)   DEFAULT "%",
a_evento      CHAR(255) DEFAULT "*"
) RETURNING CHAR(50),CHAR(3),CHAR(50),CHAR(5),CHAR(50),CHAR(18),
            CHAR(20),CHAR(100),DATE,DATE,CHAR(255);

DEFINE v_filtros         CHAR(255);

DEFINE v_numrecla        CHAR(18); 
DEFINE v_nopoliza        CHAR(20); 
DEFINE v_asegurado       CHAR(100);
DEFINE v_fecha_siniestro DATE;     
DEFINE v_fecha_reclamo   DATE;     
DEFINE v_codgrupo        CHAR(5);  
DEFINE v_codramo         CHAR(3);  
DEFINE v_descr_cia       CHAR(50); 
DEFINE v_desc_ramo       CHAR(50); 
DEFINE v_desc_grupo      CHAR(50); 

LET v_descr_cia = NULL;
LET v_codramo   = NULL;
LET v_codgrupo  = NULL;
LET v_numrecla  = NULL;
LET v_nopoliza  = NULL;
LET v_asegurado = NULL;
LET v_fecha_siniestro = NULL;
LET v_fecha_reclamo = NULL;

-- Nombre de la Compania

LET v_descr_cia = sp_sis01(cod_compania);

LET v_filtros = sp_rec03(
cod_compania,
periodo_desde,
periodo_hasta,
a_sucursal,    
a_grupo,       
a_ramo,
a_ajustador,
a_agente,
a_origen,
a_evento        
);

FOREACH
 SELECT numrecla,no_poliza,asegurado,fecha_siniestro,fecha_reclamo,
        cod_ramo,cod_grupo
   INTO v_numrecla,v_nopoliza,v_asegurado,v_fecha_siniestro,
           v_fecha_reclamo,v_codramo,v_codgrupo
   FROM tmp_sinis
  WHERE seleccionado = 1
  ORDER BY cod_grupo, cod_ramo, numrecla

	SELECT nombre
      INTO v_desc_ramo
      FROM prdramo
     WHERE cod_ramo = v_codramo;

	SELECT nombre
      INTO v_desc_grupo
      FROM cligrupo
     WHERE cod_grupo = v_codgrupo;

	RETURN v_descr_cia,
		   v_codramo,
		   v_desc_ramo,
		   v_codgrupo,
		   v_desc_grupo,
    	   v_numrecla,
    	   v_nopoliza,
    	   v_asegurado,
    	   v_fecha_siniestro,
      	   v_fecha_reclamo,
		   v_filtros
      	   WITH RESUME;

END FOREACH

DROP TABLE tmp_sinis;

END PROCEDURE;
