   DROP procedure sp_pro94;
   CREATE procedure sp_pro94(a_cia CHAR(03),a_agencia CHAR(3),a_periodo CHAR(7), a_periodo2 CHAR(7), a_origen CHAR(3) DEFAULT '%')
   RETURNING CHAR(50),INT,DECIMAL(16,2),CHAR(50),CHAR(45),INT,SMALLINT,DECIMAL(16,2),INTEGER,DECIMAL(16,2),DECIMAL(16,2),DECIMAL(16,2),INTEGER,INTEGER,INTEGER,INTEGER,INTEGER,INTEGER,INTEGER,INTEGER;
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
	define _mensaje             char(50);
	define _error_isam		integer;
	define _error			integer;
	define _error_desc      char(50);
	define _origen 				smallint;
	define _periodo_ant     char(7);
	define _anio_aniv			char(4);
	define _mes_aniv			char(2);
	
	
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
			  prima_sus_cor  DECIMAL(16,2),
			  prima_sus_dir  DECIMAL(16,2),
			  prima_sus_can  DECIMAL(16,2),
              PRIMARY KEY(cod_ramo,cod_subramo)) WITH NO LOG;
			  
	CREATE TEMP TABLE tmp_unidad_v(
			  no_unidad          CHAR(5),                           
              activo             SMALLINT DEFAULT 0,			  
              PRIMARY KEY(no_unidad)) WITH NO LOG;	
			  

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
let _origen			 = 0;

SET ISOLATION TO DIRTY READ;

IF a_origen = '001' THEN
	LET _origen = 1;
ELSE
	LET _origen = 2;
END IF


BEGIN
ON EXCEPTION set _error, _error_isam, _error_desc
 RETURN _mensaje,0,0,_error_desc,'',0,0,0,0,0,0,0,0,0,0,0,0,0,0,0;
END EXCEPTION
LET _mensaje = 'sp_pro94';
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
LET _mensaje = 'sp_pr94a';
CALL sp_pr94a();
--trae cant. de polizas vig. temp_perfil
LET _mensaje = 'sp_pro568aa';
CALL sp_pro568aa(
a_cia,
a_agencia,
_fecha2,
'*',
'4;Ex',
a_origen) RETURNING v_filtros;
LET _mensaje = 'sp_pro568cc';

-- Pólizas vencidas tmp_vence
CALL sp_pro568cc(
a_cia,
a_agencia,
a_periodo2,
a_periodo2,
a_origen
) RETURNING v_filtros;

--SET DEBUG FILE TO "sp_pro94.trc"; 
--trace on;


LET _ano1 = a_periodo[1,4];
LET _mes1 = a_periodo[6,7];

LET _fecha1 = MDY(_mes1,1,_ano1);
LET _fecha1 = _fecha1 - 1;

LET _anio_aniv = YEAR(_fecha1);

IF MONTH(_fecha1) < 10 THEN
	LET _mes_aniv = '0' || MONTH(_fecha1);
ELSE
	LET _mes_aniv = MONTH(_fecha1);
END IF

LET _periodo_ant = _anio_aniv || '-' || _mes_aniv;


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
LET _mensaje = 'sp_pro95b';

--trae cant. de polizas vig. del mes anterior temp_perfil_b
CALL sp_pro95b(
a_cia,
a_agencia,
_fecha1,
'*',
'4;Ex',
a_origen) RETURNING v_filtros;
-- Prima Suscrita tmp_prod
LET _mensaje = 'sp_pr26h';
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

LET _mensaje = 'sp_pr26h_uni';
-- tmp_prod_uni
--CALL sp_pr26h_uni(
--a_cia,
--a_agencia,
--a_periodo,
--a_periodo2,
--'*',
--'*',
--'*',
--'4;Ex',		--Reaseguro Asumido Excluido
--'*',
--'*',
--'*',
--a_origen
--) RETURNING v_filtros;

--Trae los siniestros brutos incurridos tmp_siniest
LET _mensaje = 'sp_rec14_uni';
CALL sp_rec14_uni(
a_cia,
a_agencia,
a_periodo,
a_periodo2,
a_origen
);
-- Excluye los Reclamos en Reaseguro Asumido
update tmp_siniest_uni
   set seleccionado = 0
 where seleccionado = 1
   and cod_tipoprod = "004";

update tmp_siniest_uni
   set cod_ramo = '002'
 where cod_ramo = '020';

update tmp_siniest_uni
   set cod_ramo = '002'
 where cod_ramo = '023';

update tmp_siniest_uni
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
LET _mensaje = 'sp_pro942';
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
	   cnt_polizas_ma  = 0, cnt_pol_nuevas  = 0, cnt_pol_ren = 0, cnt_pol_can_cad = 0, cnt_asegurados = 0, cnt_incurridos = 0, cnt_vencidas = 0, prima_sus_cor = 0, prima_sus_dir = 0, prima_sus_can = 0;

