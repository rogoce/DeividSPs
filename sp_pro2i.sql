--------------------------------------------
---            POLIZAS VIGENTES            ---
---  Yinia M. Zamora - agosto 2000 - YMZM
---  Modificado por Amado Perez Octubre 2001 
---  Modificado por Armando Moreno Nov. 2001 (sacar psuscrita de endosos y no de emipomae)
---  Modificado por Armando Moreno Sep. 2007 (sacar suma aseg. de unidad para ramo 002,y no de emipomae)
---  Modificado por Amado Perez Abril 2009 Reporte especial para Omar Wong para las reaseguradoras
---  Modificado por Henry Giron utilizar varias series  [ANT:a_serie char(4) DEFAULT "1900")] Solicitud: Omar Wong 23/07/2010
---  Ref. Power Builder - d_sp_pro02  execute procedure sp_pro02i("001","*",'31/03/2011',"*","014;", "2008,2009,2010,2011;" )
--------------------------------------------
DROP procedure sp_pro02i;
CREATE procedure "informix".sp_pro02i(a_compania CHAR(3),a_agencia  CHAR(03) DEFAULT "*",a_periodo DATE,a_codsucursal CHAR(255) DEFAULT "*",a_codramo CHAR(255) DEFAULT "*", a_serie char(255) default "*" )
RETURNING DEC(16,2),
		  DEC(16,2),
		  SMALLINT,
		  DEC(16,2),
          DEC(16,2),
          SMALLINT,
          SMALLINT,
          CHAR(03),
          CHAR(45),
          DATE,
          CHAR(45),
          CHAR(255),
          DEC(16,2),
          DEC(16,2),
          DEC(16,2),
          DEC(16,2),
          SMALLINT,
          DEC(16,2);

 BEGIN

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
	define _sum_fac_car 				dec(16,2);


	define _tipo_contrato				smallint;
	define _cod_contrato				char(5);
	define _serie						char(4);
    define s_ano_serie_ini              char(25);
    define s_ano_serie_fin              char(25);

    define _ano_serie_ini               smallint;
    define _ano_serie_fin               smallint;

    define _fecha_serie_ini             DATE;
    define _fecha_serie_fin             DATE;
	define _conteo 						smallint;
	define _cod_cober_reas				char(3);
	define _fronting 					smallint;
	define _cant_unidad                 smallint;

   CREATE TEMP TABLE temp_ubica
         (no_poliza          CHAR(10),
		  no_unidad          CHAR(5),
          suma_asegurada     DEC(16,2),
          prima_suscrita     DEC(16,2),
          prima_retenida     DEC(16,2),
		  sum_ret        	 dec(16,2) default 0,
		  sum_cont           dec(16,2) default 0,
		  sum_fac            dec(16,2) default 0,
		  sum_fac_car        dec(16,2) default 0,
		  serie				 char(4),
		  seleccionado       smallint  default 1,
          PRIMARY KEY (no_poliza,no_unidad))
          WITH NO LOG;
   CREATE INDEX iend1_temp_ubica ON temp_ubica(no_poliza);
   CREATE INDEX iend2_temp_ubica ON temp_ubica(no_unidad);

   CREATE TEMP TABLE temp_conteo
         (no_poliza          CHAR(10),
		  no_unidad          CHAR(5),
		  seleccionado       smallint  default 1,
          PRIMARY KEY (no_poliza,no_unidad))
          WITH NO LOG;
   CREATE INDEX iend1_temp_conteo ON temp_conteo(no_poliza);
   CREATE INDEX iend2_temp_conteo ON temp_conteo(no_unidad);


   CREATE TEMP TABLE temp_unidad
         (no_poliza          CHAR(10),
		  no_unidad          CHAR(5),
          suma_asegurada     DEC(16,2),
          cod_ramo           CHAR(3),
          prima_suscrita     DEC(16,2),
          prima_retenida     DEC(16,2),
		  serie				 char(4),
		  sum_ret            dec(16,2) default 0,
		  sum_cont           dec(16,2) default 0,
		  sum_fac            dec(16,2) default 0,
		  sum_fac_car        dec(16,2) default 0,
		  seleccionado       smallint default 1,
          PRIMARY KEY (no_poliza,no_unidad,cod_ramo))
          WITH NO LOG;

   CREATE INDEX iend1_temp_unidad ON temp_unidad(no_poliza);
   CREATE INDEX iend2_temp_unidad ON temp_unidad(no_unidad);
   CREATE INDEX iend3_temp_unidad ON temp_unidad(cod_ramo);

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
          cant_unidad      SMALLINT,
		  sum_fac_car      dec(16,2) default 0,
          PRIMARY KEY (cod_ramo,rango_inicial)) WITH NO LOG;

   CREATE INDEX iend1_temp_civil ON temp_civil(cod_ramo);
   CREATE INDEX iend2_temp_civil ON temp_civil(rango_inicial);
   CREATE INDEX iend3_temp_civil ON temp_civil(rango_final);

   CREATE TEMP TABLE temp_fact
         (no_poliza          CHAR(10),
		  no_endoso          CHAR(5),
		  no_factura         CHAR(10),
		  seleccionado       smallint  default 1,
		  suma_asegurada     dec(16,2),	
		  sum_ret            dec(16,2) default 0,
		  sum_cont           dec(16,2) default 0,
		  sum_fac            dec(16,2) default 0,
		  sum_fac_car        dec(16,2) default 0,
          prima_suscrita     DEC(16,2),
          prima_retenida     DEC(16,2),
          PRIMARY KEY (no_poliza,no_endoso,no_factura))
          WITH NO LOG;
   CREATE INDEX iend1_temp_fact ON temp_fact(no_poliza);
   CREATE INDEX iend2_temp_fact ON temp_fact(no_endoso);
   CREATE INDEX iend3_temp_fact ON temp_fact(no_factura);

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
	let _conteo          = 1;
	let _cod_cober_reas	 = "";
	let _fronting = 0;
	let _cant_unidad = 0;

    LET mes = MONTH(a_periodo);
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
--   Set debug file to "sp_pro02.trc";

	IF a_serie <> "*" THEN
	    LET v_filtros = TRIM(v_filtros) || "Serie " || TRIM(a_serie);
		LET _tipo = sp_sis04(a_serie); 
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
		LET a_serie = "1900";	 -- si no selecciona serie entonces se mantien en serie default
		LET _ano_serie_ini   = a_serie;
		LET _ano_serie_fin   = _ano_serie_ini + 1;
		LET _fecha_serie_ini = "01/01/" || _ano_serie_ini;	
		LET _fecha_serie_fin = "31/12/" || periodo1[1,4];
	    LET v_filtros = TRIM(v_filtros) || "Serie " || TRIM(a_serie)||" ; ";
	END IF

    IF _fecha_serie_fin > a_periodo THEN
		LET _fecha_serie_fin = a_periodo;
	END IF


