DROP procedure sp_pro31;
CREATE procedure "informix".sp_pro31(
a_compania    CHAR(03),
a_agencia     CHAR(03),
a_periodo1    CHAR(07),
a_periodo2    CHAR(07),
a_codsucursal CHAR(255) DEFAULT "*",
a_codramo     CHAR(255) DEFAULT "*"
) RETURNING CHAR(3),
            CHAR(50),
            DECIMAL(16,2),
            DECIMAL(9,2),
            CHAR(50),
            CHAR(255);

--------------------------------------------
---  TOTALES DE COASEGURO POR RAMO ---
---  Yinia M. Zamora - octubre 2000 - YMZM
---  Ref. Power Builder - d_sp_pro31
--------------------------------------------

   BEGIN

	DEFINE s_nopoliza       CHAR(10);     
	DEFINE v_aseg_lider     CHAR(03);     
	DEFINE s_cia            CHAR(03);     
	DEFINE s_codsucursal    CHAR(03);     
	DEFINE s_codramo        CHAR(03);     
	DEFINE s_codasegur      CHAR(03);     
	DEFINE s_codgrupo       CHAR(5);      
	DEFINE v_descramo       CHAR(45);     
	DEFINE v_porc_partic    DECIMAL(7,4); 
	DEFINE v_porc_gastos    DECIMAL(5,2); 
	DEFINE v_prima_suscrita DECIMAL(16,2);
	DEFINE v_coaseguro_ced  DECIMAL(16,2);
	DEFINE v_comision_m     DECIMAL(9,2); 
	DEFINE v_filtros        CHAR(255);    
	DEFINE _tipo            CHAR(01);     
	DEFINE v_descr_cia      CHAR(50);     
	DEFINE s_tipopro        CHAR(03);     
	DEFINE _tipo_produccion SMALLINT;     
	DEFINE _fecha_emision   DATE;
	DEFINE _no_cambio       CHAR(3);

--SET DEBUG FILE TO "\\NEMESIS\Ancon\Store Procedures\Debug\sp_pro31.trc"; 

      CREATE TEMP TABLE temp_coaseguro
               (cod_sucursal     CHAR(3),
                cod_ramo         CHAR(3),
                coaseguro_ced    DEC(16,2),
                comision_m       DEC(9,2),
                seleccionado     SMALLINT DEFAULT 1,
                PRIMARY KEY(cod_sucursal,cod_ramo)) WITH NO LOG;

      CREATE INDEX id1_temp_coaseguro ON temp_coaseguro(cod_sucursal);
      CREATE INDEX id2_temp_coaseguro ON temp_coaseguro(cod_ramo);

      LET s_tipopro        = NULL;
      LET v_descramo       = NULL;
      LET v_prima_suscrita = 0;
      LET v_porc_partic    = 0;
      LET v_porc_gastos    = 0;
      LET v_comision_m     = 0;

      LET v_descr_cia = sp_sis01(a_compania);
	    
	  SET ISOLATION TO DIRTY READ;

      SELECT par_ase_lider
        INTO v_aseg_lider
        FROM parparam
       WHERE cod_compania = a_compania;

      FOREACH WITH HOLD
       SELECT endedmae.no_poliza,
              endedmae.prima_neta,
              endedmae.fecha_emision 
         INTO s_nopoliza,
              v_prima_suscrita,
			  _fecha_emision
         FROM endedmae
        WHERE endedmae.actualizado = 1
          AND endedmae.periodo BETWEEN a_periodo1 AND a_periodo2
--          AND endedmae.prima_suscrita <> 0

			SELECT cod_ramo, 
			       cod_tipoprod,
				   sucursal_origen
			  INTO s_codramo,
			       s_tipopro,
	               s_codsucursal
			  FROM emipomae
			 WHERE emipomae.no_poliza  = s_nopoliza;

			SELECT tipo_produccion
			  INTO _tipo_produccion
			  FROM emitipro
			 WHERE cod_tipoprod = s_tipopro;

--			IF _tipo_produccion <> 2 THEN
--				CONTINUE FOREACH;
--			END IF

--TRACE ON;                                                                

			 SELECT	MAX(no_cambio)
			   INTO	_no_cambio
			   FROM	emihcmm
			  WHERE	no_poliza  = s_nopoliza
			    AND fecha_mov <= _fecha_emision;

			IF _no_cambio IS NULL THEN
				CONTINUE FOREACH;
			END IF

	        SELECT porc_partic_coas,porc_gastos
              INTO v_porc_partic,v_porc_gastos
              FROM emihcmd
             WHERE no_poliza    = s_nopoliza
               AND no_cambio    = _no_cambio
               AND cod_coasegur = v_aseg_lider;

			IF v_porc_partic IS NULL THEN
				LET v_porc_partic = 0;
				LET v_porc_gastos = 0;
			END IF

	        LET v_coaseguro_ced = (v_prima_suscrita*v_porc_partic/100);
	        LET v_coaseguro_ced = v_prima_suscrita - v_coaseguro_ced;
	        LET v_comision_m    = (v_prima_suscrita*v_porc_gastos/100);

        IF v_coaseguro_ced = 0 OR
           v_coaseguro_ced IS NULL THEN
           CONTINUE FOREACH;
        END IF

        BEGIN
            ON EXCEPTION IN(-239)
               UPDATE temp_coaseguro
                      SET coaseguro_ced = coaseguro_ced + v_coaseguro_ced,
                          comision_m    = comision_m    + v_comision_m
                    WHERE cod_sucursal  = s_codsucursal
                      AND cod_ramo      = s_codramo;

            END EXCEPTION

            INSERT INTO temp_coaseguro
                   VALUES(s_codsucursal,
                          s_codramo,
                          v_coaseguro_ced,
                          v_comision_m,
                          1);
        END

--EXIT FOREACH;

      END FOREACH

      -- Procesos v_filtros
      LET v_filtros ="";

      IF a_codramo <> "*" THEN
         LET v_filtros = TRIM(v_filtros) ||"Ramo "||TRIM(a_codramo);
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

      IF a_codsucursal <> "*" THEN
         LET v_filtros = TRIM(v_filtros) ||"Sucursal "||TRIM(a_codsucursal);
         LET _tipo = sp_sis04(a_codsucursal); -- Separa los valores del String

         IF _tipo <> "E" THEN -- Incluir los Registros

            UPDATE temp_coaseguro
                   SET seleccionado = 0
                 WHERE seleccionado = 1
                   AND cod_sucursal NOT IN(SELECT codigo FROM tmp_codigos);
         ELSE
            UPDATE temp_coaseguro
                   SET seleccionado = 0
                 WHERE seleccionado = 1
                   AND cod_sucursal IN(SELECT codigo FROM tmp_codigos);
         END IF
         DROP TABLE tmp_codigos;
      END IF

      FOREACH
       SELECT x.cod_ramo,
              SUM(x.coaseguro_ced),
              SUM(x.comision_m)
         INTO s_codramo,
              v_coaseguro_ced,
              v_comision_m
         FROM temp_coaseguro x
        WHERE x.seleccionado = 1
		GROUP BY cod_ramo
        ORDER BY x.cod_ramo

         SELECT prdramo.nombre
                INTO v_descramo
                FROM prdramo
               WHERE prdramo.cod_ramo = s_codramo;

         RETURN s_codramo,v_descramo,v_coaseguro_ced,v_comision_m,
                v_descr_cia,v_filtros  WITH RESUME;

      END FOREACH

   DROP TABLE temp_coaseguro;

   END

END PROCEDURE;