   DROP procedure sp_pro415;
   CREATE procedure "informix".sp_pro415(a_cia CHAR(03),a_agencia CHAR(3),a_periodo CHAR(7), a_periodo2 CHAR(7), a_origen CHAR(3) DEFAULT '%')
   RETURNING CHAR(50),INT,DECIMAL(16,2),CHAR(50),CHAR(45),INT,SMALLINT,DECIMAL(16,2),INTEGER,DECIMAL(16,2),DECIMAL(16,2),DECIMAL(16,2),INTEGER,INTEGER,INTEGER,INTEGER,INTEGER,INTEGER,SMALLINT;
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
	DEFINE v_cant_polizas_ma, _cnt_prima_nva, _cnt_prima_ren, _cnt_prima_can, _cnt_pol_dif, _cantidad_aseg, v_cant_asegurados  INTEGER;
	DEFINE _orig SMALLINT;
	DEFINE _orden_sub smallint;

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

-- Descomponer los periodos en fechas
LET descr_cia = sp_sis01(a_cia);
LET _ano2 = a_periodo[1,4];
LET _mes2 = a_periodo[6,7];
LET _mes = _mes2;

{IF a_origen = '001' THEN
 let _orig = 1;
ELSE
 let _orig = 2;
END IF}

FOREACH
        SELECT cod_ramo,
			   cod_subramo,
			   sum(cnt_polizas),
			   sum(prima_suscrita),
			   orden,
			   sum(incurrido_bruto),
			   sum(cnt_reclamo),
		       sum(salv_rec),
			   sum(pago_ded),
			   sum(var_reserva),
			   sum(casos_cerrados),
			   sum(cnt_polizas_ma),
			   sum(cnt_pol_nuevas),
			   sum(cnt_pol_ren),
			   sum(cnt_pol_can_cad),
			   sum(cnt_asegurados)
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
			   v_cant_asegurados
          FROM ssrpestm1
		 WHERE periodo = a_periodo
		  -- AND origen = _orig
	  GROUP BY orden,cod_ramo,cod_subramo
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
    ELIF _cod_ramo = "002" THEN
		  LET v_desc_subramo = "";
    --ELIF _cod_ramo = "006" THEN
	--	  LET v_desc_subramo = "";
    ELIF _cod_ramo = "008" THEN
		  LET v_desc_subramo = "";
		  let _orden  = 12;
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
		  	  LET _orden  = 11;	
			  LET v_desc_ramo = "RIESGOS DIVERSOS";
			  LET v_desc_subramo = "EQUIPO PESADO";
			  LET _orden_sub = 5;
		  ELIF _cod_subramo = "006" THEN
		  	  LET _orden  = 11;	
			  LET v_desc_ramo = "RIESGOS DIVERSOS";
			  LET v_desc_subramo = "OTROS";
			  --LET v_desc_subramo = "VIDRIOS";
			  LET _orden_sub = 1;			  
		  ELSE
			  LET v_desc_subramo = "";
			  LET _orden_sub = 6;
		  END IF
    {ELIF _cod_ramo = "011" THEN
		  LET v_desc_ramo = "RAMOS TECNICOS";
		  LET v_desc_subramo = "";}
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
    ELIF _cod_ramo = "006" THEN
		  let _orden  = 11;	
		  LET v_desc_ramo = "RIESGOS DIVERSOS";
		  IF  _cod_subramo = '001' THEN
		  	  LET v_desc_subramo = "RESPONSABILIDAD CIVIL";
--  ELIF  _cod_subramo = '001' THEN
--		  	LET v_desc_subramo = "RESPONSABILIDAD CIVIL";			
		  END IF
    ELIF _cod_ramo = "005" THEN
		  let _orden  = 11;	
		  LET v_desc_ramo = "RIESGOS DIVERSOS";
		  IF  _cod_subramo = '001' THEN
		  	LET v_desc_subramo = "ROBO";
		  END IF
	ELIF _cod_ramo = "015" THEN
		  let _orden  = 11;
		  LET v_desc_ramo = "RIESGOS DIVERSOS";
		  IF  _cod_subramo = '001' THEN
		  	LET v_desc_subramo = "OTROS";
		  END IF
    ELIF _cod_ramo IN ("003", "017", "019") THEN
		  IF _cod_subramo = '001' THEN
			LET _orden_sub = 1;
		  ELIF _cod_subramo = '002' THEN
			LET _orden_sub = 2;
		  END IF
	ELIF _cod_ramo = "011" THEN
		  LET _orden  = 11;
		  LET v_desc_ramo = "RIESGOS DIVERSOS";
		  LET v_desc_subramo = "";
		  IF  _cod_subramo = "002" THEN
			  LET v_desc_subramo = "ROBO";
		  ELIF _cod_subramo = "003" THEN
			  LET v_desc_subramo = "FIDELIDAD Y DDD";
		  ELIF _cod_subramo = "004" THEN
			  LET v_desc_subramo = "BBB";
		  ELSE
			  LET v_desc_subramo = "OTROS";
		  END IF
		  
    END IF
   
   
       RETURN  v_desc_subramo, v_cant_polizas, _prima_suscrita, v_desc_ramo, descr_cia, _mes, _orden, v_incurrido_bruto, _cnt_reclamo, _pago_y_ded, _salv_y_recup, _var_reserva, _cnt_cerra, v_cant_polizas_ma,
			   _cnt_prima_nva, _cnt_prima_ren, _cnt_prima_can, v_cant_asegurados, _orden_sub WITH RESUME;
END FOREACH
END PROCEDURE;