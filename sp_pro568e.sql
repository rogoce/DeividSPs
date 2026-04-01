   DROP procedure sp_pro568e;
   CREATE procedure "informix".sp_pro568e(a_periodo2 CHAR(7), a_origen CHAR(3) DEFAULT '%')
   RETURNING INTEGER, CHAR(50);
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
	define _anio_aniv			char(4);
	define _mes_aniv			char(2);
	define _origen              smallint;
	define _error_isam			smallint;
	define _error				smallint;
    define _error_desc			varchar(50);
	define _uso_auto			char(1);
	define _no_unidad			char(5);
	define _prima_sus_cor		dec(16,2);
	define _prima_sus_dir		dec(16,2);
	define _prima_sus_can		dec(16,2);
	define _cod_agente          char(5);
	define _tipo_agente         char(1);
  

IF a_origen = '001' THEN
	LET _origen = 1;
ELSE
	LET _origen = 2;
END IF

FOREACH
        SELECT cod_ramo,
			   cod_subramo,
			   cnt_polizas,
			   prima_suscrita,
			   orden,
			   incurrido_bruto,
			   cnt_reclamo,
		       salv_rec,
			   pago_ded,
			   var_reserva,
			   casos_cerrados,
			   cnt_polizas_ma,
			   cnt_pol_nuevas,
			   cnt_pol_ren,
			   cnt_pol_can_cad,
			   cnt_asegurados,
			   cnt_incurridos,
			   cnt_vencidas,
	           prima_sus_cor,
	           prima_sus_dir,
	           prima_sus_can
          INTO _cod_ramo,
			   _cod_subramo,
			   v_cant_polizas,
			   _prima_suscrita,
			   _orden,
			   v_incurrido_bruto,
			   _cnt_reclamo,
			   _salv_y_recup,
			   _pago_y_ded,
			   _var_reserva,
			   _cnt_cerra,
			   v_cant_polizas_ma,
			   _cnt_prima_nva,
			   _cnt_prima_ren,
			   _cnt_prima_can,
			   v_cant_asegurados,
			   _cnt_incurrido,
			   _cnt_vencidas,
 	           _prima_sus_cor,
	           _prima_sus_dir,
	           _prima_sus_can
         FROM ramosubr
	  ORDER BY orden,cod_ramo,cod_subramo
	  
	  INSERT INTO ramosubrh (
               cod_ramo,
			   cod_subramo,
			   cnt_polizas,
			   prima_suscrita,
			   orden,
			   incurrido_bruto,
			   cnt_reclamo,
		       salv_rec,
			   pago_ded,
			   var_reserva,
			   casos_cerrados,
			   cnt_polizas_ma,
			   cnt_pol_nuevas,
			   cnt_pol_ren,
			   cnt_pol_can_cad,
			   cnt_asegurados,
			   cnt_incurridos,
			   cnt_vencidas,
			   periodo,
			   origen,
	           prima_sus_cor,
	           prima_sus_dir,
	           prima_sus_can
			   )
	 VALUES   (_cod_ramo,
			   _cod_subramo,
			   v_cant_polizas,
			   _prima_suscrita,
			   _orden,
			   v_incurrido_bruto,
			   _cnt_reclamo,
			   _salv_y_recup,
			   _pago_y_ded,
			   _var_reserva,
			   _cnt_cerra,
			   v_cant_polizas_ma,
			   _cnt_prima_nva,
			   _cnt_prima_ren,
			   _cnt_prima_can,
			   v_cant_asegurados,
			   _cnt_incurrido,
			   _cnt_vencidas,
			   a_periodo2,
               _origen,
 	           _prima_sus_cor,
	           _prima_sus_dir,
	           _prima_sus_can
			   );

END FOREACH

FOREACH
       SELECT cod_ramo,
			  cod_subramo,
			  cnt_polizas,
			  prima_suscrita,
			  orden,
			  incurrido_bruto,
			  cnt_reclamo,
			  pago_ded,
			  salv_rec,
			  var_reserva,
			  casos_cerrados,
			  cnt_polizas_ma,
			  cnt_pol_nuevas,
			  cnt_pol_ren,
			  cnt_pol_can_cad,
			  cnt_asegurados,
			  cnt_incurridos,
			  cnt_vencidas,
	          prima_sus_cor,
	          prima_sus_dir,
	          prima_sus_can
         INTO _cod_ramo,
			  _cod_subramo,
			  v_cant_polizas,
			  _prima_suscrita,
			  _orden,
			  v_incurrido_bruto,
			  _cnt_reclamo,
			  _pago_y_ded,
			  _salv_y_recup,
			  _var_reserva,
			  _cnt_cerra,
			  v_cant_polizas_ma,
			  _cnt_prima_nva,
			  _cnt_prima_ren,
			  _cnt_prima_can,
			  v_cant_asegurados,
			  _cnt_incurrido,
			  _cnt_vencidas,
 	          _prima_sus_cor,
	          _prima_sus_dir,
	          _prima_sus_can
         FROM ramootro
	 ORDER BY orden,cod_ramo,cod_subramo

	 insert into ramootroh (
              cod_ramo,
			  cod_subramo,
			  cnt_polizas,
			  prima_suscrita,
			  orden,
			  incurrido_bruto,
			  cnt_reclamo,
			  pago_ded,
			  salv_rec,
			  var_reserva,
			  casos_cerrados,
			  cnt_polizas_ma,
			  cnt_pol_nuevas,
			  cnt_pol_ren,
			  cnt_pol_can_cad,
			  cnt_asegurados,
			  cnt_incurridos,
			  cnt_vencidas,
			  periodo,
			  origen,
	          prima_sus_cor,
	          prima_sus_dir,
	          prima_sus_can
			 )
			 values(
			 _cod_ramo,
			 _cod_subramo,
			 v_cant_polizas,
			 _prima_suscrita,
			 _orden,
			 v_incurrido_bruto,
			 _cnt_reclamo,
			 _pago_y_ded,
			 _salv_y_recup,
			 _var_reserva,
			 _cnt_cerra,
			 v_cant_polizas_ma,
			  _cnt_prima_nva,
			  _cnt_prima_ren,
			  _cnt_prima_can,
			  v_cant_asegurados,
			  _cnt_incurrido,
			  _cnt_vencidas,
			 a_periodo2,
			 _origen,
 	         _prima_sus_cor,
	         _prima_sus_dir,
	         _prima_sus_can
			 );
	 
END FOREACH

insert into estpolvih
select no_poliza,
       no_documento,
       cod_ramo,
       cod_subramo,
       vigencia_inic,
       vigencia_final,
       nueva_renov,
       _origen,
       a_periodo2
  from temp_perfil;
  
insert into estpolenh
select no_poliza,
       no_endoso,
       no_documento,
       cod_ramo,
       cod_subramo,
       cod_endomov,
       nueva_renov,
       vigencia_inic,
       vigencia_final,
       _origen,
       a_periodo2
  from tmp_prod;

insert into estpolveh
select no_poliza,
       no_documento,
       cod_ramo,
       cod_subramo,
       vigencia_inic,
       vigencia_final,
       cod_no_renov,
       nueva_renov,
      _origen,
      a_periodo2
 from tmp_vence;


return 0, "Actualizacion exitosa";

END PROCEDURE;