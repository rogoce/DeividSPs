-- Informe diario para el Cobrador
-- 
-- Creado    : 26/09/2000 - Autor: Amado Perez 
-- Modificado: 26/09/2000 - Autor: Amado Perez
--
-- SIS v.2.0 - d_cobr_sp_cob24_dw1 - DEIVID, S.A.

DROP PROCEDURE sp_cob24;

CREATE PROCEDURE "informix".sp_cob24(a_compania CHAR(3), a_sucursal CHAR(3), a_dia INT) 
			RETURNING 	CHAR(100),	
				  	  	CHAR(20),		
		    	  	  	DATE,     	
		    	  		DATE,     	
		    	  		DEC(16,2),	
		    	  		DEC(16,2),  	
				  		CHAR(50),		
				  		CHAR(10),		
		    	  		CHAR(50), 	
				  		CHAR(50),   	
				  		INT,        	
						CHAR(30),
						CHAR(30),
						CHAR(100),
		    	  		CHAR(50); 	

DEFINE v_nombre_cliente  CHAR(100);
DEFINE v_doc_poliza      CHAR(20); 
DEFINE v_vigencia_inic   DATE;     
DEFINE v_vigencia_final  DATE; 
DEFINE _fecha_cancelacion  DATE; 
DEFINE v_saldo           DEC(16,2);
DEFINE v_a_pagar         DEC(16,2);
DEFINE v_direccion       CHAR(50);
DEFINE v_telefono        CHAR(10);
DEFINE v_nombre_cobrador CHAR(50); 
DEFINE v_cobrador_calle  CHAR(50); 
DEFINE v_compania_nombre CHAR(50); 
DEFINE v_ciudad          CHAR(30);
DEFINE v_distrito        CHAR(30);
DEFINE v_correg 		 CHAR(100);

DEFINE _code_pais        CHAR(3);
DEFINE _code_provincia   CHAR(2);
DEFINE _code_distrito    CHAR(2);
DEFINE _code_ciudad      CHAR(2);
DEFINE _code_correg      CHAR(5);
DEFINE _estatus_poliza   CHAR(1);
DEFINE _cod_cliente      CHAR(10);
DEFINE _cod_agente       CHAR(5);
DEFINE _no_poliza        CHAR(20);
DEFINE _cod_cobrador_o   CHAR(3);
DEFINE _cod_cobrador_c   CHAR(3);



CREATE TEMP TABLE tmp_rutero(
	no_poliza		CHAR(10),
	pais            CHAR(3),
	provincia       CHAR(2),
	distrito        CHAR(2),
	ciudad          CHAR(2),
	correg			CHAR(2),
	doc_poliza		CHAR(20),
	vigencia_inic 	DATE,
	vigencia_final  DATE,	  
	saldo			DEC(16,2),
	a_pagar			DEC(16,2),
	nombre_cliente 	CHAR(100),
	direccion       CHAR(50),
	telefono        CHAR(10),
	cod_cobrador_c  CHAR(3),
	nombre_cobrador CHAR(50),
	cobrador_calle  CHAR(50),
	PRIMARY KEY (no_poliza)
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
		code_correg
   INTO _cod_cobrador_c,
        v_saldo,
		v_a_pagar,
		_no_poliza,
		_code_pais,
		_code_provincia,
		_code_distrito,
		_code_ciudad,
		_code_correg
   FROM cobruter
  WHERE dia_cobros1 = a_dia
     OR dia_cobros2 = a_dia

 SELECT no_documento,
		vigencia_inic,
		vigencia_final,
		cod_contratante,
		fecha_cancelacion
   INTO v_doc_poliza,
		v_vigencia_inic,
		v_vigencia_final,
		_cod_cliente,
		_fecha_cancelacion
   FROM emipomae
  WHERE no_poliza = _no_poliza;
  
 {IF _estatus_poliza = 2 THEN --cancelada
	IF _fecha_cancelacion IS NOT NULL THEN
		LET v_vigencia_final = _fecha_cancelacion;
	END IF
 END IF}

  SELECT nombre,
		 direccion_1,
		 telefono1
    INTO v_nombre_cliente,
	     v_direccion,
		 v_telefono
	FROM cliclien
   WHERE cod_cliente = _cod_cliente;
   
  SELECT nombre
    INTO v_cobrador_calle
    FROM cobcobra
   WHERE cod_cobrador = _cod_cobrador_c;

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
  telefono,
  cod_cobrador_c, 
  cobrador_calle,
  saldo,
  a_pagar
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
  v_telefono,
  _cod_cobrador_c,
  v_cobrador_calle,
  v_saldo,
  v_a_pagar
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
		 telefono,
		 cod_cobrador_c,
		 cobrador_calle,
		 saldo,
		 a_pagar
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
		 v_telefono,
		 _cod_cobrador_c,
		 v_cobrador_calle,
		 v_saldo,
		 v_a_pagar
	FROM tmp_rutero
ORDER BY cod_cobrador_c, pais, provincia, distrito, ciudad, correg
    
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
	 WHERE code_pais = _code_pais
	   AND code_provincia = _code_provincia
	   AND code_ciudad = _code_ciudad;

	SELECT nombre
	  INTO v_distrito
	  FROM gendtto
	 WHERE code_pais = _code_pais
	   AND code_provincia = _code_provincia
	   AND code_ciudad = _code_ciudad
	   AND code_distrito = _code_distrito;

	SELECT nombre
	  INTO v_correg
	  FROM gencorr
	 WHERE code_pais = _code_pais
	   AND code_provincia = _code_provincia
	   AND code_ciudad = _code_ciudad
	   AND code_distrito = _code_distrito
	   AND code_correg = _code_correg;

	RETURN v_nombre_cliente,
		   v_doc_poliza,     
		   v_vigencia_inic,  
		   v_vigencia_final, 
		   v_saldo,          
		   v_a_pagar,        
		   v_direccion,      
		   v_telefono,       
		   v_nombre_cobrador,
		   v_cobrador_calle, 
		   a_dia,
		   v_ciudad,
		   v_distrito,
		   v_correg,
		   v_compania_nombre
		   WITH RESUME;	 		

END FOREACH

DROP TABLE tmp_rutero;


END PROCEDURE;
