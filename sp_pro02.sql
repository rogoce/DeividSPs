--------------------------------------------
---  PERFIL DE CARTERA - RAMOS AUTOMOVIL   ---
---            POLIZAS VIGENTES            ---
---  Yinia M. Zamora - agosto 2000 - YMZM
---  Modificado por Amado Perez Octubre 2001 
---  Modificado por Armando Moreno Nov. 2001 (sacar psuscrita de endosos y no de emipomae)
---  Modificado por Armando Moreno Sep. 2007 (sacar suma aseg. de unidad para ramo 002,y no de emipomae)
---  Ref. Power Builder - d_sp_pro02
--------------------------------------------
DROP procedure sp_pro02;
CREATE procedure "informix".sp_pro02(
a_compania 	   CHAR(3),
a_agencia  	   CHAR(03)  DEFAULT "*",
a_periodo  	   DATE,
a_codsucursal  CHAR(255) DEFAULT "*",
a_codramo 	   CHAR(255) DEFAULT "*",
a_serie		   char(255) default "*"	
)
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
          dec(16,2),
          dec(16,2),
          dec(16,2),
          dec(16,2),
          dec(16,2);

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

	define _pri_sus_tot					dec(16,2);
	define _pri_sus_inc					dec(16,2);
	define _pri_sus_ter					dec(16,2);
	define _pri_ret_inc					dec(16,2);
	define _pri_ret_ter					dec(16,2);
	define _es_terremoto				smallint;
	define _cod_cober_reas				char(3);
	define _serie						char(4);
    define _ano_serie_ini               smallint;
    define _ano_serie_fin               smallint;
    define _fecha_serie_ini             DATE;
    define _fecha_serie_fin             DATE;
	define _concat                      VARCHAR(255);

   CREATE TEMP TABLE temp_ubica
         (no_poliza          CHAR(10),
          suma_asegurada     DEC(16,2),
          prima_suscrita     DEC(16,2),
          prima_retenida     DEC(16,2),
		  pri_sus_inc		 dec(16,2) default 0,
		  pri_sus_ter		 dec(16,2) default 0,
		  pri_ret_inc		 dec(16,2) default 0,
		  pri_ret_ter		 dec(16,2) default 0,
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
		  pri_sus_inc	   dec(16,2) default 0,
		  pri_sus_ter	   dec(16,2) default 0,
		  pri_ret_inc	   dec(16,2) default 0,
		  pri_ret_ter	   dec(16,2) default 0,
          PRIMARY KEY (cod_ramo,rango_inicial)) WITH NO LOG;

   CREATE INDEX iend1_temp_civil ON temp_civil(cod_sucursal);
   CREATE INDEX iend2_temp_civil ON temp_civil(cod_ramo);

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
    LET mes 			 = MONTH(a_periodo);

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
	LET v_filtros ="";

   SET ISOLATION TO DIRTY READ;

--set debug file to "sp_pro02.trc";
--trace on;


IF a_serie <> "*" THEN
    LET v_filtros = TRIM(v_filtros) || "Serie " || TRIM(a_serie);
	LET _tipo = sp_sis04(a_serie); 
	IF _tipo <> "E" THEN
	    FOREACH
			SELECT codigo INTO _ano_serie_ini  FROM tmp_codigos ORDER BY 1 
			EXIT FOREACH;
		END FOREACH
	    FOREACH
			SELECT codigo INTO _ano_serie_fin  FROM tmp_codigos ORDER BY 1 DESC 
			EXIT FOREACH;
		END FOREACH
	END IF
	DROP TABLE tmp_codigos;

	LET _fecha_serie_ini = "01/01/" || _ano_serie_ini;
	LET _fecha_serie_fin = "31/12/" || _ano_serie_fin;

    LET _concat = "'" || a_compania || "' AND a.vigencia_inic >= '" || _fecha_serie_ini || "' AND a.vigencia_inic < '" || _fecha_serie_fin || "'";
ELSE
	LET _concat = a_compania;
	LET _fecha_serie_ini = "01/01/" ||"1900";
	LET _fecha_serie_fin = "31/12/" || periodo1[1,4];