IF a_codramo <> "*" THEN
  LET _tipo = sp_sis04(a_codramo); -- Separa los valores del String
  IF _tipo <> "E" THEN -- Incluir los Registros
--	   trace on;
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
			     WHERE a.cod_compania       = a_compania
			       AND (a.vigencia_final   >= a_periodo
			   	    OR a.vigencia_final    IS NULL)
				   AND a.fecha_suscripcion <= a_periodo
				   AND a.actualizado        = 1
  				   AND a.cod_ramo          IN(SELECT codigo FROM tmp_codigos)
				   AND b.no_poliza          = a.no_poliza
				   AND b.periodo           <= periodo1
				   AND b.fecha_emision     <= a_periodo
			   	   AND b.actualizado 	    = 1
			   	   AND a.vigencia_inic     >= _fecha_serie_ini
				   AND a.vigencia_inic     <= _fecha_serie_fin
--				   and b.no_documento       = "1411-00014-01" --"0109-00401-01"

				   let _fronting = 0;
				   let _fronting = sp_sis135(_no_poliza);

				   if _fronting = 1 then -- es fronting
						continue foreach;
					end if

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

				--Sacar suma asegurada de la unidad
				if v_codramo = "018" or v_codramo = "002" or v_codramo = "016" then

					let _prima = 0;

{					foreach
					    select suma_asegurada,
						       no_unidad
						  into _suma_unidad,
							   _no_unidad
						  from emipouni
						 where no_poliza = _no_poliza	}
					foreach
						SELECT b.no_unidad,
						       b.suma_asegurada
				          INTO _no_unidad,
						  	   _suma_unidad
						  FROM endedmae a, endeduni b
						 WHERE a.no_poliza = _no_poliza
						   AND a.no_endoso = _no_endoso
						   AND a.no_poliza = b.no_poliza
						   AND a.no_endoso = b.no_endoso

						select sum(prima_suscrita),
						       sum(prima_retenida)
						  into _prima_suscrita,
							   _prima_retenida
						  from endeduni
						 where no_poliza = _no_poliza
						   and no_unidad = _no_unidad;

						if v_codramo = "002" then
						   let _prima_retenida = _prima_suscrita;
						end if

						let _sum_ret      = 0.00;
						let _sum_cont     = 0.00;
						let _sum_fac      = 0.00;
						let _sum_fac_car  = 0.00;

					   foreach
						select a.cod_contrato,a.cod_cober_reas,
						       sum(a.suma_asegurada)
						  into _cod_contrato,
						       _cod_cober_reas,
						       _suma_aseg_tot
						  from emifacon a, endedmae b
						 where a.no_poliza = _no_poliza
						   and a.no_poliza = b.no_poliza
						   and a.no_endoso = b.no_endoso
						   and a.no_unidad = _no_unidad
			               AND a.no_endoso = _no_endoso
						   and b.cod_endomov <> '002'
						 group by a.cod_contrato,a.cod_cober_reas
						 order by a.cod_contrato,a.cod_cober_reas

							if (v_codramo = "001" or v_codramo = "003") and _cod_cober_reas = '021' then
							   continue foreach;
							end if

						select tipo_contrato
						  into _tipo_contrato
						  from reacomae
						 where cod_contrato = _cod_contrato;

							if _tipo_contrato = 1 then
								let _sum_ret = _sum_ret + _suma_aseg_tot;
							elif _tipo_contrato = 3 then
								let _sum_fac = _sum_fac + _suma_aseg_tot;
							else
								if _cod_contrato = "00574" or _cod_contrato = "00584" or _cod_contrato = "00594" or _cod_contrato = "00604" then
								   let _sum_fac_car = _sum_fac_car + _suma_aseg_tot;
								else
								   let _sum_cont = _sum_cont + _suma_aseg_tot;
								end if
							end if

						end foreach	
							
					  let v_suma_asegurada = _sum_ret + _sum_cont + _sum_fac + _sum_fac_car;

					  if _sum_fac = v_suma_asegurada and _sum_fac > 0 then
					  	 continue foreach;
					 end if

						   BEGIN
						      ON EXCEPTION IN(-239,-268)
						         UPDATE temp_unidad
						            SET sum_ret        = sum_ret     + _sum_ret, 
										sum_cont       = sum_cont    + _sum_cont,
										sum_fac        = sum_fac     + _sum_fac,
										sum_fac_car    = sum_fac_car + _sum_fac_car		
						          WHERE no_poliza      = _no_poliza
						            and no_unidad      = _no_unidad; 

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
							  _sum_ret, 
							  _sum_cont,
							  _sum_fac,
							  _sum_fac_car,
							  1
							  );

						   END

							   BEGIN
							      ON EXCEPTION IN(-239,-268)
							      END EXCEPTION

							      INSERT INTO temp_fact	( no_poliza,    
							      						  no_endoso,    
							      						  no_factura,   
							      						  seleccionado,
							      						  suma_asegurada,  
							      						  sum_ret,         
							      						  sum_cont,        
							      						  sum_fac,              
							      						  sum_fac_car,
														  prima_suscrita,
														  prima_retenida							      						       								      						  
							      						  )
								  select no_poliza,  
								  		 no_endoso,  
								  		 no_factura, 
								  		 1,
										 v_suma_asegurada, 
							      		 _sum_ret,     				      
							      		 _sum_cont,    				      
							      		 _sum_fac,     				      			      
							      		 _sum_fac_car,
										 prima_suscrita,
										 prima_retenida							      		   				     
								    from endedmae
								   where no_poliza = _no_poliza 
								  	 and no_endoso = _no_endoso;

							   END

