--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*--
--*  ACTUALIZACIÓN DE COMPROBANTES
--*  Juan Plata  - ABRIL 2007
--*  Ref. Power Builder


CREATE PROCEDURE sp_sac64(v_compania char(3), v_notrx integer) 
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
DEFINE w1_comprobante char(8);
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
-------------------------------------
DEFINE w_status1       char(1);
DEFINE mensaje_error   char(150);
DEFINE l_codigo        SMALLINT;
--     1 Error
--     0 Satisfactorio

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
DEFINE pdebitos        DECIMAL(15,2);
DEFINE pcreditos       DECIMAL(15,2);
DEFINE psaldo          DECIMAL(15,2);
DEFINE wsldet_periodo  SMALLINT;
DEFINE wsld1_periodo   SMALLINT;
DEFINE no_reg_mes      INTEGER;

LET l_codigo = 1;
LET mensaje_error = "No existen registros por actualizar";

CREATE TEMP TABLE tmp_saldo(
indice         SMALLINT,
debitos        DECIMAL(15,2),
creditos       DECIMAL(15,2),
saldo          DECIMAL(15,2)) WITH NO LOG;

FOR J = 1 TO 14
	INSERT INTO tmp_saldo Values(J,0,0,0);
END FOR

SELECT cia_bda_codigo 
  INTO wdatabase 
  FROM seguridad:sigman02
 WHERE cia_comp = v_compania;

 LET wdatabase = TRIM(wdatabase);

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
   FROM wdatabase:cglparam;

 LET mes_fiscal = w_par_mesfiscal;
 LET ano_fiscal = w_par_anofiscal;

