   DROP procedure sp_pro1028; 
   CREATE procedure "informix".sp_pro1028(a_cia CHAR(03),a_agencia CHAR(3),a_periodo CHAR(7), a_periodo2 CHAR(7), a_origen CHAR(3) DEFAULT '%')
  -- RETURNING CHAR(50),INT,DECIMAL(16,2),CHAR(50),CHAR(45),INT,SMALLINT,DECIMAL(16,2),INTEGER,DECIMAL(16,2),DECIMAL(16,2),DECIMAL(16,2),INTEGER,INTEGER,INTEGER,INTEGER,INTEGER,INTEGER,INTEGER,INTEGER;
   returning
		Char(50) as pais_provincia,
		INTEGER  as per_cnt_polizas, 			 			 
		INTEGER as per_cnt_asegurados, 			 
		INTEGER as gen_cnt_polizas, 			 			 
		INTEGER as gen_cnt_asegurados, 			 			 
		INTEGER as fia_cnt_polizas, 			 			 
		INTEGER as fia_cnt_asegurados, 			 			 			 
		INTEGER as tot_cnt_polizas, 			 			 
		INTEGER as tot_cnt_asegurados,
		CHAR(45) as descr_cia;	 
--------------------------------------------
---  APADEA
---  INFORMACION ESTADISTICA MENSUAL 
---  Armando Moreno M. 21/02/2002
---  Modificado: Amado Perez M. 12/03/2013 -- Se agrega el ramo 022 de equipo pesado a Ramos Tecnicos
---  Ref. Power Builder - d_sp_pro03b
--------------------------------------------
    DEFINE v_cod_ramo,v_cod_subramo,_cod_ramo,_cod_subramo,_cod_tiporamo  CHAR(3);
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
	define _cod_origen,_codigo_agencia        CHAR(3);
	DEFINE v_cant_polizas_ma, _cnt_prima_nva, _cnt_prima_ren, _cnt_prima_can, _cnt_pol_dif, _cantidad_aseg, v_cant_asegurados, _cnt_incurrido, _cnt_vencidas, _retorno INTEGER;
	
	DEFINE _per_cnt_polizas    INTEGER;
	DEFINE _per_cnt_asegurados    INTEGER;
	DEFINE _gen_cnt_polizas    INTEGER;
	DEFINE _gen_cnt_asegurados    INTEGER;
	DEFINE _fia_cnt_polizas    INTEGER;
	DEFINE _fia_cnt_asegurados    INTEGER;
	DEFINE _tot_cnt_polizas    INTEGER;
	DEFINE _tot_cnt_asegurados    INTEGER;
	define _pais_provincia   char(50);
	define _pais_residencia   char(50);
	define _cod_contratante   char(10);	
	define _nom_sucursal	char(50);	
	define _cod_sucursal   char(3);
	
	
    CREATE TEMP TABLE temp_perfil1(
              cod_ramo       CHAR(3),
              cod_subramo    CHAR(3),
              cant_polizas    INT,
              cant_polizas_ma INT,
			  cant_asegurados INT,
              PRIMARY KEY(cod_ramo,cod_subramo)) WITH NO LOG;

    CREATE TEMP TABLE temp_perfil2(
              cod_ramo       CHAR(3),
              cod_subramo    CHAR(3),
              nueva_renov    CHAR(1),
			  prima_suscrita DECIMAL(16,2),
			  cnt_pol_nuevas  INT,
			  cnt_pol_ren     INT,
			  cnt_pol_can_cad INT,
              PRIMARY KEY(cod_ramo,cod_subramo)) WITH NO LOG;
			  
	CREATE  TEMP TABLE ramosubr_3 (
	         cod_ramo CHAR(3) NOT NULL, 
			 cod_subramo CHAR(3) NOT NULL, 
			 pais_provincia Char(50) not null,
			 per_cnt_polizas INTEGER DEFAULT  0, 			 			 
			 per_cnt_asegurados INTEGER DEFAULT  0, 			 
			 gen_cnt_polizas INTEGER DEFAULT  0, 			 			 
			 gen_cnt_asegurados INTEGER DEFAULT  0, 			 			 
			 fia_cnt_polizas INTEGER DEFAULT  0, 			 			 
			 fia_cnt_asegurados INTEGER DEFAULT  0, 			 			 			 
			 tot_cnt_polizas INTEGER DEFAULT  0, 			 			 
			 tot_cnt_asegurados INTEGER DEFAULT  0, 			 			 			 			 
             PRIMARY KEY(cod_ramo,cod_subramo,pais_provincia)) WITH NO LOG;				  			 
CREATE INDEX iend1_ramosubr_3 ON ramosubr_3(cod_ramo);
CREATE INDEX iend2_ramosubr_3 ON ramosubr_3(cod_subramo);			  
CREATE INDEX iend3_ramosubr_3 ON ramosubr_3(pais_provincia);				  

