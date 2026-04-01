   DROP procedure sp_pro94c;
   CREATE procedure sp_pro94c(a_cia CHAR(03),a_agencia CHAR(3),a_periodo CHAR(7), a_periodo2 CHAR(7),a_origen CHAR(3) DEFAULT '%')
   RETURNING CHAR(50),INT,DECIMAL(16,2),CHAR(50),CHAR(45),INT,SMALLINT,DECIMAL(16,2),INTEGER,DECIMAL(16,2),DECIMAL(16,2),DECIMAL(16,2),integer,CHAR(8),integer,integer,integer,integer,integer,integer,integer;
--------------------------------------------
---  APADEA
---  INFORMACION ESTADISTICA MENSUAL 
---
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
    DEFINE v_cant_polizas,_cnt_reclamo,_cnt_cerra       INTEGER;
    DEFINE v_prima_suscrita,v_prima_retenida,
           _prima_suscrita,_prima_retenida,v_suma_asegurada,_total_pri_sus,v_incurrido_bruto   DECIMAL(16,2);
    DEFINE _tipo,_nueva_renov              CHAR(01);
    DEFINE v_filtros          CHAR(255);
	DEFINE _mes2,_mes,_ano2,_orden   SMALLINT;
	DEFINE _fecha2     	      DATE;
	define _cod_tipoprod	  char(3);
	DEFINE _vigencia_inic, _vig_fin_vida, _vig_ini_end     DATE;
	define _no_endoso         char(5);
	define li_dia,li_mes,li_anio smallint;
	define _salv_y_recup,_pago_y_ded,_var_reserva decimal(16,2);
	DEFINE _origen   CHAR(8);
	DEFINE _cnt_polizas_ma 	INTEGER;
	DEFINE _cnt_pol_nuevas 	INTEGER;
	DEFINE _cnt_pol_ren    	INTEGER;
	DEFINE _cnt_pol_can_cad INTEGER;
	DEFINE _cnt_asegurados  INTEGER;
	DEFINE _cnt_incurridos  INTEGER;
	DEFINE _cnt_vencidas	INTEGER;   



LET v_cod_ramo       = NULL;
LET v_cod_subramo    = NULL;
LET v_desc_subramo   = NULL;
LET v_cant_polizas   = 0;
LET v_prima_suscrita = 0;
LET _prima_suscrita  = 0;
LET _tipo            = NULL;
let _pago_y_ded      = 0;
let _salv_y_recup    = 0;
let _var_reserva     = 0;
let _cnt_cerra       = 0;
let _cnt_polizas_ma  = 0;
let _cnt_pol_nuevas  = 0;
let _cnt_pol_ren     = 0;
let _cnt_pol_can_cad = 0;
LET _cnt_vencidas    = 0;
LET _cnt_incurridos  = 0;
LET _cnt_asegurados  = 0;

SET ISOLATION TO DIRTY READ;

LET descr_cia = sp_sis01(a_cia);

LET _ano2 = a_periodo[1,4];
LET _mes2 = a_periodo[6,7];
LET _mes = _mes2;

IF _mes2 = 12 THEN
   LET _mes2 = 1;
   LET _ano2 = _ano2 + 1;
ELSE
   LET _mes2 = _mes2 + 1;
END IF

LET _fecha2 = MDY(_mes2,1,_ano2);
LET _fecha2 = _fecha2 - 1;

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
			  cnt_vencidas
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
			  _cnt_polizas_ma,
			  _cnt_pol_nuevas,
			  _cnt_pol_ren,
			  _cnt_pol_can_cad,
			  _cnt_asegurados,
			  _cnt_incurridos,
			  _cnt_vencidas
         FROM ramootro
	 ORDER BY orden,cod_ramo,cod_subramo

--	 if v_cant_polizas = 0 then
--		continue foreach;
--	 end if

       SELECT nombre
         INTO v_desc_ramo
         FROM prdramo
        WHERE cod_ramo = _cod_ramo;

       SELECT nombre
         INTO v_desc_subramo
         FROM prdsubra
        WHERE cod_ramo    = _cod_ramo
          AND cod_subramo = _cod_subramo;
		
	    if a_origen = '001' then
           let _origen = 'LOCAL';
		ELSE
		   let _origen = 'EXTERIOR';
		end if		
		
       RETURN  v_desc_subramo,
       		   v_cant_polizas,
               _prima_suscrita,
               v_desc_ramo,
               descr_cia,
			   _mes,
			   _orden,
			   v_incurrido_bruto,
			   _cnt_reclamo,
			   _pago_y_ded,
			  _salv_y_recup,
			  _var_reserva,
			  _cnt_cerra,
			  _origen,
			  _cnt_polizas_ma,
			  _cnt_pol_nuevas,
			  _cnt_pol_ren,
			  _cnt_pol_can_cad,
			  _cnt_asegurados,
			  _cnt_incurridos,
			  _cnt_vencidas
               WITH RESUME;
END FOREACH
END PROCEDURE;
