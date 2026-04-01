-- Detalle por Ramo Automovil(Canceladas) 
-- Creado:     agosto 2000 - Autor:  Yinia M. Zamora 
-- Modificado: 23/07/2001  - Autor: Marquelda Valdelamar (para incluir filtro de cliente)
--			   05/09/2001  -   							 filtro de poliza
--             13/09/2001  -        Amado Perez          filtro por Agente

DROP procedure sp_pro15;
CREATE procedure "informix".sp_pro15(a_cia CHAR(3),a_agencia CHAR(03),a_codsucursal CHAR(255) DEFAULT "*",a_codgrupo CHAR(255) DEFAULT "*",a_codramo CHAR(255) DEFAULT "*",a_periodo CHAR(7),a_periodo2 CHAR(7), a_cod_cliente CHAR(255) DEFAULT "*", a_no_documento CHAR(255) DEFAULT "*",a_agente CHAR(255) DEFAULT "*")
         RETURNING CHAR(50),CHAR(5),CHAR(50),CHAR(03),CHAR(50),CHAR(45),
                   CHAR(20),CHAR(10),DECIMAL(16,2),DECIMAL(16,2),DECIMAL(16,2),
                   CHAR(7),CHAR(100),CHAR(50);

 BEGIN
    DEFINE v_contratante,v_factura               						CHAR(10);
    DEFINE v_documento                           						CHAR(20);
    DEFINE v_codramo,v_codsucursal,cod_mov, _cod_tipocan       			CHAR(3);
    DEFINE v_codgrupo, _cod_agente                 						CHAR(5);
    DEFINE v_prima_suscrita,v_prima_retenida,v_reaseguro  				DECIMAL(16,2);
    DEFINE v_desc_cliente                        						CHAR(45);
    DEFINE v_desc_ramo,v_desc_grupo,v_descr_cia,v_tipo_cancelacion		CHAR(50);
	DEFINE v_corredor													CHAR(50);
    DEFINE v_filtros                             						CHAR(100);
    DEFINE _tipo                                 						CHAR(01);
	DEFINE _porc_partic_agt                                             DEC(5,2);
    DEFINE v_saber		     											CHAR(2);
    DEFINE v_codigo		     											CHAR(5);
	DEFINE _periodo                                                     CHAR(7);

    CREATE TEMP TABLE tmp_cancela
                (no_documento     CHAR(20),
                 cod_grupo        CHAR(05),
                 cod_ramo         CHAR(03),
                 cod_sucursal     CHAR(03),
                 cod_contratante  CHAR(10),
				 cod_agente       CHAR(5),
				 cod_tipocan      CHAR(03),
                 no_factura       CHAR(10),
                 prima_suscrita   DEC(16,2),
                 prima_retenida   DEC(16,2),
                 seleccionado     SMALLINT DEFAULT 1);

   CREATE INDEX i_cancela1 ON tmp_cancela(cod_grupo,cod_ramo,no_factura);
   CREATE INDEX i_cancela2 ON tmp_cancela(cod_sucursal);
   CREATE INDEX i_cancela3 ON tmp_cancela(cod_ramo);
   CREATE INDEX i_cancela4 ON tmp_cancela(cod_grupo);
