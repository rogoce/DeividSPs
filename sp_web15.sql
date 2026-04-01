
-- Detalle de las unidades	- SALUD

-- Creado    : 14/08/2001 - Autor: Amado Perez 
-- Duplicado : 10/07/2012 - Autor: Federico Coronado
-- duplicado porque el procedimiento sp_pro701 muestra todas las unidades de la poliza incluyendo las inactivas.
-- Modificado: 

-- SIS v.2.0 -  - Pagina Web, S.A.

DROP PROCEDURE sp_web15;

CREATE PROCEDURE sp_web15(a_poliza CHAR(10))
RETURNING CHAR(5),		-- no_unidad
		  CHAR(100), 	-- contratante
		  DEC(16,2),	-- suma_asegurada
		  CHAR(50), 	-- desc_unidad
		  char(30), 	-- cedula
		  varchar(250),
		  varchar(250),
		  varchar(10);

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
DEFINE v_cedula_unidad			CHAR(30);
DEFINE _vigencia_final			DATE;
define v_cod_dependiente1       varchar(250);
define v_cod_dependiente        varchar(10);
define v_nombre_dependiente     varchar(100);
define v_nombre_dependiente1    varchar(250);


SET ISOLATION TO DIRTY READ;

--SET DEBUG FILE TO "sp_web15.trc";
--TRACE ON;

-- Nombre de la Compania

--LET  v_nombre_cia = sp_sis01(a_compania); 

CREATE TEMP TABLE tmp_tabla(
	no_unidad       CHAR(5),
	contratante     CHAR(10),
	suma_aseg       DEC(16,2),
	desc_uni        CHAR(50),
	nombre          VARCHAR(100),
	cedula          varchar(30),
	cod_dependiente varchar(250),
	nombre_dependiente varchar(250)
	) WITH NO LOG;



-- UNIDADES DE ENDEDUNI

FOREACH

	 SELECT	y.no_unidad,
			y.suma_asegurada,
			y.cod_asegurado
	   INTO	v_unidad,
			v_suma_aseg,
			v_contratante
	   FROM	emipouni y 
	  WHERE y.no_poliza = a_poliza
	  and y.activo = 1
	  ORDER BY y.no_unidad
	  
	let v_cod_dependiente1 = "";
	let v_nombre_dependiente1 = ""; 	
	
	  SELECT nombre,
			 cedula
	    INTO v_contratante_nom,
			 v_cedula_unidad
		FROM cliclien
	   WHERE cod_cliente = v_contratante;
	
	foreach
		select cod_cliente
		  into v_cod_dependiente
		  from emidepen 
		 where no_poliza = a_poliza
		   and no_unidad = v_unidad
		   
	  SELECT nombre
	    INTO v_nombre_dependiente
		FROM cliclien
	   WHERE cod_cliente = v_cod_dependiente;
	
	if v_nombre_dependiente = '' or v_nombre_dependiente is null then
	  continue foreach;
	end if
	
	let v_nombre_dependiente1 = trim(v_nombre_dependiente1) || "|" ||trim(v_nombre_dependiente);
	let v_cod_dependiente1 = trim(v_cod_dependiente1) || "|" ||trim(v_cod_dependiente);
	
	end foreach
--
	  INSERT INTO tmp_tabla(
	  contratante,
	  no_unidad,  
	  suma_aseg,  
	  desc_uni,
	  nombre,
	  cedula,
	  cod_dependiente,
	  nombre_dependiente
	  )
	  VALUES(
	  v_contratante,
	  v_unidad,     
	  v_suma_aseg,	
	  v_contratante_nom,
	  v_contratante_nom,
	  v_cedula_unidad,
	  v_cod_dependiente1,
	  v_nombre_dependiente1
	  );
END FOREACH

FOREACH

	SELECT nombre,
		   no_unidad,  
		   suma_aseg,  
		   desc_uni,
		   cedula,
		   cod_dependiente,
		   nombre_dependiente,
		   contratante
	  INTO v_contratante_nom,
		   v_unidad,     
		   v_suma_aseg,	
		   v_desc_uni,
		   v_cedula_unidad,
		   v_cod_dependiente1,
		   v_nombre_dependiente1,
		   v_contratante
	  FROM tmp_tabla
  ORDER BY nombre, no_unidad
	
	RETURN v_unidad,
		   v_contratante_nom,
		   v_suma_aseg,		
		   v_desc_uni,
		   v_cedula_unidad,
		   v_cod_dependiente1,
		   v_nombre_dependiente1,
		   v_contratante
    	   WITH RESUME;
	
END FOREACH

DROP TABLE tmp_tabla;

END PROCEDURE;


