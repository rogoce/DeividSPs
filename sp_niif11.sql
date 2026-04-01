   DROP procedure sp_niif11;
   CREATE procedure "informix".sp_niif11(a_agno CHAR(4))
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
	
	DEFINE _agno                SMALLINT;
	DEFINE _monto_pagado        DEC(16,2);
	DEFINE _no_unidad           CHAR(5);
	DEFINE _cod_cober_reas      CHAR(3);
    DEFINE _periodo             CHAR(7);
    DEFINE _periodo_desde       CHAR(7);
    DEFINE _periodo_hasta       CHAR(7);
    DEFINE _unidades            INTEGER;
	DEFINE _suma_limite         DEC(16,2);
	DEFINE _no_documento        CHAR(20);
	DEFINE _agno_siniestro      INTEGER;

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
LET _cnt_incurrido   = 0;

SET ISOLATION TO DIRTY READ;

begin

on exception set _error,_error_isam,_error_desc
	return _error, _error_desc;
end exception

let _periodo_desde = a_agno || '-' || '01';
let _periodo_hasta = a_agno || '-' || '12';

-- Descomponer los periodos en fechas
LET _ano2 = _periodo_hasta[1,4];
LET _mes2 = _periodo_hasta[6,7];
LET _mes = _mes2;

IF _mes2 = 12 THEN
   LET _mes2 = 1;
   LET _ano2 = _ano2 + 1;
ELSE
   LET _mes2 = _mes2 + 1;
END IF
LET _fecha2 = MDY(_mes2,1,_ano2);
LET _fecha2 = _fecha2 - 1;

--LET _periodo_hasta = '2022-01'; --> poner en comentario despues de las pruebas

-- Prima Suscrita tmp_prod
CALL sp_niif11b(
'001',
'001',
_periodo_desde,
_periodo_hasta,
'*',
'*',
'*',
'*',
'4;Ex',		--Reaseguro Asumido Excluido
'*',
'*',
'*',
'%'
) RETURNING v_filtros;

-- Pólizas vigentes
--trae cant. de polizas vig. temp_perfil
CALL sp_pro568aa(
'001',
'001',
_fecha2,
'*',
'4;Ex',
'%') RETURNING v_filtros;

-- Reclamos Ocurridos tmp_reclamo
CALL sp_niif11c(
_periodo_desde,
_periodo_hasta) RETURNING _error, _error_desc;

--SET DEBUG FILE TO "sp_pro94.trc"; 
--trace on;

LET _agno = a_agno;
DELETE FROM niiframosubr where agno = _agno;
DELETE FROM niifpolsini where agno = _agno;


