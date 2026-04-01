--  COASEGURO CEDIDO POR COMPANIA       ---
--  CASI IGUAL AL SP_PRO41 PARA ADELA

-- 	Amado Perez 14/05/2003
--  

DROP procedure sp_pro116;
CREATE procedure "informix".sp_pro116(a_compania CHAR(03),a_agencia CHAR(03),a_fecha DATE,a_codsucursal CHAR(255) DEFAULT "*",a_codramo CHAR(255) DEFAULT "*",a_codcoasegur CHAR(255) DEFAULT "*", a_cod_cliente CHAR(255) DEFAULT "*", a_no_documento CHAR(255) DEFAULT "*")
       RETURNING CHAR(3),
       			 CHAR(50),
       			 CHAR(10),
       			 CHAR(20),
                 CHAR(35),
                 DEC(7,2),
                 DEC(16,2),
                 DEC(16,2),
                 DEC(16,2),
                 DEC(6,2),
                 DEC(6,2),
                 DEC(16,2),
                 DEC(5,2),
                 CHAR(50),
				 DATE,
				 DATE,
				 CHAR(3),
				 CHAR(50),
                 CHAR(255);


   BEGIN
      DEFINE v_nopoliza,v_nofactura,w_no_poliza  CHAR(10);
      DEFINE v_nodocumento                   CHAR(20);
      DEFINE v_noendoso                      CHAR(5);
      DEFINE v_cod_tipoprod,v_no_cambio,v_cod_coasegur    CHAR(3);
      DEFINE v_porc_gastos                   DEC(5,2);
      DEFINE v_porc_partic                   DEC(7,4);
      DEFINE v_cod_contratante               CHAR(10);
      DEFINE v_prima_suscrita,v_total_prima,v_prima_neta,v_prima DECIMAL(16,2);
	  DEFINE v_suma_asegurada				 DECIMAL(16,2);
      DEFINE v_comision                      DECIMAL(9,2);
      DEFINE v_desc_nombre                   CHAR(35);
      DEFINE v_filtros                       CHAR(255);
      DEFINE _tipo                           CHAR(01);
      DEFINE v_descr_cia                     CHAR(50);
      DEFINE v_desc_coaseg                   CHAR(40);
      DEFINE v_impuesto,v_impuesto1          DEC(16,2);
      DEFINE mes1,mes2,ano1,ano2             SMALLINT;
	  DEFINE v_ase_lider,v_codimp5,v_codimp1 CHAR(03);
      DEFINE v_vigencia_inic, v_vigencia_final DATE;
	  DEFINE v_codramo                       CHAR(3);
	  DEFINE v_ramo							 CHAR(50);


       CREATE TEMP TABLE temp_coaseguro
               (no_factura        CHAR(10),
                no_documento       CHAR(20),
				no_poliza          CHAR(10),
                cod_contratante    CHAR(10),
                cod_coasegur       CHAR(3),
                prima              DEC(16,2),
				prima_suscrita     DEC(16,2),
				suma_asegurada     DEC(16,2),
                porc_partic_coas   DEC(7,4),
                porc_gastos        DEC(5,2),
				porc_impuesto1     DEC(9,2),
				porc_impuesto2	   DEC(9,2),
                seleccionado       SMALLINT DEFAULT 1);

      CREATE INDEX id1_temp_coaseguro ON temp_coaseguro(cod_coasegur);
      CREATE INDEX id2_temp_coaseguro ON temp_coaseguro(no_factura);

      LET v_prima_suscrita  = 0;
      LET v_comision        = 0;
      LET v_cod_contratante = NULL;
      LET v_impuesto        = 0;
      LET v_impuesto1       = 0;
	  LET v_prima           = 0;
	  LET v_no_cambio       = " ";

      LET v_descr_cia = sp_sis01(a_compania);

      SET ISOLATION TO DIRTY READ;
   	  SELECT par_ase_lider
	    INTO v_ase_lider
        FROM parparam
	   WHERE cod_compania = a_compania;

	  SELECT cod_impuesto
	    INTO v_codimp5
      	FROM prdimpue
	   WHERE factor_impuesto = 5;

	  SELECT cod_impuesto
	    INTO v_codimp1
      	FROM prdimpue
	   WHERE factor_impuesto = 1;


	       SELECT cod_tipoprod
             INTO v_cod_tipoprod
             FROM emitipro
            WHERE tipo_produccion = 2;

      CALL sp_pro116a(a_compania,a_agencia,a_fecha,a_codramo,"001")
                    RETURNING v_filtros;

