CREATE procedure "informix".sp_pro94(a_cia CHAR(03),a_agencia CHAR(3),a_periodo CHAR(7), a_periodo2 CHAR(7), a_origen CHAR(3) DEFAULT '%')

   RETURNING CHAR(50),INT,DECIMAL(16,2),CHAR(50),CHAR(45),INT,SMALLINT,DECIMAL(16,2),INTEGER,DECIMAL(16,2),DECIMAL(16,2),DECIMAL(16,2),INTEGER,INTEGER,INTEGER,INTEGER,INTEGER;
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
	DEFINE v_cant_polizas_ma  INTEGER;
	DEFINE _cnt_prima_nva     INTEGER;
	DEFINE _cnt_prima_ren     INTEGER;
	DEFINE _cnt_prima_can     INTEGER;
	DEFINE _cnt_pol_dif       INTEGER;


    CREATE TEMP TABLE temp_perfil1(
              cod_ramo       CHAR(3),
              cod_subramo    CHAR(3),
              cant_polizas    INT,
              cant_polizas_ma INT,
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

LET _ano2 = a_periodo[1,4];
LET _mes2 = a_periodo[6,7];

IF _mes2 = 12 THEN
   LET _mes2 = 1;
   LET _ano2 = _ano2 + 1;
ELSE
   LET _mes2 = _mes2 + 1;
END IF

LET _fecha2 = MDY(_mes2,1,_ano2);
LET _fecha2 = _fecha2 - 1;

--trae cant. de polizas vig. del mes anterior temp_perfil_b
CALL sp_pro95b(
a_cia,
a_agencia,
_fecha2,
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
 

--Trae la cant. de reclamos por ramo
CALL sp_rec03(
a_cia,
a_periodo, 
a_periodo2, "*", "*", "*", "*", "*",
a_origen
) RETURNING v_filtros;

UPDATE ramosubr
   SET prima_suscrita  = 0,
       cnt_polizas     = 0,
	   cnt_reclamo     = 0, 
	   incurrido_bruto = 0,
	   pago_ded        = 0,
	   salv_rec        = 0,
	   var_reserva     = 0,
	   casos_cerrados  = 0,
	   cnt_polizas_ma  = 0,
	   cnt_pol_nuevas  = 0,
	   cnt_pol_ren     = 0,
	   cnt_pol_can_cad = 0;

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

   IF _cod_ramo = "019" AND _vig_fin_vida > _vig_ini_end THEN
     UPDATE ramosubr
        SET prima_suscrita = prima_suscrita + _total_pri_sus,
		    cnt_pol_nuevas   = cnt_pol_nuevas  + _cnt_prima_nva,
			cnt_pol_ren      = cnt_pol_ren     + _cnt_prima_ren,
			cnt_pol_can_cad  = cnt_pol_can_cad + _cnt_prima_can
      WHERE cod_ramo     = _cod_ramo
        AND cod_subramo  = "001";
   END IF

   IF _cod_ramo = "019" AND _vig_fin_vida <= _vig_ini_end THEN
     UPDATE ramosubr
        SET prima_suscrita = prima_suscrita + _total_pri_sus,
		    cnt_pol_nuevas   = cnt_pol_nuevas  + _cnt_prima_nva,
			cnt_pol_ren      = cnt_pol_ren     + _cnt_prima_ren,
			cnt_pol_can_cad  = cnt_pol_can_cad + _cnt_prima_can
       WHERE cod_ramo     = _cod_ramo
        AND cod_subramo  = "002";
   END IF
   IF _cod_ramo = '004' OR _cod_ramo = '018' THEN
		select count(*)
		  into _cantidad
		  from emipouni
		 where no_poliza = _no_poliza;

		IF _cantidad > 1 then
			UPDATE ramosubr
			   SET prima_suscrita  = prima_suscrita + _total_pri_sus,
				   cnt_pol_nuevas   = cnt_pol_nuevas  + _cnt_prima_nva,
				   cnt_pol_ren      = cnt_pol_ren     + _cnt_prima_ren,
				   cnt_pol_can_cad  = cnt_pol_can_cad + _cnt_prima_can
 			 WHERE cod_ramo        = _cod_ramo
			   AND cod_subramo     = "002";
		ELSE
			UPDATE ramosubr
			   SET prima_suscrita  = prima_suscrita + _total_pri_sus,
				cnt_pol_nuevas   = cnt_pol_nuevas  + _cnt_prima_nva,
				cnt_pol_ren      = cnt_pol_ren     + _cnt_prima_ren,
				cnt_pol_can_cad  = cnt_pol_can_cad + _cnt_prima_can
 			 WHERE cod_ramo        = _cod_ramo
			   AND cod_subramo     = "001";
		END IF

	END IF
	IF _cod_ramo = "014" OR _cod_ramo = "013" THEN	--car y montaje
		UPDATE ramosubr
		   SET prima_suscrita  = prima_suscrita + _total_pri_sus,
		    cnt_pol_nuevas   = cnt_pol_nuevas  + _cnt_prima_nva,
			cnt_pol_ren      = cnt_pol_ren     + _cnt_prima_ren,
			cnt_pol_can_cad  = cnt_pol_can_cad + _cnt_prima_can
 	     WHERE cod_ramo        = '010'
		   AND cod_subramo     = "001";
	END IF
	IF _cod_ramo = "010" THEN --equio electronico
		UPDATE ramosubr
		   SET prima_suscrita  = prima_suscrita + _total_pri_sus,
		    cnt_pol_nuevas   = cnt_pol_nuevas  + _cnt_prima_nva,
			cnt_pol_ren      = cnt_pol_ren     + _cnt_prima_ren,
			cnt_pol_can_cad  = cnt_pol_can_cad + _cnt_prima_can
 		 WHERE cod_ramo        = '010'
		   AND cod_subramo     = "002";
	END IF
	IF _cod_ramo = "012" THEN	--calderas
		UPDATE ramosubr
		   SET prima_suscrita  = prima_suscrita + _total_pri_sus,
		    cnt_pol_nuevas   = cnt_pol_nuevas  + _cnt_prima_nva,
			cnt_pol_ren      = cnt_pol_ren     + _cnt_prima_ren,
			cnt_pol_can_cad  = cnt_pol_can_cad + _cnt_prima_can
 	     WHERE cod_ramo        = '010'
		   AND cod_subramo     = "003";
	END IF
	IF _cod_ramo = "011" THEN	--rotura de maquinaria
		UPDATE ramosubr
		   SET prima_suscrita  = prima_suscrita + _total_pri_sus,
		    cnt_pol_nuevas   = cnt_pol_nuevas  + _cnt_prima_nva,
			cnt_pol_ren      = cnt_pol_ren     + _cnt_prima_ren,
			cnt_pol_can_cad  = cnt_pol_can_cad + _cnt_prima_can
 	     WHERE cod_ramo        = '010'
		   AND cod_subramo     = "004";
	END IF
	IF _cod_ramo = "022" THEN	--equipo pesado
		UPDATE ramosubr
		   SET prima_suscrita  = prima_suscrita + _total_pri_sus,
		    cnt_pol_nuevas   = cnt_pol_nuevas  + _cnt_prima_nva,
			cnt_pol_ren      = cnt_pol_ren     + _cnt_prima_ren,
			cnt_pol_can_cad  = cnt_pol_can_cad + _cnt_prima_can
 	     WHERE cod_ramo        = '010'
		   AND cod_subramo     = "005";
	END IF
	IF _cod_ramo = "007" THEN	--vidrios
		UPDATE ramosubr
		   SET prima_suscrita  = prima_suscrita + _total_pri_sus,
		    cnt_pol_nuevas   = cnt_pol_nuevas  + _cnt_prima_nva,
			cnt_pol_ren      = cnt_pol_ren     + _cnt_prima_ren,
			cnt_pol_can_cad  = cnt_pol_can_cad + _cnt_prima_can
 	     WHERE cod_ramo        = '010'
		   AND cod_subramo     = "006";
	END IF
	IF _cod_ramo = "008" THEN
      IF _cod_subramo = "002" OR _cod_subramo = "003" OR _cod_subramo = "018" THEN
			UPDATE ramosubr
			   SET prima_suscrita  = prima_suscrita + _total_pri_sus,
				cnt_pol_nuevas   = cnt_pol_nuevas  + _cnt_prima_nva,
				cnt_pol_ren      = cnt_pol_ren     + _cnt_prima_ren,
				cnt_pol_can_cad  = cnt_pol_can_cad + _cnt_prima_can
 			 WHERE cod_ramo        = _cod_ramo
			   AND cod_subramo     = "001";
	  else
			UPDATE ramosubr
			   SET prima_suscrita  = prima_suscrita + _total_pri_sus,
					cnt_pol_nuevas   = cnt_pol_nuevas  + _cnt_prima_nva,
					cnt_pol_ren      = cnt_pol_ren     + _cnt_prima_ren,
					cnt_pol_can_cad  = cnt_pol_can_cad + _cnt_prima_can
 			 WHERE cod_ramo        = _cod_ramo
			   AND cod_subramo     = "002";
	  end if
	END IF 
	if _cod_ramo = '009' and _cod_subramo in('001','002','006') then
			UPDATE ramosubr
			   SET prima_suscrita  = prima_suscrita + _total_pri_sus,
				cnt_pol_nuevas   = cnt_pol_nuevas  + _cnt_prima_nva,
				cnt_pol_ren      = cnt_pol_ren     + _cnt_prima_ren,
				cnt_pol_can_cad  = cnt_pol_can_cad + _cnt_prima_can
 			 WHERE cod_ramo        = _cod_ramo
			   AND cod_subramo     = "002";
	end if
	if _cod_ramo = '009' and _cod_subramo = '003' then
			UPDATE ramosubr
			   SET prima_suscrita  = prima_suscrita + _total_pri_sus,
				cnt_pol_nuevas   = cnt_pol_nuevas  + _cnt_prima_nva,
				cnt_pol_ren      = cnt_pol_ren     + _cnt_prima_ren,
				cnt_pol_can_cad  = cnt_pol_can_cad + _cnt_prima_can
 			 WHERE cod_ramo        = _cod_ramo
			   AND cod_subramo     = "003";
	end if
	if _cod_ramo = '009' and _cod_subramo in ('004', '008') then --> Se incluye el subramo 008 MARINE CARGO STP
			UPDATE ramosubr
			   SET prima_suscrita  = prima_suscrita + _total_pri_sus,
				cnt_pol_nuevas   = cnt_pol_nuevas  + _cnt_prima_nva,
				cnt_pol_ren      = cnt_pol_ren     + _cnt_prima_ren,
				cnt_pol_can_cad  = cnt_pol_can_cad + _cnt_prima_can
			 WHERE cod_ramo        = _cod_ramo
			   AND cod_subramo     = "004";
	end if
	   BEGIN
          ON EXCEPTION IN(-239)
             UPDATE temp_perfil2
                SET prima_suscrita = prima_suscrita + _total_pri_sus,
					cnt_pol_nuevas   = cnt_pol_nuevas  + _cnt_prima_nva,
					cnt_pol_ren      = cnt_pol_ren     + _cnt_prima_ren,
					cnt_pol_can_cad  = cnt_pol_can_cad + _cnt_prima_can
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

    SELECT nueva_renov, vigencia_inic
      INTO _nueva_renov, _vigencia_inic
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

   IF v_cod_ramo = "019" AND _vig_fin_vida >= _fecha2 THEN
     UPDATE ramosubr
        SET cnt_polizas  = cnt_polizas + 1
      WHERE cod_ramo     = v_cod_ramo
        AND cod_subramo  = "001";
   END IF	

   IF v_cod_ramo = "019" AND _vig_fin_vida < _fecha2 THEN
     UPDATE ramosubr
        SET cnt_polizas  = cnt_polizas + 1
      WHERE cod_ramo     = v_cod_ramo
        AND cod_subramo  = "002";
   END IF
   IF v_cod_ramo = "014" OR v_cod_ramo = "013" THEN	--car y montaje
		UPDATE ramosubr
		   SET cnt_polizas = cnt_polizas + 1
	     WHERE cod_ramo    = '010'
		   AND cod_subramo = "001";
	END IF
	IF v_cod_ramo = "010" THEN
		UPDATE ramosubr
		   SET cnt_polizas = cnt_polizas + 1
	     WHERE cod_ramo    = '010'
		   AND cod_subramo = "002";
	END IF
	IF v_cod_ramo = "012" THEN
		UPDATE ramosubr
		   SET cnt_polizas = cnt_polizas + 1
	     WHERE cod_ramo    = '010'
		   AND cod_subramo = "003";
	END IF
	IF v_cod_ramo = "011" THEN
		UPDATE ramosubr
		   SET cnt_polizas = cnt_polizas + 1
	     WHERE cod_ramo    = '010'
		   AND cod_subramo = "004";
	END IF
	IF v_cod_ramo = "022" THEN
		UPDATE ramosubr
		   SET cnt_polizas = cnt_polizas + 1
	     WHERE cod_ramo    = '010'
		   AND cod_subramo = "005";
	END IF
	IF v_cod_ramo = "007" THEN
		UPDATE ramosubr
		   SET cnt_polizas = cnt_polizas + 1
	     WHERE cod_ramo    = '010'
		   AND cod_subramo = "006";
	END IF
	if v_cod_ramo = '009' and v_cod_subramo in('001','002','006') then
			UPDATE ramosubr
			   SET cnt_polizas = cnt_polizas + 1
			 WHERE cod_ramo    = v_cod_ramo
			   AND cod_subramo = "002";
	end if
	if v_cod_ramo = '009' and v_cod_subramo = '003' then
			UPDATE ramosubr
			   SET cnt_polizas = cnt_polizas + 1
			 WHERE cod_ramo    = v_cod_ramo
			   AND cod_subramo = "003";
	end if
	if v_cod_ramo = '009' and v_cod_subramo in ('004', '008') then --> Se incluye el subramo 008 MARINE CARGO STP
			UPDATE ramosubr
			   SET cnt_polizas = cnt_polizas + 1
			 WHERE cod_ramo    = v_cod_ramo
			   AND cod_subramo = "004";
	end if
	IF v_cod_ramo = "008" THEN
      IF v_cod_subramo = "002" OR v_cod_subramo = "003" OR v_cod_subramo = "018" THEN
			UPDATE ramosubr
			   SET cnt_polizas = cnt_polizas + 1
			 WHERE cod_ramo        = v_cod_ramo
			   AND cod_subramo     = "001";
	  else
			UPDATE ramosubr
			   SET cnt_polizas = cnt_polizas + 1
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
            SET cnt_polizas  = cnt_polizas + 1
	      WHERE cod_ramo     = v_cod_ramo
	        AND cod_subramo  = "002";
		else
	     UPDATE ramosubr
            SET cnt_polizas  = cnt_polizas + 1
	      WHERE cod_ramo     = v_cod_ramo
	        AND cod_subramo  = "001";
		end if
    END IF
   BEGIN
      ON EXCEPTION IN(-239)
         UPDATE temp_perfil1
            SET cant_polizas   = cant_polizas + 1
          WHERE cod_ramo       = v_cod_ramo
            AND cod_subramo    = v_cod_subramo;

      END EXCEPTION
      INSERT INTO temp_perfil1
          VALUES(v_cod_ramo,
                 v_cod_subramo,
                 1,
				 0
                 );
   END
END FOREACH
--Cargando las polizas vigentes del mes anterior, ramos: 019, 004, 018, 014, 013, 010, 012, 011, 022, 007, 008, 009
FOREACH WITH HOLD
   SELECT no_poliza, cod_ramo, cod_subramo 
     INTO _no_poliza, v_cod_ramo, v_cod_subramo
     FROM temp_perfil_b
    WHERE seleccionado = 1

    SELECT nueva_renov, vigencia_inic
      INTO _nueva_renov, _vigencia_inic
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
   --
   IF v_cod_ramo = "019" AND _vig_fin_vida >= _fecha2 THEN
      UPDATE ramosubr
        SET cnt_polizas_ma  = cnt_polizas_ma + 1
      WHERE cod_ramo     = v_cod_ramo
        AND cod_subramo  = "001";
   END IF	

   IF v_cod_ramo = "019" AND _vig_fin_vida < _fecha2 THEN
     UPDATE ramosubr
        SET cnt_polizas_ma  = cnt_polizas_ma + 1
      WHERE cod_ramo     = v_cod_ramo
        AND cod_subramo  = "002";
   END IF
   IF v_cod_ramo = "014" OR v_cod_ramo = "013" THEN	--car y montaje
		UPDATE ramosubr
		   SET cnt_polizas_ma = cnt_polizas_ma + 1
	     WHERE cod_ramo    = '010'
		   AND cod_subramo = "001";
	END IF
	IF v_cod_ramo = "010" THEN
		UPDATE ramosubr
		   SET cnt_polizas_ma = cnt_polizas_ma + 1
	     WHERE cod_ramo    = '010'
		   AND cod_subramo = "002";
	END IF
	IF v_cod_ramo = "012" THEN
		UPDATE ramosubr
		   SET cnt_polizas_ma = cnt_polizas_ma + 1
	     WHERE cod_ramo    = '010'
		   AND cod_subramo = "003";
	END IF
	IF v_cod_ramo = "011" THEN
		UPDATE ramosubr
		   SET cnt_polizas_ma = cnt_polizas_ma + 1
	     WHERE cod_ramo    = '010'
		   AND cod_subramo = "004";
	END IF
	IF v_cod_ramo = "022" THEN
		UPDATE ramosubr
		   SET cnt_polizas_ma = cnt_polizas_ma + 1
	     WHERE cod_ramo    = '010'
		   AND cod_subramo = "005";
	END IF
	IF v_cod_ramo = "007" THEN
		UPDATE ramosubr
		   SET cnt_polizas_ma = cnt_polizas_ma + 1
	     WHERE cod_ramo    = '010'
		   AND cod_subramo = "006";
	END IF
	if v_cod_ramo = '009' and v_cod_subramo in('001','002','006') then
			UPDATE ramosubr
			   SET cnt_polizas_ma = cnt_polizas_ma + 1
			 WHERE cod_ramo    = v_cod_ramo
			   AND cod_subramo = "002";
	end if
	if v_cod_ramo = '009' and v_cod_subramo = '003' then
			UPDATE ramosubr
			   SET cnt_polizas_ma = cnt_polizas_ma + 1
			 WHERE cod_ramo    = v_cod_ramo
			   AND cod_subramo = "003";
	end if
	if v_cod_ramo = '009' and v_cod_subramo in ('004', '008') then --> Se incluye el subramo 008 MARINE CARGO STP
			UPDATE ramosubr
			   SET cnt_polizas_ma = cnt_polizas_ma + 1
			 WHERE cod_ramo    = v_cod_ramo
			   AND cod_subramo = "004";
	end if
	IF v_cod_ramo = "008" THEN
      IF v_cod_subramo = "002" OR v_cod_subramo = "003" OR v_cod_subramo = "018" THEN
			UPDATE ramosubr
			   SET cnt_polizas_ma = cnt_polizas_ma + 1
			 WHERE cod_ramo        = v_cod_ramo
			   AND cod_subramo     = "001";
	  else
			UPDATE ramosubr
			   SET cnt_polizas_ma = cnt_polizas_ma + 1
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
            SET cnt_polizas_ma  = cnt_polizas_ma + 1
	      WHERE cod_ramo     = v_cod_ramo
	        AND cod_subramo  = "002";
		else
	     UPDATE ramosubr
            SET cnt_polizas_ma  = cnt_polizas_ma + 1
	      WHERE cod_ramo     = v_cod_ramo
	        AND cod_subramo  = "001";
		end if
    END IF
   BEGIN
      ON EXCEPTION IN(-239)
         UPDATE temp_perfil1
            SET cant_polizas_ma   = cant_polizas_ma + 1
          WHERE cod_ramo       = v_cod_ramo
            AND cod_subramo    = v_cod_subramo;

      END EXCEPTION
      INSERT INTO temp_perfil1
          VALUES(v_cod_ramo,
                 v_cod_subramo,
                 1,
				 0
                 );
   END
END FOREACH
---RECLAMOS siniestralidad Ramos: 004, 018, 014, 013, 010, 012, 011, 022, 007, 003, 001, 008, 001, 003, 009, 005, 017, 019
FOREACH
	SELECT cod_ramo, cod_subramo, incurrido_bruto, no_poliza, salv_y_recup, pago_y_ded, var_reserva
	   INTO	_cod_ramo, _cod_subramo, v_incurrido_bruto, _no_poliza, _salv_y_recup, _pago_y_ded,	_var_reserva
	   FROM	tmp_siniest
	  WHERE seleccionado = 1

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
	
    SELECT nueva_renov,
	       vigencia_inic
      INTO _nueva_renov,
	       _vigencia_inic
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
	
	IF _cod_ramo = '004' OR _cod_ramo = '018' THEN
		select count(*)
		  into _cantidad
		  from emipouni
		 where no_poliza = _no_poliza;
	
		IF _cantidad > 1 then
			UPDATE ramosubr
			   SET incurrido_bruto = incurrido_bruto + v_incurrido_bruto,
		           salv_rec        = salv_rec        + _salv_y_recup,
			       pago_ded        = pago_ded        + _pago_y_ded,
			       var_reserva     = var_reserva     + _var_reserva
			 WHERE cod_ramo        = _cod_ramo
			   AND cod_subramo     = "002";	
		ELSE
			UPDATE ramosubr
			   SET incurrido_bruto = incurrido_bruto + v_incurrido_bruto,
		           salv_rec        = salv_rec        + _salv_y_recup,
			       pago_ded        = pago_ded        + _pago_y_ded,
			       var_reserva     = var_reserva     + _var_reserva
			 WHERE cod_ramo        = _cod_ramo
			   AND cod_subramo     = "001";
		END IF

	END IF
	IF _cod_ramo = "014" OR _cod_ramo = "013" THEN	--car y montaje
		UPDATE ramosubr
		   SET incurrido_bruto = incurrido_bruto + v_incurrido_bruto,
		           salv_rec        = salv_rec        + _salv_y_recup,
			       pago_ded        = pago_ded        + _pago_y_ded,
			       var_reserva     = var_reserva     + _var_reserva
		 WHERE cod_ramo        = '010'
		   AND cod_subramo = "001";
	END IF
	IF _cod_ramo = "010" THEN
		UPDATE ramosubr
		   SET incurrido_bruto = incurrido_bruto + v_incurrido_bruto,
		           salv_rec        = salv_rec        + _salv_y_recup,
			       pago_ded        = pago_ded        + _pago_y_ded,
			       var_reserva     = var_reserva     + _var_reserva
			 WHERE cod_ramo        = '010'
		   AND cod_subramo     = "002";
	END IF
	IF _cod_ramo = "012" THEN
		UPDATE ramosubr
		   SET incurrido_bruto = incurrido_bruto + v_incurrido_bruto,
		           salv_rec        = salv_rec        + _salv_y_recup,
			       pago_ded        = pago_ded        + _pago_y_ded,
			       var_reserva     = var_reserva     + _var_reserva
			 WHERE cod_ramo        = '010'
		   AND cod_subramo     = "003";
	END IF
	IF _cod_ramo = "011" THEN
		UPDATE ramosubr
		   SET incurrido_bruto = incurrido_bruto + v_incurrido_bruto,
		           salv_rec        = salv_rec        + _salv_y_recup,
			       pago_ded        = pago_ded        + _pago_y_ded,
			       var_reserva     = var_reserva     + _var_reserva
			 WHERE cod_ramo        = '010'
		   AND cod_subramo     = "004";
	END IF
	IF _cod_ramo = "022" THEN
		UPDATE ramosubr
		   SET incurrido_bruto = incurrido_bruto + v_incurrido_bruto,
		           salv_rec        = salv_rec        + _salv_y_recup,
			       pago_ded        = pago_ded        + _pago_y_ded,
			       var_reserva     = var_reserva     + _var_reserva
			 WHERE cod_ramo        = '010'
		   AND cod_subramo     = "005";
	END IF
	IF _cod_ramo = "007" THEN
		UPDATE ramosubr
		   SET incurrido_bruto = incurrido_bruto + v_incurrido_bruto,
		           salv_rec        = salv_rec        + _salv_y_recup,
			       pago_ded        = pago_ded        + _pago_y_ded,
			       var_reserva     = var_reserva     + _var_reserva
			 WHERE cod_ramo        = '010'
		   AND cod_subramo     = "006";
	END IF
    IF _cod_ramo = "003" AND _cod_subramo = "001" THEN
      UPDATE ramosubr
         SET incurrido_bruto = incurrido_bruto + v_incurrido_bruto,
		     salv_rec        = salv_rec        + _salv_y_recup,
			 pago_ded        = pago_ded        + _pago_y_ded,
			 var_reserva     = var_reserva     + _var_reserva
       WHERE cod_ramo        = _cod_ramo
         AND cod_subramo     = _cod_subramo;
    END IF
	IF _cod_ramo = "008" THEN
      IF _cod_subramo = "002" OR _cod_subramo = "003" OR _cod_subramo = "018" THEN
		  UPDATE ramosubr
			 SET incurrido_bruto = incurrido_bruto + v_incurrido_bruto,
				 salv_rec        = salv_rec        + _salv_y_recup,
				 pago_ded        = pago_ded        + _pago_y_ded,
				 var_reserva     = var_reserva     + _var_reserva	
		   WHERE cod_ramo        = _cod_ramo
			 AND cod_subramo     = '001';
	  else
		  UPDATE ramosubr
			 SET incurrido_bruto = incurrido_bruto + v_incurrido_bruto,
				 salv_rec        = salv_rec        + _salv_y_recup,
				 pago_ded        = pago_ded        + _pago_y_ded,
				 var_reserva     = var_reserva     + _var_reserva	
		   WHERE cod_ramo        = _cod_ramo
			 AND cod_subramo     = '002';
	  end if
	end if
	IF _cod_ramo = "001" and _cod_subramo = '001' THEN
      UPDATE ramosubr
         SET incurrido_bruto = incurrido_bruto + v_incurrido_bruto,
		     salv_rec        = salv_rec        + _salv_y_recup,
			 pago_ded        = pago_ded        + _pago_y_ded,
			 var_reserva     = var_reserva     + _var_reserva
       WHERE cod_ramo        = _cod_ramo
         AND cod_subramo     = _cod_subramo;
    END IF
	IF _cod_ramo = "001" and _cod_subramo = '002' THEN
      UPDATE ramosubr
         SET incurrido_bruto = incurrido_bruto + v_incurrido_bruto,
		     salv_rec        = salv_rec        + _salv_y_recup,
			 pago_ded        = pago_ded        + _pago_y_ded,
			 var_reserva     = var_reserva     + _var_reserva	
       WHERE cod_ramo        = _cod_ramo
         AND cod_subramo     = _cod_subramo;
    END IF
	IF _cod_ramo = "001" and _cod_subramo in('003','004','006') THEN
      UPDATE ramosubr
         SET incurrido_bruto = incurrido_bruto + v_incurrido_bruto,
		     salv_rec        = salv_rec        + _salv_y_recup,
			 pago_ded        = pago_ded        + _pago_y_ded,
			 var_reserva     = var_reserva     + _var_reserva	
       WHERE cod_ramo        = _cod_ramo
         AND cod_subramo     = '003';
    END IF

    IF _cod_ramo = "003" AND _cod_subramo = "002" THEN
      UPDATE ramosubr
         SET incurrido_bruto = incurrido_bruto + v_incurrido_bruto,
		     salv_rec        = salv_rec        + _salv_y_recup,
			 pago_ded        = pago_ded        + _pago_y_ded,
			 var_reserva     = var_reserva     + _var_reserva
       WHERE cod_ramo        = _cod_ramo
         AND cod_subramo     = _cod_subramo;
    END IF
    IF _cod_ramo = "009" AND _cod_subramo in('001','002','006') THEN
      UPDATE ramosubr
         SET incurrido_bruto = incurrido_bruto + v_incurrido_bruto,
		     salv_rec        = salv_rec        + _salv_y_recup,
			 pago_ded        = pago_ded        + _pago_y_ded,
			 var_reserva     = var_reserva     + _var_reserva
       WHERE cod_ramo        = _cod_ramo
         AND cod_subramo     = '002';
    END IF
    IF _cod_ramo = "009" AND _cod_subramo = "003" THEN
      UPDATE ramosubr
         SET incurrido_bruto = incurrido_bruto + v_incurrido_bruto,
		     salv_rec        = salv_rec        + _salv_y_recup,
			 pago_ded        = pago_ded        + _pago_y_ded,
			 var_reserva     = var_reserva     + _var_reserva	
       WHERE cod_ramo        = _cod_ramo
         AND cod_subramo     = _cod_subramo;
    END IF
    IF _cod_ramo = "009" AND _cod_subramo IN ('004', '008') then --> Se incluye el subramo 008 MARINE CARGO STP
      UPDATE ramosubr
         SET incurrido_bruto = incurrido_bruto + v_incurrido_bruto,
		     salv_rec        = salv_rec        + _salv_y_recup,
			 pago_ded        = pago_ded        + _pago_y_ded,
			 var_reserva     = var_reserva     + _var_reserva	
       WHERE cod_ramo        = _cod_ramo
         AND cod_subramo     = _cod_subramo;
    END IF	
    IF _cod_ramo = "005" AND _cod_subramo = "001" THEN
      UPDATE ramosubr
         SET incurrido_bruto = incurrido_bruto + v_incurrido_bruto,
 		     salv_rec        = salv_rec        + _salv_y_recup,
			 pago_ded        = pago_ded        + _pago_y_ded,
			 var_reserva     = var_reserva     + _var_reserva
       WHERE cod_ramo        = _cod_ramo
         AND cod_subramo     = _cod_subramo;
    END IF

    IF _cod_ramo = "017" AND _cod_subramo = "001" THEN
      UPDATE ramosubr
         SET incurrido_bruto = incurrido_bruto + v_incurrido_bruto,
		     salv_rec        = salv_rec        + _salv_y_recup,
			 pago_ded        = pago_ded        + _pago_y_ded,
			 var_reserva     = var_reserva     + _var_reserva	
       WHERE cod_ramo        = _cod_ramo
         AND cod_subramo     = _cod_subramo;
    END IF

    IF _cod_ramo = "017" AND _cod_subramo = "002" THEN
      UPDATE ramosubr
         SET incurrido_bruto = incurrido_bruto + v_incurrido_bruto,
		     salv_rec        = salv_rec        + _salv_y_recup,
			 pago_ded        = pago_ded        + _pago_y_ded,
			 var_reserva     = var_reserva     + _var_reserva	
       WHERE cod_ramo        = _cod_ramo
         AND cod_subramo     = _cod_subramo;
    END IF

    IF _cod_ramo = "019" AND _vig_fin_vida >= _fecha2 THEN
      UPDATE ramosubr
         SET incurrido_bruto = incurrido_bruto + v_incurrido_bruto,
		     salv_rec        = salv_rec        + _salv_y_recup,
			 pago_ded        = pago_ded        + _pago_y_ded,
			 var_reserva     = var_reserva     + _var_reserva	
       WHERE cod_ramo        = _cod_ramo
         AND cod_subramo     = "001";
    END IF

    IF _cod_ramo = "019" AND _vig_fin_vida < _fecha2 THEN
      UPDATE ramosubr
         SET incurrido_bruto = incurrido_bruto + v_incurrido_bruto,
		     salv_rec        = salv_rec        + _salv_y_recup,
			 pago_ded        = pago_ded        + _pago_y_ded,
			 var_reserva     = var_reserva     + _var_reserva	
       WHERE cod_ramo        = _cod_ramo
         AND cod_subramo     = "002";
    END IF

END FOREACH
--Actualizar los reclamos cerrados en el mes, ramos: 004, 018, 014, 013, 010, 012, 011, 022, 007, 008, 001, 003, 009, 005, 017, 019 
foreach
	select no_reclamo
	  into _no_reclamo
      from rectrmae
     where actualizado  = 1
	   and periodo      = a_periodo
	   and cod_tipotran = '011'
	 group by no_reclamo
	 order by no_reclamo

   select no_poliza
	  into _no_poliza
	  from recrcmae
	 where no_reclamo = _no_reclamo;
	
	select cod_ramo,
	       cod_subramo,
		   vigencia_inic,
		   cod_origen
      into _cod_ramo,
	       _cod_subramo,
		   _vigencia_inic,
		   _cod_origen
      from emipomae
     where no_poliza = _no_poliza;
	
	 if _cod_origen <> a_origen then
		continue foreach;
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
   --
    LET _vig_fin_vida = _vigencia_inic + 1 UNITS YEAR;

	IF _cod_ramo = '004' OR _cod_ramo = '018' THEN
		select count(*)
		  into _cantidad
		  from emipouni
		 where no_poliza = _no_poliza;
		IF _cantidad > 1 then
			UPDATE ramosubr
			   SET casos_cerrados  = casos_cerrados + 1
			 WHERE cod_ramo        = _cod_ramo
			   AND cod_subramo     = "002";	
		ELSE
			UPDATE ramosubr
			   SET casos_cerrados  = casos_cerrados + 1
			 WHERE cod_ramo        = _cod_ramo	
			   AND cod_subramo     = "001";	
		END IF	
	END IF
	IF _cod_ramo = "014" OR _cod_ramo = "013" THEN	--car y montaje
		UPDATE ramosubr
		   SET casos_cerrados  = casos_cerrados + 1
		 WHERE cod_ramo        = '010'
		   AND cod_subramo = "001";
	END IF
	IF _cod_ramo = "010" THEN
		UPDATE ramosubr
		   SET casos_cerrados  = casos_cerrados + 1
		 WHERE cod_ramo        = '010'
		   AND cod_subramo     = "002";
	END IF
	IF _cod_ramo = "012" THEN
		UPDATE ramosubr
		   SET casos_cerrados  = casos_cerrados + 1
		 WHERE cod_ramo        = '010'
		   AND cod_subramo     = "003";
	END IF
	IF _cod_ramo = "011" THEN
		UPDATE ramosubr
		   SET casos_cerrados  = casos_cerrados + 1
		 WHERE cod_ramo        = '010'
		   AND cod_subramo     = "004";
	END IF
	IF _cod_ramo = "022" THEN
		UPDATE ramosubr
		   SET casos_cerrados  = casos_cerrados + 1
         WHERE cod_ramo        = '010'
		   AND cod_subramo     = "005";
	END IF
	IF _cod_ramo = "007" THEN
		UPDATE ramosubr
		   SET casos_cerrados  = casos_cerrados + 1
	     WHERE cod_ramo        = '010'
		   AND cod_subramo     = "006";
	END IF
	IF _cod_ramo = "008" THEN
      IF _cod_subramo = "002" OR _cod_subramo = "003" OR _cod_subramo = "018" THEN
		  UPDATE ramosubr
			 SET casos_cerrados  = casos_cerrados + 1
		   WHERE cod_ramo     = _cod_ramo
			 AND cod_subramo  = '001';
	  else
		  UPDATE ramosubr
			 SET casos_cerrados  = casos_cerrados + 1
		   WHERE cod_ramo     = _cod_ramo
			 AND cod_subramo  = '002';
	  end if
	end if
	if _cod_ramo = '001' and _cod_subramo in('003','004','006') then
      UPDATE ramosubr
         SET casos_cerrados  = casos_cerrados + 1
       WHERE cod_ramo     = _cod_ramo
         AND cod_subramo  = '003';
	end if
	if _cod_ramo = '001' and _cod_subramo = '001' then
      UPDATE ramosubr
         SET casos_cerrados  = casos_cerrados + 1
       WHERE cod_ramo     = _cod_ramo
         AND cod_subramo  = _cod_subramo;
	end if
	if _cod_ramo = '001' and _cod_subramo = '002' then
      UPDATE ramosubr
         SET casos_cerrados  = casos_cerrados + 1
       WHERE cod_ramo     = _cod_ramo
         AND cod_subramo  = _cod_subramo;
	end if

    IF _cod_ramo = "003" AND _cod_subramo = "001" THEN
      UPDATE ramosubr
         SET casos_cerrados  = casos_cerrados + 1
       WHERE cod_ramo     = _cod_ramo
         AND cod_subramo  = _cod_subramo;
    END IF

    IF _cod_ramo = "003" AND _cod_subramo = "002" THEN
      UPDATE ramosubr
         SET casos_cerrados  = casos_cerrados + 1
       WHERE cod_ramo     = _cod_ramo
         AND cod_subramo  = _cod_subramo;
    END IF
	IF _cod_ramo = "009" AND _cod_subramo in('001','002','006') THEN
      UPDATE ramosubr
         SET casos_cerrados  = casos_cerrados + 1
       WHERE cod_ramo     = _cod_ramo
         AND cod_subramo  = '002';
    END IF
	IF _cod_ramo = "009" AND _cod_subramo = "003" THEN
      UPDATE ramosubr
         SET casos_cerrados  = casos_cerrados + 1
       WHERE cod_ramo     = _cod_ramo
         AND cod_subramo  = _cod_subramo;
    END IF
	IF _cod_ramo = "009" AND _cod_subramo in ('004', '008') then --> Se incluye el subramo 008 MARINE CARGO STP
      UPDATE ramosubr
         SET casos_cerrados  = casos_cerrados + 1
       WHERE cod_ramo     = _cod_ramo
         AND cod_subramo  = _cod_subramo;
    END IF
    IF _cod_ramo = "005" AND _cod_subramo = "001" THEN
      UPDATE ramosubr
         SET casos_cerrados  = casos_cerrados + 1
       WHERE cod_ramo     = _cod_ramo
         AND cod_subramo  = _cod_subramo;
    END IF

    IF _cod_ramo = "017" AND _cod_subramo = "001" THEN
      UPDATE ramosubr
         SET casos_cerrados  = casos_cerrados + 1
       WHERE cod_ramo     = _cod_ramo
         AND cod_subramo  = _cod_subramo;
    END IF

    IF _cod_ramo = "017" AND _cod_subramo = "002" THEN
      UPDATE ramosubr
         SET casos_cerrados  = casos_cerrados + 1
       WHERE cod_ramo     = _cod_ramo
         AND cod_subramo  = _cod_subramo;
    END IF

    IF _cod_ramo = "019" AND _vig_fin_vida >= _fecha2 THEN
      UPDATE ramosubr
         SET casos_cerrados  = casos_cerrados + 1
       WHERE cod_ramo     = _cod_ramo
         AND cod_subramo  = "001";
    END IF

    IF _cod_ramo = "019" AND _vig_fin_vida < _fecha2 THEN
      UPDATE ramosubr
         SET casos_cerrados  = casos_cerrados + 1
       WHERE cod_ramo     = _cod_ramo
         AND cod_subramo  = "002";
    END IF
end foreach
--Actualizar la cantidad de reclamos, ramo: 004, 018, 014, 013, 010, 012, 011, 022, 007, 008, 001, 003, 005, 009, 017, 019
FOREACH
	SELECT cod_ramo,
		   no_reclamo
	  INTO _cod_ramo,
		   _no_reclamo
	  FROM tmp_sinis
	 WHERE seleccionado = 1

	SELECT no_poliza
	  INTO _no_poliza
	  FROM recrcmae
	 WHERE no_reclamo = _no_reclamo;

    SELECT nueva_renov,
		   cod_subramo,
		   vigencia_inic
      INTO _nueva_renov,
	       _cod_subramo,
		   _vigencia_inic
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

	IF _cod_ramo = '004' OR _cod_ramo = '018' THEN
		select count(*)
		  into _cantidad
		  from emipouni
		 where no_poliza = _no_poliza;
	
		IF _cantidad > 1 then
			UPDATE ramosubr
			 SET cnt_reclamo  = cnt_reclamo + 1
		   WHERE cod_ramo     = _cod_ramo
			 AND cod_subramo  = '002';
		ELSE
		  UPDATE ramosubr
			 SET cnt_reclamo  = cnt_reclamo + 1
		   WHERE cod_ramo     = _cod_ramo
			 AND cod_subramo  = '002';
		END IF
	END IF
	IF _cod_ramo = "014" OR _cod_ramo = "013" THEN	--car y montaje
		UPDATE ramosubr
		   SET cnt_reclamo  = cnt_reclamo + 1
		 WHERE cod_ramo        = '010'
		   AND cod_subramo = "001";
	END IF
	IF _cod_ramo = "010" THEN
		UPDATE ramosubr
		   SET cnt_reclamo  = cnt_reclamo + 1
		 WHERE cod_ramo        = '010'
		   AND cod_subramo     = "002";
	END IF
	IF _cod_ramo = "012" THEN
		UPDATE ramosubr
		   SET cnt_reclamo  = cnt_reclamo + 1
		 WHERE cod_ramo        = '010'
		   AND cod_subramo     = "003";
	END IF
	IF _cod_ramo = "011" THEN
		UPDATE ramosubr
		   SET cnt_reclamo  = cnt_reclamo + 1
		 WHERE cod_ramo        = '010'
		   AND cod_subramo     = "004";
	END IF
	IF _cod_ramo = "022" THEN
		UPDATE ramosubr
		   SET cnt_reclamo  = cnt_reclamo + 1
         WHERE cod_ramo        = _cod_ramo
		   AND cod_subramo     = "005";
	END IF
	IF _cod_ramo = "007" THEN
		UPDATE ramosubr
		   SET cnt_reclamo  = cnt_reclamo + 1
	     WHERE cod_ramo        = '010'
		   AND cod_subramo     = "006";
	END IF
	IF _cod_ramo = "008" THEN
      IF _cod_subramo = "002" OR _cod_subramo = "003" OR _cod_subramo = "018" THEN
		  UPDATE ramosubr
			 SET cnt_reclamo  = cnt_reclamo + 1
		   WHERE cod_ramo     = _cod_ramo
			 AND cod_subramo  = '001';
	  else
		  UPDATE ramosubr
			 SET cnt_reclamo  = cnt_reclamo + 1
		   WHERE cod_ramo     = _cod_ramo
			 AND cod_subramo  = '002';
	  end if
	end if 
	IF _cod_ramo = "001" and _cod_subramo in('003','004','006') THEN
      UPDATE ramosubr
         SET cnt_reclamo  = cnt_reclamo + 1
       WHERE cod_ramo     = _cod_ramo
         AND cod_subramo  = '003';
    END IF
	IF _cod_ramo = "001" and _cod_subramo = '001' THEN
      UPDATE ramosubr
         SET cnt_reclamo  = cnt_reclamo + 1
       WHERE cod_ramo     = _cod_ramo
         AND cod_subramo  = _cod_subramo;
    END IF
	IF _cod_ramo = "001" and _cod_subramo = '002' THEN
      UPDATE ramosubr
         SET cnt_reclamo  = cnt_reclamo + 1
       WHERE cod_ramo     = _cod_ramo
         AND cod_subramo  = _cod_subramo;
    END IF
    IF _cod_ramo = "003" AND _cod_subramo = "001" THEN
      UPDATE ramosubr
         SET cnt_reclamo  = cnt_reclamo + 1
       WHERE cod_ramo     = _cod_ramo
         AND cod_subramo  = _cod_subramo;
    END IF

    IF _cod_ramo = "003" AND _cod_subramo = "002" THEN
      UPDATE ramosubr
         SET cnt_reclamo  = cnt_reclamo + 1
       WHERE cod_ramo     = _cod_ramo
         AND cod_subramo  = _cod_subramo;
    END IF

    IF _cod_ramo = "005" AND _cod_subramo = "001" THEN
      UPDATE ramosubr
         SET cnt_reclamo  = cnt_reclamo + 1
       WHERE cod_ramo     = _cod_ramo
         AND cod_subramo  = _cod_subramo;
    END IF
	IF _cod_ramo = "009" AND _cod_subramo in('001','002','006') THEN
      UPDATE ramosubr
         SET cnt_reclamo  = cnt_reclamo + 1
       WHERE cod_ramo     = _cod_ramo
         AND cod_subramo  = '002';
    END IF
	IF _cod_ramo = "009" AND _cod_subramo = "003" THEN
      UPDATE ramosubr
         SET cnt_reclamo  = cnt_reclamo + 1
       WHERE cod_ramo     = _cod_ramo
         AND cod_subramo  = _cod_subramo;
    END IF
	IF _cod_ramo = "009" AND _cod_subramo in ('004', '008') then --> Se incluye el subramo 008 MARINE CARGO STP
      UPDATE ramosubr
         SET cnt_reclamo  = cnt_reclamo + 1
       WHERE cod_ramo     = _cod_ramo
         AND cod_subramo  = _cod_subramo;
    END IF	
    IF _cod_ramo = "017" AND _cod_subramo = "001" THEN
      UPDATE ramosubr
         SET cnt_reclamo  = cnt_reclamo + 1
       WHERE cod_ramo     = _cod_ramo
         AND cod_subramo  = _cod_subramo;
    END IF

    IF _cod_ramo = "017" AND _cod_subramo = "002" THEN
      UPDATE ramosubr
         SET cnt_reclamo  = cnt_reclamo + 1
       WHERE cod_ramo     = _cod_ramo
         AND cod_subramo  = _cod_subramo;
    END IF

    IF _cod_ramo = "019" AND _vig_fin_vida >= _fecha2 THEN
      UPDATE ramosubr
         SET cnt_reclamo  = cnt_reclamo + 1
       WHERE cod_ramo     = _cod_ramo
         AND cod_subramo  = "001";
    END IF	

    IF _cod_ramo = "019" AND _vig_fin_vida < _fecha2 THEN
    --_nueva_renov = "R" THEN
      UPDATE ramosubr
         SET cnt_reclamo  = cnt_reclamo + 1
       WHERE cod_ramo     = _cod_ramo
         AND cod_subramo  = "002";
    END IF

END FOREACH

delete from ramootro;	----*******************************************----

--Actualizando ramootro para el ramo: 015
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

	SELECT SUM(incurrido_bruto), SUM(salv_y_recup), SUM(pago_y_ded), SUM(var_reserva)
	  INTO v_incurrido_bruto, _salv_y_recup, _pago_y_ded, _var_reserva
	  FROM	tmp_siniest
	 WHERE seleccionado = 1
	   AND cod_ramo     = v_cod_ramo
	   and cod_subramo  = _cod_subramo;

	 SELECT COUNT(numrecla)
	   INTO	_cnt_reclamo
	   FROM	tmp_sinis
	  WHERE seleccionado = 1
	    AND cod_ramo     = v_cod_ramo
	   and cod_subramo   = _cod_subramo;

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
	
    let _cnt_cerra = 0;
	select count(t.no_tranrec)
	  into _cnt_cerra
	  from emipomae e, recrcmae r, rectrmae t
	 where e.no_poliza = r.no_poliza
	   and r.no_reclamo = t.no_reclamo
	   and t.actualizado = 1
	   and t.periodo = a_periodo
	   and t.cod_tipotran = '011'
	   and e.cod_origen = a_origen
	   and e.cod_ramo = '015'
	   and e.cod_subramo = _cod_subramo;
	
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
	 _cnt_prima_can);
END FOREACH
-- Actualizando todo para los ramos: 003, 001, 017, 005, 016, 002, 006 ,015
FOREACH
   SELECT cod_ramo
     INTO v_cod_ramo
     FROM temp_ramo
	WHERE cod_ramo <> "019"

   SELECT SUM(cant_polizas),
          SUM(cant_polizas_ma)
     INTO v_cant_polizas,
	      v_cant_polizas_ma
     FROM temp_perfil1
    WHERE cod_ramo = v_cod_ramo;

   SELECT SUM(prima_suscrita),
          SUM(cnt_pol_nuevas),
		  SUM(cnt_pol_ren),
		  SUM(cnt_pol_can_cad)
     INTO _prima_suscrita,
	      _cnt_prima_nva,
		  _cnt_prima_ren,
		  _cnt_prima_can
     FROM temp_perfil2
    WHERE cod_ramo    = v_cod_ramo;

	SELECT SUM(incurrido_bruto),
	       SUM(salv_y_recup),
		   SUM(pago_y_ded),
		   SUM(var_reserva)
	   INTO	v_incurrido_bruto,
	        _salv_y_recup,
			_pago_y_ded,
			_var_reserva
	   FROM	tmp_siniest
	  WHERE seleccionado = 1
	    AND cod_ramo     = v_cod_ramo;

	SELECT COUNT(numrecla)
	   INTO	_cnt_reclamo
	   FROM	tmp_sinis
	  WHERE seleccionado = 1
	    AND cod_ramo     = v_cod_ramo;

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

    IF v_cod_ramo = "003" THEN

	   SELECT SUM(cant_polizas),
              SUM(cant_polizas_ma)
	     INTO v_cant_polizas,
		      v_cant_polizas_ma
	     FROM temp_perfil1
	    WHERE cod_ramo    = v_cod_ramo
	      AND cod_subramo = "001";

	   SELECT SUM(prima_suscrita),
			  SUM(cnt_pol_nuevas),
			  SUM(cnt_pol_ren),
			  SUM(cnt_pol_can_cad)
	     INTO _prima_suscrita,
			  _cnt_prima_nva,
			  _cnt_prima_ren,
			  _cnt_prima_can
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
	
	   UPDATE ramosubr
          SET cnt_polizas  = v_cant_polizas,
		      cnt_polizas_ma = v_cant_polizas_ma,
	   		  prima_suscrita = _prima_suscrita,
			  cnt_pol_nuevas   = _cnt_prima_nva,
			  cnt_pol_ren      = _cnt_prima_ren,
			  cnt_pol_can_cad  = _cnt_prima_can
        WHERE cod_ramo     = v_cod_ramo
          AND cod_subramo  = "001";

	   SELECT SUM(cant_polizas),
              SUM(cant_polizas_ma)
	     INTO v_cant_polizas,
		      v_cant_polizas_ma
	     FROM temp_perfil1
	    WHERE cod_ramo    = v_cod_ramo
	      AND cod_subramo <> "001";

	   SELECT SUM(prima_suscrita),
			  SUM(cnt_pol_nuevas),
			  SUM(cnt_pol_ren),
			  SUM(cnt_pol_can_cad)
	     INTO _prima_suscrita,
			  _cnt_prima_nva,
			  _cnt_prima_ren,
			  _cnt_prima_can
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
			  cnt_pol_can_cad  = _cnt_prima_can
        WHERE cod_ramo     = v_cod_ramo
          AND cod_subramo  = "002";

	END IF
    IF v_cod_ramo = "001" THEN

	   SELECT SUM(cant_polizas),
              SUM(cant_polizas_ma)
	     INTO v_cant_polizas,
		      v_cant_polizas_ma
	     FROM temp_perfil1
	    WHERE cod_ramo    = v_cod_ramo
	      AND cod_subramo = "001";

	   SELECT SUM(prima_suscrita),
			  SUM(cnt_pol_nuevas),
			  SUM(cnt_pol_ren),
			  SUM(cnt_pol_can_cad)
	     INTO _prima_suscrita,
			  _cnt_prima_nva,
			  _cnt_prima_ren,
			  _cnt_prima_can
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
	
	   UPDATE ramosubr
          SET cnt_polizas  = v_cant_polizas,
		      cnt_polizas_ma = v_cant_polizas_ma,
	   		  prima_suscrita = _prima_suscrita,
			  cnt_pol_nuevas   = _cnt_prima_nva,
			  cnt_pol_ren      = _cnt_prima_ren,
			  cnt_pol_can_cad  = _cnt_prima_can
        WHERE cod_ramo     = v_cod_ramo
          AND cod_subramo  = "001";

	   SELECT SUM(cant_polizas),
              SUM(cant_polizas_ma)
	     INTO v_cant_polizas,
		      v_cant_polizas_ma	
	     FROM temp_perfil1
	    WHERE cod_ramo    = v_cod_ramo
	      AND cod_subramo = "002";

	   SELECT SUM(prima_suscrita),
			  SUM(cnt_pol_nuevas),
			  SUM(cnt_pol_ren),
			  SUM(cnt_pol_can_cad)
	     INTO _prima_suscrita,
			  _cnt_prima_nva,
			  _cnt_prima_ren,
			  _cnt_prima_can
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
			  cnt_pol_can_cad  = _cnt_prima_can
        WHERE cod_ramo     = v_cod_ramo
          AND cod_subramo  = "002";

	   SELECT SUM(cant_polizas),
              SUM(cant_polizas_ma)	
	     INTO v_cant_polizas,
		      v_cant_polizas_ma	
	     FROM temp_perfil1
	    WHERE cod_ramo    = v_cod_ramo
	      AND cod_subramo in("003","004","006");

	   SELECT SUM(prima_suscrita),
			  SUM(cnt_pol_nuevas),
			  SUM(cnt_pol_ren),
			  SUM(cnt_pol_can_cad)
	     INTO _prima_suscrita,
			  _cnt_prima_nva,
			  _cnt_prima_ren,
			  _cnt_prima_can
	     FROM temp_perfil2
	    WHERE cod_ramo    = v_cod_ramo
	      AND cod_subramo in("003","004","006");

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
	
	   UPDATE ramosubr
          SET cnt_polizas  = v_cant_polizas,
		      cnt_polizas_ma = v_cant_polizas_ma,	
	   		  prima_suscrita = _prima_suscrita,
			  cnt_pol_nuevas   = _cnt_prima_nva,
			  cnt_pol_ren      = _cnt_prima_ren,
			  cnt_pol_can_cad  = _cnt_prima_can
        WHERE cod_ramo      = v_cod_ramo
          AND cod_subramo   = "003";
	END IF
	IF v_cod_ramo = "017" THEN

	   SELECT SUM(cant_polizas),
              SUM(cant_polizas_ma)	
	     INTO v_cant_polizas,
		      v_cant_polizas_ma	
	     FROM temp_perfil1
	    WHERE cod_ramo    = v_cod_ramo
	      AND cod_subramo = "001";

	   SELECT SUM(prima_suscrita),
			  SUM(cnt_pol_nuevas),
			  SUM(cnt_pol_ren),
			  SUM(cnt_pol_can_cad)
	     INTO _prima_suscrita,
			  _cnt_prima_nva,
			  _cnt_prima_ren,
			  _cnt_prima_can
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
	
	   UPDATE ramosubr
          SET cnt_polizas  = v_cant_polizas,
		      cnt_polizas_ma = v_cant_polizas_ma,	
			  prima_suscrita = _prima_suscrita,
			  cnt_pol_nuevas   = _cnt_prima_nva,
			  cnt_pol_ren      = _cnt_prima_ren,
			  cnt_pol_can_cad  = _cnt_prima_can
        WHERE cod_ramo     = v_cod_ramo
          AND cod_subramo  = "001";

	   SELECT SUM(cant_polizas),
              SUM(cant_polizas_ma)
	     INTO v_cant_polizas,
		      v_cant_polizas_ma	
	     FROM temp_perfil1
	    WHERE cod_ramo    = v_cod_ramo
	      AND cod_subramo = "002";

	   SELECT SUM(prima_suscrita),
			  SUM(cnt_pol_nuevas),
			  SUM(cnt_pol_ren),
			  SUM(cnt_pol_can_cad)
	     INTO _prima_suscrita,
			  _cnt_prima_nva,
			  _cnt_prima_ren,
			  _cnt_prima_can
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
			  cnt_pol_can_cad  = _cnt_prima_can
        WHERE cod_ramo     = v_cod_ramo
          AND cod_subramo  = "002";

	END IF
	IF v_cod_ramo = "005" THEN
	   SELECT SUM(cant_polizas),
              SUM(cant_polizas_ma)	
	     INTO v_cant_polizas,
		      v_cant_polizas_ma	
	     FROM temp_perfil1
	    WHERE cod_ramo    = v_cod_ramo
	      AND cod_subramo = "001";

	   SELECT SUM(prima_suscrita),
			  SUM(cnt_pol_nuevas),
			  SUM(cnt_pol_ren),
			  SUM(cnt_pol_can_cad)
	     INTO _prima_suscrita,
			  _cnt_prima_nva,
			  _cnt_prima_ren,
			  _cnt_prima_can
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
	
	   UPDATE ramosubr
          SET cnt_polizas  = v_cant_polizas,
		      cnt_polizas_ma = v_cant_polizas_ma,	
	   		  prima_suscrita = _prima_suscrita,
			  cnt_pol_nuevas   = _cnt_prima_nva,
			  cnt_pol_ren      = _cnt_prima_ren,
			  cnt_pol_can_cad  = _cnt_prima_can
        WHERE cod_ramo     = v_cod_ramo
          AND cod_subramo  = "001";
   END IF

	let _cnt_cerra = 0;

	select count(t.no_tranrec)
	  into _cnt_cerra
	  from emipomae e, recrcmae r, rectrmae t
	 where e.no_poliza = r.no_poliza
	   and r.no_reclamo = t.no_reclamo
	   and t.actualizado = 1
	   and t.periodo = a_periodo
	   and t.cod_tipotran = '011'
	   and e.cod_origen = a_origen
	   and e.cod_ramo = v_cod_ramo;
 
   IF v_cod_ramo = "016" THEN
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
			cnt_pol_can_cad = _cnt_prima_can
      WHERE cod_ramo     = v_cod_ramo
        AND cod_subramo  = "001";
   ELIF	v_cod_ramo = "002" THEN
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
			cnt_pol_can_cad = _cnt_prima_can
      WHERE cod_ramo     = v_cod_ramo
        AND cod_subramo  = "001";
   ELIF	v_cod_ramo = "006" THEN
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
			cnt_pol_can_cad = _cnt_prima_can
      WHERE cod_ramo     = v_cod_ramo
        AND cod_subramo  = "001";
   ELIF	v_cod_ramo = "015" THEN
     UPDATE ramosubr
        SET cnt_polizas    = v_cant_polizas,
		    cnt_polizas_ma = v_cant_polizas_ma,
     	    prima_suscrita = _prima_suscrita,
     	    incurrido_bruto = v_incurrido_bruto,
		    salv_rec        = _salv_y_recup,
			pago_ded        = _pago_y_ded,
			var_reserva     = _var_reserva,
			cnt_reclamo     = _cnt_reclamo,
			casos_cerrados  = _cnt_cerra,
			cnt_pol_nuevas  = _cnt_prima_nva,
			cnt_pol_ren     = _cnt_prima_ren,
			cnt_pol_can_cad = _cnt_prima_can
      WHERE cod_ramo        = v_cod_ramo
        AND cod_subramo     = "001";
   END IF
END FOREACH

foreach
	select cnt_polizas_ma, cnt_polizas, cod_ramo, cod_subramo into v_cant_polizas_ma, v_cant_polizas, _cod_ramo, _cod_subramo from ramosubr
	if v_cant_polizas_ma >= v_cant_polizas then
		UPDATE ramosubr SET cnt_pol_can_cad = (cnt_polizas_ma + cnt_pol_nuevas) - cnt_polizas where cod_ramo = _cod_ramo and cod_subramo = _cod_subramo;
	else
		UPDATE ramosubr SET cnt_pol_nuevas =  (cnt_pol_can_cad + cnt_polizas) - cnt_polizas_ma where cod_ramo = _cod_ramo and cod_subramo = _cod_subramo;
	end if
end foreach
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
			   cnt_pol_can_cad
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
			   _cnt_prima_can
          FROM ramosubr
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

    IF _cod_ramo = "001" THEN
		  LET v_desc_ramo = "INCENDIO Y LINEAS ALIADAS";
		  --LET v_desc_subramo = "";
    ELIF _cod_ramo = "009" THEN
		  LET v_desc_ramo = "TRANSPORTE DE CARGA";
		  IF  _cod_subramo = '002' THEN
		  	LET v_desc_subramo = "TERRESTRE";
		  END IF
    ELIF _cod_ramo = "004" THEN
		  LET v_desc_subramo = "";
		  IF  _cod_subramo = '001' THEN
		  	LET v_desc_subramo = "INDIVIDUAL";
		  ELSE
		  	LET v_desc_subramo = "GRUPO";
		  END IF
    ELIF _cod_ramo = "018" THEN
		  LET v_desc_subramo = "";
		  IF  _cod_subramo = '001' THEN
		  	LET v_desc_subramo = "INDIVIDUAL";
		  ELSE
		  	LET v_desc_subramo = "GRUPO";
		  END IF
    ELIF _cod_ramo = "016" THEN
		  LET v_desc_subramo = "";
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
    ELIF _cod_ramo = "010" THEN
		  LET v_desc_ramo = "RAMOS TECNICOS";
		  LET v_desc_subramo = "";
		  IF _cod_subramo = "001"	THEN
			  LET v_desc_subramo = "TRC / TRM";
		  ELIF _cod_subramo = "002" THEN
			  LET v_desc_subramo = "EQUIPO ELECTRONICO";
		  ELIF _cod_subramo = "003" THEN
			  LET v_desc_subramo = "CALDERA Y MAQUINARIA";
		  ELIF _cod_subramo = "004" THEN
			  LET v_desc_subramo = "ROTURA DE MAQUINARIA";
		  ELIF _cod_subramo = "005" THEN
			  LET v_desc_subramo = "EQUIPO PESADO";
		  ELSE
			  LET v_desc_subramo = "VIDRIOS";
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
    END IF

       RETURN  v_desc_subramo, v_cant_polizas, _prima_suscrita, v_desc_ramo, descr_cia, _mes, _orden, v_incurrido_bruto, _cnt_reclamo, _pago_y_ded, _salv_y_recup, _var_reserva, _cnt_cerra, v_cant_polizas_ma,
			   _cnt_prima_nva, _cnt_prima_ren, _cnt_prima_can WITH RESUME;
END FOREACH
DROP TABLE temp_perfil;
DROP TABLE temp_perfil_b;
DROP TABLE temp_perfil1;
DROP TABLE temp_perfil2;
DROP TABLE tmp_prod;
DROP TABLE temp_ramo;
DROP TABLE tmp_siniest;
DROP TABLE tmp_sinis;
END PROCEDURE                                                                                                                                                                                
