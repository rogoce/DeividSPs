---------------------------------------------------
-- Reporte   : ENVIADO POR EMAIL - EMICARTASAL2  --
-- Creado    : 20/12/2011 - Autor: Henry Giron	 --
---------------------------------------------------
DROP PROCEDURE sp_pro4945;
--CREATE PROCEDURE sp_pro4945(a_periodo CHAR(7),a_imp1 SMALLINT DEFAULT 0, a_imp2 SMALLINT DEFAULT 0, a_envi1 SMALLINT DEFAULT 0, a_envi2 SMALLINT DEFAULT 0, a_envi3 SMALLINT DEFAULT 0, a_envi4 SMALLINT DEFAULT 0,a_poliza CHAR(20) DEFAULT "%")
CREATE PROCEDURE sp_pro4945(a_periodo CHAR(7), a_codagente CHAR(255) DEFAULT "*")
RETURNING char(100),char(20),date,char(50),char(5),decimal(16,2),char(7),char(3),char(100),CHAR(100),char(100),char(100),decimal(16,2),smallint,CHAR(255),smallint,date,char(10),CHAR(255);
   BEGIN
      DEFINE _nombre_cliente  	   CHAR(100);
      DEFINE _no_documento	  	   CHAR(100);
      DEFINE _fecha_aniv   	  	   date;
      DEFINE _nombre_agente	  	   CHAR(50);
      DEFINE _cod_producto 	  	   CHAR(5);
      DEFINE _prima      	   	   decimal(16,2);
      DEFINE _periodo    	  	   CHAR(7);
      DEFINE _name_cliclien   	   CHAR(100);
	  DEFINE _nombre_plan          CHAR(100);
	  DEFINE _email_cliente	       CHAR(100);
	  DEFINE _email_agente	       CHAR(100); 
	  DEFINE _prima_mensual	       decimal(16,2);
	  DEFINE _total_enviada        smallint;
	  DEFINE _emails			   CHAR(255);
	  DEFINE _enviado_email	       smallint;
	  DEFINE _fecha_email		   date;	
	  DEFINE _error 			   smallint; 	
	  DEFINE _e_mail               varchar(50);	
	  DEFINE _no_poliza			   CHAR(10);	
	  DEFINE _cod_asegurado        CHAR(10);	
	  DEFINE _cod_agente       	   CHAR(10);	
      DEFINE _cod_perpago  	  	   CHAR(3);
	  DEFINE _no_pagos             INTEGER;
	  DEFINE _vigencia_inic        date;
	  DEFINE _vigencia_final       date;
	  DEFINE v_filtros             CHAR(255);
	  DEFINE _tipo                 CHAR(1);

--	     set debug file to "sp_pro4945.trc";
--	   trace on;

     CREATE TEMP TABLE tmp_email2012
			  (nombre_cliente	char(100), 
			   no_documento		char(20),	
			   fecha_aniv   	date,	
			   nombre_agente	char(50),	
			   cod_producto 	char(5), 
			   prima      		decimal(16,2),
			   periodo    		char(7), 
			   cod_perpago  	char(3),	
			   name_cliclien    char(100),
			   nombre_plan      CHAR(100),
			   email_cliente	char(100), 
			   email_agente	    char(100), 
			   prima_mensual	decimal(16,2),
			   total_enviada    smallint,
	           emails			CHAR(255),
	           enviado_email	smallint,
	           fecha_email		date,
	           cod_agente		char(10),
			   seleccionado		smallint
            ) WITH NO LOG;
										 
	CREATE INDEX idx1_tmp_email2012 ON tmp_email2012(no_documento);
	CREATE INDEX idx2_tmp_email2012 ON tmp_email2012(periodo);	       

	LET _total_enviada = 0;
FOREACH
  SELECT DISTINCT emicartasal2.nombre_cliente,   
         emicartasal2.no_documento,   
         emicartasal2.fecha_aniv,   
         emicartasal2.nombre_agente,   
         emicartasal2.cod_producto,   
         emicartasal2.prima,   
         emicartasal2.periodo,   
         cliclien.nombre,
         emicartasal2.nombre_plan,
         emicartasal2.emails,
         emicartasal2.enviado_email,
         emicartasal2.fecha_email,
         emicartasal2.cod_perpago
    INTO _nombre_cliente, 
		 _no_documento, 
		 _fecha_aniv, 
		 _nombre_agente, 
		 _cod_producto, 
		 _prima, 
		 _periodo, 
		 _name_cliclien,
		 _nombre_plan,
         _emails,
         _enviado_email,
         _fecha_email,
		 _cod_perpago 
    FROM emicartasal2,   
         emipomae,   
         cliclien  
   WHERE ( emicartasal2.no_documento = emipomae.no_documento ) and  
         ( emipomae.cod_contratante = cliclien.cod_cliente ) and  
         ( emicartasal2.periodo = a_periodo ) --AND  
