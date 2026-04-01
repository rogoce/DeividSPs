------------------------------------------------
--      TOTALES DE PRODUCCION POR             --  
--         CONTRATO DE REASEGURO              --
---  Yinia M. Zamora - octubre 2000 - YMZM	  --
---  Ref. Power Builder - d_sp_pro40		  --
--- Modificado por Armando Moreno 19/01/2002; -- la parte de los tipo de contratos
------------------------------------------------
--execute procedure sp_pr860bk('001','001','2012-07','2012-09',"*","*","*","*","001,003,006,008,010,011,012,013,014,021,022;","*","2012,2011,2010,2009,2008;")

drop procedure sp_pr860det;
CREATE PROCEDURE sp_pr860det(a_compania CHAR(03),a_agencia CHAR(03),a_periodo1 CHAR(07),a_periodo2 CHAR(07),a_codsucursal CHAR(255) DEFAULT "*",a_codgrupo  CHAR(255) DEFAULT "*",a_codagente CHAR(255) DEFAULT "*",a_codusuario CHAR(255) DEFAULT "*",a_codramo  CHAR(255) DEFAULT "*",a_reaseguro CHAR(255) DEFAULT "*",a_serie CHAR(255) DEFAULT "*",a_tipo_bx char(2) DEFAULT "01")
RETURNING CHAR(3),CHAR(3),CHAR(5),CHAR(3),DECIMAL(16,2),DECIMAL(16,2),DECIMAL(16,2),DECIMAL(16,2),DECIMAL(16,2),DECIMAL(16,2),DECIMAL(16,2),DECIMAL(16,2),CHAR(50),CHAR(50), CHAR(50), char(255);
   BEGIN
      DEFINE v_nopoliza                      CHAR(10);
      DEFINE v_noendoso,v_cod_contrato       CHAR(5);
      DEFINE v_cod_ramo,v_cobertura, v_clase,_cod_ramo CHAR(03);
      DEFINE v_desc_ramo, v_desc_contrato    CHAR(50);
      DEFINE v_desc_cobertura	             CHAR(100);
      DEFINE v_filtros                       CHAR(255);
      DEFINE v_filtros2                      CHAR(255);
      DEFINE _tipo                           CHAR(01);
      DEFINE v_descr_cia                     CHAR(50);
      DEFINE v_prima                		 DEC(16,2);
      DEFINE v_prima1                		 DEC(16,2);
      DEFINE v_tipo_contrato                 SMALLINT;
	  define _error							 integer;
	  define _error_desc					 char(255);

	  define _porc_impuesto					 dec(16,2);
	  define _porc_comision					 dec(16,2);
	  define _cuenta						 char(25);
	  define _serie 						 smallint;
	  define _impuesto						 dec(16,2);
	  define _comision						 dec(16,2);
	  define _por_pagar						 dec(16,2);
	  define _siniestro						 dec(16,2);

	  DEFINE _cod_traspaso	 				 CHAR(5);
	  define _traspaso		 				 smallint;
	  define _tiene_comis_rea				 smallint;
	  define _cantidad						 smallint;
	  define _tipo_cont                      smallint;
	  	
	  define _porc_cont_partic 				 dec(5,2);
	  define _porc_cont_terr                 dec(5,2);
	  DEFINE _porc_comis_ase   				 DECIMAL(5,2);
	  define _monto_reas					 dec(16,2);
	  define v_prima_suscrita				 dec(16,2);
	  define _cod_coasegur	 				 char(3);
	  define _nombre_coas					 char(50);
	  define _nombre_cob					 char(50);
	  define _nombre_con					 char(50);
	  define _cod_subramo					 char(3);
	  define _cod_origen					 char(3);
	  define _prima_tot_ret                  dec(16,2);
	  define _prima_sus_tot					 dec(16,2);
	  define _prima_tot_ret_sum              dec(16,2);
	  define _prima_tot_sus_sum              dec(16,2);
	  define _prima_devuelta				 dec(16,2);
	  define _no_cambio						 smallint;
	  define _no_unidad						 char(5);
      define v_prima_cobrada           		 DEC(16,2);
	  define _porc_partic_coas				 dec(7,4);
	  define _fecha						     date;
	  define _porc_partic_prima				 dec(9,6);
	  define _p_sus_tot						 DEC(16,2);
	  define _p_sus_tot_sum					 DEC(16,2);
	  DEFINE _ano,_ano2 				     SMALLINT;
	  define _tot_comision 					 dec(16,2);
	  define _tot_impuesto 					 dec(16,2);
	  define _tot_prima_neta				 dec(16,2);
	  DEFINE _tiene_comision				 SMALLINT;
	  define _p_c_partic					 dec(5,2);
	  define _p_c_partic_hay				 smallint;
	  define v_existe                        smallint;

	  define nivel,_nivel                    smallint;
	  define _xnivel                         char(3);
	  define v_prima70, v_prima30            decimal (16,2);
	  define _comision70, _comision30        decimal (16,2);
	  define _impuesto70, _impuesto30        decimal (16,2);
	  define _por_pagar70, _por_pagar30      decimal (16,2);
	  define _siniestro70, _siniestro30      decimal (16,2);
	  define v_prima10,_por_pagar10 		 decimal (16,2);
	  define _comision10,_impuesto10		 decimal (16,2);
	  define _siniestro2,_sini_bk,_sini_dif  decimal (16,2);
	  define _siniestro3					 decimal (16,2);
	  define _pagado_neto					 decimal (16,2);
	  define _porc_impuesto4				 dec(7,4);
	  define _porc_comision4,_porc_comisiond dec(7,4);

	  DEFINE _anio_reas						 char(9);
	  DEFINE _trim_reas,_contrato_xl		 Smallint;
	  DEFINE _borderaux						 char(2);
	  DEFINE _bouquet						 smallint;
	  DEFINE _no_documento					 char(20);
	  DEFINE _flag , _cnt,_cnt2,_cnt3		 smallint;
	  DEFINE _serie1 			             smallint;
	  DEFINE _dt_vig_inic                    date;
	  define _facilidad_car,_tipo2           smallint;
	  define _cod_c                          char(5);
	  define _porc_terr,_porc_inun,_siniestro4           decimal (16,2);
	  define _no_reclamo                     char(10);
	  define _sini_inc 						 decimal (16,2);
	  define _sini_mul 						 decimal (16,2);
	  define _renglon						 integer;
	  define _no_remesa						 char(10);
	  define _porc_proporcion             	 dec(5,2);

     SET ISOLATION TO DIRTY READ;

	 LET _borderaux = a_tipo_bx;   -- BOUQUET,CUOTA PARTE ACC PERS, VIDA, FACILIDAD CAR
	 select tipo into _tipo2 from reacontr where cod_contrato = _borderaux;
	 CALL sp_rea002(a_periodo2,_tipo2) RETURNING _anio_reas,_trim_reas;
	 
	 let _contrato_xl = 0;
	 let _porc_proporcion = 0; 

	 if _borderaux = '01' then	--es bouquet y facilidad car
	  
		 delete from reacoest where anio = _anio_reas and trimestre = _trim_reas and borderaux = _borderaux;  -- Elimina borderaux del trimestre
		 delete from temphg   where anio = _anio_reas and trimestre = _trim_reas and borderaux = _borderaux;  -- Elimina borderaux datos

		if a_codramo = '*' then
			let a_codramo = "001,003,006,008,010,011,012,013,014,021,022;";
		end if
	 else
		 DELETE FROM reacoest where anio = _anio_reas and trimestre = _trim_reas and borderaux = _borderaux;  -- Elimina borderaux del trimestre
		 DELETE FROM temphg   where anio = _anio_reas and trimestre = _trim_reas and borderaux = _borderaux;  -- Elimina borderaux datos

		if _borderaux = '06' then
			if a_codramo = '*' then
				let a_codramo = "014;";
			end if
		elif _borderaux = '08' then
			if a_codramo = '*' then
				let a_codramo = "004,016,019;";
			end if
		elif _borderaux = '09' then
			if a_codramo = '*' then
				let a_codramo = "008;";
			end if
		elif _borderaux = '10' then
			if a_codramo = '*' then
				let a_codramo = "002;";
			end if

		end if

	 end if

     LET _ano        = a_periodo1[1,4];
     LET v_descr_cia = sp_sis01(a_compania);
	
	-- Cargar los valores de devolucion de primas	  Crea tabla temp_det  (temporal)
	call sp_pr860c1(a_compania,a_agencia,a_periodo1,a_periodo2,a_codsucursal,a_codgrupo,a_codagente,a_codusuario,a_codramo,a_reaseguro,a_serie,a_tipo_bx) 
	returning _error,_error_desc;
	
	if _error = 1 then
		drop table temp_produccion;
		RETURN	"",
				"",
				"",
				"",
				0.00, 
				0.00, 
				0.00, 
				0.00, 
				0.00, 
				0.00, 
				0.00, 
				0.00, 
				"No Existe Distribucion de Reaseguro",
				"",
				v_descr_cia,
				"";
	end if
	
	select * 
	  from temp_produccion
	  into temp temp_devpri;
	
	drop table temp_produccion;	
     CALL sp_pro307(a_compania,a_agencia,a_periodo1,a_periodo2,a_codsucursal,a_codgrupo,   --crea tabla temp_det (temporal)
                   a_codagente,a_codusuario,a_codramo,a_reaseguro) RETURNING v_filtros;

	-- Cargar el Incurrido	  Crea tabla tmp_sinis  (temporal)
 		LET v_filtros2 = sp_rec708(
		a_compania,
		a_agencia,
		a_periodo1,
		a_periodo2,
		a_codsucursal,
		'*', 
		a_codramo, --'*',    ---a_ramo,
		'*', 
		'*', 
		'*', 
		'*',
		'*'     ---a_contrato
		);
			   
     CREATE TEMP TABLE temp_produccion
               (cod_ramo         CHAR(3),
			    cod_subramo		 char(3),
				cod_origen		 char(3),
                cod_contrato     CHAR(5),
				desc_contrato    CHAR(50),
                cod_cobertura    CHAR(3),
				prima            DEC(16,2),
				tipo             smallint default 0,
				comision         DEC(16,2),
				impuesto         DEC(16,2),
				por_pagar        DEC(16,2),
				desc_cob         CHAR(100),
				porc_comision 	 DECIMAL(16,2), 
				porc_impuesto 	 DECIMAL(16,2), 
				porc_cont_partic DECIMAL(16,2), 
				cod_coasegur 	 CHAR(3),
				tiene_comision   Smallint,
				serie 			 SMALLINT,
				no_poliza        char(10),
				no_remesa        char(10),
				renglon          integer) with no log;

            --PRIMARY KEY(cod_ramo, cod_subramo, cod_origen, cod_contrato, cod_cobertura, desc_cob, serie)) WITH NO LOG;

