--------------------------------------------
---            POLIZAS VIGENTES            ---
---  Yinia M. Zamora - agosto 2000 - YMZM
---  Modificado por Amado Perez Octubre 2001 
---  Modificado por Armando Moreno Nov. 2001 (sacar psuscrita de endosos y no de emipomae)
---  Modificado por Armando Moreno Sep. 2007 (sacar suma aseg. de unidad para ramo 002,y no de emipomae)
---  Modificado por Amado Perez Abril 2009 Reporte especial para Omar Wong para las reaseguradoras
---  Modificado por Henry Giron Junio 2009 Reporte para Omar Wong por contrato excluyendo fronting y retenciones
---  Modificado por Henry Giron utilizar varias series  [ANT:a_serie char(4) DEFAULT "1900")] Solicitud: Omar Wong 23/07/2010
---  Ref. Power Builder - d_sp_pro02
--------------------------------------------

DROP procedure sp_rea21d;
CREATE procedure "informix".sp_rea21d(a_compania CHAR(3), a_agencia  CHAR(03) DEFAULT "*", a_periodo DATE, a_codsucursal  CHAR(255) DEFAULT "*", a_codramo CHAR(255) DEFAULT "*", a_serie char(255) default "*" ) 
RETURNING  CHAR(10),
		   DEC(16,2),
		   DEC(16,2),
		   DEC(16,2),
		   dec(16,2), 
		   dec(16,2), 
		   dec(16,2), 
		   dec(16,2), 
		   dec(16,2), 
		   dec(16,2), 
		   dec(16,2), 
		   dec(16,2), 
		   char(4),
		   smallint; 

 BEGIN

	define _a_compania     CHAR(3); 
	define _a_agencia      CHAR(03);
	define _a_periodo      DATE; 
	define _a_codsucursal  CHAR(255);
	define _a_codramo      CHAR(255);
	define _a_serie        CHAR(4);
	define x_no_poliza     CHAR(10);
    DEFINE x_dif           DECIMAL(16,2);	
    DEFINE tx_dif           DECIMAL(16,2);	


    DEFINE v_codramo,v_codsucursal      CHAR(3);
    DEFINE v_desc_ramo,descr_cia        CHAR(45);
	DEFINE _no_unidad                   CHAR(5);
    DEFINE v_cant_polizas 				SMALLINT;
    DEFINE v_cant_coasegur1             SMALLINT;
    DEFINE v_cant_coasegur2 			SMALLINT;
    DEFINE mes 							SMALLINT;
    DEFINE v_prima_suscrita				DECIMAL(16,2);
    DEFINE v_prima_retenida				DECIMAL(16,2);	

    DEFINE _prima_suscrita				DECIMAL(16,2);
    DEFINE _prima_retenida				DECIMAL(16,2);
    DEFINE v_rango_inicial				DECIMAL(16,2);
    DEFINE v_rango_final				DECIMAL(16,2);
    DEFINE v_suma_asegurada				DECIMAL(16,2);
    DEFINE _suma_unidad 				DECIMAL(16,2);
    DEFINE v_suma_aseg_end 				DECIMAL(16,2);
    DEFINE codigo1         				SMALLINT;
    DEFINE v_fecha_cancel  				DATE;
    DEFINE _no_poliza      				CHAR(10);
    DEFINE v_filtros       				CHAR(255);
    DEFINE _tipo           				CHAR(1);
    DEFINE rango_max,_cnt  				INTEGER;
    DEFINE rango_min       				DECIMAL(16,2);
	DEFINE _limite_2_a     				DECIMAL(16,2);
	DEFINE _prima          				DECIMAL(16,2);
	DEFINE _limite_2_c        			DECIMAL(16,2);
	DEFINE _limite_1_b        			DECIMAL(16,2);
	DEFINE _limite_max        			DECIMAL(16,2);
    DEFINE mes1               			CHAR(02);
	DEFINE ano                			CHAR(04);
    DEFINE periodo1           			CHAR(07);
	DEFINE v_cod_tipoprod     			CHAR(03);
	DEFINE v_cod_cliente      			CHAR(10);
	DEFINE _fecha_emision	  			DATE;
	define _fecha_cancelacion 			DATE;
	DEFINE _no_endoso		  			CHAR(5);
	DEFINE _cod_ramo_tmp      			CHAR(3);

	define _suma_aseg_tot				dec(16,2);
	define _sum_ret 					dec(16,2);
	define _sum_cont					dec(16,2);
	define _sum_fac 					dec(16,2);
	define _sum_5						dec(16,2);
	define _sum_7 						dec(16,2);
	define _sum_pcont   				dec(16,2);
	define _sum_fcont					dec(16,2);
	define _sum_rcont					dec(16,2);
	define _prima_cont					dec(16,2);
	define _porc_prima                  dec(9,6);

	define _tipo_contrato				smallint;
	define _cod_contrato				char(5);
	define _serie						char(4);
    define s_ano_serie_ini              char(25);
    define s_ano_serie_fin              char(25);

    define _ano_serie_ini               smallint;
    define _ano_serie_fin               smallint;

    define _fecha_serie_ini             DATE;
    define _fecha_serie_fin             DATE;
	DEFINE _front						smallint;
	DEFINE _c_asegurado					CHAR(10);
	DEFINE _cantidad					smallint;
	define _concat                      VARCHAR(255);

