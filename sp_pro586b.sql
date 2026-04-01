   DROP procedure sp_pro586b;
   CREATE procedure "informix".sp_pro586b(a_periodo char(7), a_periodo2 char(7), a_origen CHAR(3) DEFAULT '%' );
--------------------------------------------
---  APADEA
---  INFORMACION ESTADISTICA MENSUAL 
---  Armando Moreno M. 21/02/2002
---  Modificado: Amado Perez M. 12/03/2013 -- Se agrega el ramo 022 de equipo pesado a Ramos Tecnicos
---  Ref. Power Builder - d_sp_pro03b
--------------------------------------------
    DEFINE v_cod_ramo,v_cod_subramo,_cod_ramo,_cod_subramo  CHAR(3);
    DEFINE v_desc_ramo        CHAR(50);
    DEFINE v_desc_subramo     CHAR(50);
    DEFINE descr_cia	      CHAR(45);
    DEFINE unidades2          SMALLINT;
    DEFINE _no_poliza,_no_reclamo         CHAR(10);
    DEFINE v_cant_polizas,_cnt_reclamo          INTEGER;
    DEFINE v_prima_suscrita,v_prima_retenida,
           _prima_suscrita,_prima_retenida,v_suma_asegurada,
		   _total_pri_sus,v_incurrido_bruto,
           _salv_y_recup,_pago_y_ded,_var_reserva, _siniestro_pagado, _prima_devengada DECIMAL(16,2);
    DEFINE _tipo,_nueva_renov              CHAR(01);
    DEFINE v_filtros          CHAR(255);
	DEFINE _mes2,_mes,_ano2,_orden   SMALLINT;
	DEFINE _fecha2     	      DATE;
	define _cod_tipoprod	  char(3);
	DEFINE _vigencia_inic, _vig_fin_vida, _vig_ini_end     DATE;
	define _no_endoso         char(5);
	define li_dia,li_mes,li_anio smallint;
	DEFINE _cnt_cerra,_cantidad , _cnt           INTEGER;
	define _cod_origen        CHAR(3);
	DEFINE v_cant_polizas_ma, _cnt_prima_nva, _cnt_prima_ren, _cnt_prima_can, _cnt_pol_dif, _cantidad_aseg, v_cant_asegurados  INTEGER;
	define _reembolso_admin DEC(16,2);

LET v_cod_ramo       = NULL;
LET v_cod_subramo    = NULL;
LET v_desc_subramo   = NULL;
LET v_cant_polizas   = 0;
LET v_prima_suscrita = 0;
LET _prima_suscrita  = 0;
LET _tipo            = NULL;
let _salv_y_recup    = 0;
let _pago_y_ded      = 0;
let _var_reserva     = 0;
let _cnt_cerra       = 0;
LET v_cant_polizas_ma  = 0;
LET _cnt_prima_nva   = 0;
LET _cnt_prima_ren   = 0;
LET _cnt_prima_can   = 0;

SET ISOLATION TO DIRTY READ;

-- Actualizando todo para los ramos: 003, 001, 017, 005, 016, 002, 006 ,015 

