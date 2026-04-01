-- Modificado: 28/08/2001. Lic. Marquelda Valdelamar, para incluir el filtro de cliente y poliza
-- Modificado: 20/12/2002. Lic. Armando Moreno M. Arreglando el reporte totalmente.

DROP procedure sp_pro58;
CREATE procedure "informix".sp_pro58(a_compania CHAR(03),a_agencia CHAR(03),a_periodo1 CHAR(07),a_periodo2 CHAR(07),a_codsucursal CHAR(255) DEFAULT "*",a_codgrupo CHAR(255) DEFAULT "*",a_codagente CHAR(255) DEFAULT "*",a_codusuario CHAR(255) DEFAULT "*",a_codramo CHAR(255) DEFAULT "*",a_contrato VARCHAR(255) DEFAULT"*",a_reaseguro CHAR(255) DEFAULT "*", a_cod_cliente CHAR(255) DEFAULT "*", a_no_documento CHAR(255) DEFAULT "*")

         RETURNING CHAR(10),CHAR(45),CHAR(3),CHAR(50),
                   CHAR(10),CHAR(20),CHAR(03),CHAR(25),
                   CHAR(35),CHAR(30),DEC(16,2),DEC(9,2),
                   DEC(16,2),CHAR(50),CHAR(255);

--------------------------------------------
---  DETALLE DE PRODUCCION POR CONTRATO ---
---  Yinia M. Zamora - octubre 2000 - YMZM
---  Ref. Power Builder - d_sp_pro33
--------------------------------------------

   BEGIN
      DEFINE v_nopoliza,v_nofactura          CHAR(10);
      DEFINE v_nodocumento                   CHAR(20);
      DEFINE v_noendoso,v_no_unidad          CHAR(5);
      DEFINE s_cia,v_cod_sucursal,v_cod_ramo,v_cod_subramo,
             v_cod_tipoprod                  CHAR(03);
      DEFINE v_cod_agente,v_cod_grupo,v_cod_acreedor   CHAR(5);
      DEFINE v_cod_usuario                   CHAR(8);
      DEFINE v_porc_comis                    DEC(5,2);
      DEFINE v_cod_contrato,v_cod_contratante,w_cod_contrato  CHAR(10);
      DEFINE v_prima,_prima_sus		          DECIMAL(16,2);
      DEFINE v_comision                      DECIMAL(9,2);
      DEFINE v_desc_contrato                 CHAR(45);
      DEFINE v_desc_subramo                  CHAR(25);
      DEFINE v_desc_ramo                     CHAR(50);
      DEFINE v_desc_nombre                   CHAR(35);
      DEFINE v_desc_acreedor                 CHAR(30);
      DEFINE v_filtros                       CHAR(255);
      DEFINE _tipo,_tipo_produccion,v_tipo_contrato   CHAR(01);
      DEFINE v_descr_cia                     CHAR(50);
      DEFINE s_tipopro                       CHAR(03);
	  DEFINE _tipo_contrato                   smallint;

      CREATE TEMP TABLE temp_detalle
               (cod_sucursal     CHAR(3),
                cod_grupo        CHAR(5),
                cod_agente       CHAR(5),
                cod_usuario      CHAR(8),
                cod_contrato     CHAR(5),
                cod_ramo         CHAR(3),
                cod_subramo      CHAR(3),
                cod_tipoprod     CHAR(3),
				tipo_contrato    CHAR(1),
				tipo_produccion  CHAR(1),
				no_factura       CHAR(10),
                no_documento     CHAR(20),
                cod_contratante  CHAR(10),
                cod_acreedor     CHAR(05),
                prima            DEC(16,2),
                comision         DEC(9,2),
				prima_sus        DEC(16,2),
                seleccionado     SMALLINT DEFAULT 1);

      CREATE INDEX id1_temp_detalle ON temp_detalle(cod_sucursal);
      CREATE INDEX id2_temp_detalle ON temp_detalle(cod_grupo);
      CREATE INDEX id3_temp_detalle ON temp_detalle(cod_agente);
      CREATE INDEX id4_temp_detalle ON temp_detalle(cod_usuario);
      CREATE INDEX id5_temp_detalle ON temp_detalle(cod_ramo);
	  CREATE INDEX id6_temp_detalle ON temp_detalle(tipo_produccion);


      LET s_tipopro        = NULL;
      LET v_desc_ramo      = NULL;
      LET v_cod_agente     = NULL;
      LET v_prima          = 0;
      LET _prima_sus       = 0;
      LET v_porc_comis     = 0;
	  LET v_cod_acreedor   = " ";

      LET v_descr_cia = sp_sis01(a_compania);

    --   SET DEBUG FILE TO "sp_pro33z";
    --   TRACE ON;