--						end foreach
					end foreach

				end if

			     foreach
					SELECT b.no_unidad,
					       b.prima_suscrita, 
					       b.prima_retenida
			          INTO _no_unidad,
			               _prima_suscrita,
					  	   _prima_retenida
					  FROM endedmae a, endeduni b
					 WHERE a.no_poliza = _no_poliza
					   AND a.no_endoso = _no_endoso
					   AND a.no_poliza = b.no_poliza
					   AND a.no_endoso = b.no_endoso

						let _sum_ret  = 0.00;
						let _sum_cont = 0.00;
						let _sum_fac  = 0.00;
						let _sum_fac_car  = 0.00;

					   foreach
						select a.cod_contrato,a.cod_cober_reas,
						       sum(a.suma_asegurada)
						  into _cod_contrato,
						       _cod_cober_reas,
						       _suma_aseg_tot
						  from emifacon a, endedmae b
						 where a.no_poliza = _no_poliza
						   and a.no_poliza = b.no_poliza
						   and a.no_endoso = b.no_endoso
						   and a.no_unidad = _no_unidad
			               AND a.no_endoso = _no_endoso
						   and b.cod_endomov <> '002'
						 group by a.cod_contrato,a.cod_cober_reas
						 order by a.cod_contrato,a.cod_cober_reas

							if (v_codramo = "001" or v_codramo = "003") and _cod_cober_reas = '021' then
							   continue foreach;
							end if

						select tipo_contrato
						  into _tipo_contrato
						  from reacomae
						 where cod_contrato = _cod_contrato;

							if _tipo_contrato = 1 then
								let _sum_ret = _sum_ret + _suma_aseg_tot;
							elif _tipo_contrato = 3 then
								let _sum_fac = _sum_fac + _suma_aseg_tot;
							else
								if _cod_contrato = "00574" or _cod_contrato = "00584" or _cod_contrato = "00594" or _cod_contrato = "00604" then
								   let _sum_fac_car = _sum_fac_car + _suma_aseg_tot;
								else
								   let _sum_cont = _sum_cont + _suma_aseg_tot;
								end if
							end if

						end foreach	
							
					  let v_suma_asegurada = _sum_ret + _sum_cont + _sum_fac + _sum_fac_car;

					  if _sum_fac = v_suma_asegurada and _sum_fac > 0 then
					  	 continue foreach;
					 end if

					  if v_codramo = "018" or v_codramo = "002" or v_codramo = "016" then
					  else

						   BEGIN
						      ON EXCEPTION IN(-239,-268)
						         UPDATE temp_ubica
						            SET prima_suscrita = prima_suscrita + _prima_suscrita,
						                prima_retenida = prima_retenida + _prima_retenida,
										sum_ret        = sum_ret     + _sum_ret, 
										sum_cont       = sum_cont    + _sum_cont,
										sum_fac        = sum_fac     + _sum_fac,
										sum_fac_car    = sum_fac_car + _sum_fac_car,
										suma_asegurada = suma_asegurada + v_suma_asegurada										
						          WHERE no_poliza      = _no_poliza; 

						      END EXCEPTION

						      INSERT INTO temp_ubica
							  VALUES
							  (
							  _no_poliza,
							  _no_unidad,
							  v_suma_asegurada,
							  _prima_suscrita,
							  _prima_retenida,
							  _sum_ret, 
							  _sum_cont,
							  _sum_fac,
							  _sum_fac_car,
							  _serie,
							  1
							  );
						   END

						   BEGIN
						      ON EXCEPTION IN(-239,-268)
						      END EXCEPTION

						      INSERT INTO temp_fact	( no_poliza,    
						      						  no_endoso,    
						      						  no_factura,   
						      						  seleccionado,
						      						  suma_asegurada,  
						      						  sum_ret,         
						      						  sum_cont,        
						      						  sum_fac,              
						      						  sum_fac_car,
													  prima_suscrita,
													  prima_retenida							      						       								      						  
						      						  )
							  select no_poliza,  
							  		 no_endoso,  
							  		 no_factura, 
							  		 1,
									 v_suma_asegurada, 
						      		 _sum_ret,     				      
						      		 _sum_cont,    				      
						      		 _sum_fac,     				      			      
						      		 _sum_fac_car,
									 prima_suscrita,
									 prima_retenida							      		   				     
							    from endedmae
							   where no_poliza = _no_poliza 
							  	 and no_endoso = _no_endoso;

						   END


					  end if
			END FOREACH
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
				   AND a.vigencia_inic     <=  _fecha_serie_fin

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
						  0.00,
						  0.00,
						  0.00,
						  0.00,
						  1
						  );

					   END

						   BEGIN
						      ON EXCEPTION IN(-239,-268)
						      END EXCEPTION

						      INSERT INTO temp_fact	( no_poliza,    
						      						  no_endoso,    
						      						  no_factura,   
						      						  seleccionado,
						      						  suma_asegurada,  
						      						  sum_ret,         
						      						  sum_cont,        
						      						  sum_fac,              
						      						  sum_fac_car,
													  prima_suscrita,
													  prima_retenida							      						       								      						  
						      						  )
							  select no_poliza,  
							  		 no_endoso,  
							  		 no_factura, 
							  		 1,
									 v_suma_asegurada, 
						      		 _sum_ret,     				      
						      		 _sum_cont,    				      
						      		 _sum_fac,     				      			      
						      		 _sum_fac_car,
									 prima_suscrita,
									 prima_retenida							      		   				     
							    from endedmae
							   where no_poliza = _no_poliza 
							  	 and no_endoso = _no_endoso;

						   END


					end foreach

				end if


			     foreach
					SELECT b.no_unidad,
					       b.prima_suscrita, 
					       b.prima_retenida
			          INTO _no_unidad,
			               _prima_suscrita,
					  	   _prima_retenida
					  FROM endedmae a, endeduni b
					 WHERE a.no_poliza = _no_poliza
					   AND a.no_endoso = _no_endoso
					   AND a.no_poliza = b.no_poliza
					   AND a.no_endoso = b.no_endoso

						let _sum_ret  = 0.00;
						let _sum_cont = 0.00;
						let _sum_fac  = 0.00;
						let _sum_fac_car  = 0.00;

					   foreach
						select a.cod_contrato,a.cod_cober_reas,
						       sum(a.suma_asegurada)
						  into _cod_contrato,
						       _cod_cober_reas,
						       _suma_aseg_tot
						  from emifacon a, endedmae b
						 where a.no_poliza = _no_poliza
						   and a.no_poliza = b.no_poliza
						   and a.no_endoso = b.no_endoso
						   and a.no_unidad = _no_unidad
			               AND a.no_endoso = _no_endoso
						   and b.cod_endomov <> '002'
						 group by a.cod_contrato,a.cod_cober_reas
						 order by a.cod_contrato,a.cod_cober_reas

							if (v_codramo = "001" or v_codramo = "003") and _cod_cober_reas = '021' then
							   continue foreach;
							end if

						select tipo_contrato
						  into _tipo_contrato
						  from reacomae
						 where cod_contrato = _cod_contrato;

							if _tipo_contrato = 1 then
								let _sum_ret = _sum_ret + _suma_aseg_tot;
							elif _tipo_contrato = 3 then
								let _sum_fac = _sum_fac + _suma_aseg_tot;
							else
								if _cod_contrato = "00574" or _cod_contrato = "00584" or _cod_contrato = "00594" or _cod_contrato = "00604" then
								   let _sum_fac_car = _sum_fac_car + _suma_aseg_tot;
								else
								   let _sum_cont = _sum_cont + _suma_aseg_tot;
								end if
							end if

						end foreach					   
							
					  let v_suma_asegurada = _sum_ret + _sum_cont + _sum_fac + _sum_fac_car;

					  if _sum_fac = v_suma_asegurada and _sum_fac > 0 then
					  	 continue foreach;
					 end if

					  if v_codramo = "018" or v_codramo = "002" or v_codramo = "016" then
					  else

						   BEGIN
						      ON EXCEPTION IN(-239,-268)
						         UPDATE temp_ubica
						            SET prima_suscrita = prima_suscrita + _prima_suscrita,
						                prima_retenida = prima_retenida + _prima_retenida,
										sum_ret        = sum_ret     + _sum_ret, 
										sum_cont       = sum_cont    + _sum_cont,
										sum_fac        = sum_fac     + _sum_fac,
										sum_fac_car    = sum_fac_car + _sum_fac_car,
										suma_asegurada = suma_asegurada + v_suma_asegurada										
						          WHERE no_poliza      = _no_poliza; 

						      END EXCEPTION

						      INSERT INTO temp_ubica
							  VALUES
							  (
							  _no_poliza,
							  _no_unidad,
							  v_suma_asegurada,
							  _prima_suscrita,
							  _prima_retenida,
							  _sum_ret, 
							  _sum_cont,
							  _sum_fac,
							  _sum_fac_car,
							  _serie,
							  1
							  );
						   END

						   BEGIN
						      ON EXCEPTION IN(-239,-268)
						      END EXCEPTION

						      INSERT INTO temp_fact	( no_poliza,    
						      						  no_endoso,    
						      						  no_factura,   
						      						  seleccionado,
						      						  suma_asegurada,  
						      						  sum_ret,         
						      						  sum_cont,        
						      						  sum_fac,              
						      						  sum_fac_car,
													  prima_suscrita,
													  prima_retenida							      						       								      						  
						      						  )
							  select no_poliza,  
							  		 no_endoso,  
							  		 no_factura, 
							  		 1,
									 v_suma_asegurada, 
						      		 _sum_ret,     				      
						      		 _sum_cont,    				      
						      		 _sum_fac,     				      			      
						      		 _sum_fac_car,
									 prima_suscrita,
									 prima_retenida							      		   				     
							    from endedmae
							   where no_poliza = _no_poliza 
							  	 and no_endoso = _no_endoso;

						   END


					  end if
			END FOREACH
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
		   AND a.vigencia_inic     <=  _fecha_serie_fin

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
				  0.00,
				  0.00,
				  0.00,
				  0.00,
				  1
				  );

				 	INSERT INTO temp_conteo
					  VALUES
					  (
					  _no_poliza,
					  _no_unidad,
					  1 );

			   END

				   BEGIN
				      ON EXCEPTION IN(-239,-268)
				      END EXCEPTION

				      INSERT INTO temp_fact	( no_poliza,    
				      						  no_endoso,    
				      						  no_factura,   
				      						  seleccionado,
				      						  suma_asegurada,  
				      						  sum_ret,         
				      						  sum_cont,        
				      						  sum_fac,              
				      						  sum_fac_car,
											  prima_suscrita,
											  prima_retenida							      						       								      						  
				      						  )
					  select no_poliza,  
					  		 no_endoso,  
					  		 no_factura, 
					  		 1,
							 v_suma_asegurada, 
				      		 _sum_ret,     				      
				      		 _sum_cont,    				      
				      		 _sum_fac,     				      			      
				      		 _sum_fac_car,
							 prima_suscrita,
							 prima_retenida							      		   				     
					    from endedmae
					   where no_poliza = _no_poliza 
					  	 and no_endoso = _no_endoso;

				   END


			end foreach

		end if


			     foreach
					SELECT b.no_unidad,
					       b.prima_suscrita, 
					       b.prima_retenida
			          INTO _no_unidad,
			               _prima_suscrita,
					  	   _prima_retenida
					  FROM endedmae a, endeduni b
					 WHERE a.no_poliza = _no_poliza
					   AND a.no_endoso = _no_endoso
					   AND a.no_poliza = b.no_poliza
					   AND a.no_endoso = b.no_endoso

						let _sum_ret  = 0.00;
						let _sum_cont = 0.00;
						let _sum_fac  = 0.00;
						let _sum_fac_car  = 0.00;

					   foreach
						select a.cod_contrato,a.cod_cober_reas,
						       sum(a.suma_asegurada)
						  into _cod_contrato,
						       _cod_cober_reas,
						       _suma_aseg_tot
						  from emifacon a, endedmae b
						 where a.no_poliza = _no_poliza
						   and a.no_poliza = b.no_poliza
						   and a.no_endoso = b.no_endoso
						   and a.no_unidad = _no_unidad
			               AND a.no_endoso = _no_endoso
						   and b.cod_endomov <> '002'
						 group by a.cod_contrato,a.cod_cober_reas
						 order by a.cod_contrato,a.cod_cober_reas

							if (v_codramo = "001" or v_codramo = "003") and _cod_cober_reas = '021' then
							   continue foreach;
							end if

						select tipo_contrato
						  into _tipo_contrato
						  from reacomae
						 where cod_contrato = _cod_contrato;

							if _tipo_contrato = 1 then
								let _sum_ret = _sum_ret + _suma_aseg_tot;
							elif _tipo_contrato = 3 then
								let _sum_fac = _sum_fac + _suma_aseg_tot;
							else
								if _cod_contrato = "00574" or _cod_contrato = "00584" or _cod_contrato = "00594" or _cod_contrato = "00604" then
								   let _sum_fac_car = _sum_fac_car + _suma_aseg_tot;
								else
								   let _sum_cont = _sum_cont + _suma_aseg_tot;
								end if
							end if

						end foreach					   
							
					  let v_suma_asegurada = _sum_ret + _sum_cont + _sum_fac + _sum_fac_car;

					  if _sum_fac = v_suma_asegurada and _sum_fac > 0 then
					  	 continue foreach;
					 end if

					  if v_codramo = "018" or v_codramo = "002" or v_codramo = "016" then
					  else

						   BEGIN
						      ON EXCEPTION IN(-239,-268)
						         UPDATE temp_ubica
						            SET prima_suscrita = prima_suscrita + _prima_suscrita,
						                prima_retenida = prima_retenida + _prima_retenida,
										sum_ret        = sum_ret     + _sum_ret, 
										sum_cont       = sum_cont    + _sum_cont,
										sum_fac        = sum_fac     + _sum_fac,
										sum_fac_car    = sum_fac_car + _sum_fac_car,
										suma_asegurada = suma_asegurada + v_suma_asegurada										
						          WHERE no_poliza      = _no_poliza; 

						      END EXCEPTION

						      INSERT INTO temp_ubica
							  VALUES
							  (
							  _no_poliza,
							  _no_unidad,
							  v_suma_asegurada,
							  _prima_suscrita,
							  _prima_retenida,
							  _sum_ret, 
							  _sum_cont,
							  _sum_fac,
							  _sum_fac_car,
							  _serie,
							  1
							  );
						   END

						   BEGIN
						      ON EXCEPTION IN(-239,-268)
						      END EXCEPTION

						      INSERT INTO temp_fact	( no_poliza,    
						      						  no_endoso,    
						      						  no_factura,   
						      						  seleccionado,
						      						  suma_asegurada,  
						      						  sum_ret,         
						      						  sum_cont,        
						      						  sum_fac,              
						      						  sum_fac_car,
													  prima_suscrita,
													  prima_retenida							      						       								      						  
						      						  )
							  select no_poliza,  
							  		 no_endoso,  
							  		 no_factura, 
							  		 1,
									 v_suma_asegurada, 
						      		 _sum_ret,     				      
						      		 _sum_cont,    				      
						      		 _sum_fac,     				      			      
						      		 _sum_fac_car,
									 prima_suscrita,
									 prima_retenida							      		   				     
							    from endedmae
							   where no_poliza = _no_poliza 
							  	 and no_endoso = _no_endoso;

						   END


					  end if
			END FOREACH
		END FOREACH
