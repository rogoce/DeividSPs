   DROP procedure sp_pro94d;
   CREATE procedure sp_pro94d(a_cia CHAR(03),a_agencia CHAR(3),a_periodo CHAR(7), a_periodo2 CHAR(7), a_origen CHAR(3) DEFAULT '%')
   RETURNING integer;
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
           _salv_y_recup,_pago_y_ded,_var_reserva, _calculo		   DECIMAL(16,2);
    DEFINE _tipo,_nueva_renov              CHAR(01);
    DEFINE v_filtros          CHAR(255);
	DEFINE _mes1, _mes2,_mes,_ano2, _ano1,_orden, _meses   SMALLINT;
	DEFINE _fecha2, _fecha1     	      DATE;
	define _cod_tipoprod	  char(3);
	DEFINE _vigencia_inic, _vig_fin_vida, _vig_ini_end     DATE;
	define _no_endoso         char(5);
	define li_dia,li_mes,li_anio smallint;
	DEFINE _cnt_cerra,_cantidad            INTEGER;
	define _cod_origen        CHAR(3);
	DEFINE v_cant_polizas_ma, _cnt_prima_nva, _cnt_prima_ren, _cnt_prima_can, _cnt_pol_dif, _cantidad_aseg, v_cant_asegurados, _cnt_incurrido, _cnt_vencidas, _retorno INTEGER;
	define _uso_auto			char(1);
	define _no_unidad			char(5);
	define _prima_sus_cor		dec(16,2);
	define _prima_sus_dir		dec(16,2);
	define _prima_sus_can		dec(16,2);
	define _cod_agente          char(5);
	define _tipo_agente         char(1);
	define _cod_endomov         char(3);
	define _activo              smallint;
			  

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
LET _cnt_incurrido   = 0;
LET _cnt_vencidas    = 0;

SET ISOLATION TO DIRTY READ;

