--  LOSS BORDERAUX RAMO SALUD

--  Creado:	23/10/2002 - Autor: Armando Moreno M.
--  SIS v.2.0 - DEIVID, S.A.


DROP procedure sp_proe32;
CREATE PROCEDURE sp_proe32(a_cia CHAR(3),a_agencia CHAR(3),a_codsucursal CHAR(255) DEFAULT "*",a_corredor char(255) DEFAULT "*",a_codramo CHAR(255) DEFAULT "*",a_subramo CHAR(255) DEFAULT "*",a_periodo1 DATE, a_cod_cliente CHAR(255) DEFAULT "*", a_no_documento CHAR(255) DEFAULT "*") 
     RETURNING CHAR(50),   --cia
     		   CHAR(03),   --codramo
     		   CHAR(50),   --desc ramo
     		   CHAR(03),   --codsubramo
     		   CHAR(50),   --desc subramo
               CHAR(100),  --contratante/asegurado
               CHAR(20),      --poliza
               DATE,	      --vigfini
               CHAR(255),     --vfiltros
               INTEGER,	      --dependientes
               DECIMAL(16,2), --primaxl
               DECIMAL(16,2), --primaxla
               DECIMAL(16,2), --primaxlb
               DECIMAL(16,2), --primaxlc
			   CHAR(1),	      --tipo suscr.
               CHAR(100),	  --contratante
               INTEGER,		  --colectivo si o no
               CHAR(5),		  --nounidad
               INTEGER,
               INTEGER,		  
			   INTEGER,
			   date,
			   dec(16,2);

BEGIN

    DEFINE v_nopoliza,v_contratante,_cod_asegurado         CHAR(10);
    DEFINE v_documento                      CHAR(20);
    DEFINE v_codramo,v_codsubramo           CHAR(3);
    DEFINE v_fecha_suscripc,v_vigencia_inic,v_vigencia_final,_fecha_aniversario,_fecha_hoy DATE;
    DEFINE _prima_xl, _prima_xla, _prima_xlb, _prima_xlc  DECIMAL(16,2);
    DEFINE v_codagente,_cod_producto,_no_unidad        CHAR(5);
    DEFINE v_filtros                        CHAR(255);
    DEFINE _tipo,_tipo_suscripcion,_tipo_sus    CHAR(1);
    DEFINE v_desc_asegurado,v_desc_cliente,_contratante  CHAR(100);
    DEFINE v_desc_ramo,v_desc_subr,v_desc_agente,v_descr_cia  CHAR(50);
	DEFINE _dependientes,_edad,_colectivo,_a,_b,_c INTEGER;
	DEFINE _mes_contable      CHAR(2);
	DEFINE _ano_contable      CHAR(4);
	DEFINE _periodo, _periodo_priex CHAR(7);
	define _fecha_nac			date;
	define _prima_bruta			dec(16,2);

	   CREATE TEMP TABLE temp_prod
             (no_poliza      	CHAR(10),
              no_documento   	CHAR(20),
              cod_producto     	CHAR(5),
              cod_ramo       	CHAR(3),
              cod_subramo    	CHAR(3),
              cod_contratante   CHAR(10),
              vigencia_inic     DATE,
              cod_asegurado     CHAR(10),
			  no_unidad         CHAR(5),
              colectivo         SMALLINT DEFAULT 0,
              fecha_nac			date,
              prima_bruta		dec(16,2))
              WITH NO LOG;

SET ISOLATION TO DIRTY READ;

	LET _fecha_hoy = TODAY;
    LET _dependientes    = 0;
    LET _edad		     = 0;
    LET v_desc_cliente   = NULL;
    LET v_desc_asegurado = NULL;
    LET v_desc_agente    = NULL;
    LET v_desc_subr      = NULL;
    LET v_descr_cia      = NULL;
    LET v_filtros        = NULL;

	LET _ano_contable = YEAR(a_periodo1);

	IF MONTH(a_periodo1) < 10 THEN
		LET _mes_contable = '0' || MONTH(a_periodo1);
	ELSE
		LET _mes_contable = MONTH(a_periodo1);
	END IF

	LET _periodo = _ano_contable || '-' || _mes_contable;


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