SET ISOLATION TO DIRTY READ;
FOREACH WITH HOLD
         SELECT a.no_poliza,
         		a.no_endoso,
         		a.cod_sucursal,
         		a.no_factura,
				a.prima_suscrita
           INTO v_nopoliza,
           		v_noendoso,
           		v_cod_sucursal,
           		v_nofactura,
				_prima_sus
		   FROM endedmae a
          WHERE a.cod_compania = a_compania
            AND a.actualizado  = 1
            AND a.periodo >= a_periodo1
            AND a.periodo <= a_periodo2

         SELECT y.cod_grupo,
         		y.cod_ramo,
         		y.cod_subramo,
         		y.user_added,
                y.no_documento,
                y.cod_tipoprod,
                y.cod_contratante
           INTO v_cod_grupo,
           		v_cod_ramo,
           		v_cod_subramo,
           		v_cod_usuario,
                v_nodocumento,
                v_cod_tipoprod,
                v_cod_contratante
           FROM emipomae y
          WHERE y.no_poliza    = v_nopoliza
            AND y.cod_compania = a_compania;

         IF v_cod_ramo IS NULL OR
            v_cod_ramo = " "   THEN
            CONTINUE FOREACH;
         END IF;

		 SELECT tipo_produccion
	       INTO _tipo_produccion
		   FROM emitipro
		  WHERE cod_tipoprod = v_cod_tipoprod;

         FOREACH
           SELECT cod_agente,
           		  porc_comis_agt
             INTO v_cod_agente,
             	  v_porc_comis
             FROM emipoagt
            WHERE no_poliza = v_nopoliza

           IF v_cod_agente IS NULL THEN
              CONTINUE FOREACH;
           ELSE
              EXIT FOREACH;
           END IF
         END FOREACH;

		LET v_comision = (_prima_sus * v_porc_comis)/100;

		foreach
		 select no_unidad
		   into v_no_unidad
		   from endeduni
         WHERE no_poliza = v_nopoliza
           AND no_endoso = v_noendoso

	         FOREACH
	            SELECT no_unidad,
	            	   cod_contrato,
	            	   prima
	              INTO v_no_unidad,
	              	   v_cod_contrato,
	              	   v_prima
	              FROM emifacon
	             WHERE no_poliza = v_nopoliza
	               AND no_endoso = v_noendoso
				   and no_unidad = v_no_unidad
	   			   AND prima <> 0

		
	             SELECT tipo_contrato
	               INTO _tipo_contrato
	               FROM reacomae
	              WHERE cod_contrato = v_cod_contrato;
				    --AND tipo_contrato <> 1;

	{
				IF _tipo_contrato = 1 THEN
				 CONTINUE FOREACH;
				END IF
	}               

	            LET v_tipo_contrato = _tipo_contrato; 

				LET v_cod_acreedor = '';

				FOREACH
	             SELECT cod_acreedor
	               INTO v_cod_acreedor
	               FROM emipoacr
	              WHERE no_poliza = v_nopoliza
	                AND  no_unidad = v_no_unidad
					EXIT FOREACH;
	            END FOREACH; 

	            INSERT INTO temp_detalle
	                  VALUES(v_cod_sucursal,
	                         v_cod_grupo,
	                         v_cod_agente,
	                         v_cod_usuario,
	                         v_cod_contrato,
	                         v_cod_ramo,
	                         v_cod_subramo,
	                         v_cod_tipoprod,
							 v_tipo_contrato,
							 _tipo_produccion,
	                         v_nofactura,
	                         v_nodocumento,
	                         v_cod_contratante,
	                         v_cod_acreedor,
	                         v_prima,
	                         v_comision,
							 _prima_sus,
	                         1);
	         END FOREACH

         END FOREACH

