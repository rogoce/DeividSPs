CREATE PROCEDURE informix.sp_cob335(a_no_chequera CHAR(3), a_periodo CHAR(7),a_periodo2 char(7), a_area CHAR(255) DEFAULT '*') 
       RETURNING   	    CHAR(20),   -- No poliza
						CHAR(100),	-- asegurado
						DEC(16,2),  -- saldo
						CHAR(100),  -- Cobrador
						CHAR(100),  -- direccion
						CHAR(100),  -- ciudad
						CHAR(100),  -- distrito
						CHAR(100),  -- corregimiento
						CHAR(255),  -- Corredor
						CHAR(100),  -- tipo de pago
						CHAR(100),  -- Forma de pago
						DATE;       -- Fecha de cobros

DEFINE v_no_remesa	    CHAR(8);
DEFINE v_no_poliza      CHAR(10);
DEFINE v_codformapag    CHAR(100);
DEFINE v_cod_cliente    CHAR(100);
DEFINE v_no_documento   CHAR(100);		-- Numero de poliza
DEFINE v_saldo     		DEC(16,2);		-- Saldo de asegurado
DEFINE v_cobrador       CHAR(100);		-- Cobrador de calle
DEFINE v_nombre_cli     CHAR(100);		-- Nombre del cliente
DEFINE _direccion		CHAR(100);		-- Direccion de asegurado
DEFINE _code_pais       CHAR(8);  	
DEFINE _code_provincia  CHAR(8);   				
DEFINE _code_ciudad     CHAR(8);		
DEFINE _code_distrito   CHAR(8);		
DEFINE _cod_cobrador    CHAR(8);	
DEFINE v_ciudad			CHAR(100);      --Ciudad
DEFINE v_distrito       CHAR(100);      --Distrito
DEFINE v_correg         CHAR(100);      
DEFINE _code_correg     CHAR(8);      	--Corrgimiento
DEFINE v_tipo_pago		CHAR(100);    	--tipo  de pago
DEFINE _renglon         SMALLINT;		
DEFINE _tipo_pago       SMALLINT;
DEFINE v_forma_pago     CHAR(100);
DEFINE v_filtros        CHAR(255);
DEFINE _tipo	        CHAR(255);
DEFINE v_nombre_banco   CHAR(50);
DEFINE _cod_sucursal	CHAR(8); 
DEFINE v_cod_corredor   CHAR(8);
DEFINE _cod_agente		CHAR(100);
DEFINE _nombre_agente   CHAR(100);
DEFINE v_corredor       CHAR(255);	
DEFINE _cont			SMALLINT;
DEFINE _cuenta          CHAR(20);
DEFINE _fecha_cobro		date;



SET ISOLATION TO DIRTY READ;

IF a_no_chequera = '015' OR a_no_chequera = '016' OR a_no_chequera = '020' OR a_no_chequera = '018' OR a_no_chequera = '019' OR a_no_chequera = '022' OR a_no_chequera = '014' OR a_no_chequera = '028' THEN
	LET a_area = '*';
END IF				  

IF a_no_chequera = '038' THEN

	CALL sp_cob335a(a_periodo,a_periodo2);