--   CREATE INDEX i_cancela5 ON tmp_cancela(cod_contratante);

    LET v_prima_suscrita = 0;
    LET v_prima_retenida = 0;
    LET v_reaseguro      = 0;
    LET v_desc_cliente   = NULL;
    LET v_desc_ramo      = NULL;
    LET v_desc_grupo     = NULL;
    LET v_descr_cia      = NULL;
    LET v_filtros        = NULL;

    LET v_descr_cia = sp_sis01(a_cia);

    SET ISOLATION TO DIRTY READ;
    SELECT cod_endomov
           INTO cod_mov
           FROM endtimov
          WHERE tipo_mov = 2;

    FOREACH

       SELECT emipomae.no_documento,emipomae.cod_sucursal,emipomae.cod_grupo,
              emipomae.cod_ramo,emipomae.cod_contratante,endedmae.no_factura,
              endedmae.prima_suscrita,endedmae.prima_retenida,endedmae.cod_tipocan,
			  emipoagt.cod_agente,emipoagt.porc_partic_agt 
              INTO v_documento,v_codsucursal,v_codgrupo,v_codramo,v_contratante,
                   v_factura,v_prima_suscrita,v_prima_retenida,_cod_tipocan,
				   _cod_agente, _porc_partic_agt
              FROM emipomae,endedmae,emipoagt
             WHERE emipomae.cod_compania = a_cia
               AND emipomae.no_poliza    = endedmae.no_poliza
			   AND emipoagt.no_poliza    = emipomae.no_poliza
               AND endedmae.periodo     >= a_periodo
			   AND endedmae.periodo     <= a_periodo2
               AND endedmae.actualizado = 1
               AND endedmae.cod_endomov = cod_mov
            ORDER BY emipomae.cod_grupo,emipomae.cod_ramo,
                     emipomae.no_documento

       LET v_prima_suscrita = _porc_partic_agt * v_prima_suscrita / 100;
       LET v_prima_retenida = _porc_partic_agt * v_prima_retenida / 100;

       INSERT INTO tmp_cancela
                  VALUES(v_documento,
                         v_codgrupo,
                         v_codramo,
                         v_codsucursal,
                         v_contratante,
						 _cod_agente,
						 _cod_tipocan,
                         v_factura,
                         v_prima_suscrita,
                         v_prima_retenida,
                         1);

    END FOREACH
    -- Filtro de Agencia
      LET v_filtros = " ";
      IF a_codsucursal <> "*" THEN
         LET v_filtros = TRIM(v_filtros) ||"Sucursal "||TRIM(a_codsucursal);
         LET _tipo = sp_sis04(a_codsucursal); -- Separa los valores del String

         IF _tipo <> "E" THEN -- Incluir los Registros

            UPDATE tmp_cancela
                   SET seleccionado = 0
                 WHERE seleccionado = 1
                   AND cod_sucursal NOT IN(SELECT codigo FROM tmp_codigos);
         ELSE
            UPDATE tmp_cancela
                   SET seleccionado = 0
                 WHERE seleccionado = 1
                   AND cod_sucursal IN(SELECT codigo FROM tmp_codigos);
         END IF
         DROP TABLE tmp_codigos;
      END IF

      -- Filtro de Ramo
      IF a_codramo <> "*" THEN
         LET v_filtros = TRIM(v_filtros) ||"Ramo "||TRIM(a_codramo);
         LET _tipo = sp_sis04(a_codramo); -- Separa los valores del String

         IF _tipo <> "E" THEN -- Incluir los Registros

            UPDATE tmp_cancela
                   SET seleccionado = 0
                 WHERE seleccionado = 1
                   AND cod_ramo NOT IN(SELECT codigo FROM tmp_codigos);
         ELSE
            UPDATE tmp_cancela
                   SET seleccionado = 0
                 WHERE seleccionado = 1
                   AND cod_ramo IN(SELECT codigo FROM tmp_codigos);
         END IF
         DROP TABLE tmp_codigos;
      END IF
      -- Filtro de Grupo
      IF a_codgrupo <> "*" THEN
         LET v_filtros = TRIM(v_filtros) ||"Grupo "||TRIM(a_codgrupo);
         LET _tipo = sp_sis04(a_codgrupo); -- Separa los valores del String

         IF _tipo <> "E" THEN -- Incluir los Registros

            UPDATE tmp_cancela
                   SET seleccionado = 0
                 WHERE seleccionado = 1
                   AND cod_grupo NOT IN(SELECT codigo FROM tmp_codigos);
         ELSE
            UPDATE tmp_cancela
                   SET seleccionado = 0
                 WHERE seleccionado = 1
                   AND cod_grupo IN(SELECT codigo FROM tmp_codigos);
         END IF
         DROP TABLE tmp_codigos;
      END IF

