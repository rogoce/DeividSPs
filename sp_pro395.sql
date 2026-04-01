-- POLIZAS VIGENTES POR RAMO
--
-- Creado    : 08/10/2000 - Autor: Yinia Zamora

-- Modificado: 16/08/2001 - Marquelda Valdelamar (inclusion de filtro de cliente)
--			   05/09/2001                         inclusion de filtro de poliza
-- SIS v.2.0 - DEIVID, S.A.

   DROP procedure sp_pro395;
   CREATE procedure "informix".sp_pro395(a_cia CHAR(03),a_agencia CHAR(3),a_fecha DATE,a_codsucursal CHAR(255) DEFAULT "*",a_codramo CHAR(255) DEFAULT "*",a_codgrupo CHAR(255) DEFAULT "*",a_agente CHAR(255) DEFAULT "*",a_usuario CHAR(255) DEFAULT "*", a_cod_cliente CHAR(255) DEFAULT "*", a_acreedor CHAR(255) DEFAULT "*", a_no_documento CHAR(255) DEFAULT "*")

   RETURNING CHAR(3),CHAR(50),CHAR(20),CHAR(45),CHAR(10),DATE,DATE,DECIMAL(16,2),VARCHAR(50);


    DEFINE v_cod_ramo,v_cod_sucursal  			 CHAR(3);
    DEFINE v_saber					  			 CHAR(2);
    DEFINE v_cod_grupo,_cod_acreedor,_limite	 CHAR(5);
    DEFINE v_contratante,v_codigo,_temp_poliza	 CHAR(10);
    DEFINE v_asegurado                			 CHAR(45);
    DEFINE v_desc_ramo,v_descr_cia,v_desc_agente CHAR(50);
    DEFINE v_desc_grupo               			 CHAR(40);
    DEFINE no_documento               			 CHAR(20);
    DEFINE v_vigencia_inic,v_vigencia_final   	 DATE;
    DEFINE v_cant_polizas             			 INTEGER;
    DEFINE v_prima_suscrita,v_suma_asegurada   	 DECIMAL(16,2);
    DEFINE _tipo              					 CHAR(1);
    DEFINE v_filtros          					 CHAR(255);
	DEFINE _no_poliza							 CHAR(10);
	DEFINE _cant                                 SMALLINT;
    DEFINE _cod_cobertura                        char(5);
	DEFINE _desc_cobertura                       VARCHAR(50);

    LET v_cod_ramo       = NULL;
    LET v_cod_sucursal   = NULL;
    LET v_cod_grupo      = NULL;
    LET v_contratante    = NULL;
    LET no_documento     = NULL;
    LET v_desc_ramo      = NULL;
    LET v_descr_cia      = NULL;
    LET v_cant_polizas   = 0;
    LET v_prima_suscrita = 0;
    LET _tipo            = NULL;

    SET ISOLATION TO DIRTY READ;

    LET v_descr_cia = sp_sis01(a_cia);
    CALL sp_pro03(a_cia,a_agencia,a_fecha,a_codramo) RETURNING v_filtros;

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

    IF a_codgrupo <> "*" THEN
         LET v_filtros = TRIM(v_filtros) ||"Grupo "||TRIM(a_codgrupo);
         LET _tipo = sp_sis04(a_codgrupo); -- Separa los valores del String

         IF _tipo <> "E" THEN -- Incluir los Registros

            UPDATE temp_perfil
                   SET seleccionado = 0
                 WHERE seleccionado = 1
                   AND cod_grupo NOT IN(SELECT codigo FROM tmp_codigos);
         ELSE
            UPDATE temp_perfil
                   SET seleccionado = 0
                 WHERE seleccionado = 1
                   AND cod_grupo IN(SELECT codigo FROM tmp_codigos);
         END IF
         DROP TABLE tmp_codigos;
    END IF

    IF a_agente <> "*" THEN
         LET v_filtros = TRIM(v_filtros) ||"Corredor: "; --||TRIM(a_agente);
         LET _tipo = sp_sis04(a_agente); -- Separa los valores del String

         IF _tipo <> "E" THEN -- Incluir los Registros

            UPDATE temp_perfil
                   SET seleccionado = 0
                 WHERE seleccionado = 1
                   AND cod_agente NOT IN(SELECT codigo FROM tmp_codigos);
			       LET v_saber = "";
         ELSE
            UPDATE temp_perfil
                   SET seleccionado = 0
                 WHERE seleccionado = 1
                   AND cod_agente IN(SELECT codigo FROM tmp_codigos);
			       LET v_saber = " Ex";
         END IF
		 FOREACH
			SELECT agtagent.nombre,tmp_codigos.codigo
	          INTO v_desc_agente,v_codigo
	          FROM agtagent,tmp_codigos
	         WHERE agtagent.cod_agente = codigo
	         LET v_filtros = TRIM(v_filtros) || " " || TRIM(v_codigo) || " " || TRIM(v_desc_agente) || TRIM(v_saber);
		 END FOREACH

         DROP TABLE tmp_codigos;
    END IF

    IF a_usuario <> "*" THEN
         LET v_filtros = TRIM(v_filtros) ||"Corredor: "||TRIM(a_usuario);
         LET _tipo = sp_sis04(a_usuario); -- Separa los valores del String

         IF _tipo <> "E" THEN -- Incluir los Registros

            UPDATE temp_perfil
                   SET seleccionado = 0
                 WHERE seleccionado = 1
                   AND usuario NOT IN(SELECT codigo FROM tmp_codigos);
         ELSE
            UPDATE temp_perfil
                   SET seleccionado = 0
                 WHERE seleccionado = 1
                   AND usuario IN(SELECT codigo FROM tmp_codigos);
         END IF
         DROP TABLE tmp_codigos;
    END IF

    IF a_cod_cliente <> "*" THEN
         LET v_filtros = TRIM(v_filtros) ||"Cliente: "||TRIM(a_cod_cliente);
         LET _tipo = sp_sis04(a_cod_cliente); -- Separa los valores del String

         IF _tipo <> "E" THEN -- Incluir los Registros

            UPDATE temp_perfil
                   SET seleccionado = 0
                 WHERE seleccionado = 1
                   AND cod_contratante NOT IN(SELECT codigo FROM tmp_codigos);
         ELSE
            UPDATE temp_perfil
                   SET seleccionado = 0
                 WHERE seleccionado = 1
                   AND cod_contratante IN(SELECT codigo FROM tmp_codigos);
         END IF
         DROP TABLE tmp_codigos;
    END IF

