--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*--
--*  CIERRRE MENSUAL
--*  Juan Plata  - ABRIL 2007
--*  Ref. Power Builder
--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*--
-- 24/04/2012 modifico:henry validacion: periodo 14 no actualice si exista comprobante de cierre.
DROP PROCEDURE sp_sac94;
CREATE PROCEDURE sp_sac94()
RETURNING SMALLINT, CHAR(150);

BEGIN
----
DEFINE wdatabase        char(18);
DEFINE w_periodos       char(2);
DEFINE w_par_mesfiscal  char(2);
DEFINE w_par_anofiscal  char(4);
DEFINE w_par_ingreso1   char(12);
DEFINE w_par_ingreso2   char(12);
DEFINE mes_fiscal       char(2);
DEFINE ano_fiscal       char(4);
DEFINE nvo_ano          char(4);
---Variables de la tabla cgltrx1
DEFINE w1_notrx       integer;
DEFINE w1_tipo        char(2);
DEFINE w1_comprobante char(15);
DEFINE w1_fecha       date;
DEFINE w1_concepto    char(3);
DEFINE w1_ccosto      char(3);
DEFINE w1_descrip     char(50);
DEFINE w1_monto       decimal(15,2);
DEFINE w1_moneda      char(2);
DEFINE w1_debito      decimal(15,2);
DEFINE w1_credito     decimal(15,2);
DEFINE w1_status      char(1);
DEFINE w1_origen      char(3);
DEFINE w1_usuario     char(15);
DEFINE w1_fechacap    datetime year to second;
---Variables de la tabla cgltrx2
DEFINE w2_notrx   integer;
DEFINE w2_tipo    char(2);
DEFINE w2_linea   integer;
DEFINE w2_cuenta  char(12);
DEFINE w2_ccosto  char(3);
DEFINE w2_debito  decimal(15,2);
DEFINE w2_credito decimal(15,2);
DEFINE w2_actlzdo char(1);
---Variables de la tabla cgltrx2
DEFINE w3_notrx integer;
DEFINE w3_tipo char(2);
DEFINE w3_lineatrx2 integer;
DEFINE w3_linea integer;
DEFINE w3_cuenta char(12);
DEFINE w3_auxiliar char(5);
DEFINE w3_debito decimal(15,2);
DEFINE w3_credito decimal(15,2);
DEFINE w3_actlzdo char(1);
---Variables de la tabla cglcuenta
DEFINE wcta_nivel      char(1);
DEFINE wcta_tippartida char(1);
DEFINE wcta_recibe     char(1);
DEFINE wcta_histmes    char(1);
DEFINE wcta_histano    char(1);
DEFINE wcta_auxiliar   char(1);
DEFINE wcta_saldoprom  char(1);
DEFINE wcta_moneda     char(2);

DEFINE ws_sld_tipo char(2);
DEFINE ws_sld_cuenta char(12);
DEFINE ws_sld_ccosto char(3);
DEFINE ws_sld_ano char(4);
DEFINE ws_sld_incioano char(18);

DEFINE ws_sldet_tipo char(2);
DEFINE ws_sldet_cuenta char(12);
DEFINE ws_sldet_ccosto char(3);
DEFINE ws_sldet_ano char(4);
DEFINE ws_sldet_periodo smallint;
DEFINE ws_sldet_debtop decimal(15,2);
DEFINE ws_sldet_cretop decimal(15,2);
DEFINE ws_sldet_saldop decimal(15,2);

--DEFINE ws_sld_tipo char(2);
--DEFINE ws_sld_cuenta char(12);
DEFINE ws_sld_tercero char(5);
--DEFINE ws_sld_ano char(4);
--DEFINE ws_sld_incioano decimal(15,2);


DEFINE ws_sld1_tipo char(2);
DEFINE ws_sld1_cuenta char(12);
DEFINE ws_sld1_tercero char(5);
DEFINE ws_sld1_ano char(4);
DEFINE ws_sld1_periodo smallint;
DEFINE ws_sld1_debitos decimal(15,2);
DEFINE ws_sld1_creditos decimal(15,2);
DEFINE ws_sld1_saldo decimal(15,2);
-------------------------------------
DEFINE w_status1      char(1);
DEFINE mensaje_error  char(150);
DEFINE l_codigo       SMALLINT;
DEFINE ls_auxiliar   char(1);
-- 1 Error
-- 0 Satisfactorio

