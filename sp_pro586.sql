   DROP procedure sp_pro586;
   CREATE procedure "informix".sp_pro586(a_cia CHAR(03),a_agencia CHAR(3),a_periodo1 CHAR(7),a_periodo2 CHAR(7), a_origen CHAR(3) DEFAULT '%')
   RETURNING CHAR(50) AS subramo,
             INTEGER AS cant_polizas,
			 DEC(16,2) AS prima_suscrita,
			 CHAR(50) AS desc_ramo,
			 CHAR(45) AS compania,
			 SMALLINT AS mes,
			 SMALLINT AS orden,
			 DEC(16,2) AS siniestro_pag,
			 INTEGER AS poblacion_aseg,
			 SMALLINT AS orden_sub,
			 DEC(16,2) AS prima_devengada,
			 DEC(16,2) AS reembolso_admin,
			 DEC(16,2) AS comision_agent;
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
           _salv_y_recup,_pago_y_ded,_var_reserva, _calculo, _siniestro_pagado, _comision_agent DECIMAL(16,2);
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
	define _anio_aniv			char(4);
	define _mes_aniv			char(2);
	define _origen              smallint;
	define _error_isam			smallint;
	define _error				smallint;
    define _error_desc			varchar(50);
	define _cnt_agente          smallint;
	define _prima_devengada     dec(16,2);
	define _reembolso_admin     dec(16,2);
	define _porc_partic_agt, _porc_comis_agt dec(5,2);
	define _no_documento        char(20);
	define _orden_sub           smallint;
	
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
			  reembolso_admin DECIMAL(16,2),
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
LET _origen          = 0;

SET ISOLATION TO DIRTY READ;

begin

on exception set _error,_error_isam,_error_desc
	return _error_desc, _error, 0.00, "", "", 0, 0, 0.00, 0, 0, 0.00, 0.00, 0.00;
end exception


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
CALL sp_pro586c(
a_cia,
a_agencia,
_fecha2,
'*',
'4;Ex') RETURNING v_filtros;


--SET DEBUG FILE TO "sp_pro94.trc"; 
--trace on;

{LET _ano1 = a_periodo[1,4];
LET _mes1 = a_periodo[6,7];

LET _fecha1 = MDY(_mes1,1,_ano1);
LET _fecha1 = _fecha1 - 1;

LET _anio_aniv = YEAR(_fecha1);

IF MONTH(_fecha1) < 10 THEN
	LET _mes_aniv = '0' || MONTH(_fecha1);
ELSE
	LET _mes_aniv = MONTH(_fecha1);
END IF

LET a_periodo = _anio_aniv || '-' || _mes_aniv;
}
--trace off;

-- Prima Suscrita tmp_prod
CALL sp_pro586d(
a_cia,
a_agencia,
a_periodo1,
a_periodo2,
'*',
'*',
'*',
'*',
'4;Ex',		--Reaseguro Asumido Excluido
'*',   --Solo Bac
'*',
'*',
a_origen
) RETURNING v_filtros;
--Trae los siniestros brutos incurridos tmp_siniest
CALL sp_pro586g(
a_cia,
a_agencia,
a_periodo1,
a_periodo2
);

-- Excluye los Reclamos en Reaseguro Asumido
update tmp_siniest
   set seleccionado = 0
 where seleccionado = 1
   and cod_tipoprod = "004";

-- Excluye los Reclamos que no sean BAC
update tmp_siniest
   set seleccionado = 0
 where seleccionado = 1
   and cod_agente <> "02596";

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

 update temp_perfil
   set cod_ramo = '002'
 where cod_ramo = '020';

LET _fecha1 = MDY(1,1,year(_fecha2));

-- Trae la prima devengada BAC -- tmp_prima_devengada
CALL sp_pro586e(
_fecha1,
_fecha2
) returning _error, _error_desc;

update tmp_prima_devengada
   set cod_ramo = '002'
 where cod_ramo = '020';

update tmp_prima_devengada
   set cod_ramo = '002'
 where cod_ramo = '023';

update tmp_prima_devengada
   set cod_ramo = '001'
 where cod_ramo = '021';

