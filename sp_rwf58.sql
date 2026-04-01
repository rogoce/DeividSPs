-- Creacion de la Transaccion Inicial de Reclamos
-- 
-- Creado    : 04/05/2004 - Autor: Demetrio Hurtado Almanza 
--
-- SIS v.2.0 - - DEIVID, S.A.

DROP PROCEDURE sp_rwf58;
CREATE PROCEDURE "informix".sp_rwf58(a_incidente int)
	RETURNING   CHAR(100),
				CHAR(50),
				CHAR(100),
				CHAR(100),
				CHAR(18),
				CHAR(50),
				DATE,
				CHAR(50),
				CHAR(10),
				CHAR(10),
				CHAR(10),
				VARCHAR(50),
				VARCHAR(30),
				SMALLINT,
				VARCHAR(50),
				CHAR(10),
				CHAR(10),
				VARCHAR(10);

DEFINE v_proveedor        CHAR(100);
DEFINE v_marca		      CHAR(50);
DEFINE v_asegurado        CHAR(100);
DEFINE v_reclamante       CHAR(100);
DEFINE v_reclamo          CHAR(18);
DEFINE v_ajustador		  CHAR(50);
DEFINE v_fecha_orden	  DATE;
DEFINE v_entregar_a       CHAR(50);
DEFINE v_transaccion	  CHAR(10);
DEFINE v_compania_nombre  CHAR(50);
DEFINE v_no_chasis		  VARCHAR(30);
DEFINE v_ano_auto		  SMALLINT;
DEFINE v_modelo			  VARCHAR(50);
DEFINE v_tipoauto         VARCHAR(50);
DEFINE v_no_orden         CHAR(10);
DEFINE v_placa            CHAR(10);
DEFINE _no_cotizacion     VARCHAR(10);

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
DEFINE _cod_tipoauto     CHAR(3);
DEFINE _wf_inc_auto, _wf_inc_padre INTEGER;
DEFINE _wf_proveedor	 CHAR(10);
DEFINE _tipo_reclamante  char(1);
DEFINE _cant_reclamante  SMALLINT;

--SET DEBUG FILE TO "sp_cwf3.trc"; 
--trACE ON;
SET ISOLATION TO DIRTY READ;

CREATE TEMP TABLE tmp_arreglo(
        no_orden         CHAR(10),
		no_reclamo       CHAR(10),
		no_tranrec       CHAR(10),
		no_poliza        CHAR(10),    
		cod_cliente	     CHAR(10),  
		cod_reclamante	 CHAR(10),   
		cod_ajustador    CHAR(3),
		no_motor         CHAR(30),	
		reclamo       	 CHAR(18),
		cod_proveedor    CHAR(10),
		fecha_orden		 DATE,
		entregar_a       CHAR(50),
		transaccion      CHAR(10),
		no_cotizacion    VARCHAR(10)    
		) WITH NO LOG;   

FOREACH
	SELECT no_tranrec
	  INTO _no_tranrec
	  FROM rectrmae
	 WHERE wf_incidente = a_incidente

	FOREACH
		 SELECT no_orden,
		        cod_ajustador,
				no_reclamo,
				fecha_orden,
				entregar_a,
				cod_proveedor,
				no_orden,
				no_tranrec,
				no_cotizacion
		   INTO v_no_orden,
		        _cod_ajustador,
				_no_reclamo,
				v_fecha_orden,
				v_entregar_a,
				_cod_proveedor,
				_no_orden,
				_no_tranrec,
				_no_cotizacion
		   FROM recordma
		  WHERE no_tranrec = _no_tranrec
		    AND actualizado = 1
			AND tipo_ord_comp = "C"
		 	
		   	-- Lectura de Reclamos

		 	SELECT numrecla,
		           no_poliza,
				   cod_reclamante,
				   no_motor
		   	  INTO v_reclamo,
		           _no_poliza,
				   _cod_reclamante,
				   _no_motor
		      FROM recrcmae
		     WHERE no_reclamo = _no_reclamo
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

		 			   
			INSERT INTO tmp_arreglo(
			no_orden,
			no_reclamo,     
			no_tranrec,   
			no_poliza,   
			cod_cliente,	   
			cod_reclamante, 
			cod_ajustador,  
			no_motor,       
			reclamo,        
			cod_proveedor,
			entregar_a,
			fecha_orden,
			transaccion,
			no_cotizacion	 
			)
			VALUES(
			v_no_orden,
			_no_reclamo,    
			_no_tranrec,   
			_no_poliza,  
			_cod_cliente,	  
			_cod_reclamante,
			_cod_ajustador, 
			_no_motor,
			v_reclamo,      
			_cod_proveedor, 
			v_entregar_a,
			v_fecha_orden,
			v_transaccion,
			_no_cotizacion
			);
	  END FOREACH
