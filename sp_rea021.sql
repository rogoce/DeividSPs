   DROP procedure sp_rea021;
   CREATE procedure "informix".sp_rea021(a_cia CHAR(03),a_agencia CHAR(3),a_fecha DATE,a_serie CHAR(255) DEFAULT "*",a_contrato CHAR(255) DEFAULT "*")

   RETURNING CHAR(3),CHAR(50),CHAR(20), CHAR(45), DECIMAL(16,2),DECIMAL(16,2), CHAR(255),CHAR(50),CHAR(50),varchar(30);

-------------------------------------------
---       POLIZAS VIGENTES POR RAMO      ---
---  Amado Perez - Abril 2001 - YMZM
---  Ref. Power Builder - d_sp_pro60
--------------------------------------------

    DEFINE v_cod_ramo,v_cod_sucursal, _cod_coasegur CHAR(3);
    DEFINE v_saber					  CHAR(2);
    DEFINE v_cod_grupo                CHAR(5);
    DEFINE v_contratante,v_codigo     CHAR(10);
    DEFINE v_asegurado                CHAR(45);
    DEFINE v_desc_ramo,v_descr_cia,v_desc_agente, v_subramo CHAR(50);
    DEFINE v_desc_grupo               CHAR(40);
    DEFINE no_documento               CHAR(20);
    DEFINE v_vigencia_inic,v_vigencia_final   DATE;
    DEFINE v_cant_polizas             INTEGER;
    DEFINE v_prima_suscrita,v_suma_asegurada   DECIMAL(16,2);
    DEFINE _tipo              CHAR(1);
    DEFINE v_filtros          CHAR(255);
	DEFINE _cod_subramo       CHAR(3);
	DEFINE _cod_agente        CHAR(5);
	DEFINE _no_poliza         CHAR(10);
	DEFINE v_prima_pagada     DEC(16,2);
	DEFINE _periodo           CHAR(7);
	DEFINE _porc_comis_agt, _porcentaje	  DEC(16,2);
	DEFINE _no_factura        CHAR(10);
	DEFINE _bouquet,_fronting			  smallint;
	define _ruc                     varchar(30);

    LET v_cod_ramo       = NULL;
	let _ruc             = null;
    LET v_cod_sucursal   = NULL;
    LET v_cod_grupo      = NULL;
    LET v_contratante    = NULL;
    LET no_documento     = NULL;
    LET v_desc_ramo      = NULL;
    LET v_descr_cia      = NULL;
    LET v_cant_polizas   = 0;
    LET v_prima_suscrita = 0;
    LET _tipo     = NULL;
    LET _bouquet  = 0;

	SELECT par_ase_lider
	  INTO _cod_coasegur
	  FROM parparam
	 WHERE cod_compania = a_cia;

    LET v_descr_cia = sp_sis01(a_cia);
  
--  CALL sp_rea21a(a_cia,a_agencia,a_fecha,"008;",a_serie,a_contrato) RETURNING v_filtros; -- Solo Fianzas
--	CALL sp_rea21b(a_cia,a_agencia,"001",a_fecha,"008;",a_serie,a_contrato) RETURNING v_filtros; -- Solo Fianzas
	CALL sp_rea21bbb(a_cia,a_agencia,"001",a_fecha,"008;",a_serie,a_contrato) RETURNING v_filtros; -- Solo Fianzas, 01/06/2017, s usa este procedimiento para usar la serie del contrato y no de la poliza

	SET ISOLATION TO DIRTY READ;
    FOREACH WITH HOLD
       SELECT y.no_documento,y.cod_ramo,y.cod_contratante,y.vigencia_inic,y.cod_subramo,
	          y.vigencia_final,y.cod_grupo,y.suma_asegurada,y.prima_suscrita,y.cod_agente,y.no_poliza,y.no_factura,y.bouquet
	     INTO no_documento,v_cod_ramo,v_contratante,v_vigencia_inic,_cod_subramo,
	          v_vigencia_final,v_cod_grupo,v_suma_asegurada,
	          v_prima_suscrita,_cod_agente,_no_poliza, _no_factura, _bouquet
	     FROM temp_perfil y
	    WHERE y.seleccionado = 1
	 ORDER BY y.cod_ramo,y.cod_subramo,y.no_documento

		IF _bouquet = 0 THEN
			CONTINUE FOREACH;
		END IF

		select fronting
		  into _fronting
		  from emipomae
		 where no_poliza = _no_poliza;

		IF _fronting = 1 THEN
			CONTINUE FOREACH;
		END IF

       SELECT a.nombre
              INTO v_desc_ramo
              FROM prdramo a
             WHERE a.cod_ramo  = v_cod_ramo;

	   SELECT nombre 
	          INTO v_subramo
			  FROM prdsubra
			 WHERE cod_ramo = v_cod_ramo
			   AND cod_subramo = _cod_subramo;

	   SELECT porc_comis_agt
	          INTO _porc_comis_agt
			  FROM emipoagt
			 WHERE cod_agente = _cod_agente
			   AND no_poliza  = _no_poliza;

       SELECT nombre,cedula
              INTO v_asegurado,_ruc
              FROM cliclien
             WHERE cod_cliente = v_contratante;

       SELECT nombre
              INTO v_desc_grupo
              FROM cligrupo
             WHERE cod_grupo = v_cod_grupo;

	   SELECT periodo
	          INTO _periodo
			  FROM emipomae
			 WHERE no_poliza = _no_poliza;	   

       RETURN  v_cod_ramo,v_desc_ramo,no_documento,
               v_asegurado,
               v_suma_asegurada,v_prima_suscrita,
               v_filtros,v_descr_cia,v_subramo,_ruc WITH RESUME;	  

    END FOREACH
DROP TABLE temp_perfil;

END PROCEDURE;
				   