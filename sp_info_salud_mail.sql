--Asegurados activo Salud – Envio Actualizacion Red Premier Care:

--Generar Query de asegurados, del ramo -018-, todos los subramos, de pólizas VIGENTES, VENCIDAS con Motivo de No renovación -027- SALDO PENDIENTE Y FACTURACION ATRASADA. Unidades Activas.

--Salida: Nombre del Asegurado, Email.


--DROP procedure sp_info_salud_mail;
CREATE PROCEDURE sp_info_salud_mail()
RETURNING CHAR(3),
 		  CHAR(50),
 		  CHAR(20),
          DATE,
          INTEGER,
          INTEGER;

 BEGIN

    DEFINE v_nopoliza,v_contratante         CHAR(10);
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
           
       SELECT nombre
         INTO v_desc_subr
         FROM prdsubra
        WHERE cod_ramo    = v_codramo
          AND cod_subramo = v_codsubramo;

       SELECT count(*)
         INTO _cant_ase
         FROM emipouni
        WHERE no_poliza     = v_nopoliza
          AND vigencia_inic <= a_periodo1
          AND activo        = 1;

	   SELECT COUNT(*)
         INTO _dependientes
         FROM emidepen
        WHERE no_poliza = v_nopoliza
          AND activo = 1
          AND fecha_efectiva <= a_periodo1;

	   IF _dependientes IS NULL THEN
			LET _dependientes = 0;
	   END IF

       RETURN   v_codsubramo,v_desc_subr,v_documento,a_periodo1,_cant_ase,_dependientes WITH RESUME;

      END FOREACH
    DROP TABLE temp_perfil;
END
END PROCEDURE;
