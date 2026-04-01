
-- Detalle de las unidades

-- Creado    : 22/11/2000 - Autor: Amado Perez 
-- Modificado: 23/05/2001 - Autor: Marquelda Valdelamar

-- SIS v.2.0 - d_cheq_sp_rec34_dw1 - DEIVID, S.A.

DROP PROCEDURE sp_yos07;

CREATE PROCEDURE sp_yos07(a_no_poliza CHAR(255))
RETURNING CHAR(10),		-- no_poliza
		  char(5),  	-- no_endoso
		  char(5),     	-- cod_marca
		  CHAR(50), 	-- marca
		  CHAR(5),  	-- cod_modelo
		  CHAR(50),  	-- Modelo
		  integer,		-- ano_auto
		  integer	, 	-- valor_original
		  CHAR(10), 	-- placa
		  char(5),		-- no_unidad
		  char(30),		-- no_motor
		  char(30), 	-- no_chasis
		  integer, 		-- tamano
		  CHAR(5), 		-- cod_producto
		  dec(16,2); 	-- suma_asegurada;


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
DEFINE _cod_leasing             CHAR(10);
DEFINE _cod_producto            char(5);
define v_tamano                 integer;
define fecha                   date;
define _tipo				   char(1);
DEFINE _vigencia_final, _fecha_emision DATE;

SET ISOLATION TO DIRTY READ;

--SET DEBUG FILE TO "sp_rec34.trc";
--TRACE ON;

-- Nombre de la Compania

--LET  v_nombre_cia = sp_sis01(a_compania); 

drop table if exists tmp_tabla;
CREATE TEMP TABLE tmp_tabla(
    no_poliza       CHAR(10),
	no_endoso       CHAR(5),
	no_unidad       CHAR(5),
	suma_aseg       DEC(16,2),
    valor_original  DEC(16,2),
    ano_auto        INT,
    no_chasis       CHAR(30),
    tamano          int,
    placa		    CHAR(10),
	cod_marca		char(5),
    nombre_marca    CHAR(50), 
	cod_modelo      char(5),
    nombre_modelo   CHAR(50),
	motor			CHAR(30),
	eliminada       INT DEFAULT 0,
	cod_producto    CHAR(5)
	) WITH NO LOG;

let _cod_producto = null;
let _tipo = sp_sis04(a_no_poliza);
let fecha = today;
-- UNIDADES DE EMIPOUNI
	FOREACH
		 SELECT	y.no_poliza,
				y.no_unidad,
				y.suma_asegurada,
				y.desc_unidad,
				y.vigencia_inic,
				y.vigencia_final,
				y.cod_asegurado,
				y.cod_producto
		   INTO	v_poliza,
				v_unidad,
				v_suma_aseg,
				v_desc_uni,
				v_vigen_ini,
				v_vigen_fin,
				_cod_leasing,
				_cod_producto
		   FROM	emipouni y
		  WHERE y.no_poliza in(select * from tmp_codigos)
		  ORDER BY y.no_unidad

		LET v_eliminada = 0;
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
			   valor_original,
			   ano_auto,
			   no_chasis,
			   placa
		  INTO _cod_marca,
		       _cod_modelo,
			   v_valor_original,
			   v_ano_auto,
			   v_no_chasis,
			   v_placa
		  FROM emivehic
		 WHERE no_motor = v_motor;

		 SELECT nombre
		   INTO v_nombre_marca
		   FROM emimarca
		  WHERE cod_marca = _cod_marca;

		 SELECT nombre,
				tamano
		   INTO v_nombre_modelo,
		        v_tamano
		   FROM emimodel
		  WHERE cod_modelo = _cod_modelo;

	  INSERT INTO tmp_tabla(
	  no_poliza,
	  no_endoso,
	  no_unidad,
	  suma_aseg,
	  valor_original,
	  ano_auto,
	  no_chasis,
	  tamano,
	  placa,
	  nombre_marca,
	  nombre_modelo,
	  motor,
	  eliminada,
	  cod_producto,
	  cod_marca,
	  cod_modelo
	  )
	  VALUES(
	  v_poliza,
	  '00000',
	  v_unidad, 
	  v_suma_aseg,
	  v_valor_original,
	  v_ano_auto,
	  v_no_chasis,
	  v_tamano,
	  v_placa,
	  v_nombre_marca,
	  v_nombre_modelo,
	  v_motor,
	  v_eliminada,
	  _cod_producto, 
      _cod_marca,
	  _cod_modelo
	  );
	END FOREACH

