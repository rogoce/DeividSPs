-- Procedimiento que Finiquito Reclamante-- 
-- 
-- Creado    : 06/09/2000 - Autor: Amado Perez Mendoza 
-- Modificado: 06/09/2000 - Autor: Amado Perez Mendoza
--
-- SIS v.2.0 - DEIVID, S.A.

--DROP PROCEDURE sp_rec26PRU;
DROP PROCEDURE sp_rec26;
--DROP TABLE tmp_arreglo;
CREATE PROCEDURE "informix".sp_rec26(a_compania CHAR(3), a_agencia CHAR(3), a_tranrec CHAR(10)) 
			RETURNING   CHAR(18),
						VARCHAR(100),
						CHAR(30),
						DEC(16,2),
						CHAR(20),
						DATE,
						CHAR(50),
						VARCHAR(100);

DEFINE v_numrecla         CHAR(18);
DEFINE v_reclamante       VARCHAR(100);
DEFINE v_asegurado        VARCHAR(100);
DEFINE v_cedula           CHAR(30);
DEFINE v_monto			  DEC(16,2);
DEFINE v_no_documento     CHAR(20);
DEFINE v_fecha_sini       DATE;
DEFINE v_compania_nombre  CHAR(50);

DEFINE _no_reclamo       CHAR(10);      
DEFINE _no_tranrec       CHAR(10);
DEFINE _no_poliza        CHAR(10);
DEFINE _cod_cliente	     CHAR(10);
DEFINE _cod_contratante  CHAR(10);

-- Nombre de la Compania

SET ISOLATION TO DIRTY READ;

LET v_compania_nombre = sp_sis01(a_compania);

CREATE TEMP TABLE tmp_arreglo(
		no_poliza        CHAR(10) NOT NULL,
		numrecla         CHAR(18) NOT NULL,    
		no_documento     CHAR(20) NOT NULL,
		cod_cliente	     CHAR(10) NOT NULL,  
		fecha_siniestro  DATE     NOT NULL,
		monto            DEC(16,2) NOT NULL
		) WITH NO LOG;   

FOREACH	

 	-- Lectura de Transaccion
	 SELECT no_reclamo,
	        monto,
			cod_cliente
	   INTO _no_reclamo,
	        v_monto,
			_cod_cliente
	   FROM rectrmae
	  WHERE no_tranrec = a_tranrec
	    AND cod_tipopago = '004'

   	-- Lectura de Reclamos

 	SELECT no_poliza,
		   numrecla,
		   fecha_siniestro
   	  INTO _no_poliza,
	       v_numrecla,
		   v_fecha_sini
      FROM recrcmae
     WHERE no_reclamo = _no_reclamo
       AND cod_compania = a_compania
	   AND actualizado = 1;

	-- Lectura de Polizas

	SELECT no_documento,
	       cod_contratante
	  INTO v_no_documento,
	       _cod_contratante
	  FROM emipomae
	 WHERE no_poliza = _no_poliza;

 			   
	INSERT INTO tmp_arreglo(
	no_poliza,      
	numrecla,      
	no_documento,   
	cod_cliente,	   
	fecha_siniestro,
	monto   
	)
	VALUES(
	_no_poliza,
	v_numrecla, 
	v_no_documento, 
	_cod_cliente,	  
	v_fecha_sini,
	v_monto
	);
END FOREACH;



--Recorre la tabla temporal y asigna valores a variables de salida
FOREACH WITH HOLD
 SELECT no_poliza,     
        numrecla,      
		no_documento,  
 		cod_cliente,	
 		fecha_siniestro,
 		monto     
   INTO _no_poliza,
        v_numrecla, 
        v_no_documento,  
		_cod_cliente,	
		v_fecha_sini,
		v_monto    
   FROM tmp_arreglo

	-- Lectura de Cliente

	SELECT nombre,
	       cedula
	  INTO v_reclamante,
		   v_cedula	
 	  FROM cliclien
	 WHERE cod_cliente = _cod_cliente;

	IF v_reclamante IS NULL THEN
		LET v_reclamante = " ";
	END IF 

	SELECT nombre
	  INTO v_asegurado
 	  FROM cliclien
	 WHERE cod_cliente = _cod_contratante;

	RETURN v_numrecla,        
		   trim(v_reclamante),      
		   v_cedula,         
		   v_monto,			
		   v_no_documento,   
		   v_fecha_sini,     
		   trim(v_compania_nombre),
		   trim(v_asegurado)
		   WITH RESUME;   	

END FOREACH



DROP TABLE tmp_arreglo;
END PROCEDURE