LET _mensaje = 'sp_pro94d';
let _retorno = sp_pro94d(a_cia,a_agencia,a_periodo, a_periodo2, a_origen);	   
LET _mensaje = 'sp_pro94-2';
--Cargando las polizas vigentes del mes anterior, ramos: 019, 004, 018, 014, 013, 010, 012, 011, 022, 007, 008, 009
{FOREACH WITH HOLD
   SELECT no_poliza, cod_ramo, cod_subramo    
     INTO _no_poliza, v_cod_ramo, v_cod_subramo
     FROM temp_perfil_b
    WHERE seleccionado = 1

    SELECT nueva_renov, vigencia_inic, cod_subramo	
      INTO _nueva_renov, _vigencia_inic, _cod_subramo	
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
    IF v_cod_ramo = "019" AND _nueva_renov = 'N' THEN --Amado 02-06-2017
      UPDATE ramosubr
        SET cnt_polizas_ma  = cnt_polizas_ma + 1
      WHERE cod_ramo     = v_cod_ramo
        AND cod_subramo  = "001";
   END IF	

    IF v_cod_ramo = "019" AND _nueva_renov = 'R' THEN --Amado 02-06-2017
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
	if v_cod_ramo = '009' and v_cod_subramo in('001','002','006','009') then -- Se agregó el subramo 009 10-08-2022 ID de la solicitud	# 4243
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
      IF v_cod_subramo = "002" OR v_cod_subramo = "018" THEN
			UPDATE ramosubr
			   SET cnt_polizas_ma = cnt_polizas_ma + 1
			 WHERE cod_ramo        = v_cod_ramo
			   AND cod_subramo     = "001";
	  ELIF 	v_cod_subramo = "003" THEN	   
			UPDATE ramosubr
			   SET cnt_polizas_ma = cnt_polizas_ma + 1
			 WHERE cod_ramo        = v_cod_ramo
			   AND cod_subramo     = "003";
	  ELIF 	v_cod_subramo = "012" THEN	   
			UPDATE ramosubr
			   SET cnt_polizas_ma = cnt_polizas_ma + 1
			 WHERE cod_ramo        = v_cod_ramo
			   AND cod_subramo     = "004";
	  ELIF 	v_cod_subramo = "009" THEN	   
			UPDATE ramosubr
			   SET cnt_polizas_ma = cnt_polizas_ma + 1
			 WHERE cod_ramo        = v_cod_ramo
			   AND cod_subramo     = "005";
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
	IF v_cod_ramo in ('002','020','023') THEN
	    delete from tmp_unidad_v;
		FOREACH
			select b.no_unidad,
			       a.cod_endomov
			  into _no_unidad,
			       _cod_endomov
			  from endedmae a, endeduni b
             where a.no_poliza = b.no_poliza
			   and a.no_endoso = b.no_endoso
			   and a.no_poliza = _no_poliza
               and a.periodo <= '2025-12'
		  order by a.no_endoso

            if _cod_endomov = '005' then
				let _activo = 0;
			else 
				let _activo = 1;
			end if
			
		   BEGIN
			  ON EXCEPTION IN(-239)
				 UPDATE tmp_unidad_v
					SET activo = _activo
				  WHERE no_unidad  = _no_unidad ;

			  END EXCEPTION
			  			  
			  INSERT INTO tmp_unidad_v
				  VALUES(_no_unidad,						 						 
						 _activo
						 );
		   END
        END FOREACH	
		
		select min(no_unidad)
		  into _no_unidad
		  from tmp_unidad_v 
		 where activo = 1;
		 
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
			   SET cnt_polizas_ma  = cnt_polizas_ma + 1
			 WHERE cod_ramo        = '002'
			   AND cod_subramo     = "001";
		ELSE
			UPDATE ramosubr
			   SET cnt_polizas_ma  = cnt_polizas_ma + 1
			 WHERE cod_ramo        = '002'
			   AND cod_subramo     = "002";
        END IF		 
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
                 0,
				 1,
				 0
                 );
   END
END FOREACH}

--Cargando las polizas vigentes del mes anterior, ramos: 019, 004, 018, 014, 013, 010, 012, 011, 022, 007, 008, 009
FOREACH WITH HOLD
   SELECT cnt_polizas, cod_ramo, cod_subramo    
     INTO v_cant_polizas_ma, v_cod_ramo, v_cod_subramo
     FROM ramosubrh
    WHERE periodo = _periodo_ant
	  AND origen = _origen

	 UPDATE ramosubr
		SET cnt_polizas_ma  = v_cant_polizas_ma
	  WHERE cod_ramo     = v_cod_ramo
		AND cod_subramo  = v_cod_subramo;
			
   BEGIN
      ON EXCEPTION IN(-239)
         UPDATE temp_perfil1
            SET cant_polizas_ma   = v_cant_polizas_ma
          WHERE cod_ramo       = v_cod_ramo
            AND cod_subramo    = v_cod_subramo;

      END EXCEPTION
      INSERT INTO temp_perfil1
          VALUES(v_cod_ramo,
                 v_cod_subramo,
                 0,
				 v_cant_polizas_ma,
				 0
                 );
   END
END FOREACH