--Trae la cant. de reclamos por ramo --tmp_sinis
{CALL sp_rec03(
a_cia, 
a_periodo, 
a_periodo2, "*", "*", "*", "*", "*",
a_origen
) RETURNING v_filtros;}
CALL sp_pro586f(
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
 
UPDATE canaldist_super
   SET prima_suscrita  = 0, cnt_polizas = 0, prima_devengada = 0, siniestro_pagado = 0, reembolso_admin = 0, comision_agent = 0, poblacion_aseg = 0;	   
	 
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
	
  SELECT porc_partic_agt,
         porc_comis_agt
    INTO _porc_partic_agt,
	     _porc_comis_agt
	FROM emipoagt
   WHERE no_poliza = _no_poliza;
   
   let _reembolso_admin = 0;
   
   let _reembolso_admin = _total_pri_sus * _porc_partic_agt / 100 * _porc_comis_agt / 100;

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
     UPDATE canaldist_super
        SET prima_suscrita = prima_suscrita + _total_pri_sus,
		    reembolso_admin = reembolso_admin + _reembolso_admin
      WHERE cod_ramo     = _cod_ramo
        AND cod_subramo  = "001";
   END IF	

  -- IF _cod_ramo = "019" AND (_vig_fin_vida <= _vig_ini_end or _nueva_renov = "R") THEN --Amado 02/06/2017
  IF _cod_ramo = "019" AND _nueva_renov = "R" THEN
     UPDATE canaldist_super
        SET prima_suscrita = prima_suscrita + _total_pri_sus,
		    reembolso_admin = reembolso_admin + _reembolso_admin
      WHERE cod_ramo     = _cod_ramo
        AND cod_subramo  = "002";
		
	END IF
   IF _cod_ramo = '004' OR _cod_ramo = '018' THEN
		select count(*)
		  into _cantidad
		  from emipouni
		 where no_poliza = _no_poliza;
		 
		IF _cantidad > 1 then
			UPDATE canaldist_super
			   SET prima_suscrita = prima_suscrita + _total_pri_sus,
				   reembolso_admin = reembolso_admin + _reembolso_admin
 			 WHERE cod_ramo        = _cod_ramo
			   AND cod_subramo     = "002";
		ELSE
			UPDATE canaldist_super
			   SET prima_suscrita = prima_suscrita + _total_pri_sus,
				   reembolso_admin = reembolso_admin + _reembolso_admin
 			 WHERE cod_ramo        = _cod_ramo
			   AND cod_subramo     = "001";		
		END IF
		 
	END IF
	IF _cod_ramo = "014" OR _cod_ramo = "013" THEN	--car y montaje
		UPDATE canaldist_super
           SET prima_suscrita = prima_suscrita + _total_pri_sus,
		       reembolso_admin = reembolso_admin + _reembolso_admin
 	     WHERE cod_ramo        = '010'
		   AND cod_subramo     = "001";
	END IF
	IF _cod_ramo = "010" THEN --equio electronico
		UPDATE canaldist_super
           SET prima_suscrita = prima_suscrita + _total_pri_sus,
		       reembolso_admin = reembolso_admin + _reembolso_admin
 		 WHERE cod_ramo        = '010'
		   AND cod_subramo     = "002";
	END IF
	IF _cod_ramo = "012" THEN	--calderas
		UPDATE canaldist_super
           SET prima_suscrita = prima_suscrita + _total_pri_sus,
		       reembolso_admin = reembolso_admin + _reembolso_admin
 	     WHERE cod_ramo        = '010'
		   AND cod_subramo     = "003";
	END IF
	IF _cod_ramo = "011" THEN	--rotura de maquinaria
		UPDATE canaldist_super
           SET prima_suscrita = prima_suscrita + _total_pri_sus,
		       reembolso_admin = reembolso_admin + _reembolso_admin
 	     WHERE cod_ramo        = '010'
		   AND cod_subramo     = "004";
	END IF
	IF _cod_ramo = "022" THEN	--equipo pesado
		UPDATE canaldist_super
           SET prima_suscrita = prima_suscrita + _total_pri_sus,
		       reembolso_admin = reembolso_admin + _reembolso_admin
 	     WHERE cod_ramo        = '010'
		   AND cod_subramo     = "005";
	END IF
	IF _cod_ramo = "007" THEN	--vidrios
		UPDATE canaldist_super
           SET prima_suscrita = prima_suscrita + _total_pri_sus,
		       reembolso_admin = reembolso_admin + _reembolso_admin
 	     WHERE cod_ramo        = '010'
		   AND cod_subramo     = "006";
	END IF
	IF _cod_ramo = "008" THEN
      IF _cod_subramo = "002" OR _cod_subramo = "003" OR _cod_subramo = "018" THEN
			UPDATE canaldist_super
               SET prima_suscrita = prima_suscrita + _total_pri_sus,
		           reembolso_admin = reembolso_admin + _reembolso_admin
 			 WHERE cod_ramo        = _cod_ramo
			   AND cod_subramo     = "001";
	  else
			UPDATE canaldist_super
               SET prima_suscrita = prima_suscrita + _total_pri_sus,
		           reembolso_admin = reembolso_admin + _reembolso_admin
 			 WHERE cod_ramo        = _cod_ramo
			   AND cod_subramo     = "002";
	  end if
	END IF  
	if _cod_ramo = '009' and _cod_subramo in('001','002','006') then
			UPDATE canaldist_super
               SET prima_suscrita = prima_suscrita + _total_pri_sus,
		           reembolso_admin = reembolso_admin + _reembolso_admin
 			 WHERE cod_ramo        = _cod_ramo
			   AND cod_subramo     = "002";
	end if
	if _cod_ramo = '009' and _cod_subramo = '003' then	
			UPDATE canaldist_super
               SET prima_suscrita = prima_suscrita + _total_pri_sus,
		           reembolso_admin = reembolso_admin + _reembolso_admin
 			 WHERE cod_ramo        = _cod_ramo
			   AND cod_subramo     = "003";
	end if
	if _cod_ramo = '009' and _cod_subramo in ('004', '008') then --> Se incluye el subramo 008 MARINE CARGO STP
			UPDATE canaldist_super
               SET prima_suscrita = prima_suscrita + _total_pri_sus,
		           reembolso_admin = reembolso_admin + _reembolso_admin
			 WHERE cod_ramo        = _cod_ramo
			   AND cod_subramo     = "004";
	end if
	   BEGIN
          ON EXCEPTION IN(-239)
             UPDATE temp_perfil2
                SET prima_suscrita = prima_suscrita + _total_pri_sus, 
				    cnt_pol_nuevas = cnt_pol_nuevas  + _cnt_prima_nva, 
					cnt_pol_ren = cnt_pol_ren + _cnt_prima_ren, 
					cnt_pol_can_cad  = cnt_pol_can_cad + _cnt_prima_can,
					reembolso_admin = reembolso_admin + _reembolso_admin
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
					 _reembolso_admin
                     );
       END
