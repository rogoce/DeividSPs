--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*--
--*  ACTUALIZACIÓN DE COMPROBANTES
--*  Juan Plata  - ABRIL 2007
--*  Ref. Power Builder

drop procedure sp_sac64arr;
CREATE PROCEDURE sp_sac64arr(v_compania char(3), v_notrx integer, a_usu_act char(8))
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
DEFINE w1_comprobante char(15); -- 29/01/2009 Henry: Nota: subio de 8 a 15
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
DEFINE w_status1      char(1);
DEFINE mensaje_error  char(150);
DEFINE l_codigo       SMALLINT;
DEFINE ls_auxiliar    char(1);
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
DEFINE ls_cuenta       char(12);
DEFINE pdebitos        DECIMAL(15,2);
DEFINE pcreditos       DECIMAL(15,2);
DEFINE psaldo          DECIMAL(15,2);
DEFINE pdebitos2       DECIMAL(15,2);
DEFINE pcreditos2      DECIMAL(15,2);
DEFINE psaldo2         DECIMAL(15,2);
DEFINE pdebitos3       DECIMAL(15,2);
DEFINE pcreditos3      DECIMAL(15,2);
DEFINE psaldo3         DECIMAL(15,2);
DEFINE ls_cuenta3      char(12);
DEFINE ls_auxiliar3    char(5);
DEFINE pdebitos4       DECIMAL(15,2);
DEFINE pcreditos4      DECIMAL(15,2);
DEFINE psaldo4         DECIMAL(15,2);
DEFINE wsldet_periodo  SMALLINT;
DEFINE ws_periodo  		SMALLINT;
DEFINE ws_periodo1  	SMALLINT;
DEFINE wsld1_periodo  	SMALLINT;
DEFINE no_reg_mes       INTEGER;
DEFINE ll_ciclo   		INTEGER;
DEFINE ld_fecha_inicio	date;
DEFINE ld_fecha_final  	date;
DEFINE pant_ano 		INTEGER;
DEFINE pant_mes 		INTEGER;
DEFINE w3_referencia  	char(20);
DEFINE _cantidad 		INTEGER;

define _error			integer;
define _error_isam		integer;
define _error_desc		char(100);

set isolation to dirty read;

--set debug file to "sp_sac64.trc";
--trace on;

begin
on exception set _error, _error_isam, _error_desc
	return _error, "(" || w_status1 || ") -" || _error_desc;
end exception

LET l_codigo = 1;
LET mensaje_error = "No existen registros por actualizar";

CREATE TEMP TABLE tmp_saldo(
indice         SMALLINT,
debitos        DECIMAL(15,2),
creditos       DECIMAL(15,2),
saldo          DECIMAL(15,2)) WITH NO LOG;

FOR J = 1 TO 14
    INSERT INTO tmp_saldo(indice,debitos,creditos,saldo) Values(J,0,0,0);
END FOR

 SELECT par_periodos,par_mesfiscal,par_anofiscal,par_ingreso1,par_ingreso2
   INTO w_periodos,w_par_mesfiscal,w_par_anofiscal,w_par_ingreso1,w_par_ingreso2
   FROM cglparam;

LET mes_fiscal = w_par_mesfiscal;
LET ano_fiscal = w_par_anofiscal;

