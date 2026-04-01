-- Carta de Aviso de Cancelacion
-- Creado    : 11/08/2010 - Autor: Armando Moreno
-- CREATE PROCEDURE "informix".sp_cob748(a_compania CHAR(3),a_cobrador CHAR(3) DEFAULT '*',a_tipo_aviso SMALLINT,a_sucursal CHAR(3) DEFAULT '*',a_agente CHAR(5) DEFAULT '*',a_ramo CHAR(3) DEFAULT '*',a_acreedor	CHAR(5) DEFAULT '*', a_asegurado CHAR(10) DEFAULT '*',a_callcenter SMALLINT DEFAULT 0)

--DROP PROCEDURE sp_cob749;
CREATE PROCEDURE "informix".sp_cob749(a_compania CHAR(3),a_cobrador CHAR(3) DEFAULT '*',a_tipo_aviso SMALLINT,a_agente CHAR(5) DEFAULT '*',a_acreedor CHAR(5) DEFAULT '*', a_asegurado CHAR(10) DEFAULT '*',a_callcenter SMALLINT DEFAULT 0, a_referencia CHAR(15))
RETURNING   CHAR(15), 		   -- no_aviso 		
		    CHAR(20), 		   -- no_documento 	
		    CHAR(10), 		   -- no_poliza 		
		    CHAR(7), 		   -- periodo 			
		    DATE, 			   -- vigencia_inic 	
		    DATE, 			   -- vigencia_final 
		    CHAR(3), 		   -- cod_ramo 		
		    CHAR(50), 		   -- nombre_ramo 		
		    CHAR(50), 		   -- nombre_subramo 
		    CHAR(10), 		   -- cedula 			
		    CHAR(100), 		   -- nombre_cliente 
		    DECIMAL(16,2),	   -- saldo 			
		    DECIMAL(16,2),	   -- por_vencer 		
		    DECIMAL(16,2),	   -- exigible 		
		    DECIMAL(16,2),	   -- corriente 		
		    DECIMAL(16,2),	   -- dias_30 			
			DECIMAL(16,2),	   -- dias_60 			
			DECIMAL(16,2),	   -- dias_90 			
			DECIMAL(16,2),	   -- dias_120 		
			DECIMAL(16,2),	   -- dias_150 		
			DECIMAL(16,2),	   -- dias_180 		
			CHAR(5), 		   -- cod_acreedor 	
			CHAR(50), 		   -- nombre_acreedor
			CHAR(5), 		   -- cod_agente 		
			CHAR(50), 		   -- nombre_agente 	
			DECIMAL(16,2),	   -- porcentaje 		
			CHAR(10), 		   -- telefono 		
			CHAR(3), 		   -- cod_cobrador 	
			CHAR(3), 		   -- cod_vendedor 	
 			CHAR(20), 		   -- apartado 		
 			CHAR(10), 		   -- fax_cli 			
 			CHAR(10), 		   -- tel1_cli 		
 			CHAR(10), 		   -- tel2_cli 		
 			CHAR(20), 		   -- apart_cli 		
 			CHAR(50), 		   -- email_cli 		
 			DATE,  			   -- fecha_proc 
 			CHAR(3),  		   -- cod_forma_pago
			CHAR(50),		   -- forma_pago
			CHAR(1),		   -- cobra_poliza
			CHAR(50),		   -- compania_nombre
			CHAR(50);		   -- cobrador