FOREACH
	SELECT periodo[1,4], cod_ramo, cod_subramo, monto_pagado, no_poliza, no_unidad, cod_cober_reas, no_reclamo
	  INTO _agno, v_cod_ramo, v_cod_subramo, _monto_pagado, _no_poliza, _no_unidad, _cod_cober_reas, _no_reclamo
	  FROM niif_rcs
	  WHERE periodo >= _periodo_desde
        AND periodo <= _periodo_hasta

	-- Ramos AP, Salud, RC, Transporte, Robo, Automovil, Soda, Flota, Equipo Elect., Rotura, Calderas, Equipo Pesado, Vidrios
	IF v_cod_ramo in ('004', '018', '006', '009', '005', '002', '020', '023', '010','011','012','022','007') THEN
	    LET v_cod_subramo = '001';
	    IF v_cod_ramo = '004' THEN
			LET _orden = 30;
		ELIF v_cod_ramo = '018' THEN	
			LET _orden = 40;
		ELIF v_cod_ramo IN ('001', '003') THEN	
			LET _orden = 50;
		ELIF v_cod_ramo = '006' THEN	
			LET _orden = 80;
		ELIF v_cod_ramo = '009' THEN	
			LET _orden = 90;
		ELIF v_cod_ramo = '005' THEN	
			LET _orden = 100;
		ELIF v_cod_ramo in ('002', '020', '023') THEN	
		    LET v_cod_ramo = '002';
			LET _orden = 120;
		ELIF v_cod_ramo in ('010','011','012','022','007') THEN	
		    LET v_cod_ramo = '002';
			LET _orden = 130;
		END IF	
		
		BEGIN
		 ON EXCEPTION IN(-239,-268)
			 UPDATE niiframosubr
				SET siniestro_pagado  = siniestro_pagado + _monto_pagado
			  WHERE agno           = _agno
			    AND cod_ramo       = v_cod_ramo
				AND cod_subramo    = v_cod_subramo;

		  END EXCEPTION
		  INSERT INTO niiframosubr
			  VALUES(_agno,
			         v_cod_ramo,
					 v_cod_subramo,
					 _monto_pagado,
					 _orden,
					 0,
					 0,
					 0
					 );
		END	
    ELIF v_cod_ramo in ('016','019','017','008') THEN -- Colectivo, Vida Individual, Casco, Fianza
		IF v_cod_ramo = '016' AND v_cod_subramo = '007' THEN -- Colectivo, subramo Desgravamen
			LET _orden = 11;
			LET v_cod_subramo = '001';
			BEGIN
			 ON EXCEPTION IN(-239,-268)
				 UPDATE niiframosubr
					SET siniestro_pagado  = siniestro_pagado + _monto_pagado
			      WHERE agno           = _agno
			        AND cod_ramo       = v_cod_ramo
				    AND cod_subramo    = v_cod_subramo;

			  END EXCEPTION
			  INSERT INTO niiframosubr
				  VALUES(_agno,
						 v_cod_ramo,
						 v_cod_subramo,
						 _monto_pagado,
						 _orden,
						 0,
					     0,
					     0
						 );
			END	
		END IF	
		IF v_cod_ramo = '019' AND (v_cod_subramo = '005' OR v_cod_subramo = '006') THEN --Vida Individual, subramos Tarifa a Termino, Tarifa a Edad
			LET _orden = 11;
			LET v_cod_ramo = '016';
			LET v_cod_subramo = '001';
			BEGIN
			 ON EXCEPTION IN(-239,-268)
				 UPDATE niiframosubr
					SET siniestro_pagado  = siniestro_pagado + _monto_pagado
			      WHERE agno           = _agno
			        AND cod_ramo       = v_cod_ramo
				    AND cod_subramo    = v_cod_subramo;

			  END EXCEPTION
			  INSERT INTO niiframosubr
				  VALUES(_agno,
						 v_cod_ramo,
						 v_cod_subramo,
						 _monto_pagado,
						 _orden,
						 0,
					     0,
					     0
						 );
			END	
		END IF	
		IF v_cod_ramo = '017' AND (v_cod_subramo = '001' OR v_cod_subramo = '002') THEN -- Casco, subramo Maritimo, Aereo
			IF v_cod_subramo = '001' THEN
				LET _orden = 60;
			ELSE
                LET _orden = 70; 	
            END IF				
			BEGIN
			 ON EXCEPTION IN(-239,-268)
				 UPDATE niiframosubr
					SET siniestro_pagado  = siniestro_pagado + _monto_pagado
			      WHERE agno           = _agno
			        AND cod_ramo       = v_cod_ramo
				    AND cod_subramo    = v_cod_subramo;

			  END EXCEPTION
			  INSERT INTO niiframosubr
				  VALUES(_agno,
						 v_cod_ramo,
						 v_cod_subramo,
						 _monto_pagado,
						 _orden,
						 0,
					     0,
					     0
						 );
			END	
		END IF	
		-- Ramo Fianza, Subramos Cumplimiento de obra, secuestro, exoneración de impuesto y pago
		IF v_cod_ramo = '008' AND (v_cod_subramo = '017' OR v_cod_subramo = '005' OR v_cod_subramo = '008' OR v_cod_subramo = '004') THEN
			IF v_cod_subramo = '017' THEN
				LET _orden = 171;
			ELIF v_cod_subramo = '005' THEN
                LET _orden = 172; 	
			ELSE
                LET _orden = 173; 	
            END IF				
			BEGIN
			 ON EXCEPTION IN(-239,-268)
				 UPDATE niiframosubr
					SET siniestro_pagado  = siniestro_pagado + _monto_pagado
			      WHERE agno           = _agno
			        AND cod_ramo       = v_cod_ramo
				    AND cod_subramo    = v_cod_subramo;

			  END EXCEPTION
			  INSERT INTO niiframosubr
				  VALUES(_agno,
						 v_cod_ramo,
						 v_cod_subramo,
						 _monto_pagado,
						 _orden,
						 0,
					     0,
					     0
						 );
			END	
		END IF	
			
    ELIF v_cod_ramo in ('001', '003') THEN -- Incendio, Multirriesgo
		IF _cod_cober_reas IN ('021','022') THEN -- Coberturas Terremoto
			BEGIN
			 ON EXCEPTION IN(-239,-268)
				 UPDATE niiframosubr
					SET siniestro_pagado  = siniestro_pagado + _monto_pagado
				  WHERE agno           = _agno
				    AND cod_ramo       = '998'
					AND cod_subramo    = '001';

			  END EXCEPTION
			  INSERT INTO niiframosubr
				  VALUES(_agno,
						 '998',
						 '001',
						 _monto_pagado,
						 140,
						 0,
					     0,
					     0
						 );
			END		
        ELIF _cod_cober_reas IN ('030','032')	THEN  -- Coberturas Inundación
			BEGIN
			 ON EXCEPTION IN(-239,-268)
				 UPDATE niiframosubr
					SET siniestro_pagado  = siniestro_pagado + _monto_pagado
				  WHERE agno           = _agno
				    AND cod_ramo       = '999'
					AND cod_subramo    = '001';

			  END EXCEPTION
			  INSERT INTO niiframosubr
				  VALUES(_agno,
						 '999',
						 '001',
						 _monto_pagado,
						 150,
						 0,
					     0,
					     0
						 );
			END		
		ELSE
		    LET v_cod_ramo = '001';
		    LET v_cod_subramo = '001';
			BEGIN
			 ON EXCEPTION IN(-239,-268)
				 UPDATE niiframosubr
					SET siniestro_pagado  = siniestro_pagado + _monto_pagado
			      WHERE agno           = _agno
			        AND cod_ramo       = v_cod_ramo
				    AND cod_subramo    = v_cod_subramo;

			  END EXCEPTION
			  INSERT INTO niiframosubr
				  VALUES(_agno,
						 v_cod_ramo,
						 v_cod_subramo,
						 _monto_pagado,
						 50,
						 0,
					     0,
					     0
						 );
			END		
		END IF
	END IF	
	

END FOREACH

-- Prima Suscrita

