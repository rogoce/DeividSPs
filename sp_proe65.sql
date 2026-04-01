-- Procedimiento que Genera la Ficha de Evaluacion - Principal
-- Creado    : 31/03/2012 - Autor: Henry Giron
DROP PROCEDURE sp_proe65;
CREATE PROCEDURE "informix".sp_proe65(a_no_eval char(10))
returning  	char(10),					--_no_evaluacion,
			date,						--_fecha,
			char(10),					--_no_recibo,
			char(100),					--_nombre,
			integer,					--_tipo_ramo,
			integer,					--_indivi_colec,
			integer,					--_cant_registros, 	
			decimal(16,2),				--_monto,
			char(8),					--_user_added,
			date,						--_date_changed,
			integer,					--_procesado,
			integer,					--_escaneado,
			integer,					--_completado,
			integer,					--_bo_ok,
			date,						--_fecha_escan,
			char(8),					--_user_escan,
			integer ,					--_grupo,
			char(10),					--_cod_asegurado,
			integer ,					--_identidad,
			date,						--_fecha_nacimiento,
			integer ,					--_edad,
			char(1),					--_sexo,
			decimal(16,2),				--_peso_lb,
			decimal(16,2),				--_peso_kg,
			decimal(16,2),				--_talla,
			decimal(16,2),				--_imc,
			char(50),					--_nacionalidad,
			char(50),					--_pais_reside,
			integer ,					--_tarjeta_credito,
			date,						--_fecha_recibo,
			integer ,					--_conoce_cliente,
			char(50),					--_nombre_ejecutivo,
			char(50),					--_nombre_corredor,
			char(30),					--_email_contacto,
			integer ,					--_tipo_evaluacion,
			char(5),					--_plan,
			decimal(16,2),				--_maximo_vitalicio,
			integer ,					--_basal,
			integer ,					--_hemograma,
			integer ,					--_urinalisis,
			integer ,					--_glicemia,
			integer ,					--_hemoglobina_g,
			integer ,					--_glicemia_pre,
			integer ,					--_trigliceridos,
			integer ,					--_colesterol_total,
			integer ,					--_colesterol_hdl, 	
			integer ,					--_colesterol_ldl, 	
			integer ,					--_acido_urico,
			integer ,					--_requisitos_adic,
			char(255),					--_requisitos_obs, 	
			date,						--_fecha_obs_eval, 	
			datetime year to second,	--_hora_obs_eval,
			char(255),					--_obs_eval,
			date,						--_fecha_obs_med,
			datetime year to second,	--_hora_obs_med,
			char(255),					--_obs_med,
			date ,						--_fecha_eval,
			char(8),					--_usuario_med,
			integer ,					--_excl_recargo,
			decimal(16,2),				--_excl_peso,
			decimal(16,2),				--_excl_fumador,
			integer ,					--_decicion,
			char(255),					--_obs_especiales,
			char(10),					--_presion_arterial,
			char(20),					--_identidad_otro, 	
			char(8),					--_usuario_eval,
			char(25),					--_hiv,
			integer ,					--_glicemia_post,
			char(5),					--_cod_agente,
			char(100),					--_hemograma_desc,
			char(100),					--_urinalisis_desc,
			char(20),					--_nicotina,
			char(100),					--_rx_torax,
			char(100),					--_prueba_esfuerzo,
			char(100),					--_ekg,
			decimal(16,2),				--_psa,
			decimal(16,2),				--_creatinina,
			char(100),					--_otro,
			decimal(16,2),				--_suma_asegurada,
			char(50),					--_claves,
			char(3),					--_cod_perpago,
			char(5),					--_no_recibo2,
			decimal(16,2),				--_monto_recibo2,
			char(5),					--_exclusion1,
			char(5),					--_exclusion2,
			char(5),					--_exclusion3,
			integer,					--_tiempo1,
			integer,					--_tiempo2,
			integer,					--_tiempo3,
			integer,					--_declina_asegurado,
			decimal(16,2),				--_cumulo_vi,
			char(3),					--_cod_sucursal,
			char(10),					--_cod_contratante,
			char(255),					--_comentario,
			char(8),					--_eval_original,
			date,						--_fecha_completado,
			char(3),					--_cod_subramo,
			integer,					--_doble_cobertura,
			char(3),					--_cod_coasegur,
			date,						--_vig_ini,
			integer,					--_cia_ind_col,
			char(20),					--_tipo_ramo_t,
			char(20),					--_indivi_colec_t,
			char(2),					--_grupo_t,
			char(3),					--_identidad_t,
			char(15),					--_sexo_t,
			char(30),					--_tipo_evaluacion_t,
			char(10),					--_hemograma_t,
			char(10),   				--_urinalisis_t,
			char(30),   				--_decicion_t,
			char(15),					--_tiempo1_t,
			char(15),   				--_tiempo2_t,
			char(15),					--_tiempo3_t,
			char(15),   				--_cia_ind_col_t
			varchar(100);				--_asegurado