---RECLAMOS siniestralidad Ramos: 004, 018, 014, 013, 010, 012, 011, 022, 007, 003, 001, 008, 001, 003, 009, 005, 017, 019
FOREACH
	SELECT cod_ramo, cod_subramo, incurrido_bruto, no_poliza, salv_y_recup, pago_y_ded, var_reserva, cnt_incurrido, no_reclamo
	   INTO	_cod_ramo, _cod_subramo, v_incurrido_bruto, _no_poliza, _salv_y_recup, _pago_y_ded,	_var_reserva, _cnt_incurrido, _no_reclamo
	   FROM	tmp_siniest_uni
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
	       vigencia_inic,
		   cod_subramo
      INTO _nueva_renov,
	       _vigencia_inic,
		   _cod_subramo
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
			   SET incurrido_bruto = incurrido_bruto + v_incurrido_bruto, salv_rec = salv_rec + _salv_y_recup, pago_ded = pago_ded + _pago_y_ded, var_reserva = var_reserva + _var_reserva, cnt_incurridos = cnt_incurridos + _cnt_incurrido
			 WHERE cod_ramo        = _cod_ramo
			   AND cod_subramo     = "002";				   
		ELSE
			UPDATE ramosubr
			   SET incurrido_bruto = incurrido_bruto + v_incurrido_bruto, salv_rec = salv_rec + _salv_y_recup, pago_ded = pago_ded + _pago_y_ded, var_reserva = var_reserva + _var_reserva, cnt_incurridos = cnt_incurridos + _cnt_incurrido
			 WHERE cod_ramo        = _cod_ramo
			   AND cod_subramo     = "001";		
		END IF
		 
	END IF	
	IF _cod_ramo = "014" OR _cod_ramo = "013" THEN	--car y montaje
		UPDATE ramosubr
		   SET incurrido_bruto = incurrido_bruto + v_incurrido_bruto, salv_rec = salv_rec + _salv_y_recup, pago_ded = pago_ded + _pago_y_ded, var_reserva = var_reserva + _var_reserva, cnt_incurridos = cnt_incurridos + _cnt_incurrido
		 WHERE cod_ramo        = '010'
		   AND cod_subramo = "001";
	END IF
	IF _cod_ramo = "010" THEN
		UPDATE ramosubr
		   SET incurrido_bruto = incurrido_bruto + v_incurrido_bruto, salv_rec = salv_rec + _salv_y_recup, pago_ded = pago_ded + _pago_y_ded, var_reserva = var_reserva + _var_reserva, cnt_incurridos = cnt_incurridos + _cnt_incurrido
			 WHERE cod_ramo        = '010'
		   AND cod_subramo     = "002";
	END IF
	IF _cod_ramo = "012" THEN
		UPDATE ramosubr
		   SET incurrido_bruto = incurrido_bruto + v_incurrido_bruto, salv_rec = salv_rec + _salv_y_recup, pago_ded = pago_ded + _pago_y_ded, var_reserva = var_reserva + _var_reserva, cnt_incurridos = cnt_incurridos + _cnt_incurrido
			 WHERE cod_ramo        = '010'
		   AND cod_subramo     = "003";
	END IF
	IF _cod_ramo = "011" THEN
		UPDATE ramosubr
		   SET incurrido_bruto = incurrido_bruto + v_incurrido_bruto, salv_rec  = salv_rec + _salv_y_recup, pago_ded = pago_ded + _pago_y_ded, var_reserva = var_reserva + _var_reserva, cnt_incurridos = cnt_incurridos + _cnt_incurrido
			 WHERE cod_ramo        = '010'
		   AND cod_subramo     = "004";
	END IF
	IF _cod_ramo = "022" THEN
		UPDATE ramosubr
		   SET incurrido_bruto = incurrido_bruto + v_incurrido_bruto, salv_rec = salv_rec + _salv_y_recup, pago_ded = pago_ded + _pago_y_ded, var_reserva = var_reserva + _var_reserva, cnt_incurridos = cnt_incurridos + _cnt_incurrido
			 WHERE cod_ramo        = '010'
		   AND cod_subramo     = "005";
	END IF
	IF _cod_ramo = "007" THEN
		UPDATE ramosubr
		   SET incurrido_bruto = incurrido_bruto + v_incurrido_bruto,
		           salv_rec        = salv_rec        + _salv_y_recup,
			       pago_ded        = pago_ded        + _pago_y_ded,
			       var_reserva     = var_reserva     + _var_reserva, cnt_incurridos = cnt_incurridos + _cnt_incurrido
			 WHERE cod_ramo        = '010'
		   AND cod_subramo     = "006";
	END IF
    IF _cod_ramo = "003" AND _cod_subramo = "001" THEN
      UPDATE ramosubr
         SET incurrido_bruto = incurrido_bruto + v_incurrido_bruto,
		     salv_rec        = salv_rec        + _salv_y_recup,
			 pago_ded        = pago_ded        + _pago_y_ded,
			 var_reserva     = var_reserva     + _var_reserva, cnt_incurridos = cnt_incurridos + _cnt_incurrido
       WHERE cod_ramo        = _cod_ramo
         AND cod_subramo     = _cod_subramo;
    END IF
	IF _cod_ramo = "008" THEN
      IF _cod_subramo = "002" OR _cod_subramo = "018" THEN
		  UPDATE ramosubr
			 SET incurrido_bruto = incurrido_bruto + v_incurrido_bruto,
				 salv_rec        = salv_rec        + _salv_y_recup,
				 pago_ded        = pago_ded        + _pago_y_ded,
				 var_reserva     = var_reserva     + _var_reserva, cnt_incurridos = cnt_incurridos + _cnt_incurrido		 
		   WHERE cod_ramo        = _cod_ramo
			 AND cod_subramo     = '001';
	  ELIF 	_cod_subramo = "003" THEN	   
			UPDATE ramosubr
			 SET incurrido_bruto = incurrido_bruto + v_incurrido_bruto,
				 salv_rec        = salv_rec        + _salv_y_recup,
				 pago_ded        = pago_ded        + _pago_y_ded,
				 var_reserva     = var_reserva     + _var_reserva, cnt_incurridos = cnt_incurridos + _cnt_incurrido		 
 			 WHERE cod_ramo        = _cod_ramo
			   AND cod_subramo     = "003";
	  ELIF 	_cod_subramo = "012" THEN	   
			UPDATE ramosubr
			 SET incurrido_bruto = incurrido_bruto + v_incurrido_bruto,
				 salv_rec        = salv_rec        + _salv_y_recup,
				 pago_ded        = pago_ded        + _pago_y_ded,
				 var_reserva     = var_reserva     + _var_reserva, cnt_incurridos = cnt_incurridos + _cnt_incurrido		 
 			 WHERE cod_ramo        = _cod_ramo
			   AND cod_subramo     = "004";
	  ELIF 	_cod_subramo = "009" THEN	   
			UPDATE ramosubr
			 SET incurrido_bruto = incurrido_bruto + v_incurrido_bruto,
				 salv_rec        = salv_rec        + _salv_y_recup,
				 pago_ded        = pago_ded        + _pago_y_ded,
				 var_reserva     = var_reserva     + _var_reserva, cnt_incurridos = cnt_incurridos + _cnt_incurrido		 
 			 WHERE cod_ramo        = _cod_ramo
			   AND cod_subramo     = "005";
	  else
		  UPDATE ramosubr
			 SET incurrido_bruto = incurrido_bruto + v_incurrido_bruto,
				 salv_rec        = salv_rec        + _salv_y_recup,
				 pago_ded        = pago_ded        + _pago_y_ded,
				 var_reserva     = var_reserva     + _var_reserva, cnt_incurridos = cnt_incurridos + _cnt_incurrido		 
		   WHERE cod_ramo        = _cod_ramo
			 AND cod_subramo     = '002';
	  end if
	end if  
	IF _cod_ramo = "001" and _cod_subramo = '001' THEN
      UPDATE ramosubr
         SET incurrido_bruto = incurrido_bruto + v_incurrido_bruto,
		     salv_rec        = salv_rec        + _salv_y_recup,
			 pago_ded        = pago_ded        + _pago_y_ded,
			 var_reserva     = var_reserva     + _var_reserva, cnt_incurridos = cnt_incurridos + _cnt_incurrido		 
       WHERE cod_ramo        = _cod_ramo
         AND cod_subramo     = _cod_subramo;
    END IF
	IF _cod_ramo = "001" and _cod_subramo in ('002','007') THEN
      UPDATE ramosubr
         SET incurrido_bruto = incurrido_bruto + v_incurrido_bruto,
		     salv_rec        = salv_rec        + _salv_y_recup,
			 pago_ded        = pago_ded        + _pago_y_ded,
			 var_reserva     = var_reserva     + _var_reserva, cnt_incurridos = cnt_incurridos + _cnt_incurrido		 
       WHERE cod_ramo        = _cod_ramo
         AND cod_subramo     = '002';
    END IF
	IF _cod_ramo = "001" and _cod_subramo in('003','004','006') THEN
      UPDATE ramosubr
         SET incurrido_bruto = incurrido_bruto + v_incurrido_bruto,
		     salv_rec        = salv_rec        + _salv_y_recup,
			 pago_ded        = pago_ded        + _pago_y_ded,
			 var_reserva     = var_reserva     + _var_reserva, cnt_incurridos = cnt_incurridos + _cnt_incurrido		 
       WHERE cod_ramo        = _cod_ramo
         AND cod_subramo     = '003';
    END IF	

    IF _cod_ramo = "003" AND _cod_subramo <> "001" THEN
      UPDATE ramosubr
         SET incurrido_bruto = incurrido_bruto + v_incurrido_bruto,
		     salv_rec        = salv_rec        + _salv_y_recup,
			 pago_ded        = pago_ded        + _pago_y_ded,
			 var_reserva     = var_reserva     + _var_reserva, cnt_incurridos = cnt_incurridos + _cnt_incurrido		 
       WHERE cod_ramo        = _cod_ramo
         AND cod_subramo     = '002';
    END IF
    IF _cod_ramo = "009" AND _cod_subramo in('001','002','006','009') THEN -- Se agregó el subramo 009 10-08-2022 ID de la solicitud	# 4243
      UPDATE ramosubr
         SET incurrido_bruto = incurrido_bruto + v_incurrido_bruto,
		     salv_rec        = salv_rec        + _salv_y_recup,
			 pago_ded        = pago_ded        + _pago_y_ded,
			 var_reserva     = var_reserva     + _var_reserva, cnt_incurridos = cnt_incurridos + _cnt_incurrido		 
       WHERE cod_ramo        = _cod_ramo
         AND cod_subramo     = '002';
    END IF
    IF _cod_ramo = "009" AND _cod_subramo = "003" THEN
      UPDATE ramosubr
         SET incurrido_bruto = incurrido_bruto + v_incurrido_bruto,
		     salv_rec        = salv_rec        + _salv_y_recup,
			 pago_ded        = pago_ded        + _pago_y_ded,
			 var_reserva     = var_reserva     + _var_reserva, cnt_incurridos = cnt_incurridos + _cnt_incurrido		 
       WHERE cod_ramo        = _cod_ramo
         AND cod_subramo     = _cod_subramo;
    END IF
    IF _cod_ramo = "009" AND _cod_subramo IN ('004', '008') then --> Se incluye el subramo 008 MARINE CARGO STP
      UPDATE ramosubr
         SET incurrido_bruto = incurrido_bruto + v_incurrido_bruto,
		     salv_rec        = salv_rec        + _salv_y_recup,
			 pago_ded        = pago_ded        + _pago_y_ded,
			 var_reserva     = var_reserva     + _var_reserva, cnt_incurridos = cnt_incurridos + _cnt_incurrido		 
       WHERE cod_ramo        = _cod_ramo
         AND cod_subramo     = "004";
    END IF	
    IF _cod_ramo = "005" AND _cod_subramo = "001" THEN
      UPDATE ramosubr
         SET incurrido_bruto = incurrido_bruto + v_incurrido_bruto,
 		     salv_rec        = salv_rec        + _salv_y_recup,
			 pago_ded        = pago_ded        + _pago_y_ded,
			 var_reserva     = var_reserva     + _var_reserva, cnt_incurridos = cnt_incurridos + _cnt_incurrido
       WHERE cod_ramo        = _cod_ramo
         AND cod_subramo     = _cod_subramo;
    END IF

    IF _cod_ramo = "016" AND _cod_subramo <> "007" THEN    -- Colectivo de Vida Amado 28-05-2021
      UPDATE ramosubr
         SET incurrido_bruto = incurrido_bruto + v_incurrido_bruto,
		     salv_rec        = salv_rec        + _salv_y_recup,
			 pago_ded        = pago_ded        + _pago_y_ded,
			 var_reserva     = var_reserva     + _var_reserva, cnt_incurridos = cnt_incurridos + _cnt_incurrido		 
       WHERE cod_ramo        = _cod_ramo
         AND cod_subramo     = '001';
    END IF

    IF _cod_ramo = "016" AND _cod_subramo = "007" THEN      -- Colectivo de Deuda Amado 28-05-2021 
      UPDATE ramosubr
         SET incurrido_bruto = incurrido_bruto + v_incurrido_bruto,
		     salv_rec        = salv_rec        + _salv_y_recup,
			 pago_ded        = pago_ded        + _pago_y_ded,
			 var_reserva     = var_reserva     + _var_reserva, cnt_incurridos = cnt_incurridos + _cnt_incurrido		 
       WHERE cod_ramo        = _cod_ramo
         AND cod_subramo     = '002';
    END IF
	
    IF _cod_ramo = "017" AND _cod_subramo = "001" THEN
      UPDATE ramosubr
         SET incurrido_bruto = incurrido_bruto + v_incurrido_bruto,
		     salv_rec        = salv_rec        + _salv_y_recup,
			 pago_ded        = pago_ded        + _pago_y_ded,
			 var_reserva     = var_reserva     + _var_reserva, cnt_incurridos = cnt_incurridos + _cnt_incurrido		 
       WHERE cod_ramo        = _cod_ramo
         AND cod_subramo     = _cod_subramo;
    END IF

    IF _cod_ramo = "017" AND _cod_subramo = "002" THEN
      UPDATE ramosubr
         SET incurrido_bruto = incurrido_bruto + v_incurrido_bruto,
		     salv_rec        = salv_rec        + _salv_y_recup,
			 pago_ded        = pago_ded        + _pago_y_ded,
			 var_reserva     = var_reserva     + _var_reserva, cnt_incurridos = cnt_incurridos + _cnt_incurrido		 
       WHERE cod_ramo        = _cod_ramo
         AND cod_subramo     = _cod_subramo;
    END IF

 --   IF _cod_ramo = "019" AND _vig_fin_vida >= _fecha2 THEN
    IF _cod_ramo = "019" AND _nueva_renov = 'N' THEN
      UPDATE ramosubr
         SET incurrido_bruto = incurrido_bruto + v_incurrido_bruto,
		     salv_rec        = salv_rec        + _salv_y_recup,
			 pago_ded        = pago_ded        + _pago_y_ded,
			 var_reserva     = var_reserva     + _var_reserva, cnt_incurridos = cnt_incurridos + _cnt_incurrido		 
       WHERE cod_ramo        = _cod_ramo
         AND cod_subramo     = "001";
    END IF	

 --   IF _cod_ramo = "019" AND _vig_fin_vida < _fecha2 THEN
    IF _cod_ramo = "019" AND _nueva_renov = 'R' THEN
     UPDATE ramosubr
         SET incurrido_bruto = incurrido_bruto + v_incurrido_bruto,
		     salv_rec        = salv_rec        + _salv_y_recup,
			 pago_ded        = pago_ded        + _pago_y_ded,
			 var_reserva     = var_reserva     + _var_reserva, cnt_incurridos = cnt_incurridos + _cnt_incurrido		 
       WHERE cod_ramo        = _cod_ramo
         AND cod_subramo     = "002";
    END IF

	IF _cod_ramo in ('002','020','023') THEN
		SELECT no_unidad			
            INTO _no_unidad
		   FROM recrcmae 
		  WHERE no_reclamo = _no_reclamo;
			
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
          END IF
		  IF _uso_auto IS NULL OR TRIM(_uso_auto) = "" THEN
		   LET _uso_auto = 'P';
		  END IF 				
      IF _uso_auto = 'P' THEN
			UPDATE ramosubr
			 SET incurrido_bruto = incurrido_bruto + v_incurrido_bruto,
				 salv_rec        = salv_rec        + _salv_y_recup,
				 pago_ded        = pago_ded        + _pago_y_ded,
				 var_reserva     = var_reserva     + _var_reserva, cnt_incurridos = cnt_incurridos + _cnt_incurrido		 
 			 WHERE cod_ramo        = '002'
			   AND cod_subramo     = "001";
			LET _cod_ramo = '002';   
			LET _cod_subramo = '001';   
	  else
			UPDATE ramosubr
			 SET incurrido_bruto = incurrido_bruto + v_incurrido_bruto,
				 salv_rec        = salv_rec        + _salv_y_recup,
				 pago_ded        = pago_ded        + _pago_y_ded,
				 var_reserva     = var_reserva     + _var_reserva, cnt_incurridos = cnt_incurridos + _cnt_incurrido		 
 			 WHERE cod_ramo        = '002'
			   AND cod_subramo     = "002";
			LET _cod_ramo = '002';   
			LET _cod_subramo = '002';   
	  end if
	END IF