end if

--Agregar limite maximo + suma asegurada

foreach
	select no_poliza,
	       no_unidad,
		   suma_asegurada,
		   prima_suscrita,
		   prima_retenida,
		   serie
	  into _no_poliza,
	       _no_unidad,
		   _suma_unidad,
		   _prima_suscrita,
		   _prima_retenida,
		   _serie
	  from temp_unidad
	 where cod_ramo = "002"

	select limite_2
	  into _limite_2_a
	  from emipocob
	 where no_poliza = _no_poliza
	   and no_unidad = _no_unidad
	   and cod_cobertura = "00102";

	select limite_1
	  into _limite_1_b
	  from emipocob
	 where no_poliza = _no_poliza
	   and no_unidad = _no_unidad
	   and cod_cobertura = "00113";

	if _limite_1_b is null then

		select limite_1						   
		  into _limite_1_b
		  from emipocob
		 where no_poliza = _no_poliza
		   and no_unidad = _no_unidad
		   and cod_cobertura = "00671";

	end if

	if _limite_1_b is null then
		let _limite_1_b = 0;
	end if

	select limite_2
	  into _limite_2_c
	  from emipocob
	 where no_poliza = _no_poliza
	   and no_unidad = _no_unidad
	   and cod_cobertura = "00107";

	let _limite_max = _suma_unidad + _limite_2_a + _limite_1_b + _limite_2_c;

    BEGIN
	     ON EXCEPTION IN(-239)
	     END EXCEPTION

	      INSERT INTO temp_unidad
		  VALUES(
		  _no_poliza,
		  _no_unidad,
		  _limite_max,
		  '999',
		  _prima_suscrita,
		  _prima_retenida,
		  _serie,
		  1
		  );
	END