FOREACH
	SELECT periodo[1,4], cod_ramo, cod_subramo, total_pri_sus, no_poliza, no_endoso, periodo
	  INTO _agno, v_cod_ramo, v_cod_subramo, _monto_pagado, _no_poliza, _no_endoso, _periodo
	  FROM tmp_prod
	  WHERE periodo >= _periodo_desde
        AND periodo <= _periodo_hasta

	
	IF v_cod_ramo in ('004', '018', '006', '009', '005', '002', '020', '023', '010','011','012','022','007') THEN
	    LET v_cod_subramo = '001';
	    IF v_cod_ramo = '004' THEN
			LET _orden = 30;
		ELIF v_cod_ramo = '018' THEN	
			LET _orden = 40;
		ELIF v_cod_ramo IN ('001', '003') THEN	
			LET _orden = 50;
		ELIF v_cod_ramo = '006' THEN	
			LET _orden = 80;
		ELIF v_cod_ramo = '009' THEN	
			LET _orden = 90;
		ELIF v_cod_ramo = '005' THEN	
			LET _orden = 100;
		ELIF v_cod_ramo in ('002', '020', '023') THEN	
		    LET v_cod_ramo = '002';
			LET _orden = 120;
		ELIF v_cod_ramo in ('010','011','012','022','007') THEN	
		    LET v_cod_ramo = '002';
			LET _orden = 130;
		END IF	
		
		BEGIN
		 ON EXCEPTION IN(-239,-268)
			 UPDATE niiframosubr
				SET prima  = prima + _monto_pagado
			  WHERE agno           = _agno
			    AND cod_ramo       = v_cod_ramo
				AND cod_subramo    = v_cod_subramo;

		  END EXCEPTION
		  INSERT INTO niiframosubr
			  VALUES(_agno,
			         v_cod_ramo,
					 v_cod_subramo,
					 0,
					 _orden,
					 _monto_pagado,
					 0,
					 0
					 );
		END	
    ELIF v_cod_ramo in ('016','019','017','008') THEN
		IF v_cod_ramo = '016' AND v_cod_subramo = '007' THEN
			LET _orden = 11;
			LET v_cod_subramo = '001';
			BEGIN
			 ON EXCEPTION IN(-239,-268)
				 UPDATE niiframosubr
					SET prima  = prima + _monto_pagado
			      WHERE agno           = _agno
			        AND cod_ramo       = v_cod_ramo
				    AND cod_subramo    = v_cod_subramo;

			  END EXCEPTION
			  INSERT INTO niiframosubr
			  VALUES(_agno,
			         v_cod_ramo,
					 v_cod_subramo,
					 0,
					 _orden,
					 _monto_pagado,
					 0,
					 0
					 );
			END	
		END IF	
		IF v_cod_ramo = '019' AND (v_cod_subramo = '005' OR v_cod_subramo = '006') THEN
			LET _orden = 11;
			LET v_cod_ramo = '016';
			LET v_cod_subramo = '001';
			BEGIN
			 ON EXCEPTION IN(-239,-268)
				 UPDATE niiframosubr
					SET prima  = prima + _monto_pagado
			      WHERE agno           = _agno
			        AND cod_ramo       = v_cod_ramo
				    AND cod_subramo    = v_cod_subramo;

			  END EXCEPTION
			  INSERT INTO niiframosubr
			  VALUES(_agno,
			         v_cod_ramo,
					 v_cod_subramo,
					 0,
					 _orden,
					 _monto_pagado,
					 0,
					 0
					 );
			END	
		END IF	
		IF v_cod_ramo = '017' AND (v_cod_subramo = '001' OR v_cod_subramo = '002') THEN
			IF v_cod_subramo = '001' THEN
				LET _orden = 60;
			ELSE
                LET _orden = 70; 	
            END IF				
			BEGIN
			 ON EXCEPTION IN(-239,-268)
				 UPDATE niiframosubr
					SET prima  = prima + _monto_pagado
			      WHERE agno           = _agno
			        AND cod_ramo       = v_cod_ramo
				    AND cod_subramo    = v_cod_subramo;

			  END EXCEPTION
			  INSERT INTO niiframosubr
			  VALUES(_agno,
			         v_cod_ramo,
					 v_cod_subramo,
					 0,
					 _orden,
					 _monto_pagado,
					 0,
					 0
					 );
			END	
		END IF	
		IF v_cod_ramo = '008' AND (v_cod_subramo = '017' OR v_cod_subramo = '005' OR v_cod_subramo = '008' OR v_cod_subramo = '004') THEN
			IF v_cod_subramo = '017' THEN
				LET _orden = 171;
			ELIF v_cod_subramo = '005' THEN
                LET _orden = 172; 	
			ELSE
                LET _orden = 173; 	
            END IF				
			BEGIN
			 ON EXCEPTION IN(-239,-268)
				 UPDATE niiframosubr
					SET prima  = prima + _monto_pagado
			      WHERE agno           = _agno
			        AND cod_ramo       = v_cod_ramo
				    AND cod_subramo    = v_cod_subramo;

			  END EXCEPTION
			  INSERT INTO niiframosubr
			  VALUES(_agno,
			         v_cod_ramo,
					 v_cod_subramo,
					 0,
					 _orden,
					 _monto_pagado,
					 0,
					 0
					 );
			END	
		END IF	
			
    ELIF v_cod_ramo in ('001', '003') THEN
	    FOREACH
			SELECT a.prima_neta,
				   b.cod_cober_reas
			  INTO _monto_pagado,
                   _cod_cober_reas
              FROM endedcob a, prdcober b
             WHERE a.cod_cobertura = b.cod_cobertura
			   AND a.no_poliza = _no_poliza
               AND a.no_endoso = _no_endoso
			   
			   
			IF _cod_cober_reas IN ('021','022') THEN
				BEGIN
				 ON EXCEPTION IN(-239,-268)
					 UPDATE niiframosubr
						SET prima  = prima + _monto_pagado
					  WHERE agno           = _agno
						AND cod_ramo       = '998'
						AND cod_subramo    = '001';

				  END EXCEPTION
				  INSERT INTO niiframosubr
			      VALUES(_agno,
			              '998',
					      '001',
					      0,
					      140,
					      _monto_pagado,
					      0,
					      0
					      );
				END		
			ELIF _cod_cober_reas IN ('030','032')	THEN
				BEGIN
				 ON EXCEPTION IN(-239,-268)
					 UPDATE niiframosubr
						SET prima  = prima + _monto_pagado
					  WHERE agno           = _agno
						AND cod_ramo       = '999'
						AND cod_subramo    = '001';

				  END EXCEPTION
				  INSERT INTO niiframosubr
					  VALUES(_agno,
							 '999',
							 '001',
							 0,
							 150,
							 _monto_pagado,
							 0,
							 0
							 );
				END		
			ELSE
			    LET v_cod_ramo = '001';
				LET v_cod_subramo = '001';
				BEGIN
				 ON EXCEPTION IN(-239,-268)
					 UPDATE niiframosubr
						SET prima  = prima + _monto_pagado
					  WHERE agno           = _agno
						AND cod_ramo       = v_cod_ramo
						AND cod_subramo    = v_cod_subramo;

				  END EXCEPTION
				  INSERT INTO niiframosubr
					  VALUES(_agno,
							 v_cod_ramo,
							 v_cod_subramo,
							 0,
							 50,
							 _monto_pagado,
							 0,
							 0
							 );
				END		
			END IF
			END FOREACH
	END IF	
	

