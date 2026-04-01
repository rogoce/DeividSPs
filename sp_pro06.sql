   DROP procedure sp_pro06;
   CREATE procedure "informix".sp_pro06(a_cia CHAR(03),a_agencia CHAR(3), a_codsucursal CHAR(255) DEFAULT "*",a_codramo CHAR(255) DEFAULT "*",a_periodo DATE)

   RETURNING CHAR(3),CHAR(3),CHAR(50),CHAR(50),integer,DECIMAL(16,2),
             DECIMAL(16,2),DATE,CHAR(255),CHAR(45);

--------------------------------------------
---  PERFIL DE CARTERA - RAMOS AUTOMOVIL ---
---            POLIZAS VIGENTES          ---
---  EXCLUYENDO COASEGUROS Y POLIZAS EN  ---
---        CONTRATOS ESPECIALES          ---
---  Yinia M. Zamora - agosto 2000 - YMZM
---  Ref. Power Builder - d_sp_pro06     ---
---  Modif. Armando Moreno 21/12/2001 llamar al procedure sp_pro87 en vez del sp_pro03
--------------------------------------------

BEGIN

    DEFINE v_codramo,v_codsubramo,v_codsucursal  CHAR(3);
    DEFINE v_desc_ramo,v_desc_subramo            CHAR(50);
    DEFINE unidades2,v_unidades2                 SMALLINT;
    DEFINE _no_poliza          					 CHAR(10);
    DEFINE v_cant_polizas          				 INTEGER;
    DEFINE v_prima_suscrita,v_prima_retenida,
           w_prima_suscrita,w_prima_retenida   	 DECIMAL(16,2);
    DEFINE v_filtros                           	 CHAR(255);
	DEFINE descr_cia						   	 CHAR(45);	
    DEFINE _tipo                                 CHAR(01);
	DEFINE _no_endoso                            CHAR(5);
	define _no_documento                         char(20);
	define _cant_polizas                         smallint;
	define _cnnt								 integer;

    CREATE TEMP TABLE temp_perfil1(
              no_poliza      CHAR(10),
              cod_ramo       CHAR(3),
              cod_subramo    CHAR(3),
              cod_sucursal   CHAR(3),
              cant_polizas   integer,
              prima_suscrita   DEC(16,2),
              prima_retenida   DEC(16,2),
              seleccionado     SMALLINT DEFAULT 1,
			  no_documento     char(20),
              PRIMARY KEY(no_poliza)) WITH NO LOG;
			  CREATE INDEX i_perfil111 ON temp_perfil1(no_documento);

   { CREATE TEMP TABLE temp_perfil2(
              no_poliza      CHAR(10),
              cod_ramo       CHAR(3),
              cod_subramo    CHAR(3),
              cod_sucursal   CHAR(3),
              cant_polizas   integer,
              prima_suscrita DEC(16,2),
              prima_retenida DEC(16,2),
              seleccionado   SMALLINT DEFAULT 1) WITH NO LOG;}

	LET descr_cia = sp_sis01(a_cia);
    --LET v_filtros = sp_pro87(a_cia,a_agencia,a_periodo,a_codramo);
	call sp_pro83(a_cia,a_agencia,a_periodo,a_codramo) returning v_filtros;

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

    LET v_codsucursal = NULL;
	LET v_unidades2   = 0;
    LET v_codramo     = NULL;
    LET v_codsubramo  = NULL;
    LET v_desc_ramo   = NULL;
    LET v_desc_subramo = NULL;
    LET v_cant_polizas = 0;
    LET v_prima_suscrita = 0;
    LET v_prima_retenida = 0;
    LET w_prima_suscrita = 0;
    LET w_prima_retenida = 0;
    LET unidades2        = 0;
	let _cant_polizas    = 1;

    SET ISOLATION TO DIRTY READ;
FOREACH
       SELECT y.no_poliza,
	          y.no_endoso,
       		  y.cod_sucursal,
       		  y.cod_ramo,
       		  y.cod_subramo,
			  y.no_documento
         INTO _no_poliza,
		      _no_endoso,
         	  v_codsucursal,
         	  v_codramo,
         	  v_codsubramo,
			  _no_documento
         FROM temp_perfil y, emitipro z
        WHERE y.cod_tipoprod = z.cod_tipoprod 
          AND z.tipo_produccion IN (1, 4)
	      AND y.cod_grupo NOT IN ('00069', '00081', '00056', '00060', '00051')
		  AND y.seleccionado = 1

          SELECT prima_suscrita,
				 prima_retenida
            INTO w_prima_suscrita,
				 w_prima_retenida
            FROM endedmae
           WHERE no_poliza = _no_poliza
             AND no_endoso = _no_endoso;

        BEGIN
          ON EXCEPTION IN(-239)
             UPDATE temp_perfil1
                SET prima_suscrita = prima_suscrita + w_prima_suscrita,
                    prima_retenida = prima_retenida + w_prima_retenida
              WHERE no_poliza   = _no_poliza;

          END EXCEPTION

		select count(*)  
		  into _cnnt
		  from temp_perfil1
		 where no_documento = _no_documento;
		if _cnnt is null then
			let _cnnt = 0;
		end if
		if _cnnt = 0 then
			let _cant_polizas = 1;
		else
			let _cant_polizas = 0;
		end if
          INSERT INTO temp_perfil1
              VALUES(_no_poliza,
                     v_codramo,
                     v_codsubramo,
                     v_codsucursal,
                     _cant_polizas,
                     w_prima_suscrita,
                     w_prima_retenida,
                     1,
					 _no_documento);
        END
        LET v_unidades2 = 0;

END FOREACH
      -- Procesos v_filtros
      LET v_filtros ="";
      IF a_codramo <> "*" THEN
         LET v_filtros = TRIM(v_filtros) ||"Ramos "||TRIM(a_codramo);
      END IF

    FOREACH
       SELECT x.cod_ramo,
       		  x.cod_subramo,
       		  SUM(x.cant_polizas),
              SUM(x.prima_suscrita),
              SUM(x.prima_retenida)
         INTO v_codramo,
         	  v_codsubramo,
         	  v_cant_polizas,
              v_prima_suscrita,
              v_prima_retenida
         FROM temp_perfil1 x
        WHERE x.seleccionado = 1
		GROUP BY x.cod_ramo,x.cod_subramo
        ORDER BY x.cod_ramo,x.cod_subramo

       SELECT a.nombre
         INTO v_desc_ramo
         FROM prdramo a
        WHERE a.cod_ramo = v_codramo;

       SELECT prdsubra.nombre
         INTO v_desc_subramo
         FROM prdsubra
        WHERE prdsubra.cod_subramo = v_codsubramo
          AND prdsubra.cod_ramo    = v_codramo;

       RETURN v_codramo,v_codsubramo,v_desc_ramo,v_desc_subramo,
              v_cant_polizas,v_prima_suscrita,v_prima_retenida,
              a_periodo,v_filtros,descr_cia WITH RESUME;
    END FOREACH

DROP TABLE temp_perfil;
DROP TABLE temp_perfil1;
END
END PROCEDURE;