CREATE INDEX idx1_temp_produccion ON temp_produccion(cod_ramo);
CREATE INDEX idx2_temp_produccion ON temp_produccion(cod_subramo);
CREATE INDEX idx3_temp_produccion ON temp_produccion(cod_origen);
CREATE INDEX idx4_temp_produccion ON temp_produccion(cod_contrato);
CREATE INDEX idx5_temp_produccion ON temp_produccion(cod_cobertura);
CREATE INDEX idx6_temp_produccion ON temp_produccion(desc_cob);
CREATE INDEX idx7_temp_produccion ON temp_produccion(cod_coasegur);
CREATE INDEX idx8_temp_produccion ON temp_produccion(serie);
       
     CREATE TEMP TABLE tmp_priret
               (cod_ramo         CHAR(3),
			    prima_sus_tot    DEC(16,2),
				prima            DEC(16,2),
				prima_sus_t      DEC(16,2)) WITH NO LOG;

      let v_prima        = 0;
	  let _cod_subramo   = "001";
	  let _prima_tot_ret = 0;
	  let _prima_sus_tot = 0;
	  let _p_sus_tot     = 0;
	  let _p_sus_tot_sum = 0;
	  let _tipo_cont     = 0;
	  let _porc_comis_ase = 0;
	  let v_prima10       = 0;
	  let _por_pagar10    = 0;
	  let _comision10     = 0;
	  let _impuesto10     = 0;


