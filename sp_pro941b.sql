   DROP procedure sp_pro941b;
   CREATE procedure "informix".sp_pro941b(a_periodo char(7), a_periodo2 char(7), a_origen CHAR(3) DEFAULT '%' );
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
           _salv_y_recup,_pago_y_ded,_var_reserva		   DECIMAL(16,2);
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
	DEFINE v_cant_polizas_ma, _cnt_prima_nva, _cnt_prima_ren, _cnt_prima_can, _cnt_pol_dif, _cantidad_aseg, v_cant_asegurados, _cnt_incurridos  INTEGER;
	define _prima_sus_cor		dec(16,2);
	define _prima_sus_dir		dec(16,2);
	define _prima_sus_can		dec(16,2);

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
LET _cnt_incurridos  = 0;

SET ISOLATION TO DIRTY READ;

-- Actualizando todo para los ramos: 003, 001, 017, 005, 016, 002, 006 ,015 

FOREACH
   SELECT cod_ramo
     INTO v_cod_ramo
     FROM temp_ramo
	WHERE cod_ramo not in  ("019","002")

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
		  SUM(prima_sus_cor),
		  SUM(prima_sus_dir),
		  SUM(prima_sus_can)
     INTO _prima_suscrita,
	      _cnt_prima_nva,
		  _cnt_prima_ren,
		  _cnt_prima_can,
		  _prima_sus_cor,
		  _prima_sus_dir,
		  _prima_sus_can
     FROM temp_perfil2
    WHERE cod_ramo    = v_cod_ramo;

	SELECT SUM(incurrido_bruto),
	       SUM(salv_y_recup),
		   SUM(pago_y_ded),
		   SUM(var_reserva),
		   SUM(cnt_incurrido)
	   INTO	v_incurrido_bruto,
	        _salv_y_recup,
			_pago_y_ded,
			_var_reserva,
			_cnt_incurridos
	   FROM	tmp_siniest_uni
	  WHERE seleccionado = 1
	    AND cod_ramo     = v_cod_ramo;

	SELECT COUNT(no_reclamo)
	   INTO	_cnt_reclamo
	   FROM	tmp_sinis
	  WHERE cod_ramo     = v_cod_ramo
	    and seleccionado = 1;

	IF _prima_suscrita IS NULL THEN
		LET _prima_suscrita = 0;
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
		IF _cnt_incurridos IS NULL THEN
		LET _cnt_incurridos  = 0;	
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
		      SUM(prima_sus_cor),
		      SUM(prima_sus_dir),
		      SUM(prima_sus_can)
	     INTO _prima_suscrita,
			  _cnt_prima_nva,
			  _cnt_prima_ren,
			  _cnt_prima_can,
		      _prima_sus_cor,
		      _prima_sus_dir,
		      _prima_sus_can
	     FROM temp_perfil2
	    WHERE cod_ramo    = v_cod_ramo
	      AND cod_subramo = "001";

		  IF _prima_suscrita IS NULL THEN
		  	LET _prima_suscrita = 0;
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
	
	   UPDATE ramosubr
          SET cnt_polizas  = v_cant_polizas,
		      cnt_polizas_ma = v_cant_polizas_ma,
	   		  prima_suscrita = _prima_suscrita,
			  cnt_pol_nuevas   = _cnt_prima_nva,
			  cnt_pol_ren      = _cnt_prima_ren,
			  cnt_pol_can_cad  = _cnt_prima_can,
			  cnt_asegurados   = v_cant_asegurados,
			  prima_sus_cor	   = _prima_sus_cor,
			  prima_sus_dir	   = _prima_sus_dir,
			  prima_sus_can	   = _prima_sus_can
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
		      SUM(prima_sus_cor),
		      SUM(prima_sus_dir),
		      SUM(prima_sus_can)
	     INTO _prima_suscrita,
			  _cnt_prima_nva,
			  _cnt_prima_ren,
			  _cnt_prima_can,
		      _prima_sus_cor,
		      _prima_sus_dir,
		      _prima_sus_can
	     FROM temp_perfil2
	    WHERE cod_ramo    = v_cod_ramo
	      AND cod_subramo <> "001";

	    IF _prima_suscrita IS NULL THEN
			LET _prima_suscrita = 0;
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

	   UPDATE ramosubr
          SET cnt_polizas  = v_cant_polizas,
		      cnt_polizas_ma = v_cant_polizas_ma,
	     	  prima_suscrita = _prima_suscrita,
			  cnt_pol_nuevas   = _cnt_prima_nva,
			  cnt_pol_ren      = _cnt_prima_ren,
			  cnt_pol_can_cad  = _cnt_prima_can,
			  cnt_asegurados   = v_cant_asegurados,
			  prima_sus_cor	   = _prima_sus_cor,
			  prima_sus_dir	   = _prima_sus_dir,
			  prima_sus_can	   = _prima_sus_can
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
		      SUM(prima_sus_cor),
		      SUM(prima_sus_dir),
		      SUM(prima_sus_can)
	     INTO _prima_suscrita,
			  _cnt_prima_nva,
			  _cnt_prima_ren,
			  _cnt_prima_can,
		      _prima_sus_cor,
		      _prima_sus_dir,
		      _prima_sus_can
	     FROM temp_perfil2
	    WHERE cod_ramo    = v_cod_ramo
	      AND cod_subramo = "001";

		  IF _prima_suscrita IS NULL THEN
		  	LET _prima_suscrita = 0;
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
		  
	   UPDATE ramosubr
          SET cnt_polizas  = v_cant_polizas,
		      cnt_polizas_ma = v_cant_polizas_ma,
	   		  prima_suscrita = _prima_suscrita,
			  cnt_pol_nuevas   = _cnt_prima_nva,
			  cnt_pol_ren      = _cnt_prima_ren,
			  cnt_pol_can_cad  = _cnt_prima_can,
			  cnt_asegurados   = v_cant_asegurados,
			  prima_sus_cor	   = _prima_sus_cor,
			  prima_sus_dir	   = _prima_sus_dir,
			  prima_sus_can	   = _prima_sus_can
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
		      SUM(prima_sus_cor),
		      SUM(prima_sus_dir),
		      SUM(prima_sus_can)
	     INTO _prima_suscrita,
			  _cnt_prima_nva,
			  _cnt_prima_ren,
			  _cnt_prima_can,
		      _prima_sus_cor,
		      _prima_sus_dir,
		      _prima_sus_can
	     FROM temp_perfil2
	    WHERE cod_ramo    = v_cod_ramo
	      AND cod_subramo = "002";

		  IF _prima_suscrita IS NULL THEN
		  	LET _prima_suscrita = 0;
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
		  
	   UPDATE ramosubr
          SET cnt_polizas  = v_cant_polizas,
		      cnt_polizas_ma = v_cant_polizas_ma,		  
	   		  prima_suscrita = _prima_suscrita,
			  cnt_pol_nuevas   = _cnt_prima_nva,
			  cnt_pol_ren      = _cnt_prima_ren,
			  cnt_pol_can_cad  = _cnt_prima_can,
			  cnt_asegurados  = v_cant_asegurados,
			  prima_sus_cor	   = _prima_sus_cor,
			  prima_sus_dir	   = _prima_sus_dir,
			  prima_sus_can	   = _prima_sus_can
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
		      SUM(prima_sus_cor),
		      SUM(prima_sus_dir),
		      SUM(prima_sus_can)
	     INTO _prima_suscrita,
			  _cnt_prima_nva,
			  _cnt_prima_ren,
			  _cnt_prima_can,
		      _prima_sus_cor,
		      _prima_sus_dir,
		      _prima_sus_can
	     FROM temp_perfil2
	    WHERE cod_ramo    = v_cod_ramo
	      AND cod_subramo in("003","004","006","007");

		  IF _prima_suscrita IS NULL THEN
		  	LET _prima_suscrita = 0;
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
		  
	   UPDATE ramosubr
          SET cnt_polizas  = v_cant_polizas,
		      cnt_polizas_ma = v_cant_polizas_ma,		  
	   		  prima_suscrita = _prima_suscrita,
			  cnt_pol_nuevas   = _cnt_prima_nva,
			  cnt_pol_ren      = _cnt_prima_ren,
			  cnt_pol_can_cad  = _cnt_prima_can,
			  cnt_asegurados  = v_cant_asegurados,
			  prima_sus_cor	   = _prima_sus_cor,
			  prima_sus_dir	   = _prima_sus_dir,
			  prima_sus_can	   = _prima_sus_can
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
		      SUM(prima_sus_cor),
		      SUM(prima_sus_dir),
		      SUM(prima_sus_can)
	     INTO _prima_suscrita,
			  _cnt_prima_nva,
			  _cnt_prima_ren,
			  _cnt_prima_can,
		      _prima_sus_cor,
		      _prima_sus_dir,
		      _prima_sus_can
	     FROM temp_perfil2
	    WHERE cod_ramo    = v_cod_ramo
	      AND cod_subramo = "001";

	  IF _prima_suscrita IS NULL THEN
		LET _prima_suscrita = 0;
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
	  
	   UPDATE ramosubr
          SET cnt_polizas  = v_cant_polizas,
		      cnt_polizas_ma = v_cant_polizas_ma,		  
			  prima_suscrita = _prima_suscrita,
			  cnt_pol_nuevas   = _cnt_prima_nva,
			  cnt_pol_ren      = _cnt_prima_ren,
			  cnt_pol_can_cad  = _cnt_prima_can,
			  cnt_asegurados   = v_cant_asegurados,
			  prima_sus_cor	   = _prima_sus_cor,
			  prima_sus_dir	   = _prima_sus_dir,
			  prima_sus_can	   = _prima_sus_can
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
		      SUM(prima_sus_cor),
		      SUM(prima_sus_dir),
		      SUM(prima_sus_can)
	     INTO _prima_suscrita,
			  _cnt_prima_nva,
			  _cnt_prima_ren,
			  _cnt_prima_can,
		      _prima_sus_cor,
		      _prima_sus_dir,
		      _prima_sus_can
	     FROM temp_perfil2
	    WHERE cod_ramo    = v_cod_ramo
	      AND cod_subramo = "002";

	  IF _prima_suscrita IS NULL THEN
	  	LET _prima_suscrita = 0;
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
	  
	   UPDATE ramosubr
          SET cnt_polizas  = v_cant_polizas,
		      cnt_polizas_ma = v_cant_polizas_ma,		  		  
	   		  prima_suscrita = _prima_suscrita,
			  cnt_pol_nuevas   = _cnt_prima_nva,
			  cnt_pol_ren      = _cnt_prima_ren,
			  cnt_pol_can_cad  = _cnt_prima_can,
			  cnt_asegurados   = v_cant_asegurados,
			  prima_sus_cor	   = _prima_sus_cor,
			  prima_sus_dir	   = _prima_sus_dir,
			  prima_sus_can	   = _prima_sus_can
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
		      SUM(prima_sus_cor),
		      SUM(prima_sus_dir),
		      SUM(prima_sus_can)
	     INTO _prima_suscrita,
			  _cnt_prima_nva,
			  _cnt_prima_ren,
			  _cnt_prima_can,
		      _prima_sus_cor,
		      _prima_sus_dir,
		      _prima_sus_can
	     FROM temp_perfil2
	    WHERE cod_ramo    = v_cod_ramo
	      AND cod_subramo = "001";

	  IF _prima_suscrita IS NULL THEN
	  	LET _prima_suscrita = 0;
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
	  
	   UPDATE ramosubr
          SET cnt_polizas  = v_cant_polizas,
		      cnt_polizas_ma = v_cant_polizas_ma,		  		  
	   		  prima_suscrita = _prima_suscrita,
			  cnt_pol_nuevas   = _cnt_prima_nva,
			  cnt_pol_ren      = _cnt_prima_ren,
			  cnt_pol_can_cad  = _cnt_prima_can,
			  cnt_asegurados   = v_cant_asegurados,
			  prima_sus_cor	   = _prima_sus_cor,
			  prima_sus_dir	   = _prima_sus_dir,
			  prima_sus_can	   = _prima_sus_can
        WHERE cod_ramo     = v_cod_ramo
          AND cod_subramo  = "001";
   END IF
   
    IF v_cod_ramo = "016" THEN

	   SELECT SUM(cant_polizas),
              SUM(cant_polizas_ma),
			  SUM(cant_asegurados)
	     INTO v_cant_polizas,
		      v_cant_polizas_ma,
			  v_cant_asegurados
	     FROM temp_perfil1
	    WHERE cod_ramo    = v_cod_ramo
	      AND cod_subramo <> "007";

	   SELECT SUM(prima_suscrita),
			  SUM(cnt_pol_nuevas),
			  SUM(cnt_pol_ren),
			  SUM(cnt_pol_can_cad),
		      SUM(prima_sus_cor),
		      SUM(prima_sus_dir),
		      SUM(prima_sus_can)
	     INTO _prima_suscrita,
			  _cnt_prima_nva,
			  _cnt_prima_ren,
			  _cnt_prima_can,
		      _prima_sus_cor,
		      _prima_sus_dir,
		      _prima_sus_can
	     FROM temp_perfil2
	    WHERE cod_ramo    = v_cod_ramo
	      AND cod_subramo <> "007";

		  IF _prima_suscrita IS NULL THEN
		  	LET _prima_suscrita = 0;
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
	   
	   -- Colectivo de Vida 27-05-2021
	   UPDATE ramosubr
          SET cnt_polizas  = v_cant_polizas,
		      cnt_polizas_ma = v_cant_polizas_ma,
	   		  prima_suscrita = _prima_suscrita,
			  cnt_pol_nuevas   = _cnt_prima_nva,
			  cnt_pol_ren      = _cnt_prima_ren,
			  cnt_pol_can_cad  = _cnt_prima_can,
			  cnt_asegurados   = v_cant_asegurados,
			  prima_sus_cor	   = _prima_sus_cor,
			  prima_sus_dir	   = _prima_sus_dir,
			  prima_sus_can	   = _prima_sus_can
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
	      AND cod_subramo = "007";

	   SELECT SUM(prima_suscrita),
			  SUM(cnt_pol_nuevas),
			  SUM(cnt_pol_ren),
			  SUM(cnt_pol_can_cad),
		      SUM(prima_sus_cor),
		      SUM(prima_sus_dir),
		      SUM(prima_sus_can)
	     INTO _prima_suscrita,
			  _cnt_prima_nva,
			  _cnt_prima_ren,
			  _cnt_prima_can,
		      _prima_sus_cor,
		      _prima_sus_dir,
		      _prima_sus_can
	     FROM temp_perfil2
	    WHERE cod_ramo    = v_cod_ramo
	      AND cod_subramo = "007";

	    IF _prima_suscrita IS NULL THEN
			LET _prima_suscrita = 0;
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

	   -- Colectivo de Deuda 27-05-2021
	   UPDATE ramosubr
          SET cnt_polizas  = v_cant_polizas,
		      cnt_polizas_ma = v_cant_polizas_ma,
	     	  prima_suscrita = _prima_suscrita,
			  cnt_pol_nuevas   = _cnt_prima_nva,
			  cnt_pol_ren      = _cnt_prima_ren,
			  cnt_pol_can_cad  = _cnt_prima_can,
			  cnt_asegurados  = v_cant_asegurados,
			  prima_sus_cor	   = _prima_sus_cor,
			  prima_sus_dir	   = _prima_sus_dir,
			  prima_sus_can	   = _prima_sus_can
        WHERE cod_ramo     = v_cod_ramo
          AND cod_subramo  = "002";

	END IF
   
   
    IF v_cod_ramo = "015" THEN

	   SELECT SUM(cant_polizas),
              SUM(cant_polizas_ma),
			  SUM(cant_asegurados)
	     INTO v_cant_polizas,
		      v_cant_polizas_ma,
			  v_cant_asegurados
	     FROM temp_perfil1
	    WHERE cod_ramo = "015";

	   SELECT SUM(prima_suscrita),
			  SUM(cnt_pol_nuevas),
			  SUM(cnt_pol_ren),
			  SUM(cnt_pol_can_cad),
		      SUM(prima_sus_cor),
		      SUM(prima_sus_dir),
		      SUM(prima_sus_can)
	     INTO _prima_suscrita,
			  _cnt_prima_nva,
			  _cnt_prima_ren,
			  _cnt_prima_can,
		      _prima_sus_cor,
		      _prima_sus_dir,
		      _prima_sus_can
	     FROM temp_perfil2
	    WHERE cod_ramo in ('015');

		SELECT SUM(incurrido_bruto),
			   SUM(salv_y_recup),
			   SUM(pago_y_ded),
			   SUM(var_reserva),
			   SUM(cnt_incurrido)
		   INTO	v_incurrido_bruto,
				_salv_y_recup,
				_pago_y_ded,
				_var_reserva,
				_cnt_incurridos
		   FROM	tmp_siniest_uni
		  WHERE seleccionado = 1
			AND cod_ramo = "015";

		SELECT COUNT(no_reclamo)
		   INTO	_cnt_reclamo
		   FROM	tmp_sinis
		  WHERE cod_ramo = "015"
			and seleccionado = 1;

		IF _prima_suscrita IS NULL THEN
			LET _prima_suscrita = 0;
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
		IF _cnt_incurridos IS NULL THEN
			LET _cnt_incurridos  = 0;	
		END IF		 
	
     UPDATE ramosubr
        SET cnt_polizas    	= v_cant_polizas, 
			cnt_polizas_ma 	= v_cant_polizas_ma, 
			prima_suscrita 	= _prima_suscrita, 
			incurrido_bruto = v_incurrido_bruto, 
			salv_rec 		= _salv_y_recup,
			pago_ded        = _pago_y_ded, 
			var_reserva 	= _var_reserva, 
			cnt_reclamo 	= _cnt_reclamo, 
			casos_cerrados  = _cnt_cerra, 
			cnt_pol_nuevas  = _cnt_prima_nva,
			cnt_pol_ren     = _cnt_prima_ren, 
			cnt_pol_can_cad = _cnt_prima_can,	
			cnt_asegurados  = v_cant_asegurados,
			cnt_incurridos  = _cnt_incurridos,
			prima_sus_cor   = _prima_sus_cor,
			prima_sus_dir   = _prima_sus_dir,
			prima_sus_can   = _prima_sus_can
      WHERE cod_ramo        = v_cod_ramo
        AND cod_subramo     = "001";

	END IF
   
	let _cnt_cerra = 0;
	
	if v_cod_ramo = '001' then
		foreach with hold
			select r.no_reclamo 
			  into _no_reclamo
			  from emipomae e, recrcmae r, rectrmae t
			 where e.no_poliza = r.no_poliza
			   and r.no_reclamo = t.no_reclamo
			   and t.actualizado = 1
			   and t.periodo >= a_periodo
			   and t.periodo <= a_periodo2
			   and (t.cod_tipotran = '011'
	            or t.cerrar_rec = 1)
			   and e.cod_origen = a_origen
			   and e.cod_ramo in ('001','021')
			group by r.no_reclamo
			   
			let _cnt_cerra = _cnt_cerra + 1;
		end foreach
	elif v_cod_ramo = '002' then
	{	foreach with hold     --APM 12-02-2026
			select r.no_reclamo 
			  into _no_reclamo
			  from emipomae e, recrcmae r, rectrmae t
			 where e.no_poliza = r.no_poliza
			   and r.no_reclamo = t.no_reclamo
			   and t.actualizado = 1
			   and t.periodo >= a_periodo
			   and t.periodo <= a_periodo2
			   and (t.cod_tipotran = '011'
	            or t.cerrar_rec = 1)
			   and e.cod_origen = a_origen
			   and e.cod_ramo in ('002','020','023')
               and (t.variacion <> 0
                or (trim(t.user_added) <> 'informix'
               and t.variacion = 0))
			group by r.no_reclamo
			
			let _cnt_cerra = _cnt_cerra + 1;
		end foreach	}	  
	else
		foreach with hold
			select r.no_reclamo 
			  into _no_reclamo
			  from emipomae e, recrcmae r, rectrmae t
			 where e.no_poliza = r.no_poliza
			   and r.no_reclamo = t.no_reclamo
			   and t.actualizado = 1
			   and t.periodo >= a_periodo
			   and t.periodo <= a_periodo2
			   and (t.cod_tipotran = '011'
	            or t.cerrar_rec = 1)
			   and e.cod_origen = a_origen
			   and e.cod_ramo = v_cod_ramo
			group by r.no_reclamo
			
			let _cnt_cerra = _cnt_cerra + 1;
		end foreach		  
	end if
	
   
 {  IF v_cod_ramo = "016" THEN
     UPDATE ramosubr
        SET cnt_polizas  = v_cant_polizas,
		    cnt_polizas_ma = v_cant_polizas_ma,				
			prima_suscrita = _prima_suscrita,
     	    incurrido_bruto = incurrido_bruto + v_incurrido_bruto,
		    salv_rec        = salv_rec        + _salv_y_recup,
			pago_ded        = pago_ded        + _pago_y_ded,
			var_reserva     = var_reserva     + _var_reserva,
			cnt_reclamo     = _cnt_reclamo,
			casos_cerrados  = _cnt_cerra,			
			cnt_pol_nuevas  = _cnt_prima_nva,
			cnt_pol_ren     = _cnt_prima_ren,
			cnt_pol_can_cad = _cnt_prima_can,
			cnt_asegurados  = v_cant_asegurados
      WHERE cod_ramo     = v_cod_ramo
        AND cod_subramo  = "001";
   ELIF	v_cod_ramo = "002" THEN
  } 
   IF v_cod_ramo = "002" THEN
    {UPDATE ramosubr   --APM 12-02-2026
        SET cnt_polizas  = v_cant_polizas,
		    cnt_polizas_ma = v_cant_polizas_ma,		  		  
     	    prima_suscrita = _prima_suscrita,
     	    incurrido_bruto = incurrido_bruto + v_incurrido_bruto,
		    salv_rec        = salv_rec        + _salv_y_recup,
			pago_ded        = pago_ded        + _pago_y_ded,
			var_reserva     = var_reserva     + _var_reserva,
			cnt_reclamo     = _cnt_reclamo,
			casos_cerrados  = _cnt_cerra,			
			cnt_pol_nuevas  = _cnt_prima_nva,
			cnt_pol_ren     = _cnt_prima_ren,
			cnt_pol_can_cad = _cnt_prima_can,
			cnt_asegurados  = v_cant_asegurados,
			cnt_incurridos  = _cnt_incurridos
      WHERE cod_ramo     = v_cod_ramo
        AND cod_subramo  = "001";}
   ELIF	v_cod_ramo in ("006","026","027") THEN
     UPDATE ramosubr
        SET cnt_polizas  = v_cant_polizas,
		    cnt_polizas_ma = v_cant_polizas_ma,		  		  
     	    prima_suscrita = _prima_suscrita,
     	    incurrido_bruto = incurrido_bruto + v_incurrido_bruto,
		    salv_rec        = salv_rec        + _salv_y_recup,
			pago_ded        = pago_ded        + _pago_y_ded,
			var_reserva     = var_reserva     + _var_reserva,
			cnt_reclamo     = _cnt_reclamo,
			casos_cerrados  = _cnt_cerra,			
			cnt_pol_nuevas  = _cnt_prima_nva,
			cnt_pol_ren     = _cnt_prima_ren,
			cnt_pol_can_cad = _cnt_prima_can,
			cnt_asegurados  = v_cant_asegurados,
			cnt_incurridos  = _cnt_incurridos,
			prima_sus_cor	= _prima_sus_cor,
			prima_sus_dir	= _prima_sus_dir,
			prima_sus_can	= _prima_sus_can			
      WHERE cod_ramo     = v_cod_ramo
        AND cod_subramo  = "001";
   ELIF	v_cod_ramo = "015" THEN
    { UPDATE ramosubr    --APM 12-02-2026
        SET cnt_polizas    = v_cant_polizas, cnt_polizas_ma = v_cant_polizas_ma, prima_suscrita = _prima_suscrita, incurrido_bruto = v_incurrido_bruto, salv_rec = _salv_y_recup,
			pago_ded        = _pago_y_ded, var_reserva = _var_reserva, cnt_reclamo = _cnt_reclamo, casos_cerrados  = _cnt_cerra, cnt_pol_nuevas  = _cnt_prima_nva,
			cnt_pol_ren     = _cnt_prima_ren, cnt_pol_can_cad = _cnt_prima_can,	cnt_asegurados  = v_cant_asegurados,
			cnt_incurridos  = _cnt_incurridos
      WHERE cod_ramo        = v_cod_ramo
        AND cod_subramo     = "001";}
   END IF
END FOREACH


END PROCEDURE;