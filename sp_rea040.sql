-- Sacar informacion para un contrato dado

-- SIS v.2.0 - DEIVID, S.A.
-- Creado    : 09/07/2012 - Autor: Armando Moreno

--execute procedure sp_rea040('001','001','2012-04','2012-06','*','*','*','*','*','*','1','00613')


DROP procedure sp_rea040;

CREATE procedure "informix".sp_rea040(
a_compania     CHAR(03),
a_agencia      CHAR(03),
a_periodo1     CHAR(07),
a_periodo2     CHAR(07),
a_codsucursal  CHAR(255) DEFAULT "*",
a_codgrupo     CHAR(255) DEFAULT "*",
a_codagente    CHAR(255) DEFAULT "*",
a_codusuario   CHAR(255) DEFAULT "*",
a_codramo      CHAR(255) DEFAULT "*",
a_reaseguro    CHAR(255) DEFAULT "*",
a_tipopol      CHAR(1)   DEFAULT "1",
a_cod_contrato CHAR(5)
) RETURNING    CHAR(255);

      DEFINE v_nopoliza,v_nofactura          CHAR(10);
      DEFINE v_nodocumento                   CHAR(20);
      DEFINE v_noendoso                      CHAR(5);
      DEFINE s_cia,v_cod_sucursal,v_cod_ramo,v_cod_tipoprod,v_cod_subramo CHAR(03);
      DEFINE v_cod_agente,v_cod_grupo        CHAR(5);
      DEFINE v_cod_usuario                   CHAR(8);
      DEFINE v_porc_comis,_porc_partic_agt   DEC(5,2);
      DEFINE v_cod_contratante               CHAR(10);
      DEFINE v_prima_suscrita,v_prima_neta,v_suma_asegurada,_tot_prima_sus   DECIMAL(16,2);
      DEFINE v_comision                      DECIMAL(9,2);
      DEFINE v_desc_nombre                   CHAR(35);
      DEFINE v_desc_grupo                    CHAR(50);
      DEFINE v_filtros                       CHAR(255);
      DEFINE _tipo                           CHAR(01);
      DEFINE v_estatus                       SMALLINT;
      DEFINE v_forma_pago                    CHAR(3);
      DEFINE v_cant_pagos                    SMALLINT;
      DEFINE v_descr_cia                     CHAR(50);
      DEFINE s_tipopro                       CHAR(03);
      DEFINE _tipo_produccion                CHAR(01);
	  DEFINE v_vigencia_inic                 DATE;
	  DEFINE _nueva_renov                    CHAR(1);
	  DEFINE _reemplaza_poliza				 CHAR(20);
	  define _cantidad						 smallint;
	  define _no_remesa                      char(10);

SET ISOLATION TO DIRTY READ;

