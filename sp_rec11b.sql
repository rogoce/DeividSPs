-- Procedimiento que Carga de Arreglo de Pago por Abogado
-- a una Fecha Dada
-- 
-- Creado    : 17/08/2000 - Autor: Amado Perez Mendoza 
-- Modificado: 04/07/2001 - Autor: Lic. Amado Perez M.
-- SIS v.2.0 - DEIVID, S.A.

DROP PROCEDURE sp_rec11b;
--DROP TABLE tmp_arreglo;
CREATE PROCEDURE "informix".sp_rec11b(a_compania CHAR(3), a_agencia CHAR(3), a_fecha DATE, a_abogado CHAR(255) DEFAULT "*", a_forma_pago CHAR(255) DEFAULT "*" ) 
			RETURNING   CHAR(5),	 --  v_no_recupero
						CHAR(100),	 --  v_asegurado     	
		    	        CHAR(18),	 --  v_numrecla       
		            	CHAR(100),	 --  v_responsable    
						CHAR(100),	 --  v_direcc_respo	
						CHAR(10),	 --  v_telefono_respo
						CHAR(10),    --  v_celular_respo
						CHAR(50),	 --  v_forma_pago    
						DEC(16,2),	 --  v_monto_arreglo
		            	DATE,		 --  v_fecha_firma   
		               	INT,		 --  v_no_pagos	
						DATE,		 --  v_fecha_pri_pago
						DEC(16,2),	 --  v_pago_mensual 	
						DEC(16,2),	 --  v_pagos_al	   
						DEC(16,2),	 --  v_saldo_al
						CHAR(50),	 --  v_nombre_abogado
						CHAR(50),	 --  v_compania_nombre
					  	DEC(16,2),	 --  _recuperado
						DEC(16,2),	 --  v_ultimo_pago
						DATE,		 --  v_fecha_ultimo_pago
						CHAR(20),	 --  v_estatus_recobro
						CHAR(255);	 --  v_filtros

DEFINE v_no_recupero         				CHAR(5);
DEFINE v_asegurado     	  	 				CHAR(100);
DEFINE v_numrecla         	 				CHAR(18);
DEFINE v_responsable         				CHAR(100);
DEFINE v_direcc_respo		 				CHAR(100);
DEFINE v_telefono_respo, v_celular_respo	CHAR(10);
DEFINE v_forma_pago          				CHAR(50);
DEFINE v_estatus_recobro     				CHAR(20);
DEFINE v_monto_arreglo       				DEC(16,2);
DEFINE v_fecha_firma         				DATE;
DEFINE v_no_pagos			 				INT;
DEFINE v_fecha_pri_pago      				DATE;
DEFINE v_pago_mensual  		 				DEC(16,2);
DEFINE v_pagos_al			 				DEC(16,2);
DEFINE v_saldo_al            				DEC(16,2);
DEFINE v_nombre_abogado      				CHAR(50);
DEFINE v_compania_nombre     				CHAR(50);
DEFINE v_filtros             				CHAR(255);
DEFINE v_prima_orig          				DEC(16,2);
DEFINE v_saldo               				DEC(16,2);
DEFINE v_ultimo_pago          				DEC(16,2);
DEFINE v_fecha_ultimo_pago					DATE;
DEFINE _recuperado           				DEC(16,2);

DEFINE _cod_abogado     					CHAR(3);
DEFINE _no_reclamo, _no_tranrec			    CHAR(10);      
DEFINE _no_poliza       					CHAR(10);
DEFINE _cod_cliente							CHAR(10);
DEFINE _cod_perpago     					CHAR(3);
DEFINE _tipo            					CHAR(1);
DEFINE _mes             					CHAR(2);
DEFINE _ano             					CHAR(4);
DEFINE _periodo         					CHAR(7);
DEFINE _estatus_recobro 					SMALLINT;

--SET DEBUG FILE TO "\\nemesis\ancon\Store Procedures\Debug\sp_rec11.trc";-- Nombre de la Compania
--TRACE ON;
SET ISOLATION TO DIRTY READ;

LET v_compania_nombre = sp_sis01(a_compania);


