-- Procedimiento que extrae el Informe de Siniestro
-- 
-- Creado    : 07/09/2000 - Autor: Amado Perez Mendoza 
-- Modificado: 04/09/2001 - Autor: Amado Perez Mendoza
--
-- SIS v.2.0 - DEIVID, S.A.

DROP PROCEDURE sp_rec30;
--DROP TABLE tmp_arreglo;
CREATE PROCEDURE "informix".sp_rec30(a_compania CHAR(3), a_agencia CHAR(3), a_reclamo CHAR(10)) 
			RETURNING   CHAR(18),
						CHAR(20),
						DATE,
						DATE,
						CHAR(10),
						CHAR(100),
						CHAR(50),
						CHAR(50),
						CHAR(10),
						CHAR(10),
						CHAR(30),
						CHAR(255),
						CHAR(255),
						CHAR(50),
						CHAR(5),
						CHAR(50),
						CHAR(100),
						DATE,
						CHAR(50),
						DEC(16,2),
						DEC(16,2),
						DEC(16,2),
						DEC(16,2),
						DEC(16,2),
						DEC(16,2),
						DEC(16,2),
						DEC(16,2),
						DEC(16,2),
						DEC(16,2),
						CHAR(50);

DEFINE v_reclamo	      CHAR(18);
DEFINE v_poliza           CHAR(20);
DEFINE v_vig_inic         DATE;
DEFINE v_vig_final        DATE;
DEFINE v_estatus          CHAR(10);
DEFINE v_asegurado        CHAR(100);
DEFINE v_direccion1	   	  CHAR(50);
DEFINE v_direccion2	      CHAR(50);
DEFINE v_telefono		  CHAR(10);
DEFINE v_fax              CHAR(10);
DEFINE v_cedula           CHAR(30);
DEFINE v_acreedor         CHAR(255);
DEFINE v_agente           CHAR(255);
DEFINE v_ajustador        CHAR(50);
DEFINE v_unidad           CHAR(5);
DEFINE v_descuni		  CHAR(50);
DEFINE v_lug_repara		  CHAR(100);
DEFINE v_fech_sini        DATE;
DEFINE v_lug_sini         CHAR(50);
DEFINE v_incurr_bruto_p	  DEC(16,2);
DEFINE v_incurr_bruto_u	  DEC(16,2);
DEFINE v_sinies_p		  DEC(16,2);
DEFINE v_sinies_u		  DEC(16,2);
DEFINE v_saldo     		  DEC(16,2);
DEFINE v_por_vencer		  DEC(16,2);
DEFINE v_corriente 		  DEC(16,2);
DEFINE v_monto_30  		  DEC(16,2);
DEFINE v_monto_60  		  DEC(16,2);
DEFINE v_monto_90  		  DEC(16,2);
DEFINE v_compania_nombre  CHAR(50);

DEFINE _no_poliza        CHAR(10);
DEFINE _cod_cliente	     CHAR(10);
DEFINE _ajust_interno    CHAR(3);
DEFINE _cod_lugar        CHAR(3);
DEFINE _estatus_reclamo  CHAR(1);
DEFINE _acreedor_temp	 CHAR(50);
DEFINE _agente_temp      CHAR(50);
DEFINE _cod_acreedor 	 CHAR(5);
DEFINE _cod_proveedor	 CHAR(10);
DEFINE _cod_agente       CHAR(5);
DEFINE _no_reclamo_temp  CHAR(10);
DEFINE _prima_suscri_p   DEC(16,2);
DEFINE _prima_suscri_u   DEC(16,2);
DEFINE _monto_total      DEC(16,2);
DEFINE _porc_partic_coas DEC(7,4);
DEFINE _periodo        	 CHAR(7);
DEFINE _prima_orig		 DEC(16,2);
DEFINE _exigible  		 DEC(16,2);
DEFINE _largo            INT;

-- Nombre de la Compania

SET ISOLATION TO DIRTY READ;

LET v_compania_nombre = sp_sis01(a_compania);
LET	v_incurr_bruto_p = 0;
LET	v_incurr_bruto_u = 0;

CREATE TEMP TABLE tmp_arreglo(
		no_poliza        CHAR(10),
		cod_cliente	     CHAR(10),
		ajust_interno    CHAR(3),
		cod_lugar        CHAR(3),    
		reclamo          CHAR(18),
		documento        CHAR(20),
		estatus          CHAR(1),
		fecha_sini       DATE,
		unidad           CHAR(5),
		vig_inic 		 DATE,
		vig_final        DATE
		) WITH NO LOG;   