LET _per_cnt_polizas = 0;
LET _per_cnt_asegurados  = 0;
LET _gen_cnt_polizas = 0;
LET _gen_cnt_asegurados = 0;
LET _fia_cnt_polizas = 0;	
LET _fia_cnt_asegurados  = 0;	
LET _tot_cnt_polizas = 0;
LET _tot_cnt_asegurados = 0;	

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
--Crea tabla temp_ramo
CALL sp_pr94a();
--trae cant. de polizas vig. temp_perfil
CALL sp_pro95(
a_cia,
a_agencia,
_fecha2,
'*',
'4;Ex',
a_origen) RETURNING v_filtros;
--SET DEBUG FILE TO "sp_pro94.trc"; 
--trace on;

LET _ano1 = a_periodo[1,4];
LET _mes1 = a_periodo[6,7];


if a_periodo <> a_periodo2 then
	IF _mes1 = 1 AND _mes = 3 THEN
		LET _mes1 = 12;
		LET _ano1 = _ano1 - 1;
	END IF
	IF _mes1 = 4 AND _mes = 6 THEN
		LET _mes1 = 03;
	END IF
	IF _mes1 = 7 AND _mes = 9 THEN
		LET _mes1 = 6;
	END IF
	IF _mes1 = 10 AND _mes = 12 THEN
		LET _mes1 = 9;
	END IF
	IF _mes1 = 12 THEN
	   LET _mes1 = 1;
	   LET _ano1 = _ano1 + 1;
	ELSE
	   LET _mes1 = _mes1 + 1;
	END IF
end if
LET _fecha1 = MDY(_mes1,1,_ano1);
LET _fecha1 = _fecha1 - 1;

--trace off;

--trae cant. de polizas vig. del mes anterior temp_perfil_b
CALL sp_pro95b(
a_cia,
a_agencia,
_fecha1,
'*',
'4;Ex',
a_origen) RETURNING v_filtros;
-- Prima Suscrita tmp_prod
CALL sp_pr26h(
a_cia,
a_agencia,
a_periodo,
a_periodo2,
'*',
'*',
'*',
'*',
'4;Ex',		--Reaseguro Asumido Excluido
'*',
'*',
'*',
a_origen
) RETURNING v_filtros;
--Trae los siniestros brutos incurridos tmp_siniest
CALL sp_rec14(
a_cia,
a_agencia,
a_periodo,
a_periodo2,
a_origen
);
-- Excluye los Reclamos en Reaseguro Asumido
update tmp_siniest
   set seleccionado = 0
 where seleccionado = 1
   and cod_tipoprod = "004";

update tmp_siniest
   set cod_ramo = '002'
 where cod_ramo = '020';

update tmp_siniest
   set cod_ramo = '002'
 where cod_ramo = '023';

update tmp_siniest
   set cod_ramo = '001'
 where cod_ramo = '021';

update temp_perfil
   set cod_ramo = '002'
 where cod_ramo = '023';

update temp_perfil_b
   set cod_ramo = '002'
 where cod_ramo = '023';
 
 update temp_perfil
   set cod_ramo = '002'
 where cod_ramo = '020';

update temp_perfil_b
   set cod_ramo = '002'
 where cod_ramo = '020';
--Trae la cant. de reclamos por ramo --tmp_sinis
{CALL sp_rec03(
a_cia, 
a_periodo, 
a_periodo2, "*", "*", "*", "*", "*",
a_origen
) RETURNING v_filtros;}
CALL sp_pro942(
a_cia, 
a_periodo2,
a_origen
);

update tmp_sinis
   set cod_ramo = '002'
 where cod_ramo = '020';

update tmp_sinis
   set cod_ramo = '002'
 where cod_ramo = '023';

update tmp_sinis
   set cod_ramo = '001'
 where cod_ramo = '021';

update tmp_sinis
   set seleccionado = 0
 where seleccionado = 1
   and cod_tipoprod = "004";
 
UPDATE ramosubr
   SET prima_suscrita  = 0, cnt_polizas = 0, cnt_reclamo = 0, incurrido_bruto = 0, pago_ded = 0, salv_rec = 0, var_reserva = 0, casos_cerrados  = 0,
	   cnt_polizas_ma  = 0, cnt_pol_nuevas  = 0, cnt_pol_ren = 0, cnt_pol_can_cad = 0, cnt_asegurados = 0, cnt_incurridos = 0, cnt_vencidas = 0;
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

	-- Informacion de Poliza
   SELECT nueva_renov, cod_subramo, vigencia_inic
     INTO _nueva_renov, _cod_subramo, _vigencia_inic
     FROM emipomae
    WHERE no_poliza = _no_poliza;

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
        SET prima_suscrita = prima_suscrita + _total_pri_sus, cnt_pol_nuevas  = cnt_pol_nuevas + _cnt_prima_nva, cnt_pol_ren = cnt_pol_ren + _cnt_prima_ren, cnt_pol_can_cad  = cnt_pol_can_cad + _cnt_prima_can
      WHERE cod_ramo     = _cod_ramo
        AND cod_subramo  = "001";
   END IF	

  -- IF _cod_ramo = "019" AND (_vig_fin_vida <= _vig_ini_end or _nueva_renov = "R") THEN --Amado 02/06/2017
  IF _cod_ramo = "019" AND _nueva_renov = "R" THEN
     UPDATE ramosubr
        SET prima_suscrita = prima_suscrita + _total_pri_sus, cnt_pol_nuevas = cnt_pol_nuevas + _cnt_prima_nva, cnt_pol_ren = cnt_pol_ren + _cnt_prima_ren, cnt_pol_can_cad = cnt_pol_can_cad + _cnt_prima_can
      WHERE cod_ramo     = _cod_ramo
        AND cod_subramo  = "002";
		