CREATE TEMP TABLE tmp_arreglo(
        no_recupero          CHAR(5)   NOT NULL,
		asegurado            CHAR(100) NOT NULL,
		numrecla             CHAR(18)  NOT NULL,
		responsable 		 CHAR(100),
		direccion_respo		 CHAR(100),
		telefono_respo		 CHAR(10),
		celular_respo        CHAR(10),
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
		ultimo_pago			 DEC(16,2),
		fecha_ult_pago		 DATE,
		estatus_recobro      SMALLINT,
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
		celular_tercero,
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
		v_celular_respo,
		v_monto_arreglo,
		v_no_pagos,
		v_fecha_pri_pago,
		_estatus_recobro
   FROM recrecup
  WHERE cod_compania    = a_compania
    AND fecha_recupero <= a_fecha
--    AND estatus_recobro = 5		-- Arreglo de Pago

  LET v_saldo_al = 0;
  LET v_ultimo_pago = 0;
  LET _recuperado = 0;
  LET v_pagos_al = 0;
  LET v_fecha_ultimo_pago = NULL;

  IF v_monto_arreglo IS NULL THEN
	 LET v_monto_arreglo = 0;
  END IF
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
 	  INTO _recuperado
 	  FROM rectrmae 
 	 WHERE cod_compania = a_compania
 	   AND cod_tipotran = '006'
 	   AND no_reclamo = _no_reclamo 
 	   AND fecha <= a_fecha
	   AND actualizado = 1
 	 GROUP BY no_reclamo
 	HAVING SUM(monto) <> 0;  
 	
 	IF _recuperado IS NULL THEN
 	   LET _recuperado = 0;
 	END IF  

-- Pagado

 	SELECT SUM(monto) 
 	  INTO v_pagos_al
 	  FROM rectrmae 
 	 WHERE cod_compania = a_compania
 	   AND cod_tipotran = '004'
 	   AND no_reclamo = _no_reclamo 
 	   AND fecha <= a_fecha
	   AND actualizado = 1
 	 GROUP BY no_reclamo
 	HAVING SUM(monto) <> 0;     

 	IF v_pagos_al IS NULL THEN
 	   LET v_pagos_al = 0;
 	END IF  

	IF v_asegurado IS NULL THEN
		LET v_asegurado = " ";
	END IF 

	IF v_numrecla IS NULL THEN
		LET v_numrecla = " ";
	END IF 

-- Ultimo Recupero

   FOREACH
 	SELECT monto,
	       fecha
 	  INTO v_ultimo_pago,
	       v_fecha_ultimo_pago
 	  FROM rectrmae 
 	 WHERE cod_compania = a_compania
 	   AND cod_tipotran = '006'
 	   AND no_reclamo = _no_reclamo 
 	   AND fecha <= a_fecha
	   AND actualizado = 1
	   ORDER BY fecha DESC
	  EXIT FOREACH;
   END FOREACH

 	IF v_ultimo_pago IS NULL THEN
 	   LET v_ultimo_pago = 0;
 	END IF  

   LET v_ultimo_pago = v_ultimo_pago * (-1);
 			   
	INSERT INTO tmp_arreglo(
	no_recupero,
	asegurado,          
	numrecla,           
	responsable, 	
	direccion_respo,
	telefono_respo,
	celular_respo,	
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
	recuperado,
	ultimo_pago,		
	fecha_ult_pago,    
	estatus_recobro    
	)
	VALUES(
	v_no_recupero,
	v_asegurado,     	  	
	v_numrecla,         	
	v_responsable,   
	v_direcc_respo,	
	v_telefono_respo, 
	v_celular_respo,
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
	_recuperado,
	v_ultimo_pago,
	v_fecha_ultimo_pago,
	_estatus_recobro
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
		celular_respo,
 		forma_pago,        
 		monto_arreglo,	
 		fecha_firma,		
 		no_pagos,          
 		fecha_pri_pago,   
		monto_pagado,
		abogado,
		no_reclamo,
		recuperado,
		ultimo_pago,	
		fecha_ult_pago,			
		estatus_recobro			
   INTO v_no_recupero,
   		v_asegurado,     	  
    	v_numrecla,        	
    	v_responsable,       
    	v_direcc_respo,	 
    	v_telefono_respo,	   
		v_celular_respo,
    	v_forma_pago,        
    	v_monto_arreglo,  
    	v_fecha_firma,    
    	v_no_pagos,		
    	v_fecha_pri_pago, 
	    v_pagos_al,
		v_nombre_abogado,
		_no_reclamo,
		_recuperado,
		v_ultimo_pago,
		v_fecha_ultimo_pago,
		_estatus_recobro
   FROM tmp_arreglo
  WHERE seleccionado = 1
  ORDER BY estatus_recobro, abogado,  no_recupero, numrecla

  LET v_pago_mensual = v_monto_arreglo / v_no_pagos;

  LET _recuperado = _recuperado * (-1);

  LET v_saldo_al = v_monto_arreglo - _recuperado;


  IF MONTH(a_fecha) < 10  THEN 
     LET _mes =  MONTH(a_fecha);
     LET _mes = '0'|| _mes;
  ELSE
     LET _mes =  MONTH(a_fecha);
  END IF

  LET _ano = YEAR(a_fecha);

  LET _periodo = _ano||'-'||_mes;

  LET v_estatus_recobro = '';

	IF   _estatus_recobro = 1 THEN
	   LET v_estatus_recobro = 'TRAMITE';
	ELIF _estatus_recobro = 2 THEN
	   LET v_estatus_recobro = 'INVESTIGACION';
	ELIF _estatus_recobro = 3 THEN
	   LET v_estatus_recobro = 'SUBROGACION';
	ELIF _estatus_recobro = 4 THEN
	   LET v_estatus_recobro = 'ABOGADO';
	ELIF _estatus_recobro = 5 THEN
	   LET v_estatus_recobro = 'ARREGLO DE PAGO';
	ELIF _estatus_recobro = 6 THEN
	   LET v_estatus_recobro = 'INFRUCTUOSO';
	ELIF _estatus_recobro = 7 THEN
	   LET v_estatus_recobro = 'RECUPERADO';
	ELSE
	   LET v_estatus_recobro = 'INDEFINIDO';
	END IF

 	RETURN v_no_recupero,
 		   v_asegurado,     	  	 	
		   v_numrecla,       
		   v_responsable,    
		   v_direcc_respo,	
		   v_telefono_respo,
		   v_celular_respo,	
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
		   _recuperado, 
		   v_ultimo_pago,
		   v_fecha_ultimo_pago,
		   v_estatus_recobro,
		   v_filtros
      WITH RESUME;

END FOREACH

DROP TABLE tmp_arreglo;
END PROCEDURE;