define _n_nombre_paren              varchar(100);
define _asegurado                   varchar(100);
define _n_paren                     varchar(50);
define _dep_declinacion_obs      	char(255);
define _dep_requisitos_obs       	char(255);
define _dep_obs_especiales       	char(255);
define _requisitos_obs    		   	char(255);
define _obs_especiales    		   	char(255);
define _dep_obs_eval             	char(255);
define _dep_obs_med              	char(255);
define _comentario    			   	char(255);
define _obs_eval    			   	char(255);
define _obs_med    				   	char(255);
define _dep_prueba_esfuerzo      	char(100);
define _dep_urinalisis_desc      	char(100);
define _dep_hemograma_desc       	char(100);
define _prueba_esfuerzo    		   	char(100);
define _urinalisis_desc    		   	char(100);
define _hemograma_desc    		   	char(100);
define _dep_rx_torax             	char(100);
define _rx_torax    			   	char(100);
define _dep_otro                 	char(100);
define _dep_ekg                  	char(100);
define _nombre    				   	char(100);
define _otro    				   	char(100);
define _ekg    					   	char(100);
define _nombre_ejecutivo    	   	char(50);
define _nombre_corredor    		   	char(50);
define _nacionalidad    		   	char(50);
define _pais_reside    			   	char(50);
define _claves    				   	char(50);
define _tipo_evaluacion_t    		char(30);
define _email_contacto    		   	char(30);
define _decicion_t           		char(30);
define _dep_hiv                   	char(25);
define _hiv    					   	char(25);
define _identidad_otro    		   	char(20);
define _indivi_colec_t       		char(20);
define _dep_nicotina              	char(20);
define _tipo_ramo_t          		char(20);
define _nicotina    			   	char(20);
define _cia_ind_col_t 				char(15);
define _dep_tiempo1_t 			    char(15);
define _dep_tiempo2_t 		        char(15);
define _dep_tiempo3_t 		       	char(15);
define _tiempo1_t 			    	char(15);
define _tiempo2_t 		        	char(15);
define _tiempo3_t 		       		char(15);
define _sexo_t               		char(15);
define _dep_presion_arterial      	char(10);
define _dep_no_evaluacion        	char(10);
define _dep_cod_asegurado        	char(10);
define _dep_urinalisis_t 			char(10);
define _presion_arterial    	   	char(10);
define _cod_contratante    		   	char(10);
define _dep_hemograma_t 			char(10);
define _dep_rx_torax_t 		        char(10);
define _cod_asegurado    		   	char(10);
define _no_evaluacion    		   	char(10);
define _urinalisis_t 				char(10);
define _hemograma_t 				char(10);
define _dep_hiv_t      			    char(10);
define _no_recibo    			   	char(10);
define _eval_original    		   	char(8);
define _usuario_eval    		   	char(8);
define _usuario_med    			   	char(8);
define _user_escan					char(8);
define _user_added    			   	char(8);
define _dep_exclusion3             	char(5);
define _dep_exclusion2             	char(5);
define _dep_exclusion1    			char(5);
define _no_recibo2    			   	char(5);
define _cod_agente    			   	char(5);
define _exclusion1    			   	char(5);
define _exclusion2    			   	char(5);
define _exclusion3    			   	char(5);
define _plan    				   	char(5);
define _dep_cod_parentesco         	char(3);
define _cod_coasegur    		   	char(3);
define _cod_sucursal    		   	char(3);
define _cod_perpago    			   	char(3);
define _cod_subramo    			   	char(3);
define _identidad_t          		char(3);
define _grupo_t              		char(2);
define _sexo    				   	char(1);
define _cant_registros    		   	integer;
define _indivi_colec    		   	integer;
define _tipo_ramo    			   	integer;
define _procesado    			   	integer;
define _escaneado    			   	integer;
define _completado    			   	integer;
define _bo_ok    				   	integer;
define _grupo    				   	integer;
define _edad    				   	integer;
define _tarjeta_credito    		   	integer;
define _identidad    			   	integer;
define _conoce_cliente    		   	integer;
define _basal    				   	integer;
define _hemograma    			   	integer;
define _urinalisis    			   	integer;
define _glicemia    			   	integer;
define _hemoglobina_g    		   	integer;
define _glicemia_pre    		   	integer;
define _trigliceridos    		   	integer;
define _colesterol_total    	   	integer;
define _colesterol_hdl    		   	integer;
define _colesterol_ldl    		   	integer;
define _acido_urico    			   	integer;
define _requisitos_adic    		   	integer;
define _excl_recargo    		   	integer;
define _decicion    			   	integer;
define _glicemia_post    		   	integer;
define _tiempo1    				   	integer;
define _tiempo2    				   	integer;
define _tiempo3    				   	integer;
define _declina_asegurado    	   	integer;
define _doble_cobertura    		   	integer;
define _cia_ind_col 			   	integer;
define _dep_tipo_evaluacion        	integer;
define _dep_hemograma              	integer;
define _dep_urinalisis             	integer;
define _dep_glicemia               	integer;
define _dep_hemoglobina_g          	integer;
define _dep_glicemia_pre           	integer;
define _dep_trigliceridos          	integer;
define _dep_colesterol_total       	integer;
define _dep_colesterol_hdl         	integer;
define _dep_colesterol_ldl         	integer;
define _dep_acido_urico            	integer;
define _dep_procesado            	integer;
define _dep_requisitos_adic      	integer;
define _dep_excl_recargo           	integer;
define _dep_glicemia_post          	integer;
define _dep_tiempo3                	integer;
define _dep_tiempo2                	integer;
define _tipo_evaluacion    		   	integer;
define _dep_tiempo1                	integer;
define _maximo_vitalicio    	   	decimal(16,2);
define _dep_excl_fumador     		decimal(16,2);
define _dep_creatinina       		decimal(16,2);
define _suma_asegurada    		   	decimal(16,2);
define _monto_recibo2    		   	decimal(16,2);
define _dep_excl_peso        		decimal(16,2);
define _excl_fumador    		   	decimal(16,2);
define _dep_peso_lb          		decimal(16,2);        
define _dep_peso_kg          		decimal(16,2);
define _creatinina    			   	decimal(16,2);
define _dep_talla            		decimal(16,2);
define _cumulo_vi    			   	decimal(16,2);
define _peso_lb    				   	decimal(16,2);
define _peso_kg    				   	decimal(16,2);
define _dep_imc              		decimal(16,2);
define _dep_psa              		decimal(16,2);
define _monto    				   	decimal(16,2);
define _talla    				   	decimal(16,2);
define _imc    					   	decimal(16,2);
define _psa    					   	decimal(16,2);
define _excl_peso    			   	decimal(16,2);
define _dep_hora_obs_eval           datetime year to second;
define _dep_hora_obs_med            datetime year to second;
define _hora_obs_eval    		   	datetime year to second;
define _hora_obs_med    		   	datetime year to second;
define _dep_fecha_obs_eval          date;
define _dep_fecha_obs_med           date;
define _fecha_completado    	   	date;
define _fecha_nacimiento    	   	date;
define _dep_fecha_eval            	date;
define _fecha_obs_eval    		   	date;
define _fecha_obs_med    		   	date;
define _fecha_recibo    		   	date;
define _date_changed    		   	date;
define _fecha_escan    			   	date;
define _fecha_eval    			   	date;
define _dep_fecha                   date;
define _vig_ini    				   	date;
define _fecha    				   	date;