FOREACH
 SELECT trx1_notrx,trx1_tipo,trx1_comprobante,trx1_fecha,trx1_concepto,trx1_ccosto,
        trx1_descrip,trx1_monto,trx1_moneda,trx1_debito,trx1_credito,trx1_status,
        trx1_origen,trx1_usuario,trx1_fechacap
   INTO w1_notrx,w1_tipo,w1_comprobante,w1_fecha,w1_concepto,w1_ccosto,w1_descrip,
        w1_monto,w1_moneda,w1_debito,w1_credito,w1_status,w1_origen,w1_usuario,
        w1_fechacap
   FROM wdatabase:cgltrx1
  WHERE trx1_notrx  = v_notrx
    AND trx1_status = "I"

    LET l_codigo = 0;
    LET mensaje_error = "Comprobante actualizado satisfactoriamente";

    SELECT con_status INTO w_status1  FROM wdatabase:cglconcepto
     WHERE con_codigo = w1_concepto;

     IF w_status1 IS NULL THEN
          LET l_codigo = 1;
	  LET mensaje_error = "Concepto "||w1_concepto||
                              " No existe, Compte. "|| w1_comprobante;
          EXIT FOREACH;
     END IF

     SELECT per_ano, per_mes, per_status
       INTO wper_ano, wper_mes, wper_status
       FROM wdatabase:cglperiodo
      WHERE w1_fecha BETWEEN per_inicio AND per_final
        AND per_status1 = w_status1;

     IF wper_ano IS NULL THEN
          LET l_codigo = 1;
          LET mensaje_error = "No esta definido periodo para las fecha "||
		     w1_fecha|| " Sts1 "|| w_status1|| " Compte "||
		     w1_comprobante;
          EXIT FOREACH ;
     ELSE
          LET I        = wper_mes;
	  LET work_ano = wper_ano;
     END IF

     IF wper_status = "C" THEN
         LET l_codigo = 1;
         LET mensaje_error = "El periodo "|| wper_ano||"-"||
             wper_mes|| " a mayorizar esta cerrado";
         EXIT FOREACH ;
     END IF

     LET total_db_det = 0;
     LET total_cr_det = 0;

     SELECT SUM(trx2_debito), SUM(trx2_credito)
       INTO total_db_det, total_cr_det
       FROM wdatabase:cgltrx2
      WHERE trx2_notrx = w1_notrx
        AND trx2_cuenta IS NOT NULL;

     IF total_db_det <> total_cr_det THEN
        LET l_codigo = 1;
        LET mensaje_error = "Comprobante "|| w1_comprobante||
                                      " No esta en Balance";
        EXIT FOREACH ;
     END IF

    FOREACH
       SELECT trx2_notrx,trx2_tipo,trx2_linea,trx2_cuenta,trx2_ccosto,
              trx2_debito,trx2_credito,trx2_actlzdo
         INTO w2_notrx,w2_tipo,w2_linea,w2_cuenta,w2_ccosto,
              w2_debito,w2_credito,w2_actlzdo
         FROM wdatabase:cgltrx2
        WHERE trx2_notrx = w1_notrx
          AND trx2_cuenta IS NOT NULL

       	-----------------------------------------------#
	--  Verifica Integridad de Cuentas del Mayor     #
	-----------------------------------------------#

	 SELECT cta_nivel, cta_tippartida, cta_recibe, cta_histmes,
	        cta_histano, cta_auxiliar, cta_saldoprom, cta_moneda
           INTO wcta_nivel, wcta_tippartida, wcta_recibe, wcta_histmes,
	        wcta_histano, wcta_auxiliar, wcta_saldoprom, wcta_moneda
           FROM wdatabase:cglcuentas
          WHERE cta_cuenta = w2_cuenta;

	  IF w2_cuenta IS NULL THEN
	     LET l_codigo = 1;
	     LET mensaje_error = "Compte "|| w1_comprobante||
			 " Cuenta "|| w2_cuenta|| " No existe ";
	     EXIT FOREACH ;
	  END IF

	  IF wcta_recibe  = "N" THEN
	      LET l_codigo = 1;
	      LET mensaje_error = "Compte "|| w1_comprobante||
		          " Cuenta "|| w2_cuenta|| " No recibe movimiento ";
	      EXIT FOREACH ;
	  END IF
          -----------------------------------------------#
          --  Actualiza Saldos de Cuentas del Mayor        #
	  -----------------------------------------------#

	   LET nivel1 = wcta_nivel;

          FOR indice = nivel1 TO 1 STEP -1

              SELECT est_posinicial, est_posfinal INTO pos1, pos2
	        FROM wdatabase:cglestructura
	       WHERE est_nivel = indice;

	       IF pos1 IS NULL THEN
	          LET l_codigo = 1;
	 	  LET mensaje_error = "Para la Cuenta "|| w2_cuenta||
			     " No existe el nivel "|| indice ;
		  EXIT FOR ;
	       END IF

	       LET work_cta = substring(w2_cuenta from 1 for pos2);

	       SELECT cta_nivel, cta_tippartida, cta_recibe, cta_histmes,
	              cta_histano, cta_auxiliar, cta_saldoprom, cta_moneda
                 INTO wcta_nivel, wcta_tippartida, wcta_recibe, wcta_histmes,
	              wcta_histano, wcta_auxiliar, wcta_saldoprom, wcta_moneda
                 FROM wdatabase:cglcuentas
                WHERE cta_cuenta = work_cta;

	        IF wcta_nivel IS NOT NULL THEN
		   INSERT INTO wdatabase:cglcuentas
				(cta_cuenta, cta_nombre,cta_nombreexten,
				 cta_tipo,cta_subtipo,cta_nivel,
				 cta_tippartida,cta_recibe,cta_histmes,
				 cta_histano,cta_auxiliar, cta_saldoprom,
				 cta_moneda)
		   VALUES (work_cta, "GENERADO POR SIGMA",
			  "GENERADO POR SIGMA","1","01",
			  indice, "D","N","S","S","N","N","00");
	        END IF

	        --FOR J = 1 TO 14
		--    LET pdebitos[J]  = 0 ;
		--    LET pcreditos[J] = 0 ;
		--    LET psaldo[J]    = 0 ;
		--END FOR

                UPDATE tmp_saldo SET debitos = 0,creditos = 0,saldo = 0;

		LET idx = 0;

		SELECT COUNT(*) INTO idx FROM wdatabase:cglsaldodet
	         WHERE sldet_cuenta  = work_cta
		   AND sldet_ano     = work_ano
		   AND sldet_tipo    = w1_tipo
		   AND sldet_ccosto  = w2_ccosto;

		IF idx = 0 THEN
		   INSERT INTO wdatabase:cglsaldoctrl
			VALUES(w1_tipo,work_cta,w2_ccosto, work_ano, 0) ;
		    FOR J = 1 TO 14
		        INSERT INTO wdatabase:cglsaldodet
		        VALUES(w1_tipo,work_cta,w2_ccosto, work_ano,J, 0, 0, 0);
		    END FOR
		END IF
		LET J = 1;
		FOREACH
		   SELECT sldet_debtop, sldet_cretop, sldet_saldop
                     INTO pdebitos,pcreditos,psaldo
			   FROM wdatabase:cglsaldodet
			  WHERE sldet_cuenta   = work_cta
			    AND sldet_ano      = work_ano
			    AND sldet_tipo     = w1_tipo
			    AND sldet_ccosto   = w2_ccosto
			 ORDER BY sldet_periodo


                        UPDATE tmp_saldo SET debitos = pdebitos,creditos = pcreditos,saldo = psaldo
                         WHERE indice = J;

			 IF J = 14 THEN
			    EXIT FOREACH  ;
			 ELSE
			    LET J = J + 1;
			 END IF
	        END FOREACH

                --LET pdebitos[I]  =  pdebitos[I]  + w2_debito ;
		--LET pcreditos[I] =  pcreditos[I] - w2_credito ;
		--LET psaldo[I]    =  psaldo[I]    + w2_debito - w2_credito ;

                UPDATE tmp_saldo SET debitos  = debitos  + w2_debito,
                                     creditos = creditos + w2_credito,
                                     saldo    = saldo    + (w2_debito - w2_credito)
                 WHERE indice = I;



		IF ano_fiscal = work_ano THEN
		    IF I < mes_fiscal  THEN
		       FOR J = I+1 TO mes_fiscal
		   	   --LET psaldo[J] = psaldo[J] + w2_debito - w2_credito;
                           UPDATE tmp_saldo SET saldo = saldo  + (w2_debito - w2_credito)
                            WHERE indice = J;
		       END FOR
		    END IF
		    FOR J = 1 TO  14

                        SELECT debitos,creditos,saldo
                          INTO pdebitos,pcreditos,psaldo
                          FROM tmp_saldo
                         WHERE indice = J;

		        UPDATE wdatabase:cglsaldodet
		   	   SET sldet_debtop  = pdebitos,
			       sldet_cretop  = pcreditos,
			       sldet_saldop  = psaldo
			 WHERE sldet_cuenta  = work_cta
			   AND sldet_ano     = work_ano
	  		   AND sldet_ccosto  = w2_ccosto
			   AND sldet_tipo    = w1_tipo
			   AND sldet_periodo = J ;

		    END FOR
		ELSE
			 IF ano_fiscal < work_ano THEN
			    FOR J = 1 TO  14
                                SELECT debitos,creditos,saldo
                                  INTO pdebitos,pcreditos,psaldo
                                  FROM tmp_saldo
                                 WHERE indice = J;

				UPDATE wdatabase:cglsaldodet
				   SET sldet_debtop  = pdebitos,
				       sldet_cretop  = pcreditos,
				       sldet_saldop  = psaldo
				 WHERE sldet_cuenta  = work_cta
				   AND sldet_ano     = work_ano
				   AND sldet_ccosto  = w2_ccosto
				   AND sldet_tipo    = w1_tipo
				   AND sldet_periodo = J;
			    END FOR
			 ELSE
			    FOR J = I+1 TO 14
				 --LET psaldo[J] = psaldo[J]+ w2_debito - w2_credito;
                                 UPDATE tmp_saldo SET saldo = saldo  + (w2_debito - w2_credito)
                                  WHERE indice = J;

			    END FOR

			    FOR J = 1 TO  14
                                SELECT debitos,creditos,saldo
                                  INTO pdebitos,pcreditos,psaldo
                                  FROM tmp_saldo
                                 WHERE indice = J;


				UPDATE wdatabase:cglsaldodet
				   SET sldet_debtop  = pdebitos,
				       sldet_cretop  = pcreditos,
				       sldet_saldop  = psaldo
				 WHERE sldet_cuenta  = work_cta
				   AND sldet_ano     = work_ano
				   AND sldet_ccosto  = w2_ccosto
				   AND sldet_tipo    = w1_tipo
				   AND sldet_periodo = J;
			    END FOR

                   	    LET nvo_ano = work_ano;

			    IF work_cta < w_par_ingreso1 OR
			       work_cta > w_par_ingreso1 THEN
			       WHILE nvo_ano <= ano_fiscal
				 LET nvo_ano = nvo_ano + 1;
				 IF nvo_ano > ano_fiscal THEN
				    EXIT WHILE;
				 END IF

				   SELECT COUNT(*) INTO idx
                                     FROM wdatabase:cglsaldoctrl
				    WHERE sld_tipo    = w1_tipo
				      AND sld_cuenta  = work_cta
				      AND sld_ccosto  = w2_ccosto
				      AND sld_ano     = nvo_ano;

				 IF idx > 0 THEN
				    UPDATE wdatabase:cglsaldoctrl
				       SET sld_incioano = sld_incioano
							+ w2_debito
							- w2_credito
				    WHERE sld_tipo    = w1_tipo
				      AND sld_cuenta  = work_cta
				      AND sld_ccosto  = w2_ccosto
				      AND sld_ano     = nvo_ano ;
				 ELSE
				    INSERT INTO wdatabase:cglsaldoctrl
					 VALUES(w1_tipo,   work_cta,
						w2_ccosto, nvo_ano, 0);
				    FOR J = 1 TO 14
					INSERT INTO wdatabase:cglsaldodet
					   VALUES(w1_tipo, work_cta,
						  w2_ccosto, nvo_ano,
						   J, 0, 0, 0) ;
				    END FOR
				 END IF

                                 FOREACH
				    SELECT sldet_periodo INTO wsldet_periodo
                                     FROM wdatabase:cglsaldodet
				       WHERE sldet_cuenta   = work_cta
					 AND sldet_ano      = nvo_ano
					 AND sldet_tipo     = w1_tipo
					 AND sldet_ccosto   = w2_ccosto
				    ORDER BY sldet_periodo


				    IF nvo_ano = ano_fiscal THEN
				       IF wsldet_periodo <=
					  mes_fiscal THEN
					  UPDATE wdatabase:cglsaldodet
					     SET sldet_saldop  = sldet_saldop
						+ w2_debito
						- w2_credito
					   WHERE sldet_cuenta  = work_cta
					     AND sldet_ano     = nvo_ano
					     AND sldet_ccosto  = w2_ccosto
					     AND sldet_tipo    = w1_tipo
					     AND sldet_periodo = wsldet_periodo;

				       END IF
				    ELSE
				       UPDATE wdatabase:cglsaldodet
					  SET sldet_saldop  = sldet_saldop
					      + w2_debito
					      - w2_credito
					WHERE sldet_cuenta  = work_cta
					  AND sldet_ano     = nvo_ano
					  AND sldet_ccosto  = w2_ccosto
					  AND sldet_tipo    = w1_tipo
					  AND sldet_periodo = wsldet_periodo;
				    END IF
				 END FOREACH
			       END WHILE
			    END IF
			 END IF
		      END IF
  		      IF nivel1 = indice THEN
  		          SELECT param_valor INTO no_reg_mes
                            FROM seguridad:sigman25
                           WHERE param_comp     = v_compania
                             AND param_apl_id   = "CGL"
                             AND param_apl_vers = "03"
                             AND param_codigo   = "para_resumen";

                           IF no_reg_mes IS NULL OR
                              no_reg_mes = " " THEN
                              LET no_reg_mes = 1;
                           END IF


			 LET no_reg_mes = no_reg_mes + 1;
			 INSERT INTO wdatabase:cglresumen
				VALUES (no_reg_mes,
					w1_tipo,
					w2_notrx,
					w1_comprobante,
					w1_fecha,
					w1_concepto,
					w2_ccosto,
					w1_descrip,
					w1_moneda,
					w2_cuenta,
					w2_debito,
					w2_credito,
					"informix",
					"informix",
					CURRENT YEAR TO SECOND,
					CURRENT YEAR TO SECOND,
					w1_origen, "C", "  " ) ;

			  UPDATE seguridad:sigman25
                             SET param_valor    = no_reg_mes
                           WHERE param_comp     = v_compania
                             AND param_apl_id   = "CGL"
                             AND param_apl_vers = "03"
                             AND param_codigo   = "para_resumen";

        		 IF wcta_auxiliar = "S" THEN


			    FOREACH
                               SELECT trx3_notrx,trx3_tipo,trx3_lineatrx2,
                                trx3_linea,trx3_cuenta,trx3_auxiliar,
                                trx3_debito,trx3_credito,trx3_actlzdo
                                INTO w3_notrx,w3_tipo,w3_lineatrx2,
                                w3_linea,w3_cuenta,w3_auxiliar,
                                w3_debito,w3_credito,w3_actlzdo
                                FROM  wdatabase:cgltrx3
                               	WHERE trx3_notrx     = w1_notrx
				  AND trx3_tipo      = w1_tipo
				  AND trx3_cuenta    = work_cta
				  AND trx3_lineatrx2 = w2_linea


			       --FOR J = 1 TO 14
			       --  LET pdebitos[J]  = 0 ;
			       --  LET pcreditos[J] = 0 ;
			       --  LET psaldo[J]    = 0 ;
			       --END FOR
                               UPDATE tmp_saldo SET debitos = 0,creditos = 0,saldo = 0;

                               LET idx = 0;

			       SELECT COUNT(*) INTO idx
				 FROM wdatabase:cglsaldoaux1
                                WHERE sld1_tipo    = w1_tipo
				  AND sld1_cuenta  = work_cta
				  AND sld1_tercero = w3_auxiliar
				  AND sld1_ano     = work_ano ;

			       IF idx = 0 THEN
				  INSERT INTO wdatabase:cglsaldoaux
					 VALUES(w1_tipo,work_cta,
						w3_auxiliar,
						work_ano, 0);
				  FOR J = 1 TO 14
				      INSERT INTO wdatabase:cglsaldoaux1
					     VALUES(w1_tipo,
						    work_cta,
						    w3_auxiliar,
						    work_ano, J, 0, 0, 0);
				  END FOR
			       END IF

			       LET J = 1;
			       FOREACH
                                   SELECT sld1_debitos, sld1_creditos,sld1_saldo
				     INTO pdebitos,pcreditos,psaldo
				     FROM wdatabase:cglsaldoaux1
				    WHERE sld1_tipo    = w1_tipo
				      AND sld1_cuenta  = work_cta
				      AND sld1_tercero = w3_auxiliar
				      AND sld1_ano     = work_ano
				  ORDER BY sld1_periodo

                                  UPDATE tmp_saldo SET debitos = pdebitos,creditos = pcreditos,saldo = psaldo
                                   WHERE indice = J;

				  IF J = 14 THEN
				     EXIT FOREACH;
				  ELSE
				     LET J = J + 1 ;
				  END IF
			      END FOREACH

			       --LET pdebitos[I]  =  pdebitos[I]  + w3_debito ;
			       --LET pcreditos[I] =  pcreditos[I] - w3_credito ;
			       --LET psaldo[I]    =  psaldo[I]    + w3_debito - w3_credito;

                               UPDATE tmp_saldo SET debitos  = debitos  + w3_debito,
                                                    creditos = creditos + w3_credito,
                                                    saldo    = saldo    + (w3_debito - w3_credito)
                                WHERE indice = I;

			       IF ano_fiscal = work_ano THEN
				  IF I < mes_fiscal  THEN
				     FOR J = I+1 TO mes_fiscal
					 --LET psaldo[J] = psaldo[J] + w3_debito - w3_credito ;
                                         UPDATE tmp_saldo SET saldo = saldo  + (w3_debito - w3_credito)
                                          WHERE indice = J;
				     END FOR
				  END IF
				  FOR J = 1 TO  14
                                      SELECT debitos,creditos,saldo
                                        INTO pdebitos,pcreditos,psaldo
                                        FROM tmp_saldo
                                       WHERE indice = J;

				      UPDATE wdatabase:cglsaldoaux1
					 SET sld1_debitos  = pdebitos,
					     sld1_creditos = pcreditos,
					     sld1_saldo    = psaldo
				       WHERE sld1_tipo     = w1_tipo
					 AND sld1_cuenta   = work_cta
					 AND sld1_tercero  = w3_auxiliar
					 AND sld1_ano      = work_ano
					 AND sld1_periodo  = J ;
				  END FOR
			       ELSE
				  IF ano_fiscal < work_ano THEN
				     FOR J = 1 TO  14
                                         SELECT debitos,creditos,saldo
                                           INTO pdebitos,pcreditos,psaldo
                                           FROM tmp_saldo
                                          WHERE indice = J;

					 UPDATE wdatabase:cglsaldoaux1
					    SET sld1_debitos = pdebitos,
						sld1_creditos = pcreditos,
						sld1_saldo    = psaldo
					  WHERE sld1_tipo     = w1_tipo
					    AND sld1_cuenta   = work_cta
					    AND sld1_tercero  = w3_auxiliar
					    AND sld1_ano      = work_ano
					    AND sld1_periodo  = J;
				       END FOR
				    ELSE
				       FOR J = I+1 TO 14
					   --LET psaldo[J] = psaldo[J]+ w3_debito - w3_credito ;
                                           UPDATE tmp_saldo SET saldo = saldo  + (w3_debito - w3_credito)
                                            WHERE indice = J;
				       END FOR
				       FOR J = 1 TO  14
                                          SELECT debitos,creditos,saldo
                                            INTO pdebitos,pcreditos,psaldo
                                            FROM tmp_saldo
                                           WHERE indice = J;


					   UPDATE wdatabase:cglsaldoaux1
					      SET sld1_debitos  = pdebitos,
						  sld1_creditos = pcreditos,
						  sld1_saldo    = psaldo
					    WHERE sld1_tipo     = w1_tipo
					      AND sld1_cuenta   = work_cta
					      AND sld1_tercero  = w3_auxiliar
					      AND sld1_ano      = work_ano
					      AND sld1_periodo  = J;
				       END FOR

                        	       LET nvo_ano = work_ano ;

				       IF work_cta < w_par_ingreso1 OR
					  work_cta > w_par_ingreso2 THEN
				       WHILE nvo_ano <= ano_fiscal 
					  LET nvo_ano = nvo_ano + 1;
					  IF nvo_ano > ano_fiscal THEN
					     EXIT WHILE;
					  END IF

					  SELECT COUNT(*) INTO idx 
                                              FROM wdatabase:cglsaldoaux
					     WHERE sld_tipo    = w1_tipo
					       AND sld_cuenta  = work_cta
					       AND sld_tercero = w3_auxiliar
					       AND sld_ano     = nvo_ano ;

					  IF idx >  0 THEN
					     UPDATE wdatabase:cglsaldoaux
						SET sld_incioano = sld_incioano
							+ w3_debito
							- w3_credito
					     WHERE sld_tipo    = w1_tipo
					       AND sld_cuenta  = work_cta
					       AND sld_tercero = w3_auxiliar
					       AND sld_ano     = nvo_ano  ;
					  ELSE
					     INSERT INTO wdatabase:cglsaldoaux
						  VALUES(w1_tipo,
							 work_cta,
							 w3_auxiliar,
							 nvo_ano, 0);
					     FOR J = 1 TO 14
						 INSERT INTO wdatabase:cglsaldoaux1
						    VALUES(w1_tipo,
							   work_cta,
							   w3_auxiliar,
							   nvo_ano,
							   J, 0, 0, 0) ;
					     END FOR
					  END IF


					  FOREACH
					    SELECT sld1_periodo INTO wsld1_periodo FROM wdatabase:cglsaldoaux1
					     WHERE sld1_cuenta  = work_cta
					       AND sld1_ano     = nvo_ano
					       AND sld1_tipo    = w1_tipo
					       AND sld1_tercero = w3_auxiliar
					     ORDER BY sld1_periodo

					     IF nvo_ano = ano_fiscal THEN
						IF wsld1_periodo <= mes_fiscal THEN
						   UPDATE wdatabase:cglsaldoaux1
						      SET sld1_saldo =
							  sld1_saldo
							 + w3_debito
							 - w3_credito
						    WHERE sld1_cuenta  = work_cta
						      AND sld1_ano     = nvo_ano
						      AND sld1_tercero = w3_auxiliar
						      AND sld1_tipo    = w1_tipo
						      AND sld1_periodo = wsld1_periodo;
						END IF
					     ELSE
						UPDATE wdatabase:cglsaldoaux1
						   SET sld1_saldo  =
						       sld1_saldo
						       + w3_debito
						       - w3_credito
						 WHERE sld1_cuenta  = work_cta
						   AND sld1_ano     = nvo_ano
						   AND sld1_tercero = w3_auxiliar
						   AND sld1_tipo    = w1_tipo
						   AND sld1_periodo = wsld1_periodo;

					     END IF
					  END FOREACH
				       END WHILE
				       END IF
				    END IF
				 END IF
------------------------------------------------------------------#
--# RUTINA PARA CREAR LA HISTORIA DEL AUXILIAR MOV. POR MOV. EN cglresumen2 #
--#-------------------------------------------------------------------------#
			      INSERT INTO wdatabase:cglresumen1
				     VALUES (no_reg_mes,
					     w3_linea,
					     w1_tipo,
					     w1_comprobante,
					     w2_cuenta,
					     w3_auxiliar,
					     w3_debito,
					     w3_credito,
					     "CGL" );
			   END FOREACH
			END IF
		     END IF


          END FOR
    END FOREACH

    If l_codigo = 0 then
       DELETE FROM wdatabase:cgltrx3 WHERE trx3_notrx = w1_notrx;
       DELETE FROM wdatabase:cgltrx2 WHERE trx2_notrx = w1_notrx;
       DELETE FROM wdatabase:cgltrx1 WHERE trx1_notrx = w1_notrx;
    End If

 END FOREACH

DROP TABLE tmp_saldo;

RETURN l_codigo, mensaje_error WITH RESUME;

END

END PROCEDURE;
