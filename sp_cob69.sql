-- Informe de polizas que no se cobraron hasta una fecha dada
-- 
-- Creado    : 16/07/2001 - Autor: Armando Moreno
-- Modificado: 16/07/2001 - Autor: Armando Moreno
--

--DROP PROCEDURE sp_cob69;

CREATE PROCEDURE "informix".sp_cob69(a_compania CHAR(3), a_sucursal CHAR(3), a_fecha DATE, a_cobrador CHAR(255) DEFAULT "*")
			RETURNING 	CHAR(100),	
				  	  	CHAR(20),		
		    	  	  	DATE,     	
		    	  		DATE,     	
		    	  		DEC(16,2),	
		    	  		DEC(16,2),  	
				  		CHAR(100),		
		    	  		CHAR(50), 	
				  		CHAR(50),   	
						CHAR(30),
						CHAR(30),
						CHAR(100),
				  		CHAR(50),
		    	  		CHAR(50),
		    	  		DATE,
		    	  		INT,
		    	  		INT,
		    	  		CHAR(255); 	

DEFINE v_nombre_cliente  CHAR(100);
DEFINE v_doc_poliza      CHAR(20); 
DEFINE v_vigencia_inic,_fecha_cancelacion   DATE;     
DEFINE v_vigencia_final,_fecha  DATE; 
DEFINE v_saldo           DEC(16,2);
DEFINE v_a_pagar         DEC(16,2);
DEFINE v_direccion       CHAR(100);
DEFINE v_direccion1,v_direccion2 CHAR(50);
DEFINE v_telefono,v_telefono1,v_telefono2    CHAR(10);
DEFINE v_nombre_cobrador CHAR(50); 
DEFINE v_cobrador_calle,v_motivo CHAR(50); 
DEFINE v_compania_nombre CHAR(50); 
DEFINE v_ciudad          CHAR(30);
DEFINE v_distrito        CHAR(30);
DEFINE v_correg 		 CHAR(100);
DEFINE _tipo,_estatus_poliza  CHAR(1);
DEFINE _code_pais,_cod_motiv CHAR(3);
DEFINE _code_provincia   CHAR(2);
DEFINE _code_distrito    CHAR(2);
DEFINE _code_ciudad      CHAR(2);
DEFINE _code_correg      CHAR(5);
DEFINE _cod_cliente      CHAR(10);
DEFINE _cod_agente       CHAR(5);
DEFINE _no_poliza        CHAR(20);
DEFINE _cod_cobrador_o   CHAR(3);
DEFINE _cod_cobrador_c   CHAR(3);
DEFINE v_filtros		 CHAR(255);
DEFINE _estatus			 SMALLINT;	
DEFINE _dia_cobros1			 INTEGER;
DEFINE _dia_cobros2			 INTEGER;

CREATE TEMP TABLE tmp_rutero(
	no_poliza		CHAR(10),
	pais            CHAR(3),
	provincia       CHAR(2),
	distrito        CHAR(2),
	ciudad          CHAR(2),
	correg			CHAR(5),
	doc_poliza		CHAR(20),
	vigencia_inic 	DATE,
	vigencia_final  DATE,	  
	saldo			DEC(16,2),
	a_pagar			DEC(16,2),
	nombre_cliente 	CHAR(100),
	direccion       CHAR(100),
	motivo        	CHAR(50),
	cod_cobrador_c  CHAR(3),
	nombre_cobrador CHAR(50),
	cobrador_calle  CHAR(50),
	fecha			DATE,
	dia1			INTEGER,
	dia2			INTEGER,
	seleccionado   	SMALLINT  DEFAULT 1 NOT NULL
	--PRIMARY KEY (no_poliza)
	)WITH NO LOG;

-- Nombre de la Compania

LET  v_compania_nombre = sp_sis01(a_compania); 

FOREACH 

 SELECT cod_cobrador,
		saldo,
		a_pagar,
		no_poliza,
		code_pais,
		code_provincia,
		code_distrito,
		code_ciudad,
		cod_motiv,
		code_correg,
		direccion,
		fecha,
		dia_cobros1,
		dia_cobros2
   INTO _cod_cobrador_c,
        v_saldo,
		v_a_pagar,
		_no_poliza,
		_code_pais,
		_code_provincia,
		_code_distrito,
		_code_ciudad,
		_cod_motiv,
		_code_correg,
		v_direccion,
		_fecha,
		_dia_cobros1,
		_dia_cobros2
   FROM cobruter
  WHERE fecha <= a_fecha

 SELECT no_documento,
		vigencia_inic,
		vigencia_final,
		cod_contratante,
		fecha_cancelacion,
		estatus_poliza
   INTO v_doc_poliza,
		v_vigencia_inic,
		v_vigencia_final,
		_cod_cliente,
		_fecha_cancelacion,
		_estatus_poliza	
   FROM emipomae
  WHERE no_poliza = _no_poliza;
  
  SELECT nombre
    INTO v_nombre_cliente
	FROM cliclien
   WHERE cod_cliente = _cod_cliente;

 IF v_direccion IS NULL OR v_direccion = "" THEN
	  SELECT direccion_1,
			 direccion_2,
			 telefono1,
			 telefono2
	    INTO v_direccion1,
			 v_direccion2,
	         v_telefono1,
	         v_telefono2
		FROM emidirco
	   WHERE no_poliza = _no_poliza;

	   IF v_direccion1 IS NULL THEN
	   	LET v_direccion1 = " ";
	   END IF
	   IF v_direccion2 IS NULL THEN
	   	LET v_direccion2 = " ";
	   END IF
	   LET v_direccion = v_direccion1 || v_direccion2;
 END IF

  LET v_telefono  = v_telefono1  || "/" || v_telefono2;

   IF _cod_motiv IS NULL THEN
   	CONTINUE FOREACH;
   END IF

 SELECT nombre
    INTO v_cobrador_calle
    FROM cobcobra
   WHERE cod_cobrador = _cod_cobrador_c;

  SELECT nombre,
		 estatus
    INTO v_motivo,
		 _estatus
    FROM cobmotiv
   WHERE cod_motiv = _cod_motiv;

   IF _estatus = 0 THEN
   	CONTINUE FOREACH;
   END IF

  IF _estatus_poliza = 2 THEN --cancelada
  	LET v_vigencia_final = _fecha_cancelacion;
  END IF

  INSERT INTO tmp_rutero(
  no_poliza,
  doc_poliza,
  pais,    
  provincia,
  distrito, 
  ciudad,   
  correg,		
  vigencia_inic, 	
  vigencia_final, 
  nombre_cliente, 
  direccion,
  cod_cobrador_c, 
  motivo,
  cobrador_calle,
  saldo,
  a_pagar,
  fecha,
  dia1,
  dia2,
  seleccionado
  )
  VALUES(
  _no_poliza,
  v_doc_poliza,
  _code_pais,
  _code_provincia,
  _code_distrito,
  _code_ciudad,
  _code_correg,
  v_vigencia_inic,  
  v_vigencia_final,
  v_nombre_cliente,
  v_direccion,
  _cod_cobrador_c,
  v_motivo,
  v_cobrador_calle,
  v_saldo,
  v_a_pagar,
  _fecha,
  _dia_cobros1,
  _dia_cobros2,
  1
  ); 

 END FOREACH

