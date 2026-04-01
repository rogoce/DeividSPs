-- Procedimiento que Retorna la Depreciacion por Unidad

-- Creado    : 18/05/2001 - Autor: Demetrio Hurtado Almanza  
-- Modificado: 18/05/2001 - Autor: Demetrio Hurtado Almanza

-- SIS v.2.0 - d_prod_ren_sel_de_pol_a_ren - DEIVID, S.A.

DROP PROCEDURE sp_pro28b;

CREATE PROCEDURE "informix".sp_pro28b(a_no_poliza CHAR(10))
RETURNING CHAR(5),
		  DEC(16,2),
		  DEC(16,2),
		  CHAR(1),
		  CHAR(50),
		  CHAR(30),
		  CHAR(50),
		  CHAR(50);	

DEFINE _cantidad		INTEGER;
DEFINE _no_unidad		CHAR(5);
DEFINE _cod_tipoveh		CHAR(3);
DEFINE _uso_auto		CHAR(1);
DEFINE _no_motor		CHAR(30);
DEFINE _nombre_marca	CHAR(50);
DEFINE _nombre_modelo	CHAR(50);
DEFINE _nombre_tipoveh	CHAR(50);
DEFINE _porc_depre		DEC(16,2);
DEFINE _suma_asegurada  DEC(16,2);
DEFINE _cod_marca		CHAR(5);
DEFINE _cod_modelo		CHAR(5);

FOREACH
 SELECT no_unidad,
		suma_asegurada
   INTO _no_unidad,
		_suma_asegurada
   FROM emipouni
  WHERE no_poliza = a_no_poliza

	SELECT porc_depreciacion
	  INTO _porc_depre
	  FROM emirepod
	 WHERE no_poliza = a_no_poliza
	   AND no_unidad = _no_unidad;

	IF _porc_depre IS NULL THEN
		LET _porc_depre = 0;
		INSERT INTO emirepod
		VALUES (a_no_poliza, _no_unidad, 0.00);
	END IF
	
	SELECT no_motor,
	       cod_tipoveh,
		   uso_auto
	  INTO _no_motor,
	       _cod_tipoveh,
		   _uso_auto
	  FROM emiauto
	 WHERE no_poliza = a_no_poliza
	   AND no_unidad = _no_unidad;

	SELECT cod_marca,
	       cod_modelo
	  INTO _cod_marca,
	       _cod_modelo
	  FROM emivehic
	 WHERE no_motor = _no_motor;

	SELECT nombre
	  INTO _nombre_marca
	  FROM emimarca
	 WHERE cod_marca = _cod_marca;

	SELECT nombre
	  INTO _nombre_modelo
	  FROM emimodel
	 WHERE cod_modelo = _cod_modelo;

	SELECT nombre
	  INTO _nombre_tipoveh
	  FROM emitiveh
	 WHERE cod_tipoveh = _cod_tipoveh;


	RETURN _no_unidad,
		   _porc_depre,
		   _suma_asegurada,
		   _uso_auto,
		   _nombre_tipoveh,
		   _no_motor,
		   _nombre_marca,
		   _nombre_modelo
		   WITH RESUME;
		   	
END FOREACH

END PROCEDURE;