end foreach

delete from tmp_sp_pro2i;

FOREACH
  SELECT no_poliza,
	     no_unidad,
         suma_asegurada,
		 prima_suscrita,
		 prima_retenida,
		 sum_ret, 
		 sum_cont,
		 sum_fac,
		 sum_fac_car
	INTO _no_poliza,
		 _no_unidad,
		 v_suma_asegurada,
		 _prima_suscrita,
		 _prima_retenida,
		 _sum_ret, 
		 _sum_cont,
		 _sum_fac,
		 _sum_fac_car
	FROM temp_ubica
   WHERE seleccionado = 1

   LET _suma_aseg_tot = _sum_ret + _sum_cont + _sum_fac + _sum_fac_car;

   IF v_suma_asegurada <> _suma_aseg_tot THEN
	      INSERT INTO tmp_sp_pro2i
		  VALUES(
		  _no_poliza,
		  v_suma_asegurada,
		  _sum_ret, 
		  _sum_cont,
		  _sum_fac
		  );
   END IF

	 	INSERT INTO temp_conteo
		  VALUES
		  (
		  _no_poliza,
		  _no_unidad,
		  1 );

	  SELECT cod_ramo
		INTO v_codramo
		FROM emipomae
	   WHERE no_poliza = _no_poliza;

	  SELECT emitipro.tipo_produccion
        INTO codigo1
        FROM emitipro,emipomae
       WHERE emitipro.cod_tipoprod = emipomae.cod_tipoprod 
         AND emipomae.no_poliza = _no_poliza;

       IF codigo1 = 2 OR codigo1 = 3  THEN
          LET v_cant_coasegur1 = 1;
          LET v_cant_coasegur2 = 0;
       ELSE
          LET v_cant_coasegur1 = 0;
          LET v_cant_coasegur2 = 1;
       END IF;

	  SELECT parinfra.rango1, 
		     parinfra.rango2
	  	INTO v_rango_inicial,
	  		 v_rango_final
	  	FROM parinfra
	   WHERE parinfra.cod_ramo = v_codramo
	     AND parinfra.rango1 <= v_suma_asegurada	   
	     AND parinfra.rango2 >= v_suma_asegurada;

       IF v_rango_inicial IS NULL THEN
          CONTINUE FOREACH;
       END IF;

	if v_codramo = "018" or v_codramo = "002" or v_codramo = "016" then
	else
       BEGIN
          ON EXCEPTION IN(-239)

		     let _conteo = 0;
			 select count(*)
			   into _conteo
			   from temp_conteo
			  where	no_poliza = _no_poliza;
			  if _conteo > 1 then
			     let _conteo = 0;
			else
			     let _conteo = 1;
			 end if

             UPDATE temp_civil
                SET cant_polizas   = cant_polizas   + _conteo, --1,
                    prima_suscrita = prima_suscrita + _prima_suscrita,
                    prima_retenida = prima_retenida + _prima_retenida,
                    cant_coasegur1 = cant_coasegur1 + v_cant_coasegur1,
                    cant_coasegur2 = cant_coasegur2 + v_cant_coasegur2,
					suma_asegurada = suma_asegurada + v_suma_asegurada,
					sum_ret        = sum_ret	    + _sum_ret,
					sum_cont       = sum_cont	    + _sum_cont,
					sum_fac        = sum_fac	    + _sum_fac,
					sum_fac_car    = sum_fac_car    + _sum_fac_car,
					cant_unidad    = cant_unidad    + 1
              WHERE cod_ramo       = v_codramo
                AND rango_inicial  = v_rango_inicial
                AND rango_final    = v_rango_final;

          END EXCEPTION

          INSERT INTO temp_civil
  		  VALUES(
  		  v_codsucursal,
          v_codramo,
          v_rango_inicial,
          v_rango_final,
          1,
          _prima_suscrita,
          _prima_retenida,
          v_cant_coasegur1,
          v_cant_coasegur2,
          1,
		  v_suma_asegurada,
		  _sum_ret, 
		  _sum_cont,
		  _sum_fac,
		  1,
		  _sum_fac_car
		  );
       END

	end if

   LET _prima_suscrita   = 0;
   LET _prima_retenida   = 0;

