-- Reaseguro Cedido Facultativo con Reaseguro Asumido
-- Creado    : 26/11/2008 - Autor: Ricardo Jim‚nez
-- SIS v.2.0 - DEIVID, S.A.

DROP procedure sp_pro849_a;
CREATE procedure "informix".sp_pro849(a_compania CHAR(03),a_agencia CHAR(3),a_periodo1 CHAR(07),a_periodo2 CHAR(7),a_codramo CHAR(255) DEFAULT "*",a_codagente CHAR(255) DEFAULT "*",a_codsucursal CHAR(255) DEFAULT "*",a_codgrupo CHAR(255) DEFAULT "*",a_codcoasegur CHAR(255) DEFAULT "*",a_useradd CHAR(255) DEFAULT "*",a_reaseguro CHAR(255) DEFAULT "*",a_cod_cliente CHAR(255) DEFAULT "*",a_no_documento CHAR(255) DEFAULT "*",a_fronting SMALLINT DEFAULT 0)
RETURNING CHAR(50),
		  CHAR(03),
		  CHAR(50),
		  CHAR(03),
		  CHAR(50),
          CHAR(45),
          CHAR(20),
          CHAR(10),
          DATE,
          DECIMAL(16,2),
          DECIMAL(9,2),
          DECIMAL(9,2),
          DECIMAL(16,2),
          CHAR(07),
          CHAR(07),
          CHAR(255),
          SMALLINT;

   BEGIN

      DEFINE s_nopoliza,s_contratante,v_factura     CHAR(10);
      DEFINE s_codsucursal,s_codramo,s_codasegur,
             s_tipopro                              CHAR(3);
      DEFINE s_codgrupo,s_codagente,s_noendoso      CHAR(5);
      DEFINE v_documento                            CHAR(20);
      DEFINE s_user                                 CHAR(8);
      DEFINE v_descrea,v_descr_cia,v_descramo       CHAR(50);
      DEFINE v_descclte                             CHAR(45);
      DEFINE porc_comis,_porc_impuesto              DECIMAL(5,2);
      DEFINE periodo1,periodo2                      CHAR(7);
      DEFINE v_prima_suscrita,v_saldo               DECIMAL(16,2);
      DEFINE v_comision,v_impuesto                  DECIMAL(9,2);
      DEFINE v_fecha_emision                        DATE;
      DEFINE w_cuenta,v_seleccionado                SMALLINT;
      DEFINE v_filtros                              CHAR(255);
      DEFINE _tipo,_tipo_produccion                 CHAR(1);
	  DEFINE _porc_cont_partic                     	DECIMAL(5,2);
	  DEFINE _existe                                SMALLINT;
  	  DEFINE _porc_partic_coas				        DEC(7,4);
  	  DEFINE _cod_contrato                           CHAR(5);
	  DEFINE _fronting                              SMALLINT;
	  

      CREATE TEMP TABLE temp_endoso
               (no_poliza        CHAR(10),
                cod_sucursal     CHAR(3),
                cod_grupo        CHAR(5),
                cod_ramo         CHAR(3),
                cod_contratante  CHAR(10),
                cod_coasegur     CHAR(3),
                cod_tipopro      CHAR(3),
				tipo_produccion  CHAR(1),
                no_documento     CHAR(20),
                no_factura       CHAR(10),
                fecha_emision    DATE,
                prima_suscrita   DEC(16,2),
                comision         DEC(9,2),
                impuesto         DEC(9,2),
				fronting         SMALLINT default 0,
                seleccionado     SMALLINT DEFAULT 1 NOT NULL,
                PRIMARY KEY (cod_coasegur,cod_ramo,no_factura)) WITH NO LOG;

      CREATE INDEX iend1_temp_endoso ON temp_endoso(cod_grupo);
      CREATE INDEX iend2_temp_endoso ON temp_endoso(cod_ramo);
      CREATE INDEX iend3_temp_endoso ON temp_endoso(cod_coasegur);
      CREATE INDEX iend4_temp_endoso ON temp_endoso(cod_sucursal);
      CREATE INDEX iend5_temp_endoso ON temp_endoso(tipo_produccion);
      CREATE INDEX iend6_temp_endoso ON temp_endoso(cod_coasegur,cod_ramo,no_documento);

      LET v_descrea        = NULL;
      LET v_descramo       = NULL;
      LET v_descclte       = NULL;
      LET v_descr_cia      = NULL;
      LET v_documento      = NULL;
      LET v_factura        = NULL;
      LET v_prima_suscrita = 0;
      LET v_impuesto       = 0;
      LET v_comision       = 0;
      LET v_saldo          = 0;
      LET v_seleccionado   = 1;
      LET porc_comis       = 0;
      LET _porc_impuesto   = 0;
	  LET _existe          = 0;
	  LET _fronting        = 0;
      LET v_descr_cia = sp_sis01(a_compania);
	   
	  SET ISOLATION TO DIRTY READ;

	 --crea tabla temporal temp_det
      CALL sp_pro307(a_compania,a_agencia,a_periodo1,a_periodo2,a_codsucursal,a_codgrupo,
                    a_codagente,a_useradd,a_codramo,a_reaseguro) RETURNING v_filtros;
	
     FOREACH
		  SELECT no_poliza,
				 no_endoso,
				 no_factura,
				 vigencia_inic,
		         prima_neta
            INTO s_nopoliza,
	     		 s_noendoso,
				 v_factura,
				 v_fecha_emision,
		         v_prima_suscrita
            FROM temp_det
           WHERE seleccionado = 1

		 SELECT count(*)
           INTO _existe
           FROM endedmae
          WHERE cod_compania = a_compania
		    AND no_poliza    = s_nopoliza
			AND no_endoso    = s_noendoso
            AND periodo BETWEEN a_periodo1 AND a_periodo2
			AND actualizado  = 1;

	      If _existe = 0 Then
		     CONTINUE FOREACH;
		  End if
		  
          SELECT cod_sucursal,
                 cod_grupo,
                 cod_ramo,
                 cod_contratante,
                 no_documento,
                 cod_tipoprod
            INTO s_codsucursal,
                 s_codgrupo,
                 s_codramo,
                 s_contratante,
                 v_documento,
                 s_tipopro
            FROM emipomae
           WHERE no_poliza    = s_nopoliza
             AND cod_compania = a_compania;

		 select porc_partic_coas
		   into _porc_partic_coas 
		   from emicoama
		  where no_poliza    = s_nopoliza
		    and cod_coasegur = "036";

		 if _porc_partic_coas is null then
		 	let _porc_partic_coas = 100;
		 end if

		 --let v_prima_suscrita = v_prima_suscrita * _porc_partic_coas / 100;
  
		 SELECT tipo_produccion
           INTO _tipo_produccion
           FROM emitipro
          WHERE cod_tipoprod = s_tipopro;
		 		 	

		  FOREACH
		   	SELECT cod_coasegur,
             	   porc_comis_fac,
             	   porc_impuesto,
				   porc_partic_reas,
				   cod_contrato
              INTO s_codasegur,
               	   porc_comis,
               	   _porc_impuesto,
				   _porc_cont_partic,
				   _cod_contrato
              FROM emifafac
             WHERE no_poliza = s_nopoliza
               AND no_endoso = s_noendoso
							   	 
			IF a_fronting  = 1 THEN
				  SELECT fronting
				    INTO _fronting
				    FROM reacomae
				   WHERE cod_contrato = _cod_contrato;

				  if _fronting = 1 then  -- es fronting
				  else
				    continue foreach;
				  end if
			END IF;
			
            IF porc_comis IS NULL THEN
               LET porc_comis = 0;
            END IF;

            IF _porc_impuesto IS NULL THEN
               LET _porc_impuesto = 0;
            END IF;

	 		--LET v_prima_suscrita = v_prima_suscrita * (_porc_cont_partic / 100);
            LET v_comision = (v_prima_suscrita * (porc_comis/100));
            LET v_impuesto = (v_prima_suscrita * (_porc_impuesto/100));
			
			IF s_nopoliza = "220864" and s_noendoso = "00001" THEN
			   LET v_prima_suscrita = 0.00;
			END IF

            BEGIN
			   ON EXCEPTION IN (-239)
			      UPDATE temp_endoso
				     SET prima_suscrita = prima_suscrita + v_prima_suscrita,
					     comision       = comision       + v_comision,
						 impuesto       = impuesto       + v_impuesto
				   WHERE cod_coasegur   = s_codasegur
				     AND cod_ramo       = s_codramo
				     AND no_factura     = v_factura;

			   END EXCEPTION
			   

           		INSERT INTO temp_endoso
               	       VALUES(s_nopoliza,
                      		  s_codsucursal,
                      		  s_codgrupo,
                              s_codramo,
                              s_contratante,
                              s_codasegur,
                              s_tipopro,
					          _tipo_produccion,
                              v_documento,
                              v_factura,
                              v_fecha_emision,
                              v_prima_suscrita,
                              v_comision,
                      		  v_impuesto,
					  		  _fronting,
                      		  v_seleccionado);
		  END
          END FOREACH
      END FOREACH

      -- Procesos v_filtros
      LET v_filtros ="";

      IF a_codramo <> "*" THEN
         LET v_filtros = TRIM(v_filtros) ||"Ramo "||TRIM(a_codramo);
         LET _tipo     = sp_sis04(a_codramo); -- Separa los valores del String

         IF _tipo <> "E" THEN -- Incluir los Registros

            UPDATE temp_endoso
               SET seleccionado = 0
             WHERE seleccionado = 1
               AND cod_ramo NOT IN(SELECT codigo FROM tmp_codigos);
         ELSE
            UPDATE temp_endoso
               SET seleccionado = 0
             WHERE seleccionado = 1
               AND cod_ramo IN(SELECT codigo FROM tmp_codigos);
         END IF
         DROP TABLE tmp_codigos;
      END IF

      IF a_codsucursal <> "*" THEN
         LET v_filtros = TRIM(v_filtros) ||"Sucursal "||TRIM(a_codsucursal);
         LET _tipo = sp_sis04(a_codsucursal); -- Separa los valores del String

         IF _tipo <> "E" THEN -- Incluir los Registros
		    UPDATE temp_endoso
               SET seleccionado = 0
             WHERE seleccionado = 1
               AND cod_sucursal NOT IN(SELECT codigo FROM tmp_codigos);
         ELSE
            UPDATE temp_endoso
               SET seleccionado = 0
             WHERE seleccionado = 1
               AND cod_sucursal IN(SELECT codigo FROM tmp_codigos);
         END IF
         DROP TABLE tmp_codigos;
      END IF

      IF a_codgrupo <> "*" THEN
         LET v_filtros = TRIM(v_filtros) ||"Grupo"||TRIM(a_codgrupo);
         LET _tipo = sp_sis04(a_codgrupo); -- Separa los valores del String

         IF _tipo <> "E" THEN -- Incluir los Registros

            UPDATE temp_endoso
               SET seleccionado = 0
             WHERE seleccionado = 1
               AND cod_grupo NOT IN(SELECT codigo FROM tmp_codigos);
         ELSE
            UPDATE temp_endoso
               SET seleccionado = 0
             WHERE seleccionado = 1
               AND cod_grupo IN(SELECT codigo FROM tmp_codigos);
         END IF
         DROP TABLE tmp_codigos;
      END IF

      IF a_codcoasegur <> "*" THEN
         LET v_filtros = TRIM(v_filtros) ||"Coaseguradora "||TRIM(a_codcoasegur);
         LET _tipo = sp_sis04(a_codcoasegur); -- Separa los valores del String

         IF _tipo <> "E" THEN -- Incluir los Registros

            UPDATE temp_endoso
               SET seleccionado = 0
             WHERE seleccionado = 1
               AND cod_coasegur NOT IN(SELECT codigo FROM tmp_codigos);
         ELSE
            UPDATE temp_endoso
               SET seleccionado = 0
             WHERE seleccionado = 1
               AND cod_coasegur IN (SELECT codigo FROM tmp_codigos);
         END IF
         DROP TABLE tmp_codigos;
      END IF

	  IF a_reaseguro = "*" THEN
	     LET v_filtros = "Con Reaseguro Asumido";
      END IF

	  IF a_reaseguro <> "*" THEN
         LET v_filtros = TRIM(v_filtros) ||" Tipo de Produccion "||TRIM(a_reaseguro);
         LET _tipo     = sp_sis04(a_reaseguro); -- Separa los valores del String

         IF _tipo <> "E" THEN -- Incluir los Registros

			LET v_filtros = TRIM(v_filtros) || " Reaseguro Asumido: Solamente ";
            UPDATE temp_endoso
               SET seleccionado = 0
             WHERE seleccionado = 1
               AND tipo_produccion NOT IN(SELECT codigo FROM tmp_codigos);
         ELSE

            LET v_filtros = TRIM(v_filtros) || " Reaseguro Asumido: Excluido ";
			UPDATE temp_endoso
               SET seleccionado = 0
             WHERE seleccionado = 1
               AND tipo_produccion IN(SELECT codigo FROM tmp_codigos);
         END IF
		DROP TABLE tmp_codigos;
	END IF
		
      IF a_cod_cliente <> "*" THEN
         LET v_filtros = TRIM(v_filtros) ||"Cliente"||TRIM(a_cod_cliente);
         LET _tipo = sp_sis04(a_cod_cliente); -- Separa los valores del String

         IF _tipo <> "E" THEN -- Incluir los Registros

            UPDATE temp_endoso
               SET seleccionado = 0
             WHERE seleccionado = 1
               AND cod_contratante NOT IN(SELECT codigo FROM tmp_codigos);
         ELSE
            UPDATE temp_endoso
               SET seleccionado = 0
             WHERE seleccionado = 1
               AND cod_contratante IN(SELECT codigo FROM tmp_codigos);
         END IF
         DROP TABLE tmp_codigos;
      END IF

