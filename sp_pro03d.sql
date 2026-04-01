--------------------------------------------
---  MOVIMIENTO DE UNIDADES DE AUTOMOVIL  ---
---  Amado Perez - Diciembre 2001 - 
---  Ref. Power Builder - d_sp_pro03d
--------------------------------------------

   DROP procedure sp_pro03d;
   CREATE procedure "informix".sp_pro03d(a_cia CHAR(03),a_agencia CHAR(3),a_periodo1 CHAR(7),a_periodo2 CHAR(7),a_codsucursal CHAR(255) DEFAULT "*",a_codramo CHAR(255) DEFAULT "*")

   RETURNING CHAR(3),CHAR(50),CHAR(50),INT,INT,INT,INT,INT,INT,INT,DECIMAL(16,2),DECIMAL(16,2),CHAR(7),
             CHAR(7),CHAR(3),CHAR(50),CHAR(255),CHAR(45),CHAR(10),CHAR(5),CHAR(20),DATE;

    DEFINE v_cod_ramo,v_cod_subramo,v_cod_sucursal  CHAR(3);
    DEFINE v_desc_ramo                              CHAR(50);
    DEFINE v_desc_subramo,v_desc_vehic              CHAR(50);
    DEFINE descr_cia	                            CHAR(45);
    DEFINE unidades2, _cant_unidad                  SMALLINT;
    DEFINE _no_poliza                               CHAR(10);
    DEFINE v_uni_orig, v_uni_renov, v_uni_incluida, v_uni_rehab,
           v_uni_excluida, v_uni_cancelada,v_uni_vencida  INTEGER;
    DEFINE v_prima_suscrita,v_prima_retenida,
           _prima_suscrita,_prima_retenida,v_suma_asegurada   DECIMAL(16,2);
    DEFINE _tipo, _nueva_renov                      CHAR(01);
	DEFINE v_endomov, _cod_tipoveh                  CHAR(3);
	DEFINE _no_endoso, _no_unidad                   CHAR(5);
	DEFINE v_documento                              CHAR(20);
    DEFINE v_filtros                                CHAR(255);
	DEFINE _mes1,  _mes2		                    CHAR(2);
	DEFINE _ano1,  _ano2							CHAR(4);
	DEFINE _vige1, _vige2                           DATE;
	DEFINE _ano_int                                 INTEGER;

    DEFINE _uni_orig, _uni_renov, _uni_incluida, _uni_rehab,
           _uni_excluida, _uni_cancelada, _uni_vencida   SMALLINT;

    CREATE TEMP TABLE temp_perfil1(
              cod_ramo       CHAR(3),
              cod_subramo    CHAR(3),
			  no_poliza      CHAR(10),
			  no_unidad      CHAR(5),
              cod_sucursal   CHAR(3),
			  uni_orig       SMALLINT,
			  uni_renov      SMALLINT,
			  uni_incluida	 SMALLINT,
			  uni_rehab   	 SMALLINT,
			  uni_excluida   SMALLINT,
			  uni_cancelada  SMALLINT,
			  uni_vencida    SMALLINT,
              prima_suscrita DEC(16,2),
              prima_retenida DEC(16,2),
              seleccionado   SMALLINT DEFAULT 1,
              PRIMARY KEY(cod_ramo,cod_subramo,no_poliza,no_unidad)) WITH NO LOG;

	LET	a_codramo = '002;';
	LET v_cod_ramo  = NULL;
    LET v_cod_sucursal = NULL;
    LET v_cod_subramo  = NULL;
    LET v_desc_subramo = NULL;
    LET v_prima_suscrita = 0;
    LET v_prima_retenida = 0;
    LET _prima_suscrita  = 0;
    LET _prima_retenida  = 0;
    LET _tipo     = NULL;

	LET descr_cia = sp_sis01(a_cia);

    CALL sp_pr26(a_cia,a_agencia,a_periodo1,a_periodo2,a_codsucursal,a_codramo) RETURNING v_filtros;
    
    IF a_codsucursal <> "*" THEN
         LET v_filtros = TRIM(v_filtros) ||"Sucursal "||TRIM(a_codsucursal);
         LET _tipo = sp_sis04(a_codsucursal); -- Separa los valores del String
 
         IF _tipo <> "E" THEN -- Incluir los Registros
            UPDATE temp_perfil
               SET seleccionado = 0
             WHERE seleccionado = 1
               AND cod_sucursal NOT IN(SELECT codigo FROM tmp_codigos);
         ELSE
            UPDATE temp_perfil
               SET seleccionado = 0
             WHERE seleccionado = 1
               AND cod_sucursal IN(SELECT codigo FROM tmp_codigos);
         END IF
         DROP TABLE tmp_codigos;
    END IF  
     
    FOREACH WITH HOLD
       SELECT no_poliza,
       		  cod_ramo,
       		  cod_sucursal
         INTO _no_poliza,
         	  v_cod_ramo,
         	  v_cod_sucursal
         FROM tmp_prod
        WHERE seleccionado = 1
		GROUP BY no_poliza, cod_ramo, cod_sucursal

	   SELECT cod_subramo,
	          suma_asegurada
		 INTO v_cod_subramo,
		      v_suma_asegurada
		 FROM emipomae
		WHERE no_poliza = _no_poliza;

		 FOREACH
          SELECT a.no_poliza,
		         a.no_unidad,
                 a.no_endoso, 
                 b.cod_endomov,
                 a.prima_suscrita,
                 a.prima_retenida 
            INTO _no_poliza,
				 _no_unidad,
				 _no_endoso,
                 v_endomov,
				 _prima_suscrita,
				 _prima_retenida
            FROM endeduni a, endedmae b
           WHERE a.no_poliza = b.no_poliza
		     AND a.no_endoso = b.no_endoso
             AND b.no_poliza = _no_poliza
			 AND b.actualizado = 1
			 AND b.cod_endomov IN ('004','011','003')
             AND b.periodo >= a_periodo1
			 AND b.periodo <= a_periodo2

		  LET _uni_orig = 0;
		  LET _uni_renov = 0;
		  LET _uni_incluida = 0;
		  LET _uni_rehab  = 0; 

		  IF v_endomov = '011' AND _no_endoso = '00000' THEN
		     SELECT nueva_renov
			   INTO _nueva_renov
			   FROM emipomae
			  WHERE no_poliza = _no_poliza;
		  END IF

          IF v_endomov = '004' THEN	  --incl.
		  	LET _uni_incluida = 1;
		  ELIF   v_endomov = '011' AND _nueva_renov = 'N' THEN	  --poliza orig.
		  	LET _uni_orig = 1;
		  ELIF   v_endomov = '011' AND _nueva_renov = 'R' THEN	  --poliza Renov.
		  	LET _uni_renov = 1;
		  ELIF   v_endomov = '003' THEN   --rehab.
		  	LET _uni_rehab  = 1; 
		  END IF;

	       BEGIN
	          ON EXCEPTION IN(-239)
	             UPDATE temp_perfil1
	                SET prima_suscrita = prima_suscrita + _prima_suscrita,
	                    prima_retenida = prima_retenida + _prima_retenida,
						uni_orig     = uni_orig + _uni_orig,
						uni_renov    = uni_renov + _uni_renov, 
						uni_incluida = uni_incluida + _uni_incluida,
						uni_rehab    = uni_rehab + _uni_rehab
	              WHERE cod_ramo    = v_cod_ramo
	                AND cod_subramo = v_cod_subramo
					AND no_poliza  = _no_poliza
	                AND no_unidad = _no_unidad;

	          END EXCEPTION
	          INSERT INTO temp_perfil1
	              VALUES(v_cod_ramo,
	                     v_cod_subramo,
						 _no_poliza,
						 _no_unidad,
	                     v_cod_sucursal,
						 _uni_orig,
						 _uni_renov,
	                     _uni_incluida,
	                     _uni_rehab,
						 0,
						 0,
						 0,
						 _prima_suscrita,
						 _prima_retenida,
	                     1);
	       END
		   LET _prima_suscrita = 0;
		   LET _prima_retenida = 0;
		   LET _uni_orig = 0;
		   LET _uni_renov = 0;
		   LET _uni_incluida = 0;
		   LET _uni_rehab  = 0; 
			  
		 END FOREACH

         FOREACH
          SELECT a.no_poliza,
		         a.no_unidad,
                 a.no_endoso, 
                 b.cod_endomov,
                 a.prima_suscrita,
                 a.prima_retenida 
            INTO _no_poliza,
				 _no_unidad,
				 _no_endoso,
                 v_endomov,
				 _prima_suscrita,
				 _prima_retenida
            FROM endeduni a, endedmae b
           WHERE a.no_poliza = b.no_poliza
		     AND a.no_endoso = b.no_endoso
             AND b.no_poliza = _no_poliza
			 AND b.actualizado = 1
			 AND b.cod_endomov IN ('005','002','020')
             AND b.periodo >= a_periodo1
			 AND b.periodo <= a_periodo2

		  LET _uni_excluida = 0;
		  LET _uni_cancelada = 0;

		  IF v_endomov = '005' THEN	  --eliminacion	
		  	LET _uni_excluida = 1;
		  ELIF   v_endomov IN ('002','020')	THEN --cancelacion, cancelacion manual
		  	LET _uni_cancelada = 1;
		  END IF;

	       BEGIN
	          ON EXCEPTION IN(-239)
	             UPDATE temp_perfil1
	                SET prima_suscrita = prima_suscrita + _prima_suscrita,
	                    prima_retenida = prima_retenida + _prima_retenida,
						uni_excluida   = uni_excluida   + _uni_excluida,
						uni_cancelada  = uni_cancelada  + _uni_cancelada
	              WHERE cod_ramo    = v_cod_ramo
	                AND cod_subramo = v_cod_subramo
					AND no_poliza  = _no_poliza
	                AND no_unidad = _no_unidad;

	          END EXCEPTION
	          INSERT INTO temp_perfil1
	              VALUES(v_cod_ramo,
	                     v_cod_subramo,
						 _no_poliza,
						 _no_unidad,
	                     v_cod_sucursal,
						 0,
						 0,
						 0,
						 0,
						 _uni_excluida,
						 _uni_cancelada,
						 0,
	                     _prima_suscrita,
	                     _prima_retenida,
	                     1);
	       END
		   LET _prima_suscrita = 0;
		   LET _prima_retenida = 0;
		   LET _uni_excluida = 0;
		   LET _uni_cancelada = 0;
		 END FOREACH
		  
    END FOREACH

	LET _ano1 = a_periodo1[1,4];
	LET _mes1 = a_periodo1[6,7];
	LET _ano2 = a_periodo2[1,4];
	LET _mes2 = a_periodo2[6,7];
	LET _vige1 = MDY(_mes1,'01',_ano1);
    LET _vige2 = MDY(_mes2,'01',_ano2);
	LET _ano_int = YEAR(_vige2);

	IF 	_mes2 = '02' THEN
	    IF MOD(_ano_int,4) = 0 THEN
	      LET _vige2 = MDY(_mes2,'29',_ano2);
		ELSE
	      LET _vige2 = MDY(_mes2,'28',_ano2);
		END IF
	ELIF _mes2 = '04' OR 
	     _mes2 = '06' OR
	     _mes2 = '09' OR
	     _mes2 = '11' THEN
	     LET _vige2 = MDY(_mes2,'30',_ano2);
	ELSE
	     LET _vige2 = MDY(_mes2,'31',_ano2);
	END IF

    FOREACH
      SELECT no_poliza,
	         cod_subramo
	    INTO _no_poliza,
		     v_cod_subramo
		FROM emipomae
       WHERE vigencia_final >= _vige1
		 AND vigencia_final <= _vige2
		 AND actualizado = 1
		 AND cod_ramo = '002'
		 AND renovada = 0
	     AND fecha_cancelacion is null

	   FOREACH
          SELECT a.no_poliza,
		         a.no_unidad,
                 a.no_endoso, 
                 b.cod_endomov,
                 a.prima_suscrita,
                 a.prima_retenida 
            INTO _no_poliza,
				 _no_unidad,
				 _no_endoso,
                 v_endomov,
				 _prima_suscrita,
				 _prima_retenida
            FROM endeduni a, endedmae b
           WHERE a.no_poliza = b.no_poliza
		     AND a.no_endoso = b.no_endoso
             AND b.no_poliza = _no_poliza
			 AND b.actualizado = 1
			 AND b.vigencia_final <= _vige2

		  LET _uni_vencida = 0;

		  IF v_endomov IN ('011','004','003')  THEN	  --original, inclusion, eliminacion
		  	LET _uni_vencida = 1;
		  ELIF   v_endomov IN ('002','020','005')	THEN --cancelacion, cancelacion manual
		  	LET _uni_vencida = -1;
		  END IF;

	       BEGIN
	          ON EXCEPTION IN(-239)
	             UPDATE temp_perfil1
	                SET prima_suscrita = prima_suscrita + _prima_suscrita,
	                    prima_retenida = prima_retenida + _prima_retenida,
						uni_vencida   = uni_vencida   + _uni_vencida
	              WHERE cod_ramo    = v_cod_ramo
	                AND cod_subramo = v_cod_subramo
					AND no_poliza  = _no_poliza
	                AND no_unidad = _no_unidad;

	          END EXCEPTION
	          INSERT INTO temp_perfil1
	              VALUES(v_cod_ramo,
	                     v_cod_subramo,
						 _no_poliza,
						 _no_unidad,
	                     v_cod_sucursal,
						 0,
						 0,
						 0,
						 0,
						 0,
						 0,
						 _uni_vencida,
	                     _prima_suscrita,
	                     _prima_retenida,
	                     1);
	       END
		   LET _uni_vencida = 0;

	END FOREACH
 END FOREACH