END FOREACH
--Actualizar los reclamos cerrados en el mes, ramos: 004, 018, 014, 013, 010, 012, 011, 022, 007, 008, 001, 003, 009, 005, 017, 019 
foreach
	select no_reclamo
	  into _no_reclamo
      from rectrmae
     where actualizado  = 1
	   and periodo      >= a_periodo
	   and periodo      <= a_periodo2
	   and (cod_tipotran = '011'
	   or cerrar_rec = 1)
	 group by no_reclamo
	 order by no_reclamo

   select no_poliza,
          no_unidad
	  into _no_poliza,
           _no_unidad
	  from recrcmae
	 where no_reclamo = _no_reclamo;
	 
	select cod_ramo,
	       cod_subramo,
		   vigencia_inic,
		   cod_origen,
		   nueva_renov
      into _cod_ramo,
	       _cod_subramo,
		   _vigencia_inic,
		   _cod_origen,
		   _nueva_renov
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
      IF _cod_subramo = "002" OR _cod_subramo = "018" THEN
		  UPDATE ramosubr
			 SET casos_cerrados  = casos_cerrados + 1
		   WHERE cod_ramo     = _cod_ramo
			 AND cod_subramo  = '001';
	  ELIF 	_cod_subramo = "003" THEN	   
		  UPDATE ramosubr
			 SET casos_cerrados  = casos_cerrados + 1
 		   WHERE cod_ramo        = _cod_ramo
			 AND cod_subramo     = "003";
	  ELIF 	_cod_subramo = "012" THEN	   
		  UPDATE ramosubr
			 SET casos_cerrados  = casos_cerrados + 1
 		   WHERE cod_ramo        = _cod_ramo
			 AND cod_subramo     = "004";
	  ELIF 	_cod_subramo = "009" THEN	   
		  UPDATE ramosubr
			 SET casos_cerrados  = casos_cerrados + 1
 		   WHERE cod_ramo        = _cod_ramo
			 AND cod_subramo     = "005";
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
	if _cod_ramo = '001' and _cod_subramo in ('002','007') then
      UPDATE ramosubr
         SET casos_cerrados  = casos_cerrados + 1
       WHERE cod_ramo     = _cod_ramo
         AND cod_subramo  = '002';
	end if
	
    IF _cod_ramo = "003" AND _cod_subramo = "001" THEN
      UPDATE ramosubr
         SET casos_cerrados  = casos_cerrados + 1
       WHERE cod_ramo     = _cod_ramo
         AND cod_subramo  = _cod_subramo;
    END IF

    IF _cod_ramo = "003" AND _cod_subramo <> "001" THEN
      UPDATE ramosubr
         SET casos_cerrados  = casos_cerrados + 1
       WHERE cod_ramo     = _cod_ramo
         AND cod_subramo  = "002";
    END IF
	IF _cod_ramo = "009" AND _cod_subramo in('001','002','006','009') THEN -- Se agregó el subramo 009 10-08-2022 ID de la solicitud	# 4243
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
         AND cod_subramo  = "004";
    END IF	
    IF _cod_ramo = "005" AND _cod_subramo = "001" THEN
      UPDATE ramosubr
         SET casos_cerrados  = casos_cerrados + 1
       WHERE cod_ramo     = _cod_ramo
         AND cod_subramo  = _cod_subramo;
    END IF

    IF _cod_ramo = "016" AND _cod_subramo <> "007" THEN --> Colectivo de Vida 27-05-2021
      UPDATE ramosubr
         SET casos_cerrados  = casos_cerrados + 1
       WHERE cod_ramo     = _cod_ramo
         AND cod_subramo  = '001';
    END IF

    IF _cod_ramo = "016" AND _cod_subramo = "007" THEN --> Colectivo de Deuda 27-05-2021
      UPDATE ramosubr
         SET casos_cerrados  = casos_cerrados + 1
       WHERE cod_ramo     = _cod_ramo
         AND cod_subramo  = "002";
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

 --   IF _cod_ramo = "019" AND _vig_fin_vida >= _fecha2 THEN --Amado 02-06-2017
    IF _cod_ramo = "019" AND _nueva_renov = 'N' THEN
      UPDATE ramosubr
         SET casos_cerrados  = casos_cerrados + 1
       WHERE cod_ramo     = _cod_ramo
         AND cod_subramo  = "001";
    END IF	

 --   IF _cod_ramo = "019" AND _vig_fin_vida < _fecha2 THEN --Amado 02-06-2017
    IF _cod_ramo = "019" AND _nueva_renov = 'R' THEN
      UPDATE ramosubr
         SET casos_cerrados  = casos_cerrados + 1
       WHERE cod_ramo     = _cod_ramo
         AND cod_subramo  = "002";
    END IF
	IF _cod_ramo in ('002','020','023') THEN
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
          END IF 
		  IF _uso_auto IS NULL OR TRIM(_uso_auto) = "" THEN
		   LET _uso_auto = 'P';
		  END IF 				
     IF _uso_auto = 'P' THEN
			UPDATE ramosubr
			   SET casos_cerrados  = casos_cerrados + 1
 			 WHERE cod_ramo        = '002'
			   AND cod_subramo     = "001";
			LET _cod_ramo = '002';   
			LET _cod_subramo = '001';   
	  else
			UPDATE ramosubr
               SET casos_cerrados  = casos_cerrados + 1
 			 WHERE cod_ramo        = '002'
			   AND cod_subramo     = "002";
			LET _cod_ramo = '002';   
			LET _cod_subramo = '002';   
	  end if
    END IF    