END FOREACH
           -- Procesos v_filtros
      LET v_filtros ="";

      IF a_codsucursal <> "*" THEN
         LET v_filtros = TRIM(v_filtros) ||"Sucursal "||TRIM(a_codsucursal);
         LET _tipo = sp_sis04(a_codsucursal); -- Separa los valores del String

         IF _tipo <> "E" THEN -- Incluir los Registros

            UPDATE temp_detalle
               SET seleccionado = 0
             WHERE seleccionado = 1
               AND cod_sucursal NOT IN(SELECT codigo FROM tmp_codigos);
         ELSE
            UPDATE temp_detalle
               SET seleccionado = 0
             WHERE seleccionado = 1
               AND cod_sucursal IN(SELECT codigo FROM tmp_codigos);
         END IF
         DROP TABLE tmp_codigos;
      END IF

      IF a_codgrupo <> "*" THEN
         LET v_filtros = TRIM(v_filtros) ||"Grupo "||TRIM(a_codgrupo);
         LET _tipo = sp_sis04(a_codgrupo); -- Separa los valores del String

         IF _tipo <> "E" THEN -- Incluir los Registros

            UPDATE temp_detalle
               SET seleccionado = 0
             WHERE seleccionado = 1
               AND cod_grupo NOT IN(SELECT codigo FROM tmp_codigos);
         ELSE
            UPDATE temp_detalle
               SET seleccionado = 0
             WHERE seleccionado = 1
               AND cod_grupo IN(SELECT codigo FROM tmp_codigos);
         END IF
         DROP TABLE tmp_codigos;
      END IF

      IF a_cod_cliente <> "*" THEN
         LET v_filtros = TRIM(v_filtros) ||"Cliente "||TRIM(a_cod_cliente);
         LET _tipo = sp_sis04(a_cod_cliente); -- Separa los valores del String

         IF _tipo <> "E" THEN -- Incluir los Registros

            UPDATE temp_detalle
               SET seleccionado = 0
             WHERE seleccionado = 1
               AND cod_contratante NOT IN(SELECT codigo FROM tmp_codigos);
         ELSE
            UPDATE temp_detalle
               SET seleccionado = 0
             WHERE seleccionado = 1
               AND cod_contratante IN(SELECT codigo FROM tmp_codigos);
         END IF
         DROP TABLE tmp_codigos;
      END IF

      IF a_codagente <> "*" THEN
         LET v_filtros = TRIM(v_filtros) ||"Agente "||TRIM(a_codagente);
         LET _tipo = sp_sis04(a_codagente); -- Separa los valores del String

         IF _tipo <> "E" THEN -- Incluir los Registros

            UPDATE temp_detalle
                   SET seleccionado = 0
                 WHERE seleccionado = 1
                   AND cod_agente NOT IN(SELECT codigo FROM tmp_codigos);
         ELSE
            UPDATE temp_detalle
                   SET seleccionado = 0
                 WHERE seleccionado = 1
                   AND cod_agente IN(SELECT codigo FROM tmp_codigos);
         END IF
         DROP TABLE tmp_codigos;
      END IF

      IF a_codusuario <> "*" THEN
         LET v_filtros = TRIM(v_filtros) ||"Usuario "||TRIM(a_codusuario);
         LET _tipo = sp_sis04(a_codusuario); -- Separa los valores del String

         IF _tipo <> "E" THEN -- Incluir los Registros

            UPDATE temp_detalle
                   SET seleccionado = 0
                 WHERE seleccionado = 1
                   AND cod_usuario NOT IN(SELECT codigo FROM tmp_codigos);
         ELSE
            UPDATE temp_detalle
                   SET seleccionado = 0
                 WHERE seleccionado = 1
                   AND cod_usuario IN(SELECT codigo FROM tmp_codigos);
         END IF
         DROP TABLE tmp_codigos;
      END IF

      IF a_codramo <> "*" THEN
         LET v_filtros = TRIM(v_filtros) ||"Ramo "||TRIM(a_codramo);
         LET _tipo = sp_sis04(a_codramo); -- Separa los valores del String

         IF _tipo <> "E" THEN -- Incluir los Registros

            UPDATE temp_detalle
                   SET seleccionado = 0
                 WHERE seleccionado = 1
                   AND cod_ramo NOT IN(SELECT codigo FROM tmp_codigos);
         ELSE
            UPDATE temp_detalle
                   SET seleccionado = 0
                 WHERE seleccionado = 1
                   AND cod_ramo IN(SELECT codigo FROM tmp_codigos);
         END IF
         DROP TABLE tmp_codigos;
      END IF

	  IF a_reaseguro = "*" THEN
	     LET v_filtros = TRIM(v_filtros) || " Con Reaseguro Asumido ";
	  END IF

		IF a_reaseguro <> "*" THEN

			LET _tipo = sp_sis04(a_reaseguro);  -- Separa los Valores del String en una tabla de codigos

			IF _tipo <> "E" THEN -- Incluir los Registros

			    LET v_filtros = TRIM(v_filtros) || " Reaseguro Asumido: Solamente ";
				UPDATE temp_detalle
				   SET seleccionado = 0
				 WHERE seleccionado = 1
				   AND tipo_produccion NOT IN (SELECT codigo FROM tmp_codigos);

			ELSE		        -- Excluir estos Registros

			    LET v_filtros = TRIM(v_filtros) || " Reaseguro Asumido: Excluido ";
				UPDATE temp_detalle
				   SET seleccionado = 0
				 WHERE seleccionado = 1
				   AND tipo_produccion IN (SELECT codigo FROM tmp_codigos);

			END IF
			DROP TABLE tmp_codigos;

		END IF

	  IF a_contrato <> "*" THEN
	   	LET _tipo = sp_sis04(TRIM(a_contrato));
	   	 -- Separa los Valores del String en una tabla de codigos

	    IF _tipo <> "E" THEN -- Incluir los Registros

           LET v_filtros = TRIM(v_filtros);

	       UPDATE temp_detalle
		      SET seleccionado = 0
		    WHERE seleccionado = 1
		      AND tipo_contrato NOT IN (SELECT codigo FROM tmp_codigos);

     	ELSE		        -- (E) Excluir estos Registros

           LET v_filtros = TRIM(v_filtros);

	       UPDATE temp_detalle
		      SET seleccionado = 0
		    WHERE seleccionado = 1
		      AND tipo_contrato IN (SELECT codigo FROM tmp_codigos);

	    END IF
	    DROP TABLE tmp_codigos;
	   END IF