END FOREACH

let _cod_ramo_tmp = "";

FOREACH
  SELECT no_poliza,
         no_unidad,
         suma_asegurada,
		 cod_ramo,
		 prima_suscrita,
		 prima_retenida,
		 sum_ret, 
		 sum_cont,
		 sum_fac,
		 sum_fac_car
	INTO _no_poliza,
	     _no_unidad,
		 v_suma_asegurada,
		 v_codramo,
		 _prima_suscrita,
		 _prima_retenida,
		 _sum_ret, 
		 _sum_cont,
		 _sum_fac,
		 _sum_fac_car
	FROM temp_unidad
   where seleccionado = 1
   ORDER BY cod_ramo
	  
	if v_codramo = "999" then
		let _cod_ramo_tmp = v_codramo;
		let v_codramo = "002";
	end if
	LET _suma_aseg_tot = 0;

   LET _suma_aseg_tot = _sum_ret + _sum_cont + _sum_fac + _sum_fac_car;

   IF v_suma_asegurada <> _suma_aseg_tot THEN
	      INSERT INTO tmp_sp_pro2i
		  VALUES(
		  _no_poliza,
		  v_suma_asegurada,
		  _sum_ret, 
		  _sum_cont,
		  _sum_fac
		  );
		  CONTINUE FOREACH;
   END IF


	 	INSERT INTO temp_conteo
		  VALUES
		  (
		  _no_poliza,
		  _no_unidad,
		  1 );

	SELECT parinfra.rango1, 
		   parinfra.rango2
	  INTO v_rango_inicial,
	  	   v_rango_final
	  FROM parinfra
	 WHERE parinfra.cod_ramo = v_codramo
	   AND parinfra.rango1 <= v_suma_asegurada	   
	   AND parinfra.rango2 >= v_suma_asegurada;

	if _cod_ramo_tmp = "999" then
		let v_codramo = _cod_ramo_tmp;
		let _cod_ramo_tmp = "";
	end if

       IF v_rango_inicial IS NULL THEN
          CONTINUE FOREACH;
       END IF;

	  SELECT emitipro.tipo_produccion
        INTO codigo1
        FROM emitipro,emipomae
       WHERE emitipro.cod_tipoprod = emipomae.cod_tipoprod 
         AND emipomae.no_poliza = _no_poliza;

       IF codigo1 = 2 OR codigo1 = 3 THEN
          LET v_cant_coasegur1 = 1;
          LET v_cant_coasegur2 = 0;
       ELSE
          LET v_cant_coasegur1 = 0;
          LET v_cant_coasegur2 = 1;
       END IF;
	   let _conteo = 1;

       BEGIN
          ON EXCEPTION IN(-239)

			if v_codramo = "016" then
			     let _conteo = 0;
				 select count(*)
				   into _conteo
				   from temp_conteo
				  where	no_poliza = _no_poliza;
				  if _conteo > 1 then
				     let _conteo = 0;
				else
				     let _conteo = 1;
				 end if
			end if

             UPDATE temp_civil
                SET suma_asegurada = suma_asegurada + v_suma_asegurada,
					cant_polizas   = cant_polizas   + _conteo, --1,
                    prima_suscrita = prima_suscrita + _prima_suscrita,
                    prima_retenida = prima_retenida + _prima_retenida,
                    cant_coasegur1 = cant_coasegur1 + v_cant_coasegur1,
                    cant_coasegur2 = cant_coasegur2 + v_cant_coasegur2,
					sum_ret        = sum_ret	    + _sum_ret,
					sum_cont       = sum_cont	    + _sum_cont,
					sum_fac        = sum_fac	    + _sum_fac,
					sum_fac_car    = sum_fac_car    + _sum_fac_car,
					cant_unidad    = cant_unidad    + 1
              WHERE cod_ramo       = v_codramo
                AND rango_inicial  = v_rango_inicial
                AND rango_final    = v_rango_final;

          END EXCEPTION

          INSERT INTO temp_civil
  		  VALUES(
  		  v_codsucursal,	   
          v_codramo,		   
          v_rango_inicial,	   
          v_rango_final,	   
          _conteo,				   
          _prima_suscrita,	   
          _prima_retenida,	   
          v_cant_coasegur1,	   
          v_cant_coasegur2,	   
          1,				   
		  v_suma_asegurada,	   
		  _sum_ret, 
		  _sum_cont,
		  _sum_fac,
		  1,
		  _sum_fac_car);

