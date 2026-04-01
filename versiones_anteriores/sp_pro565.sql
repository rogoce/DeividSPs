   DROP procedure sp_pro565;
   CREATE procedure "informix".sp_pro565(a_cia CHAR(03),a_agencia CHAR(3),a_periodo CHAR(7), a_periodo2 CHAR(7), a_origen CHAR(3) DEFAULT '%')
   RETURNING CHAR(50),INT,DECIMAL(16,2),CHAR(50),CHAR(45),INT,SMALLINT,DECIMAL(16,2),INTEGER,DECIMAL(16,2),DECIMAL(16,2),DECIMAL(16,2),INTEGER,INTEGER,INTEGER,INTEGER,INTEGER,INTEGER,SMALLINT,INTEGER,INTEGER;
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
	DEFINE v_cant_polizas_ma, _cnt_prima_nva, _cnt_prima_ren, _cnt_prima_can, _cnt_pol_dif, _cantidad_aseg, v_cant_asegurados, _cnt_incurridos, _cnt_vencidas INTEGER;
	DEFINE _orig SMALLINT;
	DEFINE _orden_sub smallint;
	
	define _pais_residencia   char(50);	
	define _pri_sus_ext       dec(16,2);
	define _pag_ded_541       dec(16,2);
	define _salv_rec_419      dec(16,2);
	define _var_res_221       dec(16,2);
	DEFINE _cod_ramo_ext      char(3);

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
LET _cnt_vencidas    = 0;
let _pri_sus_ext  = 0;
let _pag_ded_541  = 0;
let _salv_rec_419 = 0;
let _var_res_221  = 0;


SET ISOLATION TO DIRTY READ;

-- Descomponer los periodos en fechas
LET descr_cia = sp_sis01(a_cia);
LET _ano2 = a_periodo[1,4];
LET _mes2 = a_periodo[6,7];
LET _mes = _mes2;

IF a_origen = '001' THEN
 let _orig = 1;
ELSE
 let _orig = 2;