-- UNIDADES ELIMINADAS DE ENDEDUNI

	FOREACH

	 SELECT	y.no_poliza,
			y.no_unidad,
			y.suma_asegurada,
			y.desc_unidad,
			y.no_endoso,
			y.vigencia_inic,
			y.vigencia_final,
			y.cod_cliente,
			x.fecha_emision,
			y.cod_producto
	   INTO	v_poliza,
			v_unidad,
			v_suma_aseg,
			v_desc_uni,
			v_noendoso,
			v_vigen_ini,
			v_vigen_fin,
			_cod_leasing,
			_fecha_emision,
			_cod_producto
	   FROM	endedmae x, endeduni y
	  WHERE x.no_poliza in(select * from tmp_codigos)
	    AND y.no_poliza = x.no_poliza
		AND y.no_endoso = x.no_endoso
	    AND x.cod_endomov = '005'
	  ORDER BY y.no_unidad

	LET v_eliminada = 0;

	SELECT no_motor
	  INTO v_motor
	  FROM endmoaut
	 WHERE no_poliza = v_poliza
	   AND no_unidad = v_unidad
	   AND no_endoso = v_noendoso;

	-- Descripcion del Vehiculo
		SELECT cod_marca,
			   cod_modelo,
			   valor_original,
			   ano_auto,
			   no_chasis,
			   placa
		  INTO _cod_marca,
		       _cod_modelo,
			   v_valor_original,
			   v_ano_auto,
			   v_no_chasis,
			   v_placa
		  FROM emivehic
		 WHERE no_motor = v_motor;

		 SELECT nombre
		   INTO v_nombre_marca
		   FROM emimarca
		  WHERE cod_marca = _cod_marca;

		 SELECT nombre,
				tamano
		   INTO v_nombre_modelo,
		        v_tamano
		   FROM emimodel
		  WHERE cod_modelo = _cod_modelo;

	  INSERT INTO tmp_tabla(
	  no_poliza,
	  no_endoso,
	  no_unidad,
	  suma_aseg,
	  valor_original,
	  ano_auto,
	  no_chasis,
	  tamano,
	  placa,
	  nombre_marca,
	  nombre_modelo,
	  motor,
	  eliminada,
	  cod_producto,
	  cod_marca,
	  cod_modelo
	  )
	  VALUES(
	  v_poliza,
	  v_noendoso,
	  v_unidad, 
	  v_suma_aseg,
	  v_valor_original,
	  v_ano_auto,
	  v_no_chasis,
	  v_tamano,
	  v_placa,
	  v_nombre_marca,
	  v_nombre_modelo,
	  v_motor,
	  v_eliminada,
	  _cod_producto, 
      _cod_marca,
	  _cod_modelo
	  );
	END FOREACH

drop table tmp_codigos;
FOREACH

	SELECT no_poliza,
	       no_endoso,
		   no_unidad,
		   suma_aseg,
  		   valor_original,
  		   ano_auto,
           no_chasis,
           tamano,
  		   placa,
           nombre_marca,
           nombre_modelo,
		   motor,
           eliminada,
		   cod_producto,
		   cod_marca,
		   cod_modelo
	  INTO v_poliza,
	       v_noendoso,
		   v_unidad, 
		   v_suma_aseg,
		   v_valor_original,
           v_ano_auto,
           v_no_chasis,
           v_tamano,
           v_placa,
           v_nombre_marca,
           v_nombre_modelo,
		   v_motor,
           v_eliminada,
		   _cod_producto,
_cod_marca,
_cod_modelo		   
	  FROM tmp_tabla
  ORDER BY no_unidad


	RETURN v_poliza,
		   v_noendoso,
		   _cod_marca,
		   v_nombre_marca,
		   _cod_modelo,
		   v_nombre_modelo,
		   v_ano_auto,
		   v_valor_original,
		   v_placa,
	 	   v_unidad,
		   v_motor,
		   v_no_chasis,
		   v_tamano,
		   _cod_producto,
		   v_suma_aseg
    	   WITH RESUME;

END FOREACH

DROP TABLE tmp_tabla;

END PROCEDURE;