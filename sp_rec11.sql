-- Procedimiento que Carga de Arreglo de Pago por Abogado
-- a una Fecha Dada
-- 
-- Creado    : 17/08/2000 - Autor: Amado Perez Mendoza 
-- Modificado: 22/05/2001 - Autor: Marquelda Valdelamar
-- SIS v.2.0 - DEIVID, S.A.

--DROP PROCEDURE sp_rec11;
--DROP TABLE tmp_arreglo;
CREATE PROCEDURE "informix".sp_rec11(a_compania CHAR(3), a_agencia CHAR(3), a_fecha DATE, a_abogado CHAR(255) DEFAULT "*", a_forma_pago CHAR(255) DEFAULT "*" ) 
			RETURNING   CHAR(5),
						CHAR(100),
		    	        CHAR(18),
		            	CHAR(100),
						CHAR(100),
						CHAR(10),
						CHAR(50),
						DEC(16,2),
		            	DATE,
		               	INT,
						DATE,
						DEC(16,2),
						DEC(16,2),
						DEC(16,2),
						CHAR(50),
						CHAR(50),
						DEC(16,2),	-- Prima Original
						DEC(16,2),	-- Saldo
						DEC(16,2),	-- Por Vencer
						DEC(16,2),	-- Exigible
						DEC(16,2),	-- Corriente
						DEC(16,2),	-- 30 Dias
						DEC(16,2),	-- 60 Dias
						DEC(16,2),	-- 90 Dias   
					  	DEC(16,2),	-- recuperado
						CHAR(255)

DEFINE v_no_recupero         CHAR(5);
DEFINE v_asegurado     	  	 CHAR(100);
DEFINE v_numrecla         	 CHAR(18);
DEFINE v_responsable         CHAR(100);
DEFINE v_direcc_respo		 CHAR(100);
DEFINE v_telefono_respo		 CHAR(10);
DEFINE v_forma_pago          CHAR(50);
DEFINE v_monto_arreglo       DEC(16,2);
DEFINE v_fecha_firma         DATE;
DEFINE v_no_pagos			 INT;
DEFINE v_fecha_pri_pago      DATE;
DEFINE v_pago_mensual  		 DEC(16,2);
DEFINE v_pagos_al			 DEC(16,2);
DEFINE v_saldo_al            DEC(16,2);
DEFINE v_nombre_abogado      CHAR(50);
DEFINE v_compania_nombre     CHAR(50);
DEFINE v_filtros             CHAR(255);
DEFINE v_prima_orig          DEC(16,2);
DEFINE v_saldo               DEC(16,2);
DEFINE v_por_vencer          DEC(16,2);
DEFINE v_exigible            DEC(16,2);
DEFINE v_corriente           DEC(16,2);
DEFINE v_monto_30            DEC(16,2);
DEFINE v_monto_60            DEC(16,2);
DEFINE v_monto_90            DEC(16,2);
DEFINE _recuperado           DEC(16,2);

DEFINE _cod_abogado     CHAR(3);
DEFINE _no_reclamo      CHAR(10);      
DEFINE _no_poliza       CHAR(10);
DEFINE _cod_cliente		CHAR(10);
DEFINE _cod_perpago     CHAR(3);
DEFINE _tipo            CHAR(1);
DEFINE _mes             CHAR(2);
DEFINE _ano             CHAR(4);
DEFINE _periodo         CHAR(7);
DEFINE _estatus_recobro SMALLINT;

SET ISOLATION TO DIRTY READ;

--SET DEBUG FILE TO "\\nemesis\ancon\Store Procedures\Debug\sp_rec11.trc";-- Nombre de la Compania
--TRACE ON;

LET v_compania_nombre = sp_sis01(a_compania);


CREATE TEMP TABLE tmp_arreglo(
        no_recupero          CHAR(5)   NOT NULL,
		asegurado            CHAR(100) NOT NULL,
		numrecla             CHAR(18)  NOT NULL,
		responsable 		 CHAR(100),
		direccion_respo		 CHAR(100),
		telefono_respo		 CHAR(10),
		forma_pago           CHAR(50),
		monto_arreglo	     DEC(16,2),
		fecha_firma		     DATE,
		no_pagos             INT, 
		fecha_pri_pago       DATE,
		monto_pagado         DEC(16,2),
		abogado				 CHAR(50),
		cod_abogado          CHAR(3),
		cod_perpago          CHAR(3),
		no_reclamo			 CHAR(10),
		recuperado           DEC(16,2),
		seleccionado         SMALLINT  DEFAULT 1 NOT NULL
		) WITH NO LOG;   