END IF

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
				   AND a.vigencia_inic     <= _fecha_serie_fin

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

		        SELECT prima_suscrita,
				  	   prima_retenida
		          INTO _prima_suscrita,
				  	   _prima_retenida
		          FROM endedmae
		         WHERE no_poliza = _no_poliza
				   AND no_endoso = _no_endoso;

				let _pri_sus_inc = 0.00;
				let _pri_sus_ter = 0.00;
				let _pri_ret_inc = 0.00;
				let _pri_ret_ter = 0.00;

				if v_codramo in ("001", "003") then

				   foreach
					select cod_cober_reas,
					       sum(prima)
					  into _cod_cober_reas,
					       _pri_sus_tot
					  from emifacon
					 where no_poliza = _no_poliza
					   and no_endoso = _no_endoso
					 group by cod_cober_reas
					 order by cod_cober_reas

						select es_terremoto
						  into _es_terremoto
						  from reacobre
						 where cod_cober_reas = _cod_cober_reas;

						if _es_terremoto = 1 then
							let _pri_sus_ter = _pri_sus_tot;
						else
							let _pri_sus_inc = _pri_sus_tot;
						end if

					end foreach					   
					
				   foreach
					select e.cod_cober_reas,
					       sum(e.prima)
					  into _cod_cober_reas,
					       _pri_sus_tot
					  from emifacon e, reacomae c
					 where e.cod_contrato  = c.cod_contrato
					   and e.no_poliza     = _no_poliza
					   and e.no_endoso     = _no_endoso
					   and c.tipo_contrato = 1
					 group by e.cod_cober_reas
					 order by e.cod_cober_reas

						select es_terremoto
						  into _es_terremoto
						  from reacobre
						 where cod_cober_reas = _cod_cober_reas;

						if _es_terremoto = 1 then
							let _pri_ret_ter = _pri_sus_tot;
						else
							let _pri_ret_inc = _pri_sus_tot;
						end if

				   end foreach
					
				end if

			    --> se modifica para que traiga la suma de emifacon Amado 06-05-2010					   
			   {	select sum(a.suma_asegurada)
				  into v_suma_asegurada
				  from emifacon a, endedmae b
				 where a.no_poliza = _no_poliza
				   and a.no_poliza = b.no_poliza
				   and a.no_endoso = b.no_endoso;}
				  -- and b.cod_endomov <> '002';

			  if v_codramo = "018" or v_codramo = "002" or v_codramo = "016" then
			  else

				   BEGIN
				      ON EXCEPTION IN(-239)
				         UPDATE temp_ubica
				            SET prima_suscrita = prima_suscrita + _prima_suscrita,
				                prima_retenida = prima_retenida + _prima_retenida,
								pri_sus_inc    = pri_sus_inc    + _pri_sus_inc,
								pri_sus_ter    = pri_sus_ter    + _pri_sus_ter,
								pri_ret_inc    = pri_ret_inc    + _pri_ret_inc,
								pri_ret_ter    = pri_ret_ter    + _pri_ret_ter
				          WHERE no_poliza      = _no_poliza;

				      END EXCEPTION

				      INSERT INTO temp_ubica
					  VALUES
					  (
					  _no_poliza,
					  v_suma_asegurada,
					  _prima_suscrita,
					  _prima_retenida,
					  _pri_sus_inc, 
					  _pri_sus_ter,
					  _pri_ret_inc,
					  _pri_ret_ter,
					  _serie,
					  1
					  );

				   END

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
				   AND a.vigencia_inic     < a_periodo
				   AND a.actualizado       = 1
  				   AND a.cod_ramo         NOT IN(SELECT codigo FROM tmp_codigos)
				   AND b.no_poliza         = a.no_poliza
				   AND b.periodo           <= periodo1
				   AND b.fecha_emision     <= a_periodo
			   	   AND b.actualizado 	   = 1
			   	   AND a.vigencia_inic     >= _fecha_serie_ini
				   AND a.vigencia_inic     <= _fecha_serie_fin

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

		        SELECT prima_suscrita,
				  	   prima_retenida
		          INTO _prima_suscrita,
				  	   _prima_retenida
		          FROM endedmae
		         WHERE no_poliza = _no_poliza
				   AND no_endoso = _no_endoso;

				let _pri_sus_inc = 0.00;
				let _pri_sus_ter = 0.00;
				let _pri_ret_inc = 0.00;
				let _pri_ret_ter = 0.00;

				if v_codramo in ("001", "003") then

				   foreach
					select cod_cober_reas,
					       sum(prima)
					  into _cod_cober_reas,
					       _pri_sus_tot
					  from emifacon
					 where no_poliza = _no_poliza
					   and no_endoso = _no_endoso
					 group by cod_cober_reas
					 order by cod_cober_reas

						select es_terremoto
						  into _es_terremoto
						  from reacobre
						 where cod_cober_reas = _cod_cober_reas;

						if _es_terremoto = 1 then
							let _pri_sus_ter = _pri_sus_tot;
						else
							let _pri_sus_inc = _pri_sus_tot;
						end if

					end foreach					   
					
				   foreach
					select e.cod_cober_reas,
					       sum(e.prima)
					  into _cod_cober_reas,
					       _pri_sus_tot
					  from emifacon e, reacomae c
					 where e.cod_contrato  = c.cod_contrato
					   and e.no_poliza     = _no_poliza
					   and e.no_endoso     = _no_endoso
					   and c.tipo_contrato = 1
					 group by e.cod_cober_reas
					 order by e.cod_cober_reas

						select es_terremoto
						  into _es_terremoto
						  from reacobre
						 where cod_cober_reas = _cod_cober_reas;

						if _es_terremoto = 1 then
							let _pri_ret_ter = _pri_sus_tot;
						else
							let _pri_ret_inc = _pri_sus_tot;
						end if

					end foreach					   

				end if

			    --> se modifica para que traiga la suma de emifacon Amado 06-05-2010					   
			  {	select sum(a.suma_asegurada)
				  into v_suma_asegurada
				  from emifacon a, endedmae b
				 where a.no_poliza = _no_poliza
				   and a.no_poliza = b.no_poliza
				   and a.no_endoso = b.no_endoso;}
				   --and b.cod_endomov <> '002';

			  if v_codramo = "018" or v_codramo = "002" or v_codramo = "016" then
			  else

			   BEGIN
			      ON EXCEPTION IN(-239)
			         UPDATE temp_ubica
			            SET prima_suscrita = prima_suscrita + _prima_suscrita,
			                prima_retenida = prima_retenida + _prima_retenida,
							pri_sus_inc    = pri_sus_inc    + _pri_sus_inc,
							pri_sus_ter    = pri_sus_ter    + _pri_sus_ter,
							pri_ret_inc    = pri_ret_inc    + _pri_ret_inc,
							pri_ret_ter    = pri_ret_ter    + _pri_ret_ter
			          WHERE no_poliza      = _no_poliza;

			      END EXCEPTION

			      INSERT INTO temp_ubica
				  VALUES
				  (
				  _no_poliza,
				  v_suma_asegurada,
				  _prima_suscrita,
				  _prima_retenida,
				  _pri_sus_inc, 
				  _pri_sus_ter,
				  _pri_ret_inc,
				  _pri_ret_ter,
				  _serie,
				  1
				  );
			   END

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
		   AND a.vigencia_inic     < a_periodo
		   AND a.actualizado       = 1
		   AND b.no_poliza         = a.no_poliza
		   AND b.periodo           <= periodo1
		   AND b.fecha_emision     <= a_periodo
	   	   AND b.actualizado 	   = 1
	   	   AND a.vigencia_inic     >= _fecha_serie_ini
		   AND a.vigencia_inic     <= _fecha_serie_fin

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

        SELECT prima_suscrita,
		  	   prima_retenida
          INTO _prima_suscrita,
		  	   _prima_retenida
          FROM endedmae
         WHERE no_poliza = _no_poliza
		   AND no_endoso = _no_endoso;

		let _pri_sus_inc = 0.00;
		let _pri_sus_ter = 0.00;
		let _pri_ret_inc = 0.00;
		let _pri_ret_ter = 0.00;

		if v_codramo in ("001", "003") then

		   foreach
			select cod_cober_reas,
			       sum(prima)
			  into _cod_cober_reas,
			       _pri_sus_tot
			  from emifacon
			 where no_poliza = _no_poliza
			   and no_endoso = _no_endoso
			 group by cod_cober_reas
			 order by cod_cober_reas

				select es_terremoto
				  into _es_terremoto
				  from reacobre
				 where cod_cober_reas = _cod_cober_reas;

				if _es_terremoto = 1 then
					let _pri_sus_ter = _pri_sus_tot;
				else
					let _pri_sus_inc = _pri_sus_tot;
				end if

			end foreach					   
			
		   foreach
			select e.cod_cober_reas,
			       sum(e.prima)
			  into _cod_cober_reas,
			       _pri_sus_tot
			  from emifacon e, reacomae c
			 where e.cod_contrato  = c.cod_contrato
			   and e.no_poliza     = _no_poliza
			   and e.no_endoso     = _no_endoso
			   and c.tipo_contrato = 1
			 group by e.cod_cober_reas
			 order by e.cod_cober_reas

				select es_terremoto
				  into _es_terremoto
				  from reacobre
				 where cod_cober_reas = _cod_cober_reas;

				if _es_terremoto = 1 then
					let _pri_ret_ter = _pri_sus_tot;
				else
					let _pri_ret_inc = _pri_sus_tot;
				end if

			end foreach					   

		end if

	    --> se modifica para que traiga la suma de emifacon Amado 06-05-2010					   
	   {	select sum(a.suma_asegurada)
		  into v_suma_asegurada
		  from emifacon a, endedmae b
		 where a.no_poliza = _no_poliza
		   and a.no_poliza = b.no_poliza
		   and a.no_endoso = b.no_endoso;}
