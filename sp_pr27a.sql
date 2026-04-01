-- Reporte de Total de Produccion de Reaseguro por Grupo
-- 
-- Creado    : 09/08/2000 - Autor: Lic. Armando Moreno 
-- Modificado: 09/08/2000 - Autor: Lic. Armando Moreno
-- Modificado: 11/04/2007 - Por  : Rub‚n Dar¡o Arn ez
-- SIS v.2.0 d_- DEIVID, S.A.

 DROP PROCEDURE sp_pro27a;

CREATE PROCEDURE "informix".sp_pro27a(a_compania CHAR(3), a_agencia CHAR(3), a_periodo1 CHAR(7), a_periodo2 CHAR(7),a_sucursal CHAR(255) DEFAULT "*",a_ramo CHAR(255) DEFAULT "*",a_grupo    CHAR(255) DEFAULT "*", a_usuario  CHAR(255) DEFAULT "*", a_reaseguro CHAR(255) DEFAULT "*", a_agente CHAR(255) DEFAULT "*")
  RETURNING CHAR(50),        -- 1. Nombre del Ramo
            DECIMAL(16,2), 	 -- 2. Total de Prima Suscrita
            DECIMAL(16,2), 	 -- 3. Total de Prima Retenida 
            DECIMAL(16,2),	 -- 4. Total de Prima Ced
           	CHAR(50),		 -- 5. Compania Nombre
           	CHAR(50),		 -- 6. Descripcion 
            CHAR(255);		 -- 7. filtros

DEFINE v_nombre     	 CHAR(50);
DEFINE v_descripcion  	 CHAR(50);
DEFINE v_total_prima_sus DECIMAL(16,2);
DEFINE v_total_prima_ret DECIMAL(16,2);
DEFINE v_total_prima_ced DECIMAL(16,2);
DEFINE v_compania_nombre CHAR(50);
DEFINE v_filtros         CHAR(255);
DEFINE _cod_ramo         CHAR(3);
DEFINE v_agencia         CHAR(3);

-- Nombre de la Compania

LET v_compania_nombre = sp_sis01(a_compania);

--DROP TABLE tmp_prod;


CREATE TEMP TABLE tmp_prod2(
	        cod_ramo       CHAR(3) NOT NULL,
	     	nombre         CHAR(50),
	        total_pri_sus  DEC(16,2) NOT NULL,
	    	total_pri_ret  DEC(16,2) NOT NULL,
	    	total_pri_ced  DEC(16,2) NOT NULL,
			descripcion    CHAR(50)  NOT NULL,
	    PRIMARY KEY (cod_ramo)) WITH NO LOG;

LET v_filtros = sp_pro27(
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

--Recorre la tabla temporal y asigna valores a variables de salida

SET ISOLATION TO DIRTY READ;

FOREACH WITH HOLD

 SELECT cod_ramo,
		total_pri_sus,
		total_pri_ret,
		total_pri_ced,
		cod_sucursal
   INTO _cod_ramo,
		v_total_prima_sus,
		v_total_prima_ret,
		v_total_prima_ced,
		v_agencia
   FROM tmp_prod
  WHERE seleccionado = 1

 FOREACH	
		 SELECT descripcion 
		 INTO v_descripcion
		 FROM insagen  
		 WHERE codigo_agencia = v_agencia

 END FOREACH;

--Selecciona los nombres de Ramos

    BEGIN
          ON EXCEPTION IN(-239)
             UPDATE tmp_prod2
                  SET total_pri_sus = total_pri_sus + v_total_prima_sus,
                      total_pri_ret = total_pri_ret + v_total_prima_ret,
	                  total_pri_ced = total_pri_ced + v_total_prima_ced
	             WHERE cod_ramo = _cod_ramo;

          END EXCEPTION


         SELECT nombre
  	       INTO v_nombre
           FROM prdramo
          WHERE cod_ramo = _cod_ramo;
		

          INSERT INTO tmp_prod2
              VALUES(_cod_ramo,
					 v_nombre,
                     v_total_prima_sus,
                     v_total_prima_ret,
                     v_total_prima_ced,
                     v_descripcion);
    END
END FOREACH;

FOREACH WITH HOLD
    SELECT cod_ramo,
	       nombre,
		   total_pri_sus,
		   total_pri_ret,
		   total_pri_ced,
		   descripcion
   	  INTO _cod_ramo,
           v_nombre,
		   v_total_prima_sus,
		   v_total_prima_ret,
		   v_total_prima_ced,
		   v_descripcion 
   	  FROM tmp_prod2
  ORDER BY cod_ramo
  
  RETURN  v_nombre,
   		  v_total_prima_sus,
		  v_total_prima_ret,
		  v_total_prima_ced,
		  v_compania_nombre,
		  v_descripcion,
		  v_filtros
		  
		  WITH RESUME;

END FOREACH;

DROP TABLE tmp_prod;
DROP TABLE tmp_prod2;

END PROCEDURE;