FOREACH	

 SELECT no_recupero,
 		no_reclamo,
		cod_abogado,
		cod_perpago,
		fecha_envio,
		nombre_tercero,
		direccion_tercero,
		telefono_tercero,
		monto_arreglo,
		no_pagos,
		fecha_primer_pago,
		estatus_recobro
   INTO v_no_recupero,
   		_no_reclamo,
		_cod_abogado,
		_cod_perpago,
		v_fecha_firma,
		v_responsable,
		v_direcc_respo,
		v_telefono_respo,
		v_monto_arreglo,
		v_no_pagos,
		v_fecha_pri_pago,
		_estatus_recobro
   FROM recrecup
  WHERE cod_compania    = a_compania
    AND fecha_recupero <= a_fecha

 
 --   AND estatus_recobro = 5		-- Arreglo de Pago

   	-- Lectura de Reclamos

 	SELECT numrecla,
           no_poliza
   	  INTO v_numrecla,
           _no_poliza
      FROM recrcmae
     WHERE no_reclamo = _no_reclamo 
	   AND actualizado = 1;

	-- Lectura de Polizas

	SELECT cod_contratante
	  INTO _cod_cliente
	  FROM emipomae
	 WHERE no_poliza = _no_poliza;

	-- Lectura de Cliente

	SELECT nombre
	  INTO v_asegurado
 	  FROM cliclien
	 WHERE cod_cliente = _cod_cliente;

    -- Lectura de Abogado

	SELECT nombre_abogado
	  INTO v_nombre_abogado
	  FROM recaboga
	 WHERE cod_abogado = _cod_abogado;

	-- Lectura de Periodo de Pago

	SELECT nombre
	  INTO v_forma_pago
	  FROM cobperpa
	 WHERE cod_perpago = _cod_perpago;

-- Recuperos

 	SELECT SUM(monto) 
 	  INTO v_pagos_al
 	  FROM rectrmae 
 	 WHERE cod_compania = a_compania
 	   AND cod_tipotran = '006'
 	   AND no_reclamo = _no_reclamo 
 	   AND fecha <= a_fecha
	   AND actualizado = 1
 	 GROUP BY no_reclamo
 	HAVING SUM(monto) <> 0;     

	IF v_asegurado IS NULL THEN
		LET v_asegurado = " ";
	END IF 

	IF v_numrecla IS NULL THEN
		LET v_numrecla = " ";
	END IF 

-- Recuperado

 	SELECT SUM(recupero) 
 	  INTO _recuperado
 	  FROM recrccob  
 	 WHERE no_reclamo = _no_reclamo;
 			   
	INSERT INTO tmp_arreglo(
	no_recupero,
	asegurado,          
	numrecla,           
	responsable, 	
	direccion_respo,
	telefono_respo,	
	forma_pago,     	
	monto_arreglo,		
	fecha_firma,		 
	no_pagos,       		
	fecha_pri_pago, 
	monto_pagado,
	abogado,			
	cod_abogado,
	cod_perpago,
	no_reclamo,
	recuperado
	)
	VALUES(
	v_no_recupero,
	v_asegurado,     	  	
	v_numrecla,         	
	v_responsable,   
	v_direcc_respo,	
	v_telefono_respo, 
	v_forma_pago,    
	v_monto_arreglo,   
	v_fecha_firma,	
	v_no_pagos,    
	v_fecha_pri_pago,
	v_pagos_al,
	v_nombre_abogado,
	_cod_abogado,
	_cod_perpago,
	_no_reclamo,
	_recuperado
	);
END FOREACH;

--Filtros

LET v_filtros = "";