DEFINE wper_ano        char(4);
DEFINE wper_mes        char(2);
DEFINE wper_status     char(1);
DEFINE pos1            SMALLINT;
DEFINE pos2            SMALLINT;
DEFINE indice          SMALLINT;
DEFINE I               SMALLINT;
DEFINE J               SMALLINT;
DEFINE K               SMALLINT;
DEFINE idx             SMALLINT;
DEFINE nivel1          SMALLINT;
DEFINE work_cta        CHAR(12);
DEFINE work_ano        CHAR(04);
DEFINE total_db_det    DECIMAL(15,2);
DEFINE total_cr_det    DECIMAL(15,2);
DEFINE ls_cuenta       CHAR(12);
DEFINE pdebitos        DECIMAL(15,2);
DEFINE pcreditos       DECIMAL(15,2);
DEFINE psaldo          DECIMAL(15,2);
DEFINE pdebitos2       DECIMAL(15,2);
DEFINE pcreditos2      DECIMAL(15,2);
DEFINE psaldo2         DECIMAL(15,2);
DEFINE pdebitos3       DECIMAL(15,2);
DEFINE pcreditos3      DECIMAL(15,2);
DEFINE psaldo3         DECIMAL(15,2);
DEFINE ls_cuenta3      CHAR(12);
DEFINE ls_auxiliar3    CHAR(5);
DEFINE pdebitos4       DECIMAL(15,2);
DEFINE pcreditos4      DECIMAL(15,2);
DEFINE psaldo4         DECIMAL(15,2);
DEFINE wsldet_periodo  SMALLINT;
DEFINE ws_periodo      SMALLINT;
DEFINE ws_periodo1     SMALLINT;
DEFINE wsld1_periodo   SMALLINT;
DEFINE no_reg_mes      INTEGER;
DEFINE ll_ciclo        INTEGER;
DEFINE ld_fecha_inicio date;
DEFINE ld_fecha_final  date;
DEFINE pant_ano        INTEGER;
DEFINE pant_mes        INTEGER;
DEFINE v_variable      INTEGER;
DEFINE v_var_det       INTEGER;
DEFINE mes             SMALLINT;
DEFINE ano             SMALLINT;
DEFINE ld_saldo        DECIMAL(15,2);
DEFINE mesa            CHAR(02);
DEFINE anoa            CHAR(04);
DEFINE saldo_inicial   DECIMAL (17,2);
DEFINE saldo_inicial_1 DECIMAL (17,2); 
DEFINE _cpt_concepto   CHAR(3);
DEFINE _dt_cierre      DATE;
DEFINE _cnt_cpte       SMALLINT;

--set debug file to "sp_sac94.trc";	--"C:\Informix\SIGMA003\Mayor\data\juan2.txt";

--set debug file to "sp_sac94.trc";
--trace on;

LET _cnt_cpte = 0;
LET l_codigo = 1;
LET mensaje_error = "No existen registros por actualizar";

CREATE TEMP TABLE tmp_saldo(
indice         SMALLINT,
debitos        DECIMAL(15,2) default 0,
creditos       DECIMAL(15,2) default 0,
saldo          DECIMAL(15,2) default 0) WITH NO LOG;

FOR J = 1 TO 14
    INSERT INTO tmp_saldo(indice,debitos,creditos,saldo) Values(J,0,0,0);
END FOR

--trace on;
SELECT par_periodos,
	   par_mesfiscal,
	   par_anofiscal,
	   par_ingreso1,
	   par_ingreso2
  INTO w_periodos,
	   w_par_mesfiscal,
	   w_par_anofiscal,
	   w_par_ingreso1,
	   w_par_ingreso2
  FROM cglparam;

LET mes_fiscal = w_par_mesfiscal;
LET ano_fiscal = w_par_anofiscal;
LET mes        = w_par_mesfiscal;
--    LET ano      = w_par_mesfiscal;