--set debug file to "sp_pro2m.trc";
--trace on;

   CREATE TEMP TABLE temp_ubica
         (no_poliza          CHAR(10),
          suma_asegurada     DEC(16,2),
          prima_suscrita     DEC(16,2),
          prima_retenida     DEC(16,2),
		  sum_ret        	 dec(16,2) default 0,
		  sum_cont           dec(16,2) default 0,
		  sum_fac            dec(16,2) default 0,
		  sum_pcont          dec(16,2) default 0,
		  sum_fcont          dec(16,2) default 0,
		  sum_rcont          dec(16,2) default 0,
		  sum_5              dec(16,2) default 0,
		  sum_7              dec(16,2) default 0,
		  serie				 char(4),
		  seleccionado       smallint  default 1,
          PRIMARY KEY (no_poliza))
          WITH NO LOG;

   CREATE TEMP TABLE temp_unidad
         (no_poliza          CHAR(10),
		  no_unidad          CHAR(5),
          suma_asegurada     DEC(16,2),
          cod_ramo           CHAR(3),
          prima_suscrita     DEC(16,2),
          prima_retenida     DEC(16,2),
		  serie				 char(4),
		  seleccionado       smallint default 1,
          PRIMARY KEY (no_poliza,no_unidad,cod_ramo))
          WITH NO LOG;

   CREATE TEMP TABLE temp_cliente
          (cod_ramo         CHAR(03),
		  cod_asegurado	   CHAR(10),
          rango_inicial    DECIMAL(16,2),
          rango_final      DECIMAL(16,2),
          cantidad         SMALLINT,
		  seleccionado       smallint default 1,
          PRIMARY KEY (cod_ramo,cod_asegurado,rango_inicial,rango_final))
          WITH NO LOG;

   LET descr_cia = sp_sis01(a_compania);

   CREATE TEMP TABLE temp_civil
         (cod_sucursal     CHAR(03),
          cod_ramo         CHAR(03),
          rango_inicial    DECIMAL(16,2),
          rango_final      DECIMAL(16,2),
          cant_polizas     SMALLINT,
          prima_suscrita   DEC(16,2),
          prima_retenida   DEC(16,2),
          cant_coasegur1   SMALLINT,
          cant_coasegur2   SMALLINT,
          seleccionado     SMALLINT DEFAULT 1,
		  suma_asegurada   dec(16,2),	
		  sum_ret          dec(16,2) default 0,
		  sum_cont         dec(16,2) default 0,
		  sum_fac          dec(16,2) default 0,
		  sum_pcont        dec(16,2) default 0,
		  sum_fcont        dec(16,2) default 0,
		  sum_rcont        dec(16,2) default 0,
		  sum_5            dec(16,2) default 0,
		  sum_7            dec(16,2) default 0,
          PRIMARY KEY (cod_ramo,rango_inicial)) WITH NO LOG;

   CREATE INDEX iend1_temp_civil ON temp_civil(cod_sucursal);
   CREATE INDEX iend2_temp_civil ON temp_civil(cod_ramo);

	LET _a_compania = a_compania;
	LET  _a_agencia = a_agencia;
	LET  _a_periodo = a_periodo; 
	LET  _a_codsucursal = a_codsucursal;
	LET  _a_codramo = a_codramo;

    LET v_codramo        = NULL;
    LET v_desc_ramo      = NULL;
    LET v_rango_inicial  = 0;
    LET v_rango_final    = 0;
    LET v_cant_polizas   = 0;
    LET v_cant_coasegur1 = 0;
    LET v_cant_coasegur2 = 0;
    LET v_prima_suscrita = 0;
    LET v_prima_retenida = 0;
    LET _prima_suscrita  = 0;
    LET _prima_retenida  = 0;
    LET v_suma_asegurada = 0;
	LET v_suma_aseg_end  = 0;
    LET _no_poliza       = NULL;
    LET v_cant_coasegur1 = 0;
    LET v_cant_coasegur2 = 0;
	LET v_filtros ="";
	let _ano_serie_ini = year(today);
	let _ano_serie_fin = year(today);
	let s_ano_serie_ini = "";
	let s_ano_serie_fin = "";

    LET mes 		 = MONTH(a_periodo);
  	IF mes <= 9 THEN
	   LET mes1[1,1] = '0';
	   LET mes1[2,2] = mes;
	ELSE
	   LET mes1 = mes;
	END IF

    LET ano = YEAR(a_periodo);
	LET periodo1[1,4] = ano;
	LET periodo1[5] = "-";
	LET periodo1[6,7] = mes1;

   SET ISOLATION TO DIRTY READ;
