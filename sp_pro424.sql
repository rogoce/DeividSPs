   DROP procedure sp_pro424;
   CREATE procedure "informix".sp_pro424(a_cia CHAR(03),a_agencia CHAR(3),a_periodo CHAR(7))
   RETURNING INTEGER, CHAR(255);
--------------------------------------------
---  APADEA
---  INFORMACION ESTADISTICA MENSUAL
---
---  Amado Perez M. 02/02/2007
---  Modificado 12/03/2013 se agrega el ramo 022 de equipo pesado a Ramos Tecnicos
---  Ref. Power Builder
--------------------------------------------

    DEFINE v_cod_ramo,v_cod_subramo,_cod_ramo,_cod_subramo  CHAR(3);
    DEFINE v_desc_ramo        CHAR(50);
    DEFINE v_desc_subramo     CHAR(50);
    DEFINE descr_cia	      CHAR(45);
    DEFINE unidades2          SMALLINT;
    DEFINE _no_poliza,_no_reclamo         CHAR(10);
    DEFINE v_cant_polizas,_cnt_reclamo          INTEGER;
    DEFINE v_prima_suscrita,v_prima_retenida,
           _prima_suscrita,_prima_retenida,v_suma_asegurada,_total_pri_sus,v_incurrido_bruto   DECIMAL(16,2);
    DEFINE _tipo,_nueva_renov              CHAR(01);
    DEFINE v_filtros          CHAR(255);
	DEFINE _mes2,_mes,_ano2,_orden   SMALLINT;
	DEFINE _fecha2     	      DATE;
	DEFINE _cod_tipoprod	  char(3);
	DEFINE _cod_sucursal      char(3);
	DEFINE _prima_pma		  dec(16,2);
	DEFINE _prima_col		  dec(16,2);
	DEFINE _prima_chi		  dec(16,2);
	DEFINE _prima_her		  dec(16,2);
	DEFINE _prima_ver		  dec(16,2);
	DEFINE _prima_pmo		  dec(16,2);
	DEFINE _prima_otro		  dec(16,2);
	DEFINE _prima_ext     	  dec(16,2);
	DEFINE _incu_pma		  dec(16,2);
	DEFINE _incu_col		  dec(16,2);
	DEFINE _incu_chi		  dec(16,2);
	DEFINE _incu_her		  dec(16,2);
	DEFINE _incu_ver		  dec(16,2);
	DEFINE _incu_pmo		  dec(16,2);
	DEFINE _incu_otro		  dec(16,2);
	DEFINE _incu_ext		  dec(16,2);
	DEFINE _cod_cobertura     char(5);
	DEFINE _prima_neta		  dec(16,2);
	DEFINE _incurrido_bruto	  dec(16,2);
	DEFINE _prima_auto_part   dec(16,2);
	DEFINE _prima_auto_come   dec(16,2);
	DEFINE _incu_auto_part    dec(16,2);
	DEFINE _incu_auto_come    dec(16,2);
	DEFINE _no_endoso         char(5);
	DEFINE _cnt_poliza_p      int;
	DEFINE _cnt_poliza_c      int;
	define _cant_unidad       int;
	DEFINE _cnt_auto_p		  int;
	DEFINE _cnt_auto_c		  int;
	DEFINE _cnt_incu_p        int;
	DEFINE _cnt_incu_c        int;
	define _inc_bruto         dec(16,2);
	DEFINE _cantidad          int;
	DEFINE _cantidad_acu      int;
	DEFINE _cod_sub_cob, _cod_origen  CHAR(3);
	DEFINE _dif               dec(16,2);
	DEFINE _vig_fin_vida, _vigencia_inic, _vig_ini_end  date;
	define li_dia,li_mes,li_anio smallint;
	--DEFINE _no_unidad         INT;
	DEFINE _no_tranrec        char(10);
	DEFINE _cnt_r, _cnt_i, _cnt_e int;
	DEFINE _uso_auto          CHAR(1);
	DEFINE _no_unidad       CHAR(5);
	DEFINE _no_documento      CHAR(20);
	DEFINE _primero, _cnt_pol SMALLINT;
	define _error_desc		char(255); 
    define _error_isam		integer; 
    define _error			integer;	
	
    CREATE TEMP TABLE temp_perfil1(
              cod_ramo       CHAR(3),
              cod_subramo    CHAR(3),
              cant_polizas   INTEGER,
              PRIMARY KEY(cod_ramo,cod_subramo)) WITH NO LOG;

    CREATE TEMP TABLE temp_perfil2(
              cod_ramo       CHAR(3),
              cod_subramo    CHAR(3),
              nueva_renov    CHAR(1),
			  prima_suscrita DECIMAL(16,2),
              PRIMARY KEY(cod_ramo,cod_subramo)) WITH NO LOG;

    CREATE TEMP TABLE temp_cant_uni(
          cod_ramo       CHAR(3),
          cod_subramo    CHAR(3),
          cant_unidad   INTEGER,
          PRIMARY KEY(cod_ramo,cod_subramo)) WITH NO LOG;
		  
	CREATE TEMP TABLE tmp_unidad(
			  no_documento       CHAR(20),
			  no_unidad          CHAR(5),
			  uso_auto           CHAR(1),
			  cnt_pol            SMALLINT,
              PRIMARY KEY(no_documento, no_unidad)) WITH NO LOG;			  

