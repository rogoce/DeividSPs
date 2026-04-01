-- REPORTE DE POLIZAS - CARTERA VIGENTE POR CORREDOR - (SOLICITUD DE LOS REASEGURADORES)
-- BALANCEAR LA CARTERA DE INCENDIO 
-- Creado    : 19/08/2011      -- Autor: Henry Giron 
-- Execute Procedure sp_pro4938("001","001",'24/08/2011',"*","001;","*","00141;","*","*","*","*")
DROP procedure sp_pro4938;
CREATE procedure "informix".sp_pro4938(a_cia CHAR(03),a_agencia CHAR(3),a_fecha DATE,a_codsucursal CHAR(255) DEFAULT "*",a_codramo CHAR(255) DEFAULT "*",a_codgrupo CHAR(255) DEFAULT "*",a_agente CHAR(255) DEFAULT "*",a_usuario CHAR(255) DEFAULT "*", a_cod_cliente CHAR(255) DEFAULT "*", a_acreedor CHAR(255) DEFAULT "*", a_no_documento CHAR(255) DEFAULT "*")
RETURNING CHAR(3),CHAR(50),CHAR(20),CHAR(45),DATE,DATE, CHAR(40),DECIMAL(16,2),DECIMAL(16,2),CHAR(255),CHAR(50),CHAR(10),CHAR(5),CHAR(50),CHAR(50),CHAR(50), CHAR(5),DECIMAL(16,2),DECIMAL(16,2),INTEGER,CHAR(50);
		  --	NO POLIZA
		  --	ASEGURADO
		  --	UBICACION
		  --	VIGENCIA
		  --	TIPO ASEGURADO (CONTENIDO,EDIFICIO,LUCRO,ETC)
		  --	SUMA ASEGURADA Y PRIMA
		  --	UBICACION POR UNIDAD DE LA POLIZA:
		  --		1-Z.L. Y F.F.
		  --		2-RESTO DE LA REPUBLICA
		  --	QUE TOTALICE POR UBICACIÓN LA S/A Y LA PRIMA

    DEFINE v_cod_ramo,v_cod_sucursal  			 CHAR(3);
    DEFINE v_saber					  			 CHAR(2);
    DEFINE v_cod_grupo,_cod_acreedor,_limite	 CHAR(5);
    DEFINE v_contratante,v_codigo,_temp_poliza	 CHAR(10);
    DEFINE v_asegurado                			 CHAR(45);
    DEFINE v_desc_ramo,v_descr_cia,v_desc_agente CHAR(50);
    DEFINE v_desc_grupo               			 CHAR(40);
    DEFINE v_no_documento             			 CHAR(20);
    DEFINE v_vigencia_inic,v_vigencia_final   	 DATE;
    DEFINE v_cant_polizas             			 INTEGER;
    DEFINE v_prima_suscrita,v_suma_asegurada   	 DECIMAL(16,2);
    DEFINE _tipo              					 CHAR(1);
    DEFINE v_filtros          					 CHAR(255);
	DEFINE v_no_poliza							 CHAR(10);
    DEFINE _cod_agente                           CHAR(5); 
    DEFINE _nombre_agente                        CHAR(50); 
    DEFINE u_no_unidad                           CHAR(5);
    DEFINE u_suma_asegurada  					 DECIMAL(16,2);
	DEFINE u_prima_suscrita					     DECIMAL(16,2);
    DEFINE u_tipo_incendio                       INTEGER;
    DEFINE u_cod_manzana                         CHAR(15); 
    DEFINE u_tipo_asegurado                      CHAR(50); 
    DEFINE u_referencia                          CHAR(50); 
    DEFINE u_zona_libre                          INTEGER;
	DEFINE _cod_ubica                            CHAR(3);
    DEFINE v_ubicacion                           CHAR(50); 
	DEFINE v_porc_ubicacion					     DECIMAL(9,4);

