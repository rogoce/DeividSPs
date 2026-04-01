-- Procedimiento que extrae el Informe de Siniestro
-- 
-- Creado    : 07/09/2000 - Autor: Amado Perez Mendoza 
-- Modificado: 04/09/2001 - Autor: Amado Perez Mendoza
-- Modificado: 20/04/2004 - Autor: Amado Perez Mendoza "Se agrega informacion sobre el automovil (Marca, Modelo, etc)"
-- Modificado: 10/08/2005 - Autor: Amado Perez Mendoza "Se busca la morosidad del documento no de no_poliza"
-- Modificado: 23/12/2014 - Autor: Jaime Chevalier "Se busca la version, suma asegurada, fecha de reclamo, evento"
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
						VARCHAR(50),
						CHAR(30),
						CHAR(50),
						CHAR(50),
						CHAR(10),
						SMALLINT,
						CHAR(100),
						DATE,
						DEC(16,2),
						CHAR(50),
						CHAR(10),
						CHAR(10);

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
DEFINE v_fech_reclamo     DATE;
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
DEFINE v_compania_nombre  VARCHAR(50);
DEFINE v_no_motor		  CHAR(30);
DEFINE v_nombre_marca	  CHAR(50);
DEFINE v_nombre_modelo	  CHAR(50);
DEFINE v_nombre_version	  CHAR(100);
DEFINE v_placa            CHAR(10);
DEFINE v_ano_auto         SMALLINT;
DEFINE v_suma_asegurada   DEC(16,2);
DEFINE v_evento_reclamo   CHAR(50);
DEFINE v_estatus_poliza   CHAR(10);

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
DEFINE _cod_ramo         CHAR(3);
DEFINE _no_reclamo_temp  CHAR(10);
DEFINE _prima_suscri_p   DEC(16,2);
DEFINE _prima_suscri_u   DEC(16,2);
DEFINE _monto_total      DEC(16,2);
DEFINE _porc_partic_coas DEC(7,4);
DEFINE _periodo        	 CHAR(7);
DEFINE _prima_orig		 DEC(16,2);
DEFINE _exigible  		 DEC(16,2);
DEFINE _largo            INT;
DEFINE _cod_marca		 CHAR(5);
DEFINE _cod_modelo		 CHAR(5);
DEFINE _cod_version		 CHAR(10);
DEFINE _cod_evento		 CHAR(3);
DEFINE _monto      		 DEC(16,2);
DEFINE _estatus_poliza   SMALLINT;


-- Nombre de la Compania

SET ISOLATION TO DIRTY READ;

LET v_compania_nombre = sp_sis01(a_compania);
LET	v_incurr_bruto_p = 0;
LET	v_incurr_bruto_u = 0;
LET	v_ano_auto       = 0;
let v_placa          = "";
let v_nombre_modelo  = "";
let v_nombre_marca   = "";
let v_nombre_version = "";
let v_no_motor       = "";
let _cod_proveedor = "";
let v_evento_reclamo = "";

CREATE TEMP TABLE tmp_arreglo(
		no_poliza        CHAR(10),
		cod_cliente	     CHAR(10),
		ajust_interno    CHAR(3),
		cod_lugar        CHAR(3),    
		reclamo          CHAR(18),
		documento        CHAR(20),
		estatus          CHAR(1),
		fecha_sini       DATE,
		fecha_reclamo    DATE,
		unidad           CHAR(5),
		vig_inic 		 DATE,
		vig_final        DATE,
		cod_ramo         CHAR(3),
		cod_evento       CHAR(3)
		) WITH NO LOG;   

