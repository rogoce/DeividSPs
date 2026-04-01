-- Inicio : 14/08/2007 - Autor: Arn ez Rub‚n
-- Procedimiento para la Red de Salud - Certificaci¢n

--DROP PROCEDURE sp_rec148;

CREATE PROCEDURE "informix".sp_rec148(a_aprob char(10))

returning char(10),
		  char(10),	
		  char(100),  
		  char(10),	
		  char(100),	
		  smallint,	
		  char(10),	
		  char(10),	
		  char(10),	
		  char(10),	
		  char(10),	
		  char(10),	
		  char(10),	
		  char(10),	
		  char(10),	
		  char(10),	
		  decimal(16,2), 
		  decimal(16,2), 
		  smallint,	   
		  decimal(5,2),  
		  decimal(5,2),  
		  integer,	   
		  decimal(16,2), 
		  decimal(5,2),  
		  decimal(16,2), 
		  decimal(5,2),  
		  decimal(16,2), 
		  decimal(5,2),  
		  decimal(16,2), 
		  decimal(5,2),  
		  char(255),		  			 
		  datetime year to fraction(5),
		  smallint, 					 
		  char(10);	  
										  	
define _no_aprobacion	     char(10);						-- A.   N£mero de Certificado
define _cod_reclamante	     char(10);						-- 1.   Cod  del Paciente
define _reclamante	         char(100);                     -- 1.1  Nombre del Reclamante
define _cod_hospital     	 char(10);						-- 2	Cod	del Cliente	Hospital/Proveedor
define _hospital	         char(100);						-- 2.1	Nombre del Cliente Hospital/Proveedor
define _tipo_procedimiento   smallint;						-- 3.   Tipo de Procedimiento
define _cod_icd1             char(10);					    -- 4.1  Diag 1
define _cod_icd2             char(10);						-- 4.2  Diag 2
define _cod_icd3             char(10);						-- 4.3  Diag 3
define _cod_icd4             char(10);						-- 4.4  Diag 4
define _cod_icd5             char(10);						-- 4.5  Diag 5
define _cod_cpt1             char(10);						-- 5.1  Procedimientos 1
define _cod_cpt2             char(10);						-- 5.2  Procedimientos 2
define _cod_cpt3             char(10);						-- 5.3  Procedimientos 3
define _cod_cpt4             char(10);						-- 5.4  Procedimientos 4
define _cod_cpt5             char(10);						-- 5.5  Procedimientos 5
define _co_pago              decimal(16,2);	  				-- 6.   Co-Pago
define _deducible            decimal(16,2);					-- 7.   Deducible
define _tipo_hab             smallint;						-- 8.   Tipo de Habitaci¢n
define _porc_aprob_hab       decimal(5,2);					-- 8.2  Por de hab
define _porc_gastos_hospit   decimal(5,2);                  -- 9    Porcentaje en gastos de hosp
define _total_dias           integer;	         		    -- 10.  Total de Dias autorizados
define _atencion_medica      decimal(16,2);					-- 11.  Atenci¢n M‚dica 
define _porc_atencion_medi   decimal(5,2);					-- 11.1 Porcentaje Atenci¢n M‚dica
define _cirujano             decimal(16,2);                 -- 12   Cirujano
define _porc_cirujano        decimal(5,2); 	  				-- 12.1 Porc. de Cirujano
define _anesteciologo        decimal(16,2);					-- 13.	Anestesiologo
define _porc_anesteciologo   decimal(5,2);					-- 13.1	Porc. Anestesiologo
define _pediatra             decimal(16,2);					-- 14   Pediatra
define _porc_pediatra        decimal(5,2);					-- 14.1 Por de Pediatra
define _comentario           char(255);		  			    -- 15   Cometarios
define _fecha_autorizacion   datetime year to fraction(5);  -- 16   Fecha de autorazaci¢n
define _estado               smallint; 						-- 17 	Estado 
define _autorizado_por       char(10);						-- 18   Registrado por	



define _no_documento	    char(20);
define _producto            char(50);

		  				 --


SET ISOLATION TO DIRTY READ;

   foreach
		SELECT  no_aprobacion,      
			    cod_reclamante,		
				cod_cliente,        
			    tipo_procedimiento,	
				cod_icd1,			
				cod_icd2,			
				cod_icd3,			
				cod_icd4,			
				cod_icd5,			
				cod_cpt1,			
				cod_cpt2,			
				cod_cpt3,			
				cod_cpt4,			
				cod_cpt5,			
			    co_pago,			
			    deducible,			
				tipo_hab,			
				porc_aprob_hab,     
				total_dias,         
				atencion_medica,    
				porc_atencion_medi, 
				cirujano,           
				porc_cirujano,      
				anesteciologo,    	
				porc_anesteciologo,	
				pediatra,          	
				porc_pediatra,      
				comentario,         
				fecha_autorizacion, 
				estado,             
				autorizado_por      

		  INTO  _no_aprobacion,      
			    _cod_reclamante,		
				_cod_hospital,
			    _tipo_procedimiento,	
				_cod_icd1,			
				_cod_icd2,			
				_cod_icd3,			
				_cod_icd5,			
				_cod_cpt1,			
				_cod_cpt2,			
				_cod_cpt3,			
				_cod_cpt4,			
				_cod_cpt5,			
			    _co_pago,			
			    _deducible,			
				_tipo_hab,			
				_porc_aprob_hab,     
				_total_dias,         
				_atencion_medica,    
				_porc_atencion_medi, 
				_cirujano,           
				_porc_cirujano,      
				_anesteciologo,    	
				_porc_anesteciologo,	
				_pediatra,          	
				_porc_pediatra,      
				_comentario,         
				_fecha_autorizacion, 
				_estado,             
				_autorizado_por      
	       FROM recprea1			             
	      WHERE no_aprobacion  = a_aprob
		    
			
		 SELECT nombre
		  INTO _hospital
		  FROM cliclien
		 WHERE cod_cliente     = _cod_hospital;
	

	   	 SELECT nombre
		   INTO _reclamante
		   FROM cliclien
		  WHERE cod_cliente    = _cod_reclamante;

	     return _no_aprobacion,      
			    _cod_reclamante,		
				_cod_hospital,
			    _tipo_procedimiento,	
				_cod_icd1,			
				_cod_icd2,			
				_cod_icd3,			
				_cod_icd5,			
				_cod_cpt1,			
				_cod_cpt2,			
				_cod_cpt3,			
				_cod_cpt4,			
				_cod_cpt5,			
			    _co_pago,			
			    _deducible,			
				_tipo_hab,			
				_porc_aprob_hab,     
				_total_dias,         
				_atencion_medica,    
				_porc_atencion_medi, 
				_cirujano,           
				_porc_cirujano,      
				_anesteciologo,    	
				_porc_anesteciologo,	
				_pediatra,          	
				_porc_pediatra,      
				_comentario,         
				_fecha_autorizacion, 
				_estado,             
				_autorizado_por
		   with resume;				 
	end foreach

END PROCEDURE
