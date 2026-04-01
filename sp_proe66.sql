-- Procedimiento que Genera la Ficha de Evaluacion - Dependintes
-- Creado    : 31/03/2012 - Autor: Henry Giron
DROP PROCEDURE sp_proe66;
CREATE PROCEDURE "informix".sp_proe66(a_no_eval char(10))
returning   char(10),        	 	   --	   _ dep_no_evaluacion       
			integer,        	 	   --	   _ dep_procesado           
			char(10) ,       	 	   --	   _ dep_cod_asegurado       
			decimal(16,2),   	 	   --	   _ dep_peso_lb          		
			decimal(16,2),   	 	   --	   _ dep_peso_kg          		
			decimal(16,2),   	 	   --	   _ dep_talla            		
			decimal(16,2),   	 	   --	   _ dep_imc              		
			integer,        	 	   --	   _ dep_tipo_evaluacion     
			integer,        	 	   --	   _ dep_hemograma           
			integer,        	 	   --	   _ dep_urinalisis          
			decimal(16,2),   	 	   --	   _ dep_psa              		
			integer,        	 	   --	   _ dep_glicemia            
			integer,        	 	   --	   _ dep_hemoglobina_g       
			integer,        	 	   --	   _ dep_glicemia_pre        
			integer,        	 	   --	   _ dep_trigliceridos       
			char(20) ,       	 	   --	   _ dep_nicotina            
			integer,        	 	   --	   _ dep_colesterol_total    
			integer,        	 	   --	   _ dep_colesterol_hdl      
			integer,        	 	   --	   _ dep_colesterol_ldl      
			integer,        	 	   --	   _ dep_acido_urico         
			decimal(16,2),   	 	   --	   _ dep_creatinina       		
			char(100),       	 	   --	   _ dep_otro                
			integer,        	 	   --	   _ dep_requisitos_adic     
			char(255),       	 	   --	   _ dep_requisitos_obs      
			date,          	     	   --	   _ dep_fecha_obs_eval      
			datetime year to second ,  --	   _ dep_hora_obs_eval       
			char(255),       	       --	   _ dep_obs_eval       
			date ,          	       --	   _ dep_fecha_obs_med  
			datetime year to second ,  --	   _ dep_hora_obs_med        
			char(255),       	       --	   _ dep_obs_med          
			date ,       	     	   --	   _ dep_fecha_eval   
			integer,        	       --	   _ dep_excl_recargo     
			decimal(16,2),   	 	   --	   _ dep_excl_peso        	
			decimal(16,2),   	 	   --	   _ dep_excl_fumador     	
			char(255),       	       --	   _ dep_obs_especiales   
			char(100),       	       --	   _ dep_hemograma_desc   
			char(100),       	       --	   _ dep_urinalisis_desc  
			integer,        	       --	   _ dep_glicemia_post    
			char(25) ,       	       --	   _ dep_hiv              
			char(100),       	       --	   _ dep_rx_torax         
			char(100),       	       --	   _ dep_ekg              
			char(100),       	       --	   _ dep_prueba_esfuerzo  
			char(10) ,       	       --	   _ dep_presion_arterial 
			char(255),       	       --	   _ dep_declinacion_obs  
			date ,          	       --	   _ dep_fecha            
			char(3),        	       --	   _ dep_cod_parentesco   
			integer,        	       --	   _ dep_tiempo3          
			integer,        	       --	   _ dep_tiempo2          
			integer,        	       --	   _ dep_tiempo1          
			char(5),        	       --	   _ dep_exclusion3       
			char(5),        	       --	   _ dep_exclusion2       
			char(5),      		 	   --	   _ dep_exclusion1    		
			char(10) ,			 	   --	   _ dep_hemograma_t 		
			char(10) ,   		 	   --	   _ dep_urinalisis_t 		
			char(10) ,			  	   --	   _ dep_hiv_t      			
			char(10) ,   		       --	   _ dep_rx_torax_t 		 
			char(15) ,			  	   --	   _ dep_tiempo1_t 			
			char(15) ,   		       --	   _ dep_tiempo2_t 		 
			char(15) ,			       --	   _ dep_tiempo3_t 		 
			char(50) ,			 	   --	   _ dep_cod_parentesco_t
			char(50) ;			 	   --	   _ dep_cod_asegurado_t 