--   set debug file to "sp_pro02.trc";

	IF a_serie <> "*" THEN
	    LET v_filtros = TRIM(v_filtros) || "Serie " || TRIM(a_serie);
		LET _tipo = sp_sis04(a_serie); 
--		trace on;
		LET a_serie = trim(a_serie);
		LET _tipo = trim(_tipo);
		IF _tipo <> "E" THEN
		    FOREACH
				SELECT codigo INTO s_ano_serie_ini  FROM tmp_codigos ORDER BY 1 
				EXIT FOREACH;
			END FOREACH
		    FOREACH
				SELECT codigo INTO s_ano_serie_fin  FROM tmp_codigos ORDER BY 1 DESC 
				EXIT FOREACH;
			END FOREACH
		END IF
		DROP TABLE tmp_codigos;

		LET _ano_serie_ini   = s_ano_serie_ini;
		LET _ano_serie_fin   = s_ano_serie_fin;

		LET _fecha_serie_ini = "01/01/" || trim(s_ano_serie_ini);
		LET _fecha_serie_fin = "31/12/" || trim(s_ano_serie_fin);

	ELSE
		LET a_serie = "1900";	 -- si no selecciona serie entonces se mantiene en serie default

		LET _ano_serie_ini   = a_serie;
		LET _ano_serie_fin   = _ano_serie_ini + 1;
	--	LET _fecha_serie_ini = "01/07/" || _ano_serie_ini;
	--	LET _fecha_serie_fin = "30/06/" || _ano_serie_fin;
		LET _fecha_serie_ini = "01/01/" || _ano_serie_ini;
		LET _fecha_serie_fin = "31/12/" || _ano_serie_ini;

	    LET v_filtros = TRIM(v_filtros) || "Serie " || TRIM(a_serie)||" ; ";
	END IF

    IF _fecha_serie_fin > a_periodo THEN
		LET _fecha_serie_fin = a_periodo;
	END IF

--trace off;


