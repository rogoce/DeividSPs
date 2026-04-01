-- Procedimiento de Cotizacion de Piezas
-- a una Fecha Dada
-- 
-- Creado    : 04/09/2000 - Autor: Amado Perez Mendoza 
-- Modificado: 04/09/2000 - Autor: Amado Perez Mendoza
--
-- SIS v.2.0 - DEIVID, S.A.

DROP PROCEDURE sp_rec22;
--DROP TABLE tmp_arreglo;
CREATE PROCEDURE "informix".sp_rec22(a_compania CHAR(3), a_agencia CHAR(3), a_no_cot_piezas CHAR(5)) 
			RETURNING   CHAR(100),
	   					CHAR(50),
						CHAR(100),
						CHAR(100),
						CHAR(18),
						CHAR(50),
						DATE,
						CHAR(50),
						CHAR(5),
						CHAR(50),
						CHAR(10),
						INT;


DEFINE v_proveedor        CHAR(100);
DEFINE v_marca		      CHAR(50);
DEFINE v_asegurado        CHAR(100);
DEFINE v_reclamante       CHAR(100);
DEFINE v_reclamo          CHAR(18);
DEFINE v_ajustador		  CHAR(50);
DEFINE v_fecha_cotiza	  DATE;
DEFINE v_compania_nombre  CHAR(50);
DEFINE v_placa            CHAR(10);
DEFINE v_ano_auto         INT;
DEFINE v_modelo           CHAR(50);

DEFINE _no_reclamo       CHAR(10);      
DEFINE _no_poliza        CHAR(10);
DEFINE _cod_cliente	     CHAR(10);
DEFINE _cod_reclamante	 CHAR(10);
DEFINE _cod_ajustador    CHAR(3);
DEFINE _no_motor         CHAR(30);
DEFINE _cod_proveedor    CHAR(10);
DEFINE _cod_marca        CHAR(5);
DEFINE _cod_modelo       CHAR(5);


-- Nombre de la Compania

LET v_compania_nombre = sp_sis01(a_compania);

CREATE TEMP TABLE tmp_arreglo(
		no_reclamo       CHAR(10),
		no_poliza        CHAR(10),    
		cod_cliente	     CHAR(10),  
		cod_reclamante	 CHAR(10),   
		cod_ajustador    CHAR(3),
		no_motor         CHAR(30),	
		reclamo       	 CHAR(18),
		cod_proveedor    CHAR(10),
		fecha_cotiza	 DATE   
		) WITH NO LOG;   

FOREACH	

 -- Lectura desde Proveedor

 SELECT cod_proveedor
   INTO _cod_proveedor
   FROM recpcota
  WHERE no_cot_piezas = a_no_cot_piezas
 
 
 SELECT cod_ajustador,
		no_reclamo,
		fecha_cot_pieza
   INTO _cod_ajustador,
		_no_reclamo,
		v_fecha_cotiza
   FROM recpcoma
  WHERE no_cot_piezas = a_no_cot_piezas;

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
       AND cod_compania = a_compania
	   AND actualizado = 1;

	-- Lectura de Polizas

	SELECT cod_contratante
	  INTO _cod_cliente
	  FROM emipomae
	 WHERE no_poliza = _no_poliza;

 			   
	INSERT INTO tmp_arreglo(
	no_reclamo,     
	no_poliza,      
	cod_cliente,	   
	cod_reclamante, 
	cod_ajustador,  
	no_motor,       
	reclamo,        
	cod_proveedor,  
	fecha_cotiza	 
	)
	VALUES(
	_no_reclamo,    
	_no_poliza,     
	_cod_cliente,	  
	_cod_reclamante,
	_cod_ajustador, 
	_no_motor,
	v_reclamo,      
	_cod_proveedor, 
	v_fecha_cotiza
	);
END FOREACH;



--Recorre la tabla temporal y asigna valores a variables de salida
FOREACH WITH HOLD
 SELECT no_reclamo,     
 		no_poliza,         
 		cod_cliente,	   
 		cod_reclamante,
 		cod_ajustador, 
 		no_motor,         
 		reclamo,       
 		cod_proveedor, 	
 		fecha_cotiza	   
   INTO _no_reclamo,    
		_no_poliza,     
		_cod_cliente,	
		_cod_reclamante,
		_cod_ajustador, 
    	_no_motor, 
    	v_reclamo,     
    	_cod_proveedor, 
    	v_fecha_cotiza
   FROM tmp_arreglo
  ORDER BY cod_proveedor

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

    SELECT cod_marca,
	       cod_modelo,
	       placa,
		   ano_auto
	  INTO _cod_marca,
	       _cod_modelo,
		   v_placa,
		   v_ano_auto
	  FROM emivehic
	 WHERE no_motor = _no_motor;

    SELECT nombre
	  INTO v_marca
	  FROM emimarca
	 WHERE cod_marca = _cod_marca;

   SELECT nombre 
     INTO v_modelo
	 FROM emimodel
	WHERE cod_marca = _cod_marca
	  AND cod_modelo = _cod_modelo;

	RETURN v_proveedor,      
		   v_marca,		    
	 	   v_asegurado,      
		   v_reclamante,     
		   v_reclamo,        
		   v_ajustador,		
		   v_fecha_cotiza,	
		   v_compania_nombre,
		   a_no_cot_piezas,
		   v_modelo,
		   v_placa,
		   v_ano_auto
		   WITH RESUME;   	

END FOREACH



DROP TABLE tmp_arreglo;
END PROCEDURE