END FOREACH
--Cargando las polizas vigentes, ramos: 019, 004, 018, 014, 013, 010, 012, 011, 022, 007, 008, 009
FOREACH WITH HOLD
   SELECT no_poliza, cod_ramo, cod_subramo
     INTO _no_poliza, v_cod_ramo, v_cod_subramo
     FROM temp_perfil
    WHERE seleccionado = 1
	
	let _cnt_agente = 0;
	

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
    UPDATE canaldist_super
        SET cnt_polizas  = cnt_polizas + 1,
		    poblacion_aseg = poblacion_aseg + _cantidad_aseg
      WHERE cod_ramo     = v_cod_ramo
        AND cod_subramo  = "001";
   END IF	

   --IF v_cod_ramo = "019" AND _vig_fin_vida < _fecha2 THEN --Amado 02-06-2017
   IF v_cod_ramo = "019" AND _nueva_renov = 'R' THEN
    UPDATE canaldist_super
        SET cnt_polizas  = cnt_polizas + 1,
		    poblacion_aseg = poblacion_aseg + _cantidad_aseg
      WHERE cod_ramo     = v_cod_ramo
        AND cod_subramo  = "002";
   END IF
   IF v_cod_ramo = "014" OR v_cod_ramo = "013" THEN	--car y montaje
		UPDATE canaldist_super
		   SET cnt_polizas = cnt_polizas + 1, 
		       poblacion_aseg = poblacion_aseg + _cantidad_aseg     
		 WHERE cod_ramo    = '010'
		   AND cod_subramo = "001";
	END IF
	IF v_cod_ramo = "010" THEN
		UPDATE canaldist_super
		   SET cnt_polizas = cnt_polizas + 1, 
		       poblacion_aseg = poblacion_aseg + _cantidad_aseg
	     WHERE cod_ramo    = '010'
		   AND cod_subramo = "002";
	END IF
	IF v_cod_ramo = "012" THEN
		UPDATE canaldist_super
		   SET cnt_polizas = cnt_polizas + 1, 
		       poblacion_aseg = poblacion_aseg + _cantidad_aseg
	     WHERE cod_ramo    = '010'
		   AND cod_subramo = "003";
	END IF
	IF v_cod_ramo = "011" THEN
		UPDATE canaldist_super
		   SET cnt_polizas = cnt_polizas + 1, 
		       poblacion_aseg = poblacion_aseg + _cantidad_aseg
	     WHERE cod_ramo    = '010'
		   AND cod_subramo = "004";
	END IF
	IF v_cod_ramo = "022" THEN
		UPDATE canaldist_super
		   SET cnt_polizas = cnt_polizas + 1, 
		       poblacion_aseg = poblacion_aseg + _cantidad_aseg
	     WHERE cod_ramo    = '010'
		   AND cod_subramo = "005";
	END IF
	IF v_cod_ramo = "007" THEN
		UPDATE canaldist_super
		   SET cnt_polizas = cnt_polizas + 1, 
		       poblacion_aseg = poblacion_aseg + _cantidad_aseg
	     WHERE cod_ramo    = '010'
		   AND cod_subramo = "006";
	END IF
	if v_cod_ramo = '009' and v_cod_subramo in('001','002','006') then
			UPDATE canaldist_super
			   SET cnt_polizas = cnt_polizas + 1, 
			       poblacion_aseg = poblacion_aseg + _cantidad_aseg
			 WHERE cod_ramo    = v_cod_ramo
			   AND cod_subramo = "002";
	end if
	if v_cod_ramo = '009' and v_cod_subramo = '003' then	
			UPDATE canaldist_super
			   SET cnt_polizas = cnt_polizas + 1, 
			       poblacion_aseg = poblacion_aseg + _cantidad_aseg
			 WHERE cod_ramo    = v_cod_ramo
			   AND cod_subramo = "003";
	end if
	if v_cod_ramo = '009' and v_cod_subramo in ('004', '008') then --> Se incluye el subramo 008 MARINE CARGO STP	
			UPDATE canaldist_super
			   SET cnt_polizas = cnt_polizas + 1, 
			       poblacion_aseg = poblacion_aseg + _cantidad_aseg
			 WHERE cod_ramo    = v_cod_ramo
			   AND cod_subramo = "004";
	end if
	IF v_cod_ramo = "008" THEN
      IF v_cod_subramo = "002" OR v_cod_subramo = "003" OR v_cod_subramo = "018" THEN
			UPDATE canaldist_super
			   SET cnt_polizas = cnt_polizas + 1, 
			       poblacion_aseg = poblacion_aseg + _cantidad_aseg
			 WHERE cod_ramo        = v_cod_ramo
			   AND cod_subramo     = "001";
	  else
			UPDATE canaldist_super
			   SET cnt_polizas = cnt_polizas + 1, 
			       poblacion_aseg = poblacion_aseg + _cantidad_aseg
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
	     UPDATE canaldist_super
            SET cnt_polizas  = cnt_polizas + 1, 
			    poblacion_aseg = poblacion_aseg + _cantidad_aseg
	      WHERE cod_ramo     = v_cod_ramo
	        AND cod_subramo  = "002";
		else
	     UPDATE canaldist_super
            SET cnt_polizas  = cnt_polizas + 1, 
			    poblacion_aseg = poblacion_aseg + _cantidad_aseg
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
---RECLAMOS siniestralidad Ramos: 004, 018, 014, 013, 010, 012, 011, 022, 007, 003, 001, 008, 001, 003, 009, 005, 017, 019
FOREACH
	SELECT cod_ramo, cod_subramo, siniestro_pagado, no_poliza
	   INTO	_cod_ramo, _cod_subramo, _siniestro_pagado, _no_poliza 
	   FROM	tmp_siniest
	  WHERE seleccionado = 1

	IF _siniestro_pagado IS NULL THEN
		LET _siniestro_pagado = 0;
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
			UPDATE canaldist_super
			   SET siniestro_pagado = siniestro_pagado + _siniestro_pagado
			 WHERE cod_ramo        = _cod_ramo
			   AND cod_subramo     = "002";				   
		ELSE
			UPDATE canaldist_super
			   SET siniestro_pagado = siniestro_pagado + _siniestro_pagado
			 WHERE cod_ramo        = _cod_ramo
			   AND cod_subramo     = "001";		
		END IF
		 
	END IF	
	IF _cod_ramo = "014" OR _cod_ramo = "013" THEN	--car y montaje
		UPDATE canaldist_super
		   SET siniestro_pagado = siniestro_pagado + _siniestro_pagado
		 WHERE cod_ramo        = '010'
		   AND cod_subramo = "001";
	END IF
	IF _cod_ramo = "010" THEN
		UPDATE canaldist_super
		   SET siniestro_pagado = siniestro_pagado + _siniestro_pagado
			 WHERE cod_ramo        = '010'
		   AND cod_subramo     = "002";
	END IF
	IF _cod_ramo = "012" THEN
		UPDATE canaldist_super
		   SET siniestro_pagado = siniestro_pagado + _siniestro_pagado
			 WHERE cod_ramo        = '010'
		   AND cod_subramo     = "003";
	END IF
	IF _cod_ramo = "011" THEN
		UPDATE canaldist_super
		   SET siniestro_pagado = siniestro_pagado + _siniestro_pagado
			 WHERE cod_ramo        = '010'
		   AND cod_subramo     = "004";
	END IF
	IF _cod_ramo = "022" THEN
		UPDATE canaldist_super
		   SET siniestro_pagado = siniestro_pagado + _siniestro_pagado
			 WHERE cod_ramo        = '010'
		   AND cod_subramo     = "005";
	END IF
	IF _cod_ramo = "007" THEN
		UPDATE canaldist_super
		   SET siniestro_pagado = siniestro_pagado + _siniestro_pagado
			 WHERE cod_ramo        = '010'
		   AND cod_subramo     = "006";
	END IF
    IF _cod_ramo = "003" AND _cod_subramo = "001" THEN
      UPDATE canaldist_super
         SET siniestro_pagado = siniestro_pagado + _siniestro_pagado
       WHERE cod_ramo        = _cod_ramo
         AND cod_subramo     = _cod_subramo;
    END IF
	IF _cod_ramo = "008" THEN
      IF _cod_subramo = "002" OR _cod_subramo = "003" OR _cod_subramo = "018" THEN
		  UPDATE canaldist_super
			 SET siniestro_pagado = siniestro_pagado + _siniestro_pagado		 
		   WHERE cod_ramo        = _cod_ramo
			 AND cod_subramo     = '001';
	  else
		  UPDATE canaldist_super
			 SET siniestro_pagado = siniestro_pagado + _siniestro_pagado		 
		   WHERE cod_ramo        = _cod_ramo
			 AND cod_subramo     = '002';
	  end if
	end if  
	IF _cod_ramo = "001" and _cod_subramo = '001' THEN
      UPDATE canaldist_super
         SET siniestro_pagado = siniestro_pagado + _siniestro_pagado		 
       WHERE cod_ramo        = _cod_ramo
         AND cod_subramo     = _cod_subramo;
    END IF
	IF _cod_ramo = "001" and _cod_subramo in ('002', '007') THEN
      UPDATE canaldist_super
         SET siniestro_pagado = siniestro_pagado + _siniestro_pagado		 
       WHERE cod_ramo        = _cod_ramo
         AND cod_subramo     = '002';
    END IF
	IF _cod_ramo = "001" and _cod_subramo in('003','004','006') THEN
      UPDATE canaldist_super
         SET siniestro_pagado = siniestro_pagado + _siniestro_pagado		 
       WHERE cod_ramo        = _cod_ramo
         AND cod_subramo     = '003';
    END IF	

    IF _cod_ramo = "003" AND _cod_subramo <> "001" THEN
      UPDATE canaldist_super
         SET siniestro_pagado = siniestro_pagado + _siniestro_pagado		 
       WHERE cod_ramo        = _cod_ramo
         AND cod_subramo     = '002';
    END IF
    IF _cod_ramo = "009" AND _cod_subramo in('001','002','006') THEN
      UPDATE canaldist_super
         SET siniestro_pagado = siniestro_pagado + _siniestro_pagado		 
       WHERE cod_ramo        = _cod_ramo
         AND cod_subramo     = '002';
    END IF
    IF _cod_ramo = "009" AND _cod_subramo = "003" THEN
      UPDATE canaldist_super
         SET siniestro_pagado = siniestro_pagado + _siniestro_pagado		 
       WHERE cod_ramo        = _cod_ramo
         AND cod_subramo     = _cod_subramo;
    END IF
    IF _cod_ramo = "009" AND _cod_subramo IN ('004', '008') then --> Se incluye el subramo 008 MARINE CARGO STP
      UPDATE canaldist_super
         SET siniestro_pagado = siniestro_pagado + _siniestro_pagado		 
       WHERE cod_ramo        = _cod_ramo
         AND cod_subramo     = "004";
    END IF	
    IF _cod_ramo = "005" AND _cod_subramo = "001" THEN
      UPDATE canaldist_super
         SET siniestro_pagado = siniestro_pagado + _siniestro_pagado
       WHERE cod_ramo        = _cod_ramo
         AND cod_subramo     = _cod_subramo;
    END IF

    IF _cod_ramo = "017" AND _cod_subramo = "001" THEN
      UPDATE canaldist_super
         SET siniestro_pagado = siniestro_pagado + _siniestro_pagado		 
       WHERE cod_ramo        = _cod_ramo
         AND cod_subramo     = _cod_subramo;
    END IF

    IF _cod_ramo = "017" AND _cod_subramo = "002" THEN
      UPDATE canaldist_super
         SET siniestro_pagado = siniestro_pagado + _siniestro_pagado		 
       WHERE cod_ramo        = _cod_ramo
         AND cod_subramo     = _cod_subramo;
    END IF

 --   IF _cod_ramo = "019" AND _vig_fin_vida >= _fecha2 THEN
    IF _cod_ramo = "019" AND _nueva_renov = 'N' THEN
      UPDATE canaldist_super
         SET siniestro_pagado = siniestro_pagado + _siniestro_pagado		 
       WHERE cod_ramo        = _cod_ramo
         AND cod_subramo     = "001";
    END IF	

 --   IF _cod_ramo = "019" AND _vig_fin_vida < _fecha2 THEN
    IF _cod_ramo = "019" AND _nueva_renov = 'R' THEN
     UPDATE canaldist_super
         SET siniestro_pagado = siniestro_pagado + _siniestro_pagado		 
       WHERE cod_ramo        = _cod_ramo
         AND cod_subramo     = "002";
    END IF

