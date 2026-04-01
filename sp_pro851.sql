-- Informaci¢n: para el SEMM 
-- Creado     : 16/04/2009 - Autor: Amado Perez

--DROP PROCEDURE sp_pro851;

create procedure sp_pro851()

returning CHAR(30),  -- 1. Nombre del Titular
          CHAR(30),  -- 2. Cedula
	      CHAR(14),	 --	3. P¢liza
		  CHAR(8),	 -- 4. Placa
		  CHAR(30);	 -- 5. Vehiculo

DEFINE v_nombre			 CHAR(30);
DEFINE v_poliza			 CHAR(14);
DEFINE v_marca			 VARCHAR(50);
DEFINE v_modelo			 VARCHAR(50);
DEFINE v_ano_auto		 CHAR(10);
DEFINE v_placa			 CHAR(10);
DEFINE v_vigencia_inic	 CHAR(10);
DEFINE v_vigencia_final	 CHAR(10);
DEFINE v_no_unidad		 CHAR(10);
DEFINE v_uso_auto	 	 CHAR(1);

DEFINE v_titular		 CHAR(30);
DEFINE v_cedula          CHAR(30);
DEFINE v_vehiculo		 CHAR(30);
DEFINE v_compania		 SMALLINT;
DEFINE v_fechain		 CHAR(8);
DEFINE v_fechaout		 CHAR(8);
DEFINE v_unidad			 CHAR(10);

CREATE TEMP TABLE tmp_anconvig (
	titular  CHAR(30),
	cedula   CHAR(30),
	poliza	 CHAR(14),
	placa	 CHAR(8),	
	vehiculo CHAR(30),
	unidad	 CHAR(10),
	PRIMARY KEY (poliza, unidad)) WITH NO LOG; 
   

SET ISOLATION TO DIRTY READ;

--SET DEBUG FILE TO "sp_pro312.trc";
--TRACE ON;


-- *** Automovil que no son Soda

FOREACH
  SELECT a.no_documento, 
         c.nombre,
  		 d.nombre, 
		 b.nombre,
         b.cedula, 
         g.no_unidad,
		 e.ano_auto,
  		 e.placa
	INTO v_poliza,
		 v_marca,
		 v_modelo,
		 v_nombre,
	     v_cedula,
		 v_no_unidad,
		 v_ano_auto,
		 v_placa
    FROM emipomae a, emimarca c, emimodel d, cliclien b, emipouni g, emiauto f, emivehic e
   WHERE a.no_poliza = g.no_poliza
     AND b.cod_cliente = g.cod_asegurado
     AND f.no_poliza = g.no_poliza
     AND f.no_unidad = g.no_unidad
     AND e.no_motor = f.no_motor
     AND d.cod_marca = e.cod_marca
     AND d.cod_modelo = e.cod_modelo
     AND c.cod_marca = e.cod_marca
     AND (a.cod_ramo = '002'
     AND g.vigencia_inic <= date(current)
     AND g.vigencia_final >= date(current)
     AND a.actualizado = 1
     AND a.linea_rapida <> 1
     AND a.estatus_poliza = 1)

    IF v_marca IS NULL THEN
		LET v_marca = "";
	END IF
    IF v_modelo IS NULL THEN
		LET v_modelo = "";
	END IF
    IF v_ano_auto IS NULL THEN
		LET v_ano_auto = "";
	END IF

	BEGIN

	ON EXCEPTION 
		CONTINUE FOREACH;
	END EXCEPTION
	
	INSERT INTO tmp_anconvig
	VALUES (v_nombre,
	        v_cedula,
	        v_poliza,
			v_placa,
			TRIM(v_marca) || " " || TRIM(v_modelo) || " " || SUBSTRING(v_ano_auto from 1 for 4),
	        v_no_unidad);
	END
   

END FOREACH

FOREACH WITH HOLD
	SELECT titular, 
		   poliza,	
		   placa,	
		   vehiculo,
		   cedula
	  INTO v_titular, 
		   v_poliza,	
		   v_placa,	
		   v_vehiculo,
		   v_cedula
	  FROM tmp_anconvig
  ORDER BY 4

   RETURN  v_titular, 
           v_cedula,
		   v_poliza,	
		   v_placa,	
		   v_vehiculo
		   WITH RESUME;
END FOREACH 

DROP TABLE tmp_anconvig;

end procedure;

		   