LET v_filtros = "";

IF a_cobrador <> "*" THEN
	LET v_filtros = TRIM(v_filtros) || " Cobrador: " ||  TRIM(a_cobrador);

	LET _tipo = sp_sis04(a_cobrador);  -- Separa los Valores del String en una tabla de codigos

	IF _tipo <> "E" THEN -- Incluir los Registros

		UPDATE tmp_rutero
		   SET seleccionado = 0
		 WHERE seleccionado = 1
		   AND cod_cobrador_c NOT IN (SELECT codigo FROM tmp_codigos);
	ELSE		        -- Excluir estos Registros

		UPDATE tmp_rutero
		   SET seleccionado = 0
		 WHERE seleccionado = 1
		   AND cod_cobrador_c IN (SELECT codigo FROM tmp_codigos);
	END IF

	DROP TABLE tmp_codigos;
END IF

FOREACH WITH HOLD
  SELECT no_poliza,
		 doc_poliza,
		 pais,    
		 provincia,
		 distrito, 
		 ciudad,   
		 correg,	
		 vigencia_inic, 
		 vigencia_final,
		 nombre_cliente,
		 direccion,
		 motivo,
		 cod_cobrador_c,
		 cobrador_calle,
		 saldo,
		 a_pagar,
		 fecha,
		 dia1,
		 dia2
	INTO _no_poliza,
		 v_doc_poliza,
		 _code_pais,
		 _code_provincia,
		 _code_distrito,
		 _code_ciudad,
		 _code_correg,
		 v_vigencia_inic, 
		 v_vigencia_final,
		 v_nombre_cliente,
		 v_direccion,
		 v_motivo,
		 _cod_cobrador_c,
		 v_cobrador_calle,
		 v_saldo,
		 v_a_pagar,
		 _fecha,
		 _dia_cobros1,
		 _dia_cobros2
	FROM tmp_rutero
   WHERE seleccionado = 1
ORDER BY cod_cobrador_c, pais, provincia, distrito, ciudad, correg, fecha

 	FOREACH 
	 SELECT cod_agente
	   INTO	_cod_agente
	   FROM	emipoagt
	  WHERE	no_poliza = _no_poliza
		EXIT FOREACH;
	END FOREACH

	SELECT cod_cobrador
	  INTO _cod_cobrador_o
	  FROM agtagent
	 WHERE cod_agente = _cod_agente;
	  	   		   	
	SELECT nombre
	  INTO v_nombre_cobrador
	  FROM cobcobra
	 WHERE cod_cobrador = _cod_cobrador_o;

	SELECT nombre
	  INTO v_ciudad
	  FROM genciud
	 WHERE code_pais      = _code_pais
	   AND code_provincia = _code_provincia
	   AND code_ciudad    = _code_ciudad;

	SELECT nombre
	  INTO v_distrito
	  FROM gendtto
	 WHERE code_pais      = _code_pais
	   AND code_provincia = _code_provincia
	   AND code_ciudad    = _code_ciudad
	   AND code_distrito  = _code_distrito;

	SELECT nombre
	  INTO v_correg
	  FROM gencorr
	 WHERE code_pais      = _code_pais
	   AND code_provincia = _code_provincia
	   AND code_ciudad    = _code_ciudad
	   AND code_distrito  = _code_distrito
	   AND code_correg    = _code_correg;

	RETURN v_nombre_cliente,
		   v_doc_poliza,     
		   v_vigencia_inic,  
		   v_vigencia_final, 
		   v_saldo,          
		   v_a_pagar,        
		   v_direccion,      
		   v_nombre_cobrador,
		   v_cobrador_calle, 
		   v_ciudad,
		   v_distrito,
		   v_correg,
		   v_motivo,
		   v_compania_nombre,
		   _fecha,
		   _dia_cobros1,
		   _dia_cobros2,
		   v_filtros
		   WITH RESUME;	 		
END FOREACH

DROP TABLE tmp_rutero;

END PROCEDURE;