LET v_cod_ramo       = NULL;
LET v_cod_subramo    = NULL;
LET v_desc_subramo   = NULL;
LET v_cant_polizas   = 0;
LET _cant_unidad     = 0;
LET v_prima_suscrita = 0;
LET _prima_suscrita  = 0;
LET _tipo            = NULL;
let _cantidad_acu    = 0;
let _error = 0; 
let _error_isam = 0;
let _error_desc = ' ';


SET ISOLATION TO DIRTY READ;
begin

on exception set _error,_error_isam,_error_desc
	return _error, _error_desc;
end exception

LET descr_cia = sp_sis01(a_cia);

-- Descomponer los periodos en fechas

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
--begin work;
--Crea tabla temp_ramo
--CALL sp_pr94a();

--trae cant. de polizas vig. temp_perfil
--CALL sp_pro95(
--a_cia,
--a_agencia,
--_fecha2,
--'*',
--'4;Ex') RETURNING v_filtros;

--trae primas suscritas del mes. tmp_prod, tmp_cobp
CALL sp_pro178b(
a_cia,
a_agencia,
a_periodo,
a_periodo,
'*',
'*',
'*',
'*',
'4;Ex',		--Reaseguro Asumido Excluido
'*'
) RETURNING v_filtros;

--Trae los siniestros brutos incurridos tmp_siniest
--Trae los siniestros brutos incurridos tmp_siniest
CALL sp_rec14(
a_cia,
a_agencia,
a_periodo,
a_periodo,
'001'
);

--CALL sp_pro178d(
--a_cia,
--a_agencia,
--a_periodo,
--a_periodo
--);

-- Excluye los Reclamos en Reaseguro Asumido

update tmp_siniest
   set seleccionado = 0
 where seleccionado = 1
   and cod_tipoprod = "004";

update tmp_siniest
   set cod_ramo = "002"
 where cod_ramo = "020";

update tmp_siniest
   set cod_ramo = "002"
 where cod_ramo = "023";

update tmp_siniest
   set cod_ramo = "001"
 where cod_ramo = "021";

{update temp_perfil
   set cod_ramo = '002'
 where cod_ramo = '023';

update temp_perfil
   set cod_ramo = '002'
 where cod_ramo = '020';

update temp_perfil
   set cod_ramo = '001'
 where cod_ramo = '021';
 
update temp_ramo
   set cod_ramo = '002'
 where cod_ramo = '023';

update temp_ramo
   set cod_ramo = '002'
 where cod_ramo = '020';

update temp_ramo
   set cod_ramo = '001'
 where cod_ramo = '021';}


DELETE FROM ssrpestm5 where periodo = a_periodo;

LET _prima_auto_part     = 0;
LET _prima_auto_come	 = 0;
LET _incu_auto_part 	 = 0;
LET _incu_auto_come 	 = 0;
LET _cnt_poliza_p        = 0;
LET _cnt_poliza_c        = 0;
LET _cnt_incu_p          = 0;
LET _cnt_incu_c          = 0;

