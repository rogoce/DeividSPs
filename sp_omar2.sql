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
---  COpia de sp_rea21b
--   CREATE procedure "informix".sp_rea21a(a_cia CHAR(03),a_agencia CHAR(3),a_periodo DATE,a_codramo CHAR(255),a_serie CHAR(255), a_contrato CHAR(255))
--RETURNING CHAR(255);
--------------------------------------------
--DROP procedure sp_omar2;
CREATE procedure "informix".sp_omar2(a_compania CHAR(03),a_agencia CHAR(3),a_codsucursal  CHAR(255),a_periodo DATE,a_codramo CHAR(255),a_serie CHAR(255), a_contrato CHAR(255))
RETURNING CHAR(255);
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

    DEFINE _no_documento              	CHAR(20);
    DEFINE _no_factura     				CHAR(10);
    DEFINE v_cod_subramo                CHAR(3);

    DEFINE v_cod_grupo              CHAR(05);
    DEFINE v_contratante            CHAR(10);
    DEFINE v_cod_agente             CHAR(05);
    DEFINE v_vigencia_inic,v_vigencia_final,v_fecha_suscrip   DATE;
    DEFINE v_usuario                CHAR(08);
	DEFINE _bouquet                 SMALLINT;
	define _cod_cober_reas	        char(3);
	DEFINE v_porc_partic			dec(9,6);
  
   LET descr_cia = sp_sis01(a_compania);

CREATE TEMP TABLE temp_bouquet
		 (no_poliza	        CHAR(10),
		 no_endoso	        CHAR(5),
		 cod_contrato       CHAR(5),
		 bouquet			Smallint default 0,
		 front				Smallint default 0,
         PRIMARY KEY (no_poliza,no_endoso,cod_contrato,bouquet,front))
         WITH NO LOG;

	CREATE INDEX i_temp_bouquet0 ON temp_bouquet(no_poliza);
	CREATE INDEX i_temp_bouquet1 ON temp_bouquet(no_endoso);
	CREATE INDEX i_temp_bouquet3 ON temp_bouquet(cod_contrato);
	CREATE INDEX i_temp_bouquet4 ON temp_bouquet(bouquet);
	CREATE INDEX i_temp_bouquet5 ON temp_bouquet(front);

CREATE TEMP TABLE temp_perfil
	     (no_poliza         CHAR(10),
	      no_documento      CHAR(20),
	      no_factura        CHAR(10),
	      cod_ramo          CHAR(3),
	      cod_subramo       CHAR(3),
	      cod_sucursal      CHAR(3),
	      cod_grupo         CHAR(5),
	      cod_tipoprod      CHAR(3),
	      cod_contratante   CHAR(10),
	      cod_agente        CHAR(5),
	      prima_suscrita    DEC(16,2),
	      prima_retenida    DEC(16,2),
	      vigencia_inic     DATE,
	      vigencia_final    DATE,
	      fecha_suscripcion DATE,
	      usuario           CHAR(08),
	      suma_asegurada    DEC(16,2),
	      seleccionado      SMALLINT DEFAULT 0,
	      serie			    SMALLINT,
	      cod_contrato      CHAR(5),
	      bouquet           SMALLINT,
		  sum_ret        	dec(16,2) default 0,
		  sum_cont          dec(16,2) default 0,
		  sum_fac           dec(16,2) default 0,
		  sum_pcont         dec(16,2) default 0,
		  sum_fcont         dec(16,2) default 0,
		  sum_rcont         dec(16,2) default 0,
		  sum_5             dec(16,2) default 0,
		  sum_7             dec(16,2) default 0,
		  front	      		SMALLINT  default 0,
          PRIMARY KEY (no_poliza))
          WITH NO LOG;

--        PRIMARY KEY (no_poliza,cod_contrato))
--        WITH NO LOG;

	 --   PRIMARY KEY(no_poliza))