let _dep_presion_arterial	= '';
let _dep_declinacion_obs	= '';
let _dep_prueba_esfuerzo	= '';
let _dep_urinalisis_desc	= '';
let _dep_obs_especiales		= '';
let _dep_hemograma_desc		= '';
let _dep_requisitos_obs		= '';
let _dep_cod_parentesco		= '';
let _tipo_evaluacion_t		= '';
let _dep_no_evaluacion		= '';
let _dep_cod_asegurado		= '';
let _nombre_ejecutivo		= '';
let _dep_urinalisis_t		= '';
let _presion_arterial		= '';
let _prueba_esfuerzo		= '';
let _dep_hemograma_t		= '';
let _nombre_corredor		= '';
let _urinalisis_desc		= '';
let _cod_contratante		= '';
let _hemograma_desc			= '';
let _dep_exclusion3			= '';
let _dep_exclusion2			= '';
let _dep_exclusion1			= '';
let _email_contacto			= '';
let _dep_rx_torax_t			= '';
let _requisitos_obs			= '';
let _obs_especiales			= '';
let _identidad_otro			= '';
let _indivi_colec_t			= '';
let _dep_tiempo1_t			= '';
let _dep_tiempo2_t			= '';
let _dep_tiempo3_t			= '';
let _no_evaluacion			= '';
let _cod_asegurado			= '';
let _cia_ind_col_t			= '';
let _eval_original			= '';
let _usuario_eval			= '';
let _cod_sucursal			= '';
let _dep_nicotina			= '';
let _nacionalidad			= '';
let _urinalisis_t			= '';
let _cod_coasegur			= '';
let _dep_rx_torax			= '';
let _dep_obs_eval			= '';
let _dep_obs_med			= '';
let _usuario_med			= '';
let _cod_perpago			= '';
let _cod_subramo			= '';
let _tipo_ramo_t			= '';
let _identidad_t			= '';
let _hemograma_t			= '';
let _pais_reside			= '';
let _decicion_t				= '';
let _comentario				= '';
let _no_recibo2				= '';
let _exclusion1				= '';
let _exclusion2				= '';
let _exclusion3				= ''; 
let _cod_agente				= ''; 
let _user_escan				= '';
let _user_added				= '';
let _dep_hiv_t				= ''; 
let _tiempo1_t				= ''; 
let _tiempo2_t				= ''; 
let _tiempo3_t				= '';
let _no_recibo				= ''; 
let _obs_eval				= '';
let _dep_otro				= ''; 
let _nicotina				= ''; 
let _rx_torax				= '';
let _obs_med				= '';
let _dep_hiv				= '';
let _dep_ekg				= '';
let _grupo_t				= '';
let _claves					= '';
let _sexo_t					= '';
let _nombre					= '';
let _sexo					= '';
let _plan					= '';
let _hiv					= '';
let _ekg					= '';
let _otro					= '';
let _dep_colesterol_total	= 0;
let _dep_tipo_evaluacion	= 0;
let _dep_requisitos_adic	= 0;
let _dep_colesterol_hdl		= 0;
let _dep_colesterol_ldl		= 0;
let _declina_asegurado  	= 0;
let _dep_hemoglobina_g		= 0;
let _dep_glicemia_post		= 0;
let _dep_trigliceridos		= 0;
let _dep_excl_recargo		= 0;
let _dep_glicemia_pre		= 0;
let _colesterol_total		= 0;
let _requisitos_adic		= 0;
let _doble_cobertura		= 0;
let _dep_acido_urico		= 0;
let _tarjeta_credito		= 0;
let _tipo_evaluacion		= 0;
let _dep_urinalisis			= 0;
let _colesterol_hdl			= 0;
let _colesterol_ldl			= 0;
let _cant_registros			= 0;
let _conoce_cliente			= 0;
let _dep_procesado			= 0;
let _dep_hemograma			= 0;
let _glicemia_post			= 0;
let _hemoglobina_g			= 0;
let _trigliceridos			= 0;
let _glicemia_pre			= 0;
let _excl_recargo			= 0;
let _dep_glicemia			= 0;
let _indivi_colec			= 0;
let _cia_ind_col			= 0;
let _dep_tiempo3			= 0;
let _dep_tiempo2			= 0;
let _dep_tiempo1			= 0;
let _acido_urico			= 0;
let _completado				= 0;
let _urinalisis				= 0;
let _hemograma				= 0;
let _tipo_ramo				= 0;
let _procesado				= 0;
let _escaneado				= 0;
let _identidad				= 0;
let _decicion				= 0;
let _glicemia				= 0;
let _tiempo1				= 0;
let _tiempo2				= 0;
let _tiempo3				= 0;
let _bo_ok					= 0;
let _grupo					= 0;
let _basal					= 0;
let _edad					= 0;
let _maximo_vitalicio		= 0.00;
let _dep_excl_fumador		= 0.00;
let _suma_asegurada			= 0.00;
let _dep_creatinina			= 0.00;
let _monto_recibo2			= 0.00;
let _dep_excl_peso			= 0.00;
let _excl_fumador			= 0.00;
let _dep_peso_lb			= 0.00;
let _dep_peso_kg			= 0.00;
let _creatinina				= 0.00;
let _dep_talla				= 0.00;
let _excl_peso				= 0.00;
let _cumulo_vi				= 0.00;
let _peso_lb				= 0.00;
let _peso_kg				= 0.00;
let _dep_imc				= 0.00;
let _dep_psa				= 0.00;
let _talla					= 0.00;
let _monto					= 0.00;
let _imc					= 0.00;
let _psa					= 0.00;
let _dep_fecha_obs_eval		= '01/01/1900';
let _dep_fecha_obs_med		= '01/01/1900';
let _fecha_nacimiento		= '01/01/1900';
let _fecha_completado		= '01/01/1900';
let _fecha_obs_eval			= '01/01/1900';
let _dep_fecha_eval			= '01/01/1900';
let _fecha_obs_med			= '01/01/1900';
let _date_changed			= '01/01/1900';
let _fecha_recibo			= '01/01/1900';
let _fecha_escan			= '01/01/1900';
let _fecha_eval				= '01/01/1900';
let _dep_fecha				= '01/01/1900';
let _vig_ini				= '01/01/1900';
let _fecha					= '01/01/1900';
let _dep_hora_obs_eval		= current;
let _dep_hora_obs_med		= current;
let _hora_obs_eval			= current;
let _hora_obs_med			= current;