END FOREACH

-- Prima devengada

FOREACH
	SELECT cod_ramo, cod_subramo, no_documento, sum(prima_devengada)
	   INTO	_cod_ramo, _cod_subramo, _no_documento, _prima_devengada 
	   FROM	tmp_prima_devengada
	  group by cod_ramo, cod_subramo, no_documento

	IF _prima_devengada IS NULL THEN
		LET _prima_devengada = 0;
	END IF
	
	FOREACH
		select no_poliza,
		       nueva_renov,
			   vigencia_inic
		  into _no_poliza,
		       _nueva_renov,
			   _vigencia_inic
		  from emipomae
		 where no_documento = _no_documento
		   and actualizado = 1
		   and (vigencia_final   >= _fecha2
		    or vigencia_final    IS NULL)
		  and fecha_suscripcion <= _fecha2
		  and vigencia_inic     <= _fecha2
		 order by vigencia_final desc

		exit foreach;
	END FOREACH
	
--    SELECT nueva_renov,
--	       vigencia_inic
--      INTO _nueva_renov,
--	       _vigencia_inic
 --     FROM emipomae
 --    WHERE no_poliza = _no_poliza;

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
			UPDATE canaldist_super
			   SET prima_devengada = prima_devengada + _prima_devengada
			 WHERE cod_ramo        = _cod_ramo
			   AND cod_subramo     = "002";				   
		ELSE
			UPDATE canaldist_super
			   SET prima_devengada = prima_devengada + _prima_devengada
			 WHERE cod_ramo        = _cod_ramo
			   AND cod_subramo     = "001";		
		END IF
		 
	END IF	
	IF _cod_ramo = "014" OR _cod_ramo = "013" THEN	--car y montaje
		UPDATE canaldist_super
		   SET prima_devengada = prima_devengada + _prima_devengada
		 WHERE cod_ramo        = '010'
		   AND cod_subramo = "001";
	END IF
	IF _cod_ramo = "010" THEN
		UPDATE canaldist_super
		   SET prima_devengada = prima_devengada + _prima_devengada
		 WHERE cod_ramo        = '010'
		   AND cod_subramo     = "002";
	END IF
	IF _cod_ramo = "012" THEN
		UPDATE canaldist_super
			   SET prima_devengada = prima_devengada + _prima_devengada
			 WHERE cod_ramo        = '010'
		   AND cod_subramo     = "003";
	END IF
	IF _cod_ramo = "011" THEN
		UPDATE canaldist_super
			   SET prima_devengada = prima_devengada + _prima_devengada
			 WHERE cod_ramo        = '010'
		   AND cod_subramo     = "004";
	END IF
	IF _cod_ramo = "022" THEN
		UPDATE canaldist_super
			   SET prima_devengada = prima_devengada + _prima_devengada
			 WHERE cod_ramo        = '010'
		   AND cod_subramo     = "005";
	END IF
	IF _cod_ramo = "007" THEN
		UPDATE canaldist_super
			   SET prima_devengada = prima_devengada + _prima_devengada
			 WHERE cod_ramo        = '010'
		   AND cod_subramo     = "006";
	END IF
    IF _cod_ramo = "003" AND _cod_subramo = "001" THEN
      UPDATE canaldist_super
			   SET prima_devengada = prima_devengada + _prima_devengada
       WHERE cod_ramo        = _cod_ramo
         AND cod_subramo     = _cod_subramo;
    END IF
	IF _cod_ramo = "008" THEN
      IF _cod_subramo = "002" OR _cod_subramo = "003" OR _cod_subramo = "018" THEN
		  UPDATE canaldist_super
			   SET prima_devengada = prima_devengada + _prima_devengada
		   WHERE cod_ramo        = _cod_ramo
			 AND cod_subramo     = '001';
	  else
		  UPDATE canaldist_super
			   SET prima_devengada = prima_devengada + _prima_devengada
		   WHERE cod_ramo        = _cod_ramo
			 AND cod_subramo     = '002';
	  end if
	end if  
	IF _cod_ramo = "001" and _cod_subramo = '001' THEN
      UPDATE canaldist_super
 	     SET prima_devengada = prima_devengada + _prima_devengada
       WHERE cod_ramo        = _cod_ramo
         AND cod_subramo     = _cod_subramo;
    END IF
	IF _cod_ramo = "001" and _cod_subramo in ('002', '007') THEN
      UPDATE canaldist_super
         SET siniestro_pagado = siniestro_pagado + _siniestro_pagado		 
       WHERE cod_ramo        = _cod_ramo
         AND cod_subramo     = '002';
    END IF
	IF _cod_ramo = "001" and _cod_subramo in('003','004','006') THEN
      UPDATE canaldist_super
   	     SET prima_devengada = prima_devengada + _prima_devengada
       WHERE cod_ramo        = _cod_ramo
         AND cod_subramo     = '003';
    END IF	

    IF _cod_ramo = "003" AND _cod_subramo <> "001" THEN
      UPDATE canaldist_super
		 SET prima_devengada = prima_devengada + _prima_devengada
       WHERE cod_ramo        = _cod_ramo
         AND cod_subramo     = '002';
    END IF
    IF _cod_ramo = "009" AND _cod_subramo in('001','002','006') THEN
      UPDATE canaldist_super
 			   SET prima_devengada = prima_devengada + _prima_devengada
       WHERE cod_ramo        = _cod_ramo
         AND cod_subramo     = '002';
    END IF
    IF _cod_ramo = "009" AND _cod_subramo = "003" THEN
      UPDATE canaldist_super
			   SET prima_devengada = prima_devengada + _prima_devengada
       WHERE cod_ramo        = _cod_ramo
         AND cod_subramo     = _cod_subramo;
    END IF
    IF _cod_ramo = "009" AND _cod_subramo IN ('004', '008') then --> Se incluye el subramo 008 MARINE CARGO STP
      UPDATE canaldist_super
			   SET prima_devengada = prima_devengada + _prima_devengada
       WHERE cod_ramo        = _cod_ramo
         AND cod_subramo     = "004";
    END IF	
    IF _cod_ramo = "005" AND _cod_subramo = "001" THEN
      UPDATE canaldist_super
			   SET prima_devengada = prima_devengada + _prima_devengada
       WHERE cod_ramo        = _cod_ramo
         AND cod_subramo     = _cod_subramo;
    END IF

    IF _cod_ramo = "017" AND _cod_subramo = "001" THEN
      UPDATE canaldist_super
			   SET prima_devengada = prima_devengada + _prima_devengada
       WHERE cod_ramo        = _cod_ramo
         AND cod_subramo     = _cod_subramo;
    END IF

    IF _cod_ramo = "017" AND _cod_subramo = "002" THEN
      UPDATE canaldist_super
			   SET prima_devengada = prima_devengada + _prima_devengada
       WHERE cod_ramo        = _cod_ramo
         AND cod_subramo     = _cod_subramo;
    END IF

 --   IF _cod_ramo = "019" AND _vig_fin_vida >= _fecha2 THEN
    IF _cod_ramo = "019" AND _nueva_renov = 'N' THEN
      UPDATE canaldist_super
			   SET prima_devengada = prima_devengada + _prima_devengada
       WHERE cod_ramo        = _cod_ramo
         AND cod_subramo     = "001";
    END IF	

 --   IF _cod_ramo = "019" AND _vig_fin_vida < _fecha2 THEN
    IF _cod_ramo = "019" AND _nueva_renov = 'R' THEN
     UPDATE canaldist_super
			   SET prima_devengada = prima_devengada + _prima_devengada
       WHERE cod_ramo        = _cod_ramo
         AND cod_subramo     = "002";
    END IF