FOREACH
  
  	SELECT numrecla,
		   no_poliza,
		   ajust_interno,
		   no_unidad,
		   cod_lugar,
		   fecha_siniestro,
		   fecha_reclamo,
		   estatus_reclamo,
		   periodo,
		   cod_evento
   	  INTO v_reclamo,
	       _no_poliza,
		   _ajust_interno,
		   v_unidad,
		   _cod_lugar,
		   v_fech_sini,
		   v_fech_reclamo,
		   _estatus_reclamo,
		   _periodo,
		   _cod_evento
  	  FROM recrcmae 	
  	 WHERE no_reclamo = a_reclamo
  --	   AND estatus_reclamo = 'A'	

	-- Lectura de Polizas

	SELECT cod_contratante,
		   no_documento,
		   vigencia_inic,
		   vigencia_final,
		   prima_suscrita,
		   suma_asegurada,
		   cod_ramo,
		   estatus_poliza
	  INTO _cod_cliente,
		   v_poliza,
		   v_vig_inic, 
		   v_vig_final,
		   _prima_suscri_p,
		   v_suma_asegurada,
		   _cod_ramo,
		   _estatus_poliza
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
    fecha_reclamo,	
	unidad,
	vig_inic, 
	vig_final,
	cod_ramo,
	cod_evento
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
	v_fech_reclamo,
	v_unidad,
	v_vig_inic,
	v_vig_final,
	_cod_ramo,
	_cod_evento
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
		fecha_reclamo,		
 		unidad,
 		vig_inic,
 		vig_final,
		cod_evento
   INTO _no_poliza,    
   		_cod_cliente,	 
        _ajust_interno, 
		_cod_lugar,     
    	v_reclamo,	
    	v_poliza,
    	_estatus_reclamo,
		v_fech_sini,
		v_fech_reclamo,
		v_unidad,
		v_vig_inic, 
		v_vig_final,
		_cod_evento
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
		LET v_asegurado = "";
	END IF 
	
    -- Lectura de Ajustador

	SELECT nombre
	  INTO v_ajustador
	  FROM recajust
	 WHERE cod_ajustador = _ajust_interno;

    -- Blanqueo

    LET v_agente = "";
	LET v_acreedor = "";

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
    	   LET v_acreedor = TRIM(_acreedor_temp);
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
	
	IF _estatus_poliza = '1' THEN
	  LET v_estatus_poliza = "VIGENTE";
	ELIF _estatus_reclamo = '2' THEN
	  LET v_estatus_poliza = "CANCELADA";
	ELIF _estatus_reclamo = '3' THEN
	ELSE
	  LET v_estatus_poliza = "VENCIDA";
	END IF
    
    -- Lectura de unidad
    
    SELECT desc_unidad
      INTO v_descuni
	  FROM emipouni
	 WHERE no_poliza = _no_poliza
	   and no_unidad = v_unidad;

    -- Lectura del Automovil

	if _cod_ramo in("002","020", "023") then

		select no_motor
		  into v_no_motor
		  from emiauto
		 where no_poliza = _no_poliza
		   and no_unidad = v_unidad;

		if v_no_motor is null then

			foreach
			 select no_motor
			   into v_no_motor
			   from endmoaut
		      where no_poliza = _no_poliza
		        and no_unidad = v_unidad
				exit foreach;
			end foreach

		end if

		if v_no_motor is not null then

			select cod_marca,
			       cod_modelo,
				   placa,
				   ano_auto,
				   cod_version
			  into _cod_marca,
			       _cod_modelo,
				   v_placa,
				   v_ano_auto,
				   _cod_version
			  from emivehic
			 where no_motor = v_no_motor;
			 
			 select nombre
			   into v_nombre_marca
			   from emimarca
			  where cod_marca = _cod_marca;

			 select nombre
			   into v_nombre_modelo
			   from emimodel
			  where cod_modelo = _cod_modelo;
			  
			 select nombre 
			   into v_nombre_version
			   from emimodelver
			  where cod_version = _cod_version;

		end if
	
	end if

    -- Lectura de lugar del accidente
    
    SELECT nombre 
      INTO v_lug_sini
      FROM prdlugar
     WHERE cod_lugar = _cod_lugar;      

    -- JAC Busca el nombre del evento
	SELECT nombre 
	  INTO v_evento_reclamo
	  FROM recevent  
	 WHERE cod_evento = _cod_evento;	 
     
    -- Lectura de lugar de Reparacion
    
	foreach
	    SELECT cod_proveedor
	      INTO _cod_proveedor
	      FROM recordma
	     WHERE no_reclamo = a_reclamo
	       AND tipo_ord_comp = "R"
	end foreach

	if _cod_proveedor is not null and trim(_cod_proveedor) <> "" then
	    SELECT nombre
		  INTO v_lug_repara
		  FROM cliclien
		 WHERE cod_cliente = _cod_proveedor;
    else
		let v_lug_repara = "";
	end if


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
	    AND cod_coasegur = '036';

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
	    AND cod_coasegur = '036';

	 LET v_incurr_bruto_u = v_incurr_bruto_u + (_monto_total * _porc_partic_coas / 100);
	
	END FOREACH
          
	LET v_sinies_p =  v_incurr_bruto_p / _prima_suscri_p;
	LET v_sinies_u =  v_incurr_bruto_u / _prima_suscri_u;

	CALL sp_cob33(
	a_compania,
	a_agencia,
	v_poliza,
	_periodo,
	current
	) RETURNING v_por_vencer,
			    _exigible,  
			    v_corriente, 
			    v_monto_30,  
			    v_monto_60,  
			    v_monto_90,
			    v_saldo;
			      
 {   LET _prima_orig = 0; 
			    
	FOREACH
	 SELECT prima_bruta
	   INTO _monto
	   FROM endedmae
	  WHERE no_documento   = v_poliza	-- Facturas de la Poliza
	    AND actualizado    = 1			    -- Factura este Actualizada
	    AND periodo       <= _periodo	    -- No Incluye Periodos Futuros
		AND activa         = 1
	--    AND fecha_emision <= a_fecha        -- Hechas durante y antes de la fecha seleccionada
			LET _prima_orig = _prima_orig + _monto;
	END FOREACH
			       

 {	CALL sp_cob01(
	_no_poliza,
	_periodo,
	current
	) RETURNING _prima_orig,
			    v_saldo,     
			    v_por_vencer,
			    _exigible,  
			    v_corriente, 
			    v_monto_30,  
			    v_monto_60,  
			    v_monto_90;  
  }
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
		   TRIM(v_compania_nombre),
		   v_no_motor,		
		   v_nombre_marca,
		   v_nombre_modelo,
		   v_placa,
	       v_ano_auto,
           v_nombre_version,
		   v_fech_reclamo,	
	       v_suma_asegurada,
           v_evento_reclamo,
           _no_poliza,
           v_estatus_poliza		   
		   WITH RESUME;   	

END FOREACH



DROP TABLE tmp_arreglo;
END PROCEDURE












     