IF w_par_mesfiscal = "14"  THEN

	SELECT con_codigo
	  INTO _cpt_concepto
	  FROM cglconcepto 
	 WHERE con_status = "C";

	SELECT per_final 
	  INTO _dt_cierre
	  FROM cglperiodo  
	 WHERE per_ano     = w_par_anofiscal
	   AND per_mes     = w_par_mesfiscal
	   AND per_status1 = "C";

	SELECT count(*) 
	  INTO _cnt_cpte
	  FROM cgltrx1
	 WHERE trx1_fecha     = _dt_cierre
	   AND trx1_concepto  = _cpt_concepto
	   AND TRIM(UPPER(trx1_comprobante)) = "CIERRE"
	   AND trx1_status    = "I";

	IF  _cnt_cpte <> 0 THEN
		LET l_codigo = 1;
		LET mensaje_error = "NO PROCEDE EL CIERRE DE MES "||w_par_anofiscal ||"-"|| w_par_mesfiscal ||", EXISTE COMPROBANTE DE CIERRE SIN ACTUALIZAR.";
		RETURN l_codigo, mensaje_error;
	END IF
END IF

SELECT per_ano,
	   per_mes,
	   per_status,
	   per_inicio,
	   per_final
  INTO wper_ano,
	   wper_mes,
	   wper_status,
	   ld_fecha_inicio,
	   ld_fecha_final
  FROM cglperiodo
 WHERE per_ano = w_par_anofiscal
   and per_mes = w_par_mesfiscal;