end foreach
--Actualizar la cantidad de reclamos, ramo: 004, 018, 014, 013, 010, 012, 011, 022, 007, 008, 001, 003, 005, 009, 017, 019  
FOREACH
	SELECT cod_ramo,
	       no_poliza,
		   no_reclamo
	  INTO _cod_ramo,
	       _no_poliza,
		   _no_reclamo
	  FROM tmp_sinis
	 WHERE seleccionado = 1

    select no_unidad
	  into _no_unidad
	  from recrcmae
	 where no_reclamo = _no_reclamo;

    SELECT nueva_renov,
		   cod_subramo,
		   vigencia_inic
		 --  cod_ramo,
		 --  cod_origen
      INTO _nueva_renov,
	       _cod_subramo,
		   _vigencia_inic
		 --  _cod_ramo,
		 --  _cod_origen
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
      IF _cod_subramo = "002" OR _cod_subramo = "018" THEN
		  UPDATE ramosubr
			 SET cnt_reclamo  = cnt_reclamo + 1
		   WHERE cod_ramo     = _cod_ramo
			 AND cod_subramo  = '001';
	  ELIF 	_cod_subramo = "003" THEN	   
		  UPDATE ramosubr
			 SET cnt_reclamo  = cnt_reclamo + 1
 		   WHERE cod_ramo        = _cod_ramo
			 AND cod_subramo     = "003";
	  ELIF 	_cod_subramo = "012" THEN	   
		  UPDATE ramosubr
			 SET cnt_reclamo  = cnt_reclamo + 1
 		   WHERE cod_ramo        = _cod_ramo
			 AND cod_subramo     = "004";
	  ELIF 	_cod_subramo = "009" THEN	   
		  UPDATE ramosubr
			 SET cnt_reclamo  = cnt_reclamo + 1
 		   WHERE cod_ramo        = _cod_ramo
			 AND cod_subramo     = "005";
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
	IF _cod_ramo = "001" and _cod_subramo in ('002','007') THEN
      UPDATE ramosubr
         SET cnt_reclamo  = cnt_reclamo + 1
       WHERE cod_ramo     = _cod_ramo
         AND cod_subramo  = '002';
    END IF	
    IF _cod_ramo = "003" AND _cod_subramo = "001" THEN
      UPDATE ramosubr
         SET cnt_reclamo  = cnt_reclamo + 1
       WHERE cod_ramo     = _cod_ramo
         AND cod_subramo  = _cod_subramo;
    END IF

    IF _cod_ramo = "003" AND _cod_subramo <> "001" THEN
      UPDATE ramosubr
         SET cnt_reclamo  = cnt_reclamo + 1
       WHERE cod_ramo     = _cod_ramo
         AND cod_subramo  = "002";
    END IF

    IF _cod_ramo = "005" AND _cod_subramo = "001" THEN
      UPDATE ramosubr
         SET cnt_reclamo  = cnt_reclamo + 1
       WHERE cod_ramo     = _cod_ramo
         AND cod_subramo  = _cod_subramo;
    END IF
	IF _cod_ramo = "009" AND _cod_subramo in('001','002','006','009') THEN -- Se agregó el subramo 009 10-08-2022 ID de la solicitud	# 4243
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
         AND cod_subramo  = "004";
    END IF	
 
    IF _cod_ramo = "016" AND _cod_subramo <> "007" THEN
      UPDATE ramosubr
         SET cnt_reclamo  = cnt_reclamo + 1
       WHERE cod_ramo     = _cod_ramo
         AND cod_subramo  = '001';
    END IF

    IF _cod_ramo = "016" AND _cod_subramo = "007" THEN
      UPDATE ramosubr
         SET cnt_reclamo  = cnt_reclamo + 1
       WHERE cod_ramo     = _cod_ramo
         AND cod_subramo  = '002';
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

 --   IF _cod_ramo = "019" AND _vig_fin_vida >= _fecha2 THEN --Amado 02-06-2017
    IF _cod_ramo = "019" AND _nueva_renov = 'N' THEN
      UPDATE ramosubr
         SET cnt_reclamo  = cnt_reclamo + 1
       WHERE cod_ramo     = _cod_ramo
         AND cod_subramo  = "001";
    END IF	

  --  IF _cod_ramo = "019" AND _vig_fin_vida < _fecha2 THEN --Amado 02-06-2017
     IF _cod_ramo = "019" AND _nueva_renov = 'R' THEN
   --_nueva_renov = "R" THEN
      UPDATE ramosubr
         SET cnt_reclamo  = cnt_reclamo + 1
       WHERE cod_ramo     = _cod_ramo
         AND cod_subramo  = "002";
    END IF
	IF _cod_ramo in ('002','020','023') THEN
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
          END IF
		  IF _uso_auto IS NULL OR TRIM(_uso_auto) = "" THEN
		   LET _uso_auto = 'P';
		  END IF 				
      IF _uso_auto = 'P' THEN
			UPDATE ramosubr
               SET cnt_reclamo  = cnt_reclamo + 1
 			 WHERE cod_ramo        = '002'
			   AND cod_subramo     = "001";
			LET _cod_ramo = '002';   
			LET _cod_subramo = '001';   
	  else
			UPDATE ramosubr
               SET cnt_reclamo  = cnt_reclamo + 1
 			 WHERE cod_ramo        = '002'
			   AND cod_subramo     = "002";
			LET _cod_ramo = '002';   
			LET _cod_subramo = '002';   
	  end if
	END IF