--  Seleccion Final
    FOREACH
       SELECT cod_ramo,
       		  cod_subramo,
			  no_poliza,
			  no_unidad,
			  uni_orig,  
			  uni_renov,   
			  uni_incluida,	
			  uni_rehab,   	
			  uni_excluida, 
			  uni_cancelada,
			  uni_vencida,
       		  prima_suscrita,
              prima_retenida
         INTO v_cod_ramo,
              v_cod_subramo,
			  _no_poliza,
			  _no_unidad,
			  v_uni_orig,  
			  v_uni_renov,   
			  v_uni_incluida,	
			  v_uni_rehab,   	
			  v_uni_excluida, 
			  v_uni_cancelada,
			  v_uni_vencida,
              v_prima_suscrita,
              v_prima_retenida
         FROM temp_perfil1
        WHERE seleccionado = 1
     ORDER BY cod_ramo,cod_subramo,no_poliza,no_unidad 
--		  AND cant_unidades <> 0

       SELECT nombre
         INTO v_desc_ramo
         FROM prdramo
        WHERE cod_ramo = v_cod_ramo;

       SELECT nombre
         INTO v_desc_subramo
         FROM prdsubra
        WHERE cod_ramo    = v_cod_ramo
          AND cod_subramo = v_cod_subramo;

	   LET 	_cod_tipoveh = NULL;