--Filtro de poliza
   IF a_no_documento <> "*" and a_no_documento <> "" THEN
         LET v_filtros = TRIM(v_filtros) ||"Documento: "||TRIM(a_no_documento);

            UPDATE temp_endoso
               SET seleccionado = 0
             WHERE seleccionado = 1
               AND no_documento <> a_no_documento;
   END IF
      
   IF a_fronting = 1 THEN
         LET v_filtros = TRIM(v_filtros) || " SOLO FRONTING ";

            UPDATE temp_endoso
               SET seleccionado = 0
             WHERE seleccionado = 1
               AND fronting    <> 1;
   END IF
      	        
   FOREACH
         SELECT x.no_poliza,
         		x.cod_sucursal,
         		x.cod_grupo,
         		x.cod_ramo,
                x.cod_contratante,
                x.cod_coasegur,
                x.no_documento,
                x.no_factura,
                x.fecha_emision,
                x.prima_suscrita,
                x.comision,
                x.impuesto,
				x.fronting
           INTO s_nopoliza,
                s_codsucursal,
                s_codgrupo,
                s_codramo,
                s_contratante,
                s_codasegur,
                v_documento,
                v_factura,
                v_fecha_emision,
                v_prima_suscrita,
                v_comision,
                v_impuesto,
				_fronting
           FROM temp_endoso x
          WHERE seleccionado = 1
          ORDER BY x.cod_coasegur,x.cod_ramo,x.no_factura

         SELECT emicoase.nombre
           INTO v_descrea
           FROM emicoase
          WHERE emicoase.cod_coasegur = s_codasegur;

         SELECT prdramo.nombre
           INTO v_descramo
           FROM prdramo
          WHERE prdramo.cod_ramo = s_codramo;

         SELECT cliclien.nombre
           INTO v_descclte
           FROM cliclien
          WHERE cliclien.cod_cliente = s_contratante;

         LET v_saldo = v_prima_suscrita - v_comision - v_impuesto;
		 
         RETURN v_descr_cia,
         		s_codasegur,
         		v_descrea,
         		s_codramo,
         		v_descramo,
                v_descclte,
                v_documento,
                v_factura,
                v_fecha_emision,
                v_prima_suscrita,
                v_comision,
                v_impuesto,
                v_saldo,
                a_periodo1,
                a_periodo2,
                v_filtros,
                _fronting  WITH RESUME;
      END FOREACH

   	DROP TABLE temp_endoso;
    DROP TABLE temp_det;
  END

END PROCEDURE;