--trace off;	
IF w_par_mesfiscal < w_periodos + 2 THEN
	FOREACH
		SELECT sld_tipo,
			   sld_cuenta,
			   sld_ccosto,
			   sld_ano,
			   sld_incioano
		  INTO ws_sld_tipo,
			   ws_sld_cuenta,
			   ws_sld_ccosto,
			   ws_sld_ano,
			   ws_sld_incioano
		  FROM cglsaldoctrl
		 WHERE sld_ano  = w_par_anofiscal
		 ORDER BY sld_tipo, sld_cuenta

		LET J = 1;

		FOREACH
			SELECT sldet_tipo,
				   sldet_cuenta,
				   sldet_ccosto,
				   sldet_ano,
				   sldet_periodo,
				   sldet_debtop,
				   sldet_cretop,
				   sldet_saldop 
			  INTO ws_sldet_tipo,
				   ws_sldet_cuenta,
				   ws_sldet_ccosto,
				   ws_sldet_ano,
				   ws_sldet_periodo,
				   ws_sldet_debtop,
				   ws_sldet_cretop,
				   ws_sldet_saldop 
			  FROM cglsaldodet	
			 WHERE sldet_tipo   = ws_sld_tipo 
			   AND sldet_cuenta = ws_sld_cuenta 
			   AND sldet_ccosto = ws_sld_ccosto 
			   AND sldet_ano    = ws_sld_ano 
			 ORDER BY sldet_periodo	

			UPDATE tmp_saldo
			   SET tmp_saldo.debitos = ws_sldet_debtop  
			 WHERE tmp_saldo.indice = J;

			UPDATE tmp_saldo
			   SET tmp_saldo.creditos = ws_sldet_cretop
			 WHERE tmp_saldo.indice = J;

			UPDATE tmp_saldo
			   SET tmp_saldo.saldo = ws_sldet_saldop 
			 WHERE tmp_saldo.indice = J;

			LET J = J + 1;

			IF J > 14 THEN
			  EXIT FOREACH;
			END IF		
		END FOREACH	
    
		LET indice = mes + 1;
		LET ld_saldo = 0;

		SELECT tmp_saldo.saldo 
		  INTO ld_saldo 
		  FROM tmp_saldo
		 WHERE tmp_saldo.indice = mes;
	
		IF ld_saldo IS NULL THEN
			LET ld_saldo = 0;
		END IF
	 
		UPDATE tmp_saldo 
		   SET tmp_saldo.saldo = tmp_saldo.debitos  +  tmp_saldo.creditos + ld_saldo
		 WHERE tmp_saldo.indice = indice;
	 
		FOR J = 1 TO 14
			SELECT tmp_saldo.debitos,
				   tmp_saldo.creditos,
				   tmp_saldo.saldo 
			  INTO pdebitos,
				   pcreditos,
				   psaldo 
			  FROM tmp_saldo 
			 WHERE tmp_saldo.indice = J;
		
			UPDATE cglsaldodet
			   SET sldet_debtop = pdebitos,
				   sldet_cretop = pcreditos,
				   sldet_saldop = psaldo
			 WHERE sldet_tipo   = ws_sld_tipo
			   AND sldet_cuenta = ws_sld_cuenta 
			   AND sldet_ccosto = ws_sld_ccosto
			   AND sldet_ano    = ws_sld_ano
			   AND sldet_periodo = J;     
			
			LET l_codigo = 0;
			LET mensaje_error = "Anio/Periodo  "||w_par_anofiscal ||"-"|| w_par_mesfiscal ||" actualizado satisfactoriamente";		   
		END FOR      
	END FOREACH	

	UPDATE tmp_saldo  SET tmp_saldo.debitos  = 0;
	UPDATE tmp_saldo  SET tmp_saldo.creditos = 0;
	UPDATE tmp_saldo  SET tmp_saldo.saldo    = 0;

	FOREACH
		SELECT sld_tipo,
			   sld_cuenta,
			   sld_tercero,
			   sld_ano,
			   sld_incioano
		  INTO ws_sld_tipo,
			   ws_sld_cuenta,
			   ws_sld_tercero,
			   ws_sld_ano,
			   ws_sld_incioano
		  FROM cglsaldoaux
		 WHERE sld_ano = ano_fiscal

		LET J = 1;

		FOREACH
			SELECT sld1_debitos,
				   sld1_creditos,
				   sld1_saldo,
				   sld1_periodo
			  INTO ws_sld1_debitos,
				   ws_sld1_creditos,
				   ws_sld1_saldo,
				   ws_sld1_periodo
			  FROM cglsaldoaux1 
			 WHERE sld1_tipo    = ws_sld_tipo
			   AND sld1_cuenta  = ws_sld_cuenta
			   AND sld1_tercero = ws_sld_tercero
			   AND sld1_ano     = ws_sld_ano
			 ORDER BY sld1_periodo

			UPDATE tmp_saldo  SET tmp_saldo.debitos  = ws_sld1_debitos   WHERE tmp_saldo.indice = J;
			UPDATE tmp_saldo  SET tmp_saldo.creditos = ws_sld1_creditos  WHERE tmp_saldo.indice = J;
			UPDATE tmp_saldo  SET tmp_saldo.saldo    = ws_sld1_saldo     WHERE tmp_saldo.indice = J;

			LET J = J + 1;

			IF J > 14 THEN
			   EXIT FOREACH;
			END IF		 
		END FOREACH

		LET indice = mes + 1;
		LET ld_saldo = 0;
	
		SELECT tmp_saldo.saldo 
		  INTO ld_saldo 
		  FROM tmp_saldo 
		 WHERE tmp_saldo.indice = mes;
	
		IF ld_saldo IS NULL THEN
			LET ld_saldo = 0;
		END IF

		UPDATE tmp_saldo
		   SET tmp_saldo.saldo = tmp_saldo.debitos  +  tmp_saldo.creditos + ld_saldo
		 WHERE tmp_saldo.indice = indice;
	 
		FOR J = 1 TO 14
			SELECT tmp_saldo.debitos,
				   tmp_saldo.creditos,
				   tmp_saldo.saldo 
			  INTO pdebitos,
				   pcreditos,
				   psaldo
			  FROM tmp_saldo 
			 WHERE tmp_saldo.indice = J;
	
			UPDATE cglsaldoaux1
			   SET sld1_debitos  = pdebitos,
				   sld1_creditos = pcreditos,
				   sld1_saldo    = psaldo
			 WHERE sld1_tipo     = ws_sld_tipo
			   AND sld1_cuenta   = ws_sld_cuenta
			   AND sld1_tercero  = ws_sld_tercero
			   AND sld1_ano      = ws_sld_ano
			   AND sld1_periodo  = J;
		END FOR
	END FOREACH	


	IF l_codigo = 0 THEN
		UPDATE cglperiodo
		   SET per_status = "C"
		 WHERE per_ano = ano_fiscal  -- se quito el ;	que tenia en esta linea
		   AND per_mes = mes_fiscal;
		
		LET mes = mes + 1 ;