--Filtro de poliza
   IF a_no_documento <> "*" and a_no_documento <> "" THEN
         LET v_filtros = TRIM(v_filtros) ||"Documento: "||TRIM(a_no_documento);

            UPDATE temp_perfil
                   SET seleccionado = 0
                 WHERE seleccionado = 1
                   AND no_documento <> a_no_documento;
      END IF

    IF a_acreedor <> "*" THEN

		 CREATE TEMP TABLE tmp_acreedor
			   (cod_acreedor CHAR(5),
			    no_poliza    CHAR(10),
				limite       DEC(16,2),
				seleccionado SMALLINT DEFAULT 1)
              WITH NO LOG;

		 FOREACH
		 	SELECT no_poliza 
			  INTO _temp_poliza
			  FROM temp_perfil
			 WHERE seleccionado = 1
			FOREACH
				SELECT cod_acreedor, limite
				  INTO _cod_acreedor, _limite
				  FROM emipoacr
				 WHERE no_poliza = _temp_poliza

				INSERT INTO tmp_acreedor
				     VALUES(_cod_acreedor,
					        _temp_poliza,
							_limite,
							1);
			END FOREACH
		 END FOREACH

         LET v_filtros = TRIM(v_filtros) ||"Acreedor: "||TRIM(a_acreedor);
         LET _tipo = sp_sis04(a_acreedor); -- Separa los valores del String

         IF _tipo <> "E" THEN -- Incluir los Registros

            UPDATE tmp_acreedor
                   SET seleccionado = 0
                 WHERE seleccionado = 1
                   AND cod_acreedor NOT IN(SELECT codigo FROM tmp_codigos);
         ELSE
            UPDATE tmp_acreedor
                   SET seleccionado = 0
                 WHERE seleccionado = 1
                   AND cod_acreedor IN(SELECT codigo FROM tmp_codigos);
         END IF

         UPDATE temp_perfil
               SET seleccionado = 0
             WHERE seleccionado = 1
               AND no_poliza NOT IN(SELECT no_poliza FROM tmp_acreedor WHERE seleccionado = 1);

         DROP TABLE tmp_codigos;
         DROP TABLE tmp_acreedor;
    END IF

    IF a_codramo <> "*" THEN
         LET v_filtros = TRIM(v_filtros) ||"Ramo: "||TRIM(a_codramo);
    END IF


	SET ISOLATION TO DIRTY READ;
    FOREACH WITH HOLD

       SELECT y.no_documento,y.cod_ramo,y.cod_contratante,y.vigencia_inic,
              y.vigencia_final,y.cod_grupo,y.suma_asegurada,y.prima_suscrita,y.no_poliza
         INTO no_documento,v_cod_ramo,v_contratante,v_vigencia_inic,
              v_vigencia_final,v_cod_grupo,v_suma_asegurada,
              v_prima_suscrita, _no_poliza
         FROM temp_perfil y
        WHERE y.seleccionado = 1
	 GROUP BY y.cod_ramo,y.no_documento,y.cod_contratante,y.vigencia_inic,
              y.vigencia_final,y.cod_grupo,y.suma_asegurada,y.prima_suscrita,y.no_poliza
     ORDER BY y.cod_ramo,y.no_documento

          LET _cant = 0;

       SELECT COUNT(*)
	     INTO _cant
		 FROM emipocob
		WHERE no_poliza = _no_poliza
		  AND cod_cobertura in('00225','00885');

       IF _cant = 0 THEN
			CONTINUE FOREACH;
	   END IF

       FOREACH
	   	SELECT cod_cobertura
		  INTO _cod_cobertura
		  FROM emipocob
		 WHERE no_poliza = _no_poliza
		   AND cod_cobertura in('00225','00885')

        SELECT nombre
	      INTO _desc_cobertura
		  FROM prdcober
		 WHERE cod_cobertura = _cod_cobertura;

		 IF _cod_cobertura = '00225' OR _cod_cobertura = '00885' THEN
		 	EXIT FOREACH;
		 END IF

	   END FOREACH



       SELECT a.nombre
         INTO v_desc_ramo
         FROM prdramo a
        WHERE a.cod_ramo  = v_cod_ramo;

       SELECT nombre
         INTO v_asegurado
         FROM cliclien
        WHERE cod_cliente = v_contratante;

       SELECT nombre
         INTO v_desc_grupo
         FROM cligrupo
        WHERE cod_grupo = v_cod_grupo;

  --     RETURN v_cod_ramo,v_desc_ramo,no_documento,
  --            v_asegurado,v_vigencia_inic,v_vigencia_final,
  --            v_desc_grupo,v_suma_asegurada,v_prima_suscrita,
  --            v_filtros,v_descr_cia WITH RESUME;

       RETURN v_cod_ramo,v_desc_ramo,no_documento,
              v_asegurado,v_contratante,v_vigencia_inic,v_vigencia_final,
              v_prima_suscrita,_desc_cobertura WITH RESUME;
    END FOREACH
DROP TABLE temp_perfil;

END PROCEDURE;