DEFINE _compania_nombre 	CHAR(50); 
DEFINE _nombre_cobrador 	CHAR(50); 
define _no_aviso 			CHAR(15); 
define _no_documento 		CHAR(20); 
define _no_poliza 			CHAR(10); 
define _periodo 			CHAR(7); 
define _vigencia_inic 		DATE; 
define _vigencia_final 	    DATE; 
define _cod_ramo 			CHAR(3); 
define _nombre_ramo 		CHAR(50); 
define _nombre_subramo 	    CHAR(50); 
define _cedula 				CHAR(10); 
define _nombre_cliente 	    CHAR(100); 
define _saldo 				DECIMAL(16,2); 
define _por_vencer 			DECIMAL(16,2); 
define _exigible 			DECIMAL(16,2); 
define _corriente 			DECIMAL(16,2); 
define _dias_30 			DECIMAL(16,2); 
define _dias_60 			DECIMAL(16,2); 
define _dias_90 			DECIMAL(16,2); 
define _dias_120 			DECIMAL(16,2); 
define _dias_150 			DECIMAL(16,2); 
define _dias_180 			DECIMAL(16,2); 
define _cod_acreedor 		CHAR(5); 
define _nombre_acreedor 	CHAR(50); 
define _cod_agente 			CHAR(5); 
define _nombre_agente 		CHAR(50); 
define _porcentaje 			DECIMAL(16,2); 
define _telefono 			CHAR(10); 
define _cod_cobrador 		CHAR(3); 
define _cod_vendedor 		CHAR(3); 
define _apartado 			CHAR(20); 
define _fax_cli 			CHAR(10); 
define _tel1_cli 			CHAR(10); 
define _tel2_cli 			CHAR(10); 
define _apart_cli 			CHAR(20); 
define _email_cli 			CHAR(50); 
define _fecha_proc 			DATE;
define _cobra_poliza	 	CHAR(1);
DEFINE _cod_formapag    	CHAR(3);
DEFINE _nombre_formapag 	CHAR(50);
DEFINE _direccion1          CHAR(50);
DEFINE _direccion2			CHAR(50);


SET ISOLATION TO DIRTY READ;

IF a_agente = '%'	THEN
	LET a_agente = '*';
END IF
IF a_acreedor = '%'	THEN
	LET a_acreedor = '*';
END IF
IF a_asegurado = '%'	THEN
	LET a_asegurado = '*';
END IF
IF a_cobrador = '%'	THEN
	LET a_cobrador = '*';
END IF

-- Nombre de la Compania
LET  _compania_nombre = sp_sis01(a_compania); 

if a_callcenter = 0 then
	let _cobra_poliza = "C";
else
	let _cobra_poliza = "E";
end if

-- Reporte de las Cartas a Imprimir
FOREACH
  SELECT no_aviso,   
         no_documento,   
         no_poliza,   
         periodo,   
         vigencia_inic,   
         vigencia_final,   
         cod_ramo,   
         nombre_ramo,   
         nombre_subramo,   
         cedula,   
         nombre_cliente,   
         saldo,   
         por_vencer,   
         exigible,   
         corriente,   
         dias_30,   
         dias_60,   
         dias_90,   
         dias_120,   
         dias_150,   
         dias_180,   
         cod_acreedor,   
         nombre_acreedor,   
         cod_agente,   
         nombre_agente,   
         porcentaje,   
         telefono,   
         cod_cobrador,   
         cod_vendedor,   
         apartado,   
         fax_cli,   
         tel1_cli,   
         tel2_cli,   
         apart_cli,   
         email_cli,   
         fecha_proc,  
		 cod_formapag,   
		 nombre_formapag,
		 cobra_poliza          
  into  _no_aviso,   
         _no_documento,   
         _no_poliza,   
         _periodo,   
         _vigencia_inic,   
         _vigencia_final,   
         _cod_ramo,   
         _nombre_ramo,   
         _nombre_subramo,   
         _cedula,   
         _nombre_cliente,   
         _saldo,   
         _por_vencer,   
         _exigible,   
         _corriente,   
         _dias_30,   
         _dias_60,   
         _dias_90,   
         _dias_120,   
         _dias_150,   
         _dias_180,   
         _cod_acreedor,   
         _nombre_acreedor,   
         _cod_agente,   
         _nombre_agente,   
         _porcentaje,   
         _telefono,   
         _cod_cobrador,   
         _cod_vendedor,   
         _apartado,   
         _fax_cli,   
         _tel1_cli,   
         _tel2_cli,   
         _apart_cli,   
         _email_cli,   
         _fecha_proc,
		 _cod_formapag,   
		 _nombre_formapag,
		 _cobra_poliza          
    FROM avisocanc  
   WHERE no_aviso     = a_referencia
	 AND cod_agente   MATCHES a_agente
	 AND cod_acreedor MATCHES a_acreedor
	 AND cedula  MATCHES a_asegurado
	 AND cod_cobrador MATCHES a_cobrador
   ORDER BY periodo, nombre_agente, nombre_cliente, no_documento	          