FOREACH
 SELECT cod_ramo,
		total_pri_sus,
		no_poliza,
		no_endoso,
		cod_sucursal
   INTO _cod_ramo,
		_total_pri_sus,
		_no_poliza,
		_no_endoso,
		_cod_sucursal
   FROM tmp_prod
  WHERE	seleccionado = 1

  IF _cod_ramo = '020' THEN	  --soda
	LET _cod_ramo = '002';
  END IF

  IF _cod_ramo = '023' THEN	  --auto flotas
	LET _cod_ramo = '002';
  END IF

  IF _cod_ramo = '021' THEN	  --todo riesgo
	LET _cod_ramo = '001';
  END IF

  IF _total_pri_sus IS NULL THEN
  	LET _total_pri_sus = 0;
  END IF

  LET _prima_pma = 0;
  LET _prima_col = 0;
  LET _prima_chi = 0;
  LET _prima_her = 0;
  LET _prima_ver = 0;
  LET _prima_pmo = 0;
  LET _prima_otro = 0;
  LET _prima_ext = 0;

	-- Informacion de Poliza
   SELECT no_documento,
          nueva_renov,
   	      cod_subramo,
   	      cod_origen,
   	      vigencia_inic
     INTO _no_documento,
	      _nueva_renov,
		  _cod_subramo,
		  _cod_origen,
		  _vigencia_inic
     FROM emipomae
    WHERE no_poliza = _no_poliza;



	 -- Esta es para la parte de primas por sucursal

       IF _cod_ramo = "004" or _cod_ramo = "016" or _cod_ramo = "018" or _cod_ramo = "019" Then
	      LET _orden = 1;
	   ELIF _cod_ramo = "008" THEN
	      LET _orden = 3;
       ELSE
	      LET _orden = 2;
	   END IF

	   IF _cod_sucursal = '001' AND _cod_origen = "001" THEN
	   		LET _prima_pma = _total_pri_sus;
	   ELIF _cod_sucursal = '002' AND _cod_origen = "001" THEN
	   		LET _prima_col = _total_pri_sus;
	   ELIF _cod_sucursal = '003' AND _cod_origen = "001" THEN
	   		LET _prima_chi = _total_pri_sus;
	   ELIF _cod_sucursal = '007' AND _cod_origen = "001" THEN
	   		LET _prima_pmo = _total_pri_sus;
	   ELIF _cod_sucursal = '011' AND _cod_origen = "001" THEN
	   		LET _prima_ver = _total_pri_sus;
	   ELIF _cod_sucursal = '005' AND _cod_origen = "001" THEN
	   		LET _prima_her = _total_pri_sus;
	   ELSE
	   	    IF _cod_origen = "001" THEN
	   			LET _prima_pma = _total_pri_sus;
			ELSE
	   			LET _prima_ext = _total_pri_sus;
			END IF
	   END IF

       BEGIN
          ON EXCEPTION IN(-239, -268)
             UPDATE ssrpestm5
                SET prima_pma  = prima_pma + _prima_pma,
					prima_col  = prima_col + _prima_col,
					prima_chi  = prima_chi + _prima_chi,
					prima_pmo  = prima_pmo + _prima_pmo,
					prima_ver  = prima_ver + _prima_ver,
					prima_her  = prima_her + _prima_her,
					prima_otro = prima_otro + _prima_otro,
					prima_ext  = prima_ext + _prima_ext
              WHERE cod_ramo   = _cod_ramo
			    and periodo = a_periodo;
    --            AND orden2    = 1;

          END EXCEPTION
          INSERT INTO ssrpestm5
              VALUES(_cod_ramo,
			         _orden,
                     _prima_pma,
                     _prima_col,
                     _prima_chi,
					 _prima_her,
					 _prima_ver,
					 _prima_pmo,
					 _prima_otro,
					 0,
					 0,
					 0,
					 0,
					 0,
					 0,
					 0,
					 1,
					 _prima_ext,
					 0,
					 a_periodo
                     );
	   END

END FOREACH

--SET DEBUG FILE TO "sp_pro178.trc";
--trace on;

