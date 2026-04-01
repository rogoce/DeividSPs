-- Ayuda para la impresion de certif. de colectivo de vida

-- Creado    : 17/08/2001 - Autor: Armando Moreno
-- Modificado: 23/11/20011  - Autor: Armando Moreno para que imprima los cert. de col de vida desde emipouni

-- SIS v.2.0 -  - DEIVID, S.A.

DROP PROCEDURE sp_pro72;

CREATE PROCEDURE sp_pro72(a_poliza CHAR(10), a_endoso CHAR(5))
RETURNING CHAR(5),	 -- no_unidad
		  CHAR(100), -- asegurado
		  DEC(16,2), -- suma_asegurada
		  DEC(16,2), -- suma_asegurada_adic
		  DATE,		 -- fecha efectividad(vigencia_inic)
		  DATE,		 -- fecha de emision
		  DATE;		 -- fecha de nacimiento

DEFINE v_asegurado  			CHAR(10);
DEFINE v_unidad       			CHAR(5);
DEFINE v_suma_aseg	  			DEC(16,2);
DEFINE v_suma_aseg_adic  	    DEC(16,2);
DEFINE v_asegurado_nom          CHAR(100);
DEFINE v_eliminada	         	INT;
DEFINE _no_cambio       		CHAR(3);
DEFINE _fecha_emision			DATE;
DEFINE _fecha_efect			    DATE;
DEFINE _fecha_aniversario	    DATE;

SET ISOLATION TO DIRTY READ;

CREATE TEMP TABLE tmp_tabla(
	no_unidad        CHAR(5),
	asegurado        CHAR(10),
	suma_aseg        DEC(16,2),
	suma_aseg_adic   DEC(16,2),
	fecha_efect		 DATE,
	fecha_emision    DATE,
	fecha_nacimiento DATE
	) WITH NO LOG;

-- UNIDADES DE ENDEDUNI
IF a_endoso <> "00000" THEN
FOREACH
	 SELECT	y.no_unidad,
			y.suma_asegurada,
			y.cod_cliente,
			y.vigencia_inic,
			y.suma_aseg_adic
	   INTO	v_unidad,
			v_suma_aseg,
			v_asegurado,
			_fecha_efect,
			v_suma_aseg_adic
	   FROM	endeduni y 
	  WHERE y.no_poliza = a_poliza
		AND y.no_endoso = a_endoso
	  ORDER BY y.no_unidad

	IF v_suma_aseg_adic IS NULL THEN
		LET v_suma_aseg_adic = 0.00;
	END IF

	SELECT fecha_aniversario
	  INTO _fecha_aniversario
	  FROM cliclien
	 WHERE cod_cliente = v_asegurado;

	SELECT fecha_emision
	  INTO _fecha_emision
	  FROM endedmae
	 WHERE no_poliza = a_poliza
	   AND no_endoso = a_endoso;

	  INSERT INTO tmp_tabla(
	  asegurado,
	  no_unidad,  
	  suma_aseg,
	  suma_aseg_adic,
	  fecha_nacimiento,
	  fecha_emision,
	  fecha_efect
	  )
	  VALUES(
	  v_asegurado,
	  v_unidad,     
	  v_suma_aseg,
	  v_suma_aseg_adic,
	  _fecha_aniversario,
	  _fecha_emision,
	  _fecha_efect
	  );
END FOREACH
ELSE
FOREACH
	 SELECT	y.no_unidad,
			y.suma_asegurada,
			y.cod_asegurado,
			y.vigencia_inic,
			y.suma_aseg_adic
	   INTO	v_unidad,
			v_suma_aseg,
			v_asegurado,
			_fecha_efect,
			v_suma_aseg_adic
	   FROM	emipouni y 
	  WHERE y.no_poliza = a_poliza
	  ORDER BY y.no_unidad

	IF v_suma_aseg_adic IS NULL THEN
		LET v_suma_aseg_adic = 0.00;
	END IF

	SELECT fecha_aniversario
	  INTO _fecha_aniversario
	  FROM cliclien
	 WHERE cod_cliente = v_asegurado;

	SELECT fecha_emision
	  INTO _fecha_emision
	  FROM endedmae
	 WHERE no_poliza = a_poliza
	   AND no_endoso = a_endoso;

	  INSERT INTO tmp_tabla(
	  asegurado,
	  no_unidad,  
	  suma_aseg,
	  suma_aseg_adic,
	  fecha_nacimiento,
	  fecha_emision,
	  fecha_efect
	  )
	  VALUES(
	  v_asegurado,
	  v_unidad,     
	  v_suma_aseg,
	  v_suma_aseg_adic,
	  _fecha_aniversario,
	  _fecha_emision,
	  _fecha_efect
	  );
END FOREACH
END IF
FOREACH

	SELECT asegurado,
		   no_unidad,  
		   suma_aseg,
		   suma_aseg_adic,
		   fecha_nacimiento,
		   fecha_emision,
		   fecha_efect
	  INTO v_asegurado,
		   v_unidad,     
		   v_suma_aseg,
		   v_suma_aseg_adic,
		   _fecha_aniversario,
		   _fecha_emision,
		   _fecha_efect
	  FROM tmp_tabla
  ORDER BY no_unidad

  SELECT nombre
	INTO v_asegurado_nom
	FROM cliclien
   WHERE cod_cliente = v_asegurado;
	
	RETURN v_unidad,
		   v_asegurado_nom,
		   v_suma_aseg,
		   v_suma_aseg_adic,
		   _fecha_efect,
		   _fecha_emision,
		   _fecha_aniversario
    	   WITH RESUME;
	
END FOREACH

DROP TABLE tmp_tabla;

END PROCEDURE;


