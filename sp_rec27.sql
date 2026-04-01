-- Procedimiento Orden de Reparacion
-- a una Fecha Dada
-- 
-- Creado    : 07/09/2000 - Autor: Amado Perez Mendoza 
-- Modificado: 07/09/2000 - Autor: Amado Perez Mendoza
--
-- SIS v.2.0 - DEIVID, S.A.

DROP PROCEDURE sp_rec27;
--DROP TABLE tmp_arreglo;
CREATE PROCEDURE "informix".sp_rec27(a_compania CHAR(3), a_agencia CHAR(3), a_orden CHAR(10)) 
			RETURNING   VARCHAR(100),
						VARCHAR(100),
	   					VARCHAR(50),
						VARCHAR(50),
						CHAR(10),
						CHAR(18),
						CHAR(10),
						CHAR(100),
						CHAR(5),
						DATE,
						DEC(16,2),
						DEC(16,2),
						INT,
						CHAR(10),
						CHAR(10),
						VARCHAR(50);


DEFINE v_asegurado        CHAR(100);
DEFINE v_reclamante       CHAR(100);
DEFINE v_marca		      CHAR(50);
DEFINE v_modelo           CHAR(50);
DEFINE v_placa            CHAR(10);
DEFINE v_reclamo          CHAR(18);
DEFINE v_transaccion	  CHAR(10);
DEFINE v_proveedor        CHAR(100);
DEFINE v_presupuesto      CHAR(5);
DEFINE v_fech_cot         DATE;
DEFINE v_monto            DEC(16,2);
DEFINE v_deducible        DEC(16,2);
DEFINE v_dias_entrega     INT;
DEFINE v_compania_nombre  CHAR(50);

DEFINE _no_reclamo       CHAR(10);      
DEFINE _no_poliza        CHAR(10);
DEFINE _no_tranrec       CHAR(10);
DEFINE _cod_cliente	     CHAR(10);
DEFINE _cod_reclamante	 CHAR(10);
DEFINE _cod_ajustador    CHAR(3);
DEFINE _no_motor         CHAR(30);
DEFINE _cod_proveedor    CHAR(10);
DEFINE _cod_marca        CHAR(5);
DEFINE _cod_modelo       CHAR(5);
DEFINE _no_orden		 CHAR(5);
DEFINE _fecha_sal_taller DATE;
DEFINE _deducible        DEC(16,2);
DEFINE _no_cotizacion    CHAR(5);
DEFINE _wf_inc_auto, _wf_inc_padre   INTEGER;
DEFINE _tipo_reclamante  char(1);
DEFINE _cant_reclamante  SMALLINT;

--SET DEBUG FILE TO "sp_rec27.trc";
--TRACE ON;


-- Nombre de la Compania
SET ISOLATION TO DIRTY READ;

LET v_compania_nombre = sp_sis01(a_compania);

CREATE TEMP TABLE tmp_arreglo(
        no_cotizacion    CHAR(5),
		no_reclamo       CHAR(10)  NOT NULL,
		no_tranrec       CHAR(10)  NOT NULL,
		no_poliza        CHAR(10)  NOT NULL,    
		cod_cliente	     CHAR(10)  NOT NULL,  
		cod_reclamante	 CHAR(10)  NOT NULL,   
		cod_ajustador    CHAR(3)   NOT NULL,
		no_motor         CHAR(30)  NOT NULL,	
		reclamo       	 CHAR(18)  NOT NULL,
		cod_proveedor    CHAR(10)  NOT NULL,
		transaccion      CHAR(10)  NOT NULL,
		monto            DEC(16,2) NOT NULL,
		deducible        DEC(16,2),
		fech_sal_ta      DATE    
		) WITH NO LOG;   

FOREACH	


   -- Lectura de Orden

 SELECT cod_ajustador,
		no_reclamo,
        monto,
		cod_proveedor,
		no_orden,
		no_cotizacion,
		fecha_sal_taller,
		no_tranrec,
		deducible
   INTO _cod_ajustador,
		_no_reclamo,
        v_monto,
		_cod_proveedor,
		_no_orden,
		_no_cotizacion,
		_fecha_sal_taller,
		_no_tranrec,
		_deducible
   FROM recordma
  WHERE no_orden = a_orden
    AND actualizado = 1
	AND tipo_ord_comp = "R"

 {SELECT no_tranrec
   INTO _no_tranrec
   FROM recordam
  WHERE no_orden = _no_orden
    AND actualizado = 1;}
 	
   	-- Lectura de Reclamos

 	SELECT no_tramite, --> # de tramite en vez de numrecla Sabish 17/02/2011
           no_poliza,
		   cod_reclamante,
		   no_motor
   	  INTO v_reclamo,
           _no_poliza,
		   _cod_reclamante,
		   _no_motor
      FROM recrcmae
     WHERE no_reclamo = _no_reclamo
       AND cod_compania = a_compania
	   AND actualizado = 1;

	-- Lectura de trancciones

	SELECT transaccion,
	       wf_inc_auto,
		   wf_inc_padre
	  INTO v_transaccion,
	       _wf_inc_auto,
		   _wf_inc_padre
	  FROM rectrmae
	 WHERE no_tranrec = _no_tranrec;

	-- Lectura de Polizas

	SELECT cod_contratante
	  INTO _cod_cliente
	  FROM emipomae
	 WHERE no_poliza = _no_poliza;

	IF v_transaccion IS NULL THEN
		LET v_transaccion = "";
	END IF
 			   
	INSERT INTO tmp_arreglo(
	no_reclamo,     
	no_tranrec,   
	no_poliza,   
	cod_cliente,	   
	cod_reclamante, 
	cod_ajustador,  
	no_motor,       
	reclamo,        
	cod_proveedor,
	transaccion,
	monto,
	no_cotizacion,
	fech_sal_ta,
	deducible	 
	)
	VALUES(
	_no_reclamo,    
	_no_tranrec,   
	_no_poliza,  
	_cod_cliente,	  
	_cod_reclamante,
	_cod_ajustador, 
	_no_motor,
	v_reclamo,      
	_cod_proveedor, 
	v_transaccion,
	v_monto,
	_no_cotizacion,
	_fecha_sal_taller,
	_deducible	 
	);
