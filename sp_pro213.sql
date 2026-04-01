-- Procedimiento que Realiza el cambio de un dependiente a Asegurado principal
-- Modulo de eavluacion

-- Creado    : 11/07/2011 - Autor: Armando Moreno M.

drop procedure sp_pro213;

create procedure "informix".sp_pro213(a_eval char(10), a_principal char(10), a_anterior char(10), a_paren char(3))
RETURNING   INTEGER;

define _hemograma		  smallint;
define _urinalisis		  smallint;
define _psa				  decimal(16,2);
define _glicemia		  smallint;
define _hemoglobina_g	  smallint;
define _glicemia_pre	  smallint;
define _trigliceridos	  smallint;
define _nicotina		  char(20);
define _colesterol_total  smallint;
define _colesterol_hdl	  smallint;
define _colesterol_ldl	  smallint;
define _acido_urico 	  smallint;
define _creatinina 		  decimal(16,2)	;
define _otro			  varchar(100,0);
define _requisitos_adic	  smallint;
define _requisitos_obs	  varchar(255);
define _fecha_obs_eval	  date;
define _hora_obs_eval	  datetime hour to fraction(5);
define _obs_eval		  varchar(255);
define _fecha_obs_med	  date;
define _hora_obs_med	  datetime hour to fraction(5);
define _obs_med			  varchar(255);
define _fecha_eval		  datetime year to fraction(5);
define _peso_lb			  decimal(16,2);
define _peso_kg			  decimal(16,2);
define _talla			  decimal(16,2);
define _imc				  decimal(16,2);
define _tipo_evaluacion	  smallint;	   
define _excl_recargo	  smallint;
define _excl_peso		  decimal(16,2);
define _excl_fumador	  decimal(16,2);
define _obs_especiales	  varchar(255);
define _hemograma_desc	  varchar(100,0);
define _urinalisis_desc	  varchar(100,0);
define _glicemia_post	  smallint;
define _hiv				  varchar(25,0);
define _rx_torax		  varchar(100,0);
define _ekg				  varchar(100,0);
define _prueba_esfuerzo	  varchar(100,0);
define _presion_arterial  char(10);
define _declinacion_obs	  varchar(255);
define _exclusion1		  char(5);
define _exclusion2		  char(5);
define _exclusion3		  char(5);
define _tiempo1			  smallint;
define _tiempo2			  smallint;
define _tiempo3			  smallint;
define _sexo              char(1);
define _error             integer;
define _fecha_nacimiento  date;
define _nombre            varchar(100);
define _cedula            char(20);
define _edad              integer;

--SET DEBUG FILE TO "sp_pro213.trc"; 
--trace on;

BEGIN

ON EXCEPTION SET _error 
 	RETURN _error;         
END EXCEPTION

set isolation to dirty read;
--SET LOCK MODE TO WAIT;

select * 
  from emievalu
 where no_evaluacion = a_eval
  into temp prueba;

