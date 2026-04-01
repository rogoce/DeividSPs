--  Polizas Vigentes por Subramo

--  Creado    : 08/2000    - Autor: Yinia M. Zamora 
--  Modificado:	22/08/2001 - Autor: Marquelda Valdelamar (inclusion del filtro de cliente)
-- SIS v.2.0 - DEIVID, S.A.


DROP procedure sp_proe27;
CREATE PROCEDURE sp_proe27(a_cia CHAR(3),a_agencia CHAR(3),a_codsucursal CHAR(255) DEFAULT "*",a_corredor char(255) DEFAULT "*",a_codramo CHAR(255) DEFAULT "*",a_subramo CHAR(255) DEFAULT "*",a_periodo1 DATE, a_cod_cliente CHAR(255) DEFAULT "*", a_no_documento CHAR(255) DEFAULT "*") 
     RETURNING CHAR(50),
     		   CHAR(50),
     		   CHAR(03),
     		   CHAR(50),
     		   CHAR(03),
     		   CHAR(50),
               CHAR(45),
               CHAR(20),
               DATE,
               DATE,
               DATE,
               DECIMAL(16,2),
               DATE,
               CHAR(255),
               DATE,
               INTEGER,
               INTEGER;
 BEGIN

    DEFINE v_nopoliza,v_contratante         CHAR(10);
    DEFINE v_documento                      CHAR(20);
    DEFINE v_codramo,v_codsubramo,_cod_perpago           CHAR(3);
    DEFINE v_fecha_suscripc,v_vigencia_inic,v_vigencia_final,_fecha_aniversario,_fecha_hoy DATE;
    DEFINE v_prima_suscrita                 DECIMAL(16,2);
    DEFINE v_codagente, _no_endoso          CHAR(5);
    DEFINE v_desc_cliente                   CHAR(45);
    DEFINE v_filtros                        CHAR(255);
    DEFINE _tipo                            CHAR(01);
    DEFINE v_desc_ramo,v_desc_subr,v_desc_agente,v_descr_cia  CHAR(50);
	DEFINE _dependientes,_edad INTEGER;
	define _meses,_valor		smallint;

	LET _fecha_hoy = TODAY;
    LET v_prima_suscrita = 0;
    LET _dependientes    = 0;
    LET _edad		     = 0;
    LET v_desc_cliente   = NULL;
    LET v_desc_agente    = NULL;
    LET v_desc_subr      = NULL;
    LET v_descr_cia      = NULL;
    LET v_filtros        = NULL;

    LET v_descr_cia = sp_sis01(a_cia);
    CALL sp_pro03(a_cia,a_agencia,a_periodo1,a_codramo)
                  RETURNING v_filtros;

    -- Filtro de Sucursal
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
    -- Filtro de Subramo
    IF a_subramo <> "*" THEN
         LET v_filtros = TRIM(v_filtros) ||"Subramo "||TRIM(a_subramo);
         LET _tipo = sp_sis04(a_subramo); -- Separa los valores del String

         IF _tipo <> "E" THEN -- Incluir los Registros

            UPDATE temp_perfil
                   SET seleccionado = 0
                 WHERE seleccionado = 1
                   AND cod_subramo NOT IN(SELECT codigo FROM tmp_codigos);
         ELSE
            UPDATE temp_perfil
                   SET seleccionado = 0
                 WHERE seleccionado = 1
                   AND cod_subramo IN(SELECT codigo FROM tmp_codigos);
         END IF
         DROP TABLE tmp_codigos;
    END IF
    IF a_corredor <> "*" THEN
         LET v_filtros = TRIM(v_filtros) ||"Corredor"||TRIM(a_corredor);
         LET _tipo = sp_sis04(a_corredor); -- Separa los valores del String

         IF _tipo <> "E" THEN -- Incluir los Registros

            UPDATE temp_perfil
                   SET seleccionado = 0
                 WHERE seleccionado = 1
                   AND cod_agente NOT IN(SELECT codigo FROM tmp_codigos);
         ELSE
            UPDATE temp_perfil
                   SET seleccionado = 0
                 WHERE seleccionado = 1
                   AND cod_agente IN(SELECT codigo FROM tmp_codigos);
         END IF
         DROP TABLE tmp_codigos;
    END IF

    IF a_cod_cliente <> "*" THEN
         LET v_filtros = TRIM(v_filtros) ||"Corredor"||TRIM(a_cod_cliente);
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

    SET ISOLATION TO DIRTY READ;
    FOREACH
        SELECT y.no_poliza,
       		   y.no_documento,
       		   y.cod_ramo,
       		   y.cod_subramo,
               y.cod_contratante,
               y.fecha_suscripcion,
               y.vigencia_inic,
               y.vigencia_final,
               y.prima_suscrita,
               y.cod_agente
          INTO v_nopoliza,
         	   v_documento,
         	   v_codramo,
         	   v_codsubramo,
               v_contratante,
               v_fecha_suscripc,
               v_vigencia_inic,
               v_vigencia_final,
               v_prima_suscrita,
               v_codagente
          FROM temp_perfil y
         WHERE seleccionado = 1
           
        SELECT a.nombre
          INTO v_desc_agente
          FROM agtagent a
         WHERE a.cod_agente = v_codagente;

        SELECT nombre,
			   fecha_aniversario	
          INTO v_desc_cliente,
		 	   _fecha_aniversario
          FROM cliclien
         WHERE cod_cliente = v_contratante;

		If Month( _fecha_aniversario ) <= Month(_fecha_hoy) THEN
		     If Month( _fecha_aniversario ) = Month(_fecha_hoy) THEN
		          If Day(_fecha_aniversario ) <= Day(_fecha_hoy) THEN
		             LET _edad = year(_fecha_hoy) - year( _fecha_aniversario );
		          Else
		             LET _edad = (year(_fecha_hoy) - year( _fecha_aniversario )) - 1;
				  End If
			 Else
				 LET _edad = (year(_fecha_hoy) - year(_fecha_aniversario));
			 End If
		Else
			LET _edad = (year(_fecha_hoy) - year(_fecha_aniversario)) - 1;
		End If

		select cod_perpago,
		       prima_neta
		  into _cod_perpago,
		       v_prima_suscrita
		  from emipomae
		 where no_poliza = v_nopoliza;
		 
		{SELECT SUM(prima_asegurado)	se pone en comentario por caso de jean 12/06/2024
		  INTO v_prima_suscrita
		  FROM emipouni
		 WHERE no_poliza = v_nopoliza;}

		SELECT nombre
		  INTO v_desc_ramo
		  FROM prdramo
		 WHERE prdramo.cod_ramo = v_codramo;

		SELECT nombre
		  INTO v_desc_subr
		  FROM prdsubra
		 WHERE cod_ramo    = v_codramo
		   AND cod_subramo = v_codsubramo;

		SELECT COUNT(*)
		  INTO _dependientes
		  FROM emidepen
		 WHERE no_poliza = v_nopoliza
		   AND activo = 1;

		IF _dependientes IS NULL THEN
			LET _dependientes = 0;
		END IF
		
		--Anualizar la prima de salud
		if v_codramo = '018' THEN
			select meses
			  into _meses
			  from cobperpa
			 where cod_perpago = _cod_perpago;

			let _valor = 0;

			if _cod_perpago = '001' then
				let _meses = 1;
			end if

			if _cod_perpago = '008' or _cod_perpago = '006' then	--Es anual o inmediata, ya esta el 100% de la prima
				let _meses = 12;
			end if

			let _valor = 12 / _meses;
			let v_prima_suscrita = v_prima_suscrita * _valor;
		end IF	

        RETURN v_descr_cia,v_desc_agente,v_codramo,v_desc_ramo,
                v_codsubramo,v_desc_subr,v_desc_cliente,v_documento,
                v_fecha_suscripc,v_vigencia_inic,v_vigencia_final,
                v_prima_suscrita,a_periodo1,v_filtros,_fecha_aniversario,_dependientes,_edad
                 WITH RESUME;

		LET v_prima_suscrita = 0;
    END FOREACH
    DROP TABLE temp_perfil;
END
END PROCEDURE;