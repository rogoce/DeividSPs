---------------------------------------------------
-- Reporte   : ENVIADO POR EMAIL - EMICARTASAL5  --
-- Creado    : 14/07/2025 - Autor: Amado Perez	 --
---------------------------------------------------
DROP PROCEDURE sp_pro1124;
CREATE PROCEDURE sp_pro1124(a_periodo CHAR(7), a_opcion smallint)
RETURNING char(100),char(20),date,char(50),char(5),decimal(16,2),char(7),char(3),char(100),CHAR(100),char(100),char(100),decimal(16,2),smallint,lvarchar(500),smallint,date,char(10), CHAR(10),char(100);
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
	  DEFINE _emails			   lvarchar(500);
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
	  DEFINE _estatus_poliza,a_opc       SMALLINT;
	  DEFINE _prima_nvo			   decimal(16,2);
	  DEFINE _email_cc             char(100);
	  DEFINE _cod_vendedor         char(3);
	  DEFINE _usuario              char(8);

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
	           emails			lvarchar(500),
	           enviado_email	smallint,
	           fecha_email		date,
	           cod_agente		char(10),
			   seleccionado		smallint,
			   estatus_poliza   smallint,
			   email_cc			char(100)
            ) WITH NO LOG;
										 
	CREATE INDEX idx1_tmp_email2012 ON tmp_email2012(no_documento);
	CREATE INDEX idx2_tmp_email2012 ON tmp_email2012(periodo);	       

LET _total_enviada = 0;
	
let a_opc = a_opcion;
if a_opcion = 2 THEN
	let a_opc = 4;
end if
FOREACH
  SELECT DISTINCT b.nombre,   
         a.no_documento,   
         a.fecha_aniv,   
         a.producto_nvo,   
         a.prima_nvo,   
         a.periodo,   
         c.nombre,
         a.emails,
         a.enviado_email,
         a.fecha_email
    INTO _nombre_cliente, 
		 _no_documento, 
		 _fecha_aniv, 
		 _cod_producto, 
		 _prima, 
		 _periodo, 
		 _name_cliclien,
         _emails,
         _enviado_email,
         _fecha_email
    FROM emicartasal6 a,   
         cliclien b, 
         cliclien c		 
   WHERE a.cod_contratante = b.cod_cliente
     and a.cod_asegurado = c.cod_cliente
	 and a.periodo = a_periodo
	 and (a.opcion = a_opcion
	  or a.opcion = a_opc)
ORDER BY a.no_documento ASC   	 

		CALL sp_sis21(_no_documento) RETURNING _no_poliza;

		LET _no_pagos = 0;
		
		SELECT vigencia_inic,
			   vigencia_final,
			   no_pagos,
			   estatus_poliza,
			   cod_perpago
		  INTO _vigencia_inic,
			   _vigencia_final,
			   _no_pagos,
			   _estatus_poliza,
			   _cod_perpago
		  FROM emipomae
		 WHERE no_poliza = _no_poliza;
		 
		  FOREACH
			  SELECT cod_agente 
			    INTO _cod_agente
				FROM emipoagt
			   WHERE no_poliza = _no_poliza

			  SELECT nombre
			    INTO _nombre_agente
				FROM agtagent
			   WHERE cod_agente = _cod_agente;

				EXIT FOREACH;

		  END FOREACH	

        SELECT nombre
		  INTO _nombre_plan
		  FROM prdprod
		 WHERE cod_producto = _cod_producto;
 		

		 --prima bruta / no. de pagos
		-- LET _prima_mensual = _prima / _no_pagos;
		LET _prima_mensual = _prima;
		 
		 LET _email_cliente = ""; 
		 LET _email_agente  = "";
         LET _email_cc = "";		 
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

              foreach
				  SELECT email
					INTO _e_mail
					FROM climail
				   WHERE cod_cliente = _cod_asegurado

				  IF _e_mail IS NOT NULL OR trim(_e_mail) <> "" THEN
					LET _email_cliente = trim(_email_cliente) || ";" || trim(_e_mail) ;
				  END IF
			  end foreach
		  END FOREACH

		 LET _e_mail = "";  

		  FOREACH
			  SELECT cod_agente 
			    INTO _cod_agente
				FROM emipoagt
			   WHERE no_poliza = _no_poliza

			  SELECT email_personas
			    INTO _e_mail
				FROM agtagent
			   WHERE cod_agente = _cod_agente;

		      IF _e_mail IS NOT NULL OR trim(_e_mail) <> "" THEN
				LET _email_agente = trim(_e_mail) || ";" ;
			  ELSE
				  SELECT e_mail
					INTO _e_mail
					FROM agtagent
				   WHERE cod_agente = _cod_agente;

				  IF _e_mail IS NOT NULL OR trim(_e_mail) <> "" THEN
					LET _email_agente = trim(_e_mail) || ";" ;
				  END IF
			  END IF
			  
			  foreach
				  select email
					into _e_mail
					from agtmail
				   where cod_agente = _cod_agente
					 and tipo_correo = 'PER'

				  if _e_mail is not null and trim(_e_mail) <> "" then
					let _email_agente = trim(_email_agente) || trim(_e_mail) || ";";
				  end if
			  end foreach
			  
			  foreach
				  select email
					into _e_mail
					from agtmail
				   where cod_agente = _cod_agente
					 and tipo_correo = 'COM'

				  if _e_mail is not null and trim(_e_mail) <> "" then
					let _email_agente = trim(_email_agente) || trim(_e_mail) || ";";
				  end if
			  end foreach
			  

		  END FOREACH
		  
		  let _e_mail = "";  

		  foreach		        	
			  select cod_agente 
				into _cod_agente
				from emipoagt
			   where no_poliza = _no_poliza

			  select cod_vendedor2
				into _cod_vendedor
				from agtagent
			   where cod_agente = _cod_agente;
			   
			  select usuario
				into _usuario
				from agtvende
			   where cod_vendedor = _cod_vendedor;	

			  select e_mail	   
				into _e_mail
				from insuser
			   where usuario = _usuario;

			  if _e_mail is not null and trim(_e_mail) <> "" then
				let _email_cc = trim(_email_cc) || trim(_e_mail) || ";";
			  end if
		  end foreach
  
		  let _email_cc = trim(_email_cc) || "departamentopersonas@asegurancon.com;";		  

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
						seleccionado,
						estatus_poliza,
						email_cc
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
						1,
						_estatus_poliza,
						_email_cc
     			  	  	 );	    			    			    			    
			    
END FOREACH

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
			cod_agente,
			estatus_poliza,
			email_cc
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
			_cod_agente,
			_estatus_poliza,
			_email_cc
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
					(case when _estatus_poliza = 1 then "VIGENTE" else (case when _estatus_poliza = 2 then "CANCELADA" else (case when _estatus_poliza = 3 then "VENCIDA" else "ANULADA" end) end)end),
					_email_cc
	                WITH RESUME;


END FOREACH

DROP TABLE tmp_email2012;
END

END PROCEDURE  




	
   

 
      	
    	
  

  

	


		

	
	