--Filtro de Cliente
    IF a_cod_cliente <> "*" THEN
         LET v_filtros = TRIM(v_filtros) ||"Ramo "||TRIM(a_cod_cliente);
         LET _tipo = sp_sis04(a_cod_cliente); -- Separa los valores del String

         IF _tipo <> "E" THEN -- Incluir los Registros

            UPDATE tmp_cancela
                   SET seleccionado = 0
                 WHERE seleccionado = 1
                   AND cod_contratante NOT IN(SELECT codigo FROM tmp_codigos);
         ELSE
            UPDATE tmp_cancela
                   SET seleccionado = 0
                 WHERE seleccionado = 1
                   AND cod_contratante IN(SELECT codigo FROM tmp_codigos);
         END IF
         DROP TABLE tmp_codigos;
     END IF

--Filtro de poliza
   IF a_no_documento <> "*" and a_no_documento <> "" THEN
         LET v_filtros = TRIM(v_filtros) ||"Documento: "||TRIM(a_no_documento);

            UPDATE tmp_cancela
                   SET seleccionado = 0
                 WHERE seleccionado = 1
                   AND no_documento <> a_no_documento;
      END IF

--Filtro de Agente
	IF a_agente <> "*" THEN

		LET _tipo = sp_sis04(a_agente);  -- Separa los Valores del String en una tabla de codigos

	   	LET v_filtros = TRIM(v_filtros) || " Corredor: "; --||  TRIM(a_agente);


		IF _tipo <> "E" THEN -- Incluir los Registros

			UPDATE tmp_cancela
			   SET seleccionado = 0
			 WHERE seleccionado = 1
			   AND cod_agente NOT IN (SELECT codigo FROM tmp_codigos);
	       	   LET v_saber = "";

		ELSE		        -- Excluir estos Registros

			UPDATE tmp_cancela
			   SET seleccionado = 0
			 WHERE seleccionado = 1
			   AND cod_agente IN (SELECT codigo FROM tmp_codigos);
	           LET v_saber = " Ex";
		END IF

	    FOREACH
			SELECT agtagent.nombre,tmp_codigos.codigo
		      INTO v_corredor,v_codigo
		      FROM agtagent,tmp_codigos
		     WHERE agtagent.cod_agente = codigo
		     LET v_filtros = TRIM(v_filtros) || " " || TRIM(v_codigo) || " " || TRIM(v_corredor) || (v_saber);
	    END FOREACH

		DROP TABLE tmp_codigos;

	END IF


FOREACH
   SELECT x.no_documento,x.cod_grupo,x.cod_ramo,
          x.cod_contratante,x.no_factura,SUM(x.prima_suscrita),
          SUM(x.prima_retenida), x.cod_tipocan
   INTO v_documento,v_codgrupo,v_codramo,v_contratante,
        v_factura,v_prima_suscrita,v_prima_retenida,_cod_tipocan
   FROM tmp_cancela x
  WHERE seleccionado = 1
GROUP BY x.cod_tipocan,x.cod_grupo,x.cod_ramo,x.no_factura,x.no_documento,x.cod_contratante
--ORDER BY x.cod_tipocan,x.cod_grupo,x.cod_ramo,x.no_factura,x.no_documento,x.cod_contratante

       SELECT b.nombre
              INTO v_desc_cliente
              FROM cliclien b
             WHERE b.cod_cliente = v_contratante;

       SELECT nombre
              INTO v_desc_ramo
              FROM prdramo
             WHERE prdramo.cod_ramo = v_codramo;

       SELECT nombre
              INTO v_desc_grupo
              FROM cligrupo
             WHERE cod_grupo = v_codgrupo;

       SELECT nombre
	          INTO v_tipo_cancelacion
			  FROM endtican
			 WHERE cod_tipocan = _cod_tipocan;

	   SELECT periodo
	     INTO _periodo
		 FROM endedmae
		WHERE no_factura = v_factura;

       LET v_reaseguro = v_prima_suscrita - v_prima_retenida;

       RETURN v_descr_cia,v_codgrupo,v_desc_grupo,v_codramo,v_desc_ramo,
              v_desc_cliente,v_documento,v_factura,v_prima_suscrita,
              v_prima_retenida,v_reaseguro,_periodo,v_filtros,v_tipo_cancelacion
              WITH RESUME;

       LET v_prima_suscrita = 0;
       LET v_prima_retenida = 0;
       LET v_reaseguro      = 0;
      END FOREACH
   DROP TABLE tmp_cancela;
   END
END PROCEDURE;
