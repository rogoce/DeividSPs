--  Polizas Vigentes por Subramo

--  Creado    : 13/05/2010    - Autor: Armando Moreno M.

-- SIS v.2.0 - DEIVID, S.A.


DROP procedure sp_pro997a;
CREATE PROCEDURE sp_pro997a(a_cia CHAR(3), a_agencia   CHAR(3), a_periodo1  DATE, a_subramo CHAR(255) DEFAULT "*")
RETURNING CHAR(3),
 		  CHAR(50),
 		  CHAR(20),
          DATE,
          INTEGER,
          INTEGER,
          VARCHAR(100),
          DATE,
          SMALLINT,
          CHAR(7);

 BEGIN

    DEFINE v_nopoliza,v_contratante,_cod_asegurado   CHAR(10);
    DEFINE v_documento                      CHAR(20);
    DEFINE v_codramo,v_codsubramo           CHAR(3);
    DEFINE v_fecha_suscripc,v_vigencia_inic,v_vigencia_final,_fecha_aniversario,_fecha_hoy DATE;
    DEFINE v_prima_suscrita                 DECIMAL(16,2);
    DEFINE v_codagente, _no_endoso          CHAR(5);
    DEFINE v_desc_cliente                   CHAR(45);
    DEFINE v_filtros                        CHAR(255);
    DEFINE _tipo                            CHAR(01);
    DEFINE v_desc_ramo,v_desc_subr,v_desc_agente,v_descr_cia  CHAR(50);
	DEFINE _dependientes,_edad INTEGER;
	DEFINE _cant_ase integer;
	DEFINE v_desc_contratante               VARCHAR(100);
	DEFINE _edadcal                         SMALLINT;
	DEFINE _edadcal_tot                     INTEGER;
	define _estatus_char					char(7);
	define _estatus_poliza                  smallint;

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
    CALL sp_pro03(a_cia,a_agencia,a_periodo1,"018;")  RETURNING v_filtros;
    CALL sp_pro03h(a_cia,a_agencia,a_periodo1,"018;")  RETURNING v_filtros;

    SET ISOLATION TO DIRTY READ;

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

    FOREACH
       SELECT distinct y.no_poliza,
       		  y.no_documento,
       		  y.cod_ramo,
       		  y.cod_subramo,
              y.cod_contratante,
              y.fecha_suscripcion,
              y.vigencia_inic,
              y.vigencia_final,
              y.prima_suscrita	 --,y.cod_agente
         INTO v_nopoliza,
         	  v_documento,
         	  v_codramo,
         	  v_codsubramo,
              v_contratante,
              v_fecha_suscripc,
              v_vigencia_inic,
              v_vigencia_final,
              v_prima_suscrita    --,v_codagente
         FROM temp_perfil y
        WHERE seleccionado = 1
		  and no_documento = '1899-00076-01'
           
       SELECT nombre
         INTO v_desc_subr
         FROM prdsubra
        WHERE cod_ramo    = v_codramo
          AND cod_subramo = v_codsubramo;

       let _cant_ase = 1;

       SELECT count(*)
         INTO _cant_ase
         FROM emipouni
        WHERE no_poliza     = v_nopoliza
          AND vigencia_inic <= a_periodo1
          AND activo        = 1;

       if _cant_ase = 0 then
			let _cant_ase = 1;
	   end if

	   SELECT COUNT(*)
         INTO _dependientes
         FROM emidepen
        WHERE no_poliza = v_nopoliza
          AND activo = 1
          AND fecha_efectiva <= a_periodo1;

	   SELECT nombre
	     INTO v_desc_contratante
		 FROM cliclien
		WHERE cod_cliente = v_contratante;

	   IF _dependientes IS NULL THEN
			LET _dependientes = 0;
	   END IF

       let _edadcal_tot = 0;

       FOREACH
		SELECT cod_asegurado
		  INTO _cod_asegurado
          FROM emipouni
         WHERE no_poliza     = v_nopoliza
           AND vigencia_inic <= a_periodo1
           AND activo        = 1

        SELECT fecha_aniversario
		  INTO _fecha_aniversario
		  FROM cliclien
		 WHERE cod_cliente = _cod_asegurado;

         LET _edadcal = sp_sis78(_fecha_aniversario);
         let _edadcal_tot  = _edadcal_tot + _edadcal;

	   END FOREACH

	   select estatus_poliza into _estatus_poliza from emipomae where no_poliza = v_nopoliza;

	   let _estatus_char = null;

       if _estatus_poliza = 1 then
		let _estatus_char = 'VIGENTE';
	   elif _estatus_poliza = 3 then
 		let _estatus_char = 'VENCIDA';
	   end if

       RETURN   v_codsubramo,v_desc_subr,v_documento,a_periodo1,_cant_ase,_dependientes, v_desc_contratante, v_vigencia_inic, _edadcal_tot/_cant_ase,_estatus_char WITH RESUME;

    END FOREACH
--    DROP TABLE temp_perfil;
END
END PROCEDURE;