IF a_codramo <> "*" THEN

  LET _tipo = sp_sis04(a_codramo); -- Separa los valores del String

  IF _tipo <> "E" THEN -- Incluir los Registros

		FOREACH
				SELECT a.no_poliza,
			           a.fecha_cancelacion,
			           a.cod_ramo,
			           a.cod_sucursal,
			           a.suma_asegurada,
			           a.cod_tipoprod,
					   b.no_endoso,
					   year(a.vigencia_inic)
			      INTO _no_poliza,
			           v_fecha_cancel,
			           v_codramo,
			           v_codsucursal,
			           v_suma_asegurada,
			           v_cod_tipoprod,
					   _no_endoso,
					   _serie
			      FROM emipomae a, endedmae b
			     WHERE a.cod_compania      = a_compania
			       AND (a.vigencia_final   >= a_periodo
			   	    OR a.vigencia_final    IS NULL)
				   AND a.fecha_suscripcion <= a_periodo
				   AND a.actualizado       = 1
  				   AND a.cod_ramo          IN(SELECT codigo FROM tmp_codigos)
				   AND b.no_poliza         = a.no_poliza
				   AND b.periodo           <= periodo1
				   AND b.fecha_emision     <= a_periodo
			   	   AND b.actualizado 	   = 1
			   	   AND a.vigencia_inic     >= _fecha_serie_ini
				   AND a.vigencia_inic     <  _fecha_serie_fin

			    LET _fecha_emision = null;

			    IF v_fecha_cancel <= a_periodo THEN

				    FOREACH
						SELECT fecha_emision
						  INTO _fecha_emision
						  FROM endedmae
						 WHERE no_poliza     = _no_poliza
						   AND cod_endomov   = '002'
						   AND vigencia_inic = v_fecha_cancel
					END FOREACH

					IF  _fecha_emision <= a_periodo THEN
					    LET _prima_suscrita   = 0;
						LET _prima_retenida   = 0;
						CONTINUE FOREACH;
					END IF

				END IF

			    LET _prima_suscrita   = 0;
				LET _prima_retenida   = 0;

				--Sacar suma asegurada de la unidad

				if v_codramo = "018" or v_codramo = "002" or v_codramo = "016" then

					let _prima = 0;

					foreach
					    select suma_asegurada,
						       no_unidad
						  into _suma_unidad,
							   _no_unidad
						  from emipouni
						 where no_poliza = _no_poliza

						select sum(prima_suscrita),
						       sum(prima_retenida)
						  into _prima_suscrita,
							   _prima_retenida
						  from endeduni
						 where no_poliza = _no_poliza
						   and no_unidad = _no_unidad;

						if v_codramo = "002" then

						   {	select sum(prima)
							  into _prima
							  from emifacon
							 where no_poliza      = _no_poliza
							   and no_unidad      = _no_unidad
							   and cod_cober_reas = "002"
							   and cod_contrato   = "00562";

							let _prima_retenida = _prima_retenida + _prima;}

						   let _prima_retenida = _prima_suscrita;

						end if

					   BEGIN
					      ON EXCEPTION IN(-239)
					      END EXCEPTION

					      INSERT INTO temp_unidad
						  VALUES
						  (
						  _no_poliza,
						  _no_unidad,
						  _suma_unidad,
						  v_codramo,
						  _prima_suscrita,
						  _prima_retenida,
						  _serie,
						  1
						  );
					   END

					end foreach

				end if


		        SELECT prima_suscrita,
				  	   prima_retenida
		          INTO _prima_suscrita,
				  	   _prima_retenida
		          FROM endedmae
		         WHERE no_poliza = _no_poliza
				   AND fecha_emision  <= a_periodo
				   and cod_endomov <> '002'
				   AND no_endoso = _no_endoso;


			    if _prima_suscrita   is NULL then 
			        LET _prima_suscrita   = 0;
				end if
			    if  _prima_retenida    is NULL then 
    				LET _prima_retenida   = 0;
				end if

				let _sum_ret  	= 0.00;
				let _sum_cont 	= 0.00;
				let _sum_fac  	= 0.00;
				let _sum_pcont  = 0.00;
				let _sum_fcont  = 0.00;
				let _sum_rcont  = 0.00;
				let _sum_5 		= 0.00;
				let _sum_7 		= 0.00;
				let _suma_aseg_tot = 0.00;

			   foreach
				select a.cod_contrato, a.porc_partic_prima,
				       sum(a.suma_asegurada),
					   sum(a.prima)
				  into _cod_contrato, _porc_prima,
				       _suma_aseg_tot,
					   _prima_cont
				  from emifacon a, endedmae b
				 where a.no_poliza = _no_poliza
				   and a.no_poliza = b.no_poliza
				   and a.no_endoso = b.no_endoso
				   and b.cod_endomov <> '002'
				   and a.no_endoso = _no_endoso
                   and b.fecha_emision  <= a_periodo
				 group by a.cod_contrato , a.porc_partic_prima
				 order by a.cod_contrato , a.porc_partic_prima

				select tipo_contrato, fronting
				  into _tipo_contrato, _front
				  from reacomae
				 where cod_contrato = _cod_contrato;

					if _tipo_contrato = 1 then			-- Si 	es 100 % retencion entonces no contar 
						if _porc_prima = 100 then
							let _sum_ret  	= 0.00;
							let _sum_cont 	= 0.00;
							let _sum_fac  	= 0.00;
							let _sum_pcont  = 0.00;
							let _sum_fcont  = 0.00;
							let _sum_rcont  = 0.00;
							let _suma_aseg_tot = 0.00;
							let _prima_suscrita = 0.00;
				  	        let _prima_retenida = 0.00;
						else
							let _sum_ret = _sum_ret + _suma_aseg_tot;
							let _sum_rcont = _sum_rcont + _prima_cont;
						end if
					elif _tipo_contrato = 3 then
						let _sum_fac = _sum_fac + _suma_aseg_tot;
						let _sum_fcont = _sum_fcont + _prima_cont;
					else
						let _sum_cont = _sum_cont + _suma_aseg_tot;
						let _sum_pcont = _sum_pcont + _prima_cont;

						if _tipo_contrato = 5 then
							let _sum_5 = _sum_5 + _suma_aseg_tot;
						end if
						if _tipo_contrato = 7 then
							let _sum_7 = _sum_7 + _suma_aseg_tot;
						end if
					end if

				end foreach					   
					
			  let v_suma_asegurada = _sum_ret + _sum_cont + _sum_fac;

		      IF  _sum_cont <= 0 THEN
				CONTINUE FOREACH;
			  END IF

			  if v_codramo = "018" or v_codramo = "002" or v_codramo = "016" then
			  else
				  if _front = 0 then   -- Si encuentran poliza distinta de fronting