--		   and b.cod_endomov <> '002';

	  if v_codramo = "018" or v_codramo = "002" or v_codramo = "016" then
	  else
	   BEGIN
	      ON EXCEPTION IN(-239)
	         UPDATE temp_ubica
	            SET prima_suscrita = prima_suscrita + _prima_suscrita,
	                prima_retenida = prima_retenida + _prima_retenida,
					pri_sus_inc    = pri_sus_inc    + _pri_sus_inc,
					pri_sus_ter    = pri_sus_ter    + _pri_sus_ter,
					pri_ret_inc    = pri_ret_inc    + _pri_ret_inc,
					pri_ret_ter    = pri_ret_ter    + _pri_ret_ter
	          WHERE no_poliza      = _no_poliza;

	      END EXCEPTION

	      INSERT INTO temp_ubica
		  VALUES
		  (
		  _no_poliza,
		  v_suma_asegurada,
		  _prima_suscrita,
		  _prima_retenida,
		  _pri_sus_inc, 
		  _pri_sus_ter,
		  _pri_ret_inc,
		  _pri_ret_ter,
		  _serie,
		  1
		  );
	   END
	  end if
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

-- Procesos v_filtros

--LET v_filtros ="";

{IF a_serie <> "*" THEN

	LET v_filtros = TRIM(v_filtros) || "Serie " || TRIM(a_serie);
	LET _tipo = sp_sis04(a_serie); -- Separa los valores del String

	IF _tipo <> "E" THEN -- Incluir los Registros

		UPDATE temp_ubica
		   SET seleccionado = 0
		 WHERE seleccionado = 1
		   AND serie NOT IN(SELECT codigo FROM tmp_codigos);

	ELSE

		UPDATE temp_ubica
		   SET seleccionado = 0
		 WHERE seleccionado = 1
		   AND serie IN(SELECT codigo FROM tmp_codigos);

	END IF

	DROP TABLE tmp_codigos;

END IF
}