{		  0, -- _pri_sus_inc,  
		  0, -- _pri_sus_ter,  
		  0, -- _pri_ret_inc,  
		  1, -- _pri_ret_ter   
		  0          );		   }

       END

       LET _prima_suscrita   = 0;
       LET _prima_retenida   = 0;
	   LET v_suma_asegurada  = 0;

END FOREACH
-- Procesos v_filtros

  LET v_filtros ="";

  IF a_serie <> "*" THEN
     --	LET v_filtros = TRIM(v_filtros) || "Serie " || _fecha_serie_ini || " - " || _fecha_serie_fin || ";";
		LET v_filtros = TRIM(v_filtros) || "Serie " ||TRIM(a_serie);
  END IF

  IF a_codramo <> "*" THEN
     LET v_filtros = TRIM(v_filtros) ||"Ramo "||TRIM(a_codramo);
     LET _tipo = sp_sis04(a_codramo); -- Separa los valores del String

     IF _tipo <> "E" THEN -- Incluir los Registros
        UPDATE temp_civil
           SET seleccionado = 0
         WHERE seleccionado = 1
           AND cod_ramo NOT IN(SELECT codigo FROM tmp_codigos);
     ELSE
        UPDATE temp_civil
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

        UPDATE temp_civil
               SET seleccionado = 0
             WHERE seleccionado = 1
               AND cod_sucursal NOT IN(SELECT codigo FROM tmp_codigos);
     ELSE
        UPDATE temp_civil
           SET seleccionado = 0
         WHERE seleccionado = 1
           AND cod_sucursal IN(SELECT codigo FROM tmp_codigos);
     END IF
     DROP TABLE tmp_codigos;
  END IF

	select count(*)
	  into _cnt
	  from temp_civil
	 where seleccionado = 1
	   and cod_ramo = "002";

	if _cnt > 0 then
		update temp_civil
		   set seleccionado = 1
		 where cod_ramo = "999";
	end if