FOREACH
  
  	SELECT numrecla,
		   no_poliza,
		   ajust_interno,
		   no_unidad,
		   cod_lugar,
		   fecha_siniestro,
		   estatus_reclamo,
		   periodo
   	  INTO v_reclamo,
	       _no_poliza,
		   _ajust_interno,
		   v_unidad,
		   _cod_lugar,
		   v_fech_sini,
		   _estatus_reclamo,
		   _periodo
  	  FROM recrcmae 	
  	 WHERE no_reclamo = a_reclamo
  --	   AND estatus_reclamo = 'A'	

	-- Lectura de Polizas

	SELECT cod_contratante,
		   no_documento,
		   vigencia_inic,
		   vigencia_final,
		   prima_suscrita
	  INTO _cod_cliente,
		   v_poliza,
		   v_vig_inic, 
		   v_vig_final,
		   _prima_suscri_p
	  FROM emipomae
	 WHERE no_poliza = _no_poliza;

 			   
	INSERT INTO tmp_arreglo(
	no_poliza,      
	cod_cliente,	   	
	ajust_interno,  
	cod_lugar,       
	reclamo,        
	documento,      
	estatus,        
	fecha_sini,     
	unidad,
	vig_inic, 
	vig_final
	)
	VALUES(
	_no_poliza,    
	_cod_cliente,	 
	_ajust_interno, 
	_cod_lugar,     
	v_reclamo,	
	v_poliza,
	_estatus_reclamo,
	v_fech_sini,
	v_unidad,
	v_vig_inic,
	v_vig_final
	);

END FOREACH;


