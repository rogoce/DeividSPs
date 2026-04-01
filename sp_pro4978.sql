-- Reporte de contratantes de pólizas, del tipo de producción Coaseguro Minoritario, grupo Pólizas del Estado, Coaseguradora líder = 005ASSA
-- Creado :15/02/2024 - Henry Girón
-- SIS v.2.0 - d_prod_sp_pro4978_dw1 - DEIVID, S.A.

DROP procedure sp_pro4978;
CREATE PROCEDURE sp_pro4978(a_cia CHAR(3), a_agencia   CHAR(3), a_periodo1  DATE, a_codramo CHAR(255) DEFAULT "*", a_subramo CHAR(255) DEFAULT "*", a_coasegur CHAR(255) DEFAULT "*", a_grupo CHAR(255) DEFAULT "*")
RETURNING   CHAR(20) as Poliza,
			CHAR(10) as Contratante,
			VARCHAR(100) as Nombre_Contratante,		
			VARCHAR(50) as Ramo,	
            DATE AS vigencia_inicial,
		    DATE AS vigencia_final,			
            VARCHAR(50) AS cia_aseguradora,			
		    DEC(7,4) AS coas_asumido,
			varchar(30) as nivel_riesgo,
			DECIMAL(16,2) as Prima_Anual,
			VARCHAR(50) as Grupo;			

 BEGIN

    DEFINE v_nopoliza,v_contratante,_cod_asegurado,_no_poliza   CHAR(10);
    DEFINE v_documento                      CHAR(20);
    DEFINE v_codramo,v_codsubramo           CHAR(3);
    DEFINE v_fecha_suscripc,v_vigencia_inic,v_vigencia_final,_fecha_aniversario,_fecha_hoy DATE;
    DEFINE v_prima_suscrita                 DECIMAL(16,2);
    DEFINE v_codagente, _no_endoso  ,v_cod_grupo        CHAR(5);
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
	
	DEFINE _cod_coasegur      CHAR(3);
	DEFINE _porc_partic_ancon DEC(7,4);
	DEFINE _cod_agente        CHAR(5); 
	DEFINE _porc_partic_agt   DEC(5,2);
	DEFINE _porc_comis_agt    DEC(5,2);
	DEFINE _cia_aseguradora   VARCHAR(50);
	DEFINE _coaseguro_asumido DEC(7,4);
	DEFINE _coaseguro_cedido  DEC(7,4);	
	define n_riesgo           varchar(30);	
    DEFINE _cod_riesgo         INTEGER;
	DEFINE _desc_ramo,_desc_subramo, _desc_grupo  VARCHAR(50);
	
	LET _fecha_hoy = TODAY;
    LET v_prima_suscrita = 0;
    LET _dependientes    = 0;
    LET _edad		     = 0;
    LET v_desc_cliente   = NULL;
    LET v_desc_agente    = NULL;
    LET v_desc_subr      = NULL;
    LET v_descr_cia      = NULL;
    LET v_filtros        = NULL;
	
    drop table if exists temp_perfil; 	
	drop table if exists tmp_perfil2; 	
    LET v_descr_cia = sp_sis01(a_cia);
    CALL sp_pro03(a_cia,a_agencia,a_periodo1,a_codramo)  RETURNING v_filtros;
  --  CALL sp_pro03h(a_cia,a_agencia,a_periodo1,"018;")  RETURNING v_filtros;

    SET ISOLATION TO DIRTY READ;
	
    -- Filtro de Ramo
      IF a_codramo <> "*" THEN
         LET v_filtros = TRIM(v_filtros) ||"Ramo "||TRIM(a_codramo);
         LET _tipo = sp_sis04(a_codramo); -- Separa los valores del String

         IF _tipo <> "E" THEN -- Incluir los Registros

            UPDATE temp_perfil
                   SET seleccionado = 0
                 WHERE seleccionado = 1
                   AND cod_ramo NOT IN(SELECT codigo FROM tmp_codigos);
         ELSE
            UPDATE temp_perfil
                   SET seleccionado = 0
                 WHERE seleccionado = 1
                   AND cod_ramo IN(SELECT codigo FROM tmp_codigos);
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
	  
    -- Filtro de Grupo
      IF a_grupo <> "*" THEN
         LET v_filtros = TRIM(v_filtros) ||"Grupo: "||TRIM(a_grupo);
         LET _tipo = sp_sis04(a_grupo); -- Separa los valores del String

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
	  
    -- Filtro de a_coasegur
      IF a_coasegur <> "*" THEN
	  
         LET v_filtros = TRIM(v_filtros) ||"Coaseguradora: "||TRIM(a_coasegur);
         LET _tipo = sp_sis04(a_coasegur); -- Separa los valores del String		 			 		 		
         IF _tipo <> "E" THEN -- Incluir los Registros
		 SELECT temp_perfil.no_poliza,temp_perfil.no_documento,temp_perfil.no_factura,temp_perfil.cod_ramo,temp_perfil.cod_subramo,temp_perfil.cod_sucursal,temp_perfil.cod_grupo,temp_perfil.cod_tipoprod,temp_perfil.cod_contratante,temp_perfil.cod_agente,temp_perfil.prima_suscrita,temp_perfil.prima_retenida,temp_perfil.vigencia_inic,temp_perfil.vigencia_final,temp_perfil.fecha_suscripcion,temp_perfil.usuario,temp_perfil.suma_asegurada,temp_perfil.prima_bruta,temp_perfil.seleccionado
		   FROM temp_perfil temp_perfil
		  INNER JOIN emicoami pol ON temp_perfil.no_poliza = pol.no_poliza AND pol.cod_coasegur NOT IN (SELECT codigo FROM tmp_codigos)
	      WHERE temp_perfil.cod_tipoprod = '002'  -- and temp_perfil.cod_grupo = '1000' 
		    and temp_perfil.seleccionado = 1
		   INTO temp tmp_perfil2;	
		   
		 foreach
		 SELECT distinct trim(no_poliza)  --temp_perfil.no_poliza,temp_perfil.no_documento,temp_perfil.no_factura,temp_perfil.cod_ramo,temp_perfil.cod_subramo,temp_perfil.cod_sucursal,temp_perfil.cod_grupo,temp_perfil.cod_tipoprod,temp_perfil.cod_contratante,temp_perfil.cod_agente,temp_perfil.prima_suscrita,temp_perfil.prima_retenida,temp_perfil.vigencia_inic,temp_perfil.vigencia_final,temp_perfil.fecha_suscripcion,temp_perfil.usuario,temp_perfil.suma_asegurada,temp_perfil.prima_bruta,temp_perfil.seleccionado
		   into _no_poliza
		   FROM tmp_perfil2
		  WHERE seleccionado = 1   
		
         UPDATE temp_perfil
		   SET seleccionado = 0
		 WHERE seleccionado = 1
		   AND cod_tipoprod = '002'  -- and  cod_grupo = '1000' 
		   and trim(no_poliza) = _no_poliza;		
		   
		   end foreach
		 
		drop table if exists tmp_perfil2; 		   
		   
         ELSE
		 
		 SELECT temp_perfil.no_poliza,temp_perfil.no_documento,temp_perfil.no_factura,temp_perfil.cod_ramo,temp_perfil.cod_subramo,temp_perfil.cod_sucursal,temp_perfil.cod_grupo,temp_perfil.cod_tipoprod,temp_perfil.cod_contratante,temp_perfil.cod_agente,temp_perfil.prima_suscrita,temp_perfil.prima_retenida,temp_perfil.vigencia_inic,temp_perfil.vigencia_final,temp_perfil.fecha_suscripcion,temp_perfil.usuario,temp_perfil.suma_asegurada,temp_perfil.prima_bruta,temp_perfil.seleccionado
		   FROM temp_perfil temp_perfil
		  INNER JOIN emicoami pol ON temp_perfil.no_poliza = pol.no_poliza AND pol.cod_coasegur IN (SELECT codigo FROM tmp_codigos)
	      WHERE temp_perfil.cod_tipoprod = '002' --  and  temp_perfil.cod_grupo = '1000' 
		    and temp_perfil.seleccionado = 1
		   INTO temp tmp_perfil2;	
		   
		 foreach
		 SELECT distinct trim(no_poliza)  --temp_perfil.no_poliza,temp_perfil.no_documento,temp_perfil.no_factura,temp_perfil.cod_ramo,temp_perfil.cod_subramo,temp_perfil.cod_sucursal,temp_perfil.cod_grupo,temp_perfil.cod_tipoprod,temp_perfil.cod_contratante,temp_perfil.cod_agente,temp_perfil.prima_suscrita,temp_perfil.prima_retenida,temp_perfil.vigencia_inic,temp_perfil.vigencia_final,temp_perfil.fecha_suscripcion,temp_perfil.usuario,temp_perfil.suma_asegurada,temp_perfil.prima_bruta,temp_perfil.seleccionado
		   into _no_poliza
		   FROM tmp_perfil2
		  WHERE seleccionado = 1   
		
         UPDATE temp_perfil
		   SET seleccionado = 0
		 WHERE seleccionado = 1
		   AND cod_tipoprod = '002'  -- and  cod_grupo = '1000' 
		   and trim(no_poliza) = _no_poliza;		
		   
		   end foreach
		 
		drop table if exists tmp_perfil2; 	
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
              y.prima_suscrita,	 --,y.cod_agente
			  y.cod_grupo
         INTO v_nopoliza,
         	  v_documento,
         	  v_codramo,
         	  v_codsubramo,
              v_contratante,
              v_fecha_suscripc,
              v_vigencia_inic,
              v_vigencia_final,
              v_prima_suscrita,    --,v_codagente
			  v_cod_grupo
         FROM temp_perfil y
        WHERE cod_tipoprod = '002'  -- and  cod_grupo = '1000' 
		and seleccionado = 1
		--  and no_documento = '1899-00076-01'
           
       SELECT nombre
         INTO v_desc_subr
         FROM prdsubra
        WHERE cod_ramo    = v_codramo
          AND cod_subramo = v_codsubramo;
		  
		LET  _cod_coasegur = NULL;  
		LET  _porc_partic_ancon = 0.00;  
		LET  _cia_aseguradora = NULL;  
		   
		SELECT cod_coasegur,
			   porc_partic_ancon
		  INTO _cod_coasegur,
			   _porc_partic_ancon
		  FROM emicoami
		 WHERE no_poliza = v_nopoliza;
		 --and cod_coasegur = a_coasegur;		 
		 
		IF _cod_coasegur IS NOT NULL THEN
			SELECT nombre
			  INTO _cia_aseguradora
			  FROM emicoase
			 WHERE cod_coasegur = _cod_coasegur;
			 
			LET _coaseguro_asumido = _porc_partic_ancon;
			LET _coaseguro_cedido = 100 - _porc_partic_ancon;
		ELSE
		    continue foreach;
			LET _coaseguro_asumido = 100;
			LET _coaseguro_cedido = 0;
		END IF
	

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
	   
		select cod_riesgo 
		into _cod_riesgo 
		from ponderacion
        where cod_cliente = v_contratante;
        		
		select nombre 
		into n_riesgo 
		from cliriesgo
		where cod_riesgo = _cod_riesgo;	  

	   SELECT nombre
         INTO v_desc_ramo
         FROM prdramo
        WHERE cod_ramo = v_codramo;		
		
	   SELECT nombre
	   into _desc_grupo
         FROM cligrupo
        WHERE cod_grupo = v_cod_grupo;

		
	     let _desc_ramo = trim(v_desc_ramo)||' - '||trim(v_codramo);
 --      RETURN   v_codsubramo,v_desc_subr,v_documento,a_periodo1,_cant_ase,_dependientes, v_desc_contratante, v_vigencia_inic, _edadcal_tot/_cant_ase,_estatus_char WITH RESUME;
		  RETURN    v_documento,	
					v_contratante, 	
					v_desc_contratante, 
                    _desc_ramo,
	                v_vigencia_inic,
                    v_vigencia_final,	
                    _cia_aseguradora,					
                    _coaseguro_asumido,	
                    n_riesgo,
                    v_prima_suscrita,_desc_grupo WITH RESUME;		
    END FOREACH
--    DROP TABLE temp_perfil;
END
END PROCEDURE;
