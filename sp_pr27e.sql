-- Reporte de Total de Produccion de Reaseguro por Grupo
-- 
-- Creado    : 09/08/2000 - Autor: Lic. Armando Moreno 
-- Modificado: 09/08/2000 - Autor: Lic. Armando Moreno
--
-- SIS v.2.0 d_- DEIVID, S.A.

--DROP PROCEDURE sp_pro27e;

CREATE PROCEDURE "informix".sp_pro27e(a_compania CHAR(3), a_agencia CHAR(3), a_periodo1 CHAR(7), a_periodo2 CHAR(7),a_sucursal CHAR(255) DEFAULT "*",a_ramo CHAR(255) DEFAULT "*",a_grupo    CHAR(255) DEFAULT "*", a_usuario  CHAR(255) DEFAULT "*", a_reaseguro CHAR(255) DEFAULT "*", a_agente CHAR(255) DEFAULT "*") 
		RETURNING CHAR(50),
		          CHAR(50),
				  CHAR(10),
				  CHAR(20),
				  CHAR(100),
		          DECIMAL(16,2), 
		          DECIMAL(16,2), 
		          DECIMAL(16,2), 
		          CHAR(50),
		          CHAR(255);

DEFINE v_nombre, v_nombre_subra		CHAR(50);
DEFINE v_total_prima_sus 			DECIMAL(16,2);
DEFINE v_total_prima_ret 			DECIMAL(16,2);
DEFINE v_total_prima_ced 			DECIMAL(16,2);
DEFINE v_compania_nombre 			CHAR(50);
DEFINE v_filtros         			CHAR(255);
DEFINE _cod_ramo, _cod_subramo 		CHAR(3);
DEFINE _no_poliza, _cod_pagador		CHAR(10);
DEFINE v_no_documento           	CHAR(20);
DEFINE v_asegurado              	CHAR(100);
DEFINE v_no_factura, _cod_cliente 	CHAR(10);
DEFINE _no_endoso					CHAR(5);

-- Nombre de la Compania

LET v_compania_nombre = sp_sis01(a_compania);

--DROP TABLE tmp_prod;


{CREATE TEMP TABLE tmp_prod2(
	        cod_ramo       CHAR(3) NOT NULL,
	     	nombre         CHAR(50),
	        total_pri_sus  DEC(16,2) NOT NULL,
	    	total_pri_ret  DEC(16,2) NOT NULL,
	    	total_pri_ced  DEC(16,2) NOT NULL,
	    PRIMARY KEY (cod_ramo)) WITH NO LOG;}


LET v_filtros = sp_pro68(
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

FOREACH WITH HOLD
 SELECT no_poliza,      
        no_endoso,
		no_factura,
 		cod_subramo,	   
 		cod_ramo,       
 		total_pri_sus,  
 		total_pri_ret,  
 		total_pri_ced  
   INTO _no_poliza,
        _no_endoso,
		v_no_factura,
        _cod_subramo,
        _cod_ramo,
		v_total_prima_sus,
		v_total_prima_ret,
		v_total_prima_ced
   FROM tmp_prod
  WHERE seleccionado = 1
  ORDER BY cod_ramo, cod_subramo, no_factura

 SELECT nombre
   INTO	v_nombre
   FROM prdramo
  WHERE cod_ramo = _cod_ramo;

 SELECT nombre
   INTO	v_nombre_subra
   FROM prdsubra
  WHERE cod_ramo = _cod_ramo
    AND cod_subramo = _cod_subramo;

 SELECT no_documento,
        cod_pagador
   INTO v_no_documento,
        _cod_cliente
   FROM emipomae
  WHERE no_poliza = _no_poliza;

 SELECT nombre
   INTO v_asegurado
   FROM cliclien
  WHERE cod_cliente = _cod_cliente;


  RETURN  v_nombre,
          v_nombre_subra,
		  v_no_factura,
		  v_no_documento,
		  v_asegurado,
   		  v_total_prima_sus,
		  v_total_prima_ret,
		  v_total_prima_ced,
		  v_compania_nombre,
		  v_filtros
		  WITH RESUME;

END FOREACH;

DROP TABLE tmp_prod;

END PROCEDURE;
