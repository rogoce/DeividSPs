
-- Detalle de las unidades

-- Creado    : 14/08/2001 - Autor: Amado Perez 
-- Modificado: 

-- SIS v.2.0 -  - DEIVID, S.A.

DROP PROCEDURE sp_pro70;

CREATE PROCEDURE sp_pro70(a_poliza CHAR(10), a_endoso CHAR(5))
RETURNING CHAR(5),	-- no_unidad
		  CHAR(100), -- contratante
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
		  CHAR(50); -- nombre_modelo


DEFINE v_contratante  			CHAR(10);
DEFINE v_unidad       			CHAR(5);
DEFINE v_suma_aseg	  			DEC(16,2);
DEFINE v_desc_uni	  			CHAR(50);
DEFINE v_motor        			CHAR(30);
DEFINE v_contratante_nom        CHAR(100);

DEFINE _cod_marca			  	CHAR(5);
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
DEFINE _vigencia_final			DATE;


SET ISOLATION TO DIRTY READ;

--SET DEBUG FILE TO "sp_rec34.trc";
--TRACE ON;

-- Nombre de la Compania

--LET  v_nombre_cia = sp_sis01(a_compania); 

CREATE TEMP TABLE tmp_tabla(
	no_unidad       CHAR(5),
	contratante     CHAR(10),
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
	motor			CHAR(30)
	) WITH NO LOG;



-- UNIDADES DE ENDEDUNI

FOREACH

	 SELECT	y.no_unidad,
			y.suma_asegurada,
			y.desc_unidad,
			y.cod_cliente
	   INTO	v_unidad,
			v_suma_aseg,
			v_desc_uni,
			v_contratante
	   FROM	endeduni y 
	  WHERE y.no_poliza = a_poliza
		AND y.no_endoso = a_endoso
	  ORDER BY y.no_unidad


	SELECT no_motor
	  INTO v_motor
	  FROM endmoaut
	 WHERE no_poliza = a_poliza
	   AND no_unidad = v_unidad
	   AND no_endoso = a_endoso;

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
--
	  INSERT INTO tmp_tabla(
	  contratante,
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
	  motor
	  )
	  VALUES(
	  v_contratante,
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
	  v_motor
	  );
END FOREACH



FOREACH

	SELECT contratante,
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
		   motor
	  INTO v_contratante,
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
		   v_motor
	  FROM tmp_tabla
  ORDER BY no_unidad

  SELECT nombre
	INTO v_contratante_nom
	FROM cliclien
   WHERE cod_cliente = v_contratante;
	
	RETURN v_unidad,
		   v_contratante_nom,
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
           v_nombre_modelo
    	   WITH RESUME;
	
END FOREACH

DROP TABLE tmp_tabla;

END PROCEDURE;