--SET DEBUG FILE TO "sp_pro41.trc";
--trace on;

	  FOREACH WITH HOLD
         SELECT x.no_poliza,
                x.no_factura,
                x.no_documento,
                x.cod_contratante,
                x.prima_suscrita,
                x.vigencia_inic,
                x.suma_asegurada
           INTO v_nopoliza,
                v_nofactura,
                v_nodocumento,
                v_cod_contratante,
                v_prima_suscrita,
                v_vigencia_inic,
		   		v_suma_asegurada
           FROM temp_perfil x
          WHERE x.seleccionado = 1

     
         FOREACH
           SELECT MAX(no_cambio)
             INTO v_no_cambio
             FROM emihcmm
            WHERE no_poliza       = v_nopoliza
		      AND vigencia_inic  <= v_vigencia_inic  
		      AND vigencia_final >= v_vigencia_inic  
 
		   EXIT FOREACH;
         END FOREACH
		 IF v_no_cambio IS NULL THEN
            SELECT MAX(no_cambio)
              INTO v_no_cambio
              FROM emihcmm
             WHERE no_poliza       = v_nopoliza;
 		 END IF
 
         FOREACH
            SELECT cod_coasegur,porc_partic_coas,porc_gastos
              INTO v_cod_coasegur,v_porc_partic,v_porc_gastos
              FROM emihcmd
             WHERE no_poliza = v_nopoliza
		       AND no_cambio = v_no_cambio
 

			IF v_cod_coasegur = v_ase_lider OR v_cod_coasegur <> '017' THEN
			   CONTINUE FOREACH;
			END IF

            LET v_prima = v_prima_suscrita*(v_porc_partic/100);
 
			SELECT monto
			  INTO v_impuesto
			  FROM emipolim
			 WHERE no_poliza    = v_nopoliza
			   AND cod_impuesto = v_codimp5;

			IF v_impuesto IS NOT NULL THEN
			   LET v_impuesto = v_prima*0.05;
			ELSE
			   LET v_impuesto = 0;
			END IF

            SELECT monto
			  INTO v_impuesto1
			  FROM emipolim
			 WHERE no_poliza    = v_nopoliza
			   AND cod_impuesto = v_codimp1; 


			IF v_impuesto1 IS NOT NULL THEN
			   LET v_impuesto1 = v_prima*0.01;
			ELSE
			   LET v_impuesto1 = 0;
			END IF

            INSERT INTO temp_coaseguro
                  VALUES(v_nofactura,
                         v_nodocumento,
						 v_nopoliza,
                         v_cod_contratante,
                         v_cod_coasegur,
                         v_prima,
						 v_prima_suscrita,
						 v_suma_asegurada,
                         v_porc_partic,
                         v_porc_gastos,
						 v_impuesto,
						 v_impuesto1,
                         1);
         END FOREACH
      END FOREACH
      IF a_codcoasegur <> "*" THEN
         LET v_filtros =
             TRIM(v_filtros) ||"Coaseguradora "||TRIM(a_codcoasegur);
         LET _tipo = sp_sis04(a_codcoasegur); -- Separa los valores del String

         IF _tipo <> "E" THEN -- Incluir los Registros

            UPDATE temp_coaseguro
                  SET seleccionado = 0
                WHERE seleccionado = 1
                  AND cod_coasegur NOT IN(SELECT codigo FROM tmp_codigos);
         ELSE
            UPDATE temp_coaseguro
                   SET seleccionado = 0
                 WHERE seleccionado = 1
                   AND cod_coasegur IN(SELECT codigo FROM tmp_codigos);
         END IF
         DROP TABLE tmp_codigos;
      END IF

	IF a_cod_cliente <> "*" THEN
         LET v_filtros =
             TRIM(v_filtros) ||"Cliente "||TRIM(a_cod_cliente);
         LET _tipo = sp_sis04(a_cod_cliente); -- Separa los valores del String

         IF _tipo <> "E" THEN -- Incluir los Registros

            UPDATE temp_coaseguro
                  SET seleccionado = 0
                WHERE seleccionado = 1
                  AND cod_contratante NOT IN(SELECT codigo FROM tmp_codigos);
         ELSE
            UPDATE temp_coaseguro
                   SET seleccionado = 0
                 WHERE seleccionado = 1
                   AND cod_contratante IN(SELECT codigo FROM tmp_codigos);
         END IF
         DROP TABLE tmp_codigos;
      END IF

--Filtro de Poliza
	   IF a_no_documento <> "*" and a_no_documento <> "" THEN
         LET v_filtros = TRIM(v_filtros) ||"Documento: "||TRIM(a_no_documento);
            UPDATE temp_coaseguro
                   SET seleccionado = 0
                 WHERE seleccionado = 1
                   AND no_documento <> a_no_documento;
      END IF

--
      FOREACH
         SELECT no_factura,
         		no_documento,
				no_poliza,
         		cod_contratante,
         		cod_coasegur,
                prima,
                porc_partic_coas,
                porc_gastos,
                porc_impuesto1,
				porc_impuesto2,
				prima_suscrita,
				suma_asegurada
           INTO v_nofactura,
           		v_nodocumento,
				v_nopoliza,
           		v_cod_contratante,
           		v_cod_coasegur,
                v_prima_neta,
                v_porc_partic,
                v_porc_gastos,
                v_impuesto,
				v_impuesto1,
				v_prima_suscrita,
				v_suma_asegurada
           FROM temp_coaseguro
          WHERE seleccionado = 1
       ORDER BY cod_coasegur

         SELECT nombre
           INTO v_desc_coaseg
           FROM emicoase
          WHERE cod_coasegur = v_cod_coasegur;

        SELECT nombre
          INTO v_desc_nombre
          FROM cliclien
         WHERE cod_cliente = v_cod_contratante;

		SELECT vigencia_inic,
			   vigencia_final,
			   cod_ramo
		  INTO v_vigencia_inic, 
			   v_vigencia_final,
			   v_codramo
		  FROM emipomae
		 WHERE no_poliza = v_nopoliza;

        SELECT nombre
		  INTO v_ramo
		  FROM prdramo
		 WHERE cod_ramo = v_codramo;

        LET v_total_prima = v_prima_neta + v_impuesto + v_impuesto1;

         RETURN v_cod_coasegur,
                v_desc_coaseg,
                v_nofactura,
                v_nodocumento,
                v_desc_nombre,
                v_porc_partic,
                v_prima_neta,
				v_prima_suscrita,
				v_suma_asegurada,
                v_impuesto,
                v_impuesto1,
                v_total_prima,
                v_porc_gastos,
                v_descr_cia,
				v_vigencia_inic, 
				v_vigencia_final,
				v_codramo,
				v_ramo,
                v_filtros  
                WITH RESUME;

      END FOREACH;
   DROP TABLE temp_coaseguro;
   DROP TABLE temp_perfil;
   END
END PROCEDURE;