END IF
delete from ramozonaext;
LET _cod_ramo_ext = '';
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
			   cnt_vencidas
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
			   _cnt_incurridos,
			   _cnt_vencidas
          FROM ramosubrh
		 WHERE periodo = a_periodo
		   AND origen = _orig
	  ORDER BY orden,cod_ramo,cod_subramo

       SELECT nombre
         INTO v_desc_ramo
         FROM prdramo
        WHERE cod_ramo = _cod_ramo;

       SELECT nombre
         INTO v_desc_subramo
         FROM prdsubra
        WHERE cod_ramo    = _cod_ramo
          AND cod_subramo = _cod_subramo;

	LET _orden_sub = 1;
	
	
		  
    IF _cod_ramo = "001" THEN
		  LET v_desc_ramo = "INCENDIO Y LINEAS ALIADAS";
		  IF _cod_subramo = '001' THEN
			LET _orden_sub = 1;
		  ELIF _cod_subramo = '002' THEN
			LET _orden_sub = 2;
		  ELIF _cod_subramo = '003' THEN
			LET _orden_sub = 3;
		  END IF
		  --LET v_desc_subramo = "";		  
    ELIF _cod_ramo = "009" THEN
		  LET v_desc_ramo = "TRANSPORTE DE CARGA";
		  IF  _cod_subramo = '002' THEN
		  	LET v_desc_subramo = "TERRESTRE";
		  END IF
 		  IF _cod_subramo = '002' THEN
			LET _orden_sub = 1;
		  ELIF _cod_subramo = '003' THEN
			LET _orden_sub = 3;
		  ELIF _cod_subramo = '004' THEN
			LET _orden_sub = 2;
		  END IF
   ELIF _cod_ramo = "004" THEN
		  LET v_desc_subramo = "";
		  IF  _cod_subramo = '001' THEN
		  	LET v_desc_subramo = "INDIVIDUAL";
		  ELSE
		  	LET v_desc_subramo = "GRUPO";
		  END IF
		  IF _cod_subramo = '001' THEN
			LET _orden_sub = 1;
		  ELIF _cod_subramo = '002' THEN
			LET _orden_sub = 2;
		  END IF
    ELIF _cod_ramo = "018" THEN
		  LET v_desc_subramo = "";
		  IF  _cod_subramo = '001' THEN
		  	LET v_desc_subramo = "INDIVIDUAL";
		  ELSE
		  	LET v_desc_subramo = "GRUPO";
		  END IF
		  IF _cod_subramo = '001' THEN
			LET _orden_sub = 1;
		  ELIF _cod_subramo = '002' THEN
			LET _orden_sub = 2;
		  END IF
    ELIF _cod_ramo = "016" THEN
		  LET v_desc_subramo = "";
		  IF  _cod_subramo = '001' THEN
		  	LET v_desc_subramo = "COLECTIVO DE VIDA";
		  ELSE
		  	LET v_desc_subramo = "COLECTIVO DE DEUDA";
		  END IF
		  IF _cod_subramo = '001' THEN
			LET _orden_sub = 1;
		  ELIF _cod_subramo = '002' THEN
			LET _orden_sub = 2;
		  END IF
    ELIF _cod_ramo = "002" THEN
		  LET v_desc_subramo = "";
    ELIF _cod_ramo = "006" THEN
		  LET v_desc_subramo = "";
    ELIF _cod_ramo = "008" THEN
		  LET v_desc_subramo = "";
		  if _cod_subramo = '001' then
			let v_desc_subramo = 'OFERTA Y CUMPLIMIENTO';
		  else
			let v_desc_subramo = 'OTRAS';
		  end if
		  IF _cod_subramo = '001' THEN
			LET _orden_sub = 1;
		  ELIF _cod_subramo = '002' THEN
			LET _orden_sub = 2;
		  END IF
    ELIF _cod_ramo = "010" THEN
		  LET v_desc_ramo = "RAMOS TECNICOS";
		  LET v_desc_subramo = "";
		  IF _cod_subramo = "001"	THEN
			  LET v_desc_subramo = "TRC / TRM";
			  LET _orden_sub = 1;
		  ELIF _cod_subramo = "002" THEN
			  LET v_desc_subramo = "EQUIPO ELECTRONICO";
			  LET _orden_sub = 2;
		  ELIF _cod_subramo = "003" THEN
			  LET v_desc_subramo = "CALDERA Y MAQUINARIA";
			  LET _orden_sub = 3;
		  ELIF _cod_subramo = "004" THEN
			  LET v_desc_subramo = "ROTURA DE MAQUINARIA";
			  LET _orden_sub = 4;
		  ELIF _cod_subramo = "005" THEN
			  LET v_desc_subramo = "EQUIPO PESADO";
			  LET _orden_sub = 5;
		  ELSE
			  LET v_desc_subramo = "VIDRIOS";
			  LET _orden_sub = 6;
		  END IF
    ELIF _cod_ramo = "011" THEN
		  LET v_desc_ramo = "RAMOS TECNICOS";
		  LET v_desc_subramo = "";
    ELIF _cod_ramo = "012" THEN
		  LET v_desc_ramo = "RAMOS TECNICOS";
		  LET v_desc_subramo = "";
    ELIF _cod_ramo = "013" THEN
		  LET v_desc_ramo = "RAMOS TECNICOS";
		  LET v_desc_subramo = "";
    ELIF _cod_ramo = "014" THEN
		  LET v_desc_ramo = "RAMOS TECNICOS";
		  LET v_desc_subramo = "";
    ELIF _cod_ramo = "022" THEN
		  LET v_desc_ramo = "RAMOS TECNICOS";
		  LET v_desc_subramo = "";
    ELIF _cod_ramo = "015" THEN
		  LET v_desc_ramo = "OTROS";
		  IF  _cod_subramo = '001' THEN
		  	LET v_desc_subramo = "RIESGOS VARIOS";
		  END IF
    ELIF _cod_ramo IN ("003", "017", "019") THEN
		  IF _cod_subramo = '001' THEN
			LET _orden_sub = 1;
		  ELIF _cod_subramo = '002' THEN
			LET _orden_sub = 2;
		  END IF
    END IF
	
