-- Reporte de Total de Produccion por Ramo
--
-- Creado    : 04/08/2000 - Autor: Lic. Armando Moreno
-- Modificado: 04/08/2000 - Autor: Lic. Armando Moreno
--
-- SIS v.2.0 d_- DEIVID, S.A.

DROP PROCEDURE sp_pro86a;

CREATE PROCEDURE "informix".sp_pro86a(a_compania CHAR(3),a_agencia  CHAR(3),a_periodo1 CHAR(7),a_periodo2 CHAR(7),a_sucursal CHAR(255) DEFAULT "*",a_ramo CHAR(255) DEFAULT "*",a_grupo    CHAR(255) DEFAULT "*", a_usuario  CHAR(255) DEFAULT "*", a_reaseguro CHAR(255) DEFAULT "*", a_agente CHAR(255) DEFAULT "*", a_producto CHAR(255) DEFAULT "*")
		RETURNING   CHAR(50),
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
		            CHAR(255);
		            
DEFINE v_nombre, v_nombre_subramo CHAR(50); 
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
DEFINE _no_poliza     	 CHAR(10);
DEFINE _no_endoso, _no_unidad, _no_endoso_v  CHAR(5);
DEFINE v_descripcion     CHAR(22); 
DEFINE _cod_tipoveh,_cod_subramo CHAR(3);
DEFINE _cod_ramo         CHAR(3);        

CREATE TEMP TABLE tmp_prod2(
        cod_subramo          CHAR(3)  NOT NULL,
		nombre_subramo		 CHAR(50),
		cod_tipoveh			 CHAR(3)  NOT NULL,
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
		PRIMARY KEY (cod_subramo,cod_tipoveh)) WITH NO LOG;

-- Nombre de la Compania

LET v_compania_nombre = sp_sis01(a_compania);
LET a_ramo = '002;';

LET v_filtros = sp_pro86(
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
 SELECT cod_ramo,
        cod_subramo,
        no_poliza,
        no_endoso,
		no_unidad,
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
   INTO _cod_ramo,
        _cod_subramo,
        _no_poliza,
        _no_endoso,
        _no_unidad,
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
		 WHERE cod_subramo     = _cod_subramo
		   AND cod_tipoveh     = _cod_tipoveh;

	END EXCEPTION

	SELECT nombre
	  INTO v_nombre_subramo
	  FROM prdsubra
	 WHERE cod_ramo = _cod_ramo
	   AND cod_subramo = _cod_subramo;

   LET 	_cod_tipoveh = NULL;

 {	FOREACH
	    SELECT cod_tipoveh,
		  	   no_endoso
	      INTO _cod_tipoveh,
			   _no_endoso_v
	      FROM endmoaut
	   	 WHERE no_poliza = _no_poliza
		   AND no_unidad = _no_unidad
		   AND cod_tipoveh is not null
		 ORDER BY no_endoso DESC
	END FOREACH

    IF _cod_tipoveh is null THEN
	  SELECT cod_tipoveh
	    INTO _cod_tipoveh
		FROM emiauto
	   WHERE no_poliza = _no_poliza
		 AND no_unidad = _no_unidad
    	 AND cod_tipoveh is not null;
    END IF}
	  SELECT cod_tipoveh
	    INTO _cod_tipoveh
		FROM emiauto
	   WHERE no_poliza = _no_poliza
		 AND no_unidad = _no_unidad
		 AND cod_tipoveh is not null;

	   IF _cod_tipoveh is null THEN
		   FOREACH
			  SELECT cod_tipoveh
			    INTO _cod_tipoveh
				FROM endmoaut
			   WHERE no_poliza = _no_poliza
				 AND no_unidad = _no_unidad
				 AND cod_tipoveh is not null
			   EXIT FOREACH;
		   END FOREACH
	   END IF


	   IF _cod_tipoveh is null THEN
	   	   LET v_nombre = '';
		   LET _cod_tipoveh = '';
	   ELSE		   
		   SELECT nombre
		     INTO v_nombre
			 FROM emitiveh
			WHERE cod_tipoveh = _cod_tipoveh;
       END IF

  {	IF _cod_tipoveh is not null THEN
	    SELECT nombre
	      INTO v_nombre
		  FROM emitiveh
		 WHERE cod_tipoveh = _cod_tipoveh;
	ELSE
	    LET v_nombre = '';
		LET _cod_tipoveh = '';
	END IF}

    INSERT INTO tmp_prod2(
	cod_subramo,
	nombre_subramo,
    cod_tipoveh,
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
	_cod_subramo,
	v_nombre_subramo,
    _cod_tipoveh,	      
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
   END
END FOREACH;

FOREACH WITH HOLD
  SELECT cod_subramo,
         nombre_subramo,
         cod_tipoveh,
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
   INTO  _cod_subramo,
         v_nombre_subramo,
         _cod_tipoveh,
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
   FROM tmp_prod2
  ORDER BY cod_subramo,cod_tipoveh

 	RETURN  v_nombre_subramo,
 	        v_nombre,
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