FOREACH
  SELECT no_poliza,
         suma_asegurada,
		 prima_suscrita,
		 prima_retenida,
		 pri_sus_inc,
		 pri_sus_ter,
		 pri_ret_inc,
		 pri_ret_ter
	INTO _no_poliza,
		 v_suma_asegurada,
		 _prima_suscrita,
		 _prima_retenida,
		 _pri_sus_inc,
		 _pri_sus_ter,
		 _pri_ret_inc,
		 _pri_ret_ter
	FROM temp_ubica
   WHERE seleccionado = 1

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
             UPDATE temp_civil
                SET cant_polizas   = cant_polizas   + 1,
                    prima_suscrita = prima_suscrita + _prima_suscrita,
                    prima_retenida = prima_retenida + _prima_retenida,
                    cant_coasegur1 = cant_coasegur1 + v_cant_coasegur1,
                    cant_coasegur2 = cant_coasegur2 + v_cant_coasegur2,
					suma_asegurada = suma_asegurada + v_suma_asegurada,
					pri_sus_inc    =  pri_sus_inc	+ _pri_sus_inc,
					pri_sus_ter    =  pri_sus_ter	+ _pri_sus_ter,
					pri_ret_inc    =  pri_ret_inc	+ _pri_ret_inc,
					pri_ret_ter    =  pri_ret_ter	+ _pri_ret_ter
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
		  _pri_sus_inc,
		  _pri_sus_ter,
		  _pri_ret_inc,
		  _pri_ret_ter
		  );
       END

	end if

   LET _prima_suscrita   = 0;
   LET _prima_retenida   = 0;