FOREACH
	SELECT cod_ramo,
		   rango_inicial,
		   rango_final,
		   cant_polizas,
		   prima_suscrita,
		   prima_retenida,
		   cant_coasegur1,
		   cant_coasegur2,
		   suma_asegurada,
		   sum_ret, 
		   sum_cont,
		   sum_fac,
		   sum_fac_car,
		   cant_unidad
	  INTO v_codramo,
	  	   v_rango_inicial,
	  	   v_rango_final,
	  	   v_cant_polizas,
	       v_prima_suscrita,
	       v_prima_retenida,
	       v_cant_coasegur1,
	       v_cant_coasegur2,
		   v_suma_asegurada,
		   _sum_ret, 
		   _sum_cont,
		   _sum_fac,
		   _sum_fac_car,
		   _cant_unidad
	  FROM temp_civil
	 WHERE seleccionado = 1
  ORDER BY cod_ramo,rango_inicial		   

	SELECT MAX(rango1)
	  INTO rango_max
	  FROM parinfra
	 WHERE cod_ramo = v_codramo;

	SELECT MIN(rango1)
	  INTO rango_min
	  FROM parinfra
	 WHERE cod_ramo = v_codramo;

    IF rango_max = v_rango_inicial THEN
	    LET v_rango_final = -1;
    END IF;
    IF rango_min = v_rango_inicial THEN
	    LET v_rango_inicial = -1;
    END IF;
	if v_codramo <> "999" then
	    SELECT nombre
	      INTO v_desc_ramo
	      FROM prdramo
	     WHERE cod_ramo = v_codramo;
	else
		let	v_desc_ramo = "AUTOMOVIL (VALOR VEHICULO + LIMITE MAXIMO)";
	end if

     RETURN v_rango_inicial,
     		v_rango_final,
     		v_cant_polizas,
            v_prima_suscrita,
            v_prima_retenida,
            v_cant_coasegur1,
            v_cant_coasegur2,
            v_codramo,
            v_desc_ramo,
            a_periodo,
            descr_cia,
            v_filtros, 
            v_suma_asegurada,
		    _sum_ret, 
		    _sum_cont,
		    _sum_fac,
		    _cant_unidad,
		    _sum_fac_car
            WITH RESUME;

END FOREACH

DROP TABLE temp_civil;
DROP TABLE temp_ubica;
DROP TABLE temp_unidad;
DROP TABLE temp_conteo;
DROP TABLE temp_fact;
--trace off;

END

END PROCEDURE;




	  