--     UPDATE ramosubr
--        SET prima_suscrita = prima_suscrita + _total_pri_sus, cnt_pol_nuevas = cnt_pol_nuevas + _cnt_prima_nva, cnt_pol_can_cad = cnt_pol_can_cad + _cnt_prima_can
--       WHERE cod_ramo     = _cod_ramo
--        AND cod_subramo  = "002";

--     UPDATE ramosubr
--        SET cnt_pol_nuevas = cnt_pol_nuevas + _cnt_prima_ren
--      WHERE cod_ramo     = _cod_ramo
--        AND cod_subramo  = "001";
	END IF
   IF _cod_ramo = '004' OR _cod_ramo = '018' THEN
		select count(*)
		  into _cantidad
		  from emipouni
		 where no_poliza = _no_poliza;
		 
		IF _cantidad > 1 then
			UPDATE ramosubr
			   SET prima_suscrita  = prima_suscrita + _total_pri_sus, cnt_pol_nuevas = cnt_pol_nuevas + _cnt_prima_nva, cnt_pol_ren = cnt_pol_ren + _cnt_prima_ren, cnt_pol_can_cad = cnt_pol_can_cad + _cnt_prima_can
 			 WHERE cod_ramo        = _cod_ramo
			   AND cod_subramo     = "002";
		ELSE
			UPDATE ramosubr
			   SET prima_suscrita  = prima_suscrita + _total_pri_sus, cnt_pol_nuevas = cnt_pol_nuevas + _cnt_prima_nva,	cnt_pol_ren = cnt_pol_ren + _cnt_prima_ren,	cnt_pol_can_cad = cnt_pol_can_cad + _cnt_prima_can
 			 WHERE cod_ramo        = _cod_ramo
			   AND cod_subramo     = "001";		
		END IF
		 
	END IF
	IF _cod_ramo = "014" OR _cod_ramo = "013" THEN	--car y montaje
		UPDATE ramosubr
		   SET prima_suscrita  = prima_suscrita + _total_pri_sus, cnt_pol_nuevas  = cnt_pol_nuevas  + _cnt_prima_nva, cnt_pol_ren = cnt_pol_ren + _cnt_prima_ren, cnt_pol_can_cad  = cnt_pol_can_cad + _cnt_prima_can
 	     WHERE cod_ramo        = '010'
		   AND cod_subramo     = "001";
	END IF
	IF _cod_ramo = "010" THEN --equio electronico
		UPDATE ramosubr
		   SET prima_suscrita  = prima_suscrita + _total_pri_sus, cnt_pol_nuevas = cnt_pol_nuevas  + _cnt_prima_nva, cnt_pol_ren = cnt_pol_ren + _cnt_prima_ren, cnt_pol_can_cad  = cnt_pol_can_cad + _cnt_prima_can
 		 WHERE cod_ramo        = '010'
		   AND cod_subramo     = "002";
	END IF
	IF _cod_ramo = "012" THEN	--calderas
		UPDATE ramosubr
		   SET prima_suscrita  = prima_suscrita + _total_pri_sus, cnt_pol_nuevas = cnt_pol_nuevas  + _cnt_prima_nva, cnt_pol_ren = cnt_pol_ren + _cnt_prima_ren, cnt_pol_can_cad = cnt_pol_can_cad + _cnt_prima_can
 	     WHERE cod_ramo        = '010'
		   AND cod_subramo     = "003";
	END IF
	IF _cod_ramo = "011" THEN	--rotura de maquinaria
		UPDATE ramosubr
		   SET prima_suscrita  = prima_suscrita + _total_pri_sus, cnt_pol_nuevas = cnt_pol_nuevas  + _cnt_prima_nva, cnt_pol_ren = cnt_pol_ren + _cnt_prima_ren, cnt_pol_can_cad = cnt_pol_can_cad + _cnt_prima_can
 	     WHERE cod_ramo        = '010'
		   AND cod_subramo     = "004";
	END IF
	IF _cod_ramo = "022" THEN	--equipo pesado
		UPDATE ramosubr
		   SET prima_suscrita = prima_suscrita + _total_pri_sus, cnt_pol_nuevas = cnt_pol_nuevas  + _cnt_prima_nva,	cnt_pol_ren = cnt_pol_ren + _cnt_prima_ren, cnt_pol_can_cad = cnt_pol_can_cad + _cnt_prima_can
 	     WHERE cod_ramo        = '010'
		   AND cod_subramo     = "005";
	END IF
	IF _cod_ramo = "007" THEN	--vidrios
		UPDATE ramosubr
		   SET prima_suscrita  = prima_suscrita + _total_pri_sus, cnt_pol_nuevas = cnt_pol_nuevas  + _cnt_prima_nva, cnt_pol_ren = cnt_pol_ren + _cnt_prima_ren, cnt_pol_can_cad = cnt_pol_can_cad + _cnt_prima_can
 	     WHERE cod_ramo        = '010'
		   AND cod_subramo     = "006";
	END IF
	IF _cod_ramo = "008" THEN
      IF _cod_subramo = "002" OR _cod_subramo = "003" OR _cod_subramo = "018" THEN
			UPDATE ramosubr
			   SET prima_suscrita  = prima_suscrita + _total_pri_sus, cnt_pol_nuevas = cnt_pol_nuevas + _cnt_prima_nva,	cnt_pol_ren = cnt_pol_ren + _cnt_prima_ren,	cnt_pol_can_cad = cnt_pol_can_cad + _cnt_prima_can
 			 WHERE cod_ramo        = _cod_ramo
			   AND cod_subramo     = "001";
	  else
			UPDATE ramosubr
			   SET prima_suscrita  = prima_suscrita + _total_pri_sus, cnt_pol_nuevas = cnt_pol_nuevas + _cnt_prima_nva, cnt_pol_ren = cnt_pol_ren + _cnt_prima_ren,	cnt_pol_can_cad  = cnt_pol_can_cad + _cnt_prima_can
 			 WHERE cod_ramo        = _cod_ramo
			   AND cod_subramo     = "002";
	  end if
	END IF  
	if _cod_ramo = '009' and _cod_subramo in('001','002','006') then
			UPDATE ramosubr
			   SET prima_suscrita  = prima_suscrita + _total_pri_sus, cnt_pol_nuevas = cnt_pol_nuevas + _cnt_prima_nva,	cnt_pol_ren = cnt_pol_ren + _cnt_prima_ren,	cnt_pol_can_cad  = cnt_pol_can_cad + _cnt_prima_can
 			 WHERE cod_ramo        = _cod_ramo
			   AND cod_subramo     = "002";
	end if
	if _cod_ramo = '009' and _cod_subramo = '003' then	
			UPDATE ramosubr
			   SET prima_suscrita  = prima_suscrita + _total_pri_sus, cnt_pol_nuevas = cnt_pol_nuevas + _cnt_prima_nva,	cnt_pol_ren = cnt_pol_ren + _cnt_prima_ren, cnt_pol_can_cad = cnt_pol_can_cad + _cnt_prima_can
 			 WHERE cod_ramo        = _cod_ramo
			   AND cod_subramo     = "003";
	end if
	if _cod_ramo = '009' and _cod_subramo in ('004', '008') then --> Se incluye el subramo 008 MARINE CARGO STP
			UPDATE ramosubr
			   SET prima_suscrita  = prima_suscrita + _total_pri_sus, cnt_pol_nuevas   = cnt_pol_nuevas  + _cnt_prima_nva, cnt_pol_ren = cnt_pol_ren + _cnt_prima_ren, cnt_pol_can_cad  = cnt_pol_can_cad + _cnt_prima_can
			 WHERE cod_ramo        = _cod_ramo
			   AND cod_subramo     = "004";
	end if
	   BEGIN
          ON EXCEPTION IN(-239)
             UPDATE temp_perfil2
                SET prima_suscrita = prima_suscrita + _total_pri_sus, cnt_pol_nuevas = cnt_pol_nuevas  + _cnt_prima_nva, cnt_pol_ren = cnt_pol_ren + _cnt_prima_ren, cnt_pol_can_cad  = cnt_pol_can_cad + _cnt_prima_can
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
					 _cnt_prima_can
                     );
       END
