
-- Detalle de las unidades	- SALUD

-- Creado    : 14/08/2001 - Autor: Amado Perez 
-- Modificado: 

-- SIS v.2.0 -  - DEIVID, S.A.

DROP PROCEDURE sp_pro701b;

CREATE PROCEDURE sp_pro701b(a_poliza CHAR(10))
RETURNING CHAR(5),	 -- no_unidad
		  CHAR(100), -- contratante
		  DEC(16,2), -- suma_asegurada
		  CHAR(50),	 -- desc_unidad
		  SMALLINT;  -- unidad activa o inactiva


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
DEFINE _activo					smallint;
DEFINE _cont                    smallint;


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
	activo          smallint default 1
	) WITH NO LOG;



-- UNIDADES DE ENDEDUNI

FOREACH

	 SELECT	y.no_unidad,
			y.suma_asegurada,
			y.desc_unidad,
			y.cod_asegurado,
			y.activo
	   INTO	v_unidad,
			v_suma_aseg,
			v_desc_uni,
			v_contratante,
			_activo
	   FROM	emipouni y 
	  WHERE y.no_poliza = a_poliza
--	    and y.activo    = 1
	  ORDER BY y.no_unidad

	 LET _cont = 0 ;
	  
	 SELECT count(*)
       INTO _cont
       FROM emidepen
      WHERE no_poliza = a_poliza
        AND no_unidad = v_unidad;	

     IF _cont IS NULL THEN
		LET _cont = 0 ;
	 END IF
--
	IF _cont > 0 THEN
	  INSERT INTO tmp_tabla(
	  contratante,
	  no_unidad,  
	  suma_aseg,  
	  desc_uni,
	  activo
	  )
	  VALUES(
	  v_contratante,
	  v_unidad,     
	  v_suma_aseg,	
	  v_desc_uni,
	  _activo
	  );
	 END IF
END FOREACH

FOREACH

	SELECT contratante,
		   no_unidad,  
		   suma_aseg,  
		   desc_uni,
		   activo
	  INTO v_contratante,
		   v_unidad,     
		   v_suma_aseg,	
		   v_desc_uni,
		   _activo
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
		   _activo
    	   WITH RESUME;
	
END FOREACH

DROP TABLE tmp_tabla;

END PROCEDURE;