select hemograma,		
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
	   peso_lb,
	   peso_kg,
	   talla,
	   imc,		
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
	   exclusion1,
	   exclusion2,
	   exclusion3,
	   tiempo1,
	   tiempo2,
	   tiempo3
  into _hemograma,		
	   _urinalisis,		
	   _psa,
	   _glicemia,		
	   _hemoglobina_g,
	   _glicemia_pre,
	   _trigliceridos,
	   _nicotina,
	   _colesterol_total,
	   _colesterol_hdl,
	   _colesterol_ldl,
	   _acido_urico, 	
	   _creatinina, 		
	   _otro,
	   _requisitos_adic,
	   _requisitos_obs,
	   _fecha_obs_eval,
	   _hora_obs_eval,
	   _obs_eval,
	   _fecha_obs_med,
	   _hora_obs_med,
	   _obs_med,
	   _fecha_eval,
	   _peso_lb,
	   _peso_kg,
	   _talla,
	   _imc,		
	   _excl_recargo,
	   _excl_peso,
	   _excl_fumador,
	   _obs_especiales,
	   _hemograma_desc,
	   _urinalisis_desc,
	   _glicemia_post,
	   _hiv,
	   _rx_torax,
	   _ekg,
	   _prueba_esfuerzo,
	   _presion_arterial,
	   _declinacion_obs,
	   _exclusion1,
	   _exclusion2,
	   _exclusion3,
	   _tiempo1,
	   _tiempo2,
	   _tiempo3
  from emievade
 where no_evaluacion = a_eval
   and cod_asegurado = a_principal;

  select fecha_aniversario,sexo,nombre,cedula
    into _fecha_nacimiento,_sexo,_nombre,_cedula
	from cliclien
   where cod_cliente = a_principal;

   let _edad = sp_sis78(_fecha_nacimiento);

  update emievalu
     set cod_asegurado    = a_principal,
		 cod_contratante  = a_principal,
		 hemograma		  =	_hemograma,		
		 urinalisis		  =	_urinalisis,		
		 psa			  =	_psa,
		 glicemia		  =	_glicemia,		
		 hemoglobina_g	  =	_hemoglobina_g,
		 glicemia_pre	  =	_glicemia_pre,
		 trigliceridos	  =	_trigliceridos,
		 nicotina		  =	_nicotina,
		 colesterol_total =	_colesterol_total,
		 colesterol_hdl	  =	_colesterol_hdl,
		 colesterol_ldl	  =	_colesterol_ldl,
		 acido_urico 	  =	_acido_urico, 	
		 creatinina 	  =	_creatinina, 		
		 otro			  =	_otro,
		 requisitos_adic  =	_requisitos_adic,
		 requisitos_obs	  =	_requisitos_obs,
		 fecha_obs_eval	  =	_fecha_obs_eval,
		 hora_obs_eval	  =	_hora_obs_eval,
		 obs_eval		  =	_obs_eval,
		 fecha_obs_med	  =	_fecha_obs_med,
		 hora_obs_med	  =	_hora_obs_med,
		 obs_med		  =	_obs_med,
		 fecha_eval		  =	_fecha_eval,
		 peso_lb		  =	_peso_lb,
		 peso_kg		  =	_peso_kg,
		 talla			  =	_talla,
		 imc			  =	_imc,		
		 excl_recargo	  =	_excl_recargo,
		 excl_peso		  =	_excl_peso,
		 excl_fumador	  =	_excl_fumador,
		 obs_especiales	  =	_obs_especiales,
		 hemograma_desc	  =	_hemograma_desc,
		 urinalisis_desc  =	_urinalisis_desc,
		 glicemia_post	  =	_glicemia_post,
		 hiv			  =	_hiv,
		 rx_torax		  =	_rx_torax,
		 ekg			  =	_ekg,
		 prueba_esfuerzo  =	_prueba_esfuerzo,
		 presion_arterial =	_presion_arterial,
		 declinacion_obs  =	_declinacion_obs,
		 exclusion1		  =	_exclusion1,
		 exclusion2		  =	_exclusion2,
		 exclusion3		  =	_exclusion3,
		 tiempo1		  =	_tiempo1,
		 tiempo2		  =	_tiempo2,
		 tiempo3		  =	_tiempo3,
		 fecha_nacimiento = _fecha_nacimiento,
		 sexo             = _sexo,
		 nombre           = _nombre,
		 edad			  = _edad,
		 identidad_otro   = _cedula
   where no_evaluacion    = a_eval;