--				  if _front = 0 and _sum_fac <= 0  then   -- Si encuentran poliza distinta de fronting
				   BEGIN
				      ON EXCEPTION IN(-239,-268)
				         UPDATE temp_ubica
				            SET suma_asegurada = suma_asegurada + v_suma_asegurada,
				                prima_suscrita = prima_suscrita + _prima_suscrita,
				                prima_retenida = prima_retenida + _prima_retenida,
								sum_ret        = sum_ret        + _sum_ret,
								sum_cont       = sum_cont       + _sum_cont,
								sum_fac        = sum_fac        + _sum_fac,
								sum_rcont      = sum_rcont      + _sum_rcont,
								sum_pcont      = sum_pcont      + _sum_pcont,
								sum_fcont      = sum_fcont      + _sum_fcont
				          WHERE no_poliza      = _no_poliza;	

{				         UPDATE temp_ubica
				            SET prima_suscrita = prima_suscrita + _prima_suscrita,
				                prima_retenida = prima_retenida + _prima_retenida
				          WHERE no_poliza      = _no_poliza; }
				      END EXCEPTION

				      INSERT INTO temp_ubica
					  VALUES
					  (
					  _no_poliza,
					  v_suma_asegurada,
					  _prima_suscrita,
					  _prima_retenida,
					  _sum_ret, 
					  _sum_cont,
					  _sum_fac,					  
					  _sum_pcont,
					  _sum_fcont,
					  _sum_rcont,
					  _sum_5,
					  _sum_7,
					  _serie,
					  1
					  );

				   END
			    end if
			  end if

		END FOREACH

	else

		FOREACH
				SELECT a.no_poliza,
			           a.fecha_cancelacion,
			           a.cod_ramo,
			           a.cod_sucursal,
			           a.suma_asegurada,
			           a.cod_tipoprod,
					   b.no_endoso,
					   year(a.vigencia_inic)
			      INTO _no_poliza,
			           v_fecha_cancel,
			           v_codramo,
			           v_codsucursal,
			           v_suma_asegurada,
			           v_cod_tipoprod,
					   _no_endoso,
					   _serie
			      FROM emipomae a, endedmae b
			     WHERE a.cod_compania      = a_compania
			       AND (a.vigencia_final   >= a_periodo
			   	    OR a.vigencia_final    IS NULL)
				   AND a.fecha_suscripcion <= a_periodo
				   AND a.actualizado       = 1
  				   AND a.cod_ramo         NOT IN(SELECT codigo FROM tmp_codigos)
				   AND b.no_poliza         = a.no_poliza
				   AND b.periodo           <= periodo1
				   AND b.fecha_emision     <= a_periodo
			   	   AND b.actualizado 	   = 1
			   	   AND a.vigencia_inic     >= _fecha_serie_ini
				   AND a.vigencia_inic     <  _fecha_serie_fin

			    LET _fecha_emision = null;

			    IF v_fecha_cancel <= a_periodo THEN
				    FOREACH
						SELECT fecha_emision
						  INTO _fecha_emision
						  FROM endedmae
						 WHERE no_poliza     = _no_poliza
						   AND cod_endomov   = '002'
						   AND vigencia_inic = v_fecha_cancel
					END FOREACH

					IF  _fecha_emision <= a_periodo THEN
					    LET _prima_suscrita   = 0;
						LET _prima_retenida   = 0;
						CONTINUE FOREACH;
					END IF
				END IF

			    LET _prima_suscrita   = 0;
				LET _prima_retenida   = 0;

				--Sacar suma asegurada de la unidad

				if v_codramo = "018" or v_codramo = "002" or v_codramo = "016" then

					let _prima = 0;

					foreach
					    select suma_asegurada,
						       no_unidad
						  into _suma_unidad,
							   _no_unidad
						  from emipouni
						 where no_poliza = _no_poliza

						select sum(prima_suscrita),
						       sum(prima_retenida)
						  into _prima_suscrita,
							   _prima_retenida
						  from endeduni
						 where no_poliza = _no_poliza
						   and no_unidad = _no_unidad;

						if v_codramo = "002" then
						   {	select sum(prima)
							  into _prima
							  from emifacon
							 where no_poliza      = _no_poliza
							   and no_unidad      = _no_unidad
							   and cod_cober_reas = "002"
							   and cod_contrato   = "00562";

							let _prima_retenida = _prima_retenida + _prima;}

						   let _prima_retenida = _prima_suscrita;
						end if

					   BEGIN
					      ON EXCEPTION IN(-239)
					      END EXCEPTION

					      INSERT INTO temp_unidad
						  VALUES
						  (
						  _no_poliza,
						  _no_unidad,
						  _suma_unidad,
						  v_codramo,
						  _prima_suscrita,
						  _prima_retenida,
						  _serie,
						  1
						  );
					   END

					end foreach
				end if

		        SELECT prima_suscrita,
				  	   prima_retenida
		          INTO _prima_suscrita,
				  	   _prima_retenida
		          FROM endedmae
		         WHERE no_poliza = _no_poliza
				   AND fecha_emision  <= a_periodo
				   and cod_endomov <> '002'
				   AND no_endoso = _no_endoso;

			    if _prima_suscrita   is NULL then 
			        LET _prima_suscrita   = 0;
				end if
			    if  _prima_retenida    is NULL then 
    				LET _prima_retenida   = 0;
				end if


				let _sum_ret    = 0.00;
				let _sum_cont   = 0.00;
				let _sum_fac    = 0.00;
				let _sum_pcont  = 0.00;
				let _sum_fcont  = 0.00;
				let _sum_rcont  = 0.00;
				let _sum_5      = 0.00;
				let _sum_7      = 0.00;
				let _suma_aseg_tot = 0.00;


			   foreach
				select a.cod_contrato, a.porc_partic_prima,
				       sum(a.suma_asegurada),
					   sum(a.prima)
				  into _cod_contrato, _porc_prima,
				       _suma_aseg_tot,
					   _prima_cont
				  from emifacon a, endedmae b
				 where a.no_poliza = _no_poliza
				   and a.no_poliza = b.no_poliza
				   and a.no_endoso = b.no_endoso
				   and b.cod_endomov <> '002'
				   and a.no_endoso = _no_endoso
                   and b.fecha_emision  <= a_periodo
				 group by a.cod_contrato , a.porc_partic_prima
				 order by a.cod_contrato , a.porc_partic_prima

				select tipo_contrato, fronting
				  into _tipo_contrato, _front
				  from reacomae
				 where cod_contrato = _cod_contrato;

					if _tipo_contrato = 1 then
						if _porc_prima = 100 then
							let _sum_ret  	= 0.00;
							let _sum_cont 	= 0.00;
							let _sum_fac  	= 0.00;
							let _sum_pcont  = 0.00;
							let _sum_fcont  = 0.00;
							let _sum_rcont  = 0.00;
							let _suma_aseg_tot = 0.00;
							let _prima_suscrita = 0.00;
				  	        let _prima_retenida = 0.00;

						else
							let _sum_ret = _sum_ret + _suma_aseg_tot;
							let _sum_rcont = _sum_rcont + _prima_cont;
						end if
					elif _tipo_contrato = 3 then
						let _sum_fac = _sum_fac + _suma_aseg_tot;
						let _sum_fcont = _sum_fcont + _prima_cont;
					else
						let _sum_cont = _sum_cont + _suma_aseg_tot;
						let _sum_pcont = _sum_pcont + _prima_cont;

						if _tipo_contrato = 5 then
							let _sum_5 = _sum_5 + _suma_aseg_tot;
						end if
						if _tipo_contrato = 7 then
							let _sum_7 = _sum_7 + _suma_aseg_tot;
						end if
					end if

				end foreach					   
					
			  let v_suma_asegurada = _sum_ret + _sum_cont + _sum_fac;

		      IF  _sum_cont <= 0 THEN
				CONTINUE FOREACH;
			  END IF


			  if v_codramo = "018" or v_codramo = "002" or v_codramo = "016" then
			  else
				  if _front = 0 then   -- Si encuentran poliza distinta de fronting
