-- Detalle de las unidades

-- Creado    : 16/07/2001 - Autor: Lic Amado Perez 
-- Modificado: 01/08/2001 - Autor: Demetrio Hurtado Almanza

-- SIS v.2.0 - d_cheq_sp_rec34_dw1 - DEIVID, S.A.
DROP PROCEDURE sp_rec34bb;
CREATE PROCEDURE sp_rec34bb(a_documento CHAR(20), fecha DATE)
RETURNING CHAR(10),  -- no_poliza
          CHAR(5),   -- no_endoso
		  CHAR(5),	 -- no_unidad
		  CHAR(50),  -- producto      
		  CHAR(10),  -- cod_contratante
		  CHAR(100), -- nombre_asegurado
		  DEC(16,2), -- suma_asegurada
		  DEC(16,2), -- prima_neta
		  CHAR(10),  -- cod_asegurado
		  INT,		 -- eliminada
		  CHAR(5);

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

--SET DEBUG FILE TO "sp_rec34b.trc";
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
	asegurado       char(100),
	PRIMARY KEY (no_poliza, no_unidad)
	) WITH NO LOG;

LET v_poliza = sp_sis21(a_documento);

FOREACH
 SELECT	x.cod_contratante
   INTO	v_contratante
   FROM	emipomae x
  WHERE x.no_poliza   = TRIM(v_poliza)
	AND x.actualizado    = 1

{ 	AND x.vigencia_inic  <= fecha
 	AND x.vigencia_final >= fecha}

	-- Asegurados

	FOREACH
	 SELECT	'00000',
	        y.no_unidad,
	        y.cod_asegurado,
			y.suma_asegurada,
			y.prima_neta,
			y.cod_producto
	   INTO	v_endoso,
	        v_unidad,
	        _cod_asegurado,
			v_suma_aseg,
			v_prima_neta,
			_cod_producto
	   FROM	emipouni y 
	  WHERE y.no_poliza = v_poliza
	    AND y.vigencia_inic <= fecha
		AND (y.no_activo_desde IS NULL
		 OR y.no_activo_desde > fecha)

--	  ORDER BY y.no_unidad ASC
		SELECT nombre 
		  INTO v_asegurado
		  FROM cliclien
		 WHERE cod_cliente = _cod_asegurado;

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
		  eliminada,
		  asegurado
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
		  0,
		  v_asegurado
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
		   eliminada,
		   asegurado
	  INTO v_poliza,
	       v_endoso,
	       _cod_producto,
	       v_contratante,
		   _cod_asegurado,
		   v_unidad,     
		   v_suma_aseg,
		   v_prima_neta,
		   v_eliminada,
		   v_asegurado
	  FROM tmp_tabla
  ORDER BY asegurado

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
		   v_eliminada,
		   _cod_producto
    	   WITH RESUME;
	
END FOREACH

--DROP TABLE tmp_tabla;

END PROCEDURE;


