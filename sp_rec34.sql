
-- Detalle de las unidades

-- Creado    : 22/11/2000 - Autor: Amado Perez 
-- Modificado: 23/05/2001 - Autor: Marquelda Valdelamar

-- SIS v.2.0 - d_cheq_sp_rec34_dw1 - DEIVID, S.A.

DROP PROCEDURE sp_rec34;

CREATE PROCEDURE sp_rec34(a_documento CHAR(20), fecha DATE)
RETURNING CHAR(10),	-- no_poliza
		  DATE,  	-- Vigen Ini
		  DATE,     -- Vigen Fin
		  CHAR(10), -- cod_contratante
		  CHAR(3),  -- cod_ramo
		  CHAR(5),  -- no_unidad
		  DEC(16,2),-- suma_asegurada
		  CHAR(50), -- desc_unidad
		  CHAR(30), -- no_motor
		  DEC(16,2),-- valor_auto
		  DEC(16,2),-- valor_original
		  INT,      -- ano_auto
		  CHAR(30), -- no_chasis
		  CHAR(30), -- vin
		  CHAR(10), -- placa
		  CHAR(10), -- placa taxi
		  INT,      -- nuevo
		  CHAR(50), -- nombre_marca
		  CHAR(50), -- nombre_modelo
		  CHAR(5),
 		  INT,		-- eliminada
		  SMALLINT,
		  SMALLINT,
		  CHAR(10),
		  CHAR(5);


DEFINE v_poliza       			CHAR(10);
DEFINE _no_endoso      			CHAR(10);
DEFINE v_vigen_ini	  			DATE; 
DEFINE v_vigen_fin    			DATE; 
DEFINE v_contratante  			CHAR(10);
DEFINE v_ramo      	  			CHAR(3);
DEFINE v_unidad       			CHAR(5);
DEFINE v_suma_aseg	  			DEC(16,2);
DEFINE v_desc_uni	  			CHAR(50);
DEFINE v_motor        			CHAR(30);
DEFINE _abierta, v_serie        SMALLINT;

DEFINE _cod_marca, v_noendoso  	CHAR(5);
DEFINE _cod_modelo	   			CHAR(5);
DEFINE v_valor_auto	   			DEC(16,2);
DEFINE v_valor_original 		DEC(16,2);
DEFINE v_ano_auto       		INT;
DEFINE v_no_chasis      		CHAR(30);
DEFINE v_vin            		CHAR(30); 
DEFINE v_placa		   			CHAR(10);
DEFINE v_placa_taxi     		CHAR(10);
DEFINE v_nuevo, v_eliminada		INT;
DEFINE v_nombre_marca  			CHAR(50);
DEFINE v_nombre_modelo  		CHAR(50);
DEFINE _no_cambio       		CHAR(3);
DEFINE _vigencia_final, _fecha_emision DATE;
DEFINE _leasing                 SMALLINT;
DEFINE _cod_leasing             CHAR(10);
DEFINE _cod_producto            char(5);

SET ISOLATION TO DIRTY READ;

--SET DEBUG FILE TO "sp_rec34.trc";
--TRACE ON;

-- Nombre de la Compania

--LET  v_nombre_cia = sp_sis01(a_compania); 

drop table if exists tmp_tabla;
CREATE TEMP TABLE tmp_tabla(
    no_poliza       CHAR(10),
	no_endoso       CHAR(5),
	vigen_ini		DATE,
	vigen_fin       DATE,
	contratante     CHAR(10),
	cod_ramo        CHAR(3),
	no_unidad       CHAR(5),
	suma_aseg       DEC(16,2),
	desc_uni        CHAR(50),
	valor_auto	    DEC(16,2),
    valor_original  DEC(16,2),
    ano_auto        INT,
    no_chasis       CHAR(30),
    vin             CHAR(30),
    placa		    CHAR(10),
    placa_taxi      CHAR(10),
    nuevo		    INT,
    nombre_marca    CHAR(50), 
    nombre_modelo   CHAR(50),
	motor			CHAR(30),
	eliminada       INT DEFAULT 0,
	serie           SMALLINT,
	leasing         SMALLINT DEFAULT 0,
	cod_leasing     CHAR(10),
	cod_producto    CHAR(5)
	) WITH NO LOG;

let _cod_producto = null;

FOREACH

 SELECT	x.no_poliza,
        x.cod_ramo,
		x.cod_contratante,
		x.vigencia_final,
		x.abierta,
		x.serie,
		x.leasing
   INTO	v_poliza,
        v_ramo,
		v_contratante,
		_vigencia_final,
		_abierta,
		v_serie,
		_leasing
   FROM	emipomae x
  WHERE x.no_documento = TRIM(a_documento)
 	AND ((x.vigencia_inic <= fecha
 	AND x.vigencia_final >= fecha)
	 OR (x.vigencia_inic <= fecha
	AND x.vigencia_final is null)
	 OR (x.vigencia_inic <= fecha
	AND x.abierta = 1))
	AND x.actualizado = 1