END FOREACH
--Cargando las polizas vigentes, ramos: 019, 004, 018, 014, 013, 010, 012, 011, 022, 007, 008, 009
FOREACH WITH HOLD
   SELECT no_poliza, cod_ramo, cod_subramo
     INTO _no_poliza, v_cod_ramo, v_cod_subramo
     FROM temp_perfil
    WHERE seleccionado = 1

    SELECT nueva_renov, vigencia_inic, sucursal_origen, cod_contratante, cod_origen
      INTO _nueva_renov, _vigencia_inic, _cod_sucursal, _cod_contratante, _cod_origen	  
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
   
   	-- Insercion a la tabla temporal 
		LET _per_cnt_polizas = 0;
		LET _per_cnt_asegurados  = 0;
		LET _gen_cnt_polizas = 0;
		LET _gen_cnt_asegurados = 0;
		LET _fia_cnt_polizas = 0;	
		LET _fia_cnt_asegurados  = 0;	
		LET _tot_cnt_polizas = 0;
		LET _tot_cnt_asegurados = 0;	
	
	select trim(cod_tiporamo) 
	  into _cod_tiporamo
	  from prdramo
	  where cod_ramo = v_cod_ramo;	  	  
	  
	    if _cod_tiporamo = '001' then
			LET _per_cnt_polizas = 1;
			LET _per_cnt_asegurados  = _cantidad_aseg;
			LET _gen_cnt_polizas = 0;
			LET _gen_cnt_asegurados = 0;
			LET _fia_cnt_polizas = 0;	
			LET _fia_cnt_asegurados  = 0;	
			LET _tot_cnt_polizas = 1;
			LET _tot_cnt_asegurados = _cantidad_aseg;		
		end if			  
	    if _cod_tiporamo = '002' then
			LET _per_cnt_polizas = 0;
			LET _per_cnt_asegurados  = 0;
			LET _gen_cnt_polizas = 1;
			LET _gen_cnt_asegurados = _cantidad_aseg;
			LET _fia_cnt_polizas = 0;	
			LET _fia_cnt_asegurados  = 0;	
			LET _tot_cnt_polizas = 1;
			LET _tot_cnt_asegurados = _cantidad_aseg;		
		end if			  
	    if _cod_tiporamo = '003' then
			LET _per_cnt_polizas = 0;
			LET _per_cnt_asegurados  = 0;
			LET _gen_cnt_polizas = 0;
			LET _gen_cnt_asegurados = 0;
			LET _fia_cnt_polizas = 1;	
			LET _fia_cnt_asegurados  = _cantidad_aseg;	
			LET _tot_cnt_polizas = 1;
			LET _tot_cnt_asegurados = _cantidad_aseg;		
		end if			  		
		let _pais_provincia = '';
		
		IF a_origen = "001" THEN			
			  
			select codigo_agencia, trim(upper(nvl(descripcion,'')))
			  into _codigo_agencia, _nom_sucursal
			  from insagen
			 where codigo_agencia  = _cod_sucursal
			   and codigo_compania = '001';	  	   			
			   LET _pais_provincia = _nom_sucursal;			   
			   
				if _codigo_agencia in ('003','005','002') then 
				else
					if _codigo_agencia in ('007') then 
						LET  _nom_sucursal = 'PANAMÁ OESTE' ;
					else
						if _codigo_agencia in ('011') then 
							LET  _nom_sucursal = 'VERAGUAS' ;
						else
							LET  _nom_sucursal = 'PANAMA' ;
					    end if					   
				    end if					   
				end if					   
			   
				if _nom_sucursal  is null  then 
					LET  _nom_sucursal = 'PANAMA' ;
				else
					 LET _pais_provincia = _nom_sucursal;
				end if			   
		ELSE	   						
				select nvl(trim(pais_residencia),'')
				into _pais_residencia
				from cliclien
				where cod_cliente = _cod_contratante;															
				
                if _pais_residencia  is null or _pais_residencia = '' then 				
					LET  _pais_residencia = 'PANAMA' ;
				end if
                if upper(_pais_residencia) in ('PANAMA','PANAMÁ') then 				
					LET  _pais_residencia = 'PANAMA' ;
				end if				
				LET _pais_provincia = _pais_residencia;
		END IF		
		
		BEGIN
          ON EXCEPTION IN(-239, -268)
             UPDATE ramosubr_3
                SET per_cnt_polizas  = per_cnt_polizas + _per_cnt_polizas,
					per_cnt_asegurados  = per_cnt_asegurados + _per_cnt_asegurados,					
					gen_cnt_polizas  = gen_cnt_polizas + _gen_cnt_polizas,
					gen_cnt_asegurados  = gen_cnt_asegurados + _gen_cnt_asegurados,					
					fia_cnt_polizas  = fia_cnt_polizas + _fia_cnt_polizas,
					fia_cnt_asegurados  = fia_cnt_asegurados + _fia_cnt_asegurados,					
					tot_cnt_polizas  = tot_cnt_polizas + _tot_cnt_polizas,
					tot_cnt_asegurados  = tot_cnt_asegurados + _tot_cnt_asegurados
              WHERE cod_ramo   = v_cod_ramo
                AND cod_subramo    = v_cod_subramo
				 AND pais_provincia = _pais_provincia;

          END EXCEPTION
			INSERT INTO ramosubr_3(
			cod_ramo,
			cod_subramo,
			pais_provincia,
			per_cnt_polizas,
			per_cnt_asegurados,
			gen_cnt_polizas,
			gen_cnt_asegurados,
			fia_cnt_polizas,
			fia_cnt_asegurados,
			tot_cnt_polizas,
			tot_cnt_asegurados 
			)
			VALUES(
			v_cod_ramo,
			v_cod_subramo,
			_pais_provincia,
			_per_cnt_polizas,
			_per_cnt_asegurados,
			_gen_cnt_polizas,
			_gen_cnt_asegurados,
			_fia_cnt_polizas,
			_fia_cnt_asegurados,
			_tot_cnt_polizas,
			_tot_cnt_asegurados 
			);  
	   END		  
   
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
	if v_cod_ramo = '009' and v_cod_subramo in('001','002','006') then
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
      IF v_cod_subramo = "002" OR v_cod_subramo = "003" OR v_cod_subramo = "018" THEN
			UPDATE ramosubr
			   SET cnt_polizas = cnt_polizas + 1, cnt_asegurados = cnt_asegurados + _cantidad_aseg
			 WHERE cod_ramo        = v_cod_ramo
			   AND cod_subramo     = "001";
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
--Cargando las polizas vigentes del mes anterior, ramos: 019, 004, 018, 014, 013, 010, 012, 011, 022, 007, 008, 009