ELSE
CREATE TEMP TABLE temp_detalle
               (t_saldo     		 DEC(16,2),
			    t_cobrador		     CHAR(50),
			    t_no_poliza		 	 CHAR(10),
				t_tipo_pago			 CHAR(50),	
				cod_area 			 CHAR(5),
				fecha_cobro			 DATE,
			    seleccionado         SMALLINT DEFAULT 1);
	FOREACH
		SELECT no_remesa,
			   cod_cobrador,
			   cod_sucursal
		  INTO v_no_remesa,
			   _cod_cobrador,
			   _cod_sucursal
		  FROM cobremae
		 WHERE cod_chequera = a_no_chequera
		   AND tipo_remesa <> 'F'
		   AND periodo >= a_periodo
		   AND periodo <= a_periodo2
		   AND actualizado = 1
			
		IF _cod_cobrador IS  NULL  THEN 
			   SELECT nombre
				 INTO v_cobrador
				 FROM chqchequ
				WHERE cod_chequera = a_no_chequera;
		ELSE
			  SELECT nombre
				INTO v_cobrador
				FROM cobcobra
			   WHERE cod_cobrador = _cod_cobrador;
		END IF  
		
		FOREACH   
				-- lectura de cobredet
		
				SELECT no_poliza,
						renglon,
						monto,
						fecha  
					INTO v_no_poliza,
						_renglon,
						v_saldo,
						_fecha_cobro
				   FROM cobredet	
				  WHERE no_remesa = v_no_remesa
					AND actualizado = 1
		
				  IF v_saldo = 0 THEN
					CONTINUE FOREACH;
				  END IF 
				 
				IF v_no_poliza IS NOT NULL THEN 
				  SELECT tipo_pago 
					INTO _tipo_pago
					FROM cobrepag
				   WHERE no_remesa = v_no_remesa
					 AND renglon   = _renglon;
					--tipo de pago
										
					IF _tipo_pago IS NOT NULL THEN	
								IF _tipo_pago = 1 THEN
									let v_tipo_pago = 'Efectivo';
								 END IF
								 
								 IF _tipo_pago = 2 THEN
									let v_tipo_pago = 'Cheque';
								 END IF
								 
								 IF _tipo_pago = 3 THEN
									let v_tipo_pago = 'Tarjeta Clave';
								 END IF
								 IF _tipo_pago = 4 THEN
									let v_tipo_pago = 'Tarjeta de Credito';
								 END IF
					END IF
					
					IF a_no_chequera = '036' OR a_no_chequera = '037' OR a_no_chequera = '038' OR a_no_chequera = '039' THEN 
						let v_tipo_pago = 'Banco';
					END IF
						  
						 SELECT cod_pagador
						   INTO  v_cod_cliente
						   FROM emipomae
						  WHERE no_poliza = v_no_poliza;
							
						 SELECT code_correg
						   INTO _code_correg
						   FROM cliclien
						  WHERE cod_cliente = v_cod_cliente;
						
						 INSERT INTO temp_detalle
							  VALUES ( v_saldo,	
									  v_cobrador,
									  v_no_poliza,
									  v_tipo_pago,
									  _code_correg,
									  _fecha_cobro,
									   1);	
					  END IF																	
					END FOREACH
				END FOREACH	
