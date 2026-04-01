-- Informe diario de polizas que no se cobraron
-- 
-- Creado    : 26/09/2000 - Autor: Amado Perez 
-- Modificado: 09/03/2001 - Autor: Armando Moreno
--
-- SIS v.2.0 - d_cobr_sp_cob61_dw1 - DEIVID, S.A.

DROP PROCEDURE sp_cob61;

CREATE PROCEDURE "informix".sp_cob61(a_compania CHAR(3), a_sucursal CHAR(3), a_dia INT, a_cobrador CHAR(3)) 
			RETURNING 	CHAR(100),	
				  	  	CHAR(20),		
		    	  	  	DATE,     	
		    	  		DATE,     	
		    	  		DEC(16,2),	
		    	  		DEC(16,2),  	
				  		CHAR(100),		
		    	  		CHAR(50), 	
				  		CHAR(50),   	
				  		INT,        	
						CHAR(30),
						CHAR(30),
						CHAR(100),
				  		CHAR(50),
		    	  		CHAR(50); 	

DEFINE v_nombre_cliente  CHAR(100);
DEFINE v_doc_poliza      CHAR(20); 
DEFINE v_vigencia_inic,_fecha_cancelacion   DATE;     
DEFINE v_vigencia_final  DATE; 
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

DEFINE _code_pais,_cod_motiv CHAR(3);
DEFINE _code_provincia   CHAR(2);
DEFINE _code_distrito    CHAR(2);
DEFINE _code_ciudad      CHAR(2);
DEFINE _code_correg      CHAR(5);
DEFINE _cod_agente       CHAR(5);
DEFINE _cod_cliente      CHAR(10);
DEFINE _no_poliza        CHAR(20);
DEFINE _cod_cobrador_o   CHAR(3);
DEFINE _cod_cobrador_c   CHAR(3);
DEFINE _estatus_poliza   CHAR(1);
DEFINE _estatus			 SMALLINT;	


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
	cod_agente		CHAR(5)	
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
		cod_agente
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
		_cod_agente
   FROM cobruter
  WHERE cod_cobrador = a_cobrador
    AND (dia_cobros1 = a_dia
	 OR dia_cobros2  = a_dia)

 IF _no_poliza IS NOT NULL THEN
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
 ELSE
	  SELECT direccion_1,
			 direccion_2,
			 telefono1,
			 telefono2
	    INTO v_direccion1,
			 v_direccion2,
	         v_telefono1,
	         v_telefono2
		FROM agtagent
	   WHERE cod_agente = _cod_agente;

	   LET v_direccion  = v_direccion1 || v_direccion2;
	   LET v_telefono   = v_telefono1  || "/" || v_telefono2;
	   LET v_doc_poliza = NULL;
 END IF

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

 SELECT nombre
   INTO v_cobrador_calle
   FROM cobcobra
  WHERE cod_cobrador = _cod_cobrador_c;

  IF _cod_motiv IS NULL THEN
  	CONTINUE FOREACH;
  END IF

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
  cod_agente
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
  _cod_agente
  ); 

END FOREACH

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
		 cod_agente
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
		 _cod_agente
	FROM tmp_rutero
ORDER BY cod_cobrador_c, pais, provincia, distrito, ciudad, correg

 IF _no_poliza IS NOT NULL THEN
	FOREACH 
	 SELECT cod_agente
	   INTO	_cod_agente
	   FROM	emipoagt
	  WHERE	no_poliza = _no_poliza
		EXIT FOREACH;
	END FOREACH
 ELSE
   SELECT nombre
    INTO v_nombre_cliente
	FROM agtagent
   WHERE cod_agente = _cod_agente;
 END IF

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
		   a_dia,
		   v_ciudad,
		   v_distrito,
		   v_correg,
		   v_motivo,
		   v_compania_nombre
		   WITH RESUME;	 		
END FOREACH

DROP TABLE tmp_rutero;

END PROCEDURE;