--				  if _front = 0 and _sum_fac <= 0  then   -- Si encuentran poliza distinta de fronting
				   BEGIN
				      ON EXCEPTION IN(-239)
				         UPDATE temp_ubica
				            SET suma_asegurada = suma_asegurada + v_suma_asegurada,
				                prima_suscrita = prima_suscrita + _prima_suscrita,
				                prima_retenida = prima_retenida + _prima_retenida,
								sum_ret        = sum_ret        + _sum_ret,
								sum_cont       = sum_cont       + _sum_cont,
								sum_fac        = sum_fac        + _sum_fac,
								sum_rcont      = sum_rcont      + _sum_rcont,
								sum_pcont      = sum_pcont      + _sum_pcont,
								sum_fcont      = sum_fcont      + _sum_fcont
				          WHERE no_poliza      = _no_poliza;	

{				         UPDATE temp_ubica
				            SET prima_suscrita = prima_suscrita + _prima_suscrita,
				                prima_retenida = prima_retenida + _prima_retenida
				          WHERE no_poliza      = _no_poliza; 					 }
				      END EXCEPTION

				      INSERT INTO temp_ubica
					  VALUES
					  (
					  _no_poliza,
					  v_suma_asegurada,
					  _prima_suscrita,
					  _prima_retenida,
					  _sum_ret, 
					  _sum_cont,
					  _sum_fac,
					  _sum_pcont,
					  _sum_fcont,
					  _sum_rcont,
					  _sum_5,
					  _sum_7,
					  _serie,
					  1
					  );

				   END
				 end if
			  end if

		END FOREACH
	end if

	DROP TABLE tmp_codigos;