---   v_filtros, v_descr_cia CHAR(255), CHAR(50)          
CREATE TEMP TABLE tmp_vigentes
    ( cod_ramo		   	CHAR(3),		 
	  desc_ramo		   	CHAR(50),		 
	  no_documento	   	CHAR(20),		 
	  asegurado		   	CHAR(45),		 
	  vigencia_inic	   	DATE,			 
	  vigencia_final   	DATE,			 
	  desc_grupo	   	CHAR(40),		 
	  suma_asegurada   	DEC(16,2),		 
	  prima_suscrita   	DEC(16,2),		 
	  filtros		   	CHAR(255),		 
	  descr_cia		   	CHAR(50),		 
	  no_poliza        	CHAR(10),		 
	  cod_agente       	CHAR(5),		 
	  nombre_agente    	CHAR(50),		 
	  referencia	   	CHAR(50),		 
	  tipo_asegurado   	CHAR(50),		 
	  no_unidad        	CHAR(5),		 
	  usuma_asegurada    DEC(16,2),		 
	  uprima_suscrita    DEC(16,2),		 
	  zona_libre        INTEGER,
	  ubicacion			CHAR(50),
      PRIMARY KEY (no_poliza,no_unidad)         
     )WITH NO LOG;

CREATE INDEX idx1_tmp_vigentes ON tmp_vigentes(no_poliza);
CREATE INDEX idx2_tmp_vigentes ON tmp_vigentes(no_unidad);


    LET v_cod_ramo       = NULL;
    LET v_cod_sucursal   = NULL;
    LET v_cod_grupo      = NULL;
    LET v_contratante    = NULL;
    LET v_no_documento   = NULL;
    LET v_desc_ramo      = NULL;
    LET v_descr_cia      = NULL;
    LET v_cant_polizas   = 0;
    LET v_prima_suscrita = 0;
    LET _tipo            = NULL;
	LET u_tipo_asegurado  = '';
	LET u_referencia      = '';
	LET u_zona_libre      = 0;
	LET v_porc_ubicacion  = 0;
	LET v_ubicacion       = '';

    SET ISOLATION TO DIRTY READ;
--    SET DEBUG FILE TO "sp_pro4938.trc";
--    TRACE ON;

    LET v_descr_cia = sp_sis01(a_cia);
    CALL sp_pro03(a_cia,a_agencia,a_fecha,a_codramo) RETURNING v_filtros;

    IF a_codsucursal <> "*" THEN
         LET v_filtros = TRIM(v_filtros) ||"Sucursal "||TRIM(a_codsucursal);
         LET _tipo = sp_sis04(a_codsucursal); -- Separa los valores del String

         IF _tipo <> "E" THEN       -- Incluir los Registros

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
         LET v_filtros = TRIM(v_filtros) ||"Corredor: "; --  ||TRIM(a_agente);
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

    FOREACH 
       SELECT y.no_documento,y.cod_ramo,y.cod_contratante,y.vigencia_inic,y.vigencia_final,y.cod_grupo,y.suma_asegurada,y.prima_suscrita,y.no_poliza
         INTO v_no_documento,v_cod_ramo,v_contratante,v_vigencia_inic,v_vigencia_final,v_cod_grupo,v_suma_asegurada,v_prima_suscrita,v_no_poliza
         FROM temp_perfil y
        WHERE y.seleccionado = 1 -- and y.no_poliza = '405212'
     ORDER BY y.cod_ramo,y.no_documento

		FOREACH
		SELECT cod_agente	 
		  INTO _cod_agente	 
		  FROM emipoagt	 
		 WHERE no_poliza = v_no_poliza	 

		SELECT nombre	 
		  INTO _nombre_agente	 
		  FROM agtagent	 
		 WHERE cod_agente = _cod_agente;	 

		  EXIT FOREACH;
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

           LET u_suma_asegurada = 0;
           LET u_prima_suscrita = 0;				 

       FOREACH 
          SELECT no_unidad,
          		 suma_asegurada,
				 prima_suscrita,
				 tipo_incendio,
				 cod_manzana
            INTO u_no_unidad,
            	 u_suma_asegurada,
				 u_prima_suscrita,
				 u_tipo_incendio,
				 u_cod_manzana
            FROM emipouni
           WHERE no_poliza = v_no_poliza

			 LET u_referencia      = '';
			 LET u_tipo_asegurado  = 'etc';

			  IF u_tipo_incendio = 1 THEN
				 LET u_tipo_asegurado  = 'Edificio';
			 END IF

			  IF u_tipo_incendio = 2 THEN
				 LET u_tipo_asegurado  = 'Contenido';
			 END IF

			  IF u_tipo_incendio = 3 THEN
				 LET u_tipo_asegurado  = 'Lucro Cesante';
			 END IF

	       	SELECT referencia
	       	  INTO u_referencia 
	       	  FROM emiman05 
	       	 WHERE cod_manzana = u_cod_manzana; 
			  
			  IF u_referencia is null THEN
				 LET u_referencia  = '';
			 END IF
			  IF u_cod_manzana[1,12] in ('030010020103','030010064400') THEN
				 LET u_zona_libre = 1;
			 ELSE
				 LET u_zona_libre = 0;
			 END IF

			FOREACH
			 SELECT	cod_ubica 
			   INTO _cod_ubica 
			   FROM	endcuend
			  WHERE no_poliza = v_no_poliza
				AND no_unidad = u_no_unidad

			 SELECT nombre
			   INTO v_ubicacion
			   FROM emiubica
			  WHERE cod_ubica = _cod_ubica;

			  EXIT FOREACH;
			   END FOREACH

