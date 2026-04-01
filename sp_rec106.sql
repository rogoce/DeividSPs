-- Busqueda de Unidade para proyecto de reclamos de salud

-- Creado    : 10/06/2005 - Autor: Demetrio Hurtado ALmanza

-- SIS v.2.0 - d_busqueda_asegurados - DEIVID, S.A.

--OP PROCEDURE sp_rec106;

CREATE PROCEDURE sp_rec106(a_documento CHAR(20), fecha DATE)
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

--SET DEBUG FILE TO "sp_rec106.trc";
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

	let v_poliza = sp_sis21(a_documento);

 SELECT	x.cod_contratante
   INTO	v_contratante
   FROM	emipomae x
  WHERE no_poliza = v_poliza;

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
	  ORDER BY y.no_unidad ASC

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