else

	FOREACH
		SELECT a.no_poliza,
	           a.fecha_cancelacion,
	           a.cod_ramo,
	           a.cod_sucursal,
	           a.suma_asegurada,
	           a.cod_tipoprod,
			   b.no_endoso,
			   year(a.vigencia_inic)
	      INTO _no_poliza,
	           v_fecha_cancel,
	           v_codramo,
	           v_codsucursal,
	           v_suma_asegurada,
	           v_cod_tipoprod,
			   _no_endoso,
			   _serie
	      FROM emipomae a, endedmae b
	     WHERE a.cod_compania      = a_compania
	       AND (a.vigencia_final   >= a_periodo
	   	    OR a.vigencia_final    IS NULL)
		   AND a.fecha_suscripcion <= a_periodo
		   AND a.actualizado       = 1
		   AND b.no_poliza         = a.no_poliza
		   AND b.periodo           <= periodo1
		   AND b.fecha_emision     <= a_periodo
	   	   AND b.actualizado 	   = 1
	   	   AND a.vigencia_inic     >= _fecha_serie_ini
		   AND a.vigencia_inic     <  _fecha_serie_fin

	    LET _fecha_emision = null;

	    IF v_fecha_cancel <= a_periodo THEN
		    FOREACH
				SELECT fecha_emision
				  INTO _fecha_emision
				  FROM endedmae
				 WHERE no_poliza     = _no_poliza
				   AND cod_endomov   = '002'
				   AND vigencia_inic = v_fecha_cancel
			END FOREACH

			IF  _fecha_emision <= a_periodo THEN
			    LET _prima_suscrita   = 0;
				LET _prima_retenida   = 0;
				CONTINUE FOREACH;
			END IF
		END IF

	    LET _prima_suscrita   = 0;
		LET _prima_retenida   = 0;

		--Sacar suma asegurada de la unidad

		if v_codramo = "018" or v_codramo = "002" or v_codramo = "016" then

			let _prima = 0;

			foreach
			    select suma_asegurada,
				       no_unidad
				  into _suma_unidad,
					   _no_unidad
				  from emipouni
				 where no_poliza = _no_poliza

				select sum(prima_suscrita),
				       sum(prima_retenida)
				  into _prima_suscrita,
					   _prima_retenida
				  from endeduni
				 where no_poliza = _no_poliza
				   and no_unidad = _no_unidad;

				if v_codramo = "002" then
				   {	select sum(prima)
					  into _prima
					  from emifacon
					 where no_poliza      = _no_poliza
					   and no_unidad      = _no_unidad
					   and cod_cober_reas = "002"
					   and cod_contrato   = "00562";

					let _prima_retenida = _prima_retenida + _prima;}

				   let _prima_retenida = _prima_suscrita;
				end if

			   BEGIN
			      ON EXCEPTION IN(-239)
			      END EXCEPTION

			      INSERT INTO temp_unidad
				  VALUES
				  (
				  _no_poliza,
				  _no_unidad,
				  _suma_unidad,
				  v_codramo,
				  _prima_suscrita,
				  _prima_retenida,
				  _serie,
				  1
				  );
			   END

			end foreach

		end if


        SELECT prima_suscrita,
		  	   prima_retenida
          INTO _prima_suscrita,
		  	   _prima_retenida
          FROM endedmae
         WHERE no_poliza = _no_poliza
		   AND fecha_emision  <= a_periodo
		   and cod_endomov <> '002'
		   AND no_endoso = _no_endoso;

			    if _prima_suscrita   is NULL then 
			        LET _prima_suscrita   = 0;
				end if
			    if  _prima_retenida    is NULL then 
    				LET _prima_retenida   = 0;
				end if


				let _sum_ret  	= 0.00;
				let _sum_cont 	= 0.00;
				let _sum_fac  	= 0.00;
				let _sum_pcont 	= 0.00;
				let _sum_fcont  = 0.00;
				let _sum_rcont  = 0.00;
				let _sum_5 		= 0.00;
				let _sum_7 		= 0.00;
				let _suma_aseg_tot = 0.00;

			   foreach
				select a.cod_contrato, a.porc_partic_prima,
				       sum(a.suma_asegurada),
					   sum(a.prima)
				  into _cod_contrato, _porc_prima,
				       _suma_aseg_tot,
					   _prima_cont
				  from emifacon a, endedmae b
				 where a.no_poliza = _no_poliza
				   and a.no_poliza = b.no_poliza
				   and a.no_endoso = b.no_endoso
				   and b.cod_endomov <> '002'
				   and a.no_endoso = _no_endoso
                   and b.fecha_emision  <= a_periodo
				 group by a.cod_contrato , a.porc_partic_prima
				 order by a.cod_contrato , a.porc_partic_prima

				select tipo_contrato, fronting
				  into _tipo_contrato, _front
				  from reacomae
				 where cod_contrato = _cod_contrato;

					if _tipo_contrato = 1 then
						if _porc_prima = 100 then
							let _sum_ret  	= 0.00;
							let _sum_cont 	= 0.00;
							let _sum_fac  	= 0.00;
							let _sum_pcont  = 0.00;
							let _sum_fcont  = 0.00;
							let _sum_rcont  = 0.00;
							let _suma_aseg_tot = 0.00;
							let _prima_suscrita = 0.00;
				  	        let _prima_retenida = 0.00;

						else
							let _sum_ret = _sum_ret + _suma_aseg_tot;
							let _sum_rcont = _sum_rcont + _prima_cont;
						end if
					elif _tipo_contrato = 3 then
						let _sum_fac = _sum_fac + _suma_aseg_tot;
						let _sum_fcont = _sum_fcont + _prima_cont;
					else
						let _sum_cont = _sum_cont + _suma_aseg_tot;
						let _sum_pcont = _sum_pcont + _prima_cont;

						if _tipo_contrato = 5 then
							let _sum_5 = _sum_5 + _suma_aseg_tot;
						end if
						if _tipo_contrato = 7 then
							let _sum_7 = _sum_7 + _suma_aseg_tot;
						end if
					end if

				end foreach					   
					
			  let v_suma_asegurada = _sum_ret + _sum_cont + _sum_fac;


		      IF  _sum_cont <= 0 THEN
				CONTINUE FOREACH;
			  END IF


			  if v_codramo = "018" or v_codramo = "002" or v_codramo = "016" then
			  else
				  if _front = 0 then   -- Si encuentran poliza distinta de fronting