define _dep_no_evaluacion        	char(10);        
define _dep_procesado            	integer;        
define _dep_cod_asegurado        	char(10);        
define _dep_peso_lb          		decimal(16,2);        
define _dep_peso_kg          		decimal(16,2);        
define _dep_talla            		decimal(16,2);        
define _dep_imc              		decimal(16,2);        
define _dep_tipo_evaluacion        	integer;        
define _dep_hemograma              	integer;        
define _dep_urinalisis             	integer;        
define _dep_psa              		decimal(16,2);        
define _dep_glicemia               	integer;        
define _dep_hemoglobina_g          	integer;        
define _dep_glicemia_pre           	integer;        
define _dep_trigliceridos          	integer;        
define _dep_nicotina              	char(20) ;        
define _dep_colesterol_total       	integer;        
define _dep_colesterol_hdl         	integer;        
define _dep_colesterol_ldl         	integer;        
define _dep_acido_urico            	integer;        
define _dep_creatinina       		decimal(16,2);        
define _dep_otro                 	char(100);        
define _dep_requisitos_adic      	integer;        
define _dep_requisitos_obs       	char(255);        
define _dep_fecha_obs_eval          date ;          
define _dep_hora_obs_eval           datetime year to second ;          
define _dep_obs_eval             	char(255);        
define _dep_fecha_obs_med           date ;          
define _dep_hora_obs_med            datetime year to second ;        
define _dep_obs_med              	char(255);        
define _dep_fecha_eval            	date;
define _dep_excl_recargo           	integer;        
define _dep_excl_peso        		decimal(16,2);        
define _dep_excl_fumador     		decimal(16,2);        
define _dep_obs_especiales       	char(255);        
define _dep_hemograma_desc       	char(100);        
define _dep_urinalisis_desc      	char(100);        
define _dep_glicemia_post          	integer;        
define _dep_hiv                   	char(25) ;        
define _dep_rx_torax             	char(100);        
define _dep_ekg                  	char(100);        
define _dep_prueba_esfuerzo      	char(100);        
define _dep_presion_arterial      	char(10) ;        
define _dep_declinacion_obs      	char(255);        
define _dep_fecha                   date ;          
define _dep_cod_parentesco         	char(3);        
define _dep_tiempo3                	integer;        
define _dep_tiempo2                	integer;        
define _dep_tiempo1                	integer;        
define _dep_exclusion3             	char(5);        
define _dep_exclusion2             	char(5);        
define _dep_exclusion1    			char(5);      
define _dep_hemograma_t 			char(10) ;
define _dep_urinalisis_t 			char(10) ;   
define _dep_hiv_t      			    char(10) ;
define _dep_rx_torax_t 		        char(10) ;   
define _dep_tiempo1_t 			    char(15) ;
define _dep_tiempo2_t 		        char(15) ;   
define _dep_tiempo3_t 		       	char(15) ;
define _dep_cod_parentesco_t        char(50) ;   
define _dep_cod_asegurado_t        	char(50) ;
												 
SET ISOLATION TO DIRTY READ;
					 
--SET DEBUG FILE TO "sp_proe66.trc";			 
--trace on;

SET LOCK MODE TO WAIT;

let _dep_no_evaluacion = ' '  ;
let _dep_procesado      =  0 ;
let _dep_cod_asegurado = ' '  ;
let  _dep_peso_lb       = 0.00 ;
let  _dep_peso_kg       = 0.00 ;
let  _dep_talla         = 0.00 ;
let  _dep_imc           = 0.00 ;
let _dep_tipo_evaluacion  =  0 ;
let _dep_hemograma        =  0 ;
let _dep_urinalisis       =  0 ;
let  _dep_psa           = 0.00 ;
let _dep_glicemia         =  0 ;
let _dep_hemoglobina_g    =  0 ;
let _dep_glicemia_pre     =  0 ;
let _dep_trigliceridos    =  0 ;
let _dep_nicotina       = ' '  ;
let _dep_colesterol_total      =  0 ;
let _dep_colesterol_hdl=  0 ;
let _dep_colesterol_ldl=  0 ;
let _dep_acido_urico   =  0 ;
let  _dep_creatinina       	 = 0.00 ;
let _dep_otro               = ' '  ;
let _dep_requisitos_adic     =  0 ;
let _dep_requisitos_obs = ' '  ;
let _dep_fecha_obs_eval    = '01/01/1900' ;
let _dep_hora_obs_eval    = current ;
let _dep_obs_eval      = ' '  ;
let _dep_fecha_obs_med     = '01/01/1900' ;
let _dep_hora_obs_med     = current ;
let _dep_obs_med       = ' '  ;
let _dep_fecha_eval     = '01/01/1900' ;
let _dep_excl_recargo     =  0 ;
let  _dep_excl_peso     = 0.00 ;
let  _dep_excl_fumador  = 0.00 ;
let _dep_obs_especiales= ' '  ;
let _dep_hemograma_desc= ' '  ;
let _dep_urinalisis_desc  = ' '  ;
let _dep_glicemia_post  =  0 ;
let _dep_hiv        = ' '  ;
let _dep_rx_torax  = ' '  ;
let _dep_ekg       = ' '  ;
let _dep_prueba_esfuerzo = ' '  ;
let _dep_presion_arterial = ' '  ;
let _dep_declinacion_obs = ' '  ;
let _dep_fecha    = '01/01/1900' ;
let _dep_cod_parentesco = ' '  ;
let _dep_tiempo3         =  0 ;
let _dep_tiempo2         =  0 ;
let _dep_tiempo1         =  0 ;
let _dep_exclusion3     = ' '  ;
let _dep_exclusion2     = ' '  ;
let _dep_exclusion1    = "" ;
let _dep_hemograma_t   = "" ;
let _dep_urinalisis_t  = "" ;
let _dep_hiv_t           = "" ;
let _dep_rx_torax_t         = "" ;
let _dep_tiempo1_t 	    = "" ;
let _dep_tiempo2_t 	    = "" ;
let _dep_tiempo3_t 	   = ' '  ;
let _dep_cod_parentesco_t = "";
let _dep_cod_asegurado_t  = "";

