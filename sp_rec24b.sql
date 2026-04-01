-- Procedimiento Finiquito de Taller cuando se emitan orden de reparacion-- 
-- 
-- Creado    : 18/07/2005 - Autor: Amado Perez Mendoza 
-- Modificado: 18/07/2005 - Autor: Amado Perez Mendoza
--
-- SIS v.2.0 - DEIVID, S.A.

--DROP PROCEDURE sp_rec24b;
--DROP TABLE tmp_arreglo;
CREATE PROCEDURE "informix".sp_rec24b(a_compania CHAR(3), a_agencia CHAR(3), a_tranrec CHAR(10)) 
			RETURNING   CHAR(18),
						CHAR(100),
						CHAR(30),
						DEC(16,2),
						CHAR(20),
						DATE,
						CHAR(50),
						CHAR(50),
						CHAR(50),
						CHAR(10),
						VARCHAR(100);

DEFINE v_numrecla         CHAR(18);
DEFINE v_asegurado        VARCHAR(100);
DEFINE v_cedula           CHAR(30);
DEFINE v_monto			  DEC(16,2);
DEFINE v_no_documento     CHAR(20);
DEFINE v_fecha_sini       DATE;
DEFINE v_compania_nombre  CHAR(50);
DEFINE v_marca		      CHAR(50);
DEFINE v_modelo           CHAR(50);
DEFINE v_placa            CHAR(10);
DEFINE v_taller			  VARCHAR(100);

DEFINE _acreedor 		 VARCHAR(100);
DEFINE _no_reclamo       CHAR(10);      
DEFINE _no_tranrec       CHAR(10);
DEFINE _no_poliza        CHAR(10);
DEFINE _cod_cliente	     CHAR(10);
DEFINE _cod_taller       CHAR(10);
DEFINE _wf_inc_auto, _wf_inc_padre      INTEGER;
DEFINE _tipo_reclamante  char(1);
DEFINE _cod_marca, _cod_modelo CHAR(5);
DEFINE _no_motor         CHAR(30);

-- Nombre de la Compania

LET v_compania_nombre = sp_sis01(a_compania);

CREATE TEMP TABLE tmp_arreglo(
		no_poliza        CHAR(10),
		no_reclamo       CHAR(10),
		numrecla         CHAR(18),    
		no_documento     CHAR(20),
		cod_cliente	     CHAR(10),  
		fecha_siniestro  DATE,
		monto            DEC(16,2),
		tipo_reclamante  CHAR(1),
		no_motor         CHAR(30),
		wf_inc_padre     INT,
		cod_taller		 CHAR(10)
		) WITH NO LOG;   

FOREACH	

 	-- Lectura de Transaccion
	 SELECT no_reclamo,
	        monto,
	        wf_inc_auto,
			wf_inc_padre,
			cod_cliente
	   INTO _no_reclamo,
	        v_monto,
	        _wf_inc_auto,
			_wf_inc_padre,
			_cod_taller
	   FROM rectrmae
	  WHERE no_tranrec = a_tranrec
	    AND cod_tipopago = '002'

	FOREACH
		SELECT tipo_reclamante
		  INTO _tipo_reclamante
		  FROM wf_ordcomp
		 WHERE wf_incidente = _wf_inc_auto 

        EXIT FOREACH;
    END FOREACH

   	-- Lectura de Reclamos

 	SELECT no_poliza,
		   numrecla,
		   fecha_siniestro,
		   no_motor
   	  INTO _no_poliza,
	       v_numrecla,
		   v_fecha_sini,
		   _no_motor
      FROM recrcmae
     WHERE no_reclamo = _no_reclamo
       AND cod_compania = a_compania
	   AND actualizado = 1;

	-- Lectura de Polizas

	SELECT no_documento,
	       cod_contratante
	  INTO v_no_documento,
	       _cod_cliente
	  FROM emipomae
	 WHERE no_poliza = _no_poliza;

 			   
	INSERT INTO tmp_arreglo(
	no_poliza,    
	no_reclamo,  
	numrecla,      
	no_documento,   
	cod_cliente,	   
	fecha_siniestro,
	monto,
	tipo_reclamante,
	no_motor,
	wf_inc_padre,
	cod_taller          
	)
	VALUES(
	_no_poliza,
	_no_reclamo,
	v_numrecla, 
	v_no_documento, 
	_cod_cliente,	  
	v_fecha_sini,
	v_monto,
	_tipo_reclamante,
	_no_motor,
	_wf_inc_padre,
	_cod_taller
	);
END FOREACH;



--Recorre la tabla temporal y asigna valores a variables de salida
FOREACH WITH HOLD
 SELECT no_poliza,  
        no_reclamo,   
        numrecla,      
		no_documento,  
 		cod_cliente,	
 		fecha_siniestro,
 		monto,
 		tipo_reclamante,
 		no_motor,
 		wf_inc_padre,
 		cod_taller             
   INTO _no_poliza,
        _no_reclamo,
        v_numrecla, 
        v_no_documento,  
		_cod_cliente,	
		v_fecha_sini,
		v_monto,
		_tipo_reclamante,
		_no_motor,
		_wf_inc_padre,
		_cod_taller
   FROM tmp_arreglo

	-- Lectura de Cliente

	 IF _tipo_reclamante = "T" THEN
	 	SELECT cod_tercero,
			   cod_marca,
			   cod_modelo,
			   placa
	 	  INTO _cod_cliente,
			   _cod_marca,
			   _cod_modelo,
			   v_placa
	 	  FROM recterce
	 	 WHERE no_incidente = _wf_inc_padre;

	 ELSE
	    SELECT cod_marca,
		       cod_modelo,
			   placa
		  INTO _cod_marca,
		       _cod_modelo,
			   v_placa
		  FROM emivehic
		 WHERE no_motor = _no_motor;
	 END IF	   


	SELECT nombre,
	       cedula
	  INTO v_asegurado,
		   v_cedula	
 	  FROM cliclien
	 WHERE cod_cliente = _cod_cliente;


	IF v_asegurado IS NULL THEN
		LET v_asegurado = " ";
	END IF 

    -- Lectura Marca y Modelo

    SELECT nombre
	  INTO v_marca
	  FROM emimarca
	 WHERE cod_marca = _cod_marca;

    SELECT nombre
	  INTO v_modelo
	  FROM emimodel
	 WHERE cod_marca = _cod_marca
	   AND cod_modelo = _cod_modelo;

	SELECT nombre
	  INTO v_taller
 	  FROM cliclien
	 WHERE cod_cliente = _cod_taller;

	RETURN v_numrecla,        
		   v_asegurado,      
		   v_cedula,         
		   v_monto,			
		   v_no_documento,   
		   v_fecha_sini,     
		   v_compania_nombre,
		   v_marca,
		   v_modelo,
		   v_placa,
		   v_taller
		   WITH RESUME;   	

END FOREACH



DROP TABLE tmp_arreglo;
END PROCEDURE