FOREACH
	     select z.no_poliza,
				z.no_endoso,
		        z.prima_neta,
				z.vigencia_inic,
				z.no_remesa,
				z.renglon
           into v_nopoliza,
	     		v_noendoso,
		        v_prima_cobrada,
				_fecha,
				_no_remesa,
				_renglon
           from temp_det z
          where z.seleccionado = 1
		
		let _prima_devuelta = 0.00;
		
		 select cod_ramo,
		 	    cod_origen,
				no_documento
		   into v_cod_ramo,
		   	    _cod_origen,
				_no_documento
		   from emipomae
		  where no_poliza = v_nopoliza;

		 let v_nopoliza    = v_nopoliza;
		 let _no_documento = _no_documento;

		 select porc_partic_coas
		   into _porc_partic_coas 
		   from emicoama
		  where no_poliza    = v_nopoliza
		    and cod_coasegur = "036"; 			

		 if _porc_partic_coas is null then
		 	let _porc_partic_coas = 100;
		 end if

		 let v_prima_cobrada = v_prima_cobrada * _porc_partic_coas / 100;

		 select count(*)
		   into _cantidad
		   from tmp_priret
		  where cod_ramo = v_cod_ramo;

		 if _cantidad = 0 then
			INSERT INTO tmp_priret
			VALUES(v_cod_ramo,v_prima_cobrada,0,0);
		 else

			update tmp_priret
			   set prima_sus_tot = prima_sus_tot + v_prima_cobrada
		     where cod_ramo = v_cod_ramo;

		 end if

         FOREACH

			    select cod_contrato,
			    	   porc_partic_prima,
					   porc_proporcion,
					   cod_cober_reas
	              into v_cod_contrato,
	              	   _porc_partic_prima,
					   _porc_proporcion,
					   v_cobertura
	              from cobreaco
				 where no_remesa = _no_remesa
				   and renglon   = _renglon

				select traspaso,tiene_comision
				  into _traspaso,_tiene_comision
				  from reacocob
				 where cod_contrato   = v_cod_contrato
				   and cod_cober_reas = v_cobertura;

				Select cod_traspaso,
					   tipo_contrato,
					   serie
				  Into _cod_traspaso,
					   v_tipo_contrato,
					   _serie
				  From reacomae
				 Where cod_contrato = v_cod_contrato;

				if _traspaso = 1 then
					let v_cod_contrato = _cod_traspaso;
				end if

				let _tipo_cont = 0;

	            IF v_tipo_contrato = 3 THEN

					let _tipo_cont = 2;

	            elif v_tipo_contrato = 1 then --retencion

				   let v_prima1 = v_prima_cobrada * _porc_partic_prima / 100;

					update tmp_priret
					   set prima    = prima + v_prima1
				     where cod_ramo = v_cod_ramo;

					 let _tipo_cont = 1;
	            END IF

			   let v_prima1 = v_prima_cobrada * (_porc_partic_prima / 100) * (_porc_proporcion / 100);
               let v_prima  = v_prima1;

		        SELECT nombre,
				       serie
		          INTO v_desc_contrato,
				       _serie
		          FROM reacomae
		         WHERE cod_contrato = v_cod_contrato;

				let _nombre_con = trim(v_desc_contrato) || " (" || v_cod_contrato || ")" || "  A: " || _serie;
				let _cuenta     = sp_sis15("PPRXP", "05", _cod_origen, v_cod_ramo, _cod_subramo);

				SELECT nombre
				  INTO v_desc_ramo
				  FROM prdramo
				 WHERE cod_ramo = v_cod_ramo;

				Select porc_impuesto,
				       porc_comision,
					   tiene_comision
				  Into _porc_impuesto,
					   _porc_comision,
					   _tiene_comis_rea
				  From reacocob
				 Where cod_contrato   = v_cod_contrato
				   And cod_cober_reas = v_cobertura;

		         SELECT nombre
		           INTO _nombre_cob
		           FROM reacobre
		          WHERE cod_cober_reas = v_cobertura;

				 select count(*)
				   into _cantidad
				   from reacoase
			      where cod_contrato   = v_cod_contrato
			        and cod_cober_reas = v_cobertura;

			 if _tipo_cont = 0 then

				  if _cantidad = 0 then

					  let v_desc_contrato  = "******* NO EXISTE REGISTRO DE COMPANIAS " || v_cod_contrato;

					  select count(*)
					    into _cantidad
					    from temp_produccion
					   where cod_ramo      = v_cod_ramo
					     and cod_subramo   = _cod_subramo
					     and cod_origen    = _cod_origen
					     and cod_contrato  = v_cod_contrato
					     and cod_cobertura = v_cobertura
					     and desc_cob      = _nombre_cob
					     and serie = _serie ;

					 	if _cantidad = 0 then

					 		INSERT INTO temp_produccion
					             VALUES(v_cod_ramo,
					 			        _cod_subramo,
					 					_cod_origen,
					                    v_cod_contrato,
					 					v_desc_contrato,
					                    v_cobertura,
					                    v_prima,
					                    _tipo_cont,
					                    0, 
					                    0, 
					                    0,
					                    _nombre_cob,
					                    0,
					                    0,
					                    0,
					                    '999',
					                    _tiene_comis_rea,
										_serie,'','',0);
					 	end if

				  else

				 	 	foreach
				 			select porc_cont_partic,
				 				   porc_comision,
				 				   cod_coasegur
				 			  into _porc_cont_partic,
				 			   	   _porc_comis_ase,
				 				   _cod_coasegur
				 			  from reacoase
				 		     where cod_contrato   = v_cod_contrato
				 		       and cod_cober_reas = v_cobertura
				 				
				 			if _tipo_cont = 1 then
				 				let _cod_coasegur = '036'; --ancon
				 			end if

				 			select nombre
				 			  into _nombre_coas
				 			  from emicoase
				 			 where cod_coasegur = _cod_coasegur;

				 			-- La comision se calcula por reasegurador

				 			if _tiene_comis_rea = 2 then 
				 				let _porc_comision = _porc_comis_ase;
				 			end if

				 			let v_desc_cobertura = "";
				 			let v_desc_cobertura = trim(_nombre_cob) || "  " || trim(_cuenta) || "  " || trim(_nombre_coas);
				 			let v_desc_contrato  = trim(v_desc_contrato) || "  I:" || _porc_impuesto || "  C:" || _porc_comision;

				 			let _monto_reas = v_prima     * _porc_cont_partic / 100;
				 			let _impuesto   = _monto_reas * _porc_impuesto / 100;
				 			let _comision   = _monto_reas * _porc_comision / 100;
				 			let _por_pagar  = _monto_reas - _impuesto - _comision;

							let _cantidad = 0;


				 				INSERT INTO temp_produccion
				 	                  VALUES(v_cod_ramo,
				 					         _cod_subramo,
				 							 _cod_origen,
				 	                         v_cod_contrato,
				 							 v_desc_contrato,
				 	                         v_cobertura,
				 	                         _monto_reas,
				 	                         _tipo_cont,
				 	                         _comision, 
				 	                         _impuesto, 
				 	                         _por_pagar,
				 	                         v_desc_cobertura,
				 	                         _porc_comision,
				 	                         _porc_impuesto,
				 	                         _porc_cont_partic,
				 	                         _cod_coasegur,
				 	                         _tiene_comis_rea,
				 	                         _serie,v_nopoliza,_no_remesa,_renglon);

				 		END FOREACH

				  END if
			  END if

		 END FOREACH

END FOREACH


--DROP TABLE temp_produccion;
--DROP TABLE temp_det;
DROP TABLE tmp_priret;
DROP TABLE tmp_sinis;
--DROP TABLE temp_devpri;

END

END PROCEDURE 