--	CREATE INDEX i_perfil1 ON temp_perfil(no_poliza);
	CREATE INDEX i_perfil1 ON temp_perfil(cod_contrato);
	CREATE INDEX i_perfil2 ON temp_perfil(cod_ramo);
	CREATE INDEX i_perfil3 ON temp_perfil(cod_subramo);
	CREATE INDEX i_perfil4 ON temp_perfil(cod_tipoprod);
	CREATE INDEX i_perfil5 ON temp_perfil(cod_sucursal);

	LET _a_compania = a_compania;
	LET _a_agencia = a_agencia;
	LET _a_periodo = a_periodo; 
	LET _a_codsucursal = a_codsucursal;
	LET _a_codramo = a_codramo;

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
		LET _fecha_serie_ini = "01/01/" || _ano_serie_ini;
		LET _fecha_serie_fin = "31/12/" || _ano_serie_ini;

	    LET v_filtros = TRIM(v_filtros) || "Serie " || TRIM(a_serie)||" ; ";
	END IF

    IF _fecha_serie_fin > a_periodo THEN
		LET _fecha_serie_fin = a_periodo;
	END IF

--trace off;
--set debug file to "sp_rea21b.trc";
--trace on;

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
					   year(a.vigencia_inic),
					   a.no_documento,
					   a.no_factura,
					   a.cod_subramo,
					   a.cod_grupo,
					   a.cod_contratante,
					   a.vigencia_inic,
					   a.vigencia_final,
					   a.fecha_suscripcion,
					   a.user_added
			      INTO _no_poliza,
			           v_fecha_cancel,
			           v_codramo,
			           v_codsucursal,
			           v_suma_asegurada,
			           v_cod_tipoprod,
					   _no_endoso,
					   _serie,
					   _no_documento,
					   _no_factura,
					   v_cod_subramo,
					   v_cod_grupo,
					   v_contratante,
					   v_vigencia_inic,
					   v_vigencia_final,
					   v_fecha_suscrip,
					   v_usuario
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
					select a.cod_contrato, a.cod_cober_reas, a.porc_partic_prima,
					       sum(a.suma_asegurada),
						   sum(a.prima)
					  into _cod_contrato, _cod_cober_reas, _porc_prima,
					       _suma_aseg_tot,
						   _prima_cont
					  from emifacon a, endedmae b
					 where a.no_poliza = _no_poliza
					   and a.no_poliza = b.no_poliza
					   and a.no_endoso = b.no_endoso
					   and b.cod_endomov <> '002'
					   and a.no_endoso = _no_endoso
	                   and b.fecha_emision  <= a_periodo
					 group by a.cod_contrato, a.cod_cober_reas , a.porc_partic_prima
					 order by a.cod_contrato, a.cod_cober_reas , a.porc_partic_prima

					select tipo_contrato, fronting, serie
					  into _tipo_contrato, _front, _serie
					  from reacomae
					 where cod_contrato = _cod_contrato;
					    
					select bouquet
					  into _bouquet
					  from reacocob
					 where cod_contrato   = _cod_contrato
					   and cod_cober_reas = _cod_cober_reas; --"008";

					   IF _bouquet is null THEN
						  let _bouquet = 0;
					   END IF


					 INSERT INTO temp_bouquet
							 (no_poliza,
							 no_endoso,
							 cod_contrato,
							 bouquet,
							 front)
					  VALUES (_no_poliza,
							  _no_endoso,
							  _cod_contrato,
							  _bouquet,
							  _front);

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

