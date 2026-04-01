   DROP procedure sp_rea024;
   CREATE procedure "informix".sp_rea024(a_cia CHAR(03),a_agencia CHAR(3),a_fecha DATE,a_serie CHAR(255) DEFAULT "*",a_contrato CHAR(255) DEFAULT "*",a_subramo CHAR(255) DEFAULT "*",a_cliente CHAR(255) DEFAULT "*")
   RETURNING CHAR(50),SMALLINT,DEC(16,2),DEC(16,2),DEC(16,2),CHAR(255),CHAR(50),SMALLINT;

--------------------------------------------
---       POLIZAS VIGENTES POR RAMO      --- SOLO Distribucion de Carteras
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
    DEFINE v_filtros1          CHAR(255);
	DEFINE _cod_subramo       CHAR(3);
	DEFINE _cod_agente        CHAR(5);
	DEFINE _no_poliza         CHAR(10);
	DEFINE v_prima_pagada     DEC(16,2);
	DEFINE _periodo           CHAR(7);
	DEFINE _porc_comis_agt, _porcentaje	  DEC(16,2);
	DEFINE _no_factura        CHAR(10);
	DEFINE _bouquet			  smallint;
	DEFINE v_count			  smallint;
	DEFINE v_total			  smallint;
	DEFINE v_promedio         DEC(16,2);
	DEFINE _edadpol           integer;
	define v_count1			  smallint;
	define v_count2			  smallint;
	define _serie			  smallint;


    LET v_cod_ramo       = NULL;
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
	let v_count1 = 0;
	let v_count2 = 0;
--  SET DEBUG FILE TO 'sp_rea024.trc';

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
		edadpol			 INTEGER  DEFAULT 0,
		serie			 SMALLINT DEFAULT 0) WITH NO LOG;

	CREATE INDEX i_tmp_reat1 ON tmp_reat(cod_ramo);
	CREATE INDEX i_tmp_reat2 ON tmp_reat(documento);
	CREATE INDEX i_tmp_reat3 ON tmp_reat(asegurado);
	CREATE INDEX i_tmp_reat4 ON tmp_reat(suma_asegurada);
	CREATE INDEX i_tmp_reat5 ON tmp_reat(prima_suscrita);
	CREATE INDEX i_tmp_reat6 ON tmp_reat(subramo);
	CREATE INDEX i_tmp_reat7 ON tmp_reat(vigencia_i);
	CREATE INDEX i_tmp_reat8 ON tmp_reat(vigencia_f);
	CREATE INDEX i_tmp_reat9 ON tmp_reat(serie);

   CREATE TEMP TABLE temp_cliente
          (subramo	   CHAR(50),
		  asegurado	   CHAR(45),
          PRIMARY KEY (asegurado))
          WITH NO LOG;
--   CREATE INDEX i_temp_cliente ON temp_cliente(asegurado);



--	edadpol	INTEGER,
--	PRIMARY KEY (cod_ramo,desc_ramo,documento,asegurado,suma_asegurada,prima_suscrita,subramo,vigencia_i,vigencia_f)) WITH NO LOG;

	SELECT par_ase_lider
	  INTO _cod_coasegur
	  FROM parparam
	 WHERE cod_compania = a_cia;

    LET v_descr_cia = sp_sis01(a_cia);
  	LET v_filtros1 = "";
--    CALL sp_rea21a(a_cia,a_agencia,a_fecha,"008;",a_serie,a_contrato) RETURNING v_filtros; -- Solo Fianzas
	CALL sp_rea21b(a_cia,a_agencia,"001",a_fecha,"008;",a_serie,a_contrato) RETURNING v_filtros; -- Solo Fianzas


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

  --	TRACE ON;

	SET ISOLATION TO DIRTY READ;
    FOREACH WITH HOLD
       SELECT y.no_documento,y.cod_ramo,y.cod_contratante,y.vigencia_inic,y.cod_subramo,
	          y.vigencia_final,y.cod_grupo,y.suma_asegurada,y.prima_suscrita,y.cod_agente,y.no_poliza,y.no_factura,y.bouquet,y.serie
	     INTO no_documento,v_cod_ramo,v_contratante,v_vigencia_inic,_cod_subramo,
	          v_vigencia_final,v_cod_grupo,v_suma_asegurada,
	          v_prima_suscrita,_cod_agente,_no_poliza, _no_factura, _bouquet,_serie
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
				edadpol,
				serie														 
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
				_edadpol,
				_serie
				);	

    END FOREACH
--TRACE OFF;

select count(documento)
  into v_total
  from tmp_reat;

BEGIN
  ON EXCEPTION IN(-239)
  END EXCEPTION
  insert into temp_cliente (subramo, asegurado)
  select subramo,asegurado from tmp_reat;
END


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
		LET v_count1 = 0;
		LET v_count2 = 0;

		select count(Distinct asegurado)
		  into v_count2
		  from temp_cliente
		 where subramo = v_subramo;

	return v_subramo,
		   v_count,
		   v_promedio,
	  	   v_suma_asegurada,
	  	   v_prima_suscrita,  	   
		   v_filtros,
		   v_descr_cia,
		   v_count2
	WITH RESUME;

end foreach


DROP TABLE temp_perfil;
DROP TABLE tmp_reat;
DROP TABLE temp_cliente;

END PROCEDURE;
			