--	   IF _cod_tipoveh NOT IN ('001','002') THEN
--	      CONTINUE FOREACH;
--	   END IF

		  SELECT cod_tipoveh
		    INTO _cod_tipoveh
			FROM emiauto
		   WHERE no_poliza = _no_poliza
			 AND no_unidad = _no_unidad
			 AND cod_tipoveh is not null;

	   IF _cod_tipoveh is null THEN
		   FOREACH
			  SELECT cod_tipoveh
			    INTO _cod_tipoveh
				FROM endmoaut
			   WHERE no_poliza = _no_poliza
				 AND no_unidad = _no_unidad
				 AND cod_tipoveh is not null
			   EXIT FOREACH;
		   END FOREACH
	   END IF


	   IF _cod_tipoveh is null THEN
	   	   LET v_desc_vehic = '';
	   ELSE		   
		   SELECT nombre
		     INTO v_desc_vehic
			 FROM emitiveh
			WHERE cod_tipoveh = _cod_tipoveh;
       END IF

	   SELECT no_documento
		 INTO v_documento
		 FROM emipomae
		WHERE no_poliza = _no_poliza;

       RETURN  v_cod_subramo,v_desc_subramo,v_desc_vehic,v_uni_orig,v_uni_renov,v_uni_incluida,v_uni_rehab,
               v_uni_excluida,v_uni_cancelada,v_uni_vencida,v_prima_suscrita,v_prima_retenida,a_periodo1,
               a_periodo2,v_cod_ramo,v_desc_ramo,v_filtros,descr_cia,_no_poliza,_no_unidad,
               v_documento,_vige2 WITH RESUME;

    END FOREACH

DROP TABLE tmp_prod;
DROP TABLE temp_perfil1;

END PROCEDURE;
