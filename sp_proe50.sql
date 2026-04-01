-- Reporte de Total de Produccion por CorredorRamo
--
-- Creado    : 04/08/2000 - Autor: Lic. Armando Moreno
-- Modificado: 07/01/2001 - Autor: Lic. Yinia M. Zamora
-- Modificado: 18/10/2010 - Autor: Henry Giron Filtro por Zona
-- SIS v.2.0 d_- DEIVID, S.A.

DROP PROCEDURE sp_proe50;
CREATE PROCEDURE "informix".sp_proe50(a_compania CHAR(3),a_agencia  CHAR(3),a_periodo1 CHAR(7),a_periodo2 CHAR(7),a_sucursal CHAR(255) DEFAULT "*",a_ramo CHAR(255) DEFAULT "*",a_grupo    CHAR(255) DEFAULT "*", a_usuario  CHAR(255) DEFAULT "*", a_reaseguro CHAR(255) DEFAULT "*", a_agente CHAR(255) DEFAULT "*", a_codvend CHAR(255) DEFAULT "*") 
		RETURNING   CHAR(50),
		            CHAR(03),
					CHAR(50),
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
		            CHAR(3), 
					CHAR(50);


DEFINE v_nombre          CHAR(50);
DEFINE v_total_prima_sus,v_total_prima_nva,v_total_prima_ren,v_total_prima_end, 
       v_total_prima_can,v_total_prima_rev DECIMAL(16,2);
DEFINE v_cnt_prima_sus,v_cnt_prima_nva,v_cnt_prima_ren,v_cnt_prima_end,
       v_cnt_prima_can,v_cnt_prima_rev   INTEGER;
DEFINE v_compania_nombre,_nombre_ramo    CHAR(50); 
DEFINE v_filtros                         CHAR(255);
DEFINE _cod_ramo                         CHAR(03);
DEFINE _cod_agente                       CHAR(5);
DEFINE _cod_vendedor		    		 CHAR(3);
DEFINE _nombre_vendedor	    			 CHAR(50);

CREATE TEMP TABLE tmp_prod2(
		cod_agente 			 CHAR(5)  NOT NULL,
		cod_ramo             CHAR(03),
		nombre               CHAR(50),
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
	    cod_vendedor	     CHAR(3),                        -- cod_vendedor
	    nombre_vendedor      CHAR(50),                       -- nombre vendedor
		PRIMARY KEY (cod_agente,cod_ramo)) WITH NO LOG;

-- Nombre de la Compania

set isolation to dirty read;
--set debug file to "sp_proe50.trc";	


LET v_compania_nombre = sp_sis01(a_compania);
	

LET v_filtros = sp_proe49(
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
"*",
a_codvend	   
);			   

--trace on;

--Recorre la tabla temporal y asigna valores a vvriables de salida WITH HOLD
FOREACH 
 SELECT cod_agente,
        cod_ramo,
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
		cod_vendedor,	
		nombre_vendedor 
   INTO _cod_agente,
        _cod_ramo,
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
		_cod_vendedor,		
		_nombre_vendedor	
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
		 WHERE cod_agente      = _cod_agente
		   AND cod_ramo        = _cod_ramo;

	END EXCEPTION;
	
	SELECT nombre
           INTO v_nombre
           FROM agtagent
           WHERE cod_agente = _cod_agente;

    INSERT INTO tmp_prod2(
			cod_agente, 		cod_ramo,           nombre,             
			total_pri_sus,		total_pri_nva,		total_pri_ren,	    
			total_pri_end,		total_pri_can,		total_pri_rev,		
			cnt_prima_sus,		cnt_prima_nva,		cnt_prima_ren,		
			cnt_prima_end,		cnt_prima_can,	 	cnt_prima_rev,
			cod_vendedor,		nombre_vendedor 
			)
			VALUES(
			_cod_agente,	    _cod_ramo,          v_nombre,           
			v_total_prima_sus, 	v_total_prima_nva, 	v_total_prima_ren,  
			v_total_prima_end,	v_total_prima_can,	v_total_prima_rev,  
			v_cnt_prima_sus,	v_cnt_prima_nva,	v_cnt_prima_ren,	
			v_cnt_prima_end,	v_cnt_prima_can,	v_cnt_prima_rev,
			_cod_vendedor,		_nombre_vendedor
			);

   END
  END FOREACH;
--  trace off;

  FOREACH 
  SELECT nombre,
         cod_ramo,
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
		cod_vendedor,		
		nombre_vendedor 
   INTO v_nombre,
        _cod_ramo,
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
		_cod_vendedor,		
		_nombre_vendedor
   FROM tmp_prod2
  -- ORDER BY total_pri_sus DESC
 

   SELECT nombre
          INTO _nombre_ramo
          FROM prdramo
         WHERE cod_ramo = _cod_ramo; 

	RETURN  v_nombre,
	        _cod_ramo,
			_nombre_ramo,
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
			_cod_vendedor,		
			_nombre_vendedor
		    WITH RESUME;

END FOREACH

DROP TABLE tmp_prod;
DROP TABLE tmp_prod2;


END PROCEDURE;