END IF
		
	LET v_filtros ="";
	IF a_area <> "*" THEN
	   LET v_filtros = TRIM(v_filtros) ||"Area "||TRIM(a_area);
         LET _tipo = sp_sis04(a_area); -- Separa los valores del String

	    IF _tipo <> "E" THEN -- Incluir los Registros

           LET v_filtros = TRIM(v_filtros);

	       UPDATE temp_detalle
		      SET seleccionado = 0
		    WHERE seleccionado = 1
		      AND cod_area NOT IN (SELECT codigo FROM tmp_codigos);

     	ELSE		        -- (E) Excluir estos Registros

           LET v_filtros = TRIM(v_filtros);

	       UPDATE temp_detalle
		      SET seleccionado = 0
		    WHERE seleccionado = 1
		      AND cod_area IN (SELECT codigo FROM tmp_codigos);

	    END IF
	    DROP TABLE tmp_codigos;
	END IF		
		   
    FOREACH
		 --lectura de tabla temporal   
		  SELECT  t_saldo,     		 
			      t_cobrador,		     
			      t_no_poliza,		 	 
				  t_tipo_pago,			 	
				  cod_area,
				  fecha_cobro
			INTO  v_saldo,	
				  v_cobrador,
				  v_no_poliza,
				  v_tipo_pago,
				  _code_correg,
				  _fecha_cobro
			FROM temp_detalle
		   WHERE seleccionado = 1
		
		
			-- lectura de emipomae
			 SELECT cod_formapag,
					cod_pagador,
					no_documento
			   INTO v_codformapag,
					v_cod_cliente,
					v_no_documento
			   FROM emipomae
			  WHERE no_poliza = v_no_poliza;
	
			--lectura de cliclien
			SELECT nombre,
				   code_pais,
				   code_provincia,
				   code_ciudad,
				   code_distrito,
				   code_correg,
				   direccion_1
			  INTO v_nombre_cli,
				   _code_pais,       
				   _code_provincia,  
				   _code_ciudad,     
				   _code_distrito,
				   _code_correg,
				   _direccion
			   FROM cliclien
			  WHERE cod_cliente = v_cod_cliente;
			  
		
			  SELECT count(*)	
			    INTO _cont
				FROM emipoagt
			   WHERE no_poliza = v_no_poliza;
			
			LET v_corredor = '';
			-- CORREDOR 			
			IF _cont > 1 THEN 
				 
				 FOREACH
					SELECT cod_agente 
					  INTO _cod_agente
					  FROM emipoagt
					 WHERE no_poliza = v_no_poliza
					 
					SELECT nombre 
					  INTO _nombre_agente
					  FROM agtagent
					 WHERE cod_agente = _cod_agente;
					 
					 LET v_corredor =  _nombre_agente||"-"|| v_corredor;
					  
				 END FOREACH
			ELSE 
				    SELECT cod_agente 
					  INTO _cod_agente
					  FROM emipoagt
					 WHERE no_poliza = v_no_poliza;
					 
					SELECT nombre 
					  INTO _nombre_agente
					  FROM agtagent
					 WHERE cod_agente = _cod_agente;
				 
				 LET v_corredor =  _nombre_agente;		
			END IF
		
		
			 SELECT  nombre
			   INTO v_forma_pago
			   FROM cobforpa	
		      WHERE cod_formapag = v_codformapag;
				    
					SELECT nombre
					  INTO v_ciudad
					  FROM genciud
					 WHERE code_pais      = _code_pais
					   AND code_provincia = _code_provincia
					   AND code_ciudad    = _code_ciudad;
					   
					SELECT nombre
					  INTO v_distrito
					  FROM gendtto
					 WHERE code_pais      = _code_pais
					   AND code_provincia = _code_provincia
					   AND code_ciudad    = _code_ciudad
					   AND code_distrito  = _code_distrito;
								
					SELECT nombre
					  INTO v_correg
					  FROM gencorr
					WHERE  code_pais      = _code_pais
					   AND code_provincia = _code_provincia
					   AND code_ciudad    = _code_ciudad
					   AND code_distrito  = _code_distrito
					   AND code_correg    = _code_correg;
					
					IF a_no_chequera = '015' THEN
						LET v_ciudad = 'COLON';
						LET v_distrito = 'COLON';
						LET v_correg = 'COLON';
					END IF
					
					IF a_no_chequera = '016' THEN
						LET v_ciudad = 'CHIRIQUI';
						LET v_distrito = 'CHIRIQUI';
						LET v_correg = 'CHIRIQUI';
					END IF
					
					IF a_no_chequera = '020' THEN
						LET v_ciudad = 'CHITRE';
						LET v_distrito = 'CHITRE';
						LET v_correg = 'CHITRE';
					END IF
					
					IF a_no_chequera = '018' THEN
						LET v_ciudad = 'CHORRERA';
						LET v_distrito = 'CHORRERA';
						LET v_correg = 'CHORRERA';
					END IF
					
					IF a_no_chequera = '019' THEN
						LET v_ciudad = 'LOS PUEBLOS';
						LET v_distrito = 'LOS PUEBLOS';
						LET v_correg = 'LOS PUEBLOS';
					END IF
					
					IF a_no_chequera = '022' THEN
						LET v_ciudad = 'SANTIAGO';
						LET v_distrito = 'SANTIAGO';
						LET v_correg = 'SANTIAGO';
					END IF
					
					IF a_no_chequera = '014' THEN
						LET v_ciudad = 'CASA MATRIZ PB1';
						LET v_distrito = 'CASA MATRIZ PB1';
						LET v_correg = 'CASA MATRIZ PB1';
					END IF
					
					IF a_no_chequera = '028' THEN
						LET v_ciudad = 'CASA MATRIZ PB2';
						LET v_distrito = 'CASA MATRIZ PB2';
						LET v_correg = 'CASA MATRIZ PB2';
					END IF
					
					RETURN v_no_documento,--EMIPOMAE
						   v_nombre_cli, -- CLICLIEN
						   v_saldo,      -- COBREDET
						   v_cobrador, --COBCOBRA
						   _direccion, --CLICLIEN
						   v_ciudad,  
						   v_distrito,
						   v_correg,
						   v_corredor,
						   v_tipo_pago,
						   v_forma_pago,
						   _fecha_cobro
						  WITH RESUME;					  
	END FOREACH
  DROP TABLE temp_detalle;
END PROCEDURE;