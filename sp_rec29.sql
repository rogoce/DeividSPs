-- Procedimiento que extrae la Nota de Cesion Facultativa
-- 
-- Creado    : 07/09/2000 - Autor: Amado Perez Mendoza 
-- Modificado: 07/09/2000 - Autor: Amado Perez Mendoza
--
-- SIS v.2.0 - DEIVID, S.A.

DROP PROCEDURE sp_rec29;
--DROP TABLE tmp_arreglo;
CREATE PROCEDURE "informix".sp_rec29(a_compania CHAR(3), a_agencia CHAR(3), a_poliza CHAR(10), a_endoso CHAR(5)) 
			RETURNING   CHAR(50),
						CHAR(50),
						CHAR(50),
						CHAR(100),
						CHAR(20),
						DATE,
						DATE,
						DATE,
						CHAR(10),
						CHAR(5),
						CHAR(3),
						CHAR(255),
						CHAR(50);

DEFINE v_facultativo      CHAR(50);
DEFINE v_ramo		   	  CHAR(50);
DEFINE v_subramo	      CHAR(50);
DEFINE v_asegurado        CHAR(100);
DEFINE v_poliza           CHAR(20);
DEFINE v_vig_inic         DATE;
DEFINE v_vig_final        DATE;
DEFINE v_fech_fact		  DATE;
DEFINE v_factura          CHAR(10);
DEFINE v_endoso		      CHAR(5);
DEFINE v_cobertura	      CHAR(255);
DEFINE v_compania_nombre  CHAR(50);

DEFINE _no_poliza        CHAR(10);
DEFINE _cod_cliente	     CHAR(10);
DEFINE _cod_ramo         CHAR(3);
DEFINE _cod_subramo      CHAR(3);
DEFINE _cod_coasegur     CHAR(3);
DEFINE _cod_cobertura    CHAR(5);
DEFINE _cobertura_temp	 CHAR(50);

-- Nombre de la Compania

LET v_compania_nombre = sp_sis01(a_compania);

CREATE TEMP TABLE tmp_arreglo(
		cod_coasegur     CHAR(3)  NOT NULL,
		no_poliza        CHAR(10) NOT NULL,
		cod_cliente	     CHAR(10) NOT NULL,
		cod_ramo         CHAR(3)  NOT NULL,    
		cod_subramo      CHAR(3)  NOT NULL,  
		vig_inic         DATE     NOT NULL,
		vig_final        DATE     NOT NULL,
		fech_fact		 DATE     NOT NULL,
		endoso		     CHAR(5)  NOT NULL,
		documento        CHAR(20) NOT NULL,
		factura          CHAR(10) NOT NULL
		) WITH NO LOG;   

FOREACH
  
  SELECT no_poliza,
         vigencia_inic,
		 vigencia_final,
		 fecha_emision,
		 no_endoso,
		 no_factura
    INTO _no_poliza,
	     v_vig_inic,
		 v_vig_final,
		 v_fech_fact,
		 v_endoso,
		 v_factura
	FROM endedmae
   WHERE no_poliza = a_poliza
     AND no_endoso = a_endoso
	 AND cod_compania = a_compania
	 AND cod_sucursal = a_agencia
     AND cod_endomov IN (1,3,4,5,6,11,14)
   
  FOREACH	

  	SELECT cod_coasegur
   	  INTO _cod_coasegur	
  	  FROM emifafac 	
  	 WHERE no_poliza = _no_poliza
  	   AND no_endoso = v_endoso	
  GROUP BY no_poliza, no_endoso, cod_coasegur

	-- Lectura de Polizas

	SELECT cod_contratante,
		   cod_ramo,
		   cod_subramo,
		   no_documento
	  INTO _cod_cliente,
	       _cod_ramo,
		   _cod_subramo,
		   v_poliza
	  FROM emipomae
	 WHERE no_poliza = _no_poliza;

 			   
	INSERT INTO tmp_arreglo(
	cod_coasegur,
	no_poliza,   	
	cod_cliente,	
	cod_ramo,     
	cod_subramo,   
	vig_inic,    
	vig_final,   
	fech_fact,
	factura,	
	endoso,
	documento		
	)
	VALUES(
	_cod_coasegur, 
	_no_poliza,    
	_cod_cliente,	 
	_cod_ramo,     
	_cod_subramo,    
    v_vig_inic, 	
	v_vig_final,	
	v_fech_fact,
	v_factura,
	v_endoso,
	v_poliza		
	);
	END FOREACH;

END FOREACH;


--Recorre la tabla temporal y asigna valores a variables de salida
FOREACH WITH HOLD
 SELECT cod_coasegur,
 		no_poliza,   
        cod_cliente,	
 		cod_ramo,        
 		cod_subramo,    
 		vig_inic,       
 		vig_final,   
 		fech_fact,		
		factura,
 		endoso,
 		documento		  
   INTO _cod_coasegur,
   		_no_poliza,   
        _cod_cliente,	
		_cod_ramo,    
		_cod_subramo, 
    	v_vig_inic, 	
    	v_vig_final,	
    	v_fech_fact,
		v_factura,
		v_endoso,
		v_poliza		
   FROM tmp_arreglo
  ORDER BY cod_coasegur

    -- Lectura de Facultativo

	SELECT nombre
	  INTO v_facultativo
	  FROM emicoase
	 WHERE cod_coasegur = _cod_coasegur;  

	-- Lectura de Cliente

	SELECT nombre
	  INTO v_asegurado
 	  FROM cliclien
	 WHERE cod_cliente = _cod_cliente;

	IF v_asegurado IS NULL THEN
		LET v_asegurado = " ";
	END IF 

	-- Lectura Ramos y Subramo

	SELECT nombre
	  INTO v_ramo
	  FROM prdramo
	 WHERE cod_ramo = _cod_ramo;

    SELECT nombre 
	  INTO v_subramo
	  FROM prdsubra
	 WHERE cod_ramo = _cod_ramo
	   AND cod_subramo = _cod_subramo;

    LET v_cobertura = "";

	-- Lectura de Cobertura

   	FOREACH WITH HOLD

    	SELECT cod_cobertura
		  INTO _cod_cobertura
		  FROM endedcob
		 WHERE no_poliza = _no_poliza
		   AND no_endoso = v_endoso
      GROUP BY cod_cobertura

		SELECT nombre
		  INTO _cobertura_temp
		  FROM prdcober
		 WHERE cod_cobertura = _cod_cobertura
		   AND cod_ramo = _cod_ramo;

		IF TRIM(v_cobertura) = "" THEN
    	   LET v_cobertura = "COBERTURAS: " || TRIM(_cobertura_temp);
		ELSE
		   LET v_cobertura = TRIM(v_cobertura) || ", " || TRIM(_cobertura_temp);
		END IF

	END FOREACH

	RETURN v_facultativo,    
		   v_ramo,		   	
		   v_subramo,	    
		   v_asegurado,      
		   v_poliza,         
   		   v_vig_inic,       
		   v_vig_final,        
		   v_fech_fact,		    
		   v_factura,
	 	   v_endoso,	
	 	   _cod_coasegur,	      
		   v_cobertura,
		   v_compania_nombre 
		   WITH RESUME;   	

END FOREACH



DROP TABLE tmp_arreglo;
END PROCEDURE