FOREACH
   SELECT trx1_notrx,trx1_tipo,trx1_comprobante,trx1_fecha,trx1_concepto,trx1_ccosto,
          trx1_descrip,trx1_monto,trx1_moneda,trx1_debito,trx1_credito,trx1_status,
          trx1_origen,trx1_usuario,trx1_fechacap
     INTO w1_notrx,w1_tipo,w1_comprobante,w1_fecha,w1_concepto,w1_ccosto,w1_descrip,
          w1_monto,w1_moneda,w1_debito,w1_credito,w1_status,w1_origen,w1_usuario,
          w1_fechacap
     FROM cgltrx1
    WHERE trx1_notrx  = v_notrx
      AND trx1_status = "I"

    LET l_codigo = 0;
    LET mensaje_error = "Comprobante actualizado satisfactoriamente";

	-- Verifica Concepto de Pago

    SELECT con_status INTO w_status1  FROM cglconcepto
     WHERE con_codigo = w1_concepto;

     IF w_status1 IS NULL THEN
          LET l_codigo = 1;
	  LET mensaje_error = "Concepto "||w1_concepto||
                              " No existe, Compte. "|| w1_comprobante;
          EXIT FOREACH;
     END IF

	-- Verifica Centro de Costo

    select count(*) 
      into _cantidad 
      from sac:cglcentro
     where cen_codigo = w1_ccosto;

     if _cantidad = 0 then

		let l_codigo      = 1;
	  	let mensaje_error = "Centro Costo " || w1_ccosto || " No Existe, Compte. " || w1_comprobante;
        exit foreach;

     end if

     SELECT per_ano, per_mes, per_status,per_inicio,per_final
       INTO wper_ano, wper_mes, wper_status,ld_fecha_inicio ,ld_fecha_final
       FROM cglperiodo
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
        LET pant_ano = wper_ano;
        LET pant_mes = wper_mes;

     END IF