--Filtro de Poliza
	  IF a_no_documento <> "*" and a_no_documento <> "" THEN
         LET v_filtros = TRIM(v_filtros) ||"Documento: "||TRIM(a_no_documento);
            UPDATE temp_detalle
                   SET seleccionado = 0
                 WHERE seleccionado = 1
                   AND no_documento <> a_no_documento;
      END IF
--       
	    FOREACH
         SELECT x.cod_contrato,
         		x.cod_ramo,
         		x.no_factura,
         		x.no_documento,
                x.cod_subramo,
                x.cod_contratante,
                x.cod_acreedor,
                x.prima,
                x.comision,
				x.prima_sus
           INTO v_cod_contrato,
           		v_cod_ramo,
           		v_nofactura,
                v_nodocumento,
                v_cod_subramo,
                v_cod_contratante,
                v_cod_acreedor,
                v_prima,
                v_comision,
				_prima_sus
           FROM temp_detalle x
          WHERE x.seleccionado = 1
          ORDER BY x.cod_ramo, x.no_factura

         SELECT prdramo.nombre
           INTO v_desc_ramo
           FROM prdramo
          WHERE prdramo.cod_ramo = v_cod_ramo;

         SELECT prdsubra.nombre
           INTO v_desc_subramo
           FROM prdsubra
          WHERE prdsubra.cod_ramo    = v_cod_ramo
            AND prdsubra.cod_subramo = v_cod_subramo;

         SELECT nombre
           INTO v_desc_nombre
           FROM cliclien
          WHERE cod_cliente = v_cod_contratante;

         SELECT nombre
           INTO v_desc_contrato
           FROM reacomae
          WHERE cod_contrato = v_cod_contrato;

         SELECT nombre
           INTO v_desc_acreedor
           FROM emiacre
          WHERE cod_acreedor = v_cod_acreedor;

--         LET v_prima_cedida = v_prima;
	
         RETURN v_cod_contrato,
         		v_desc_contrato,
         		v_cod_ramo,
         		v_desc_ramo,
                v_nofactura,
                v_nodocumento,
                v_cod_subramo,
                v_desc_subramo,
                v_desc_nombre,
                v_desc_acreedor,
                _prima_sus,
                v_comision,
                v_prima,
                v_descr_cia,
                v_filtros  WITH RESUME;

      END FOREACH

   DROP TABLE temp_detalle;
   END
END PROCEDURE;
