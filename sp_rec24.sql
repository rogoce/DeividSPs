-- Procedimiento que Finiquito Taller
-- a una Fecha Dada
-- 
-- Creado    : 05/09/2000 - Autor: Amado Perez Mendoza 
-- Modificado: 05/09/2000 - Autor: Amado Perez Mendoza
--
-- SIS v.2.0 - DEIVID, S.A.

DROP PROCEDURE sp_rec24;
--DROP TABLE tmp_arreglo;
CREATE PROCEDURE "informix".sp_rec24(a_compania CHAR(3), a_agencia CHAR(3), a_orden CHAR(10)) 
			RETURNING   CHAR(100),
						CHAR(100),
	   					CHAR(50),
						CHAR(30),
						CHAR(10),
						CHAR(20),
						DATE,
						CHAR(50),
						DEC(16,2),
						CHAR(50);


DEFINE v_asegurado        CHAR(100);
DEFINE v_proveedor        CHAR(100);
DEFINE v_marca		      CHAR(50);
DEFINE v_no_motor         CHAR(30);
DEFINE v_placa            CHAR(10);
DEFINE v_no_documento     CHAR(20);
DEFINE v_fecha_sini       DATE;
DEFINE v_lugar            CHAR(50);
DEFINE v_monto            DEC(16,2);
DEFINE v_compania_nombre  CHAR(50);

DEFINE _no_reclamo       CHAR(10);      
DEFINE _no_poliza        CHAR(10);
DEFINE _cod_lugar        CHAR(3);
DEFINE _cod_cliente	     CHAR(10);
DEFINE _cod_marca        CHAR(5);
DEFINE _cod_proveedor    CHAR(10);

-- Nombre de la Compania

LET v_compania_nombre = sp_sis01(a_compania);

CREATE TEMP TABLE tmp_arreglo(
		no_reclamo       CHAR(10) NOT NULL,
		cod_lugar        CHAR(3)  NOT NULL,
		no_poliza        CHAR(10) NOT NULL,    
		no_documento     CHAR(20) NOT NULL,
		cod_cliente	     CHAR(10) NOT NULL,  
		cod_proveedor    CHAR(10) NOT NULL,
		no_motor         CHAR(30) NOT NULL,	
		fecha_siniestro  DATE     NOT NULL,
		monto            DEC(16,2) NOT NULL
		) WITH NO LOG;   

FOREACH	

   -- Lectura de Orden

 SELECT	no_reclamo,
		cod_proveedor,
		monto
   INTO _no_reclamo,
		_cod_proveedor,
		v_monto
   FROM recordma
  WHERE no_orden = a_orden
    AND actualizado = 1

 	
   	-- Lectura de Reclamos

 	SELECT no_poliza,
		   cod_lugar,
		   no_motor,
		   fecha_siniestro
   	  INTO _no_poliza,
		   _cod_lugar,
		   v_no_motor,
		   v_fecha_sini
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
	no_reclamo,  
	cod_lugar,   
	cod_proveedor,
	no_poliza,  
	no_documento, 
	cod_cliente,	   
	no_motor,       
	fecha_siniestro,
	monto
	)
	VALUES(
	_no_reclamo,    
	_cod_lugar,
	_cod_proveedor,
	_no_poliza, 
	v_no_documento, 
	_cod_cliente,	  
	v_no_motor,
	v_fecha_sini,
	v_monto
	);
END FOREACH;



--Recorre la tabla temporal y asigna valores a variables de salida
FOREACH WITH HOLD
 SELECT no_reclamo,   
        cod_lugar,
		cod_proveedor,
 		no_poliza, 
 		no_documento,        
 		cod_cliente,	   
 		no_motor,         
		fecha_siniestro,
		monto
   INTO _no_reclamo,
        _cod_lugar,  
        _cod_proveedor,  
		_no_poliza, 
		v_no_documento,    
		_cod_cliente,	
    	v_no_motor, 
		v_fecha_sini,
		v_monto
   FROM tmp_arreglo

	-- Lectura de Cliente

	SELECT nombre
	  INTO v_asegurado
 	  FROM cliclien
	 WHERE cod_cliente = _cod_cliente;

	IF v_asegurado IS NULL THEN
		LET v_asegurado = " ";
	END IF 


	-- Lectura de Proveedor

	SELECT nombre
	  INTO v_proveedor
 	  FROM cliclien
	 WHERE cod_cliente = _cod_proveedor;


    -- Lectura Marca

    SELECT cod_marca,
	       placa
	  INTO _cod_marca,
	       v_placa
	  FROM emivehic
	 WHERE no_motor = v_no_motor;

    SELECT nombre
	  INTO v_marca
	  FROM emimarca
	 WHERE cod_marca = _cod_marca;

	-- Lectura de Lugar

	SELECT nombre
	  INTO v_lugar
	  FROM prdlugar
	 WHERE cod_lugar = _cod_lugar;


	RETURN v_asegurado,      
		   v_proveedor,      
		   v_marca,		    
		   v_no_motor,       
		   v_placa,          
		   v_no_documento,   
		   v_fecha_sini,     
		   v_lugar,          
		   v_monto,     
		   v_compania_nombre
		   WITH RESUME;   	

END FOREACH



DROP TABLE tmp_arreglo;
END PROCEDURE