---RECLAMOS siniestralidad Ramos: 004, 018, 014, 013, 010, 012, 011, 022, 007, 003, 001, 008, 001, 003, 009, 005, 017, 019

--Actualizar los reclamos cerrados en el mes, ramos: 004, 018, 014, 013, 010, 012, 011, 022, 007, 008, 001, 003, 009, 005, 017, 019 

--Actualizar la cantidad de reclamos, ramo: 004, 018, 014, 013, 010, 012, 011, 022, 007, 008, 001, 003, 005, 009, 017, 019  



-- Actualizando todo para los ramos: 003, 001, 017, 005, 016, 002, 006 ,015 

call sp_pro941b(a_periodo, a_periodo2, a_origen);
call sp_pro422(a_periodo, a_periodo2, a_origen) returning _retorno;

let _calculo = 0;


foreach
--	select cnt_polizas_ma, cnt_polizas, cod_ramo, cod_subramo into v_cant_polizas_ma, v_cant_polizas, _cod_ramo, _cod_subramo from ramosubr
--	if v_cant_polizas_ma >= v_cant_polizas then
--		UPDATE ramosubr SET cnt_pol_can_cad = (cnt_polizas_ma + cnt_pol_nuevas) - cnt_polizas where cod_ramo = _cod_ramo and cod_subramo = _cod_subramo;
--	else
--		UPDATE ramosubr SET cnt_pol_nuevas =  (cnt_pol_can_cad + cnt_polizas) - cnt_polizas_ma where cod_ramo = _cod_ramo and cod_subramo = _cod_subramo;
--	end if