FOREACH
       SELECT no_poliza,
       		  no_documento,
       		  cod_ramo,
       		  cod_subramo,
              cod_contratante,
              fecha_suscripcion,
              vigencia_inic,
              vigencia_final,
              cod_agente
         INTO v_nopoliza,
         	  v_documento,
         	  v_codramo,
         	  v_codsubramo,
              v_contratante,
              v_fecha_suscripc,
              v_vigencia_inic,
              v_vigencia_final,
              v_codagente
         FROM temp_perfil
        WHERE seleccionado = 1

       SELECT COUNT(*)
		 INTO _colectivo
         FROM emipouni
        WHERE no_poliza = v_nopoliza
          AND activo = 1;

		IF _colectivo > 1 THEN
		   LET _colectivo = 1;
		ELSE
		   LET _colectivo = 0;		   	
		END IF

	  FOREACH
       SELECT cod_producto,
			  cod_asegurado,
			  no_unidad,
			  prima_bruta
         INTO _cod_producto,
		      _cod_asegurado,
			  _no_unidad,
			  _prima_bruta
         FROM emipouni
        WHERE no_poliza = v_nopoliza
          AND activo = 1

			select fecha_aniversario
			  into _fecha_nac
			  from cliclien
			 where cod_cliente = _cod_asegurado;

            INSERT INTO temp_prod
                VALUES(v_nopoliza,
                       v_documento,
                       _cod_producto,
                       v_codramo,
                       v_codsubramo,
                       v_contratante,
                       v_vigencia_inic,
                       _cod_asegurado,
					   _no_unidad,
                       _colectivo,
                       _fecha_nac,
                       _prima_bruta);

	  END FOREACH
           
    END FOREACH

LET _a = 0;
LET _b = 0;
LET _c = 0;

FOREACH
       SELECT no_poliza,
       		  no_documento,
       		  cod_ramo,
       		  cod_subramo,
              cod_contratante,
              vigencia_inic,
			  cod_producto,
			  cod_asegurado,
			  colectivo,
			  no_unidad,
			  fecha_nac,
			  prima_bruta
         INTO v_nopoliza,
         	  v_documento,
         	  v_codramo,
         	  v_codsubramo,
              v_contratante,
              v_vigencia_inic,
			  _cod_producto,
			  _cod_asegurado,
			  _colectivo,
			  _no_unidad,
			  _fecha_nac,
			  _prima_bruta
         FROM temp_prod

       SELECT nombre,
			  fecha_aniversario	
         INTO v_desc_cliente,
		 	  _fecha_aniversario
         FROM cliclien
        WHERE cod_cliente = v_contratante;

       SELECT nombre
         INTO v_desc_asegurado
         FROM cliclien
        WHERE cod_cliente = _cod_asegurado;

       SELECT nombre
         INTO v_desc_ramo
         FROM prdramo
        WHERE cod_ramo = v_codramo;

       SELECT nombre
         INTO v_desc_subr
         FROM prdsubra
        WHERE cod_ramo    = v_codramo
          AND cod_subramo = v_codsubramo;

       SELECT tipo_suscripcion,
			  prima_exc_perd	
         INTO _tipo_suscripcion,
			  _prima_xl
         FROM prdprod
        WHERE cod_producto = _cod_producto;

	   SELECT max(periodo)
	     INTO _periodo_priex
	     FROM prdpriex
		WHERE periodo      <= _periodo
		  and cod_producto = _cod_producto;

       SELECT prima_exc_perd,
			  tipo_suscripcion
         INTO _prima_xl,
			  _tipo_suscripcion
         FROM prdpriex
        WHERE cod_producto 	   = _cod_producto
          AND periodo      	   = _periodo_priex
          AND tipo_suscripcion = _tipo_suscripcion;

		LET _a = 0;
		LET _b = 0;
		LET _c = 0;
		LET _prima_xla = 0.00;
		LET _prima_xlb = 0.00;
		LET _prima_xlc = 0.00;

		IF _tipo_suscripcion   = "1" THEN
		   LET _tipo_sus = "A";
		   LET _a = 1;
		   LET _prima_xla = _prima_xl;
		ELIF _tipo_suscripcion = "2" THEN
		   LET _tipo_sus = "B";
		   LET _b = 1;
		   LET _prima_xlb = _prima_xl;
		ELIF _tipo_suscripcion = "3" THEN
		   LET _tipo_sus = "C";
		   LET _c = 1;
		   LET _prima_xlc = _prima_xl;
		ELSE
		   LET _tipo_sus = "N";
		END IF

	   SELECT COUNT(*)
         INTO _dependientes
         FROM emidepen
        WHERE no_poliza = v_nopoliza
		  AND no_unidad = _no_unidad
          AND activo = 1;

		IF _dependientes IS NULL THEN
			LET _dependientes = 0;
		END IF

		IF _colectivo = 0 THEN
			LET _contratante = "";
		ELSE
			LET _contratante = v_desc_cliente;
			LET v_desc_cliente = v_desc_asegurado;
		END IF

         RETURN v_descr_cia,
         		v_codramo,
         		v_desc_ramo,
                v_codsubramo,
                v_desc_subr,
                v_desc_cliente,
                v_documento,
                v_vigencia_inic,
                v_filtros,
                _dependientes,
				_prima_xl,
				_prima_xla,
				_prima_xlb,
				_prima_xlc,
				_tipo_sus,
				_contratante,
				_colectivo,
				_no_unidad,
				_a,
				_b,
				_c,
				_fecha_nac,
				_prima_bruta
                 WITH RESUME;

END FOREACH
    DROP TABLE temp_perfil;
    DROP TABLE temp_prod;
END
END PROCEDURE;