--				  if _front = 0 and _sum_fac <= 0  then   -- Si encuentran poliza distinta de fronting
				   BEGIN
				      ON EXCEPTION IN(-239)
				         UPDATE temp_ubica
				            SET suma_asegurada = suma_asegurada + v_suma_asegurada,
				                prima_suscrita = prima_suscrita + _prima_suscrita,
				                prima_retenida = prima_retenida + _prima_retenida,
								sum_ret        = sum_ret        + _sum_ret,
								sum_cont       = sum_cont       + _sum_cont,
								sum_fac        = sum_fac        + _sum_fac,
								sum_rcont      = sum_rcont      + _sum_rcont,
								sum_pcont      = sum_pcont      + _sum_pcont,
								sum_fcont      = sum_fcont      + _sum_fcont
				          WHERE no_poliza      = _no_poliza;	

{				         UPDATE temp_ubica
				            SET prima_suscrita = prima_suscrita + _prima_suscrita,
				                prima_retenida = prima_retenida + _prima_retenida
				          WHERE no_poliza      = _no_poliza; 					 }
				      END EXCEPTION

				      INSERT INTO temp_ubica
					  VALUES
					  (
					  _no_poliza,
					  v_suma_asegurada,
					  _prima_suscrita,
					  _prima_retenida,
					  _sum_ret, 
					  _sum_cont,
					  _sum_fac,
					  _sum_pcont,
					  _sum_fcont,
					  _sum_rcont,
					  _sum_5,
					  _sum_7,
					  _serie,
					  1
					  );

				   END
				 end if
			  end if
END FOREACH
end if


DROP TABLE temp_civil;
DROP TABLE temp_ubica;
DROP TABLE temp_unidad;
DROP TABLE temp_cliente;


END

END PROCEDURE;
