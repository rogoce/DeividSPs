-- Reporte produccion por ramo/subramo/producto
--
-- Creado    : 13/06/2002 - Autor: Lic. Armando Moreno 
-- SIS v.2.0 d_- DEIVID, S.A.

--DROP PROCEDURE sp_proe26;

CREATE PROCEDURE "informix".sp_proe26(a_compania CHAR(3), a_agencia CHAR(3), a_periodo1 CHAR(07),a_periodo2 CHAR(07), a_sucursal CHAR(255) DEFAULT "*",a_ramo CHAR(255) DEFAULT "*", a_reaseguro CHAR(255) DEFAULT "*")
		RETURNING CHAR(50),
		          CHAR(50),
				  CHAR(50),
		          DECIMAL(16,2), 
		          CHAR(20), 
		          INT, 
		          CHAR(50),
				  CHAR(100),
		          CHAR(255);

DEFINE v_nombre_ramo   	 CHAR(50); 
DEFINE v_nombre_subramo  CHAR(50); 
DEFINE v_nombre_producto CHAR(50);
DEFINE v_total_prima_sus DECIMAL(16,2);
DEFINE _no_documento     CHAR(20);
DEFINE _cod_contratante,_no_poliza  CHAR(10);
DEFINE v_nombre_cte      CHAR(100);
DEFINE v_unidades        INT;
DEFINE v_compania_nombre CHAR(50);
DEFINE v_cod_ramo     	 CHAR(3);
DEFINE v_cod_subramo     CHAR(3);
DEFINE v_cod_producto,_no_endoso    CHAR(5);
DEFINE v_filtros         CHAR(255);

 -- Nombre de la Compania

LET v_compania_nombre = sp_sis01(a_compania);

--DROP TABLE tmp_prod;

CREATE TEMP TABLE tmp_prod2(
	    cod_ramo        CHAR(3)  NOT NULL,
		cod_subramo     CHAR(3)  NOT NULL,
		cod_producto    CHAR(5)  NOT NULL,
        no_documento    CHAR(20),
        cod_contratante CHAR(10),
		nombre_ramo     CHAR(50),
		nombre_subramo  CHAR(50),
		nombre_producto CHAR(50),
	    total_pri_sus   DEC(16,2) NOT NULL,
		unidades        INT,
	    PRIMARY KEY (cod_ramo,cod_subramo,cod_producto,no_documento)) WITH NO LOG;

  CALL sp_pro34(a_compania,
  				a_agencia,
  				a_periodo1,
                a_periodo2,
                a_sucursal,
                '*',
                '*',
                '*',
                a_ramo,
                '*',
                "1")
                RETURNING v_filtros;

--Recorre la tabla temporal y asigna valores a variables de salida

FOREACH WITH HOLD
 SELECT no_documento,
		cod_contratante,
 		cod_ramo,
        cod_subramo,
		--prima,
		no_poliza,
		no_endoso
   INTO _no_documento,
		_cod_contratante,
   		v_cod_ramo,
        v_cod_subramo,
		--v_total_prima_sus,
		_no_poliza,
		_no_endoso
   FROM temp_det
  WHERE seleccionado = 1
 
	FOREACH
		SELECT cod_producto,
			   prima_suscrita	
		  INTO v_cod_producto,
			   v_total_prima_sus	
		  FROM endeduni
		 WHERE no_poliza = _no_poliza
		   AND no_endoso = _no_endoso
		   --AND activo = 1

          ON EXCEPTION IN(-239)
             	UPDATE tmp_prod2 
                   SET total_pri_sus = total_pri_sus + v_total_prima_sus,
					   unidades = unidades + 1
	             WHERE cod_ramo     = v_cod_ramo 
	               AND cod_subramo  = v_cod_subramo
	               AND cod_producto = v_cod_producto
	               AND no_documento = _no_documento;

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
				  _no_documento,
				  _cod_contratante,
		       	  v_nombre_ramo,
				  v_nombre_subramo,
				  v_nombre_producto,
                  v_total_prima_sus,
				  1
                  );
	END FOREACH
END FOREACH;

FOREACH WITH HOLD
	    SELECT nombre_ramo,
		       nombre_subramo,
			   nombre_producto,
			   total_pri_sus,
			   unidades,
			   no_documento,
			   cod_contratante
	      INTO v_nombre_ramo,
	           v_nombre_subramo,
			   v_nombre_producto,
			   v_total_prima_sus,
			   v_unidades,
			   _no_documento,
			   _cod_contratante
	      FROM tmp_prod2
	  ORDER BY nombre_ramo

	    SELECT nombre
	      INTO v_nombre_cte
	      FROM cliclien
		 WHERE cod_cliente = _cod_contratante;

  RETURN    v_nombre_ramo, 
  			v_nombre_subramo,
			v_nombre_producto,
			v_total_prima_sus, 
			_no_documento,
			v_unidades,
			v_compania_nombre,
			v_nombre_cte,
			v_filtros
		    WITH RESUME;
END FOREACH;

DROP TABLE temp_det;
DROP TABLE tmp_prod2;

END PROCEDURE;