--	select cnt_polizas_ma, cnt_polizas, cnt_pol_nuevas, cnt_pol_ren, cnt_pol_can_cad, cod_ramo, cod_subramo into v_cant_polizas_ma, v_cant_polizas, _cnt_prima_nva, _cnt_prima_ren, _cnt_prima_can, _cod_ramo, _cod_subramo from ramosubr
--	UPDATE ramosubr SET cnt_pol_can_cad = cnt_pol_can_cad + (_cnt_prima_nva + _cnt_prima_ren - _cnt_prima_can) - (cnt_polizas - cnt_polizas_ma) where cod_ramo = _cod_ramo and cod_subramo = _cod_subramo;
--	UPDATE ramosubr SET cnt_pol_can_cad = cnt_pol_can_cad - (v_cant_polizas - (v_cant_polizas_ma +_cnt_prima_nva - _cnt_prima_can)) where cod_ramo = _cod_ramo and cod_subramo = _cod_subramo;
--	UPDATE ramosubr SET cnt_pol_nuevas = cnt_pol_nuevas - (v_cant_polizas - (v_cant_polizas_ma +_cnt_prima_nva - _cnt_prima_can)) where cod_ramo = _cod_ramo and cod_subramo = _cod_subramo;

--	select cnt_polizas_ma, cnt_pol_nuevas, cnt_pol_can_cad, cnt_polizas, cod_ramo, cod_subramo into v_cant_polizas_ma, _cnt_prima_nva, _cnt_prima_can, v_cant_polizas, _cod_ramo, _cod_subramo from ramosubr	
--	let _calculo = v_cant_polizas_ma + _cnt_prima_nva - _cnt_prima_can;		
--	if _calculo > v_cant_polizas then
--		UPDATE ramosubr SET cnt_pol_can_cad = cnt_pol_can_cad + _calculo - v_cant_polizas where cod_ramo = _cod_ramo and cod_subramo = _cod_subramo;
--	else
--		UPDATE ramosubr SET cnt_pol_nuevas = cnt_pol_nuevas + v_cant_polizas - _calculo where cod_ramo = _cod_ramo and cod_subramo = _cod_subramo;
--	end if

	select cnt_polizas_ma, cnt_pol_nuevas, cnt_pol_ren, cnt_pol_can_cad, cnt_polizas, cnt_vencidas, cod_ramo, cod_subramo into v_cant_polizas_ma, _cnt_prima_nva, _cnt_prima_ren, _cnt_prima_can, v_cant_polizas, _cnt_vencidas, _cod_ramo, _cod_subramo from ramosubr
	
	let _calculo = v_cant_polizas_ma + _cnt_prima_nva + _cnt_prima_ren - _cnt_prima_can - _cnt_vencidas;
	if _calculo - v_cant_polizas <> 0 Then
		if _calculo > v_cant_polizas then
			UPDATE ramosubr SET cnt_vencidas = cnt_vencidas + _calculo - v_cant_polizas where cod_ramo = _cod_ramo and cod_subramo = _cod_subramo;
		else
			UPDATE ramosubr SET cnt_pol_nuevas = cnt_pol_nuevas + v_cant_polizas - _calculo where cod_ramo = _cod_ramo and cod_subramo = _cod_subramo;
		end if
	end if