FOREACH
   SELECT cod_ramo
     INTO v_cod_ramo
     FROM temp_ramo
	WHERE cod_ramo <> "019"

   SELECT SUM(cant_polizas),
          SUM(cant_polizas_ma),
		  SUM(cant_asegurados)
     INTO v_cant_polizas,
	      v_cant_polizas_ma,
		  v_cant_asegurados
     FROM temp_perfil1
    WHERE cod_ramo = v_cod_ramo;
  
   SELECT SUM(prima_suscrita),
          SUM(cnt_pol_nuevas),
		  SUM(cnt_pol_ren),
		  SUM(cnt_pol_can_cad),
		  SUM(reembolso_admin)
     INTO _prima_suscrita,
	      _cnt_prima_nva,
		  _cnt_prima_ren,
		  _cnt_prima_can,
		  _reembolso_admin
     FROM temp_perfil2
    WHERE cod_ramo    = v_cod_ramo;

	SELECT SUM(incurrido_bruto),
	       SUM(salv_y_recup),
		   SUM(pago_y_ded),
		   SUM(var_reserva),
		   SUM(siniestro_pagado)
	   INTO	v_incurrido_bruto,
	        _salv_y_recup,
			_pago_y_ded,
			_var_reserva,
			_siniestro_pagado
	   FROM	tmp_siniest
	  WHERE seleccionado = 1
	    AND cod_ramo     = v_cod_ramo;

	SELECT SUM(prima_devengada)
	   INTO	_prima_devengada
	   FROM	tmp_prima_devengada
	  WHERE cod_ramo     = v_cod_ramo;
		
	SELECT COUNT(no_reclamo)
	   INTO	_cnt_reclamo
	   FROM	tmp_sinis
	  WHERE cod_ramo     = v_cod_ramo
	    and seleccionado = 1;

	IF _prima_suscrita IS NULL THEN
		LET _prima_suscrita = 0;
	END IF
	IF _reembolso_admin IS NULL THEN
		LET _reembolso_admin = 0;
	END IF
	IF _cnt_reclamo IS NULL THEN
		LET _cnt_reclamo = 0;
	END IF
	IF v_incurrido_bruto IS NULL THEN
		LET v_incurrido_bruto = 0;
	END IF
	IF _salv_y_recup IS NULL THEN
		LET _salv_y_recup = 0;
	END IF
	IF _pago_y_ded IS NULL THEN
		LET _pago_y_ded = 0;
	END IF
	IF _var_reserva IS NULL THEN
		LET _var_reserva = 0;
	END IF
	IF v_cant_polizas IS NULL THEN
		LET v_cant_polizas = 0;
	END IF		 
	IF v_cant_polizas_ma IS NULL THEN
		LET v_cant_polizas_ma = 0;
	END IF		 
	IF _cnt_prima_nva IS NULL THEN
	  	LET _cnt_prima_nva = 0;
	END IF		 
	IF _cnt_prima_ren IS NULL THEN
	  	LET _cnt_prima_ren = 0;
	END IF		 
	IF _cnt_prima_can IS NULL THEN
	  	LET _cnt_prima_can = 0;
	END IF		
	IF v_cant_asegurados IS NULL THEN
		LET v_cant_asegurados = 0;
	END IF		 
	IF _siniestro_pagado IS NULL THEN
		LET _siniestro_pagado = 0;
	END IF
	IF _prima_devengada IS NULL THEN
		LET _prima_devengada = 0;
	END IF

    IF v_cod_ramo = "003" THEN

	   SELECT SUM(cant_polizas),
              SUM(cant_polizas_ma),
			  SUM(cant_asegurados)
	     INTO v_cant_polizas,
		      v_cant_polizas_ma,
			  v_cant_asegurados
	     FROM temp_perfil1
	    WHERE cod_ramo    = v_cod_ramo
	      AND cod_subramo = "001";

	   SELECT SUM(prima_suscrita),
			  SUM(cnt_pol_nuevas),
			  SUM(cnt_pol_ren),
			  SUM(cnt_pol_can_cad),
		      SUM(reembolso_admin)
	     INTO _prima_suscrita,
			  _cnt_prima_nva,
			  _cnt_prima_ren,
			  _cnt_prima_can,
			  _reembolso_admin
	     FROM temp_perfil2
	    WHERE cod_ramo    = v_cod_ramo
	      AND cod_subramo = "001";

		  IF _prima_suscrita IS NULL THEN
		  	LET _prima_suscrita = 0;
		  END IF

		  IF _reembolso_admin IS NULL THEN
			LET _reembolso_admin = 0;
		  END IF
	
		  IF v_cant_polizas IS NULL THEN
		  	LET v_cant_polizas = 0;
		  END IF	
		  
		  IF v_cant_polizas_ma IS NULL THEN
			LET v_cant_polizas_ma = 0;
		  END IF		 

		IF v_cant_asegurados IS NULL THEN
			LET v_cant_asegurados = 0;
		END IF		
	
		IF _cnt_prima_nva IS NULL THEN
			LET _cnt_prima_nva = 0;
		END IF		 
		IF _cnt_prima_ren IS NULL THEN
			LET _cnt_prima_ren = 0;
		END IF		 
		IF _cnt_prima_can IS NULL THEN
			LET _cnt_prima_can = 0;
		END IF		 
	
	   UPDATE canaldist_super
          SET cnt_polizas  = v_cant_polizas,
	   		  prima_suscrita = _prima_suscrita,
			  poblacion_aseg   = v_cant_asegurados,
			  reembolso_admin = _reembolso_admin
        WHERE cod_ramo     = v_cod_ramo
          AND cod_subramo  = "001";

	   SELECT SUM(cant_polizas),
              SUM(cant_polizas_ma),
              SUM(cant_asegurados)			  
	     INTO v_cant_polizas,
		      v_cant_polizas_ma,
			  v_cant_asegurados
	     FROM temp_perfil1
	    WHERE cod_ramo    = v_cod_ramo
	      AND cod_subramo <> "001";

	   SELECT SUM(prima_suscrita),
			  SUM(cnt_pol_nuevas),
			  SUM(cnt_pol_ren),
			  SUM(cnt_pol_can_cad),
			  SUM(reembolso_admin)
	     INTO _prima_suscrita,
			  _cnt_prima_nva,
			  _cnt_prima_ren,
			  _cnt_prima_can,
			  _reembolso_admin
	     FROM temp_perfil2
	    WHERE cod_ramo    = v_cod_ramo
	      AND cod_subramo <> "001";

	    IF _prima_suscrita IS NULL THEN
			LET _prima_suscrita = 0;
		END IF

		IF _reembolso_admin IS NULL THEN
			LET _reembolso_admin = 0;
		END IF
		  
		IF v_cant_polizas IS NULL THEN
			LET v_cant_polizas = 0;
		END IF		
		
		IF v_cant_polizas_ma IS NULL THEN
			LET v_cant_polizas_ma = 0;
		END IF		 
		IF v_cant_asegurados IS NULL THEN
			LET v_cant_asegurados = 0;
		END IF		
		IF _cnt_prima_nva IS NULL THEN
			LET _cnt_prima_nva = 0;
		END IF		 
		IF _cnt_prima_ren IS NULL THEN
			LET _cnt_prima_ren = 0;
		END IF		 
		IF _cnt_prima_can IS NULL THEN
			LET _cnt_prima_can = 0;
		END IF		 

	   UPDATE canaldist_super
          SET cnt_polizas  = v_cant_polizas,
	   		  prima_suscrita = _prima_suscrita,
			  poblacion_aseg   = v_cant_asegurados,
			  reembolso_admin = _reembolso_admin
        WHERE cod_ramo     = v_cod_ramo
          AND cod_subramo  = "002";

	END IF
    IF v_cod_ramo = "001" THEN -- Verificar creaciones de nuevos subramos

	   SELECT SUM(cant_polizas),
              SUM(cant_polizas_ma),
              SUM(cant_asegurados)			  
	     INTO v_cant_polizas,
		      v_cant_polizas_ma,
			  v_cant_asegurados
	     FROM temp_perfil1
	    WHERE cod_ramo    = v_cod_ramo
	      AND cod_subramo = "001";

	   SELECT SUM(prima_suscrita),
			  SUM(cnt_pol_nuevas),
			  SUM(cnt_pol_ren),
			  SUM(cnt_pol_can_cad),
			  SUM(reembolso_admin)
	     INTO _prima_suscrita,
			  _cnt_prima_nva,
			  _cnt_prima_ren,
			  _cnt_prima_can,
			  _reembolso_admin
	     FROM temp_perfil2
	    WHERE cod_ramo    = v_cod_ramo
	      AND cod_subramo = "001";

		  IF _prima_suscrita IS NULL THEN
		  	LET _prima_suscrita = 0;
		  END IF

		  IF _reembolso_admin IS NULL THEN
		  	LET _reembolso_admin = 0;
		  END IF
		  
		  IF v_cant_polizas IS NULL THEN
		  	LET v_cant_polizas = 0;
		  END IF		 

		  IF v_cant_polizas_ma IS NULL THEN
			LET v_cant_polizas_ma = 0;
		  END IF		 
		IF _cnt_prima_nva IS NULL THEN
			LET _cnt_prima_nva = 0;
		END IF		 
		IF _cnt_prima_ren IS NULL THEN
			LET _cnt_prima_ren = 0;
		END IF		 
		IF _cnt_prima_can IS NULL THEN
			LET _cnt_prima_can = 0;
		END IF		 
		IF v_cant_asegurados IS NULL THEN
			LET v_cant_asegurados = 0;
		END IF		
		  
	   UPDATE canaldist_super
          SET cnt_polizas  = v_cant_polizas,
	   		  prima_suscrita = _prima_suscrita,
			  poblacion_aseg   = v_cant_asegurados,
			  reembolso_admin = _reembolso_admin
        WHERE cod_ramo     = v_cod_ramo
          AND cod_subramo  = "001";

	   SELECT SUM(cant_polizas),
              SUM(cant_polizas_ma),
              SUM(cant_asegurados)			  
	     INTO v_cant_polizas,
		      v_cant_polizas_ma,
              v_cant_asegurados			  
	     FROM temp_perfil1
	    WHERE cod_ramo    = v_cod_ramo
	      AND cod_subramo = "002";

	   SELECT SUM(prima_suscrita),
			  SUM(cnt_pol_nuevas),
			  SUM(cnt_pol_ren),
			  SUM(cnt_pol_can_cad),
			  SUM(reembolso_admin)
	     INTO _prima_suscrita,
			  _cnt_prima_nva,
			  _cnt_prima_ren,
			  _cnt_prima_can,
			  _reembolso_admin
	     FROM temp_perfil2
	    WHERE cod_ramo    = v_cod_ramo
	      AND cod_subramo = "002";

		  IF _prima_suscrita IS NULL THEN
		  	LET _prima_suscrita = 0;
		  END IF

		  IF _reembolso_admin IS NULL THEN
		  	LET _reembolso_admin = 0;
		  END IF
		  
		  IF v_cant_polizas IS NULL THEN
		  	LET v_cant_polizas = 0;
		  END IF		 

		  IF v_cant_polizas_ma IS NULL THEN
			LET v_cant_polizas_ma = 0;
		  END IF		
		  
		IF v_cant_asegurados IS NULL THEN
			LET v_cant_asegurados = 0;
		END IF		
		IF _cnt_prima_nva IS NULL THEN
			LET _cnt_prima_nva = 0;
		END IF		 
		IF _cnt_prima_ren IS NULL THEN
			LET _cnt_prima_ren = 0;
		END IF		 
		IF _cnt_prima_can IS NULL THEN
			LET _cnt_prima_can = 0;
		END IF		 
		  
	   UPDATE canaldist_super
          SET cnt_polizas  = v_cant_polizas,
	   		  prima_suscrita = _prima_suscrita,
			  poblacion_aseg   = v_cant_asegurados,
			  reembolso_admin = _reembolso_admin
        WHERE cod_ramo     = v_cod_ramo
          AND cod_subramo  = "002";
		  
	   SELECT SUM(cant_polizas),
              SUM(cant_polizas_ma),
              SUM(cant_asegurados)			  
	     INTO v_cant_polizas,
		      v_cant_polizas_ma,
              v_cant_asegurados			  
	     FROM temp_perfil1
	    WHERE cod_ramo    = v_cod_ramo
	      AND cod_subramo in("003","004","006","007");

	   SELECT SUM(prima_suscrita),
			  SUM(cnt_pol_nuevas),
			  SUM(cnt_pol_ren),
			  SUM(cnt_pol_can_cad),
			  SUM(reembolso_admin)
	     INTO _prima_suscrita,
			  _cnt_prima_nva,
			  _cnt_prima_ren,
			  _cnt_prima_can,
			  _reembolso_admin
	     FROM temp_perfil2
	    WHERE cod_ramo    = v_cod_ramo
	      AND cod_subramo in("003","004","006","007");

		  IF _prima_suscrita IS NULL THEN
		  	LET _prima_suscrita = 0;
		  END IF

		  IF _reembolso_admin IS NULL THEN
		  	LET _reembolso_admin = 0;
		  END IF
		  
		  IF v_cant_polizas IS NULL THEN
		  	LET v_cant_polizas = 0;
		  END IF		 

		  IF v_cant_polizas_ma IS NULL THEN
			LET v_cant_polizas_ma = 0;
		  END IF		 
		IF v_cant_asegurados IS NULL THEN
			LET v_cant_asegurados = 0;
		END IF		
		IF _cnt_prima_nva IS NULL THEN
			LET _cnt_prima_nva = 0;
		END IF		 
		IF _cnt_prima_ren IS NULL THEN
			LET _cnt_prima_ren = 0;
		END IF		 
		IF _cnt_prima_can IS NULL THEN
			LET _cnt_prima_can = 0;
		END IF		 
		  
	   UPDATE canaldist_super
          SET cnt_polizas  = v_cant_polizas,
	   		  prima_suscrita = _prima_suscrita,
			  poblacion_aseg   = v_cant_asegurados,
			  reembolso_admin = _reembolso_admin
        WHERE cod_ramo      = v_cod_ramo
          AND cod_subramo   = "003";
	END IF
	IF v_cod_ramo = "017" THEN

	   SELECT SUM(cant_polizas),
              SUM(cant_polizas_ma),
              SUM(cant_asegurados)			  
	     INTO v_cant_polizas,
		      v_cant_polizas_ma,
              v_cant_asegurados			  
	     FROM temp_perfil1
	    WHERE cod_ramo    = v_cod_ramo
	      AND cod_subramo = "001";

	   SELECT SUM(prima_suscrita),
			  SUM(cnt_pol_nuevas),
			  SUM(cnt_pol_ren),
			  SUM(cnt_pol_can_cad),
			  SUM(reembolso_admin)
	     INTO _prima_suscrita,
			  _cnt_prima_nva,
			  _cnt_prima_ren,
			  _cnt_prima_can,
			  _reembolso_admin
	     FROM temp_perfil2
	    WHERE cod_ramo    = v_cod_ramo
	      AND cod_subramo = "001";

	  IF _prima_suscrita IS NULL THEN
		LET _prima_suscrita = 0;
	  END IF

	  IF _reembolso_admin IS NULL THEN
		LET _reembolso_admin = 0;
	  END IF
	  
	  IF v_cant_polizas IS NULL THEN
	  	LET v_cant_polizas = 0;
	  END IF		 

	  IF v_cant_polizas_ma IS NULL THEN
		LET v_cant_polizas_ma = 0;
	  END IF		 
		IF v_cant_asegurados IS NULL THEN
			LET v_cant_asegurados = 0;
		END IF		
		IF _cnt_prima_nva IS NULL THEN
			LET _cnt_prima_nva = 0;
		END IF		 
		IF _cnt_prima_ren IS NULL THEN
			LET _cnt_prima_ren = 0;
		END IF		 
		IF _cnt_prima_can IS NULL THEN
			LET _cnt_prima_can = 0;
		END IF		 
	  
	   UPDATE canaldist_super
           SET cnt_polizas  = v_cant_polizas,
	   		  prima_suscrita = _prima_suscrita,
			  poblacion_aseg   = v_cant_asegurados,
			  reembolso_admin = _reembolso_admin
        WHERE cod_ramo     = v_cod_ramo
          AND cod_subramo  = "001";

	   SELECT SUM(cant_polizas),
              SUM(cant_polizas_ma),
              SUM(cant_asegurados)			  
	     INTO v_cant_polizas,
		      v_cant_polizas_ma,
              v_cant_asegurados			  
	     FROM temp_perfil1
	    WHERE cod_ramo    = v_cod_ramo
	      AND cod_subramo = "002";

	   SELECT SUM(prima_suscrita),
			  SUM(cnt_pol_nuevas),
			  SUM(cnt_pol_ren),
			  SUM(cnt_pol_can_cad),
			  SUM(reembolso_admin)
	     INTO _prima_suscrita,
			  _cnt_prima_nva,
			  _cnt_prima_ren,
			  _cnt_prima_can,
			  _reembolso_admin
	     FROM temp_perfil2
	    WHERE cod_ramo    = v_cod_ramo
	      AND cod_subramo = "002";

	  IF _prima_suscrita IS NULL THEN
	  	LET _prima_suscrita = 0;
	  END IF

	  IF _reembolso_admin IS NULL THEN
	  	LET _reembolso_admin = 0;
	  END IF
	  
	  IF v_cant_polizas IS NULL THEN
	  	LET v_cant_polizas = 0;
	  END IF		 

	  IF v_cant_polizas_ma IS NULL THEN
		LET v_cant_polizas_ma = 0;
	  END IF		 
		IF v_cant_asegurados IS NULL THEN
			LET v_cant_asegurados = 0;
		END IF		
		IF _cnt_prima_nva IS NULL THEN
			LET _cnt_prima_nva = 0;
		END IF		 
		IF _cnt_prima_ren IS NULL THEN
			LET _cnt_prima_ren = 0;
		END IF		 
		IF _cnt_prima_can IS NULL THEN
			LET _cnt_prima_can = 0;
		END IF		 
	  
	   UPDATE canaldist_super
           SET cnt_polizas  = v_cant_polizas,
	   		  prima_suscrita = _prima_suscrita,
			  poblacion_aseg   = v_cant_asegurados,
			  reembolso_admin = _reembolso_admin
        WHERE cod_ramo     = v_cod_ramo
          AND cod_subramo  = "002";

	END IF
	IF v_cod_ramo = "005" THEN
	   SELECT SUM(cant_polizas),
              SUM(cant_polizas_ma),
              SUM(cant_asegurados)			  
	     INTO v_cant_polizas,
		      v_cant_polizas_ma,
              v_cant_asegurados			  
	     FROM temp_perfil1
	    WHERE cod_ramo    = v_cod_ramo
	      AND cod_subramo = "001";

	   SELECT SUM(prima_suscrita),
			  SUM(cnt_pol_nuevas),
			  SUM(cnt_pol_ren),
			  SUM(cnt_pol_can_cad),
			  SUM(reembolso_admin)
	     INTO _prima_suscrita,
			  _cnt_prima_nva,
			  _cnt_prima_ren,
			  _cnt_prima_can,
			  _reembolso_admin
	     FROM temp_perfil2
	    WHERE cod_ramo    = v_cod_ramo
	      AND cod_subramo = "001";

	  IF _prima_suscrita IS NULL THEN
	  	LET _prima_suscrita = 0;
	  END IF

	  IF _reembolso_admin IS NULL THEN
	  	LET _reembolso_admin = 0;
	  END IF
	  
	  IF v_cant_polizas IS NULL THEN
	  	LET v_cant_polizas = 0;
	  END IF		 

	  IF v_cant_polizas_ma IS NULL THEN
		LET v_cant_polizas_ma = 0;
	  END IF	
		IF v_cant_asegurados IS NULL THEN
			LET v_cant_asegurados = 0;
		END IF		
		IF _cnt_prima_nva IS NULL THEN
			LET _cnt_prima_nva = 0;
		END IF		 
		IF _cnt_prima_ren IS NULL THEN
			LET _cnt_prima_ren = 0;
		END IF		 
		IF _cnt_prima_can IS NULL THEN
			LET _cnt_prima_can = 0;
		END IF		 
	  
	   UPDATE canaldist_super
          SET cnt_polizas  = v_cant_polizas,
	   		  prima_suscrita = _prima_suscrita,
			  poblacion_aseg   = v_cant_asegurados,
			  reembolso_admin = _reembolso_admin
        WHERE cod_ramo     = v_cod_ramo
          AND cod_subramo  = "001";
   END IF
   	
   
   IF v_cod_ramo = "016" THEN
     UPDATE canaldist_super
        SET cnt_polizas  = v_cant_polizas,
			prima_suscrita = _prima_suscrita,
     	    siniestro_pagado = siniestro_pagado + _siniestro_pagado,
			poblacion_aseg  = v_cant_asegurados,
			prima_devengada = prima_devengada + _prima_devengada,
			reembolso_admin = _reembolso_admin
      WHERE cod_ramo     = v_cod_ramo
        AND cod_subramo  = "001";
   ELIF	v_cod_ramo = "002" THEN
     UPDATE canaldist_super
        SET cnt_polizas  = v_cant_polizas,
     	    prima_suscrita = _prima_suscrita,
     	    siniestro_pagado = siniestro_pagado + _siniestro_pagado,
			poblacion_aseg  = v_cant_asegurados,
			prima_devengada = prima_devengada + _prima_devengada,
			reembolso_admin = _reembolso_admin
      WHERE cod_ramo     = v_cod_ramo
        AND cod_subramo  = "001";
   ELIF	v_cod_ramo = "006" THEN
     UPDATE canaldist_super
        SET cnt_polizas  = v_cant_polizas,
     	    prima_suscrita = _prima_suscrita,
     	    siniestro_pagado = siniestro_pagado + _siniestro_pagado,
			poblacion_aseg  = v_cant_asegurados,
			prima_devengada = prima_devengada + _prima_devengada,
			reembolso_admin = _reembolso_admin
      WHERE cod_ramo     = v_cod_ramo
        AND cod_subramo  = "001";
   ELIF	v_cod_ramo = "015" THEN
     UPDATE canaldist_super
        SET cnt_polizas  = v_cant_polizas,
     	    prima_suscrita = _prima_suscrita,
     	    siniestro_pagado = siniestro_pagado + _siniestro_pagado,
			poblacion_aseg  = v_cant_asegurados,
			prima_devengada = prima_devengada + _prima_devengada,
			reembolso_admin = _reembolso_admin
      WHERE cod_ramo        = v_cod_ramo
        AND cod_subramo     = "001";
   END IF
END FOREACH


END PROCEDURE;