END FOREACH

-- Polizas vigentes
FOREACH
	SELECT cod_ramo, cod_subramo, no_poliza
	  INTO v_cod_ramo, v_cod_subramo, _no_poliza
	  FROM tmp_prod

	
	IF v_cod_ramo in ('004', '018', '006', '009', '005', '002', '020', '023', '010','011','012','022','007') THEN
	    LET v_cod_subramo = '001';
	    IF v_cod_ramo = '004' THEN
			LET _orden = 30;
		ELIF v_cod_ramo IN ('001', '003') THEN	
			LET _orden = 50;
		ELIF v_cod_ramo = '006' THEN	
			LET _orden = 80;
		ELIF v_cod_ramo = '009' THEN	
			LET _orden = 90;
		ELIF v_cod_ramo = '005' THEN	
			LET _orden = 100;
		ELIF v_cod_ramo in ('002', '020', '023') THEN	
		    LET v_cod_ramo = '002';
			LET _orden = 120;
		ELIF v_cod_ramo in ('010','011','012','022','007') THEN	
		    LET v_cod_ramo = '002';
			LET _orden = 130;
		END IF	
		
		BEGIN
		 ON EXCEPTION IN(-239,-268)
			 UPDATE niiframosubr
				SET riesgo_vigor  = riesgo_vigor + 1
			  WHERE agno           = a_agno
			    AND cod_ramo       = v_cod_ramo
				AND cod_subramo    = v_cod_subramo;

		  END EXCEPTION
		  INSERT INTO niiframosubr
			  VALUES(a_agno,
			         v_cod_ramo,
					 v_cod_subramo,
					 0,
					 _orden,
					 0,
					 1,
					 0
					 );
		END	
	ELIF v_cod_ramo = '018' THEN	       
		LET _orden = 40;
        SELECT count(*)
          INTO _unidades
          FROM emipouni
         WHERE no_poliza = _no_poliza;
 		BEGIN
		 ON EXCEPTION IN(-239,-268)
			 UPDATE niiframosubr
				SET riesgo_vigor  = riesgo_vigor + _unidades
			  WHERE agno           = a_agno
			    AND cod_ramo       = v_cod_ramo
				AND cod_subramo    = v_cod_subramo;

		  END EXCEPTION
		  INSERT INTO niiframosubr
			  VALUES(a_agno,
			         v_cod_ramo,
					 v_cod_subramo,
					 0,
					 _orden,
					 0,
					 _unidades,
					 0
					 );
		END	
       
    ELIF v_cod_ramo in ('016','019','017','008') THEN
		IF v_cod_ramo = '016' AND v_cod_subramo = '007' THEN
			LET _orden = 11;
			LET v_cod_subramo = '001';
            SELECT count(*)
              INTO _unidades
              FROM emipouni
             WHERE no_poliza = _no_poliza;

			BEGIN
			 ON EXCEPTION IN(-239,-268)
				 UPDATE niiframosubr
			  	    SET riesgo_vigor  = riesgo_vigor + _unidades
			      WHERE agno           = a_agno
			        AND cod_ramo       = v_cod_ramo
				    AND cod_subramo    = v_cod_subramo;

			  END EXCEPTION
			  INSERT INTO niiframosubr
			  VALUES(a_agno,
			         v_cod_ramo,
					 v_cod_subramo,
					 0,
					 _orden,
					 0,
					 _unidades,
					 0
					 );
			END	
		END IF	
		IF v_cod_ramo = '019' AND (v_cod_subramo = '005' OR v_cod_subramo = '006') THEN
			LET _orden = 11;
			LET v_cod_ramo = '016';
			LET v_cod_subramo = '001';
            SELECT count(*)
              INTO _unidades
              FROM emipouni
             WHERE no_poliza = _no_poliza;
			BEGIN
			 ON EXCEPTION IN(-239,-268)
				 UPDATE niiframosubr
				    SET riesgo_vigor  = riesgo_vigor + _unidades
			      WHERE agno           = a_agno
			        AND cod_ramo       = v_cod_ramo
				    AND cod_subramo    = v_cod_subramo;

			  END EXCEPTION
			  INSERT INTO niiframosubr
			  VALUES(a_agno,
			         v_cod_ramo,
					 v_cod_subramo,
					 0,
					 _orden,
					 0,
					 _unidades,
					 0
					 );
			END	
		END IF	
		IF v_cod_ramo = '017' AND (v_cod_subramo = '001' OR v_cod_subramo = '002') THEN
			IF v_cod_subramo = '001' THEN
				LET _orden = 60;
			ELSE
                LET _orden = 70; 	
            END IF				
			BEGIN
			 ON EXCEPTION IN(-239,-268)
				 UPDATE niiframosubr
				    SET riesgo_vigor  = riesgo_vigor + 1
			      WHERE agno           = a_agno
			        AND cod_ramo       = v_cod_ramo
				    AND cod_subramo    = v_cod_subramo;

			  END EXCEPTION
			  INSERT INTO niiframosubr
			  VALUES(a_agno,
			         v_cod_ramo,
					 v_cod_subramo,
					 0,
					 _orden,
					 0,
					 1,
					 0
					 );
			END	
		END IF	
		IF v_cod_ramo = '008' AND (v_cod_subramo = '017' OR v_cod_subramo = '005' OR v_cod_subramo = '008' OR v_cod_subramo = '004') THEN
			IF v_cod_subramo = '017' THEN
				LET _orden = 171;
			ELIF v_cod_subramo = '005' THEN
                LET _orden = 172; 	
			ELSE
                LET _orden = 173; 	
            END IF				
			BEGIN
			 ON EXCEPTION IN(-239,-268)
				 UPDATE niiframosubr
				    SET riesgo_vigor  = riesgo_vigor + 1
			      WHERE agno           = a_agno
			        AND cod_ramo       = v_cod_ramo
				    AND cod_subramo    = v_cod_subramo;

			  END EXCEPTION
			  INSERT INTO niiframosubr
			  VALUES(a_agno,
			         v_cod_ramo,
					 v_cod_subramo,
					 0,
					 _orden,
					 0,
					 1,
					 0
					 );
			END	
		END IF	
			
    ELIF v_cod_ramo in ('001', '003') THEN
	    FOREACH
			SELECT b.cod_cober_reas
			  INTO _cod_cober_reas
              FROM emipocob a, prdcober b
             WHERE a.cod_cobertura = b.cod_cobertura
			   AND a.no_poliza = _no_poliza
            group by 1
			   
			   
			IF _cod_cober_reas IN ('021','022') THEN
				BEGIN
				 ON EXCEPTION IN(-239,-268)
					 UPDATE niiframosubr
				        SET riesgo_vigor  = riesgo_vigor + 1
					  WHERE agno           = a_agno
						AND cod_ramo       = '998'
						AND cod_subramo    = '001';

				  END EXCEPTION
				  INSERT INTO niiframosubr
			      VALUES(a_agno,
			              '998',
					      '001',
					      0,
					      140,
					      0,
					      1,
					      0
					      );
				END		
			ELIF _cod_cober_reas IN ('030','032')	THEN
				BEGIN
				 ON EXCEPTION IN(-239,-268)
					 UPDATE niiframosubr
				        SET riesgo_vigor  = riesgo_vigor + 1
					  WHERE agno           = a_agno
						AND cod_ramo       = '999'
						AND cod_subramo    = '001';

				  END EXCEPTION
				  INSERT INTO niiframosubr
					  VALUES(a_agno,
							 '999',
							 '001',
							 0,
							 150,
							 0,
							 1,
							 0
							 );
				END		
			ELSE
			    LET v_cod_ramo = '001';
				LET v_cod_subramo = '001';
				BEGIN
				 ON EXCEPTION IN(-239,-268)
					 UPDATE niiframosubr
			        	SET riesgo_vigor  = riesgo_vigor + 1
					  WHERE agno           = a_agno
						AND cod_ramo       = v_cod_ramo
						AND cod_subramo    = v_cod_subramo;

				  END EXCEPTION
				  INSERT INTO niiframosubr
					  VALUES(a_agno,
							 v_cod_ramo,
							 v_cod_subramo,
							 0,
							 50,
							 0,
							 1,
							 0
							 );
				END		
			END IF
			END FOREACH
	END IF	
	