--Cargando la prima ramos: 019, 004, 018, 014, 013, 010, 012, 011, 022, 007, 008, 009
FOREACH                   
 SELECT cod_ramo, total_pri_sus, cnt_prima_nva,	cnt_prima_ren, cnt_prima_can, no_poliza, no_endoso
   INTO _cod_ramo, _total_pri_sus, _cnt_prima_nva, _cnt_prima_ren, _cnt_prima_can, _no_poliza, _no_endoso
   FROM tmp_prod
  WHERE	seleccionado = 1

  IF _cod_ramo = '020' OR _cod_ramo = '023' THEN
	LET _cod_ramo = '002';
  END IF

  IF _cod_ramo = '021' THEN
	LET _cod_ramo = '001';
  END IF

  IF _total_pri_sus IS NULL THEN
  	LET _total_pri_sus = 0;
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
  
  LET _prima_sus_cor = 0;
  LET _prima_sus_dir = 0;
  LET _prima_sus_can = 0;  

	-- Informacion de Poliza
   SELECT nueva_renov, cod_subramo, vigencia_inic
     INTO _nueva_renov, _cod_subramo, _vigencia_inic
     FROM emipomae
    WHERE no_poliza = _no_poliza;

	SELECT FIRST 1 cod_agente
	  INTO _cod_agente
	  FROM emipoagt
	 WHERE no_poliza = _no_poliza;
	 
	select tipo_agente
	  into _tipo_agente
	  from agtagent
	 where cod_agente = _cod_agente;
	 
	if _cod_agente = '02596' then
		let _prima_sus_can = _total_pri_sus;
    else
		if _tipo_agente = 'A' then
			let _prima_sus_cor = _total_pri_sus;
		else
			let _prima_sus_dir = _total_pri_sus;
		end if
	end if

   let li_dia = day(_vigencia_inic);
   let li_mes = month(_vigencia_inic);
   let li_anio = year(_vigencia_inic);

	If li_mes = 2 Then
		If li_dia > 28 Then
			let li_dia = 28;
	    	let _vigencia_inic = mdy(li_mes, li_dia, li_anio);
		else
			let _vigencia_inic = mdy(li_mes, li_dia, li_anio);
		End If
	else
		let _vigencia_inic = mdy(li_mes, li_dia, li_anio);
	End If	

    LET _vig_fin_vida = _vigencia_inic + 1 UNITS YEAR;
   
    SELECT vigencia_inic
      INTO _vig_ini_end
	  FROM endedmae
	 WHERE no_poliza = _no_poliza
	   AND no_endoso = _no_endoso;

   IF _cod_ramo = "019" and _nueva_renov = "N" THEN --AND _vig_fin_vida > _vig_ini_end --Amado 02/06/2017
     UPDATE ramosubr
        SET prima_suscrita = prima_suscrita + _total_pri_sus, cnt_pol_nuevas  = cnt_pol_nuevas + _cnt_prima_nva, cnt_pol_ren = cnt_pol_ren + _cnt_prima_ren, cnt_pol_can_cad  = cnt_pol_can_cad + _cnt_prima_can,
		    prima_sus_cor = prima_sus_cor + _prima_sus_cor, prima_sus_dir = prima_sus_dir + _prima_sus_dir, prima_sus_can = prima_sus_can + _prima_sus_can 
      WHERE cod_ramo     = _cod_ramo
        AND cod_subramo  = "001";
   END IF	

  -- IF _cod_ramo = "019" AND (_vig_fin_vida <= _vig_ini_end or _nueva_renov = "R") THEN --Amado 02/06/2017
  IF _cod_ramo = "019" AND _nueva_renov = "R" THEN
     UPDATE ramosubr
        SET prima_suscrita = prima_suscrita + _total_pri_sus, cnt_pol_nuevas = cnt_pol_nuevas + _cnt_prima_nva, cnt_pol_ren = cnt_pol_ren + _cnt_prima_ren, cnt_pol_can_cad = cnt_pol_can_cad + _cnt_prima_can,
		    prima_sus_cor = prima_sus_cor + _prima_sus_cor, prima_sus_dir = prima_sus_dir + _prima_sus_dir, prima_sus_can = prima_sus_can + _prima_sus_can 
      WHERE cod_ramo     = _cod_ramo
        AND cod_subramo  = "002";
	END IF
   IF _cod_ramo = '004' OR _cod_ramo = '018' THEN
		select count(*)
		  into _cantidad
		  from emipouni
		 where no_poliza = _no_poliza;
		 
		IF (_cantidad > 1 and _cod_ramo = '004') or (_cod_ramo = '018' and _cod_subramo = '012') then
			UPDATE ramosubr
			   SET prima_suscrita  = prima_suscrita + _total_pri_sus, cnt_pol_nuevas = cnt_pol_nuevas + _cnt_prima_nva, cnt_pol_ren = cnt_pol_ren + _cnt_prima_ren, cnt_pol_can_cad = cnt_pol_can_cad + _cnt_prima_can,
		    prima_sus_cor = prima_sus_cor + _prima_sus_cor, prima_sus_dir = prima_sus_dir + _prima_sus_dir, prima_sus_can = prima_sus_can + _prima_sus_can 
 			 WHERE cod_ramo        = _cod_ramo
			   AND cod_subramo     = "002";
		ELSE
			UPDATE ramosubr
			   SET prima_suscrita  = prima_suscrita + _total_pri_sus, cnt_pol_nuevas = cnt_pol_nuevas + _cnt_prima_nva,	cnt_pol_ren = cnt_pol_ren + _cnt_prima_ren,	cnt_pol_can_cad = cnt_pol_can_cad + _cnt_prima_can,
		    prima_sus_cor = prima_sus_cor + _prima_sus_cor, prima_sus_dir = prima_sus_dir + _prima_sus_dir, prima_sus_can = prima_sus_can + _prima_sus_can 
 			 WHERE cod_ramo        = _cod_ramo
			   AND cod_subramo     = "001";		
		END IF
		 
	END IF
	IF _cod_ramo = "014" OR _cod_ramo = "013" THEN	--car y montaje
		UPDATE ramosubr
		   SET prima_suscrita  = prima_suscrita + _total_pri_sus, cnt_pol_nuevas  = cnt_pol_nuevas  + _cnt_prima_nva, cnt_pol_ren = cnt_pol_ren + _cnt_prima_ren, cnt_pol_can_cad  = cnt_pol_can_cad + _cnt_prima_can,
		    prima_sus_cor = prima_sus_cor + _prima_sus_cor, prima_sus_dir = prima_sus_dir + _prima_sus_dir, prima_sus_can = prima_sus_can + _prima_sus_can 
 	     WHERE cod_ramo        = '010'
		   AND cod_subramo     = "001";
	END IF
	IF _cod_ramo = "010" THEN --equio electronico
		UPDATE ramosubr
		   SET prima_suscrita  = prima_suscrita + _total_pri_sus, cnt_pol_nuevas = cnt_pol_nuevas  + _cnt_prima_nva, cnt_pol_ren = cnt_pol_ren + _cnt_prima_ren, cnt_pol_can_cad  = cnt_pol_can_cad + _cnt_prima_can,
		    prima_sus_cor = prima_sus_cor + _prima_sus_cor, prima_sus_dir = prima_sus_dir + _prima_sus_dir, prima_sus_can = prima_sus_can + _prima_sus_can 
 		 WHERE cod_ramo        = '010'
		   AND cod_subramo     = "002";
	END IF
	IF _cod_ramo = "012" THEN	--calderas
		UPDATE ramosubr
		   SET prima_suscrita  = prima_suscrita + _total_pri_sus, cnt_pol_nuevas = cnt_pol_nuevas  + _cnt_prima_nva, cnt_pol_ren = cnt_pol_ren + _cnt_prima_ren, cnt_pol_can_cad = cnt_pol_can_cad + _cnt_prima_can,
		    prima_sus_cor = prima_sus_cor + _prima_sus_cor, prima_sus_dir = prima_sus_dir + _prima_sus_dir, prima_sus_can = prima_sus_can + _prima_sus_can 
 	     WHERE cod_ramo        = '010'
		   AND cod_subramo     = "003";
	END IF
	IF _cod_ramo = "011" THEN	--rotura de maquinaria
		UPDATE ramosubr
		   SET prima_suscrita  = prima_suscrita + _total_pri_sus, cnt_pol_nuevas = cnt_pol_nuevas  + _cnt_prima_nva, cnt_pol_ren = cnt_pol_ren + _cnt_prima_ren, cnt_pol_can_cad = cnt_pol_can_cad + _cnt_prima_can,
		    prima_sus_cor = prima_sus_cor + _prima_sus_cor, prima_sus_dir = prima_sus_dir + _prima_sus_dir, prima_sus_can = prima_sus_can + _prima_sus_can 
 	     WHERE cod_ramo        = '010'
		   AND cod_subramo     = "004";
	END IF
	IF _cod_ramo = "022" THEN	--equipo pesado
		UPDATE ramosubr
		   SET prima_suscrita = prima_suscrita + _total_pri_sus, cnt_pol_nuevas = cnt_pol_nuevas  + _cnt_prima_nva,	cnt_pol_ren = cnt_pol_ren + _cnt_prima_ren, cnt_pol_can_cad = cnt_pol_can_cad + _cnt_prima_can,
		    prima_sus_cor = prima_sus_cor + _prima_sus_cor, prima_sus_dir = prima_sus_dir + _prima_sus_dir, prima_sus_can = prima_sus_can + _prima_sus_can 
 	     WHERE cod_ramo        = '010'
		   AND cod_subramo     = "005";
	END IF
	IF _cod_ramo = "007" THEN	--vidrios
		UPDATE ramosubr
		   SET prima_suscrita  = prima_suscrita + _total_pri_sus, cnt_pol_nuevas = cnt_pol_nuevas  + _cnt_prima_nva, cnt_pol_ren = cnt_pol_ren + _cnt_prima_ren, cnt_pol_can_cad = cnt_pol_can_cad + _cnt_prima_can,
		    prima_sus_cor = prima_sus_cor + _prima_sus_cor, prima_sus_dir = prima_sus_dir + _prima_sus_dir, prima_sus_can = prima_sus_can + _prima_sus_can 
 	     WHERE cod_ramo        = '010'
		   AND cod_subramo     = "006";
	END IF
	IF _cod_ramo = "008" THEN
      IF _cod_subramo = "002" OR _cod_subramo = "018" THEN
			UPDATE ramosubr
			   SET prima_suscrita  = prima_suscrita + _total_pri_sus, cnt_pol_nuevas = cnt_pol_nuevas + _cnt_prima_nva,	cnt_pol_ren = cnt_pol_ren + _cnt_prima_ren,	cnt_pol_can_cad = cnt_pol_can_cad + _cnt_prima_can,
		    prima_sus_cor = prima_sus_cor + _prima_sus_cor, prima_sus_dir = prima_sus_dir + _prima_sus_dir, prima_sus_can = prima_sus_can + _prima_sus_can 
 			 WHERE cod_ramo        = _cod_ramo
			   AND cod_subramo     = "001";
	  ELIF 	_cod_subramo = "003" THEN	   
			UPDATE ramosubr
			   SET prima_suscrita  = prima_suscrita + _total_pri_sus, cnt_pol_nuevas = cnt_pol_nuevas + _cnt_prima_nva,	cnt_pol_ren = cnt_pol_ren + _cnt_prima_ren,	cnt_pol_can_cad = cnt_pol_can_cad + _cnt_prima_can,
		    prima_sus_cor = prima_sus_cor + _prima_sus_cor, prima_sus_dir = prima_sus_dir + _prima_sus_dir, prima_sus_can = prima_sus_can + _prima_sus_can 
 			 WHERE cod_ramo        = _cod_ramo
			   AND cod_subramo     = "003";
	  ELIF 	_cod_subramo = "012" THEN	   
			UPDATE ramosubr
			   SET prima_suscrita  = prima_suscrita + _total_pri_sus, cnt_pol_nuevas = cnt_pol_nuevas + _cnt_prima_nva,	cnt_pol_ren = cnt_pol_ren + _cnt_prima_ren,	cnt_pol_can_cad = cnt_pol_can_cad + _cnt_prima_can,
		    prima_sus_cor = prima_sus_cor + _prima_sus_cor, prima_sus_dir = prima_sus_dir + _prima_sus_dir, prima_sus_can = prima_sus_can + _prima_sus_can 
 			 WHERE cod_ramo        = _cod_ramo
			   AND cod_subramo     = "004";
	  ELIF 	_cod_subramo = "009" THEN	   
			UPDATE ramosubr
			   SET prima_suscrita  = prima_suscrita + _total_pri_sus, cnt_pol_nuevas = cnt_pol_nuevas + _cnt_prima_nva,	cnt_pol_ren = cnt_pol_ren + _cnt_prima_ren,	cnt_pol_can_cad = cnt_pol_can_cad + _cnt_prima_can,
		    prima_sus_cor = prima_sus_cor + _prima_sus_cor, prima_sus_dir = prima_sus_dir + _prima_sus_dir, prima_sus_can = prima_sus_can + _prima_sus_can 
 			 WHERE cod_ramo        = _cod_ramo
			   AND cod_subramo     = "005";
	  else
			UPDATE ramosubr
			   SET prima_suscrita  = prima_suscrita + _total_pri_sus, cnt_pol_nuevas = cnt_pol_nuevas + _cnt_prima_nva, cnt_pol_ren = cnt_pol_ren + _cnt_prima_ren,	cnt_pol_can_cad  = cnt_pol_can_cad + _cnt_prima_can,
		    prima_sus_cor = prima_sus_cor + _prima_sus_cor, prima_sus_dir = prima_sus_dir + _prima_sus_dir, prima_sus_can = prima_sus_can + _prima_sus_can 
 			 WHERE cod_ramo        = _cod_ramo
			   AND cod_subramo     = "002";
	  end if
	END IF  
	if _cod_ramo = '009' and _cod_subramo in('001','002','006','009') then -- Se agregó el subramo 009 10-08-2022 ID de la solicitud	# 4243
			UPDATE ramosubr
			   SET prima_suscrita  = prima_suscrita + _total_pri_sus, cnt_pol_nuevas = cnt_pol_nuevas + _cnt_prima_nva,	cnt_pol_ren = cnt_pol_ren + _cnt_prima_ren,	cnt_pol_can_cad  = cnt_pol_can_cad + _cnt_prima_can,
		    prima_sus_cor = prima_sus_cor + _prima_sus_cor, prima_sus_dir = prima_sus_dir + _prima_sus_dir, prima_sus_can = prima_sus_can + _prima_sus_can 
 			 WHERE cod_ramo        = _cod_ramo
			   AND cod_subramo     = "002";
	end if
	if _cod_ramo = '009' and _cod_subramo = '003' then	
			UPDATE ramosubr
			   SET prima_suscrita  = prima_suscrita + _total_pri_sus, cnt_pol_nuevas = cnt_pol_nuevas + _cnt_prima_nva,	cnt_pol_ren = cnt_pol_ren + _cnt_prima_ren, cnt_pol_can_cad = cnt_pol_can_cad + _cnt_prima_can,
		    prima_sus_cor = prima_sus_cor + _prima_sus_cor, prima_sus_dir = prima_sus_dir + _prima_sus_dir, prima_sus_can = prima_sus_can + _prima_sus_can 
 			 WHERE cod_ramo        = _cod_ramo
			   AND cod_subramo     = "003";
	end if
	if _cod_ramo = '009' and _cod_subramo in ('004', '008') then --> Se incluye el subramo 008 MARINE CARGO STP
			UPDATE ramosubr
			   SET prima_suscrita  = prima_suscrita + _total_pri_sus, cnt_pol_nuevas   = cnt_pol_nuevas  + _cnt_prima_nva, cnt_pol_ren = cnt_pol_ren + _cnt_prima_ren, cnt_pol_can_cad  = cnt_pol_can_cad + _cnt_prima_can,
		    prima_sus_cor = prima_sus_cor + _prima_sus_cor, prima_sus_dir = prima_sus_dir + _prima_sus_dir, prima_sus_can = prima_sus_can + _prima_sus_can 
			 WHERE cod_ramo        = _cod_ramo
			   AND cod_subramo     = "004";
	end if
	
	IF _cod_ramo in ('002','020','023') THEN
	    FOREACH
			SELECT  no_unidad			
				INTO _no_unidad			 
			   FROM endeduni 
			  WHERE no_poliza = _no_poliza
				and no_endoso = _no_endoso			 
				order by 1
			EXIT FOREACH;	
		END FOREACH
			
		SELECT uso_auto
		  INTO _uso_auto
		  FROM emiauto
		 WHERE no_poliza = _no_poliza
		   AND no_unidad = _no_unidad;         
		 
		  IF _uso_auto IS NULL OR TRIM(_uso_auto) = "" THEN  -- Pólizas sin info en Emiauto 
			FOREACH
				  SELECT uso_auto
					INTO _uso_auto						
					FROM endmoaut 
				   WHERE no_poliza = _no_poliza
					 AND no_unidad = _no_unidad         
				exit FOREACH;
			end FOREACH			 

			  IF _uso_auto IS NULL OR TRIM(_uso_auto) = "" THEN
			   LET _uso_auto = 'P';
			  END IF 				
		  END IF 			 
		  IF _uso_auto = 'P' THEN
				UPDATE ramosubr
				   SET prima_suscrita  = prima_suscrita + _total_pri_sus, cnt_pol_nuevas = cnt_pol_nuevas + _cnt_prima_nva,	cnt_pol_ren = cnt_pol_ren + _cnt_prima_ren,	cnt_pol_can_cad = cnt_pol_can_cad + _cnt_prima_can,
				prima_sus_cor = prima_sus_cor + _prima_sus_cor, prima_sus_dir = prima_sus_dir + _prima_sus_dir, prima_sus_can = prima_sus_can + _prima_sus_can 
				 WHERE cod_ramo        = '002'
				   AND cod_subramo     = "001";
				LET _cod_ramo = '002';   
				LET _cod_subramo = '001';   
		  else
				UPDATE ramosubr
				   SET prima_suscrita  = prima_suscrita + _total_pri_sus, cnt_pol_nuevas = cnt_pol_nuevas + _cnt_prima_nva, cnt_pol_ren = cnt_pol_ren + _cnt_prima_ren,	cnt_pol_can_cad  = cnt_pol_can_cad + _cnt_prima_can,
				prima_sus_cor = prima_sus_cor + _prima_sus_cor, prima_sus_dir = prima_sus_dir + _prima_sus_dir, prima_sus_can = prima_sus_can + _prima_sus_can 
				 WHERE cod_ramo        = '002'
				   AND cod_subramo     = "002";
				LET _cod_ramo = '002';   
				LET _cod_subramo = '002';   
	  end if
	END IF
	
	   BEGIN
          ON EXCEPTION IN(-239)
             UPDATE temp_perfil2
                SET prima_suscrita = prima_suscrita + _total_pri_sus, cnt_pol_nuevas = cnt_pol_nuevas  + _cnt_prima_nva, cnt_pol_ren = cnt_pol_ren + _cnt_prima_ren, cnt_pol_can_cad  = cnt_pol_can_cad + _cnt_prima_can,
		    prima_sus_cor = prima_sus_cor + _prima_sus_cor, prima_sus_dir = prima_sus_dir + _prima_sus_dir, prima_sus_can = prima_sus_can + _prima_sus_can 
              WHERE cod_ramo       = _cod_ramo
                AND cod_subramo    = _cod_subramo;

          END EXCEPTION
          INSERT INTO temp_perfil2
              VALUES(_cod_ramo,
                     _cod_subramo,
                     _nueva_renov,
                     _total_pri_sus,
					 _cnt_prima_nva,
					 _cnt_prima_ren,
					 _cnt_prima_can,
				     _prima_sus_cor,
				     _prima_sus_dir,
				     _prima_sus_can
                     );
       END