IF a_abogado <> "*" THEN

	LET v_filtros = TRIM(v_filtros) || " Abogado: " ||  TRIM(a_abogado);

	LET _tipo = sp_sis04(a_abogado);  -- Separa los Valores del String en una tabla de codigos

	IF _tipo <> "E" THEN -- (I) Incluir los Registros

		UPDATE tmp_arreglo
		   SET seleccionado = 0
		 WHERE seleccionado = 1
		   AND cod_abogado NOT IN (SELECT codigo FROM tmp_codigos);

	ELSE		        -- (E) Excluir estos Registros
				   
		UPDATE tmp_arreglo
		   SET seleccionado = 0
		 WHERE seleccionado = 1
		   AND cod_abogado IN (SELECT codigo FROM tmp_codigos);

	END IF

	DROP TABLE tmp_codigos;

END IF

IF a_forma_pago <> "*" THEN

	LET v_filtros = TRIM(v_filtros) || " Forma de Pago: " ||  TRIM(a_forma_pago);

	LET _tipo = sp_sis04(a_forma_pago);  -- Separa los Valores del String en una tabla de codigos

	IF _tipo <> "E" THEN -- (I) Incluir los Registros

		UPDATE tmp_arreglo
		   SET seleccionado = 0
		 WHERE seleccionado = 1
		   AND cod_perpago NOT IN (SELECT codigo FROM tmp_codigos);

	ELSE		        -- (E) Excluir estos Registros
				   
		UPDATE tmp_arreglo
		   SET seleccionado = 0
		 WHERE seleccionado = 1
		   AND cod_perpago IN (SELECT codigo FROM tmp_codigos);

	END IF

	DROP TABLE tmp_codigos;

END IF


--Recorre la tabla temporal y asigna valores a variables de salida
FOREACH WITH HOLD
 SELECT no_recupero,
 		asegurado,          
 		numrecla,          
 		responsable, 	
 		direccion_respo,
 		telefono_respo,	
 		forma_pago,        
 		monto_arreglo,	
 		fecha_firma,		
 		no_pagos,          
 		fecha_pri_pago,   
		monto_pagado,
		abogado,
		no_reclamo,
		recuperado
   INTO v_no_recupero,
   		v_asegurado,     	  
    	v_numrecla,        	
    	v_responsable,       
    	v_direcc_respo,	 
    	v_telefono_respo,	   
    	v_forma_pago,        
    	v_monto_arreglo,  
    	v_fecha_firma,    
    	v_no_pagos,		
    	v_fecha_pri_pago, 
	    v_pagos_al,
		v_nombre_abogado,
		_no_reclamo,
		_recuperado
   FROM tmp_arreglo
  WHERE seleccionado = 1
  ORDER BY abogado, estatus_recobro, no_recupero, numrecla

  LET v_pagos_al = v_pagos_al * (-1);

  LET v_pago_mensual = v_monto_arreglo / v_no_pagos;

  LET v_saldo_al = v_monto_arreglo - v_pagos_al;

  IF MONTH(a_fecha) < 10  THEN 
     LET _mes =  MONTH(a_fecha);
     LET _mes = '0'|| _mes;
  ELSE
     LET _mes =  MONTH(a_fecha);
  END IF

  LET _ano = YEAR(a_fecha);

  LET _periodo = _ano||'-'||_mes;

  CALL sp_rec11a(_no_reclamo,
                v_no_recupero,
                _periodo,
                a_fecha)
      RETURNING v_prima_orig,
				v_saldo,     
				v_por_vencer,
				v_exigible,  
				v_corriente, 
				v_monto_30,  
				v_monto_60,  
				v_monto_90;


 	RETURN v_no_recupero,
 		   v_asegurado,     	  	 	
		   v_numrecla,       
		   v_responsable,    
		   v_direcc_respo,	
		   v_telefono_respo,	
		   v_forma_pago,     
		   v_monto_arreglo,  
		   v_fecha_firma,    
		   v_no_pagos,		
		   v_fecha_pri_pago,    
		   v_pago_mensual,  	  
		   v_pagos_al,		   
		   v_saldo_al,
		   v_nombre_abogado,          
		   v_compania_nombre,
		   v_prima_orig,
		   v_saldo,     
		   v_por_vencer,
		   v_exigible,  
		   v_corriente, 
		   v_monto_30,  
		   v_monto_60,  
		   v_monto_90,
		   _recuperado,  
		   v_filtros
      WITH RESUME;

END FOREACH

DROP TABLE tmp_arreglo;
END PROCEDURE;