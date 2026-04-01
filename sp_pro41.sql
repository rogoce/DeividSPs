--  COASEGURO CEDIDO POR COMPANIA       ---
--  Yinia M. Zamora - octubre 2000 - YMZM

-- Modificado por: Marquelda Valdelamar 28/08/2001 Para incluir filtro de cliente
-- Modificado por: Marquelda Valdelamar 06/09/2001 Para filtro de poliza

-- Modificado por: Demetrio Hurtado Almanza 22/09/2004 Usar la Tabla endcoama

-- Modificado por: Demetrio Hurtado Almanza 03/02/2006 
                   -- Se cambio el programa para que utilice los datos de prima de la Tabla endcoama
-- 

DROP procedure sp_pro41;
CREATE procedure "informix".sp_pro41(
a_compania 		CHAR(03),
a_agencia 		CHAR(03),
a_periodo1 		CHAR(07),
a_periodo2 		CHAR(07),
a_codsucursal 	CHAR(255) DEFAULT "*",
a_codramo 		CHAR(255) DEFAULT "*",
a_codcoasegur 	CHAR(255) DEFAULT "*", 
a_cod_cliente 	CHAR(255) DEFAULT "*", 
a_no_documento 	CHAR(255) DEFAULT "*"
) RETURNING CHAR(3),
			CHAR(50),
			CHAR(10),
			CHAR(20),
            CHAR(35),
            DEC(7,2),
            DEC(16,2),
            DEC(16,2),
            DEC(6,2),
            DEC(6,2),
            DEC(16,2),
            DEC(5,2),
            CHAR(50),
            CHAR(255),date,date,char(50);

   BEGIN
      DEFINE v_nopoliza,v_nofactura,w_no_poliza  CHAR(10);
      DEFINE v_nodocumento                   CHAR(20);
      DEFINE v_noendoso                      CHAR(5);
      DEFINE v_cod_tipoprod,v_no_cambio,v_cod_coasegur    CHAR(3);
      DEFINE v_porc_gastos                   DEC(5,2);
      DEFINE v_porc_partic                   DEC(7,4);
      DEFINE v_cod_contratante               CHAR(10);
      DEFINE v_prima_suscrita,v_total_prima,v_prima_neta,v_prima DECIMAL(16,2);
      DEFINE v_comision                      DECIMAL(9,2);
      DEFINE v_desc_nombre                   CHAR(35);
      DEFINE v_filtros                       CHAR(255);
      DEFINE _tipo                           CHAR(01);
      DEFINE v_descr_cia                     CHAR(50);
      DEFINE v_desc_coaseg                   CHAR(40);
      DEFINE v_impuesto						DEC(16,2);
      DEFINE v_impuesto1					DEC(16,2);
      DEFINE _suma_asegurada				DEC(16,2);
      DEFINE mes1,mes2,ano1,ano2             SMALLINT;
	  DEFINE v_ase_lider,v_codimp5,v_codimp1 CHAR(3);
      DEFINE v_vigencia_inic                 DATE;
	  DEFINE _cod_ramo                       CHAR(3);      
	  DEFINE v_vigencia_final                DATE;
      DEFINE _n_agente						 CHAR(50);
      DEFINE _cod_agente                     char(10);	  


       CREATE TEMP TABLE temp_coaseguro
               (no_factura			CHAR(10),
                no_documento		CHAR(20),
                cod_contratante		CHAR(10),
                cod_coasegur		CHAR(3),
                prima				DEC(16,2),
                suma_asegurada		DEC(16,2),
                porc_partic_coas   DEC(7,4),
                porc_gastos        DEC(5,2),
				porc_impuesto1     DEC(9,2),
				porc_impuesto2	   DEC(9,2),
				cod_ramo           CHAR(3),
				vig_inicial        DATE,
				vig_final          DATE,				
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

--SET DEBUG FILE TO "sp_pro41.trc";
--trace on;

	let v_filtros = "";

	FOREACH
		SELECT x.no_poliza,
			   x.no_endoso,
			   x.no_factura,
			   x.no_documento,
			   x.prima_suscrita,
			   x.prima_neta,
			   x.vigencia_inic,
			   x.vigencia_final
		  INTO v_nopoliza,
			   v_noendoso,
			   v_nofactura,
			   v_nodocumento,
			   v_prima_suscrita,
			   v_prima_neta,
			   v_vigencia_inic,
			   v_vigencia_final
		  from endedmae x
		 where periodo >= a_periodo1
		   and periodo <= a_periodo2
		   and actualizado = 1

		select cod_contratante,
			   cod_ramo
		  into v_cod_contratante,
			   _cod_ramo
		  from emipomae
		 where no_poliza = v_nopoliza; 

		foreach
			select cod_coasegur,
				   porc_partic_coas,
				   porc_gastos,
				   prima,
				   suma
			  into v_cod_coasegur,
				   v_porc_partic,
				   v_porc_gastos,
				   v_prima,
				   _suma_asegurada
			  from endcoama
			 where no_poliza    = v_nopoliza
			   and no_endoso    = v_noendoso
			   and cod_coasegur <> v_ase_lider

			select monto
			  into v_impuesto
			  from endedimp
			 where no_poliza    = v_nopoliza
			   and no_endoso    = v_noendoso
			   and cod_impuesto = v_codimp5;

			if v_impuesto is not null then
			   let v_impuesto = v_prima*0.05;
			else
			   let v_impuesto = 0;
			end if

            select monto
			  into v_impuesto1
			  from endedimp
			 where no_poliza    = v_nopoliza
			   and no_endoso    = v_noendoso
			   and cod_impuesto = v_codimp1; 

			if v_impuesto1 is not null then
			   let v_impuesto1 = v_prima*0.01;
			else
			   let v_impuesto1 = 0;
			end if

            insert into temp_coaseguro
			values(	v_nofactura,
					v_nodocumento,
					v_cod_contratante,
					v_cod_coasegur,
					v_prima,
					_suma_asegurada,
					v_porc_partic,
					v_porc_gastos,
					v_impuesto,
					v_impuesto1,
					_cod_ramo,
					v_vigencia_inic,
					v_vigencia_final,
					1);
		end foreach
	end foreach

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

-- Filtro de Poliza

	   IF a_no_documento <> "*" and a_no_documento <> "" THEN

         LET v_filtros = TRIM(v_filtros) ||"Documento: "||TRIM(a_no_documento);

            UPDATE temp_coaseguro
                   SET seleccionado = 0
                 WHERE seleccionado = 1
                   AND no_documento <> a_no_documento;
      END IF

-- Filtro de Ramo

	IF a_codramo <> "*" THEN
         LET v_filtros = TRIM(v_filtros) ||"Ramo: "||TRIM(a_codramo);
         LET _tipo = sp_sis04(a_codramo); -- Separa los valores del String

         IF _tipo <> "E" THEN -- Incluir los Registros

	           UPDATE temp_coaseguro
                  SET seleccionado = 0
                WHERE seleccionado = 1
                  AND cod_ramo NOT IN(SELECT codigo FROM tmp_codigos);
         ELSE
    	        UPDATE temp_coaseguro
                   SET seleccionado = 0
                 WHERE seleccionado = 1
                   AND cod_ramo IN(SELECT codigo FROM tmp_codigos);
         END IF
         DROP TABLE tmp_codigos;
    END IF

FOREACH
       SELECT no_factura,
              no_documento,
              cod_contratante,
              cod_coasegur,
              prima,
              porc_partic_coas,
              porc_gastos,
              porc_impuesto1,
			  porc_impuesto2,
			  vig_inicial,
			  vig_final,
			  suma_asegurada
         INTO v_nofactura,
              v_nodocumento,
              v_cod_contratante,
              v_cod_coasegur,
              v_prima_neta,
              v_porc_partic,
              v_porc_gastos,
              v_impuesto,
			  v_impuesto1,
			  v_vigencia_inic,
			  v_vigencia_final,
			  _suma_asegurada			  
         FROM temp_coaseguro
        WHERE seleccionado = 1
        ORDER BY cod_coasegur
		
		let v_nopoliza = sp_sis21(v_nodocumento);
		
		SELECT nombre
		  INTO v_desc_coaseg
		  FROM emicoase
		 WHERE cod_coasegur = v_cod_coasegur;

		SELECT nombre
		  INTO v_desc_nombre
		  FROM cliclien
		 WHERE cod_cliente = v_cod_contratante;

		LET v_total_prima = v_prima_neta + v_impuesto +	v_impuesto1;
		foreach
			SELECT cod_agente
			  INTO _cod_agente
			  FROM emipoagt
			 WHERE no_poliza = v_nopoliza
			 exit foreach;
		end foreach
		select nombre into _n_agente from agtagent where cod_agente = _cod_agente;
		
		RETURN v_cod_coasegur,
			   v_desc_coaseg,
			   v_nofactura,
			   v_nodocumento,
			   v_desc_nombre,
			   v_porc_partic,
			   v_prima_neta,
			   _suma_asegurada,
			   v_impuesto,
			   v_impuesto1,
			   v_total_prima,
			   v_porc_gastos,
			   v_descr_cia,
			   v_filtros,
			   v_vigencia_inic,
			   v_vigencia_final,
			   _n_agente
			   WITH RESUME;

      END FOREACH;

   DROP TABLE if exists temp_coaseguro;
   END

END PROCEDURE;