-- Cobrador

  SELECT nombre
    INTO _nombre_cobrador
    FROM cobcobra
   WHERE cod_cobrador = _cod_cobrador;

	  -- Seleccion de Datos del Cliente
	SELECT direccion_1, 
	       direccion_2
	  INTO _direccion1,
		   _direccion2
	  FROM cliclien
	 WHERE cod_cliente = _cod_contratante;


	RETURN _no_aviso,   		-- no_aviso 		  -- no_aviso 		
		   _no_documento,   	-- no_documento		  -- no_documento 	
		   _nombre_cliente, 	-- n_cliente		  -- no_poliza 		
		   _nombre_acreedor,	-- n_acreedor		  -- periodo 			
		   _periodo,   			-- periodo 			  -- vigencia_inic 	
		   _vigencia_inic,  	-- vig_inic 		  -- vigencia_final 
		   _vigencia_final, 	-- vig_final 		  -- cod_ramo 		
		   _cod_ramo,   		-- cod_ramo 		  -- nombre_ramo 		
		   _nombre_ramo,   		-- n_ramo 			  -- nombre_subramo 
		   _nombre_subramo, 	-- n_subramo 		  -- cedula 			
		   _cedula,   			-- cedula 			  -- nombre_cliente 
		   _saldo,   			-- saldo1 			  -- saldo 			
		   _por_vencer,   		-- porvencer 		  -- por_vencer 		
		   _exigible,   		-- exigible1 		  -- exigible 		
		   _corriente,   		-- corriente1 		  -- corriente 		
		   _dias_30,   			-- dias30 			  -- dias_30 			
		   _dias_60,   			-- dias60 			  -- dias_60 			
		   _dias_90,   			-- dias90 			  -- dias_90 			
		   _dias_120,   		-- dias120 			  -- dias_120 		
		   _dias_150,   		-- dias150 			  -- dias_150 		
		   _dias_180,   		-- dias180 			  -- dias_180 		
		   _cod_acreedor,   	-- acreedor 		  -- cod_acreedor 	
		   _cod_agente,   		-- cod_agente 		  -- nombre_acreedor
		   _nombre_agente,  	-- n_agente 		  -- cod_agente 		
		   _porcentaje,   		-- porcentaje 		  -- nombre_agente 	
		   _telefono,   		-- telefono 		  -- porcentaje 		
		   _cod_cobrador,   	-- cod_cobrador 	  -- telefono 		
		   _cod_vendedor,   	-- cod_vendedor 	  -- cod_cobrador 	
		   _apartado,   		-- apartado 		  -- cod_vendedor 	
		   _fax_cli,   			-- fax_cli 			  -- apartado 		
		   _tel1_cli,   		-- tel1_cli 		  -- fax_cli 			
		   _tel2_cli,   		-- tel2_cli 		  -- tel1_cli 		
		   _apart_cli,   		-- apart_cli 		  -- tel2_cli 		
		   _email_cli,   		-- email_cli 		  -- apart_cli 		
		   _fecha_proc,		   	-- fecha_proc 		  -- email_cli 		 
		   _cod_formapag,       -- cod_f_pago		  -- fecha_proc 
		   _nombre_formapag, 	-- f_pago			  -- cod_forma_pago
		   _cobra_poliza,		-- cobra_poliza		  -- forma_pago
		   _compania_nombre,    -- compania			  -- cobra_poliza
		   _nombre_cobrador     -- n_cobrador		  -- compania_nombre
		   WITH RESUME;	 							  -- cobrador

END FOREACH

END PROCEDURE;	 