--	  IF mes > periodos + 2  then   se modifico esto  la variable periodo no esta declarada
		IF mes > w_periodos + 2  then
			LET mes = 1 ;
		END IF

		IF mes < 10 then
			LET mesa = mes;
			LET mesa = "0"||mesa;
		ELSE
			LET mesa = mes; --using "&&";   Se adiciono para validar cuando el mes es < 10. Realizado por Henry solicitado por Demetrio.
		END IF
	  
		UPDATE cglparam  SET par_mesfiscal = mesa;
	END IF
ELSE  
--	trace on;

	LET ano  = ano_fiscal  ;
    LET ano  = ano + 1 ;
    LET anoa = ano; 

    FOREACH
		SELECT sld_tipo,
			   sld_cuenta,
			   sld_ccosto,
			   sld_ano,
			   sld_incioano
		  INTO ws_sld_tipo,
			   ws_sld_cuenta,
			   ws_sld_ccosto,
			   ws_sld_ano,
			   ws_sld_incioano
		  FROM cglsaldoctrl
		 WHERE sld_ano  = w_par_anofiscal

	    LET saldo_inicial = 0;

        IF ws_sld_cuenta >=  w_par_ingreso1 AND ws_sld_cuenta <=  w_par_ingreso2 THEN
           LET saldo_inicial = 0;
        ELSE
			SELECT sldet_saldop
			  INTO saldo_inicial
			  FROM cglsaldodet
			 WHERE sldet_tipo    = ws_sld_tipo
			   AND sldet_cuenta  = ws_sld_cuenta
			   AND sldet_ccosto  = ws_sld_ccosto
			   AND sldet_ano     = w_par_anofiscal
			   AND sldet_periodo = 14;
		END IF		

		SELECT COUNT(*)
		  INTO v_variable
		  FROM cglsaldoctrl
		 WHERE sld_tipo = ws_sld_tipo
		   AND sld_cuenta = ws_sld_cuenta
		   AND sld_ccosto = ws_sld_ccosto
		   AND sld_ano    = anoa;

		if v_variable is null then
		   let v_variable = 0;
		end if

		IF v_variable = 0 THEN
			INSERT INTO cglsaldoctrl
			VALUES(	ws_sld_tipo,
					ws_sld_cuenta,
					ws_sld_ccosto,
					anoa,
					saldo_inicial);

			FOR J = 1 TO 1 
				let v_var_det = 0;

				SELECT COUNT(*)
				  INTO v_var_det
				  FROM cglsaldodet
				 WHERE sldet_tipo = ws_sld_tipo
				   AND sldet_cuenta = ws_sld_cuenta
				   AND sldet_ccosto = ws_sld_ccosto
				   AND sldet_ano    = anoa
				   AND sldet_periodo = J;

				IF v_var_det = 0 THEN
					INSERT INTO cglsaldodet
					VALUES(	ws_sld_tipo,
							ws_sld_cuenta,
							ws_sld_ccosto,
							anoa,
							J,
							0,
							0,
							saldo_inicial);
				ELSE
					LET saldo_inicial_1 = 0;

					IF J = 1 then
						SELECT sldet_saldop
						  INTO saldo_inicial_1
						  FROM cglsaldodet
						 WHERE sldet_tipo    = ws_sld_tipo
						   AND sldet_cuenta  = ws_sld_cuenta
						   AND sldet_ccosto  = ws_sld_ccosto
						   AND sldet_ano     = w_par_anofiscal
						   AND sldet_periodo = 1;
					END IF

					UPDATE cglsaldodet
					   SET sldet_saldop  = sldet_saldop + saldo_inicial_1
					 WHERE sldet_tipo    = ws_sld_tipo
					   AND sldet_cuenta  = ws_sld_cuenta
					   AND sldet_ccosto  = ws_sld_ccosto
					   AND sldet_ano     = anoa
					   AND sldet_periodo = 1;
			    END IF

				LET saldo_inicial   = 0;
				LET saldo_inicial_1 = 0;
                LET l_codigo = 0;
		        LET mensaje_error = "Anio/Periodo  "||w_par_anofiscal ||"-"|| w_par_mesfiscal ||" actualizado satisfactoriamente";
			END FOR
		ELSE
			UPDATE cglsaldoctrl
			   SET sld_incioano  = saldo_inicial
			 WHERE sld_tipo      = ws_sld_tipo
			   AND sld_cuenta    = ws_sld_cuenta
			   AND sld_ccosto    = ws_sld_ccosto
			   AND sld_ano       = anoa;

		      LET saldo_inicial_1 = 0;

			SELECT sldet_saldop
			  INTO saldo_inicial_1
			  FROM cglsaldodet
			 WHERE sldet_tipo    = ws_sld_tipo
			   AND sldet_cuenta  = ws_sld_cuenta
			   AND sldet_ccosto  = ws_sld_ccosto
			   AND sldet_ano     = w_par_anofiscal
			   AND sldet_periodo = 1;

			UPDATE cglsaldodet
			   SET sldet_saldop  = sldet_saldop + saldo_inicial + saldo_inicial_1
			 WHERE sldet_tipo    = ws_sld_tipo
			   AND sldet_cuenta  = ws_sld_cuenta
			   AND sldet_ccosto  = ws_sld_ccosto
			   AND sldet_ano     = anoa
			   AND sldet_periodo = 1;
			
		    LET l_codigo = 0;
			LET saldo_inicial   = 0;
			LET saldo_inicial_1 = 0;
		    LET mensaje_error = "Anio/Periodo  "||w_par_anofiscal ||"-"|| w_par_mesfiscal ||" actualizado satisfactoriamente";
		END IF

	  {	 IF v_variable = 0 THEN
			INSERT INTO cglsaldoctrl
				   VALUES(ws_sld_tipo,
						  ws_sld_cuenta,
						  ws_sld_ccosto, anoa,
						  saldo_inicial);
			FOR J = 1 TO 14

				INSERT INTO cglsaldodet
				   VALUES(ws_sld_tipo,
						  ws_sld_cuenta,
						  ws_sld_ccosto, anoa, J,
						  0, 0, saldo_inicial);

				LET saldo_inicial = 0;
                LET l_codigo = 0;
		        LET mensaje_error = "Anio/Periodo  "||w_par_anofiscal ||"-"|| w_par_mesfiscal ||" actualizado satisfactoriamente";
				
			END FOR

		 ELSE
			UPDATE cglsaldoctrl
			   SET sld_incioano  = saldo_inicial
			 WHERE sld_tipo      = ws_sld_tipo
			   AND sld_cuenta    = ws_sld_cuenta
			   AND sld_ccosto    = ws_sld_ccosto
			   AND sld_ano       = anoa;

			UPDATE cglsaldodet
			   SET sldet_saldop  = sldet_saldop + saldo_inicial
			 WHERE sldet_tipo    = ws_sld_tipo
			   AND sldet_cuenta  = ws_sld_cuenta
			   AND sldet_ccosto  = ws_sld_ccosto
			   AND sldet_ano     = anoa
			   AND sldet_periodo = 1;
			
		    LET l_codigo = 0;
		    LET mensaje_error = "Anio/Periodo  "||w_par_anofiscal ||"-"|| w_par_mesfiscal ||" actualizado satisfactoriamente";

		 END IF	}

	END FOREACH	

	FOREACH
		SELECT sld_tipo,
			   sld_cuenta,
			   sld_tercero,
			   sld_ano,
			   sld_incioano
		  INTO ws_sld_tipo,ws_sld_cuenta,ws_sld_tercero,ws_sld_ano,ws_sld_incioano
		  FROM cglsaldoaux
		 WHERE sld_ano = ano_fiscal

		LET saldo_inicial = 0;

		IF ws_sld_cuenta >= w_par_ingreso1 AND ws_sld_cuenta <= w_par_ingreso2 THEN
		   LET saldo_inicial = 0;
		ELSE
			SELECT nvl(sld1_saldo,0)
			  INTO saldo_inicial 
			  FROM cglsaldoaux1
			 WHERE sld1_tipo    = ws_sld_tipo
			   AND sld1_cuenta  = ws_sld_cuenta
			   AND sld1_tercero = ws_sld_tercero
			   AND sld1_ano     = ws_sld_ano
			   AND sld1_periodo = 14;

			if v_variable is null then
				let v_variable = 0.00;
			end if
		END IF

		SELECT count(*)
		   into v_variable
		   FROM cglsaldoaux
		  WHERE sld_tipo    = ws_sld_tipo
		    AND sld_cuenta  = ws_sld_cuenta
			AND sld_tercero = ws_sld_tercero
			AND sld_ano     = anoa;

		if v_variable is null then
			let v_variable = 0.00;
		end if

        IF v_variable = 0 THEN
			IF saldo_inicial  IS NULL THEN
				LET saldo_inicial  = 0;
		    END IF

			INSERT INTO cglsaldoaux
			VALUES(	ws_sld_tipo,
					ws_sld_cuenta,
					ws_sld_tercero,
					anoa,
					saldo_inicial);
						 -- 14
			FOR J = 1 TO 1
				let v_var_det = 0;

				SELECT COUNT(*)
				  INTO v_var_det
				  FROM cglsaldoaux1
				 WHERE sld1_tipo    = ws_sld_tipo
				   AND sld1_cuenta  = ws_sld_cuenta
				   AND sld1_tercero = ws_sld_tercero
				   AND sld1_ano     = anoa
				   AND sld1_periodo = J ;

				IF v_var_det = 0 THEN
					IF saldo_inicial  IS NULL THEN
				         LET saldo_inicial  = 0;
				    END IF

					INSERT INTO cglsaldoaux1
					VALUES(	ws_sld_tipo,
							ws_sld_cuenta,
							ws_sld_tercero,
							anoa,
							J,
							0,
							0,
							saldo_inicial);
				ELSE
					LET saldo_inicial_1 = 0;

					IF  J = 1 then
						SELECT sld1_saldo
						  INTO saldo_inicial_1
						  FROM cglsaldoaux1
						 WHERE sld1_tipo    = ws_sld_tipo
						   AND sld1_cuenta  = ws_sld_cuenta
						   AND sld1_tercero = ws_sld_tercero
						   AND sld1_ano     = anoa
						   AND sld1_periodo = 1;
					END IF

					UPDATE cglsaldoaux1
					   SET sld1_saldo   = sld1_saldo + saldo_inicial
					 WHERE sld1_tipo    = ws_sld_tipo
					   AND sld1_cuenta  = ws_sld_cuenta
					   AND sld1_tercero = ws_sld_tercero
					   AND sld1_ano     = anoa             
					   AND sld1_periodo = 1;
				END IF
				LET saldo_inicial = 0;
			END FOR
		ELSE
			UPDATE cglsaldoaux
			   SET sld_incioano = saldo_inicial
			 WHERE sld_tipo     = ws_sld_tipo
			   AND sld_cuenta   = ws_sld_cuenta
			   AND sld_tercero  = ws_sld_tercero
			   AND sld_ano      = anoa;             

			LET saldo_inicial_1 = 0;

			SELECT sld1_saldo
			  INTO saldo_inicial_1
			  FROM cglsaldoaux1
             WHERE sld1_tipo    = ws_sld_tipo
			   AND sld1_cuenta  = ws_sld_cuenta
			   AND sld1_tercero = ws_sld_tercero
			   AND sld1_ano     = anoa
			   AND sld1_periodo = 1;

			UPDATE cglsaldoaux1 
			   SET sld1_saldo   = sld1_saldo + saldo_inicial	+ saldo_inicial_1
			 WHERE sld1_tipo    = ws_sld_tipo
			   AND sld1_cuenta  = ws_sld_cuenta
			   AND sld1_tercero = ws_sld_tercero
			   AND sld1_ano     = anoa             
			   AND sld1_periodo = 1;
		END IF
    END FOREACH

	IF l_codigo = 0 THEN
		UPDATE cglparam
		   SET par_anofiscal = anoa,
			   par_mesfiscal = "01";
			  
		UPDATE cglperiodo
		   SET per_status = "C"
		 WHERE per_ano = w_par_anofiscal
		   AND per_mes = w_par_mesfiscal;
	END IF	  
END IF


------FINAL
DROP TABLE tmp_saldo;
RETURN l_codigo, mensaje_error;
--trace off;
END
END PROCEDURE;