--Recorre la tabla temporal y asigna valores a variables de salida
FOREACH WITH HOLD
 SELECT no_poliza,      
 		cod_cliente,	
        ajust_interno,  
 		cod_lugar,        
 		reclamo,         
 		documento,      
 		estatus,        
		fecha_sini,     
 		unidad,
 		vig_inic,
 		vig_final
   INTO _no_poliza,    
   		_cod_cliente,	 
        _ajust_interno, 
		_cod_lugar,     
    	v_reclamo,	
    	v_poliza,
    	_estatus_reclamo,
		v_fech_sini,
		v_unidad,
		v_vig_inic, 
		v_vig_final
   FROM tmp_arreglo


	-- Lectura de Cliente

	SELECT nombre,
	       direccion_1,
		   direccion_2,
		   telefono1,
		   fax,
		   cedula
	  INTO v_asegurado,
		   v_direccion1,
		   v_direccion2,
		   v_telefono,	
		   v_fax,       
		   v_cedula    
 	  FROM cliclien
	 WHERE cod_cliente = _cod_cliente;

	IF v_asegurado IS NULL THEN
		LET v_asegurado = " ";
	END IF 

    -- Lectura de Ajustador

	SELECT nombre
	  INTO v_ajustador
	  FROM recajust
	 WHERE cod_ajustador = _ajust_interno;

    -- Blanqueo

    LET v_agente = " ";
	LET v_acreedor = " ";

	LET _largo = 0;

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
		   LET _largo = LENGTH(_agente_temp);
		   IF _largo >= 255 THEN
		   	EXIT FOREACH;
		   END IF
    	   LET v_agente = TRIM(_agente_temp);
		ELSE
		   LET _largo = LENGTH(TRIM(v_agente) || ", " || TRIM(_agente_temp));
		   IF _largo >= 255 THEN
		   	EXIT FOREACH;
		   END IF
		   LET v_agente = TRIM(v_agente) || ", " || TRIM(_agente_temp);
		END IF

	END FOREACH

	LET _largo = 0;

	FOREACH WITH HOLD

	-- Lectura de Acreedor
	   
		SELECT cod_acreedor
		  INTO _cod_acreedor
		  FROM emipoacr
		 WHERE no_poliza = _no_poliza
		   AND no_unidad = v_unidad

		SELECT nombre
		  INTO _acreedor_temp
		  FROM emiacre
		 WHERE cod_acreedor = _cod_acreedor;      

		IF TRIM(v_acreedor) = "" THEN
		   LET _largo = LENGTH(_acreedor_temp);
		   IF _largo > 255 THEN
		   	EXIT FOREACH;
		   END IF
    	   LET v_acreedor = TRIM(_agente_temp);
		ELSE
		   LET _largo = LENGTH(TRIM(v_acreedor) || ", " || TRIM(_acreedor_temp));
		   IF _largo > 255 THEN
		   	EXIT FOREACH;
		   END IF
		   LET v_acreedor = TRIM(v_acreedor) || ", " || TRIM(_acreedor_temp);
		END IF

	END FOREACH

    IF _estatus_reclamo = 'A' THEN
	  LET v_estatus = "ABIERTO";
	ELIF _estatus_reclamo = 'C' THEN
	  LET v_estatus = "CERRADO";
	ELIF _estatus_reclamo = 'R' THEN
	  LET v_estatus = "RE-ABIERTO";
	ELIF _estatus_reclamo = 'T' THEN
	  LET v_estatus = "EN TRAMITE";
	ELIF _estatus_reclamo = 'D' THEN
	  LET v_estatus = "DECLINADO";
	ELSE
	  LET v_estatus = "NO APLICA";
	END IF
    
    -- Lectura de unidad
    
    SELECT desc_unidad
      INTO v_descuni
	  FROM emipouni
	 WHERE no_unidad = v_unidad
	   AND no_poliza = _no_poliza;

    -- Lectura de lugar del accidente
    
    SELECT nombre 
      INTO v_lug_sini
      FROM prdlugar
     WHERE cod_lugar = _cod_lugar;      	
     
    -- Lectura de lugar de Reparacion
    
    SELECT cod_proveedor
      INTO _cod_proveedor
      FROM recordma
     WHERE no_reclamo = a_reclamo
       AND tipo_ord_comp = "R";

    SELECT nombre
	  INTO v_lug_repara
	  FROM cliclien
	 WHERE cod_cliente = _cod_proveedor;

    -- Calculo de Siniestralidad Poliza
	 
	FOREACH

	 SELECT no_reclamo
	   INTO _no_reclamo_temp
	   FROM recrcmae
	  WHERE no_poliza = _no_poliza

	 SELECT SUM(monto)
	   INTO _monto_total
	   FROM rectrmae
	  WHERE cod_compania = a_compania
	    AND actualizado  = 1
	    AND cod_tipotran IN (4,5,6,7)
	    AND no_reclamo = _no_reclamo_temp
	  GROUP BY no_reclamo
	 HAVING SUM(monto) <> 0;

	 SELECT porc_partic_coas
	   INTO _porc_partic_coas
	   FROM reccoas
	  WHERE no_reclamo = _no_reclamo_temp
	    AND cod_coasegur = '36';

	 LET v_incurr_bruto_p = v_incurr_bruto_p + (_monto_total * _porc_partic_coas / 100);
	
	END FOREACH
    
    -- Calculo de Siniestralidad Unidad

	SELECT prima_suscrita
	  INTO _prima_suscri_u
	  FROM emipouni
	 WHERE no_poliza = _no_poliza
	   AND no_unidad = v_unidad;
	 
	FOREACH

	 SELECT no_reclamo
	   INTO _no_reclamo_temp
	   FROM recrcmae
	  WHERE no_poliza = _no_poliza
	    AND no_unidad =	v_unidad

	 SELECT SUM(monto)
	   INTO _monto_total
	   FROM rectrmae
	  WHERE cod_compania = a_compania
	    AND actualizado  = 1
	    AND cod_tipotran IN (4,5,6,7)
	    AND no_reclamo = _no_reclamo_temp
	  GROUP BY no_reclamo
	 HAVING SUM(monto) <> 0;

	 SELECT porc_partic_coas
	   INTO _porc_partic_coas
	   FROM reccoas
	  WHERE no_reclamo = _no_reclamo_temp
	    AND cod_coasegur = '36';

	 LET v_incurr_bruto_u = v_incurr_bruto_u + (_monto_total * _porc_partic_coas / 100);
	
	END FOREACH
          
	LET v_sinies_p =  v_incurr_bruto_p / _prima_suscri_p;
	LET v_sinies_u =  v_incurr_bruto_u / _prima_suscri_u;

	CALL sp_cob01(
	_no_poliza,
	_periodo,
	today
	) RETURNING _prima_orig,
			    v_saldo,     
			    v_por_vencer,
			    _exigible,  
			    v_corriente, 
			    v_monto_30,  
			    v_monto_60,  
			    v_monto_90;  

	RETURN v_reclamo,	    
		   v_poliza,        
		   v_vig_inic,       
		   v_vig_final,      
		   v_estatus,        
		   v_asegurado,      
		   v_direccion1,	   	
		   v_direccion2,	    
		   v_telefono,		
		   v_fax,            
		   v_cedula,         
		   v_acreedor,       
		   v_agente,         
   		   v_ajustador,      
		   v_unidad,          
		   v_descuni,		  
		   v_lug_repara,		
	 	   v_fech_sini,      
		   v_lug_sini,
		   v_incurr_bruto_p,
		   v_incurr_bruto_u,
		   v_sinies_p,
		   v_sinies_u,  
		   v_saldo,     
		   v_por_vencer,
		   v_corriente, 
		   v_monto_30,  
		   v_monto_60,  
		   v_monto_90,  
		   v_compania_nombre
		   WITH RESUME;   	

END FOREACH



DROP TABLE tmp_arreglo;
END PROCEDURE












     