END FOREACH

-- Reclamos Ocurridos

FOREACH
	SELECT periodo[1,4], cod_ramo, cod_subramo, no_reclamo
	  INTO _agno, v_cod_ramo, v_cod_subramo,_no_reclamo
	  FROM tmp_reclamo
	  WHERE periodo >= _periodo_desde
        AND periodo <= _periodo_hasta
	 group by 1, 2, 3, 4

	-- Ramos AP, Salud, RC, Transporte, Robo, Automovil, Soda, Flota, Equipo Elect., Rotura, Calderas, Equipo Pesado, Vidrios
	IF v_cod_ramo in ('004', '018', '006', '009', '005', '002', '020', '023', '010','011','012','022','007') THEN
	    LET v_cod_subramo = '001';
	    IF v_cod_ramo = '004' THEN
			LET _orden = 30;
		ELIF v_cod_ramo = '018' THEN	
			LET _orden = 40;
		ELIF v_cod_ramo IN ('001', '003') THEN	
			LET _orden = 50;
		ELIF v_cod_ramo = '006' THEN	
			LET _orden = 80;
		ELIF v_cod_ramo = '009' THEN	
			LET _orden = 90;
		ELIF v_cod_ramo = '005' THEN	
			LET _orden = 100;
		ELIF v_cod_ramo in ('002', '020', '023') THEN	
		    LET v_cod_ramo = '002';
			LET _orden = 120;
		ELIF v_cod_ramo in ('010','011','012','022','007') THEN	
		    LET v_cod_ramo = '002';
			LET _orden = 130;
		END IF	
		
		BEGIN
		 ON EXCEPTION IN(-239,-268)
			 UPDATE niiframosubr
				SET riesgo_sinies  = riesgo_sinies + 1
			  WHERE agno           = _agno
			    AND cod_ramo       = v_cod_ramo
				AND cod_subramo    = v_cod_subramo;

		  END EXCEPTION
		  INSERT INTO niiframosubr
			  VALUES(_agno,
			         v_cod_ramo,
					 v_cod_subramo,
					 0,
					 _orden,
					 0,
					 0,
					 1
					 );
		END	
    ELIF v_cod_ramo in ('016','019','017','008') THEN -- Colectivo, Vida Individual, Casco, Fianza
		IF v_cod_ramo = '016' AND v_cod_subramo = '007' THEN -- Colectivo, subramo Desgravamen
			LET _orden = 11;
			LET v_cod_subramo = '001';
			BEGIN
			 ON EXCEPTION IN(-239,-268)
				 UPDATE niiframosubr
					SET riesgo_sinies  = riesgo_sinies + 1
			      WHERE agno           = _agno
			        AND cod_ramo       = v_cod_ramo
				    AND cod_subramo    = v_cod_subramo;

			  END EXCEPTION
			  INSERT INTO niiframosubr
				  VALUES(_agno,
						 v_cod_ramo,
						 v_cod_subramo,
						 0,
						 _orden,
						 0,
					     0,
					     1
						 );
			END	
		END IF	
		IF v_cod_ramo = '019' AND (v_cod_subramo = '005' OR v_cod_subramo = '006') THEN --Vida Individual, subramos Tarifa a Termino, Tarifa a Edad
			LET _orden = 11;
			LET v_cod_ramo = '016';
			LET v_cod_subramo = '001';
			BEGIN
			 ON EXCEPTION IN(-239,-268)
				 UPDATE niiframosubr
					SET riesgo_sinies  = riesgo_sinies + 1
			      WHERE agno           = _agno
			        AND cod_ramo       = v_cod_ramo
				    AND cod_subramo    = v_cod_subramo;

			  END EXCEPTION
			  INSERT INTO niiframosubr
				  VALUES(_agno,
						 v_cod_ramo,
						 v_cod_subramo,
						 0,
						 _orden,
						 0,
					     0,
					     1
						 );
			END	
		END IF	
		IF v_cod_ramo = '017' AND (v_cod_subramo = '001' OR v_cod_subramo = '002') THEN -- Casco, subramo Maritimo, Aereo
			IF v_cod_subramo = '001' THEN
				LET _orden = 60;
			ELSE
                LET _orden = 70; 	
            END IF				
			BEGIN
			 ON EXCEPTION IN(-239,-268)
				 UPDATE niiframosubr
					SET riesgo_sinies  = riesgo_sinies + 1
			      WHERE agno           = _agno
			        AND cod_ramo       = v_cod_ramo
				    AND cod_subramo    = v_cod_subramo;

			  END EXCEPTION
			  INSERT INTO niiframosubr
				  VALUES(_agno,
						 v_cod_ramo,
						 v_cod_subramo,
						 0,
						 _orden,
						 0,
					     0,
					     1
						 );
			END	
		END IF	
		-- Ramo Fianza, Subramos Cumplimiento de obra, secuestro, exoneración de impuesto y pago
		IF v_cod_ramo = '008' AND (v_cod_subramo = '017' OR v_cod_subramo = '005' OR v_cod_subramo = '008' OR v_cod_subramo = '004') THEN
			IF v_cod_subramo = '017' THEN
				LET _orden = 171;
			ELIF v_cod_subramo = '005' THEN
                LET _orden = 172; 	
			ELSE
                LET _orden = 173; 	
            END IF				
			BEGIN
			 ON EXCEPTION IN(-239,-268)
				 UPDATE niiframosubr
					SET riesgo_sinies  = riesgo_sinies + 1
			      WHERE agno           = _agno
			        AND cod_ramo       = v_cod_ramo
				    AND cod_subramo    = v_cod_subramo;

			  END EXCEPTION
			  INSERT INTO niiframosubr
				  VALUES(_agno,
						 v_cod_ramo,
						 v_cod_subramo,
						 0,
						 _orden,
						 0,
					     0,
					     1
						 );
			END	
		END IF	
			
    ELIF v_cod_ramo in ('001', '003') THEN -- Incendio, Multirriesgo
		FOREACH
			SELECT b.cod_cober_reas
			  INTO _cod_cober_reas
              FROM recrccob a, prdcober b
             WHERE a.cod_cobertura = b.cod_cobertura
			   AND a.no_reclamo = _no_reclamo
            group by 1

			IF _cod_cober_reas IN ('021','022') THEN -- Coberturas Terremoto
				BEGIN
				 ON EXCEPTION IN(-239,-268)
					 UPDATE niiframosubr
						SET riesgo_sinies  = riesgo_sinies + 1
					  WHERE agno           = _agno
						AND cod_ramo       = '998'
						AND cod_subramo    = '001';

				  END EXCEPTION
				  INSERT INTO niiframosubr
					  VALUES(_agno,
							 '998',
							 '001',
							 0,
							 140,
							 0,
							 0,
							 1
							 );
				END		
			ELIF _cod_cober_reas IN ('030','032')	THEN  -- Coberturas Inundación
				BEGIN
				 ON EXCEPTION IN(-239,-268)
					 UPDATE niiframosubr
						SET riesgo_sinies  = riesgo_sinies + 1
					  WHERE agno           = _agno
						AND cod_ramo       = '999'
						AND cod_subramo    = '001';

				  END EXCEPTION
				  INSERT INTO niiframosubr
					  VALUES(_agno,
							 '999',
							 '001',
							 0,
							 150,
							 0,
							 0,
							 1
							 );
				END		
			ELSE
				LET v_cod_ramo = '001';
				LET v_cod_subramo = '001';
				BEGIN
				 ON EXCEPTION IN(-239,-268)
					 UPDATE niiframosubr
						SET riesgo_sinies  = riesgo_sinies + 1
					  WHERE agno           = _agno
						AND cod_ramo       = v_cod_ramo
						AND cod_subramo    = v_cod_subramo;

				  END EXCEPTION
				  INSERT INTO niiframosubr
					  VALUES(_agno,
							 v_cod_ramo,
							 v_cod_subramo,
							 0,
							 50,
							 0,
							 0,
							 1
							 );
				END		
			END IF
		END FOREACH
	END IF	
	