END FOREACH

--Recorre la tabla temporal y asigna valores a variables de salida
FOREACH WITH HOLD
 SELECT no_orden,
        no_reclamo,   
        no_tranrec,  
 		no_poliza,         
 		cod_cliente,	   
 		cod_reclamante,
 		cod_ajustador, 
 		no_motor,         
 		reclamo,       
 		cod_proveedor, 	
		entregar_a,
 		fecha_orden,
 		transaccion,
 		no_cotizacion	   
   INTO v_no_orden,
        _no_reclamo,    
        _no_tranrec,  
		_no_poliza,     
		_cod_cliente,	
		_cod_reclamante,
		_cod_ajustador, 
    	_no_motor, 
    	v_reclamo,     
    	_cod_proveedor, 
		v_entregar_a,
    	v_fecha_orden,
		v_transaccion,
		_no_cotizacion
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
		       ano_auto,
			   placa
	 	  INTO _cod_reclamante,
		       _no_motor,
			   _cod_marca,
			   _cod_modelo,
		       v_ano_auto,
			   v_placa
	 	  FROM recterce
	 	 WHERE no_incidente = _wf_inc_padre;

         LET v_no_chasis = "";
	 ELSE
	    SELECT cod_marca,
		       cod_modelo,
			   no_chasis,
			   ano_auto,
			   placa
		  INTO _cod_marca,
		       _cod_modelo,
			   v_no_chasis,
			   v_ano_auto,
			   v_placa
		  FROM emivehic
		 WHERE no_motor = _no_motor;
	 END IF	   

 	LET _wf_proveedor = "";

    IF v_entregar_a IS NULL OR v_entregar_a = "" THEN
		LET v_entregar_a = "";
    	FOREACH
			SELECT wf_proveedor
			  INTO _wf_proveedor
			  FROM wf_ordcomp
			 WHERE wf_incidente = _wf_inc_auto 
			   AND tipo_orden = "R"

            EXIT FOREACH;
	    END FOREACH

    	IF (_wf_proveedor IS NULL OR _wf_proveedor = "") AND v_entregar_a = "" THEN
			LET _wf_proveedor = "";
		ELSE
	        SELECT nombre
			  INTO v_entregar_a
			  FROM cliclien
			 WHERE cod_cliente = _wf_proveedor;
		END IF

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


    -- Lectura de Ajustador

	SELECT nombre
	  INTO v_ajustador
	  FROM recajust
	 WHERE cod_ajustador = _cod_ajustador;

    -- Lectura Marca

    SELECT nombre
	  INTO v_marca
	  FROM emimarca
	 WHERE cod_marca = _cod_marca;

    SELECT nombre,
	       cod_tipoauto
	  INTO v_modelo,
	       _cod_tipoauto
	  FROM emimodel
	 WHERE cod_marca = _cod_marca
	   AND cod_modelo = _cod_modelo;

    SELECT nombre
	  INTO v_tipoauto
	  FROM emitiaut
	 WHERE cod_tipoauto = _cod_tipoauto;

	RETURN v_proveedor,      
		   TRIM(v_marca),		    
	 	   v_asegurado,      
		   v_reclamante,     
		   v_reclamo,        
		   v_ajustador,		
		   v_fecha_orden,	
		   v_entregar_a,
		   v_transaccion,
		   _no_tranrec,
		   v_no_orden,
		   TRIM(v_modelo),
		   TRIM(v_no_chasis),
		   v_ano_auto,
		   TRIM(v_tipoauto),
		   _cod_proveedor,
		   v_placa,
		   TRIM(_no_cotizacion)
		   WITH RESUME;   	

END FOREACH



DROP TABLE tmp_arreglo;

end procedure