END FOREACH


-- Actualizando todo para los ramos: 003, 001, 017, 005, 016, 002, 006 ,015 

call sp_pro586b(a_periodo2, a_periodo2);

FOREACH
        SELECT cod_ramo,
			   cod_subramo,
			   cnt_polizas,
			   prima_suscrita,
			   orden,
			   siniestro_pagado,
			   poblacion_aseg,
			   prima_devengada,
			   reembolso_admin,
			   comision_agent
          INTO _cod_ramo,
			   _cod_subramo,
			   v_cant_polizas,
			   _prima_suscrita,
			   _orden,
			   _siniestro_pagado,
			   v_cant_asegurados,
			   _prima_devengada,
			   _reembolso_admin,
			   _comision_agent
          FROM canaldist_super
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

       RETURN  v_desc_subramo, 
	           v_cant_polizas, 
			   _prima_suscrita, 
			   v_desc_ramo, 
			   descr_cia, 
			   _mes, 
			   _orden, 
			   _siniestro_pagado,
			   v_cant_asegurados, 
			   _orden_sub,
			   _prima_devengada,
			   _reembolso_admin,
			   _comision_agent WITH RESUME;
END FOREACH

{FOREACH
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
			   cnt_asegurados
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
			   periodo,
			   origen)
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
			   a_periodo2,
               _origen
			   );

END FOREACH
}
{FOREACH
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
			  cnt_asegurados
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
			  v_cant_asegurados
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
			  periodo,
			  origen
			 )
			 values(
			 v_cod_ramo,
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
			 a_periodo2,
			 _origen
			 );
	 
END FOREACH
}
DROP TABLE temp_perfil;
--DROP TABLE temp_perfil_b;
DROP TABLE temp_perfil1;
DROP TABLE temp_perfil2;
DROP TABLE tmp_prod;
DROP TABLE temp_ramo;
DROP TABLE tmp_siniest;
DROP TABLE tmp_sinis;

--return 0, "Actualizacion exitosa";
end
END PROCEDURE;