END FOREACH
--Cargando las polizas vigentes, ramos: 019, 004, 018, 014, 013, 010, 012, 011, 022, 007, 008, 009
FOREACH WITH HOLD
   SELECT no_poliza, cod_ramo, cod_subramo
     INTO _no_poliza, v_cod_ramo, v_cod_subramo
     FROM temp_perfil
    WHERE seleccionado = 1

    SELECT nueva_renov, vigencia_inic	
      INTO _nueva_renov, _vigencia_inic	
      FROM emipomae
     WHERE no_poliza = _no_poliza;
	 
	let _cantidad_aseg = 0; 
	 
	select count(*)
	  into _cantidad_aseg
	  from emipouni
	 where no_poliza = _no_poliza;
	 	 
   let li_dia = day(_vigencia_inic);
   let li_mes = month(_vigencia_inic);
   let li_anio = year(_vigencia_inic);

	If li_mes = 2 Then
		If li_dia > 28 Then
			let li_dia = 28;
	    	let _vigencia_inic = mdy(li_mes, li_dia, li_anio);
		else
			let _vigencia_inic = mdy(li_mes, li_dia, li_anio);
		End If
	else
		let _vigencia_inic = mdy(li_mes, li_dia, li_anio);
	End If	

   LET _vig_fin_vida = _vigencia_inic + 1 UNITS YEAR;
   
   --IF v_cod_ramo = "019" AND _vig_fin_vida >= _fecha2 THEN --Amado 02-06-2017
   IF v_cod_ramo = "019" AND _nueva_renov = 'N' THEN
    UPDATE ramosubr
        SET cnt_polizas  = cnt_polizas + 1,
		    cnt_asegurados = cnt_asegurados + _cantidad_aseg
      WHERE cod_ramo     = v_cod_ramo
        AND cod_subramo  = "001";
   END IF	

   --IF v_cod_ramo = "019" AND _vig_fin_vida < _fecha2 THEN --Amado 02-06-2017
   IF v_cod_ramo = "019" AND _nueva_renov = 'R' THEN
    UPDATE ramosubr
        SET cnt_polizas  = cnt_polizas + 1,
		    cnt_asegurados = cnt_asegurados + _cantidad_aseg
      WHERE cod_ramo     = v_cod_ramo
        AND cod_subramo  = "002";
   END IF
   IF v_cod_ramo = "014" OR v_cod_ramo = "013" THEN	--car y montaje
		UPDATE ramosubr
		   SET cnt_polizas = cnt_polizas + 1, cnt_asegurados = cnt_asegurados + _cantidad_aseg     
		 WHERE cod_ramo    = '010'
		   AND cod_subramo = "001";
	END IF
	IF v_cod_ramo = "010" THEN
		UPDATE ramosubr
		   SET cnt_polizas = cnt_polizas + 1, cnt_asegurados = cnt_asegurados + _cantidad_aseg
	     WHERE cod_ramo    = '010'
		   AND cod_subramo = "002";
	END IF
	IF v_cod_ramo = "012" THEN
		UPDATE ramosubr
		   SET cnt_polizas = cnt_polizas + 1, cnt_asegurados = cnt_asegurados + _cantidad_aseg
	     WHERE cod_ramo    = '010'
		   AND cod_subramo = "003";
	END IF
	IF v_cod_ramo = "011" THEN
		UPDATE ramosubr
		   SET cnt_polizas = cnt_polizas + 1, cnt_asegurados = cnt_asegurados + _cantidad_aseg
	     WHERE cod_ramo    = '010'
		   AND cod_subramo = "004";
	END IF
	IF v_cod_ramo = "022" THEN
		UPDATE ramosubr
		   SET cnt_polizas = cnt_polizas + 1, cnt_asegurados = cnt_asegurados + _cantidad_aseg
	     WHERE cod_ramo    = '010'
		   AND cod_subramo = "005";
	END IF
	IF v_cod_ramo = "007" THEN
		UPDATE ramosubr
		   SET cnt_polizas = cnt_polizas + 1, cnt_asegurados = cnt_asegurados + _cantidad_aseg
	     WHERE cod_ramo    = '010'
		   AND cod_subramo = "006";
	END IF
	if v_cod_ramo = '009' and v_cod_subramo in('001','002','006','009') then -- Se agregó el subramo 009 10-08-2022 ID de la solicitud	# 4243
			UPDATE ramosubr
			   SET cnt_polizas = cnt_polizas + 1, cnt_asegurados = cnt_asegurados + _cantidad_aseg
			 WHERE cod_ramo    = v_cod_ramo
			   AND cod_subramo = "002";
	end if
	if v_cod_ramo = '009' and v_cod_subramo = '003' then	
			UPDATE ramosubr
			   SET cnt_polizas = cnt_polizas + 1, cnt_asegurados = cnt_asegurados + _cantidad_aseg
			 WHERE cod_ramo    = v_cod_ramo
			   AND cod_subramo = "003";
	end if
	if v_cod_ramo = '009' and v_cod_subramo in ('004', '008') then --> Se incluye el subramo 008 MARINE CARGO STP	
			UPDATE ramosubr
			   SET cnt_polizas = cnt_polizas + 1, cnt_asegurados = cnt_asegurados + _cantidad_aseg
			 WHERE cod_ramo    = v_cod_ramo
			   AND cod_subramo = "004";
	end if
	IF v_cod_ramo = "008" THEN
      IF v_cod_subramo = "002" OR v_cod_subramo = "018" THEN
			UPDATE ramosubr
			   SET cnt_polizas = cnt_polizas + 1, cnt_asegurados = cnt_asegurados + _cantidad_aseg
			 WHERE cod_ramo        = v_cod_ramo
			   AND cod_subramo     = "001";
	  ELIF 	v_cod_subramo = "003" THEN	   
			UPDATE ramosubr
			   SET cnt_polizas = cnt_polizas + 1, cnt_asegurados = cnt_asegurados + _cantidad_aseg
 			 WHERE cod_ramo        = v_cod_ramo
			   AND cod_subramo     = "003";
	  ELIF 	v_cod_subramo = "012" THEN	   
			UPDATE ramosubr
			   SET cnt_polizas = cnt_polizas + 1, cnt_asegurados = cnt_asegurados + _cantidad_aseg
 			 WHERE cod_ramo        = v_cod_ramo
			   AND cod_subramo     = "004";
	  ELIF 	v_cod_subramo = "009" THEN	   
			UPDATE ramosubr
			   SET cnt_polizas = cnt_polizas + 1, cnt_asegurados = cnt_asegurados + _cantidad_aseg
 			 WHERE cod_ramo        = v_cod_ramo
			   AND cod_subramo     = "005";
	  else
			UPDATE ramosubr
			   SET cnt_polizas = cnt_polizas + 1, cnt_asegurados = cnt_asegurados + _cantidad_aseg
			 WHERE cod_ramo        = v_cod_ramo
			   AND cod_subramo     = "002";
	  end if
	end if
   IF v_cod_ramo = '004' OR v_cod_ramo = '018' THEN
		select count(*)
		  into _cantidad
		  from emipouni
		 where no_poliza = _no_poliza;

		if _cantidad > 1 then	     
         UPDATE ramosubr
            SET cnt_polizas  = cnt_polizas + 1, cnt_asegurados = cnt_asegurados + _cantidad_aseg
	      WHERE cod_ramo     = v_cod_ramo
	        AND cod_subramo  = "002";
		else
	     UPDATE ramosubr
            SET cnt_polizas  = cnt_polizas + 1, cnt_asegurados = cnt_asegurados + _cantidad_aseg
	      WHERE cod_ramo     = v_cod_ramo
	        AND cod_subramo  = "001";
		end if
    END IF
	IF v_cod_ramo in ('002','020','023') THEN
		
		 
		select uso_auto
		  into _uso_auto
		  from emiauto
		 where no_poliza = _no_poliza
		   and no_unidad = _no_unidad;
		   
		if _uso_auto is null then
			foreach
				select uso_auto
				  into _uso_auto
				  from endmoaut
				 where no_poliza = _no_poliza
				   and no_unidad = _no_unidad
				exit foreach;
			end foreach
		end if

		if _uso_auto is null then
			let _uso_auto = 'P';
		end if
		
		IF _uso_auto = 'P' then
			UPDATE ramosubr
			   SET cnt_polizas  = cnt_polizas + 1
			 WHERE cod_ramo        = '002'
			   AND cod_subramo     = "001";
		ELSE
			UPDATE ramosubr
			   SET cnt_polizas  = cnt_polizas + 1
			 WHERE cod_ramo        = '002'
			   AND cod_subramo     = "002";
        END IF		 
				
		FOREACH
			select no_unidad
			  into _no_unidad
			  from tmp_unidad_v 
			 where activo = 1
		  order by 1
			 
			select uso_auto
			  into _uso_auto
			  from emiauto
			 where no_poliza = _no_poliza
			   and no_unidad = _no_unidad;
			   
			if _uso_auto is null then
				foreach
					select uso_auto
					  into _uso_auto
					  from endmoaut
					 where no_poliza = _no_poliza
					   and no_unidad = _no_unidad
					exit foreach;
				end foreach
			end if
			
			if _uso_auto = 'P' then
				UPDATE ramosubr
				   SET cnt_asegurados = cnt_asegurados + 1
				 WHERE cod_ramo        = '002'
				   AND cod_subramo     = "001";
				LET v_cod_ramo = '002';   
				LET v_cod_subramo = '001'; 
			else
				UPDATE ramosubr
				   SET cnt_asegurados = cnt_asegurados + 1
				 WHERE cod_ramo        = '002'
				   AND cod_subramo     = "002";
				LET v_cod_ramo = '002';   
				LET v_cod_subramo = '002';   
			end if
		END FOREACH
	END IF
    
   BEGIN
      ON EXCEPTION IN(-239)
         UPDATE temp_perfil1
            SET cant_polizas   = cant_polizas + 1, cant_asegurados = cant_asegurados + _cantidad_aseg
          WHERE cod_ramo       = v_cod_ramo
            AND cod_subramo    = v_cod_subramo;

      END EXCEPTION
      INSERT INTO temp_perfil1
          VALUES(v_cod_ramo,
                 v_cod_subramo,
                 1,
				 0,
				 _cantidad_aseg
                 );
   END