END FOREACH;



--Recorre la tabla temporal y asigna valores a variables de salida
FOREACH WITH HOLD
 SELECT no_reclamo,   
        no_tranrec,  
 		no_poliza,         
 		cod_cliente,	   
 		cod_reclamante,
 		no_motor,         
 		reclamo,       
 		cod_proveedor, 	
 		transaccion,	   
		monto,
		no_cotizacion,
    	fech_sal_ta,
    	deducible	 
   INTO _no_reclamo,    
        _no_tranrec,  
		_no_poliza,     
		_cod_cliente,	
		_cod_reclamante,
    	_no_motor, 
    	v_reclamo,     
    	_cod_proveedor, 
		v_transaccion,
		v_monto,
		_no_cotizacion,
		_fecha_sal_taller,
		_deducible
   FROM tmp_arreglo
  ORDER BY cod_proveedor

	FOREACH
		SELECT tipo_reclamante
		  INTO _tipo_reclamante
		  FROM wf_ordcomp
		 WHERE wf_incidente = _wf_inc_auto 

        EXIT FOREACH;
    END FOREACH

    LET _cant_reclamante = 0;

    IF _tipo_reclamante IS NULL THEN
		FOREACH
			SELECT COUNT(*)
			  INTO _cant_reclamante
			  FROM recterce
			 WHERE no_incidente = _wf_inc_padre
		    
	    	IF _cant_reclamante = 0 THEN
			   LET _tipo_reclamante = "A";
			ELSE
			   LET _tipo_reclamante = "T";
			END IF
		END FOREACH
	 END IF 

	 IF _tipo_reclamante = "T" THEN
	 	SELECT cod_tercero,
		       no_motor,
			   cod_marca,
			   cod_modelo,
			   placa
	 	  INTO _cod_reclamante,
		       _no_motor,
			   _cod_marca,
			   _cod_modelo,
			   v_placa
	 	  FROM recterce
	 	 WHERE no_reclamo   = _no_reclamo
		   AND no_incidente = _wf_inc_padre;

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


	-- Lectura de Cliente

	SELECT nombre
	  INTO v_asegurado
 	  FROM cliclien
	 WHERE cod_cliente = _cod_cliente;

	IF v_asegurado IS NULL THEN
		LET v_asegurado = " ";
	END IF 

	-- Lectura de Reclamante

	SELECT nombre
	  INTO v_reclamante
 	  FROM cliclien
	 WHERE cod_cliente = _cod_reclamante;

	-- Lectura de Proveedor

	SELECT nombre
	  INTO v_proveedor
 	  FROM cliclien
	 WHERE cod_cliente = _cod_proveedor;

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

    SELECT fecha
	  INTO v_fech_cot
	  FROM rectrmae
	 WHERE no_tranrec = _no_tranrec;

    -- Lectura de Presupuesto

	SELECT no_cot_rep
	  INTO v_presupuesto
	  FROM recrcoma
	 WHERE no_cot_rep = _no_cotizacion;   

 	LET v_dias_entrega =  _fecha_sal_taller - today;

    LET v_deducible = 0;

 {   IF _deducible = 0.00 THEN

	    LET v_deducible = 0;
	    FOREACH WITH HOLD

		 SELECT deducible
		   INTO _deducible
		   FROM recrccob
		  WHERE no_reclamo = _no_reclamo    

		  LET v_deducible = v_deducible + _deducible;

		END FOREACH
	 ELSE}
	    LET v_deducible = _deducible;
--	 END IF

	RETURN TRIM(v_asegurado),      
		   TRIM(v_reclamante),     
		   TRIM(v_marca),		       
	 	   TRIM(v_modelo),         
		   v_placa,          
		   v_reclamo,        
		   v_transaccion,	
		   v_proveedor,      
		   v_presupuesto,    
		   v_fech_cot,       
		   v_monto,          
		   v_deducible,      
		   v_dias_entrega,  
		   _no_reclamo,
		   _no_tranrec, 
		   TRIM(v_compania_nombre)
		   WITH RESUME;   	

END FOREACH



DROP TABLE tmp_arreglo;
END PROCEDURE