CREATE TEMP TABLE temp_rea
               (cod_sucursal     CHAR(3),
                cod_grupo        CHAR(5),
                cod_agente       CHAR(5),
                cod_usuario      CHAR(8),
                cod_ramo         CHAR(3),
				cod_subramo      CHAR(3),
                cod_tipoprod     CHAR(3),
				tipo_produccion  CHAR(01),
                no_poliza        CHAR(10),
                no_endoso        CHAR(5),
                no_factura       CHAR(10),
                no_documento     CHAR(20),
                cod_contratante  CHAR(10),
                estatus          SMALLINT,
                forma_pago       CHAR(03),
                cant_pagos       SMALLINT,
                suma_asegurada   DEC(16,2),
                prima            DEC(16,2),
				prima_neta       DEC(16,2),
                comision         DEC(9,2),
				vigencia_inic    DATE,
				nueva_renov		 CHAR(1),
				prima_sus_tot    DEC(16,2),
				no_remesa        char(10),
                seleccionado     SMALLINT DEFAULT 1) WITH NO LOG;

      CREATE INDEX id1_temp_rea ON temp_rea(cod_sucursal);
      CREATE INDEX id2_temp_rea ON temp_rea(cod_grupo);
      CREATE INDEX id3_temp_rea ON temp_rea(cod_agente);
      CREATE INDEX id4_temp_rea ON temp_rea(cod_usuario);
      CREATE INDEX id5_temp_rea ON temp_rea(cod_ramo);
      CREATE INDEX id6_temp_rea ON temp_rea(cod_tipoprod);
	  CREATE INDEX id7_temp_rea ON temp_rea(cod_contratante);

      LET s_tipopro         = NULL;
      LET v_prima_suscrita  = 0;
      LET v_suma_asegurada  = 0;
      LET v_cant_pagos      = 0;
      LET v_estatus         = NULL;
      LET v_comision        = 0;
      LET v_cod_agente      = NULL;
      LET v_cod_contratante = NULL;
      LET v_forma_pago      = " ";
      LET v_cant_pagos      = 0;

      LET v_descr_cia = sp_sis01(a_compania);

      FOREACH

         SELECT e.no_poliza
		   INTO v_nopoliza
           FROM emifacon e, endedmae t
          WHERE e.no_poliza = t.no_poliza
            and e.no_endoso = t.no_endoso
            and t.actualizado = 1
            and e.cod_contrato = a_cod_contrato
          group by e.no_poliza
          order by e.no_poliza

  		   FOREACH
	         SELECT cobredet.no_poliza,
	         		"00000",
	                cobredet.no_recibo,
	                0.00,
	                cobredet.prima_neta,
	                0.00,
	         		"informix",
					cobredet.fecha,
					cobredet.no_remesa
	           INTO v_nopoliza,
	           		v_noendoso,
	           		v_nofactura,
	                v_prima_suscrita,
	                v_prima_neta,
	                v_suma_asegurada,
					v_cod_usuario,
					v_vigencia_inic,
					_no_remesa
	           FROM cobredet, cobreaco c
			  WHERE cobredet.no_remesa = c.no_remesa
                and cobredet.renglon   = c.renglon
                and cobredet.actualizado = 1
				and cobredet.tipo_mov    in ("P", "N")
				and cobredet.no_poliza   = v_nopoliza
			    and c.cod_contrato       = a_cod_contrato
			  order by cobredet.no_remesa

			 SELECT y.cod_grupo,
			 		y.cod_ramo,
			 		y.cod_formapag,
	                y.no_pagos,
	                y.estatus_poliza,
	                y.no_documento,
	                y.cod_tipoprod,
	                y.cod_contratante,
	                y.sucursal_origen,
	                y.nueva_renov,
	                y.cod_subramo,
					y.reemplaza_poliza
	           INTO v_cod_grupo,
	           		v_cod_ramo,
	           		v_forma_pago,
	                v_cant_pagos,
	                v_estatus,
	                v_nodocumento,
	                v_cod_tipoprod,
	                v_cod_contratante,
	                v_cod_sucursal,
	                _nueva_renov,
	                v_cod_subramo,
				    _reemplaza_poliza
	           FROM emipomae y
	          WHERE y.no_poliza    = v_nopoliza
	            AND y.cod_compania = a_compania
	            AND y.actualizado  = 1;

	         IF v_cod_ramo IS NULL OR
	            v_cod_ramo = " "   THEN
	            CONTINUE FOREACH;
	         END IF;

	         SELECT tipo_produccion
	           INTO _tipo_produccion
	           FROM emitipro
	          WHERE cod_tipoprod = v_cod_tipoprod;

			 let _tot_prima_sus = 0.00;
	         let v_comision        = 0;

			select count(*)
			  into _cantidad
	          from endmoage
	         where no_poliza = v_nopoliza
	  	       and no_endoso = v_noendoso;

			if _cantidad = 0 then

				insert into endmoage(
				no_poliza,
				no_endoso,
				cod_agente,
				porc_partic_agt,
				porc_comis_agt,
				porc_produc
				)
				select no_poliza,
					   v_noendoso,
					   cod_agente,
					   porc_partic_agt,
					   porc_comis_agt,
					   porc_produc
				  from emipoagt
				 where no_poliza = v_nopoliza;

			end if

	         FOREACH
	            SELECT cod_agente,
	            	   porc_comis_agt,
					   porc_partic_agt
	              INTO v_cod_agente,
	              	   v_porc_comis,
					   _porc_partic_agt
	              FROM endmoage
	             WHERE no_poliza = v_nopoliza
	  	           and no_endoso = v_noendoso

				 IF v_porc_comis IS NULL THEN
		            LET v_porc_comis = 0.00;
		         END IF

	            LET _tot_prima_sus = v_prima_suscrita * _porc_partic_agt / 100;
	            LET v_comision     = _tot_prima_sus   * v_porc_comis / 100;

	           INSERT INTO temp_rea
	                VALUES(v_cod_sucursal,
	                      v_cod_grupo,
	                      v_cod_agente,
	                      v_cod_usuario,
	                      v_cod_ramo,
						  v_cod_subramo,
	                      v_cod_tipoprod,
						  _tipo_produccion,
	                      v_nopoliza,
	                      v_noendoso,
	                      v_nofactura,
	                      v_nodocumento,
	                      v_cod_contratante,
	                      v_estatus,
	                      v_forma_pago,
	                      v_cant_pagos,
	                      v_suma_asegurada,
	                      _tot_prima_sus,
						  v_prima_neta,
	                      v_comision,
						  v_vigencia_inic,
						  _nueva_renov,
						  _tot_prima_sus,
						  _no_remesa,
	                      1);
	         END FOREACH;
	  end foreach

      LET v_forma_pago      = " ";
      LET v_cant_pagos      = 0;
	  LET v_suma_asegurada  = 0;

      END FOREACH