--    IF wper_status = "C" THEN
--        LET l_codigo = 1;
--         LET mensaje_error = "El periodo "|| wper_ano||"-"||
--             wper_mes|| " a mayorizar esta cerrado";
--         EXIT FOREACH ;
--     END IF

   {	IF w_status1 = "N" and w1_origen = "CGL" THEN

	    SELECT count(*) 
	      INTO _cantidad 
	      FROM sac:cglparam
	     WHERE w_par_anofiscal = wper_ano
	       AND w_par_mesfiscal = wper_mes;

			IF _cantidad = 0 THEN
		         LET l_codigo = 1;
		         LET mensaje_error = "El periodo "|| wper_ano||"-"||
		             wper_mes|| " no corresponde al periodo fiscal "|| w_par_anofiscal||"-"||
		             w_par_mesfiscal||" a actualizar. ";
		         EXIT FOREACH ;
		     END IF
     END IF	}

     LET total_db_det = 0;
     LET total_cr_det = 0;

     SELECT SUM(trx2_debito), SUM(trx2_credito)
       INTO total_db_det, total_cr_det
       FROM cgltrx2
      WHERE trx2_notrx = w1_notrx
        AND trx2_cuenta IS NOT NULL;

     IF total_db_det <> total_cr_det THEN
        LET l_codigo = 1;
        LET mensaje_error = "Comp: " || w1_comprobante || " Fecha: " || w1_fecha || " Costo: "  || w1_ccosto || " No Esta En Balance " || total_db_det || " " || total_cr_det;
        EXIT FOREACH ;
     END IF

    FOREACH
       SELECT trx2_notrx,trx2_tipo,trx2_linea,trx2_cuenta,trx2_ccosto,
              trx2_debito,trx2_credito,trx2_actlzdo
         INTO w2_notrx,w2_tipo,w2_linea,w2_cuenta,w2_ccosto,
              w2_debito,w2_credito,w2_actlzdo
         FROM cgltrx2
        WHERE trx2_notrx = w1_notrx
          AND trx2_cuenta IS NOT NULL

       	-----------------------------------------------#
	--  Verifica Integridad de Cuentas del Mayor     #
	-----------------------------------------------#
	 SELECT cta_nivel, cta_tippartida, cta_recibe, cta_histmes,
	        cta_histano, cta_auxiliar, cta_saldoprom, cta_moneda
       INTO wcta_nivel, wcta_tippartida, wcta_recibe, wcta_histmes,
	          wcta_histano, wcta_auxiliar, wcta_saldoprom, wcta_moneda
       FROM cglcuentas
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

		-------------------------------------------------------------------------------
		-- Verificacion por la afectacion de cuentas en el mayor con auxiliar en Deivid
		-------------------------------------------------------------------------------
		
		if w1_origen = "CGL" and v_compania = "001" then
		
			call sp_sac226(w2_cuenta) returning l_codigo, mensaje_error;

			if l_codigo <> 0 then

				if w2_debito <> 0 then
					let psaldo = w2_debito;
				else
					let psaldo = w2_credito;
				end if

				call sp_sac228(w2_cuenta, mensaje_error, w1_origen, w2_notrx, psaldo, w1_fecha, w1_usuario) returning l_codigo, mensaje_error;

			end if

		end if

          -----------------------------------------------#
          --  Actualiza Saldos de Cuentas del Mayor        #
	  -----------------------------------------------#

	   LET nivel1 = wcta_nivel;

          FOR indice = nivel1 TO 1 STEP -1

          SELECT est_posinicial, est_posfinal
            INTO pos1, pos2
	        FROM cglestructura
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
             FROM cglcuentas
            WHERE cta_cuenta = work_cta;

	        IF wcta_nivel IS NULL THEN

			   return 1, "No Existe la Cuenta " || work_cta;

			   {
			   INSERT INTO cglcuentas
					(cta_cuenta, cta_nombre,
					 cta_tipo,cta_subtipo,cta_nivel,
					 cta_tippartida,cta_recibe,cta_histmes,
					 cta_histano,cta_auxiliar, cta_saldoprom,
					 cta_moneda)
			   VALUES (work_cta, "GENERADO POR SIGMA",
				  "1","01",
				  indice, "D","N","S","S","N","N","00");
			   }

	        END IF

		  LET idx = 0;

		  SELECT COUNT(*)
		    INTO idx
		    FROM cglsaldodet
	       WHERE sldet_cuenta  = work_cta
		     AND sldet_ano     = work_ano
		     AND sldet_tipo    = w1_tipo
		     AND sldet_ccosto  = w2_ccosto;

			LET w1_tipo = w1_tipo;
			LET work_cta = work_cta;
            LET w2_ccosto = w2_ccosto;
            LET work_ano = work_ano;


		  IF idx = 0 THEN
			  BEGIN
	            ON EXCEPTION IN(-239, -268)      -- Henry: cglsaldoctrl existe y cglsaldodet no tiene valor => idx = 0 no se va a ejecutar correctamente.
	             END EXCEPTION

			     INSERT INTO cglsaldoctrl
				 VALUES(w1_tipo,work_cta,w2_ccosto, work_ano, 0) ;
			  END

		      FOR J = 1 TO 14
			        INSERT INTO cglsaldodet
			        VALUES(w1_tipo,work_cta,w2_ccosto, work_ano,J, 0, 0, 0);
			  END FOR

		  END IF

                	    LET nvo_ano = work_ano;

			    IF work_cta < w_par_ingreso1 OR
			       work_cta > w_par_ingreso1 THEN
			       LET ll_ciclo = 1  ;
                         WHILE ll_ciclo < 1000
                               LET ll_ciclo = ll_ciclo + 1 ;
				 LET nvo_ano = nvo_ano + 1;
				 IF nvo_ano > ano_fiscal THEN
				    EXIT WHILE;
				 END IF

				   SELECT COUNT(*)
				     INTO idx
                     FROM cglsaldoctrl
				    WHERE cglsaldoctrl.sld_tipo    = w1_tipo
				      AND cglsaldoctrl.sld_cuenta  = work_cta
				      AND cglsaldoctrl.sld_ccosto  = w2_ccosto
				      AND cglsaldoctrl.sld_ano     = nvo_ano;

				 IF idx > 0 THEN
				    UPDATE cglsaldoctrl
				       SET cglsaldoctrl.sld_incioano = cglsaldoctrl.sld_incioano + w2_debito - w2_credito
				    WHERE cglsaldoctrl.sld_tipo    = w1_tipo
				      AND cglsaldoctrl.sld_cuenta  = work_cta
				      AND cglsaldoctrl.sld_ccosto  = w2_ccosto
				      AND cglsaldoctrl.sld_ano     = nvo_ano ;
				 ELSE
				    INSERT INTO cglsaldoctrl
					 VALUES(w1_tipo,   work_cta,
						w2_ccosto, nvo_ano, 0);
				    FOR J = 1 TO 14
					INSERT INTO cglsaldodet
					   VALUES(w1_tipo, work_cta,
						  w2_ccosto, nvo_ano,
						   J, 0, 0, 0) ;
				    END FOR
				 END IF


			       END WHILE
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


			 INSERT INTO cglresumen	(res_noregistro,res_tipo_resumen,res_notrx,res_comprobante,res_fechatrx,res_tipcomp,res_ccosto,res_descripcion,res_moneda,res_cuenta,res_debito,res_credito,res_usuariocap,res_usuarioact,res_fechacap,res_fechaact,res_origen,res_status,res_tabla,subir_bo)
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
					w1_usuario,
					a_usu_act,
					w1_fechacap,
					CURRENT YEAR TO SECOND,
					w1_origen, "C", "  ", 1 ) ;

			  			  UPDATE seguridad:sigman25
                			 SET param_valor    = no_reg_mes
                           WHERE param_comp     = v_compania
                             AND param_apl_id   = "CGL"
                             AND param_apl_vers = "03"
                             AND param_codigo   = "para_resumen";

        		 IF wcta_auxiliar = "S" THEN  --AND w1_concepto <> '021'

                       FOREACH
                          SELECT trx3_notrx,trx3_tipo,trx3_lineatrx2,
                                 trx3_linea,trx3_cuenta,trx3_auxiliar,
                                 trx3_debito,trx3_credito,trx3_actlzdo,trx3_referencia
                            INTO w3_notrx,w3_tipo,w3_lineatrx2,
                                 w3_linea,w3_cuenta,w3_auxiliar,
                                 w3_debito,w3_credito,w3_actlzdo,w3_referencia
                            FROM cgltrx3
                           WHERE trx3_notrx     = w1_notrx
				             AND trx3_tipo      = w1_tipo
				             AND trx3_cuenta    = work_cta
				             AND trx3_lineatrx2 = w2_linea

                               LET idx = 0;

					       SELECT COUNT(*)
					         INTO idx
						     FROM cglsaldoaux1
		                    WHERE sld1_tipo    = w1_tipo
						      AND sld1_cuenta  = work_cta
						      AND sld1_tercero = w3_auxiliar
						      AND sld1_ano     = work_ano;

					       IF idx = 0 THEN
							  INSERT INTO cglsaldoaux
								 VALUES(w1_tipo,work_cta,
									w3_auxiliar,
									work_ano, 0);
							  FOR J = 1 TO 14
							      INSERT INTO cglsaldoaux1
								     VALUES(w1_tipo,
									    work_cta,
									    w3_auxiliar,
									    work_ano, J, 0, 0, 0);
							  END FOR
					       END IF

					       LET J = 1;
					       FOREACH
			                    SELECT sld1_debitos, sld1_creditos,sld1_saldo,
			                           sld1_periodo
							     INTO pdebitos,pcreditos,psaldo,ws_periodo1
							     FROM cglsaldoaux1
							    WHERE sld1_tipo    = w1_tipo
							      AND sld1_cuenta  = work_cta
							      AND sld1_tercero = w3_auxiliar
							      AND sld1_ano     = work_ano
							  ORDER BY sld1_periodo


			                                  UPDATE tmp_saldo
			                                     SET tmp_saldo.debitos  = pdebitos
			                                   WHERE tmp_saldo.indice = J;
			                                    UPDATE tmp_saldo
			                                     SET tmp_saldo.creditos = pcreditos
			                                   WHERE tmp_saldo.indice = J;
			                                  UPDATE tmp_saldo
			                                     SET tmp_saldo.saldo    = psaldo
			                                   WHERE tmp_saldo.indice = J;

							  IF J = 14 THEN
							     EXIT FOREACH;
							  ELSE
							     LET J = J + 1 ;
							  END IF
					      END FOREACH

			       IF ano_fiscal = work_ano THEN

			       ELSE
				    IF ano_fiscal < work_ano THEN

	  		          ELSE
		                   LET nvo_ano = work_ano ;

				       IF work_cta < w_par_ingreso1 OR
					    work_cta > w_par_ingreso2 THEN
				          LET ll_ciclo = 1  ;
                        WHILE ll_ciclo < 1000
                                      LET ll_ciclo = ll_ciclo + 1 ;

					        LET nvo_ano = nvo_ano + 1;
					        IF nvo_ano > ano_fiscal THEN
					           EXIT WHILE;
					        END IF

					        SELECT COUNT(*) INTO idx FROM cglsaldoaux
					         WHERE cglsaldoaux.sld_tipo    = w1_tipo
					           AND cglsaldoaux.sld_cuenta  = work_cta
					           AND cglsaldoaux.sld_tercero = w3_auxiliar
					           AND cglsaldoaux.sld_ano     = nvo_ano ;

					        IF idx >  0 THEN
					           UPDATE cglsaldoaux
						        SET cglsaldoaux.sld_incioano = cglsaldoaux.sld_incioano + w3_debito - w3_credito
					            WHERE cglsaldoaux.sld_tipo    = w1_tipo
					              AND cglsaldoaux.sld_cuenta  = work_cta
					              AND cglsaldoaux.sld_tercero = w3_auxiliar
					              AND cglsaldoaux.sld_ano     = nvo_ano  ;
					        ELSE
					           INSERT INTO cglsaldoaux
						     VALUES(w1_tipo,
							      work_cta,
							      w3_auxiliar,
							      nvo_ano, 0);

					           FOR J = 1 TO 14
						         INSERT INTO cglsaldoaux1
						         VALUES(w1_tipo,
							          work_cta,
							          w3_auxiliar,
							          nvo_ano,
							          J, 0, 0, 0) ;
					           END FOR
					        END IF
					    END WHILE
				       END IF
				    END IF
				 END IF