set isolation to dirty read;
foreach
  select no_evaluacion,   
         fecha,   
         no_recibo,   
         nombre,   
         tipo_ramo,   
         indivi_colec,   
         cant_registros,   
         monto,   
         user_added,   
         date_changed,   
         procesado,   
         escaneado,   
         completado,   
         bo_ok,   
         fecha_escan,   
         user_escan,   
         grupo,   
         cod_asegurado,   
         identidad,   
         fecha_nacimiento,   
         edad,   
         sexo,   
         peso_lb,   
         peso_kg,   
         talla,   
         imc,   
         nacionalidad,   
         pais_reside,   
         tarjeta_credito,   
         fecha_recibo,   
         conoce_cliente,   
         nombre_ejecutivo,   
         nombre_corredor,   
         email_contacto,   
         tipo_evaluacion,   
         plan,   
         maximo_vitalicio,   
         basal,   
         hemograma,   
         urinalisis,   
         glicemia,   
         hemoglobina_g,   
         glicemia_pre,   
         trigliceridos,   
         colesterol_total,   
         colesterol_hdl,   
         colesterol_ldl,   
         acido_urico,   
         requisitos_adic,   
         requisitos_obs,   
         fecha_obs_eval,   
         hora_obs_eval,   
         obs_eval,   
         fecha_obs_med,   
         hora_obs_med,   
         obs_med,   
         fecha_eval,   
         usuario_med,   
         excl_recargo,   
         excl_peso,   
         excl_fumador,   
         decicion,   
         obs_especiales,   
         presion_arterial,   
         identidad_otro,   
         usuario_eval,   
         hiv,   
         glicemia_post,   
         cod_agente,   
         hemograma_desc,   
         urinalisis_desc,   
         nicotina,   
         rx_torax,   
         prueba_esfuerzo,   
         ekg,   
         psa,   
         creatinina,   
         otro,   
         suma_asegurada,   
         claves,   
         cod_perpago,   
         no_recibo2,   
         monto_recibo2,   
         exclusion1,   
         exclusion2,   
         exclusion3,   
         tiempo1,   
         tiempo2,   
         tiempo3,   
         declina_asegurado,   
         cumulo_vi,   
         cod_sucursal,   
         cod_contratante,   
         comentario,   
         eval_original,   
         fecha_completado,   
         cod_subramo,   
         doble_cobertura,   
         cod_coasegur,   
         vig_ini,   
         cia_ind_col
    into _no_evaluacion,   
		 _fecha,   
		 _no_recibo,   
		 _nombre,   
		 _tipo_ramo,   
		 _indivi_colec,   
		 _cant_registros,   
		 _monto,   
		 _user_added,   
		 _date_changed,   
		 _procesado,   
		 _escaneado,   
		 _completado,   
		 _bo_ok,   
		 _fecha_escan,   
		 _user_escan,   
		 _grupo,   
		 _cod_asegurado,   
		 _identidad,   
		 _fecha_nacimiento,   
		 _edad,   
		 _sexo,   
		 _peso_lb,   
		 _peso_kg,   
		 _talla,   
		 _imc,   
		 _nacionalidad,   
		 _pais_reside,   
		 _tarjeta_credito,   
		 _fecha_recibo,   
		 _conoce_cliente,   
		 _nombre_ejecutivo,   
		 _nombre_corredor,   
		 _email_contacto,   
		 _tipo_evaluacion,   
		 _plan,   
		 _maximo_vitalicio,   
		 _basal,   
		 _hemograma,   
		 _urinalisis,   
		 _glicemia,   
		 _hemoglobina_g,   
		 _glicemia_pre,   
		 _trigliceridos,   
		 _colesterol_total,   
		 _colesterol_hdl,   
		 _colesterol_ldl,   
		 _acido_urico,   
		 _requisitos_adic,   
		 _requisitos_obs,   
		 _fecha_obs_eval,   
		 _hora_obs_eval,   
		 _obs_eval,   
		 _fecha_obs_med,   
		 _hora_obs_med,   
		 _obs_med,   
		 _fecha_eval,   
		 _usuario_med,   
		 _excl_recargo,   
		 _excl_peso,   
		 _excl_fumador,   
		 _decicion,   
		 _obs_especiales,   
		 _presion_arterial,   
		 _identidad_otro,   
		 _usuario_eval,   
		 _hiv,   
		 _glicemia_post,   
		 _cod_agente,   
		 _hemograma_desc,   
		 _urinalisis_desc,   
		 _nicotina,   
		 _rx_torax,   
		 _prueba_esfuerzo,   
		 _ekg,   
		 _psa,   
		 _creatinina,   
		 _otro,   
		 _suma_asegurada,   
		 _claves,   
		 _cod_perpago,   
		 _no_recibo2,   
		 _monto_recibo2,   
		 _exclusion1,   
		 _exclusion2,   
		 _exclusion3,   
		 _tiempo1,   
		 _tiempo2,   
		 _tiempo3,   
		 _declina_asegurado,   
		 _cumulo_vi,   
		 _cod_sucursal,   
		 _cod_contratante,   
		 _comentario,   
		 _eval_original,   
		 _fecha_completado,   
		 _cod_subramo,   
		 _doble_cobertura,   
		 _cod_coasegur,   
		 _vig_ini,   
		 _cia_ind_col
    from emievalu 
   where no_evaluacion = a_no_eval     	   		      

	if _tipo_ramo = 1 then
		let _tipo_ramo_t = "Salud";
	end if
	 
	if _tipo_ramo = 2 then
		let _tipo_ramo_t = "Vida";
	end if

	if _tipo_ramo = 3 then
		let _tipo_ramo_t = "Accidentes";
	end if

	if _indivi_colec = 0 then
		let _indivi_colec_t = "Individual";
	end if

	if _indivi_colec = 1 then
		let _indivi_colec_t = "Colectivo";
	end if  

	if _grupo = 1 then
		let _grupo_t = "SI";
	else
		let _grupo_t = "NO";
	end if  

	if _identidad = 0 then
		let _identidad_t = "CIP";
	end if

	if _identidad = 1 then
		let _identidad_t = "PAS";
	end if

	if _identidad = 2 then
		let _identidad_t = "RUC";
	end if

	if _identidad = 3 then
		let _identidad_t = "OTRO";
	end if  

	if _sexo = "F" then
		let _sexo_t = "Femenino";
	else
		let _sexo_t = "Masculino";
	end if  

	if _tipo_evaluacion = 1 then
		let _tipo_evaluacion_t = "Nueva";
	end if 
	 
	if _tipo_evaluacion = 2 then
		let _tipo_evaluacion_t = "Conversion";
	end if  

	if _tipo_evaluacion = 3 then
		let _tipo_evaluacion_t = "Continuidad de Cobertura";
	end if  

	if _tipo_evaluacion = 4 then
		let _tipo_evaluacion_t = "Inclusion Dependiente";
	end if  

	if _tipo_evaluacion = 5 then
		let _tipo_evaluacion_t = "Maternidad Cubierta";
	end if  

	if _tipo_evaluacion = 6 then
		let _tipo_evaluacion_t = "Rehabilitacion";
	end if  

	if _hemograma = 1 then
		let _hemograma_t = "Normal";
	else
		if _hemograma = 2 then
			let _hemograma_t = "Anormal";
		else
			let _hemograma_t = "" ;
		end if  
	end if  

	if _urinalisis = 1 then
		let _urinalisis_t = "Normal";
	else
		if _urinalisis = 2 then
			let _urinalisis_t = "Anormal";
		else
			let _urinalisis_t = "";
		end if  
	end if  

	if _decicion = 0 then
		let _decicion_t = "LIBERAR";
	end if  

	if _decicion = 1 then
		let _decicion_t = "APROBAR" ;
	end if  

	if _decicion = 2 then
		let _decicion_t = "APLAZAR"	;
	end if  

	if _decicion = 3 then
		let _decicion_t = "DECLINA ANCON";
	end if  

	if _decicion = 4 then
		let _decicion_t = "CON RECARGO" ;
	end if 
	 
	if _decicion = 5 then
		let _decicion_t = "CON EXCLUSION" ;
	end if 
	 
	if _decicion = 6 then
		let _decicion_t = "EVALUACION MEDICA";
	end if 
	 
	if _decicion = 7 then
		let _decicion_t = "REQUISITOS ADICIONALES";
	end if  

	if _decicion = 8 then
		let _decicion_t = "DESISTE CLIENTE" ;
	end if  

	if _decicion = 9 then
		let _decicion_t = "CON RECARGO Y EXCL.";
	end if  

	if _decicion = 10 then
		let _decicion_t = "DECLINA ?";
	end if  

	if _decicion = 11 then
		let _decicion_t = "DEVOLVER ASIST. TEC.";
	end if  

	if _tiempo1 = 0 then
		let _tiempo1_t = " ";
	end if  

	if _tiempo1 = 1 then
		let _tiempo1_t = "PERMANENTE";
	end if  

	if _tiempo1 = 2 then
		let _tiempo1_t = "1 AÑO";
	end if 
	 
	if _tiempo1 = 3 then
		let _tiempo1_t = "6 MESES";
	end if 

	if _tiempo2 = 0 then
		let _tiempo2_t = " ";
	end if  

	if _tiempo2 = 1 then
		let _tiempo2_t = "PERMANENTE";
	end if
	  
	if _tiempo2 = 2 then
		let _tiempo2_t = "1 AÑO";
	end if 
	 
	if _tiempo2 = 3 then
		let _tiempo2_t = "6 MESES";
	end if 

	if _tiempo3 = 0 then
		let _tiempo3_t = " ";
	end if  

	if _tiempo3 = 1 then
		let _tiempo3_t = "PERMANENTE";
	end if  

	if _tiempo3 = 2 then
		let _tiempo3_t = "1 AÑO";
	end if  

	if _tiempo3 = 3 then
		let _tiempo3_t = "6 MESES";
	end if 

	if _cia_ind_col = 0 then
		let _cia_ind_col_t = " ";
	end if 
	 
	if _cia_ind_col = 1 then
		let _cia_ind_col_t = "Individual";
	end if  

	if _cia_ind_col = 2 then
		let _cia_ind_col_t = "Colectivo";
	end if  

	select nombre
	into _asegurado
	from cliclien
	where cod_cliente = _cod_asegurado;

 	Return _no_evaluacion,
		   _fecha,
		   _no_recibo,
		   _nombre,
		   _tipo_ramo,
		   _indivi_colec,
		   _cant_registros, 	
		   _monto,
		   _user_added,
		   _date_changed,
		   _procesado,
		   _escaneado,
		   _completado,
		   _bo_ok,
		   _fecha_escan,
		   _user_escan,
		   _grupo,
		   _cod_asegurado,
		   _identidad,
		   _fecha_nacimiento,
		   _edad,
		   _sexo,
		   _peso_lb,
		   _peso_kg,
		   _talla,
		   _imc,
		   _nacionalidad,
		   _pais_reside,
		   _tarjeta_credito,
		   _fecha_recibo,
		   _conoce_cliente,
		   _nombre_ejecutivo,
		   _nombre_corredor,
		   _email_contacto,
		   _tipo_evaluacion,
		   _plan,
		   _maximo_vitalicio,
		   _basal,
		   _hemograma,
		   _urinalisis,
		   _glicemia,
		   _hemoglobina_g,
		   _glicemia_pre,
		   _trigliceridos,
		   _colesterol_total,
		   _colesterol_hdl, 	
		   _colesterol_ldl, 	
		   _acido_urico,
		   _requisitos_adic,
		   _requisitos_obs, 	
		   _fecha_obs_eval, 	
		   _hora_obs_eval,
		   _obs_eval,
		   _fecha_obs_med,
		   _hora_obs_med,
		   _obs_med,
		   _fecha_eval,
		   _usuario_med,
		   _excl_recargo,
		   _excl_peso,
		   _excl_fumador,
		   _decicion,
		   _obs_especiales,
		   _presion_arterial,
		   _identidad_otro, 	
		   _usuario_eval,
		   _hiv,
		   _glicemia_post,
		   _cod_agente,
		   _hemograma_desc,
		   _urinalisis_desc,
		   _nicotina,
		   _rx_torax,
		   _prueba_esfuerzo,
		   _ekg,
		   _psa,
		   _creatinina,
		   _otro,
		   _suma_asegurada,
		   _claves,
		   _cod_perpago,
		   _no_recibo2,
		   _monto_recibo2,
		   _exclusion1,
		   _exclusion2,
		   _exclusion3,
		   _tiempo1,
		   _tiempo2,
		   _tiempo3,
		   _declina_asegurado,
		   _cumulo_vi,
		   _cod_sucursal,
		   _cod_contratante,
		   _comentario,
		   _eval_original,
		   _fecha_completado,
		   _cod_subramo,
		   _doble_cobertura,
		   _cod_coasegur,
		   _vig_ini,
		   _cia_ind_col,
		   _tipo_ramo_t,
		   _indivi_colec_t,
		   _grupo_t,
		   _identidad_t,
		   _sexo_t,
		   _tipo_evaluacion_t,
		   _hemograma_t,
		   _urinalisis_t,
		   _decicion_t,
		   _tiempo1_t,
		   _tiempo2_t,
		   _tiempo3_t,
		   _cia_ind_col_t,
		   _asegurado
		   with resume;			 									
end foreach	 											
end procedure			 						
			 									
			 