-- Procesos v_filtros
      LET v_filtros ="";

--Filtro por Sucursal
      IF a_codsucursal <> "*" THEN
         LET v_filtros = TRIM(v_filtros) ||"Sucursal "||TRIM(a_codsucursal);
         LET _tipo = sp_sis04(a_codsucursal); -- Separa los valores del String

         IF _tipo <> "E" THEN -- Incluir los Registros

            UPDATE temp_rea
                   SET seleccionado = 0
                 WHERE seleccionado = 1
                   AND cod_sucursal NOT IN(SELECT codigo FROM tmp_codigos);
         ELSE
            UPDATE temp_rea
                   SET seleccionado = 0
                 WHERE seleccionado = 1
                   AND cod_sucursal IN(SELECT codigo FROM tmp_codigos);
         END IF
         DROP TABLE tmp_codigos;
      END IF

--Filtro por Grupo
      IF a_codgrupo <> "*" THEN
         LET v_filtros = TRIM(v_filtros) ||"Grupo "||TRIM(a_codgrupo);
         LET _tipo = sp_sis04(a_codgrupo); -- Separa los valores del String

         IF _tipo <> "E" THEN -- Incluir los Registros

            UPDATE temp_rea
                   SET seleccionado = 0
                 WHERE seleccionado = 1
                   AND cod_grupo NOT IN(SELECT codigo FROM tmp_codigos);
         ELSE
            UPDATE temp_rea
                   SET seleccionado = 0
                 WHERE seleccionado = 1
                   AND cod_grupo IN(SELECT codigo FROM tmp_codigos);
         END IF
         DROP TABLE tmp_codigos;
      END IF

--Filtro por Agente
      IF a_codagente <> "*" THEN
         LET v_filtros = TRIM(v_filtros) ||"Agente "||TRIM(a_codagente);
         LET _tipo = sp_sis04(a_codagente); -- Separa los valores del String

         IF _tipo <> "E" THEN -- Incluir los Registros

            UPDATE temp_rea
                   SET seleccionado = 0
                 WHERE seleccionado = 1
                   AND cod_agente NOT IN(SELECT codigo FROM tmp_codigos);
         ELSE
            UPDATE temp_rea
                   SET seleccionado = 0
                 WHERE seleccionado = 1
                   AND cod_agente IN(SELECT codigo FROM tmp_codigos);
         END IF
         DROP TABLE tmp_codigos;
      END IF