------------------------------------------------------------------#
--# RUTINA PARA CREAR LA HISTORIA DEL AUXILIAR MOV. POR MOV. EN cglresumen2 #
--#-------------------------------------------------------------------------#
				  IF w3_referencia IS NULL THEN
				     LET w3_referencia = "";
				  END IF

			      INSERT INTO cglresumen1
						( res1_noregistro,
						res1_linea		 ,
						res1_tipo_resumen,
						res1_comprobante ,
						res1_cuenta		 ,
						res1_auxiliar	 ,
						res1_debito		 ,
						res1_credito	 ,
						res1_origen		 ,
						res1_referencia
						)
				     VALUES (no_reg_mes,
					     w3_linea,
					     w1_tipo,
					     w1_comprobante,
					     w2_cuenta,
					     w3_auxiliar,
					     w3_debito,
					     w3_credito,
					     "CGL",
					     w3_referencia );
			   END FOREACH
			END IF
		     END IF


          END FOR
    END FOREACH

    If l_codigo = 0 then
       DELETE FROM cgltrx3 WHERE trx3_notrx = w1_notrx;
       DELETE FROM cgltrx2 WHERE trx2_notrx = w1_notrx;
       DELETE FROM cgltrx1 WHERE trx1_notrx = w1_notrx;
    End If

 END FOREACH