end foreach


delete from ramootro;	----*******************************************----

--Actualizando ramootro para el ramo: 015

-- Descomponer los periodos en fechas
{
LET _ano1 = a_periodo[1,4];
LET _mes1 = a_periodo[6,7];

LET _ano2 = a_periodo2[1,4];
LET _mes2 = a_periodo2[6,7];

LET _fecha1 = MDY(_mes1,1,_ano1);

IF _mes2 = 12 THEN
   LET _mes2 = 1;
   LET _ano2 = _ano2 + 1;
ELSE
   LET _mes2 = _mes2 + 1;
END IF
LET _fecha2 = MDY(_mes2,1,_ano2);
LET _fecha2 = _fecha2 - 1;
}


LET _ano1 = a_periodo[1,4];
LET _mes1 = a_periodo[6,7];

LET _mes1 = _mes1 - 1;

IF _mes1 = 0 THEN
	LET _mes1 = 12;
	LET _ano1 = _ano1 - 1;
END IF


LET _ano2 = a_periodo2[1,4];
LET _mes2 = a_periodo2[6,7];

LET _fecha1 = MDY(_mes1,1,_ano1);

LET _fecha2 = MDY(_mes2,1,_ano2);
LET _fecha2 = _fecha2 - 1;


FOREACH
   SELECT cod_subramo,
          cod_ramo
     INTO _cod_subramo,
		  v_cod_ramo
     FROM prdsubra
	WHERE cod_ramo = "015"

   SELECT SUM(cant_polizas),
          SUM(cant_polizas_ma)
     INTO v_cant_polizas,
	      v_cant_polizas_ma
     FROM temp_perfil1
    WHERE cod_ramo    = v_cod_ramo
	  and cod_subramo = _cod_subramo;

   SELECT SUM(prima_suscrita), SUM(cnt_pol_nuevas), SUM(cnt_pol_ren), SUM(cnt_pol_can_cad)
     INTO _prima_suscrita, _cnt_prima_nva, _cnt_prima_ren, _cnt_prima_can
     FROM temp_perfil2
    WHERE cod_ramo    = v_cod_ramo
	  and cod_subramo = _cod_subramo;

	SELECT SUM(incurrido_bruto), SUM(salv_y_recup), SUM(pago_y_ded), SUM(var_reserva), SUM(cnt_incurrido)
	  INTO v_incurrido_bruto, _salv_y_recup, _pago_y_ded, _var_reserva, _cnt_incurrido
	  FROM	tmp_siniest
	 WHERE seleccionado = 1
	   AND cod_ramo     = v_cod_ramo
	   and cod_subramo  = _cod_subramo;

	 SELECT COUNT(no_reclamo)
	   INTO	_cnt_reclamo
	   FROM	tmp_sinis
	  WHERE cod_ramo     = v_cod_ramo
	    and cod_subramo   = _cod_subramo
		and seleccionado = 1;

	IF _prima_suscrita IS NULL THEN
	  	LET _prima_suscrita = 0;
	END IF
	IF v_cant_polizas IS NULL THEN
	  	LET v_cant_polizas = 0;
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
	IF _cnt_reclamo IS NULL THEN
		LET _cnt_reclamo = 0;
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
    IF _cnt_incurrido IS NULL THEN
		LET _cnt_incurrido = 0;
    END IF	
	
    let _cnt_cerra = 0;
	select count(t.no_tranrec) 
	  into _cnt_cerra
	  from emipomae e, recrcmae r, rectrmae t
	 where e.no_poliza = r.no_poliza
	   and r.no_reclamo = t.no_reclamo
	   and t.actualizado = 1
	   and t.periodo >= a_periodo
	   and t.periodo <= a_periodo2
	   and (t.cod_tipotran = '011'
	   or t.cerrar_rec = 1)
	   and e.cod_origen = a_origen
	   and e.cod_ramo = '015'
	   and e.cod_subramo = _cod_subramo;

	select count(*)			   
	  into _cnt_vencidas
	  from emipomae
	 WHERE vigencia_final >= _fecha1
	   AND vigencia_final <= _fecha2
	   and cod_origen like a_origen
	   and actualizado = 1
	   and cod_ramo = '015'
	   and cod_subramo = _cod_subramo
	   and renovada = 0
	   and fecha_cancelacion is null;
	 
	 insert into ramootro
	 values(
	 v_cod_ramo,
	 _cod_subramo,
	 v_cant_polizas,
	 _prima_suscrita,
	 0,
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
	 0,
	 _cnt_incurrido,
	 _cnt_vencidas
	 );