-- UNIDADES DE EMIPOUNI

	FOREACH
		 SELECT	y.no_unidad,
				y.suma_asegurada,
				y.desc_unidad,
				y.vigencia_inic,
				y.vigencia_final,
				y.cod_asegurado,
				y.cod_producto
		   INTO	v_unidad,
				v_suma_aseg,
				v_desc_uni,
				v_vigen_ini,
				v_vigen_fin,
				_cod_leasing,
				_cod_producto
		   FROM	emipouni y
		  WHERE y.no_poliza = v_poliza
		  ORDER BY y.no_unidad

		LET v_eliminada = 0;

		IF   (v_vigen_ini <= fecha AND v_vigen_fin >= fecha) 
		  OR (v_vigen_ini <= fecha	AND v_vigen_fin is null) 
		  OR (v_vigen_ini <= fecha	AND _abierta = 1) THEN
			 LET v_eliminada = 0;
		ELSE
			 LET v_eliminada = 1;
		END IF

		LET v_motor = '';

	    SELECT no_motor
		  INTO v_motor
		  FROM emiauto
		 WHERE no_poliza = v_poliza
		   AND no_unidad = v_unidad;

		IF v_motor IS NULL OR v_motor = '' THEN
			FOREACH
				SELECT no_motor,
					   no_endoso
				  INTO v_motor,
					   _no_endoso
				  FROM endmoaut
				 WHERE no_poliza = v_poliza
				   AND no_unidad = v_unidad
			  ORDER BY no_endoso DESC
			  EXIT FOREACH;
			END FOREACH
		END IF

	-- Descripcion del Vehiculo
		SELECT cod_marca,
			   cod_modelo,
			   valor_auto,
			   valor_original,
			   ano_auto,
			   no_chasis,
			   vin,
			   placa,
			   nuevo,
			   placa_taxi
		  INTO _cod_marca,
		       _cod_modelo,
			   v_valor_auto,
			   v_valor_original,
			   v_ano_auto,
			   v_no_chasis,
			   v_vin,
			   v_placa,
			   v_nuevo,
			   v_placa_taxi
		  FROM emivehic
		 WHERE no_motor = v_motor;

		 SELECT nombre
		   INTO v_nombre_marca
		   FROM emimarca
		  WHERE cod_marca = _cod_marca;

		 SELECT nombre
		   INTO v_nombre_modelo
		   FROM emimodel
		  WHERE cod_modelo = _cod_modelo;

	  INSERT INTO tmp_tabla(
	  no_poliza,
	  no_endoso,
	  vigen_ini,
	  vigen_fin,
	  contratante,
	  cod_ramo, 
	  no_unidad,
	  suma_aseg,
	  desc_uni,
	  valor_auto,
	  valor_original,
	  ano_auto,
	  no_chasis,
	  vin,
	  placa,
	  placa_taxi,
	  nuevo,
	  nombre_marca,
	  nombre_modelo,
	  motor,
	  eliminada,
	  serie,
	  leasing,    
	  cod_leasing,
	  cod_producto
	  )
	  VALUES(
	  v_poliza,
	  '00000',
	  v_vigen_ini,
	  v_vigen_fin,
	  v_contratante,
	  v_ramo, 
	  v_unidad, 
	  v_suma_aseg,
	  v_desc_uni,
	  v_valor_auto,
	  v_valor_original,
	  v_ano_auto,
	  v_no_chasis,
	  v_vin,
	  v_placa,
	  v_placa_taxi,
	  v_nuevo,
	  v_nombre_marca,
	  v_nombre_modelo,
	  v_motor,
	  v_eliminada,
	  v_serie,
	  _leasing,    
	  _cod_leasing,
	  _cod_producto	
	  );
	END FOREACH