BEGIN
foreach
  SELECT no_evaluacion,   
         procesado,   
         cod_asegurado,   
         peso_lb,   
         peso_kg,   
         talla,   
         imc,   
         tipo_evaluacion,   
         hemograma,   
         urinalisis,   
         psa,   
         glicemia,   
         hemoglobina_g,   
         glicemia_pre,   
         trigliceridos,   
         nicotina,   
         colesterol_total,   
         colesterol_hdl,   
         colesterol_ldl,   
         acido_urico,   
         creatinina,   
         otro,   
         requisitos_adic,   
         requisitos_obs,   
         fecha_obs_eval,   
         hora_obs_eval,   
         obs_eval,   
         fecha_obs_med,   
         hora_obs_med,   
         obs_med,   
         fecha_eval,   
         excl_recargo,   
         excl_peso,   
         excl_fumador,   
         obs_especiales,   
         hemograma_desc,   
         urinalisis_desc,   
         glicemia_post,   
         hiv,   
         rx_torax,   
         ekg,   
         prueba_esfuerzo,   
         presion_arterial,   
         declinacion_obs,   
         fecha,   
         cod_parentesco,   
         tiempo3,   
         tiempo2,   
         tiempo1,   
         exclusion3,   
         exclusion2,   
         exclusion1  
	into _dep_no_evaluacion,   
         _dep_procesado,   
         _dep_cod_asegurado,   
         _dep_peso_lb,   
         _dep_peso_kg,   
         _dep_talla,   
         _dep_imc,   
         _dep_tipo_evaluacion,   
         _dep_hemograma,   
         _dep_urinalisis,   
         _dep_psa,   
         _dep_glicemia,   
         _dep_hemoglobina_g,   
         _dep_glicemia_pre,   
         _dep_trigliceridos,   
         _dep_nicotina,   
         _dep_colesterol_total,   
         _dep_colesterol_hdl,   
         _dep_colesterol_ldl,   
         _dep_acido_urico,   
         _dep_creatinina,   
         _dep_otro,   
         _dep_requisitos_adic,   
         _dep_requisitos_obs,   
         _dep_fecha_obs_eval,   
         _dep_hora_obs_eval,   
         _dep_obs_eval,   
         _dep_fecha_obs_med,   
         _dep_hora_obs_med,   
         _dep_obs_med,   
         _dep_fecha_eval,   
         _dep_excl_recargo,   
         _dep_excl_peso,   
         _dep_excl_fumador,   
         _dep_obs_especiales,   
         _dep_hemograma_desc,   
         _dep_urinalisis_desc,   
         _dep_glicemia_post,   
         _dep_hiv,   
         _dep_rx_torax,   
         _dep_ekg,   
         _dep_prueba_esfuerzo,   
         _dep_presion_arterial,   
         _dep_declinacion_obs,   
         _dep_fecha,   
         _dep_cod_parentesco,   
         _dep_tiempo3,   
         _dep_tiempo2,   
         _dep_tiempo1,   
         _dep_exclusion3,   
         _dep_exclusion2,   
         _dep_exclusion1  
    FROM emievade  
   WHERE no_evaluacion = a_no_eval    

  		if _dep_hemograma = 1 then
  		   let _dep_hemograma_t = "Normal"	;
	   else
	  		if _dep_hemograma = 2 then
	  		   let _dep_hemograma_t = "Anormal";
		   else
	  		   let _dep_hemograma_t = "";
		   end if  
	   end if  

  		if _dep_urinalisis = 1 then
  		   let _dep_urinalisis_t = "Normal";
	   else
	  		if _dep_urinalisis = 2 then
	  		   let _dep_urinalisis_t = "Anormal";
		   else
	  		   let _dep_urinalisis_t = "";
		   end if  
	   end if  
  		if _dep_hiv = "1" then
  		   let _dep_hiv_t = "Normal";
	   else
	  		if _dep_hiv = "2" then
	  		   let _dep_hiv_t = "Anormal";
		   else
	  		   let _dep_hiv_t = "";
		   end if  
	   end if  
  		if _dep_rx_torax = 1 then
  		   let _dep_rx_torax_t = "Normal";
	   else
	  		if _dep_rx_torax = 2 then
	  		   let _dep_rx_torax_t = "Anormal";
		   else
	  		   let _dep_rx_torax_t = "";
		   end if  
	   end if  

  		if _dep_tiempo1 = 0 then
  		   let _dep_tiempo1_t = " ";
	   end if  
  		if _dep_tiempo1 = 1 then
  		   let _dep_tiempo1_t = "PERMANENTE";
	   end if  
  		if _dep_tiempo1 = 2 then
  		   let _dep_tiempo1_t = "1 AÑO";
	   end if  
  		if _dep_tiempo1 = 3 then
  		   let _dep_tiempo1_t = "6 MESES";
	   end if 
  		if _dep_tiempo2 = 0 then
  		   let _dep_tiempo2_t = " ";
	   end if  
  		if _dep_tiempo2 = 1 then
  		   let _dep_tiempo2_t = "PERMANENTE";
	   end if  
  		if _dep_tiempo2 = 2 then
  		   let _dep_tiempo2_t = "1 AÑO";
	   end if  
  		if _dep_tiempo2 = 3 then
  		   let _dep_tiempo2_t = "6 MESES";
	   end if 
  		if _dep_tiempo3 = 0 then
  		   let _dep_tiempo3_t = " ";
	   end if  
  		if _dep_tiempo3 = 1 then
  		   let _dep_tiempo3_t = "PERMANENTE";
	   end if  
  		if _dep_tiempo3 = 2 then
  		   let _dep_tiempo3_t = "1 AÑO";
	   end if  
  		if _dep_tiempo3 = 3 then
  		   let _dep_tiempo3_t = "6 MESES";
	   end if 

	select nombre
	  into _dep_cod_parentesco_t
	  from emiparen
	 where cod_parentesco = _dep_cod_parentesco;

	select nombre
	  into _dep_cod_asegurado_t
	  from cliclien
	 where cod_cliente = _dep_cod_asegurado;

		 Return	_dep_no_evaluacion, 
			_dep_procesado    , 
			_dep_cod_asegurado, 
			_dep_peso_lb,	
			_dep_peso_kg,	
			_dep_talla  ,	
			_dep_imc    ,	
			_dep_tipo_evaluacion , 
			_dep_hemograma , 
			_dep_urinalisis, 
			_dep_psa       ,	
			_dep_glicemia  , 
			_dep_hemoglobina_g, 
			_dep_glicemia_pre , 
			_dep_trigliceridos, 
			_dep_nicotina     , 
			_dep_colesterol_total  , 
			_dep_colesterol_hdl, 
			_dep_colesterol_ldl, 
			_dep_acido_urico, 
			_dep_creatinina,	
			_dep_otro , 
			_dep_requisitos_adic , 
			_dep_requisitos_obs, 
			_dep_fecha_obs_eval, 
			_dep_hora_obs_eval , 
			_dep_obs_eval      , 
			_dep_fecha_obs_med , 
			_dep_hora_obs_med , 
			_dep_obs_med  , 
			_dep_fecha_eval , 
			_dep_excl_recargo , 
			_dep_excl_peso  ,	
			_dep_excl_fumador ,	
			_dep_obs_especiales , 
			_dep_hemograma_desc , 
			_dep_urinalisis_desc , 
			_dep_glicemia_post , 
			_dep_hiv , 
			_dep_rx_torax , 
			_dep_ekg , 
			_dep_prueba_esfuerzo, 
			_dep_presion_arterial, 
			_dep_declinacion_obs, 
			_dep_fecha, 
			_dep_cod_parentesco , 
			_dep_tiempo3 , 
			_dep_tiempo2 , 
			_dep_tiempo1, 
			_dep_exclusion3, 
			_dep_exclusion2, 
			_dep_exclusion1,	
			_dep_hemograma_t,	
			_dep_urinalisis_t,	
			_dep_hiv_t,
			_dep_rx_torax_t,	   
			_dep_tiempo1_t,	
			_dep_tiempo2_t,
			_dep_tiempo3_t,
			_dep_cod_parentesco_t,
			_dep_cod_asegurado_t 
		    with resume;

end foreach

END


END PROCEDURE 
	   	   		 