END FOREACH

--Cargando la prima ramos: 019, 004, 018, 014, 013, 010, 012, 011, 022, 007, 008, 009
{FOREACH                   
 SELECT cod_ramo, total_pri_sus, cnt_prima_nva,	cnt_prima_ren, cnt_prima_can, no_poliza, no_endoso, no_unidad
   INTO _cod_ramo, _total_pri_sus, _cnt_prima_nva, _cnt_prima_ren, _cnt_prima_can, _no_poliza, _no_endoso, _no_unidad
   FROM tmp_prod_uni
  WHERE	seleccionado = 1
  ORDER BY cod_ramo, no_poliza, no_endoso, no_unidad

 -- IF _cod_ramo = '020' OR _cod_ramo = '023' THEN
--	LET _cod_ramo = '002';
 -- END IF

  IF _cod_ramo = '021' THEN
	LET _cod_ramo = '001';
  END IF

  IF _total_pri_sus IS NULL THEN
  	LET _total_pri_sus = 0;
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
  
  LET _prima_sus_cor = 0;
  LET _prima_sus_dir = 0;
  LET _prima_sus_can = 0;  

	-- Informacion de Poliza
   SELECT nueva_renov, cod_subramo, vigencia_inic
     INTO _nueva_renov, _cod_subramo, _vigencia_inic
     FROM emipomae
    WHERE no_poliza = _no_poliza;

	SELECT FIRST 1 cod_agente
	  INTO _cod_agente
	  FROM emipoagt
	 WHERE no_poliza = _no_poliza;
	 
	select tipo_agente
	  into _tipo_agente
	  from agtagent
	 where cod_agente = _cod_agente;
	 
	if _cod_agente = '02596' then
		let _prima_sus_can = _total_pri_sus;
    else
		if _tipo_agente = 'A' then
			let _prima_sus_cor = _total_pri_sus;
		else
			let _prima_sus_dir = _total_pri_sus;
		end if
	end if

	IF _cod_ramo in ('002','020','023') THEN				
		  SELECT uso_auto    -- C - Comercial o P - Particular
			INTO _uso_auto
			FROM emiauto
		   WHERE no_poliza = _no_poliza
			 AND no_unidad = _no_unidad;         
			 
			  IF _uso_auto IS NULL THEN  -- Pólizas sin info en Emiauto 
				FOREACH
					  SELECT uso_auto    -- C - Comercial o P - Particular
						INTO _uso_auto 
						FROM endmoaut 
					   WHERE no_poliza = _no_poliza
						 AND no_unidad = _no_unidad         
					exit FOREACH;
				end FOREACH			 

				  IF _uso_auto IS NULL THEN
				   LET _uso_auto = 'P';
				  END IF 				
			  END IF 			 
			  
		  IF _uso_auto = 'P' THEN
				UPDATE ramosubr
				   SET prima_suscrita  = prima_suscrita + _total_pri_sus, cnt_pol_nuevas = cnt_pol_nuevas + _cnt_prima_nva,	cnt_pol_ren = cnt_pol_ren + _cnt_prima_ren,	cnt_pol_can_cad = cnt_pol_can_cad + _cnt_prima_can,
				prima_sus_cor = prima_sus_cor + _prima_sus_cor, prima_sus_dir = prima_sus_dir + _prima_sus_dir, prima_sus_can = prima_sus_can + _prima_sus_can 
				 WHERE cod_ramo        = '002'
				   AND cod_subramo     = "001";
				LET _cod_ramo = '002';   
				LET _cod_subramo = '001';   
		  else
				UPDATE ramosubr
				   SET prima_suscrita  = prima_suscrita + _total_pri_sus, cnt_pol_nuevas = cnt_pol_nuevas + _cnt_prima_nva, cnt_pol_ren = cnt_pol_ren + _cnt_prima_ren,	cnt_pol_can_cad  = cnt_pol_can_cad + _cnt_prima_can,
				prima_sus_cor = prima_sus_cor + _prima_sus_cor, prima_sus_dir = prima_sus_dir + _prima_sus_dir, prima_sus_can = prima_sus_can + _prima_sus_can 
				 WHERE cod_ramo        = '002'
				   AND cod_subramo     = "002";
				LET _cod_ramo = '002';   
				LET _cod_subramo = '002';   
	  end if
	END IF
	   BEGIN
          ON EXCEPTION IN(-239)
             UPDATE temp_perfil2
                SET prima_suscrita = prima_suscrita + _total_pri_sus, cnt_pol_nuevas = cnt_pol_nuevas  + _cnt_prima_nva, cnt_pol_ren = cnt_pol_ren + _cnt_prima_ren, cnt_pol_can_cad  = cnt_pol_can_cad + _cnt_prima_can,
		    prima_sus_cor = prima_sus_cor + _prima_sus_cor, prima_sus_dir = prima_sus_dir + _prima_sus_dir, prima_sus_can = prima_sus_can + _prima_sus_can 
              WHERE cod_ramo       = _cod_ramo
                AND cod_subramo    = _cod_subramo;

          END EXCEPTION
          INSERT INTO temp_perfil2
              VALUES(_cod_ramo,
                     _cod_subramo,
                     _nueva_renov,
                     _total_pri_sus,
					 _cnt_prima_nva,
					 _cnt_prima_ren,
					 _cnt_prima_can,
				     _prima_sus_cor,
				     _prima_sus_dir,
				     _prima_sus_can
                     );
       END
END FOREACH}
return 0;
END PROCEDURE;