select hemograma,		
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
	   peso_lb,
	   peso_kg,
	   talla,
	   imc,		
	   tipo_evaluacion,
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
	   exclusion1,
	   exclusion2,
	   exclusion3,
	   tiempo1,
	   tiempo2,
	   tiempo3
  into _hemograma,		
	   _urinalisis,		
	   _psa,
	   _glicemia,		
	   _hemoglobina_g,
	   _glicemia_pre,
	   _trigliceridos,
	   _nicotina,
	   _colesterol_total,
	   _colesterol_hdl,
	   _colesterol_ldl,
	   _acido_urico, 	
	   _creatinina, 		
	   _otro,
	   _requisitos_adic,
	   _requisitos_obs,
	   _fecha_obs_eval,
	   _hora_obs_eval,
	   _obs_eval,
	   _fecha_obs_med,
	   _hora_obs_med,
	   _obs_med,
	   _fecha_eval,
	   _peso_lb,
	   _peso_kg,
	   _talla,
	   _imc,		
	   _tipo_evaluacion,
	   _excl_recargo,
	   _excl_peso,
	   _excl_fumador,
	   _obs_especiales,
	   _hemograma_desc,
	   _urinalisis_desc,
	   _glicemia_post,
	   _hiv,
	   _rx_torax,
	   _ekg,
	   _prueba_esfuerzo,
	   _presion_arterial,
	   _declinacion_obs,
	   _exclusion1,
	   _exclusion2,
	   _exclusion3,
	   _tiempo1,
	   _tiempo2,
	   _tiempo3
  from prueba
 where no_evaluacion = a_eval;

	update emievade
	   set cod_asegurado      = a_anterior,
		   hemograma		  =	_hemograma,		
		   urinalisis		  =	_urinalisis,		
		   psa			  	  =	_psa,
		   glicemia		  	  =	_glicemia,		
		   hemoglobina_g	  =	_hemoglobina_g,
		   glicemia_pre	  	  =	_glicemia_pre,
		   trigliceridos	  =	_trigliceridos,
		   nicotina		  	  =	_nicotina,
		   colesterol_total   =	_colesterol_total,
		   colesterol_hdl	  =	_colesterol_hdl,
		   colesterol_ldl	  =	_colesterol_ldl,
		   acido_urico 	  	  =	_acido_urico, 	
		   creatinina 	  	  =	_creatinina, 		
		   otro			  	  =	_otro,
		   requisitos_adic    =	_requisitos_adic,
		   requisitos_obs	  =	_requisitos_obs,
		   fecha_obs_eval	  =	_fecha_obs_eval,
		   hora_obs_eval	  =	_hora_obs_eval,
		   obs_eval		  	  =	_obs_eval,
		   fecha_obs_med	  =	_fecha_obs_med,
		   hora_obs_med	  	  =	_hora_obs_med,
		   obs_med		  	  =	_obs_med,
		   fecha_eval		  =	_fecha_eval,
		   peso_lb		  	  =	_peso_lb,
		   peso_kg		  	  =	_peso_kg,
		   talla			  =	_talla,
		   imc			  	  =	_imc,		
		   excl_recargo	  	  =	_excl_recargo,
		   excl_peso		  =	_excl_peso,
		   excl_fumador	  	  =	_excl_fumador,
		   obs_especiales	  =	_obs_especiales,
		   hemograma_desc	  =	_hemograma_desc,
		   urinalisis_desc    =	_urinalisis_desc,
		   glicemia_post	  =	_glicemia_post,
		   hiv			  	  =	_hiv,
		   rx_torax		  	  =	_rx_torax,
		   ekg			  	  =	_ekg,
		   prueba_esfuerzo    =	_prueba_esfuerzo,
		   presion_arterial   =	_presion_arterial,
		   declinacion_obs    =	_declinacion_obs,
		   exclusion1		  =	_exclusion1,
		   exclusion2		  =	_exclusion2,
		   exclusion3		  =	_exclusion3,
		   tiempo1		  	  =	_tiempo1,
		   tiempo2		  	  =	_tiempo2,
		   tiempo3		  	  =	_tiempo3,
		   procesado       	  = 0
     where no_evaluacion      = a_eval
       and cod_asegurado      = a_principal;

	 update emievade
	    set cod_parentesco    = a_paren
     where no_evaluacion      = a_eval
       and cod_asegurado      = a_anterior;


drop table prueba;

return 0;
END
end procedure;