-- Procedimiento que Aviso de Pago Siniestro Coaseguro desde Reclamos
-- 
-- Creado    : 20/08/2012 - Autor: Armando Moreno
-- Modificado: 20/08/2012 - Autor: Armando Moreno
--
-- SIS v.2.0 - DEIVID, S.A.

DROP PROCEDURE sp_rec20a;
--DROP TABLE tmp_arreglo;
CREATE PROCEDURE "informix".sp_rec20a(a_compania CHAR(3), a_agencia CHAR(3), a_no_reclamo CHAR(10),a_firma CHAR(50), a_cargo CHAR(50)) 
			RETURNING   CHAR(50),
			            CHAR(50),
						CHAR(100),
		    	        CHAR(20),
						CHAR(50),
						DATE,
						DATE,
						CHAR(50),
						CHAR(50),
						DATE,
						CHAR(18),
						CHAR(50),
						DEC(16,2),
						DEC(9,6),
						DEC(16,2),
						CHAR(50),
						CHAR(10),
						CHAR(10),
						CHAR(50),
						CHAR(50);


DEFINE v_coaseguro        CHAR(50);
DEFINE v_contacto         CHAR(50);
DEFINE v_asegurado        CHAR(100);
DEFINE v_documento        CHAR(20);
DEFINE v_ramo             CHAR(50);
DEFINE v_vigen_ini        DATE;
DEFINE v_vigen_final      DATE;
DEFINE v_agente           CHAR(50);
DEFINE v_cobertura        CHAR(50);
DEFINE v_fecha_sinis      DATE;
DEFINE v_reclamo          CHAR(18);
DEFINE v_ajustador        CHAR(50);
DEFINE v_monto            DEC(16,2);
DEFINE v_porc_partic_coas DEC(9,6);
DEFINE v_participa        DEC(16,2);
DEFINE v_compania_nombre  CHAR(50);

DEFINE _cod_coasegur     CHAR(3);
DEFINE _cod_ramo         CHAR(3);
DEFINE _cod_tipotran     CHAR(3);
DEFINE _no_reclamo       CHAR(10);      
DEFINE _no_poliza        CHAR(10);
DEFINE _cod_cliente	     CHAR(10);
DEFINE _cod_agente       CHAR(5);
DEFINE _ajust_externo    CHAR(3);
DEFINE _cod_cobertura    CHAR(5);
DEFINE _cobertura_temp   CHAR(50);
DEFINE _agente_temp      CHAR(50);
SET ISOLATION TO DIRTY READ;


-- Nombre de la Compania

LET v_compania_nombre = sp_sis01(a_compania);

CREATE TEMP TABLE tmp_arreglo(
		cod_coasegur  CHAR(3)  NOT NULL,
		cod_ramo      CHAR(3)  NOT NULL,
		no_reclamo    CHAR(10) NOT NULL,  
		no_poliza     CHAR(10) NOT NULL,   
		cod_cliente   CHAR(10) NOT NULL,	
		no_tranrec    CHAR(10) ,
		vigen_ini     DATE,  
		vigen_final   DATE,
		fecha_sinis   DATE,
		reclamo       CHAR(18) NOT NULL,    
		monto         DEC(16,2),
		porc_parti    DEC(9,6),
		participa     DEC(16,2),
		documento     CHAR(20) NOT NULL
		) WITH NO LOG;   

FOREACH	

 -- Lectura de Participacion Coaseguro

 SELECT cod_coasegur,
        no_reclamo,
        porc_partic_coas
   INTO _cod_coasegur,
        _no_reclamo,
        v_porc_partic_coas
   FROM reccoas
  WHERE no_reclamo = a_no_reclamo
    AND TRIM(cod_coasegur) <> '036'
 
 -- Lectura del estimado de la cobertura
 
 SELECT sum(estimado)
   INTO v_monto
   FROM recrccob
  WHERE no_reclamo   = _no_reclamo;

   	-- Lectura de Reclamos

 	SELECT numrecla,
           no_poliza,
		   fecha_siniestro,
		   ajust_externo,
		   cod_asegurado
   	  INTO v_reclamo,
           _no_poliza,
		   v_fecha_sinis,
		   _ajust_externo,
    	   _cod_cliente
      FROM recrcmae
     WHERE no_reclamo  = _no_reclamo 
	   AND actualizado = 1;

	-- Lectura de Polizas

	SELECT no_documento,
	       vigencia_inic,
		   vigencia_final,
		   cod_ramo
	  INTO v_documento,
		   v_vigen_ini,  
	       v_vigen_final,
		   _cod_ramo
	  FROM emipomae
	 WHERE no_poliza = _no_poliza;

    
	IF v_reclamo IS NULL THEN
		LET v_reclamo = " ";
	END IF 
 	
	LET v_participa = (v_porc_partic_coas * v_monto) / 100;
 			   
	INSERT INTO tmp_arreglo(
	cod_coasegur, 
	cod_ramo,
	no_reclamo,   
	no_poliza,    
	cod_cliente,  
	no_tranrec,   
	vigen_ini,    
	vigen_final,  
	fecha_sinis,  
	reclamo,      
	monto, 
	porc_parti,     
	participa,    
	documento    
	)
	VALUES(
	_cod_coasegur,
	_cod_ramo,
	_no_reclamo,
	_no_poliza, 
	_cod_cliente,
	'',
	v_vigen_ini,  
	v_vigen_final,
	v_fecha_sinis,
	v_reclamo,
	v_monto,  
	v_porc_partic_coas,
	v_participa,
	v_documento
	);