--			BEGIN
--	   			ON EXCEPTION IN(-239)
--				END EXCEPTION

				INSERT INTO tmp_vigentes
	 					 ( cod_ramo,
						   desc_ramo,
						   no_documento,
						   asegurado,
				   		   vigencia_inic,
						   vigencia_final,
				           desc_grupo,
						   suma_asegurada,
						   prima_suscrita,
						   filtros,
						   descr_cia,
						   no_poliza,
						   cod_agente,
						   nombre_agente,
						   referencia,
						   tipo_asegurado,
						   no_unidad,
						   usuma_asegurada,
						   uprima_suscrita,
						   zona_libre,
						   ubicacion	 )
				   VALUES( v_cod_ramo,				 
						   v_desc_ramo,				 
						   v_no_documento,			 
						   v_asegurado,				 
				   		   v_vigencia_inic,			 
						   v_vigencia_final,		 
				           v_desc_grupo,			 
						   v_suma_asegurada,		 
						   v_prima_suscrita,		 
						   v_filtros,				 
						   v_descr_cia,				 
						   v_no_poliza, 			 
						   _cod_agente,				 
						   _nombre_agente,			 
						   u_referencia,			 
						   u_tipo_asegurado,		 
						   u_no_unidad,				 
						   u_suma_asegurada,		 
						   u_prima_suscrita,
						   u_zona_libre,
						   v_ubicacion   );	 
  --			END			   
	    END FOREACH

    END FOREACH
    SET ISOLATION TO DIRTY READ;

    FOREACH 
       SELECT cod_ramo,
			  desc_ramo,
			  no_documento,
			  asegurado,
			  vigencia_inic,
			  vigencia_final,
			  desc_grupo,
			  suma_asegurada,
			  prima_suscrita,
			  filtros,
			  descr_cia,
			  no_poliza,
			  cod_agente,
			  nombre_agente,
			  referencia,
			  tipo_asegurado,
			  no_unidad,
			  usuma_asegurada,
			  uprima_suscrita,
			  zona_libre,
			  ubicacion	
         INTO v_cod_ramo,
			  v_desc_ramo,
			  v_no_documento,
			  v_asegurado,
			  v_vigencia_inic,
			  v_vigencia_final,
			  v_desc_grupo,
			  v_suma_asegurada,
			  v_prima_suscrita,
			  v_filtros,
			  v_descr_cia,
			  v_no_poliza,
			  _cod_agente,
			  _nombre_agente,
			  u_referencia,
			  u_tipo_asegurado,
			  u_no_unidad,
			  u_suma_asegurada,
			  u_prima_suscrita,
			  u_zona_libre,
			  v_ubicacion
         FROM tmp_vigentes 
     ORDER BY nombre_agente,cod_ramo,zona_libre,no_documento,no_unidad

       RETURN v_cod_ramo,
              v_desc_ramo,
              v_no_documento,
              v_asegurado,
              v_vigencia_inic,
              v_vigencia_final,
              v_desc_grupo,
              v_suma_asegurada,
              v_prima_suscrita,
              v_filtros,
              v_descr_cia,
              v_no_poliza,
              _cod_agente,
              _nombre_agente,
              u_referencia,
              u_tipo_asegurado,
              u_no_unidad,
              u_suma_asegurada,
              u_prima_suscrita,
              u_zona_libre,
              v_ubicacion  
              WITH RESUME;  
												 
    END FOREACH


DROP TABLE temp_perfil;
DROP TABLE tmp_vigentes;
END PROCEDURE;

  