-- UNIDADES ELIMINADAS DE ENDEDUNI

	FOREACH

	 SELECT	y.no_unidad,
			y.suma_asegurada,
			y.desc_unidad,
			y.no_endoso,
			y.vigencia_inic,
			y.vigencia_final,
			y.cod_cliente,
			x.fecha_emision,
			y.cod_producto
	   INTO	v_unidad,
			v_suma_aseg,
			v_desc_uni,
			v_noendoso,
			v_vigen_ini,
			v_vigen_fin,
			_cod_leasing,
			_fecha_emision,
			_cod_producto
	   FROM	endedmae x, endeduni y
	  WHERE x.no_poliza = v_poliza
	    AND y.no_poliza = x.no_poliza
		AND y.no_endoso = x.no_endoso
	    AND x.cod_endomov = '005'
		AND x.actualizado = 1
	 	AND (x.vigencia_inic > fecha
		 OR (x.vigencia_inic <= fecha AND x.fecha_emision > fecha))
	  ORDER BY y.no_unidad

	LET v_eliminada = 0;

	IF   (v_vigen_ini > fecha AND v_vigen_fin >= fecha) 
	  OR (v_vigen_ini > fecha AND v_vigen_fin is null)
	  OR (v_vigen_ini <= fecha AND _fecha_emision > fecha)
	  OR (v_vigen_ini <= fecha	AND _abierta = 1) THEN
		 LET v_eliminada = 0;
	ELSE
		 LET v_eliminada = 1;
	END IF


	SELECT no_motor
	  INTO v_motor
	  FROM endmoaut
	 WHERE no_poliza = v_poliza
	   AND no_unidad = v_unidad
	   AND no_endoso = v_noendoso;

	-- Descripcion del Vehiculo
		SELECT cod_marca,
			   cod_modelo,
			   valor_auto,
			   valor_original,
			   ano_auto,
			   no_chasis,
			   vin,
			   placa,
			   nuevo,
			   placa_taxi
		  INTO _cod_marca,
		       _cod_modelo,
			   v_valor_auto,
			   v_valor_original,
			   v_ano_auto,
			   v_no_chasis,
			   v_vin,
			   v_placa,
			   v_nuevo,
			   v_placa_taxi
		  FROM emivehic
		 WHERE no_motor = v_motor;

		 SELECT nombre
		   INTO v_nombre_marca
		   FROM emimarca
		  WHERE cod_marca = _cod_marca;

		 SELECT nombre
		   INTO v_nombre_modelo
		   FROM emimodel
		  WHERE cod_modelo = _cod_modelo;

	  INSERT INTO tmp_tabla(
	  no_poliza,
	  no_endoso,
	  vigen_ini,	
	  vigen_fin,
	  contratante,
	  cod_ramo, 
	  no_unidad,
	  suma_aseg,
	  desc_uni,
	  valor_auto,
	  valor_original,
	  ano_auto,
	  no_chasis,
	  vin,
	  placa,
	  placa_taxi,
	  nuevo,
	  nombre_marca,
	  nombre_modelo,
	  motor,
	  eliminada,
	  serie,
	  leasing,    
	  cod_leasing,
	  cod_producto
	  )
	  VALUES(
	  v_poliza,
	  v_noendoso,
	  v_vigen_ini,	
	  v_vigen_fin,
	  v_contratante,
	  v_ramo, 
	  v_unidad, 
	  v_suma_aseg,
	  v_desc_uni,
	  v_valor_auto,
	  v_valor_original,
	  v_ano_auto,
	  v_no_chasis,
	  v_vin,
	  v_placa,
	  v_placa_taxi,
	  v_nuevo,
	  v_nombre_marca,
	  v_nombre_modelo,
	  v_motor,
	  v_eliminada,
	  v_serie,
	  _leasing,    
	  _cod_leasing,
	  _cod_producto
	  );
	END FOREACH

END FOREACH


FOREACH

	SELECT no_poliza,
	       no_endoso,
	       vigen_ini,	
		   vigen_fin,
		   contratante,
		   cod_ramo, 
		   no_unidad,
		   suma_aseg,
		   desc_uni,
		   valor_auto,
  		   valor_original,
  		   ano_auto,
           no_chasis,
           vin,
  		   placa,
           placa_taxi,
           nuevo,
           nombre_marca,
           nombre_modelo,
		   motor,
           eliminada,
           serie, 
		   leasing,    
		   cod_leasing,
		   cod_producto
	  INTO v_poliza,
	       v_noendoso,
	       v_vigen_ini,	
		   v_vigen_fin,
		   v_contratante,
		   v_ramo, 
		   v_unidad, 
		   v_suma_aseg,
		   v_desc_uni,
		   v_valor_auto,
		   v_valor_original,
           v_ano_auto,
           v_no_chasis,
           v_vin,
           v_placa,
           v_placa_taxi,
           v_nuevo,
           v_nombre_marca,
           v_nombre_modelo,
		   v_motor,
           v_eliminada,
		   v_serie,
		   _leasing,    
		   _cod_leasing,
		   _cod_producto	
	  FROM tmp_tabla
  ORDER BY no_unidad


	RETURN v_poliza,
		   v_vigen_ini,
		   v_vigen_fin,
		   v_contratante,
		   v_ramo, 
	 	   v_unidad,
		   v_suma_aseg,
		   v_desc_uni,
		   v_motor,
		   v_valor_auto,
		   v_valor_original,
           v_ano_auto,
           v_no_chasis,
           v_vin,
           v_placa,
           v_placa_taxi,
           v_nuevo,
           v_nombre_marca,
           v_nombre_modelo,
		   v_noendoso,
		   v_eliminada,
		   v_serie,
		   _leasing,
		   _cod_leasing,
		   _cod_producto
    	   WITH RESUME;

END FOREACH

DROP TABLE tmp_tabla;

END PROCEDURE;