END FOREACH;



--Recorre la tabla temporal y asigna valores a variables de salida
FOREACH WITH HOLD
 SELECT cod_coasegur,
 		cod_ramo,        
 		no_reclamo,     
 		no_poliza,   
 		cod_cliente, 
 		vigen_ini,   
 		vigen_final, 	
 		fecha_sinis,    
 		reclamo,       
		monto, 
		porc_parti,   
		participa,   
		documento    
   INTO _cod_coasegur,
		_cod_ramo,    
		_no_reclamo,
		_no_poliza, 
		_cod_cliente,
    	v_vigen_ini,    
    	v_vigen_final,
    	v_fecha_sinis,   
    	v_reclamo,  
    	v_monto,  
		v_porc_partic_coas,
    	v_participa,
    	v_documento
   FROM tmp_arreglo
  ORDER BY cod_coasegur

	-- Lectura de Cliente

	SELECT nombre
	  INTO v_asegurado
 	  FROM cliclien
	 WHERE cod_cliente = _cod_cliente;

	IF v_asegurado IS NULL THEN
		LET v_asegurado = " ";
	END IF 

    -- Lectura de Ajustador

	SELECT nombre
	  INTO v_ajustador
	  FROM recajust
	 WHERE cod_ajustador = _ajust_externo;

    -- Ramo
	SELECT 	nombre
  	  INTO 	v_ramo
  	  FROM 	prdramo
	 WHERE	cod_ramo = _cod_ramo;

    -- Facultativo
	SELECT nombre,
	       contacto
	  INTO v_coaseguro,
		   v_contacto
	  FROM emicoase
	 WHERE cod_coasegur = _cod_coasegur;


    -- Blanqueo

    LET v_cobertura = " ";
    LET v_agente = " ";


   	FOREACH WITH HOLD
    -- Lectura del Codigo de Agente

	    SELECT cod_agente
		  INTO _cod_agente
	  	  FROM emipoagt
		 WHERE no_poliza = _no_poliza

    -- Lectura de Agente

		SELECT nombre
		  INTO _agente_temp
		  FROM agtagent
		 WHERE cod_agente = _cod_agente;
 
		IF TRIM(v_agente) = "" THEN
    	   LET v_agente = TRIM(_agente_temp);
		ELSE
		   LET v_agente = TRIM(v_agente) || ", " || TRIM(_agente_temp);
		END IF

	END FOREACH


	-- Lectura de Cobertura

   	FOREACH WITH HOLD

    	SELECT cod_cobertura
		  INTO _cod_cobertura
		  FROM recrccob
		 WHERE no_reclamo = a_no_reclamo

		SELECT nombre
		  INTO _cobertura_temp
		  FROM prdcober
		 WHERE cod_cobertura = _cod_cobertura
		   AND cod_ramo      = _cod_ramo;

		IF TRIM(v_cobertura) = "" THEN
    	   LET v_cobertura = TRIM(_cobertura_temp);
		ELSE
		   LET v_cobertura = TRIM(v_cobertura) || ", " || TRIM(_cobertura_temp);
		END IF

	END FOREACH

	RETURN v_coaseguro,	
		   v_contacto,	
	 	   v_asegurado,   		
		   v_documento,  	
		   v_ramo,       	
		   v_vigen_ini,  	
		   v_vigen_final,	
		   v_agente,     	
		   v_cobertura,  	
		   v_fecha_sinis,	
		   v_reclamo,    	
		   v_ajustador,  	
		   v_monto,  	
		   v_porc_partic_coas,	  
		   v_participa,  	
		   v_compania_nombre,
		   _no_reclamo,
		   '',
		   a_firma,
		   a_cargo	
		   WITH RESUME;   	

END FOREACH



DROP TABLE tmp_arreglo;
END PROCEDURE