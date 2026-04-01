   DROP procedure sp_aud16;
   CREATE procedure "informix".sp_aud16(a_cia CHAR(03),a_agencia CHAR(3),a_fecha1 DATE,a_fecha2 DATE)
   RETURNING CHAR(50),SMALLINT,DEC(16,2),DEC(16,2),DEC(16,2),CHAR(255),CHAR(50);
--------------------------------------------
---  2010 -- CGLRESUMEN
--------------------------------------------
    DEFINE v_cod_ramo,v_cod_sucursal, _cod_coasegur CHAR(3);
 
    LET _bouquet  = 0;
     
  SET DEBUG FILE TO 'sp_rea024.trc';

CREATE TEMP TABLE tmp_reat(
		cod_ramo		 CHAR(3),
		desc_ramo		 CHAR(50),
		documento		 CHAR(20), 
		asegurado		 CHAR(45), 
		suma_asegurada	 DECIMAL(16,2),
		prima_suscrita	 DECIMAL(16,2),
		filtros			 CHAR(255),
		descr_cia		 CHAR(50),
		subramo			 CHAR(50),
		vigencia_i		 DATE,
		vigencia_f		 DATE,
		edadpol			 INTEGER  DEFAULT 0) WITH NO LOG;

	CREATE INDEX i_tmp_reat1 ON tmp_reat(cod_ramo);
 
--	edadpol	INTEGER,
--	PRIMARY KEY (cod_ramo,desc_ramo,documento,asegurado,suma_asegurada,prima_suscrita,subramo,vigencia_i,vigencia_f)) WITH NO LOG;

	SELECT par_ase_lider
	  INTO _cod_coasegur
	  FROM parparam
	 WHERE cod_compania = a_cia;

    LET v_descr_cia = sp_sis01(a_cia);

  	LET v_filtros1 = "";
    CALL sp_rea21a(a_cia,a_agencia,a_fecha,"008;",a_serie,a_contrato) RETURNING v_filtros; -- Solo Fianzas
--	CALL sp_rea21b(a_cia,a_agencia,"001",a_fecha,"008;",a_serie,a_contrato) RETURNING v_filtros; -- Solo Fianzas


	-- Adicionar filtro cliente y subramo
	-- Filtro por Contrato

   	IF a_cliente <> "*" THEN
		LET v_filtros1 = TRIM(v_filtros1) ||" Asegurado "||TRIM(a_cliente);
		LET _tipo = sp_sis04(a_cliente); -- Separa los valores del String

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

	IF a_subramo <> "*" THEN
		LET v_filtros1 = TRIM(v_filtros1) ||" Subramos "||TRIM(a_subramo);
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

    LET v_filtros = TRIM(v_filtros1)||" "|| TRIM(v_filtros);

	TRACE ON;

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

	   {	IF _bouquet = 0 THEN
			CONTINUE FOREACH;
		END IF}

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

       SELECT nombre
              INTO v_asegurado
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

       let _edadpol = v_vigencia_final - v_vigencia_inic ;

		insert into tmp_reat(
				cod_ramo,		
				desc_ramo,		
				documento,		
				asegurado,		
				suma_asegurada,
				prima_suscrita,
				filtros,			
				descr_cia,		
				subramo,			
				vigencia_i,		
				vigencia_f,
				edadpol										 
				)
				values(
				v_cod_ramo,			   
				v_desc_ramo,
				no_documento,
				v_asegurado,
				v_suma_asegurada,
				v_prima_suscrita,
				v_filtros,
				v_descr_cia,
				v_subramo,
				v_vigencia_inic,
				v_vigencia_final,
				_edadpol
				);	

    END FOREACH

TRACE OFF;

select count(documento)
  into v_total
  from tmp_reat;

foreach 
	select subramo, 	
		   count(documento),		
		   sum(suma_asegurada),
		   sum(prima_suscrita)						   		
	  into v_subramo,
		   v_count,
	  	   v_suma_asegurada,
	  	   v_prima_suscrita	  	   
	  from tmp_reat
  group by 1
  order by 1
	
	    let v_promedio = (v_count/v_total) * 100 ;

	return v_subramo,
		   v_count,
		   v_promedio,
	  	   v_suma_asegurada,
	  	   v_prima_suscrita,  	   
		   v_filtros,
		   v_descr_cia
	WITH RESUME;

end foreach


DROP TABLE temp_perfil;
DROP TABLE tmp_reat;

END PROCEDURE;
			