IF _orig = 2  and trim(_cod_ramo_ext) <> trim(_cod_ramo) THEN
    --Prima suscrita
	let _pri_sus_ext = 0; 
	FOREACH
	 SELECT  c.pais_residencia,sum(e.prima_suscrita)
	   into _pais_residencia,_pri_sus_ext
	   FROM endedmae e, emipomae f ,cliclien c
	  WHERE e.no_poliza = f.no_poliza
		AND f.cod_origen = '002' 
		and f.cod_ramo = _cod_ramo
		and f.cod_contratante = c.cod_cliente
		AND e.periodo  = a_periodo
		AND e.actualizado = 1    and e.prima_suscrita <> 0
		group by c.pais_residencia
		
			BEGIN
			  ON EXCEPTION IN(-239, -268)
				 UPDATE ramozonaext
					SET pri_sus_ext  = pri_sus_ext + _pri_sus_ext
				  WHERE cod_ramo   = _cod_ramo
					 AND orden     = _orden
					 and pais_residencia = _pais_residencia;

			  END EXCEPTION
			  INSERT INTO ramozonaext(cod_ramo,orden,pais_residencia,pri_sus_ext)
				  VALUES(_cod_ramo,_orden,_pais_residencia,_pri_sus_ext);
			END	  
	END FOREACH	
	
	--Pago y Deducible 541
	let _pag_ded_541 = 0;
	FOREACH	
	 select c.pais_residencia,sum(t.monto)
	   into _pais_residencia,_pag_ded_541
	   from emipomae e, recrcmae r, rectrmae t   ,cliclien c
	  where e.no_poliza = r.no_poliza
		and r.no_reclamo = t.no_reclamo
		and e.cod_contratante = c.cod_cliente
		and t.actualizado = 1
		and t.periodo >= a_periodo
		and t.periodo <= a_periodo
		and t.cod_tipotran in ('004','007')
		and e.cod_origen = '002'
		and e.cod_ramo = _cod_ramo  
	  group by c.pais_residencia	

			BEGIN
			  ON EXCEPTION IN(-239, -268)
				 UPDATE ramozonaext
					SET pag_ded_541  = pag_ded_541 + _pag_ded_541
				  WHERE cod_ramo   = _cod_ramo
					 AND orden     = _orden
					 and pais_residencia = _pais_residencia;

			  END EXCEPTION
			  INSERT INTO ramozonaext(cod_ramo,orden,pais_residencia,pag_ded_541)
				  VALUES(_cod_ramo,_orden,_pais_residencia,_pag_ded_541);
			END	  
	END FOREACH		
	
	 --Salvamento y Recupero 419
	 let _salv_rec_419 = 0;
	FOREACH	
	 select c.pais_residencia,sum(t.monto)
	   into _pais_residencia,_salv_rec_419
	   from emipomae e, recrcmae r, rectrmae t   ,cliclien c
	  where e.no_poliza = r.no_poliza
		and r.no_reclamo = t.no_reclamo
		and e.cod_contratante = c.cod_cliente
		and t.actualizado = 1
		and t.periodo >= a_periodo
		and t.periodo <= a_periodo
		and t.cod_tipotran in ('005','006') 
		and e.cod_origen = '002'
		and e.cod_ramo = _cod_ramo  
	  group by c.pais_residencia	

			BEGIN
			  ON EXCEPTION IN(-239, -268)
				 UPDATE ramozonaext
					SET salv_rec_419  = salv_rec_419 + _salv_rec_419
				  WHERE cod_ramo   = _cod_ramo
					 AND orden     = _orden
					 and pais_residencia = _pais_residencia;

			  END EXCEPTION
			  INSERT INTO ramozonaext(cod_ramo,orden,pais_residencia,salv_rec_419)
				  VALUES(_cod_ramo,_orden,_pais_residencia,_salv_rec_419);
			END	  
	END FOREACH			
	
	 --Reserva en tramite 221
	 let _var_res_221 = 0;
	FOREACH	
	 select c.pais_residencia,sum(t.variacion)
	   into _pais_residencia,_var_res_221
	   from emipomae e, recrcmae r, rectrmae t   ,cliclien c
	  where e.no_poliza = r.no_poliza
		and r.no_reclamo = t.no_reclamo
		and e.cod_contratante = c.cod_cliente
		and t.actualizado = 1
		and t.periodo >= a_periodo
		and t.periodo <= a_periodo
		and e.cod_origen = '002'
		and e.cod_ramo = _cod_ramo  
	  group by c.pais_residencia	

			BEGIN
			  ON EXCEPTION IN(-239, -268)
				 UPDATE ramozonaext
					SET var_res_221  = var_res_221 + _var_res_221
				  WHERE cod_ramo   = _cod_ramo
					 AND orden     = _orden
					 and pais_residencia = _pais_residencia;

			  END EXCEPTION
			  INSERT INTO ramozonaext(cod_ramo,orden,pais_residencia,var_res_221)
				  VALUES(_cod_ramo,_orden,_pais_residencia,_var_res_221);
			END	  
	END FOREACH			
	
    LET _cod_ramo_ext = _cod_ramo;
END IF		
		

       RETURN  v_desc_subramo, v_cant_polizas, _prima_suscrita, v_desc_ramo, descr_cia, _mes, _orden, v_incurrido_bruto, _cnt_reclamo, _pago_y_ded, _salv_y_recup, _var_reserva, _cnt_cerra, v_cant_polizas_ma,
			   _cnt_prima_nva, _cnt_prima_ren, _cnt_prima_can, v_cant_asegurados, _orden_sub, _cnt_incurridos, _cnt_vencidas WITH RESUME;
END FOREACH
END PROCEDURE;