END FOREACH

FOREACH 
   SELECT no_poliza, cod_ramo, cod_subramo
     INTO _no_poliza, v_cod_ramo, v_cod_subramo
     FROM temp_perfil
    WHERE seleccionado = 1
	  AND cod_ramo = '015'
	 
	let _cantidad_aseg = 0; 
	 
	select count(*)
	  into _cantidad_aseg
	  from emipouni
	 where no_poliza = _no_poliza;
	 
	update ramootro
	   set cnt_asegurados = cnt_asegurados + _cantidad_aseg
	 where cod_ramo = v_cod_ramo
	   and cod_subramo = v_cod_subramo;
END FOREACH


let _calculo = 0;
foreach
--	select cnt_polizas_ma, cnt_polizas, cnt_pol_nuevas, cnt_pol_ren, cnt_pol_can_cad, cod_ramo, cod_subramo into v_cant_polizas_ma, v_cant_polizas, _cnt_prima_nva, _cnt_prima_ren, _cnt_prima_can, _cod_ramo, _cod_subramo from ramootro
--	UPDATE ramootro SET cnt_pol_can_cad = cnt_pol_can_cad + (_cnt_prima_nva + _cnt_prima_ren - _cnt_prima_can) - (cnt_polizas - cnt_polizas_ma) where cod_ramo = _cod_ramo and cod_subramo = _cod_subramo;
--	UPDATE ramootro SET cnt_pol_can_cad = cnt_pol_can_cad - (v_cant_polizas - (v_cant_polizas_ma +_cnt_prima_nva - _cnt_prima_can)) where cod_ramo = _cod_ramo and cod_subramo = _cod_subramo;
	select cnt_polizas_ma, cnt_pol_nuevas, cnt_pol_ren, cnt_pol_can_cad, cnt_polizas, cnt_vencidas, cod_ramo, cod_subramo into v_cant_polizas_ma, _cnt_prima_nva, _cnt_prima_ren, _cnt_prima_can, v_cant_polizas, _cnt_vencidas, _cod_ramo, _cod_subramo from ramootro
	
	let _calculo = v_cant_polizas_ma + _cnt_prima_nva + _cnt_prima_ren- _cnt_prima_can - _cnt_vencidas;
	if _calculo - v_cant_polizas <> 0 Then
		if _calculo > v_cant_polizas then
			UPDATE ramootro SET cnt_vencidas = cnt_vencidas + _calculo - v_cant_polizas where cod_ramo = _cod_ramo and cod_subramo = _cod_subramo;
		else
			UPDATE ramootro SET cnt_pol_nuevas = cnt_pol_nuevas + v_cant_polizas - _calculo where cod_ramo = _cod_ramo and cod_subramo = _cod_subramo;
		end if
	end if
end foreach


foreach
	select 	pais_provincia,
			sum(per_cnt_polizas),
			sum(per_cnt_asegurados),
			sum(gen_cnt_polizas),
			sum(gen_cnt_asegurados),
			sum(fia_cnt_polizas),
			sum(fia_cnt_asegurados),
			sum(tot_cnt_polizas),
			sum(tot_cnt_asegurados) 
		INTO  _pais_provincia,
			_per_cnt_polizas,
			_per_cnt_asegurados,
			_gen_cnt_polizas,
			_gen_cnt_asegurados,
			_fia_cnt_polizas,
			_fia_cnt_asegurados,
			_tot_cnt_polizas,
			_tot_cnt_asegurados 
FROM ramosubr_3			
GROUP BY pais_provincia
order by pais_provincia
			   
		RETURN  _pais_provincia, _per_cnt_polizas, _per_cnt_asegurados, _gen_cnt_polizas, _gen_cnt_asegurados, _fia_cnt_polizas, _fia_cnt_asegurados, _tot_cnt_polizas, _tot_cnt_asegurados, descr_cia  WITH RESUME;			 
END FOREACH
DROP TABLE temp_perfil;
DROP TABLE temp_perfil_b;
DROP TABLE temp_perfil1;
DROP TABLE temp_perfil2;
--DROP TABLE tmp_prod;
DROP TABLE temp_ramo;
DROP TABLE tmp_siniest;
DROP TABLE tmp_sinis;
END PROCEDURE 
                                                                                                                                                                                                                                   