END FOREACH

let _cod_ramo_tmp = "";

{IF a_serie <> "*" THEN

	LET _tipo = sp_sis04(a_serie); -- Separa los valores del String

	IF _tipo <> "E" THEN -- Incluir los Registros

		UPDATE temp_unidad
		   SET seleccionado = 0
		 WHERE seleccionado = 1
		   AND serie NOT IN(SELECT codigo FROM tmp_codigos);

	ELSE

		UPDATE temp_unidad
		   SET seleccionado = 0
		 WHERE seleccionado = 1
		   AND serie IN(SELECT codigo FROM tmp_codigos);

	END IF

	DROP TABLE tmp_codigos;

END IF
}
FOREACH
  SELECT no_poliza,
         no_unidad,
         suma_asegurada,
		 cod_ramo,
		 prima_suscrita,
		 prima_retenida
	INTO _no_poliza,
	     _no_unidad,
		 v_suma_asegurada,
		 v_codramo,
		 _prima_suscrita,
		 _prima_retenida
	FROM temp_unidad
   where seleccionado = 1
   ORDER BY cod_ramo
	  
	if v_codramo = "999" then
		let _cod_ramo_tmp = v_codramo;
		let v_codramo = "002";
	end if

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

       IF codigo1 = 2 OR codigo1 = 3  THEN
          LET v_cant_coasegur1 = 1;
          LET v_cant_coasegur2 = 0;
       ELSE
          LET v_cant_coasegur1 = 0;
          LET v_cant_coasegur2 = 1;
       END IF;

       BEGIN
          ON EXCEPTION IN(-239)
             UPDATE temp_civil
                SET suma_asegurada = suma_asegurada + v_suma_asegurada,
					cant_polizas   = cant_polizas   + 1,
                    prima_suscrita = prima_suscrita + _prima_suscrita,
                    prima_retenida = prima_retenida + _prima_retenida,
                    cant_coasegur1 = cant_coasegur1 + v_cant_coasegur1,
                    cant_coasegur2 = cant_coasegur2 + v_cant_coasegur2
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
		  _pri_sus_inc,
		  _pri_sus_ter,
		  _pri_ret_inc,
		  _pri_ret_ter
          );

       END

       LET _prima_suscrita   = 0;
       LET _prima_retenida   = 0;
	   LET v_suma_asegurada  = 0;

END FOREACH

 -- Procesos v_filtros

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
		   pri_sus_inc,
		   pri_sus_ter,
		   pri_ret_inc,
		   pri_ret_ter
	  INTO v_codramo,
	  	   v_rango_inicial,
	  	   v_rango_final,
	  	   v_cant_polizas,
	       v_prima_suscrita,
	       v_prima_retenida,
	       v_cant_coasegur1,
	       v_cant_coasegur2,
		   v_suma_asegurada,
		   _pri_sus_inc,
		   _pri_sus_ter,
		   _pri_ret_inc,
		   _pri_ret_ter
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
		   _pri_sus_inc,
		   _pri_sus_ter,
		   _pri_ret_inc,
		   _pri_ret_ter
            WITH RESUME;

END FOREACH

DROP TABLE temp_civil;
DROP TABLE temp_ubica;
DROP TABLE temp_unidad;
END
END PROCEDURE;

  
	  