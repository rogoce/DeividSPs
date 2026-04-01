-- Detalle de las unidades

-- Creado    : 16/07/2001 - Autor: Lic Amado Perez 
-- Modificado: 01/08/2001 - Autor: Demetrio Hurtado ALmanza

-- SIS v.2.0 - d_cheq_sp_rec34_dw1 - DEIVID, S.A.

DROP PROCEDURE sp_rec34b;

CREATE PROCEDURE sp_rec34b(a_documento CHAR(20), fecha DATE)
RETURNING CHAR(10),  -- no_poliza
          CHAR(5),   -- no_endoso
		  CHAR(5),	 -- no_unidad
		  CHAR(50),  -- producto      
		  CHAR(10),  -- cod_contratante
		  CHAR(100), -- nombre_asegurado
		  DEC(16,2), -- suma_asegurada
		  DEC(16,2), -- prima_neta
		  CHAR(10),  -- cod_asegurado
		  INT;		 -- eliminada

DEFINE v_poliza        CHAR(10); 
DEFINE v_contratante   CHAR(10); 
DEFINE v_unidad        CHAR(5);  
DEFINE v_endoso        CHAR(5);  
DEFINE v_suma_aseg     DEC(16,2);
DEFINE v_prima_neta    DEC(16,2);
DEFINE v_eliminada     INT;      
DEFINE v_asegurado     CHAR(100);
DEFINE v_producto      CHAR(50); 

DEFINE _no_unidad      CHAR(5);  
DEFINE _cod_producto   CHAR(5);  
DEFINE _cod_asegurado  CHAR(10); 
DEFINE _vigencia_final DATE;     

SET ISOLATION TO DIRTY READ;

--SET DEBUG FILE TO "\\NEMESIS\Ancon\Store Procedures\Debug\sp_rec34b.trc";
--TRACE ON;

-- Nombre de la Compania

--LET  v_nombre_cia = sp_sis01(a_compania); 

CREATE TEMP TABLE tmp_tabla(
    no_poliza       CHAR(10),
	no_endoso       CHAR(5),
	no_unidad       CHAR(5),
	cod_producto    CHAR(5),
	contratante     CHAR(10),
	cod_asegurado   CHAR(10),
	suma_aseg       DEC(16,2),
	prima_neta      DEC(16,2),
	eliminada		INT,
	PRIMARY KEY (no_poliza, no_unidad)
	) WITH NO LOG;

FOREACH
 SELECT	x.no_poliza,
		x.cod_contratante
   INTO	v_poliza,
		v_contratante
   FROM	emipomae x
  WHERE x.no_documento   = TRIM(a_documento)
 	AND x.vigencia_inic  <= fecha
 	AND x.vigencia_final >= fecha
	AND x.actualizado    = 1

	-- Asegurados

	FOREACH
	 SELECT	y.no_endoso,
	        y.no_unidad,
	        y.cod_cliente,
			y.suma_asegurada,
			y.prima_neta,
			y.cod_producto,
			y.vigencia_final
	   INTO	v_endoso,
	        v_unidad,
	        _cod_asegurado,
			v_suma_aseg,
			v_prima_neta,
			_cod_producto,
			_vigencia_final
	   FROM	endedmae x, endeduni y 
	  WHERE x.no_poliza      = v_poliza
	    AND y.no_poliza      = x.no_poliza
		AND y.no_endoso      = x.no_endoso
	    AND x.cod_endomov    IN ('014','011','001')
		AND x.vigencia_final >= fecha
		AND x.actualizado    = 1
	  ORDER BY y.vigencia_final DESC, y.no_unidad ASC

		BEGIN
		  ON EXCEPTION IN(-268, -239)						
		  END EXCEPTION

		  INSERT INTO tmp_tabla(
		  no_poliza,
		  no_endoso,    
		  cod_producto, 
		  contratante,  
		  cod_asegurado,
		  no_unidad,    
		  suma_aseg,    
		  prima_neta,
		  eliminada
		  )
		  VALUES(
		  v_poliza,
		  v_endoso,
		  _cod_producto,
		  v_contratante,
		  _cod_asegurado,
		  v_unidad,     
		  v_suma_aseg,
		  v_prima_neta,
		  0
		  );

		END

	END FOREACH

END FOREACH

FOREACH
	SELECT no_poliza,    
	       no_endoso,
	       cod_producto, 
	       contratante,  
		   cod_asegurado,
		   no_unidad,    
		   suma_aseg,    
		   prima_neta,
		   eliminada
	  INTO v_poliza,
	       v_endoso,
	       _cod_producto,
	       v_contratante,
		   _cod_asegurado,
		   v_unidad,     
		   v_suma_aseg,
		   v_prima_neta,
		   v_eliminada
	  FROM tmp_tabla
  ORDER BY no_unidad

	SELECT nombre 
	  INTO v_asegurado
	  FROM cliclien
	 WHERE cod_cliente = _cod_asegurado;

	SELECT nombre
	  INTO v_producto
	  FROM prdprod
	 WHERE cod_producto = _cod_producto;
	
	RETURN v_poliza,
	       v_endoso,
		   v_unidad,     
		   v_producto,
		   v_contratante,
		   v_asegurado,
	 	   v_suma_aseg,
		   v_prima_neta,
		   _cod_asegurado,
		   v_eliminada
    	   WITH RESUME;
	
END FOREACH

DROP TABLE tmp_tabla;

END PROCEDURE;