END FOREACH

-- Actualizando todo para los ramos: 003, 001, 017, 005, 016, 002, 006 ,015 

call sp_pro941b(a_periodo, a_periodo2, a_origen);

--call sp_pro422(a_periodo, a_periodo2, a_origen) returning _retorno;
call sp_pro568dd(a_periodo, a_periodo2, a_origen) returning _retorno;

let _calculo = 0;


foreach
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

   SELECT SUM(prima_suscrita), SUM(cnt_pol_nuevas), SUM(cnt_pol_ren), SUM(cnt_pol_can_cad), SUM(prima_sus_cor), SUM(prima_sus_dir), SUM(prima_sus_can)
     INTO _prima_suscrita, _cnt_prima_nva, _cnt_prima_ren, _cnt_prima_can, _prima_sus_cor, _prima_sus_dir, _prima_sus_can
     FROM temp_perfil2
    WHERE cod_ramo    = v_cod_ramo
	  and cod_subramo = _cod_subramo;
	  
	SELECT SUM(incurrido_bruto), SUM(salv_y_recup), SUM(pago_y_ded), SUM(var_reserva), SUM(cnt_incurrido)
	  INTO v_incurrido_bruto, _salv_y_recup, _pago_y_ded, _var_reserva, _cnt_incurrido
	  FROM	tmp_siniest_uni
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
	   and e.cod_ramo = v_cod_ramo
	   and e.cod_subramo = _cod_subramo;

	select count(*)			   
	  into _cnt_vencidas
	  from emipomae
	 WHERE vigencia_final >= _fecha1
	   AND vigencia_final <= _fecha2
	   and cod_origen like a_origen
	   and actualizado = 1
	   and cod_ramo = v_cod_ramo
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
	 _cnt_vencidas,
	 _prima_sus_cor,
	 _prima_sus_dir,
	 _prima_sus_can
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
	select cnt_polizas_ma, cnt_pol_nuevas, cnt_pol_ren, cnt_pol_can_cad, cnt_polizas, cnt_vencidas, cod_ramo, cod_subramo into v_cant_polizas_ma, _cnt_prima_nva, _cnt_prima_ren, _cnt_prima_can, v_cant_polizas, _cnt_vencidas, _cod_ramo, _cod_subramo from ramootro
	
	let _calculo = v_cant_polizas_ma + _cnt_prima_nva + _cnt_prima_ren - _cnt_prima_can - _cnt_vencidas;
	if _calculo - v_cant_polizas <> 0 Then
		if _calculo > v_cant_polizas then
			UPDATE ramootro 
			   SET cnt_vencidas = cnt_vencidas + _calculo - v_cant_polizas 
			 where cod_ramo     = _cod_ramo 
			   and cod_subramo  = _cod_subramo;
		else
			UPDATE ramootro 
			   SET cnt_pol_nuevas = cnt_pol_nuevas + v_cant_polizas - _calculo 
		     where cod_ramo       = _cod_ramo
 			   and cod_subramo    = _cod_subramo;
		end if
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
			   _cnt_incurrido,
			   _cnt_vencidas
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
    ELIF _cod_ramo = "002" THEN
		  LET v_desc_subramo = "";
		  IF  _cod_subramo = '001' THEN
		  	LET v_desc_subramo = "PARTICULAR";
		  ELSE
		  	LET v_desc_subramo = "COMERCIAL";
		  END IF
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
		  IF  _cod_subramo = '001' THEN
		  	LET v_desc_subramo = "COLECTIVO DE VIDA";
		  ELSE
		  	LET v_desc_subramo = "COLECTIVO DE DEUDA";
		  END IF
    ELIF _cod_ramo = "002" THEN
		  LET v_desc_subramo = "";
    ELIF _cod_ramo in ("006","026","027") THEN
		  LET v_desc_subramo = "";
    ELIF _cod_ramo = "008" THEN
		  LET v_desc_subramo = "";
		  IF _cod_subramo = '001' THEN
			let v_desc_subramo = 'OFERTA';
		  ELIF _cod_subramo = '002' THEN
			let v_desc_subramo = 'OTRAS';
		  ELIF _cod_subramo = "003" THEN
			  LET v_desc_subramo = "CUMPLIMIENTO";
		  ELIF _cod_subramo = "004" THEN
			  LET v_desc_subramo = "CREDITO";
		  ELIF _cod_subramo = "005" THEN
			  LET v_desc_subramo = "FIDELIDAD";
		  END IF
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
			   _cnt_prima_nva, _cnt_prima_ren, _cnt_prima_can, v_cant_asegurados, _cnt_incurrido, _cnt_vencidas WITH RESUME;
END FOREACH
DROP TABLE temp_perfil;
DROP TABLE temp_perfil_b;
DROP TABLE temp_perfil1;
DROP TABLE temp_perfil2;
DROP TABLE tmp_prod;
DROP TABLE temp_ramo;
DROP TABLE tmp_siniest_uni;
DROP TABLE tmp_sinis;
DROP TABLE tmp_vence;
END
END PROCEDURE;