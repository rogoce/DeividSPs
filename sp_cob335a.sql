-- REPORTE DE MONTOS POR AREAS
-- 
-- Creado    : 06/01/2014 - Autor: Angel Tello M.
--
--
-- SIS v.2.0 - DEIVID, S.A.
DROP PROCEDURE sp_cob335a;

CREATE PROCEDURE "informix".sp_cob335a( a_periodo CHAR(7),a_periodo2 char(7)) 
       returning integer, char(100);

						
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

CREATE TEMP TABLE temp_detalle
               (t_saldo     		 DEC(16,2),
			    t_cobrador		     CHAR(50),
			    t_no_poliza		 	 CHAR(10),
				t_tipo_pago			 CHAR(50),	
				cod_area 			 CHAR(5),	
			    seleccionado         SMALLINT DEFAULT 1);

SET ISOLATION TO DIRTY READ;

	FOREACH   
	
	SELECT DISTINCT no_remesa 
	  INTO v_no_remesa
	  FROM cobredet
	 WHERE doc_remesa = '1220105'
       AND periodo >= a_periodo
	   AND periodo <= a_periodo2
	   AND actualizado = 1
	   order by 1
		 
		FOREACH
			SELECT no_poliza,
					renglon,
					monto
			   INTO v_no_poliza,
					_renglon,
					v_saldo
			   FROM cobredet	
			  WHERE no_remesa = v_no_remesa
			    AND tipo_mov <> 'M'
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
				
			
					let v_tipo_pago = 'Banco';
		
			         
					LET v_cobrador = 'MULTIBANK';
					  
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
								   1);	
				  END IF																	
				END FOREACH
		END FOREACH
		
  return 0, "Actualizacion Exitosa";		
END PROCEDURE;