--Filtro por Usuario
      IF a_codusuario <> "*" THEN
         LET v_filtros = TRIM(v_filtros) ||"Usuario "||TRIM(a_codusuario);
         LET _tipo = sp_sis04(a_codusuario); -- Separa los valores del String

         IF _tipo <> "E" THEN -- Incluir los Registroo

            UPDATE temp_rea
                   SET seleccionado = 0
                 WHERE seleccionado = 1
                   AND cod_usuario NOT IN(SELECT codigo FROM tmp_codigos);
         ELSE
            UPDATE temp_rea
                   SET seleccionado = 0
                 WHERE seleccionado = 1
                   AND cod_usuario IN(SELECT codigo FROM tmp_codigos);
         END IF
         DROP TABLE tmp_codigos;
      END IF

--Filtro por Ramo
      IF a_codramo <> "*" THEN
         LET v_filtros = TRIM(v_filtros) ||"Ramo "||TRIM(a_codramo);
         LET _tipo = sp_sis04(a_codramo); -- Separa los valores del String

         IF _tipo <> "E" THEN -- Incluir los Registros

            UPDATE temp_rea
                   SET seleccionado = 0
                 WHERE seleccionado = 1
                   AND cod_ramo NOT IN(SELECT codigo FROM tmp_codigos);
         ELSE
            UPDATE temp_rea
                   SET seleccionado = 0
                 WHERE seleccionado = 1
                   AND cod_ramo IN(SELECT codigo FROM tmp_codigos);
         END IF
         DROP TABLE tmp_codigos;
	  END IF

--Filtro por Reaseguro
	  IF a_reaseguro = "*" THEN
		 LET v_filtros = TRIM(v_filtros) || " Con Reaseguro Asumido ";
	  END IF
	     
   	  IF a_reaseguro <> "*" THEN
	  
      	LET _tipo = sp_sis04(a_reaseguro);  -- Separa los Valores del String en una tabla de codigos

     	IF _tipo <> "E" THEN -- Incluir los Registros


	       LET v_filtros = TRIM(v_filtros) || " Reaseguro Asumido: Solamente ";
	       UPDATE temp_rea
		      SET seleccionado = 0
		    WHERE seleccionado = 1
		      AND tipo_produccion NOT IN (SELECT codigo FROM tmp_codigos);

    	ELSE		        -- Excluir estos Registros

	       LET v_filtros = TRIM(v_filtros) || " Reaseguro Asumido: Excluido ";
	       UPDATE temp_rea
		      SET seleccionado = 0
		    WHERE seleccionado = 1
		      AND tipo_produccion IN (SELECT codigo FROM tmp_codigos);

     	END IF

     	DROP TABLE tmp_codigos;

      END IF

--Filtro por Tipo de Poliza
	IF a_tipopol <> '1' THEN

      IF a_tipopol = '2' THEN

	       LET v_filtros = TRIM(v_filtros) || " Polizas Nuevas ";
		   UPDATE temp_rea
		      SET seleccionado = 0
		    WHERE seleccionado = 1
		      AND nueva_renov NOT IN ('N');

    	   UPDATE temp_rea
		      SET seleccionado = 0
		    WHERE seleccionado = 1
		      AND no_endoso NOT IN ('00000');


	  ELIF a_tipopol = '3' THEN
	    
	       LET v_filtros = TRIM(v_filtros) || " Polizas Renovadas ";
		   UPDATE temp_rea
		      SET seleccionado = 0
		    WHERE seleccionado = 1
		      AND nueva_renov NOT IN ('R');

    	   UPDATE temp_rea
		      SET seleccionado = 0
		    WHERE seleccionado = 1
		      AND no_endoso NOT IN ('00000');

	  ELSE
	     
	       LET v_filtros = TRIM(v_filtros) || " Polizas Endosos ";
		   UPDATE temp_rea
		      SET seleccionado = 0
		    WHERE seleccionado = 1
		      AND no_endoso IN ('00000') ;

	  END IF
	END IF
	     
    RETURN v_filtros;
   
END PROCEDURE;