END FOREACH

-- Detalle polizas con siniestros
FOREACH
	SELECT no_reclamo, cod_ramo, cod_subramo, cod_cober_reas, suma_limite, sum(pagado_bruto) 
	  INTO _no_reclamo, v_cod_ramo, v_cod_subramo, _cod_cober_reas, _suma_limite,_monto_pagado
	  FROM tmp_reclamo
	  WHERE periodo >= _periodo_desde
        AND periodo <= _periodo_hasta
	GROUP BY 1, 2, 3, 4, 5
	
	SELECT no_documento,
	       year(fecha_siniestro)
	  INTO _no_documento,
	       _agno_siniestro
	  FROM recrcmae
	 WHERE no_reclamo = _no_reclamo;
        	  

	-- Ramos AP, Salud, RC, Transporte, Robo, Automovil, Soda, Flota, Equipo Elect., Rotura, Calderas, Equipo Pesado, Vidrios
	IF v_cod_ramo in ('004', '018', '006', '009', '005', '002', '020', '023', '010','011','012','022','007') THEN
	    LET v_cod_subramo = '001';
	    IF v_cod_ramo = '004' THEN
			LET _orden = 30;
		ELIF v_cod_ramo = '018' THEN	
			LET _orden = 40;
		ELIF v_cod_ramo IN ('001', '003') THEN	
			LET _orden = 50;
		ELIF v_cod_ramo = '006' THEN	
			LET _orden = 80;
		ELIF v_cod_ramo = '009' THEN	
			LET _orden = 90;
		ELIF v_cod_ramo = '005' THEN	
			LET _orden = 100;
		ELIF v_cod_ramo in ('002', '020', '023') THEN	
		    LET v_cod_ramo = '002';
			LET _orden = 120;
		ELIF v_cod_ramo in ('010','011','012','022','007') THEN	
		    LET v_cod_ramo = '002';
			LET _orden = 130;
		END IF	
		
		BEGIN
		 ON EXCEPTION IN(-239,-268)
			 UPDATE niifpolsini
				SET siniestro_pagado  = siniestro_pagado + _monto_pagado
			  WHERE no_documento   = _no_documento
			    AND suma_limite    = _suma_limite
				AND agno_siniestro = _agno_siniestro;

		  END EXCEPTION
		  INSERT INTO niifpolsini
			  VALUES(_no_documento,
			         v_cod_ramo,
					 v_cod_subramo,
					 _orden,
					 _suma_limite,
					 _agno_siniestro,
					 _monto_pagado,
					 a_agno
					 );
		END	
    ELIF v_cod_ramo in ('016','019','017','008') THEN -- Colectivo, Vida Individual, Casco, Fianza
		IF v_cod_ramo = '016' AND v_cod_subramo = '007' THEN -- Colectivo, subramo Desgravamen
			LET _orden = 11;
			LET v_cod_subramo = '001';
			BEGIN
			 ON EXCEPTION IN(-239,-268)
				 UPDATE niifpolsini
					SET siniestro_pagado  = siniestro_pagado + _monto_pagado
			      WHERE no_documento   = _no_documento
			        AND suma_limite    = _suma_limite
				    AND agno_siniestro = _agno_siniestro;

			  END EXCEPTION
			  INSERT INTO niifpolsini
			  VALUES(_no_documento,
			         v_cod_ramo,
					 v_cod_subramo,
					 _orden,
					 _suma_limite,
					 _agno_siniestro,
					 _monto_pagado,
					 a_agno
					 );
			END	
		END IF	
		IF v_cod_ramo = '019' AND (v_cod_subramo = '005' OR v_cod_subramo = '006') THEN --Vida Individual, subramos Tarifa a Termino, Tarifa a Edad
			LET _orden = 11;
			LET v_cod_ramo = '016';
			LET v_cod_subramo = '001';
			BEGIN
			 ON EXCEPTION IN(-239,-268)
				 UPDATE niifpolsini
					SET siniestro_pagado  = siniestro_pagado + _monto_pagado
			      WHERE no_documento   = _no_documento
			        AND suma_limite    = _suma_limite
				    AND agno_siniestro = _agno_siniestro;

			  END EXCEPTION
			  INSERT INTO niifpolsini
			  VALUES(_no_documento,
			         v_cod_ramo,
					 v_cod_subramo,
					 _orden,
					 _suma_limite,
					 _agno_siniestro,
					 _monto_pagado,
					 a_agno
					 );
			END	
		END IF	
		IF v_cod_ramo = '017' AND (v_cod_subramo = '001' OR v_cod_subramo = '002') THEN -- Casco, subramo Maritimo, Aereo
			IF v_cod_subramo = '001' THEN
				LET _orden = 60;
			ELSE
                LET _orden = 70; 	
            END IF				
			BEGIN
			 ON EXCEPTION IN(-239,-268)
				 UPDATE niifpolsini
					SET siniestro_pagado  = siniestro_pagado + _monto_pagado
			      WHERE no_documento   = _no_documento
			        AND suma_limite    = _suma_limite
				    AND agno_siniestro = _agno_siniestro;

			  END EXCEPTION
			  INSERT INTO niifpolsini
			  VALUES(_no_documento,
			         v_cod_ramo,
					 v_cod_subramo,
					 _orden,
					 _suma_limite,
					 _agno_siniestro,
					 _monto_pagado,
					 a_agno
					 );
			END	
		END IF	
		-- Ramo Fianza, Subramos Cumplimiento de obra, secuestro, exoneración de impuesto y pago
		IF v_cod_ramo = '008' AND (v_cod_subramo = '017' OR v_cod_subramo = '005' OR v_cod_subramo = '008' OR v_cod_subramo = '004') THEN
			IF v_cod_subramo = '017' THEN
				LET _orden = 171;
			ELIF v_cod_subramo = '005' THEN
                LET _orden = 172; 	
			ELSE
                LET _orden = 173; 	
            END IF				
			BEGIN
			 ON EXCEPTION IN(-239,-268)
				 UPDATE niifpolsini
					SET siniestro_pagado  = siniestro_pagado + _monto_pagado
			      WHERE no_documento   = _no_documento
			        AND suma_limite    = _suma_limite
				    AND agno_siniestro = _agno_siniestro;

			  END EXCEPTION
			  INSERT INTO niifpolsini
			  VALUES(_no_documento,
			         v_cod_ramo,
					 v_cod_subramo,
					 _orden,
					 _suma_limite,
					 _agno_siniestro,
					 _monto_pagado,
					 a_agno
					 );
			END	
		END IF	
			
    ELIF v_cod_ramo in ('001', '003') THEN -- Incendio, Multirriesgo
		IF _cod_cober_reas IN ('021','022') THEN -- Coberturas Terremoto
			BEGIN
			 ON EXCEPTION IN(-239,-268)
				 UPDATE niifpolsini
					SET siniestro_pagado  = siniestro_pagado + _monto_pagado
			      WHERE no_documento   = _no_documento
			        AND suma_limite    = _suma_limite
				    AND agno_siniestro = _agno_siniestro;

			  END EXCEPTION
			  INSERT INTO niifpolsini
				  VALUES(_no_documento,
						 '998',
						 '001',
					     _orden,
					     _suma_limite,
					     _agno_siniestro,
					     _monto_pagado,
					     a_agno
						 );
			END		
        ELIF _cod_cober_reas IN ('030','032')	THEN  -- Coberturas Inundación
			BEGIN
			 ON EXCEPTION IN(-239,-268)
				 UPDATE niifpolsini
					SET siniestro_pagado  = siniestro_pagado + _monto_pagado
			      WHERE no_documento   = _no_documento
			        AND suma_limite    = _suma_limite
				    AND agno_siniestro = _agno_siniestro;

			  END EXCEPTION
			  INSERT INTO niifpolsini
				  VALUES(_no_documento,
						 '999',
						 '001',
					     _orden,
					     _suma_limite,
					     _agno_siniestro,
					     _monto_pagado,
					     a_agno
						 );
			END		
		ELSE
		    LET v_cod_ramo = '001';
		    LET v_cod_subramo = '001';
			BEGIN
			 ON EXCEPTION IN(-239,-268)
				 UPDATE niifpolsini
					SET siniestro_pagado  = siniestro_pagado + _monto_pagado
			      WHERE no_documento   = _no_documento
			        AND suma_limite    = _suma_limite
				    AND agno_siniestro = _agno_siniestro;

			  END EXCEPTION
			  INSERT INTO niifpolsini
				  VALUES(_no_documento,
						 v_cod_ramo,
						 v_cod_subramo,
						 50,
					     _suma_limite,
					     _agno_siniestro,
					     _monto_pagado,
					     a_agno
						 );
			END		
		END IF
	END IF	
	

END FOREACH

DROP TABLE tmp_prod;
DROP TABLE tmp_reclamo;
DROP TABLE temp_perfil;

return 0, "Actualizacion exitosa";
end
END PROCEDURE;