---RECLAMOS
FOREACH
	SELECT cod_ramo,
	       cod_subramo,
		   pago_y_ded,
		   no_poliza
	   INTO	_cod_ramo,
	        _cod_subramo,
			v_incurrido_bruto,
			_no_poliza
	   FROM	tmp_siniest
	  WHERE seleccionado = 1

    IF _cod_ramo = '020' THEN
		LET _cod_ramo = '002';
	END IF

    IF _cod_ramo = '023' THEN
		LET _cod_ramo = '002';
	END IF

	IF _cod_ramo = '021' THEN
		LET _cod_ramo = '001';
	END IF

	IF v_incurrido_bruto IS NULL THEN
		LET v_incurrido_bruto = 0;
	END IF

	LET _incu_pma = 0;
	LET _incu_col = 0;
	LET _incu_chi = 0;
	LET _incu_her = 0;
	LET _incu_ver = 0;
	LET _incu_pmo = 0;
	LET _incu_otro = 0;
	LET _incu_ext = 0;

    SELECT nueva_renov,
	       sucursal_origen,
		   cod_origen,
		   vigencia_inic
      INTO _nueva_renov,
	       _cod_sucursal,
		   _cod_origen,
		   _vigencia_inic
      FROM emipomae
     WHERE no_poliza = _no_poliza;



	 -- Esta es para la parte de siniestros por sucursal
       IF _cod_ramo = "004" or _cod_ramo = "016" or _cod_ramo = "018" or _cod_ramo = "019" Then
	      LET _orden = 1;
	   ELIF _cod_ramo = "008" THEN
	      LET _orden = 3;
       ELSE
	      LET _orden = 2;
	   END IF

	   IF _cod_sucursal = '001' THEN
	   		LET _incu_pma = v_incurrido_bruto;
	   ELIF _cod_sucursal = '002' THEN
	   		LET _incu_col = v_incurrido_bruto;
	   ELIF _cod_sucursal = '003' THEN
	   		LET _incu_chi = v_incurrido_bruto;
	   ELIF _cod_sucursal = '007' THEN
	   		LET _incu_pmo = v_incurrido_bruto;
	   ELIF _cod_sucursal = '011' THEN
	   		LET _incu_ver = v_incurrido_bruto;
	   ELIF _cod_sucursal = '005' THEN
	   		LET _incu_her = v_incurrido_bruto;
	   ELSE
	        IF _cod_origen = '001' THEN
	   			LET _incu_pma = v_incurrido_bruto;
			ELSE
	   			LET _incu_ext = v_incurrido_bruto;
			END IF
	   END IF

       {IF _cod_ramo = "001" and _cod_subramo = "004" THEN
            let _incu_pma = 0;
            let _incu_col  = 0;
            let _incu_chi  = 0;
		    let _incu_otro = 0;
	   end if}

       BEGIN
          ON EXCEPTION IN(-239, -268)
             UPDATE ssrpestm5
                SET incu_pma  = incu_pma  + _incu_pma,
					incu_col  = incu_col  + _incu_col,
					incu_chi  = incu_chi  + _incu_chi,
					incu_her  = incu_her  + _incu_her,
					incu_ver  = incu_ver  + _incu_ver,
					incu_pmo  = incu_pmo  + _incu_pmo,
					incu_otro = incu_otro + _incu_otro,
					incu_ext  = incu_ext  + _incu_ext
              WHERE cod_ramo  = _cod_ramo
                AND orden2    = 1
				and periodo   = a_periodo;

          END EXCEPTION
          INSERT INTO ssrpestm5
              VALUES(_cod_ramo,
			         _orden,
					 0,
					 0,
					 0,
					 0,
					 0,
					 0,
					 0,
                     _incu_pma,
                     _incu_col,
                     _incu_chi,
                     _incu_her,
                     _incu_ver,
                     _incu_pmo,
					 _incu_otro,
					 1,
					 0,
					 _incu_ext,
					 a_periodo
                     );
	   END


END FOREACH

  
DROP TABLE if exists temp_perfil;
DROP TABLE if exists temp_perfil1;
DROP TABLE if exists temp_perfil2;
DROP TABLE if exists tmp_prod;
DROP TABLE if exists temp_ramo;
DROP TABLE if exists tmp_siniest;
DROP TABLE if exists tmp_sinis;
DROP TABLE if exists tmp_cobp;
DROP TABLE if exists tmp_inc_cob;
DROP TABLE if exists temp_cant_uni;
DROP TABLE if exists tmp_unidad;

if _error <> 0 then
	return _error,_error_desc;
else
	let _error_desc = 'EXITO';
    return _error,_error_desc;
end if
end
--commit work;
END PROCEDURE 
                                                               