{
    If l_codigo = 0 then
       COMMIT WORK;
    Else
       ROLLBACK WORK;
    End If
}

 -------------------------

 DROP TABLE tmp_saldo;

------- MODIFICA JUAN PLATA

If l_codigo = 0 then

	 FOREACH
      SELECT res_cuenta, SUM(res_debito), SUM(res_credito)
        INTO ls_cuenta,pdebitos,pcreditos
        FROM cglresumen, cglconcepto
       WHERE res_fechatrx BETWEEN ld_fecha_inicio AND ld_fecha_final
         AND res_tipcomp = con_codigo
         AND res_notrx   = v_notrx
      GROUP BY res_cuenta

      IF pdebitos IS NULL THEN
         LET pdebitos = 0;
      END IF
      IF pcreditos IS NULL THEN
         LET pcreditos = 0;
      END IF
      LET pcreditos = pcreditos * -1;

      SELECT cta_nivel INTO  wcta_nivel FROM cglcuentas
       WHERE cta_cuenta = ls_cuenta;

      IF wcta_nivel IS NULL THEN
         CONTINUE FOREACH;
      END IF

      LET nivel1 = wcta_nivel;


      FOR indice = nivel1 TO 1 STEP -1
          SELECT est_posinicial, est_posfinal INTO pos1, pos2
            FROM cglestructura
           WHERE est_nivel = indice;

           LET work_cta = substring(ls_cuenta from 1 for pos2);

  	    SELECT cta_nivel, cta_tippartida, cta_recibe, cta_histmes,
	           cta_histano, cta_auxiliar, cta_saldoprom, cta_moneda
            INTO wcta_nivel, wcta_tippartida, wcta_recibe, wcta_histmes,
	           wcta_histano, wcta_auxiliar, wcta_saldoprom, wcta_moneda
            FROM cglcuentas
           WHERE cta_cuenta = work_cta;


          SELECT sldet_debtop,sldet_cretop,sldet_saldop
            INTO pdebitos2,pcreditos2,psaldo2 FROM cglsaldodet
           WHERE sldet_tipo    = "01"
             AND sldet_cuenta  = work_cta
             AND sldet_ano     = pant_ano
             AND sldet_periodo = pant_mes
             AND sldet_ccosto  = w2_ccosto;	          -- Henry: se modifico ya que existian 2 ccosto 001,002

           LET pdebitos2  = pdebitos2  + pdebitos ;
           LET pcreditos2 = pcreditos2 + pcreditos ;
           LET psaldo2    = psaldo2 + pdebitos + pcreditos ;

           UPDATE cglsaldodet
              SET sldet_debtop  = pdebitos2,
                  sldet_cretop  = pcreditos2,
                  sldet_saldop  = psaldo2
            WHERE sldet_tipo    = "01"
              AND sldet_cuenta  = work_cta
              AND sldet_ano     = pant_ano
              AND sldet_periodo = pant_mes
              AND sldet_ccosto  = w2_ccosto;          -- Henry: ccosto no se tomo en cuenta y es parte de la llave

      END FOR

      SELECT cta_auxiliar
        INTO ls_auxiliar
        FROM cglcuentas
       WHERE cta_cuenta   = ls_cuenta;

       IF ls_auxiliar = "S" THEN  --AND w1_concepto <> '021'
          FOREACH
           SELECT res_cuenta, res1_auxiliar,SUM(res1_debito), SUM(res1_credito)
             INTO ls_cuenta3,ls_auxiliar3,pdebitos3,pcreditos3
             FROM cglresumen, cglresumen1, cglconcepto
            WHERE res_fechatrx BETWEEN ld_fecha_inicio AND ld_fecha_final
              AND res_notrx      = v_notrx
              AND res_tipcomp    = con_codigo
              AND res_cuenta     = ls_cuenta
              AND res_noregistro = res1_noregistro
           GROUP BY res_cuenta, res1_auxiliar

           IF pdebitos3 IS NULL THEN
              LET pdebitos3 = 0;
           END IF
           IF pcreditos3 IS NULL THEN
              LET pcreditos3 = 0;
           END IF
           LET pcreditos3 = pcreditos3 * -1;

           SELECT sld1_debitos,sld1_creditos,sld1_saldo
             INTO pdebitos4,pcreditos4,psaldo4 FROM cglsaldoaux1
            WHERE sld1_tipo    = "01"
              AND sld1_cuenta  = ls_cuenta3
              AND sld1_tercero = ls_auxiliar3
              AND sld1_ano     = pant_ano
              AND sld1_periodo = pant_mes;

            LET pdebitos4  = pdebitos4  + pdebitos3;
            LET pcreditos4 = pcreditos4 + pcreditos3;
            LET psaldo4    = psaldo4    + pdebitos3 + pcreditos3;

           UPDATE cglsaldoaux1
              SET sld1_debitos  = pdebitos4,
                  sld1_creditos = pcreditos4,
                  sld1_saldo    = psaldo4
            WHERE sld1_tipo    = "01"
              AND sld1_cuenta  = ls_cuenta3
              AND sld1_tercero = ls_auxiliar3
              AND sld1_ano     = pant_ano
              AND sld1_periodo = pant_mes;

      END FOREACH

    END IF

	END FOREACH

end if

end

RETURN l_codigo, mensaje_error;
END
-- trace off;
END PROCEDURE
