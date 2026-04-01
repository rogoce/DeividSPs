--------------------------------------------
---  PERFIL DE CARTERA - RAMOS AUTOMOVIL   ---
---            POLIZAS VIGENTES          ---
---  Amado Perez - Diciembre 2001 - 
---  Ref. Power Builder - d_sp_pro03c
--------------------------------------------

   DROP procedure sp_pro03c;
   CREATE procedure "informix".sp_pro03c(a_cia CHAR(03),a_agencia CHAR(3),a_periodo DATE,a_codsucursal CHAR(255) DEFAULT "*",a_codramo CHAR(255) DEFAULT "*")

   RETURNING CHAR(3),CHAR(50),CHAR(50),INT,INT,DECIMAL(16,2),DECIMAL(16,2),DATE,
             CHAR(3),CHAR(50),CHAR(255),CHAR(45),CHAR(10),CHAR(5),CHAR(20);

    DEFINE v_cod_ramo,v_cod_subramo,v_cod_sucursal  CHAR(3);
    DEFINE v_desc_ramo        CHAR(50);
    DEFINE v_desc_subramo,v_desc_vehic     CHAR(50);
    DEFINE descr_cia	      CHAR(45);
    DEFINE unidades2, _cant_unidad  SMALLINT;
    DEFINE _no_poliza         CHAR(10);
    DEFINE v_cant_polizas, v_cant_unidades     INTEGER;
    DEFINE v_prima_suscrita,v_prima_retenida,
           _prima_suscrita,_prima_retenida,v_suma_asegurada   DECIMAL(16,2);
    DEFINE _tipo              CHAR(01);
	DEFINE v_endomov, _cod_tipoveh  CHAR(3);
	DEFINE _no_endoso, _no_unidad  CHAR(5);
	DEFINE v_documento        CHAR(20);
    DEFINE v_filtros          CHAR(255);

    CREATE TEMP TABLE temp_perfil1(
              cod_ramo       CHAR(3),
              cod_subramo    CHAR(3),
			  no_poliza      CHAR(10),
			  no_unidad      CHAR(5),
              cod_sucursal   CHAR(3),
              cant_polizas   SMALLINT,
			  cant_unidades  SMALLINT,
              prima_suscrita DEC(16,2),
              prima_retenida DEC(16,2),
              seleccionado   SMALLINT DEFAULT 1,
              PRIMARY KEY(cod_ramo,cod_subramo,no_poliza,no_unidad)) WITH NO LOG;

	LET a_codramo = '002;';
    LET v_cod_ramo  = NULL;
    LET v_cod_sucursal = NULL;
    LET v_cod_subramo  = NULL;
    LET v_desc_subramo = NULL;
    LET v_cant_polizas = 0;
    LET v_prima_suscrita = 0;
    LET v_prima_retenida = 0;
    LET _prima_suscrita = 0;
    LET _prima_retenida = 0;
    LET _tipo     = NULL;

	LET descr_cia = sp_sis01(a_cia);

    CALL sp_pro831(a_cia,a_agencia,a_periodo,a_codramo) RETURNING v_filtros;
    
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
       		  cod_subramo,
       		  cod_sucursal,
              suma_asegurada
         INTO _no_poliza,
         	  v_cod_ramo,
         	  v_cod_subramo,
         	  v_cod_sucursal,
              v_suma_asegurada
         FROM temp_perfil
        WHERE seleccionado = 1


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
             AND (b.vigencia_final >= a_periodo
			  OR b.vigencia_final IS NULL)
             AND b.vigencia_inic < a_periodo
			 AND b.cod_endomov IN ('004','011','003')
             AND b.fecha_emision <= a_periodo

		     LET _cant_unidad = 1;


{          IF v_endomov = '004' OR	  --incl.
		     v_endomov = '011' OR	  --poliza orig.
		     v_endomov = '003' THEN   --rehab.
		     LET _cant_unidad =  1;
		  END IF;
		  IF v_endomov = '005' OR	  --eliminacion	
		     v_endomov = '002' OR	  --cancelacion
		     v_endomov = '020' THEN   --cancelacion manual
		     LET _cant_unidad =  -1;
		  END IF;}

	       BEGIN
	          ON EXCEPTION IN(-239)
	             UPDATE temp_perfil1
	                SET prima_suscrita = prima_suscrita + _prima_suscrita,
	                    prima_retenida = prima_retenida + _prima_retenida,
	                    cant_polizas   = cant_polizas + 1,
						cant_unidades  = cant_unidades + _cant_unidad
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
	                     1,
						 _cant_unidad,
	                     _prima_suscrita,
	                     _prima_retenida,
	                     1);
	       END
		   LET _prima_suscrita = 0;
		   LET _prima_retenida = 0;
			  
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
             AND b.vigencia_inic <= a_periodo
			 AND b.cod_endomov IN ('005','002','020')
             AND b.fecha_emision <= a_periodo

		     LET _cant_unidad = -1;

	       BEGIN
	          ON EXCEPTION IN(-239)
	             UPDATE temp_perfil1
	                SET prima_suscrita = prima_suscrita + _prima_suscrita,
	                    prima_retenida = prima_retenida + _prima_retenida,
	                    cant_polizas   = cant_polizas + 1,
						cant_unidades  = cant_unidades + _cant_unidad
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
	                     1,
						 _cant_unidad,
	                     _prima_suscrita,
	                     _prima_retenida,
	                     1);
	       END
		   LET _prima_suscrita = 0;
		   LET _prima_retenida = 0;

		 END FOREACH
		  
    END FOREACH
--  Seleccion Final
    FOREACH
       SELECT cod_ramo,
       		  cod_subramo,
			  no_poliza,
			  no_unidad,
       		  cant_polizas,
			  cant_unidades,
       		  prima_suscrita,
              prima_retenida
         INTO v_cod_ramo,
              v_cod_subramo,
			  _no_poliza,
			  _no_unidad,
              v_cant_polizas,
			  v_cant_unidades,
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

       RETURN  v_cod_subramo,v_desc_subramo,v_desc_vehic,v_cant_polizas,v_cant_unidades,
               v_prima_suscrita,v_prima_retenida,a_periodo,
               v_cod_ramo,v_desc_ramo,v_filtros,descr_cia,_no_poliza,_no_unidad,v_documento WITH RESUME;

    END FOREACH

DROP TABLE temp_perfil;
DROP TABLE temp_perfil1;

END PROCEDURE;
