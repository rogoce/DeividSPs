   --Hoja C - Factor Cliente
   --Estadistico para la superintendencia
   --  Armando Moreno M. 09/03/2017
   
   --DROP procedure sp_super01_esp1;
   CREATE procedure sp_super01_esp1(a_cia CHAR(03),a_agencia CHAR(3),a_periodo CHAR(7), a_periodo2 CHAR(7), a_origen CHAR(3) DEFAULT '%')
   RETURNING smallint,char(11),char(1),integer,integer,dec(16,2);
   
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
	DEFINE _cnt_cerra,_cantidad            INTEGER;
	define _cod_origen        CHAR(3);
	DEFINE v_cant_polizas_ma, _cnt_prima_nva, _cnt_prima_ren, _cnt_prima_can, _cnt_pol_dif, _cantidad_aseg, v_cant_asegurados  INTEGER;
	define _cnt_pol integer;
	define _cod_contratante char(10);
	define _cliente_pep smallint;
	define _tipo_persona char(1);
	define _cod_asegurado,_cod_pagador char(10);
	define _n_origen char(11);
	define _porc_partic_ben, _beneficio, _suma_asegurada dec(16,2);
	define _cnt integer;
	define _no_unidad char(5);
	define _cod_cliente  char(10);
	define _naciona      varchar(50);
	--define _cnt_pol_n,_cnt_ase_n,_cnt_pol_j,_cnt_ase_j integer;
	

      CREATE TEMP TABLE temp_asegurado(
              cod_asegurado    CHAR(10),
			  prima_suscrita   DECIMAL(16,2),
			  cant_pol         integer)
              WITH NO LOG;
	CREATE INDEX i_perf6 ON temp_asegurado(cod_asegurado);
	
   
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
let _naciona         = "";

SET ISOLATION TO DIRTY READ;
LET descr_cia = sp_sis01(a_cia);
-- Descomponer los periodos en fechas
LET _ano2 = a_periodo2[1,4];
LET _mes2 = a_periodo2[6,7];
LET _mes = _mes2;

IF _mes2 = 12 THEN
   LET _mes2 = 1;
   LET _ano2 = _ano2 + 1;
ELSE
   LET _mes2 = _mes2 + 1;
END IF
LET _fecha2 = MDY(_mes2,1,_ano2);
LET _fecha2 = _fecha2 - 1;

let _fecha2 = current;

--trae cant. de polizas vig. temp_perfil
CALL sp_pro95a(
a_cia,
a_agencia,
_fecha2,
'*',
'4;Ex',
a_origen) RETURNING v_filtros;

--SACAR TODOS LOS ASEGURADOS
let _cnt_pol = 0;
foreach
	select distinct no_poliza
	  into _no_poliza
	  from temp_perfil
	 where seleccionado = 1

    let _cnt_pol = 1;
	
	foreach
		select cod_asegurado, prima_suscrita
		  into _cod_asegurado,_prima_suscrita
		  from emipouni
		 where no_poliza = _no_poliza
		   and (activo = 1 or (activo = 0 and no_activo_desde > _fecha2))
		 
		insert into temp_asegurado(cod_asegurado,prima_suscrita,cant_pol)
		values(_cod_asegurado,_prima_suscrita,_cnt_pol);
		let _cnt_pol = 0; 
	end foreach
end foreach
--drop table temp_asegurado;
END PROCEDURE;