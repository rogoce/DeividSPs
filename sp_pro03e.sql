-- Reporte de Total de Produccion de Reaseguro por Ramo/Subramo
--
-- Creado    : 09/08/2000 - Autor: Lic. Armando Moreno 
-- Modificado: 09/08/2000 - Autor: Lic. Armando Moreno
--
-- SIS v.2.0 d_- DEIVID, S.A.

DROP PROCEDURE sp_pro03e;

CREATE PROCEDURE "informix".sp_pro03e(a_compania CHAR(3), a_agencia CHAR(3), a_periodo DATE, a_sucursal CHAR(255) DEFAULT "*",a_ramo CHAR(255) DEFAULT "*",a_grupo    CHAR(255) DEFAULT "*", a_usuario  CHAR(255) DEFAULT "*", a_reaseguro CHAR(255) DEFAULT "*", a_agente CHAR(255) DEFAULT "*")
		RETURNING CHAR(50),
		          CHAR(50),
				  CHAR(50),
		          DECIMAL(16,2), 
		          DECIMAL(16,2), 
		          INT, 
		          CHAR(50),
		          CHAR(255);

DEFINE v_nombre_ramo   	 CHAR(50); 
DEFINE v_nombre_subramo  CHAR(50); 
DEFINE v_nombre_producto CHAR(50);
DEFINE v_total_prima_sus DECIMAL(16,2);
DEFINE v_total_prima_ret DECIMAL(16,2);
DEFINE v_unidades        INT;
DEFINE v_compania_nombre CHAR(50);
DEFINE v_cod_ramo     	 CHAR(3);
DEFINE v_cod_subramo     CHAR(3);
DEFINE v_cod_producto    CHAR(5);
DEFINE v_filtros         CHAR(255);

 -- Nombre de la Compania

LET v_compania_nombre = sp_sis01(a_compania);

--DROP TABLE tmp_prod;


CREATE TEMP TABLE tmp_prod2(
	    cod_ramo       CHAR(3)  NOT NULL,
		cod_subramo    CHAR(3)  NOT NULL,
		cod_producto   CHAR(5)  NOT NULL,
		nombre_ramo    CHAR(50),
		nombre_subramo CHAR(50),
		nombre_producto CHAR(50),
	    total_pri_sus  DEC(16,2) NOT NULL,
		total_pri_ret  DEC(16,2) NOT NULL,
		unidades       INT,
	    PRIMARY KEY (cod_ramo,cod_subramo,cod_producto)) WITH NO LOG;


LET v_filtros = sp_pro03e1(
a_compania,
a_agencia,
a_periodo,
a_sucursal,
a_ramo,
a_grupo,
a_usuario,
a_reaseguro,
a_agente
);

--Recorre la tabla temporal y asigna valores a variables de salida

FOREACH WITH HOLD
 SELECT cod_ramo,
        cod_subramo,
		cod_producto,
		total_pri_sus,
		total_pri_ret
   INTO v_cod_ramo,
        v_cod_subramo,
		v_cod_producto,
		v_total_prima_sus,
		v_total_prima_ret 
   FROM tmp_prod
  WHERE seleccionado = 1
 
--Selecciona los nombres de Grupos

     BEGIN
          ON EXCEPTION IN(-239)
             UPDATE tmp_prod2 
                  SET total_pri_sus = total_pri_sus + v_total_prima_sus,
                      total_pri_ret = total_pri_ret + v_total_prima_ret,
					  unidades = unidades + 1
	             WHERE cod_ramo     = v_cod_ramo 
	               AND cod_subramo  = v_cod_subramo
	               AND cod_producto = v_cod_producto ;

          END EXCEPTION

		 --Selecciona los nombres de Ramos

	  	SELECT  	nombre
	  		INTO 	v_nombre_ramo
	  		FROM 	prdramo
			WHERE	cod_ramo = v_cod_ramo;
	 
	  	SELECT  	nombre
	  		INTO 	v_nombre_subramo
	  		FROM 	prdsubra
			WHERE	cod_ramo 	= v_cod_ramo
	    	AND 	cod_subramo = v_cod_subramo;

	  	SELECT  	nombre
	  		INTO 	v_nombre_producto
	  		FROM 	prdprod
			WHERE	cod_producto = v_cod_producto;

    	INSERT INTO tmp_prod2
           VALUES(v_cod_ramo,
		          v_cod_subramo,
				  v_cod_producto,
		       	  v_nombre_ramo,
				  v_nombre_subramo,
				  v_nombre_producto,
                  v_total_prima_sus,
                  v_total_prima_ret,
				  1
                  );
     END
END FOREACH;

FOREACH WITH HOLD
	    SELECT nombre_ramo,
		       nombre_subramo,
			   nombre_producto,
			   total_pri_sus,
			   total_pri_ret, 
			   unidades
	      INTO v_nombre_ramo,
	           v_nombre_subramo,
			   v_nombre_producto,
			   v_total_prima_sus,
			   v_total_prima_ret,
			   v_unidades
	      FROM tmp_prod2
	  ORDER BY nombre_ramo


  RETURN    v_nombre_ramo, 
  			v_nombre_subramo,
			v_nombre_producto,
			v_total_prima_sus, 
			v_total_prima_ret,
			v_unidades,
			v_compania_nombre,
			v_filtros
		    WITH RESUME;
END FOREACH;

DROP TABLE tmp_prod;
DROP TABLE tmp_prod2;

END PROCEDURE;