--         (emicartasal2.impreso = a_imp1 OR emicartasal2.impreso = a_imp2) AND  
--         emicartasal2.enviado_a in (a_envi1,a_envi2,a_envi3,a_envi4) AND  
--         emicartasal2.no_documento like a_poliza )   
ORDER BY emicartasal2.nombre_agente ASC,   
         emicartasal2.no_documento ASC   	 

		 CALL sp_sis21(_no_documento) RETURNING _no_poliza;

		   LET _no_pagos = 0;
		SELECT vigencia_inic,
			   vigencia_final,
			   no_pagos
		  INTO _vigencia_inic,
			   _vigencia_final,
			   _no_pagos
		  FROM emipomae
		 WHERE no_poliza = _no_poliza;

		 --prima bruta / no. de pagos
		 LET _prima_mensual = _prima / _no_pagos;
		 
		 LET _email_cliente = ""; 
		 LET _email_agente  = ""; 
		 LET _e_mail = "";  

		  FOREACH
			  SELECT cod_asegurado 
			    INTO _cod_asegurado
				FROM emipouni
			   WHERE no_poliza = _no_poliza

			  SELECT e_mail
			    INTO _e_mail
				FROM cliclien
			   WHERE cod_cliente = _cod_asegurado;

		      IF _e_mail IS NOT NULL OR trim(_e_mail) <> "" THEN
				LET _email_cliente = trim(_e_mail) ;
			  END IF

		  END FOREACH

		 LET _e_mail = "";  

		  FOREACH
			  SELECT cod_agente 
			    INTO _cod_agente
				FROM emipoagt
			   WHERE no_poliza = _no_poliza

			  SELECT e_mail
			    INTO _e_mail
				FROM agtagent
			   WHERE cod_agente = _cod_agente;

		      IF _e_mail IS NOT NULL OR trim(_e_mail) <> "" THEN
				LET _email_agente = trim(_e_mail) ;
				EXIT FOREACH;
			  END IF

		  END FOREACH

		LET _total_enviada = _total_enviada + 1;

			INSERT INTO tmp_email2012(nombre_cliente,
						no_documento,		
						fecha_aniv,	
						nombre_agente,	
						cod_producto,	
						prima,	
			            periodo,	
							cod_perpago,
						name_cliclien,
						nombre_plan,
						emails,			
						enviado_email,	
						fecha_email,
						email_cliente,	
						email_agente,	 
						prima_mensual,	
						total_enviada,
						cod_agente,
						seleccionado 											
						  )  
    	     VALUES(    _nombre_cliente, 
				  		_no_documento, 
    			  		_fecha_aniv, 
    			  		_nombre_agente, 
    			  		_cod_producto, 
    			  		_prima, 
    			  		_periodo, 
						_cod_perpago,
     			  	  	_name_cliclien,
     			  	  	_nombre_plan,
						_emails,			
						_enviado_email,	
						_fecha_email,
						_email_cliente,	
						_email_agente,	 
						_prima_mensual,	
						_total_enviada,
						_cod_agente,
						1 
     			  	  	 );	    			    			    			    
			    
END FOREACH

-- Procesos v_filtros
LET v_filtros ="";

IF a_codagente <> "*" THEN
 LET v_filtros = TRIM(v_filtros) ||"Corredor "||TRIM(a_codagente);
 LET _tipo = sp_sis04(a_codagente); -- Separa los valores del String

 IF _tipo <> "E" THEN -- Incluir los Registros

    UPDATE tmp_email2012
           SET seleccionado = 0
         WHERE seleccionado = 1
           AND cod_agente NOT IN(SELECT codigo FROM tmp_codigos);
 ELSE
    UPDATE tmp_email2012
           SET seleccionado = 0
         WHERE seleccionado = 1
           AND cod_agente IN(SELECT codigo FROM tmp_codigos);
 END IF
 DROP TABLE tmp_codigos;
END IF


FOREACH
     SELECT nombre_cliente,
			no_documento,		
			fecha_aniv,   	
			nombre_agente,	
			cod_producto, 	
			prima,      		
			periodo,    		
			cod_perpago,  	
			name_cliclien, 
			nombre_plan,   
			email_cliente,	
			email_agente,	 
			prima_mensual,	
	  	  	total_enviada, 
			emails,			
			enviado_email,	
			fecha_email,		
			cod_agente														
       INTO _nombre_cliente,
	        _no_documento,		
			_fecha_aniv,   	
			_nombre_agente,	
			_cod_producto, 	
			_prima,      		
			_periodo,    		
			_cod_perpago,  	
	  	  	_name_cliclien, 
			_nombre_plan,   
			_email_cliente,	
			_email_agente,	 
			_prima_mensual,	
			_total_enviada, 
			_emails,			
			_enviado_email,	
			_fecha_email,		
			_cod_agente		
       FROM tmp_email2012	
	   where seleccionado = 1
	  ORDER BY nombre_agente ASC,   
               no_documento ASC   

	         RETURN _nombre_cliente,--01
			        _no_documento,	--02
					_fecha_aniv,   	--03
					_nombre_agente,	--04
					_cod_producto, 	--05
					_prima,      	--06
					_periodo,    	--07
					_cod_perpago,  	--08
			  	  	_name_cliclien, --09
					_nombre_plan,   --10	
					_email_cliente,	--11
					_email_agente,	--12
					_prima_mensual,	--13
					_total_enviada, --14
					_emails,		--15 
					_enviado_email,	--16
					_fecha_email,	--17
				    _cod_agente,	--18
					v_filtros
	                WITH RESUME;


END FOREACH

DROP TABLE tmp_email2012;
END

END PROCEDURE  




	
   

 
      	
    	
  

  

	


		

	
	