--			  IF _front = 0 THEN   -- Si encuentran poliza distinta de fronting

				FOREACH
				     SELECT z.cod_agente,z.porc_partic_agt
				       INTO v_cod_agente,v_porc_partic
				       FROM emipoagt z
				      WHERE z.no_poliza = _no_poliza
					  EXIT FOREACH;
				END FOREACH

				   BEGIN
				      ON EXCEPTION IN(-239,-268)
				         UPDATE temp_perfil
				            SET suma_asegurada = suma_asegurada + v_suma_asegurada,
				                prima_suscrita = prima_suscrita + _prima_suscrita,
				                prima_retenida = prima_retenida + _prima_retenida,
								sum_ret        = sum_ret        + _sum_ret,
								sum_cont       = sum_cont       + _sum_cont,
								sum_fac        = sum_fac        + _sum_fac,
								sum_rcont      = sum_rcont      + _sum_rcont,
								sum_pcont      = sum_pcont      + _sum_pcont,
								sum_fcont      = sum_fcont      + _sum_fcont,
								sum_5          = sum_5          + _sum_5,
								sum_7          = sum_7          + _sum_7
				          WHERE no_poliza      = _no_poliza	 ;
--				            AND cod_contrato   = _cod_contrato;	

				      END EXCEPTION

				      INSERT INTO temp_perfil (
					  no_poliza,        
					  no_documento,     				 
					  no_factura,       				 
					  cod_ramo,         				 
					  cod_subramo,      				 
					  cod_sucursal,     				 
					  cod_grupo,        				 
					  cod_tipoprod,     				 
					  cod_contratante,  				 
					  cod_agente,       				 
					  prima_suscrita,   				 
					  prima_retenida,   				 
					  vigencia_inic,    				 
					  vigencia_final,   				
					  fecha_suscripcion,				 
					  usuario,          				 
					  suma_asegurada,   				 
					  seleccionado,     				 
					  serie,			  				 
					  cod_contrato,     				  
					  bouquet,          				 
					  sum_ret,        					 
					  sum_cont,         				
					  sum_fac,          				 
					  sum_pcont,        				 
					  sum_fcont,        				 
					  sum_rcont,        				 
					  sum_5,            				 
					  sum_7,
					  front )       				 
					  VALUES (
					  _no_poliza,
					  _no_documento,
					  _no_factura,
					  v_codramo,
					  v_cod_subramo,
					  v_codsucursal,
					  v_cod_grupo,
					  v_cod_tipoprod,
					  v_contratante,
					  v_cod_agente,
					  _prima_suscrita,
					  _prima_retenida,					  
					  v_vigencia_inic,
					  v_vigencia_final,
					  v_fecha_suscrip,
					  v_usuario,
					  v_suma_asegurada,
					  0,
					  _serie,
					  _cod_contrato,
					  _bouquet,
					  _sum_ret, 
					  _sum_cont,
					  _sum_fac,		
					  _sum_pcont,
					  _sum_fcont,
					  _sum_rcont,
					  _sum_5,
					  _sum_7,	  				  
					  _front				  
					  );   

				   END

--		    END IF
		END FOREACH

	end if
	DROP TABLE tmp_codigos;

end if
--trace off;

-- solo los bouquet y  <> fronting	
FOREACH
	SELECT Distinct no_poliza,cod_contrato 
	  INTO _no_poliza,_cod_contrato
	  FROM temp_bouquet 
     where bouquet = 1 
       and front = 0

	UPDATE temp_perfil
	   SET seleccionado = 1,
	       cod_contrato = _cod_contrato,
	       bouquet      = 1, 
	       front        = 0
	     WHERE no_poliza  = _no_poliza;

END FOREACH
-- Contratos
IF a_contrato <> "*" THEN
     LET v_filtros = TRIM(v_filtros) ||"Contratos: "||TRIM(a_contrato);
     LET _tipo = sp_sis04(a_contrato); -- Separa los valores del String

{     IF _tipo <> "E" THEN -- Incluir los Registros

        UPDATE temp_perfil
               SET seleccionado = 0
             WHERE seleccionado = 1
               AND cod_contrato NOT IN(SELECT codigo FROM tmp_codigos);
     ELSE
        UPDATE temp_perfil
               SET seleccionado = 0
             WHERE seleccionado = 1
               AND cod_contrato IN(SELECT codigo FROM tmp_codigos);
     END IF }
     DROP TABLE tmp_codigos;
END IF	

--DROP TABLE temp_bouquet;

RETURN v_filtros;


END

END PROCEDURE;
