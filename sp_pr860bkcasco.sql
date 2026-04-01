------------------------------------------------
--      TOTALES DE PRODUCCION POR             --  
--         CONTRATO DE REASEGURO              --
---  Yinia M. Zamora - octubre 2000 - YMZM	  --
---  Ref. Power Builder - d_sp_pro40		  --
--- Modificado por Armando Moreno 19/01/2002; -- la parte de los tipo de contratos
------------------------------------------------
--execute procedure sp_pr860bk('001','001','2012-07','2012-09',"*","*","*","*","001,003,006,008,010,011,012,013,014,021,022;","*","2012,2011,2010,2009,2008;")

--drop procedure sp_pr860casco;
CREATE PROCEDURE sp_pr860casco(a_compania CHAR(03),a_agencia CHAR(03),a_periodo1 CHAR(07),a_periodo2 CHAR(07),a_codsucursal CHAR(255) DEFAULT "*",a_codgrupo  CHAR(255) DEFAULT "*",a_codagente CHAR(255) DEFAULT "*",a_codusuario CHAR(255) DEFAULT "*",a_codramo  CHAR(255) DEFAULT "*",a_reaseguro CHAR(255) DEFAULT "*",a_serie CHAR(255) DEFAULT "*",a_tipo_bx char(2) DEFAULT "01")
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

     SET ISOLATION TO DIRTY READ;

	 LET _borderaux = a_tipo_bx;   -- BOUQUET,CUOTA PARTE ACC PERS, VIDA, FACILIDAD CAR
	 select tipo into _tipo2 from reacontr where cod_contrato = _borderaux;
	 CALL sp_rea002(a_periodo2,_tipo2) RETURNING _anio_reas,_trim_reas;
	 
	 let _contrato_xl = 0; 

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
            PRIMARY KEY(cod_ramo, cod_subramo, cod_origen, cod_contrato, cod_cobertura, desc_cob, serie)) WITH NO LOG;

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
				z.vigencia_inic
           into v_nopoliza,
	     		v_noendoso,
		        v_prima_cobrada,
				_fecha
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

		 select count(*)
		   into _cantidad
		   from emireama	
		  where no_poliza      = v_nopoliza
		    and vigencia_inic  <= _fecha
		    and vigencia_final >= _fecha;

		 if _cantidad = 0 then

				select count(*)
				  into _cantidad
				  from emireama	
				 where no_poliza = v_nopoliza;

				if _cantidad = 0 then

			         RETURN "",
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
							v_descr_cia
							,""
			                WITH RESUME;
				else

					select max(no_cambio)
					  into _no_cambio
					  from emireama	
					 where no_poliza = v_nopoliza;

				end if

		 else

				select max(no_cambio)
				  into _no_cambio
				  from emireama	
				 where no_poliza      = v_nopoliza
				   and vigencia_inic  <= _fecha
				   and vigencia_final >= _fecha;

		 end if

		 select min(no_unidad)
		   into _no_unidad
		   from emireama
		  where no_poliza = v_nopoliza
		    and no_cambio = _no_cambio; 			    	
		--foreach
		 select min (cod_cober_reas)
		   into v_cobertura
		   from emireama
		  where no_poliza = v_nopoliza
		    and no_unidad = _no_unidad
		    and no_cambio = _no_cambio;
		--group by cod_cober_reas

		if v_cod_ramo <> '002' then

         FOREACH
			    select cod_contrato,
			    	   porc_partic_prima
	              into v_cod_contrato,
	              	   _porc_partic_prima
	              from emireaco
				 where no_poliza      = v_nopoliza
				   and no_unidad      = _no_unidad
				   and no_cambio      = _no_cambio
				   and cod_cober_reas = v_cobertura

			   {select count(*)
				  into _cnt
				  from rearucon r, rearumae e
				 where r.cod_ruta = e.cod_ruta
				   and r.cod_contrato = v_cod_contrato
				   and e.activo = 1;

				 if _cnt > 0 then
				 else
					continue foreach;
				 end if}

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

			   let v_prima1 = v_prima_cobrada * _porc_partic_prima / 100;
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
										_serie
					                    );
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

				 			select count(*)
				 			  into _cantidad
				 			  from temp_produccion
				 			 where cod_ramo      = v_cod_ramo
				 			   and cod_subramo   = _cod_subramo
				 			   and cod_origen    = _cod_origen
				               and cod_contrato  = v_cod_contrato
				               and cod_cobertura = v_cobertura
				               and desc_cob      = v_desc_cobertura
				               and serie         = _serie;

				 			if _cantidad = 0 then

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
				 	                         _serie);
				 			else
				 			   
				                UPDATE temp_produccion
				                   SET prima         = prima     + _monto_reas,
				                   	   comision      = comision  + _comision,
				 					   impuesto      = impuesto  + _impuesto,
				 					   por_pagar     = por_pagar + _por_pagar
				                 WHERE cod_ramo      = v_cod_ramo
				 				   and cod_subramo   = _cod_subramo
				 				   and cod_origen    = _cod_origen
				                   and cod_contrato  = v_cod_contrato
				                   and cod_cobertura = v_cobertura
				                   and desc_cob      = v_desc_cobertura
				                   and serie         = _serie;

				 			END if

				 		END FOREACH

				  END if
			  END if

         --end foreach
		 END FOREACH

		else

         FOREACH
			    select cod_contrato,
			    	   porc_partic_prima,
					   cod_cober_reas
	              into v_cod_contrato,
	              	   _porc_partic_prima,
					   v_cobertura
	              from emireaco
				 where no_poliza      = v_nopoliza
				   and no_unidad      = _no_unidad
				   and no_cambio      = _no_cambio

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

			   let v_prima1 = v_prima_cobrada * _porc_partic_prima / 100;
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
										_serie
					                    );
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

				 			select count(*)
				 			  into _cantidad
				 			  from temp_produccion
				 			 where cod_ramo      = v_cod_ramo
				 			   and cod_subramo   = _cod_subramo
				 			   and cod_origen    = _cod_origen
				               and cod_contrato  = v_cod_contrato
				               and cod_cobertura = v_cobertura
				               and desc_cob      = v_desc_cobertura
				               and serie         = _serie;

				 			if _cantidad = 0 then

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
				 	                         _serie);
				 			else
				 			   
				                UPDATE temp_produccion
				                   SET prima         = prima     + _monto_reas,
				                   	   comision      = comision  + _comision,
				 					   impuesto      = impuesto  + _impuesto,
				 					   por_pagar     = por_pagar + _por_pagar
				                 WHERE cod_ramo      = v_cod_ramo
				 				   and cod_subramo   = _cod_subramo
				 				   and cod_origen    = _cod_origen
				                   and cod_contrato  = v_cod_contrato
				                   and cod_cobertura = v_cobertura
				                   and desc_cob      = v_desc_cobertura
				                   and serie         = _serie;

				 			END if

				 		END FOREACH

				  END if
			  END if

         --end foreach
		 END FOREACH

		end if
END FOREACH

-- Carga Temporal contrato por ramos.
LET _ano2 =  a_periodo2[1,4];

FOREACH 
	select cod_ramo,
	       cod_subramo,
		   cod_origen,
           cod_contrato,
		   desc_contrato,
           cod_cobertura,
		   prima,
		   tipo,
		   comision,
		   impuesto,
		   por_pagar,
		   desc_cob,
		   porc_comision, 
		   porc_impuesto, 
		   porc_cont_partic, 
		   cod_coasegur,
		   serie
	  into v_cod_ramo, 
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
		   _serie1
	  from temp_produccion

	let _prima_devuelta = 0.00;
	
	select prima
	  into _prima_devuelta
	  from temp_devpri
	 where cod_ramo			= v_cod_ramo
	   and cod_subramo		= _cod_subramo
	   and cod_origen		= _cod_origen
	   and cod_contrato		= v_cod_contrato
	   and cod_cobertura	= v_cobertura
	   and desc_cob			= v_desc_cobertura
	   and serie			= _serie1;
	
	if _prima_devuelta is null then
		let _prima_devuelta = 0.00;
	end if
	
	let _monto_reas = _monto_reas - _prima_devuelta;
	
	delete from temp_devpri
	 where cod_ramo			= v_cod_ramo
	   and cod_subramo		= _cod_subramo
	   and cod_origen		= _cod_origen
	   and cod_contrato		= v_cod_contrato
	   and cod_cobertura	= v_cobertura
	   and desc_cob			= v_desc_cobertura
	   and serie			= _serie1;

		let _p_c_partic     = 0;
		let _p_c_partic_hay = 0;
		let _bouquet        = 0;

		select traspaso,tiene_comision,bouquet
		  into _traspaso,_tiene_comision,_bouquet
		  from reacocob
		 where cod_contrato   = v_cod_contrato
		   and cod_cober_reas = v_cobertura;

		Select tipo_contrato, serie,facilidad_car
		  Into v_tipo_contrato,_serie,_facilidad_car
	      From reacomae
		 Where cod_contrato = v_cod_contrato;
	 
		   let _serie = _serie1;

		    if _bouquet <> 1 then
			   CONTINUE FOREACH;
		    end if

			IF _bouquet = 1 AND _serie >= 2008 and _cod_coasegur in ('050','063','076','042','036','089') THEN	   -- Condiciones del Borderaux Bouquet
				LET _flag = 0;
				LET _cnt  = 0;

				if _facilidad_car = 0 then
					if _cnt = 0 then
	 	   	            LET _flag = 1;
					end if
				end if
		    END IF
		    LET nivel = 1;

			if _porc_cont_partic = 100 or _flag = 1 then
			   LET nivel = 2;
	 	    else
			   LET nivel = 1;
		    end if

		INSERT INTO temphg
		VALUES (_cod_coasegur,
		         v_cod_ramo,
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
		         _serie,
		         v_tipo_contrato,
		         _tiene_comision,
		         nivel,
		         _anio_reas,
				 _trim_reas,
				 _borderaux);

END FOREACH

-- trace on;
-- Carga reacoprs
-- Clasificasion - 1-R.C.G.(006), 2-Incendio (001,003)70%, 3-Terremoto(001,003)30%, 4-Ramos Tecnicos(010,011,014),
--    5-Fianzas(008,080), 6-Acc. Personales(004), 7-Vida Ind/Col(016,019)]

FOREACH
   select serie,cod_ramo,cod_contrato,cod_cobertura,sum(prima) 
     into _serie,v_cod_ramo,v_cod_contrato,v_cobertura,v_prima 
     from temphg
    Where cod_coasegur in ('050','063','076','042','036','089') 
	  and anio      = _anio_reas
	  and trimestre = _trim_reas
	  and borderaux = _borderaux 
    group by serie,cod_ramo,cod_contrato,cod_cobertura

  			FOREACH 
				select distinct cod_coasegur,porc_cont_partic,porc_comision,porc_impuesto
				  into _cod_coasegur,_porc_cont_partic,_porc_comision,_porc_impuesto
				  from temphg
				 Where serie         = _serie
				   and cod_coasegur in  ('050','063','076','042','036','089')
				   and cod_ramo      = v_cod_ramo  
				   and cod_contrato  = v_cod_contrato
				   and cod_cobertura = v_cobertura
				   and anio          = _anio_reas
				   and trimestre     = _trim_reas
				   and borderaux     = _borderaux 

					let _siniestro = 0;

					if _siniestro is null then
					   let _siniestro = 0;
				    end if				 

					if v_cod_ramo = '006' then --Resp. Civil
						 let v_clase = '001';  --R.C.G
					end if

					if v_cod_ramo = '001' or v_cod_ramo = '003' then --Inc, Multi
						 let v_clase = '002'; --incendio
					end if					

					if v_cod_ramo = '010' or v_cod_ramo = '011' or v_cod_ramo = '012' or v_cod_ramo = '013' or v_cod_ramo = '014' or v_cod_ramo = '022' then
						 let v_clase = '004'; --Ramos Tecnicos
					end if

					if v_cod_ramo = '008' or v_cod_ramo = '080' then --Fianzas
						 let v_clase = '005';						 --Fianzas
					end if

					if v_cod_ramo = '004' then --Acc. Personales
						 let v_clase = '006';  --Acc. Personales
					end if

					if v_cod_ramo = '019' then --Vida Ind.
						 let v_clase = '007';  						 --Vida Ind./Colectivo
					end if
					if v_cod_ramo = '016' then --Col. de Vida
						 let v_clase = '012';  						 --Colectivo
					end if

					if v_cod_ramo = '002' then --Automovil
						 let v_clase = '013';
					end if

					--contrato XL
					select contrato_xl
					  into _contrato_xl
					  from reacoase
					 where cod_contrato   = v_cod_contrato
					   and cod_cober_reas = v_cobertura
					   and cod_coasegur   = _cod_coasegur;

					if _contrato_xl = 1 then
						let _porc_cont_partic = 0;
					else
					end if

					if _porc_comision is null or _porc_comision = 0 then
					   LET _porc_comision4 = 0;
					else
					   LET _porc_comision4 = _porc_comision/100;
					end if

					if _porc_impuesto is null or _porc_impuesto = 0 then
					   LET _porc_impuesto4 = 0;
					else
					   LET _porc_impuesto4 = _porc_impuesto/100;
					end if

					LET _comision  = v_prima * _porc_comision4;
					LET _impuesto  = v_prima * _porc_impuesto4;
					LET _por_pagar = v_prima - _comision - _impuesto;

					if _porc_cont_partic < 100 then 
					   let _xnivel = '1';
  				    else
					   let _xnivel = '2';
				    end if			  

  					let _porc_terr = 0.30;
					let _porc_inun = 0.00;

			  		if v_clase = '002' then

						LET _comision70 = 0;
						LET _comision30 = 0;
						LET _comision10 = 0;
						let v_prima10   = 0;

						if _borderaux = '01' and _cod_coasegur = '042' and _serie >= 2012 then
						  let _porc_terr = 0.20;
						  let _porc_inun = 0.10;
						end if

					   	LET v_prima70 = v_prima * 0.70;
						LET v_prima30 =	v_prima * _porc_terr;
						let v_prima10 = v_prima * _porc_inun;

						LET _impuesto70  = _impuesto * 0.70;
						LET _impuesto30  = _impuesto * _porc_terr;
						LET _impuesto10  = _impuesto * _porc_inun;
						LET _por_pagar70 = _por_pagar * 0.70;
						LET _por_pagar30 = _por_pagar * _porc_terr;
						LET _por_pagar10 = _por_pagar * _porc_inun;
						LET _siniestro70 = _siniestro * 1;
						LET _siniestro30 = _siniestro * 0;	 
						LET _comision70  = v_prima70 * _porc_comision4 * 1;
						LET _comision30  = v_prima30 * _porc_comision4 * 1;
						LET _comision10  = v_prima10 * _porc_comision4 * 1;

						if v_cobertura = '021' or v_cobertura = '022' then

							FOREACH
							  select distinct porc_comision
								into _porc_comision4
								from reacoase
							   where cod_contrato   = v_cod_contrato
							     and cod_cober_reas in ('001','003')
								 and cod_coasegur = _cod_coasegur
								EXIT FOREACH;
							END FOREACH

							LET _comision70 = v_prima70 * _porc_comision4 * 1;

						end if

						if 	_cod_coasegur = '063' then
							LET _comision30 = v_prima30 * 0.225;
						else
							LET _comision30 = v_prima30 * 0.20;
							LET _comision10 = v_prima10 * 0.20;
						end if

						LET _por_pagar70 = v_prima70 - _comision70 - _impuesto70;
						LET _por_pagar30 = v_prima30 - _comision30 - _impuesto30;
						LET _por_pagar10 = v_prima10 - _comision10 - _impuesto10;
	
			 			if _cod_coasegur = '036' then
							LET _comision 	    = 0; 
							LET _impuesto 	    = 0; 
							LET _por_pagar	    = v_prima; 
							LET _comision70 	= 0; 
							LET _impuesto70 	= 0; 
							LET _por_pagar70	= v_prima70; 
							LET _comision30 	= 0; 
							LET _impuesto30 	= 0; 
							LET _por_pagar30	= v_prima30; 
						end if

						BEGIN
							ON EXCEPTION IN(-239)
								UPDATE reacoest
								   SET prima      = prima      + v_prima70, 
								       comision   = comision   + _comision70, 
								       impuesto   = impuesto   + _impuesto70, 
								       prima_neta = prima_neta + _por_pagar70, 
								       siniestro  = siniestro  + _siniestro70 
								 WHERE cod_coasegur	 = _cod_coasegur
								   AND cod_contrato  = _serie
								   AND cod_cobertura = _xnivel
								   AND p_partic      = _porc_cont_partic
								   AND cod_ramo      = v_cod_ramo 
								   and cod_clase     = '002'
								   and anio          = _anio_reas
								   and trimestre     = _trim_reas
								   and borderaux     = _borderaux; 

						END EXCEPTION 	

						INSERT INTO reacoest
						VALUES (_cod_coasegur,
							        v_cod_ramo,
									_serie,
									_xnivel,
									v_prima70, 
									_comision70, 
									_impuesto70, 
									_por_pagar70,
									_siniestro70,
									0,
									0,
									_porc_cont_partic,
									'002',
									_anio_reas,
									_trim_reas,
									_borderaux);
						END
						let _porc_cont_terr = 0;

						foreach
							  SELECT distinct porc_cont_partic
							    INTO _porc_cont_terr
							    FROM reacoase
							   WHERE ( cod_contrato = v_cod_contrato ) AND
							         ( cod_cober_reas in  ('021','022')) and
							         ( cod_coasegur  = _cod_coasegur)
									 order by 1 desc
								 exit foreach;
						end foreach

						  if _porc_cont_terr is null or _porc_cont_terr = 0 then
						  else
						  	BEGIN
						  	ON EXCEPTION IN(-239)
						  		UPDATE reacoest
						  		   SET prima         = prima      + v_prima30, 
						  			   comision      = comision   + _comision30, 
						  			   impuesto      = impuesto   + _impuesto30, 
						  			   prima_neta    = prima_neta + _por_pagar30, 
						  			   siniestro     = siniestro  + _siniestro30 
						  		 WHERE cod_coasegur	 = _cod_coasegur
							  	   AND cod_contrato  = _serie
							  	   AND cod_cobertura = _xnivel
							  	   AND p_partic      = _porc_cont_terr --_porc_cont_partic
							  	   AND cod_ramo      = v_cod_ramo 
							  	   AND cod_clase     = '003' 
							  	   AND anio          = _anio_reas
							  	   AND trimestre     = _trim_reas
							  	   AND borderaux     = _borderaux; 

						  	END EXCEPTION 	

						    INSERT INTO reacoest
						  	VALUES (_cod_coasegur,
							  	    v_cod_ramo,
							  		_serie,
							  		_xnivel,
							  		v_prima30, 
							  		_comision30, 
							  		_impuesto30, 
							  		_por_pagar30,
							  		_siniestro30,
							  		0,
							  		0,
							  		_porc_cont_terr, --_porc_cont_partic,
							  		'003',
							  		_anio_reas,
							  		_trim_reas,
							  		_borderaux);
						  	END

							if _borderaux = '01' and _cod_coasegur = '042' and _serie >= 2012 then

							  	BEGIN
							  	ON EXCEPTION IN(-239)
							  		UPDATE reacoest
							  		   SET prima         = prima      + v_prima10, 
							  			   comision      = comision   + _comision10, 
							  			   impuesto      = impuesto   + _impuesto10, 
							  			   prima_neta    = prima_neta + _por_pagar10, 
							  			   siniestro     = siniestro  + _siniestro30 
							  		 WHERE cod_coasegur	 = _cod_coasegur
								  	   AND cod_contrato  = _serie
								  	   AND cod_cobertura = _xnivel
								  	   AND p_partic      = _porc_cont_terr --_porc_cont_partic
								  	   AND cod_ramo      = v_cod_ramo 
								  	   AND cod_clase     = '011' 
								  	   AND anio          = _anio_reas
								  	   AND trimestre     = _trim_reas
								  	   AND borderaux     = _borderaux; 

							  	END EXCEPTION 	

							    INSERT INTO reacoest
							  	VALUES (_cod_coasegur,
								  	    v_cod_ramo,
								  		_serie,
								  		_xnivel,
								  		v_prima10, 
								  		_comision10, 
								  		_impuesto10, 
								  		_por_pagar10,
								  		_siniestro30,
								  		0,
								  		0,
								  		_porc_cont_terr, --_porc_cont_partic,
								  		'011',
								  		_anio_reas,
								  		_trim_reas,
								  		_borderaux);
							  	END

							end if
						  end if

					else	 
			 			if _cod_coasegur = '036' then
							LET _comision 	    = 0; 
							LET _impuesto 	    = 0; 
							LET _por_pagar	    = v_prima; 
							LET _comision70 	= 0; 
							LET _impuesto70 	= 0; 
							LET _por_pagar70	= v_prima70; 
							LET _comision30 	= 0; 
							LET _impuesto30 	= 0; 
							LET _por_pagar30	= v_prima30; 
						end if

						select count(*)
						  into _cnt
						  from reacoest
						 WHERE cod_coasegur	 = _cod_coasegur
						   AND cod_contrato  = _serie
						   AND cod_cobertura = _xnivel
						   AND p_partic      = _porc_cont_partic
						   AND cod_ramo      = v_cod_ramo
						   AND cod_clase     = v_clase 
						   and anio          = _anio_reas
						   and trimestre     = _trim_reas
						   and borderaux     = _borderaux; 

						if _cnt > 0 then

							UPDATE reacoest
							   SET prima         = prima      + v_prima, 
							       comision      = comision   + _comision, 
							       impuesto      = impuesto   + _impuesto, 
							       prima_neta    = prima_neta + _por_pagar, 
							       siniestro     = siniestro  + _siniestro 
							 WHERE cod_coasegur	 = _cod_coasegur
							   AND cod_contrato  = _serie
							   AND cod_cobertura = _xnivel
							   AND p_partic      = _porc_cont_partic
							   AND cod_ramo      = v_cod_ramo
							   AND cod_clase     = v_clase 
							   and anio          = _anio_reas
							   and trimestre     = _trim_reas
							   and borderaux     = _borderaux; 

						else

						    INSERT INTO reacoest
							VALUES (_cod_coasegur,
							        v_cod_ramo,
									_serie,
									_xnivel,
									v_prima, 
									_comision, 
									_impuesto, 
									_por_pagar,
									_siniestro,
									0,
									0,
									_porc_cont_partic,
							        v_clase,
									_anio_reas,
									_trim_reas,
									_borderaux);
						end if
			 		end if

			END FOREACH
END FOREACH		

--evento inundacion para tomar la participacion de la swiss re

let _cnt2       = 0;
let _siniestro3 = 0;
let _siniestro4 = 0;
let _sini_inc   = 0;
let _sini_mul   = 0;

foreach

	SELECT t.no_reclamo,t.pagado_neto,t.cod_ramo
	  INTO _no_reclamo,_pagado_neto,_cod_ramo
	  FROM tmp_sinis t, reacomae r
	 where r.cod_contrato = t.cod_contrato
	   and t.seleccionado = 1
	   and t.tipo_contrato not in ('3','1')
	   and r.serie >= 2012
	   and t.cod_ramo in('001','003')

	{select count(*)
	  into _cnt3
	  from recrccob
	 where no_reclamo = _no_reclamo
	   and cod_cobertura in('00010','00013','00036','00057','00058',
	                        '00059','00068','00089','00097','00125',
	                        '00160','00179','00182','00725','00726',
	                        '00732','00742','00743','00748','00754',
	                        '00781','00785','00790','00793','00855',
	                        '00878','00024');}
	select count(*)
	  into _cnt3 
	  from recrccob r, prdcober p
	 where r.cod_cobertura = p.cod_cobertura
   	   and r.no_reclamo    = _no_reclamo
	   and p.relac_inundacion = 1;


	if _cod_ramo = '001' then
	   let _sini_inc = _sini_inc + _pagado_neto;
	else
	   let _sini_mul = _sini_mul + _pagado_neto;
	end if

	if _cnt3 > 0 then
		let _cnt2 = 1;
		if _cod_ramo = '001' then
			let _siniestro3 = _siniestro3 + _pagado_neto;
		else
			let _siniestro4 = _siniestro4 + _pagado_neto;
		end if
	end if

end foreach
if _siniestro3 > 0 then
	let _siniestro3	= abs(_sini_inc - _siniestro3);
end if
if _siniestro4 > 0 then
	let _siniestro4	= abs(_sini_mul - _siniestro4);
end if

let _siniestro2 = 0;
let _sini_bk    = 0;
let _cnt3       = 0;
let _pagado_neto = 0;

--evento inundacion para tomar la participacion de la swiss re en terremoto
foreach

	SELECT t.no_reclamo, t.pagado_neto
	  INTO _no_reclamo,_pagado_neto
	  FROM tmp_sinis t, reacomae r
	 where r.cod_contrato = t.cod_contrato
	   and t.seleccionado = 1
	   and t.tipo_contrato not in ('3','1')
	   and r.serie = 2011
	   and t.cod_ramo in('001','003')

	{select count(*)
	  into _cnt3
	  from recrccob
	 where no_reclamo = _no_reclamo
	   and cod_cobertura in('00010','00013','00036','00057','00058',
	                        '00059','00068','00089','00097','00125',
	                        '00160','00179','00182','00725','00726',
	                        '00732','00742','00743','00748','00754',
	                        '00781','00785','00790','00793','00855',
	                        '00878','00024');}

	select count(*)
	  into _cnt3 
	  from recrccob r, prdcober p
	 where r.cod_cobertura = p.cod_cobertura
   	   and r.no_reclamo    = _no_reclamo
	   and p.relac_inundacion = 1;

	if _cnt3 > 0 then
		let _siniestro2 = _siniestro2 + _pagado_neto;
	end if

end foreach

FOREACH
       SELECT r.serie,t.cod_ramo,t.cod_contrato,sum(t.pagado_neto) 
	     INTO _serie,v_cod_ramo,v_cod_contrato,_siniestro 
         FROM tmp_sinis t, reacomae r 
        where r.cod_contrato = t.cod_contrato 
          and t.seleccionado = 1 
          and t.tipo_contrato not in ('3','1') 
          and r.serie >= 2008 
          and t.cod_ramo in ("001","003","006","010","011","012","013","014","008","080","004","019","016","021","022","002")
     group by r.serie,t.cod_ramo,t.cod_contrato
     order by r.serie,t.cod_ramo,t.cod_contrato

		select count(*)
		  into _cnt
		  from temphg 
		 where cod_ramo     = v_cod_ramo
		   and cod_contrato = v_cod_contrato
		   and serie        = _serie;

		if _cnt > 0 then

			foreach
				select distinct cod_cobertura
				  into v_cobertura
				  from temphg 
				 where cod_ramo     = v_cod_ramo
				   and cod_contrato = v_cod_contrato
				   and serie        = _serie
			  exit foreach;
		    end foreach
		else

		   foreach

				select distinct cod_cober_reas
				  into v_cobertura
				  from reacobre
				 where cod_ramo = v_cod_ramo

				exit foreach;

		   end foreach
			
		end if

		let _sini_bk = _siniestro;

		FOREACH
		   select distinct cod_cober_reas,cod_coasegur,porc_cont_partic
		     into v_cobertura,_cod_coasegur,_porc_cont_partic
		     from reacoase
			where cod_contrato   = v_cod_contrato
			  and cod_cober_reas = v_cobertura

				let _siniestro = _sini_bk;

				if v_cod_ramo = '002' then 
					 let v_clase = '013' ; --Automovil
				end if

				if v_cod_ramo = '006' then 
					 let v_clase = '001' ; --R.C.G.
				end if

				if v_cod_ramo = '001' or v_cod_ramo = '003' then 
					 let v_clase = '002' ; --INCENDIO
				end if					

				if v_cod_ramo = '010' or v_cod_ramo = '011' or v_cod_ramo = '012' or v_cod_ramo = '013' or v_cod_ramo = '014' or v_cod_ramo = '022' then
					 let v_clase = '004' ; --RAMOS TECNICOS
				end if

				if v_cod_ramo = '008' or v_cod_ramo = '080' then 
					 let v_clase = '005' ; --FIANZAS
				end if
				if v_cod_ramo = '004' then 
					 let v_clase = '006' ; --ACCIDENTES PERSONALES
				end if
				if v_cod_ramo = '019' then 
					 let v_clase = '007' ; --VIDA IND. COL DE VIDA
				end if

				if v_cod_ramo = '016' then --Col. de Vida
					 let v_clase = '012';
				end if

			   	if _borderaux = '01' and _cod_coasegur = '042' and _serie >= 2012 then
					if ((v_cod_ramo = '001' or v_cod_ramo = '003') and _cnt2 > 0) then 
						 let v_clase = '011';
						 if v_cod_ramo = '001' then
						     if _siniestro3 = 0 then
								 let _siniestro = 0;
							 end if
							 let _siniestro = abs(_siniestro - _siniestro3);
						 else
						     if _siniestro4 = 0 then
								 let _siniestro = 0;
							 end if
							 let _siniestro = abs(_siniestro - _siniestro4);
						 end if
					end if					
				end if

				if _porc_cont_partic < 100 then 
				   let _xnivel = '1';
			    else
				   let _xnivel = '2';
	    		end if
			   	if _borderaux = '01' and _cod_coasegur = '042' and _serie = 2011 then
					if v_cod_ramo = '001' and _siniestro2 <> 0 then
						 let _sini_dif = 0;
						 let _sini_dif = _siniestro - _siniestro2;
						 let _sini_dif = abs(_sini_dif);

						UPDATE reacoest 
						   SET siniestro     = siniestro + _sini_dif 
						 WHERE cod_coasegur	 = _cod_coasegur 
						   AND cod_contrato  = _serie 
						   AND cod_cobertura = _xnivel 
						   AND p_partic      = _porc_cont_partic 
						   AND cod_ramo      = v_cod_ramo 
						   AND cod_clase     = v_clase 
						   AND anio          = _anio_reas 
						   AND trimestre     = _trim_reas 
						   AND borderaux     = _borderaux; 

						 let v_clase     = '003';
						 let v_cobertura = '021';

						 select porc_cont_partic
						   into _porc_cont_partic
						   from reacoase
						  where cod_contrato   = v_cod_contrato
						    and cod_cober_reas = v_cobertura
						    and cod_coasegur   = _cod_coasegur;

						 let _siniestro = _siniestro2;
					end if

				end if

				if _porc_cont_partic < 100 then 
				   let _xnivel = '1';
				else
				   let _xnivel = '2';
			    end if

				--contrato XL
				select contrato_xl
				  into _contrato_xl
				  from reacoase
				 where cod_contrato   = v_cod_contrato
				   and cod_cober_reas = v_cobertura
				   and cod_coasegur   = _cod_coasegur;

				if _contrato_xl = 1 then
				    if v_clase <> "011" then
						let _porc_cont_partic = 0;
					end if
				else
				end if

				select count(*)
				  into _cantidad
				  from reacoest
				 WHERE cod_coasegur	 = _cod_coasegur 
				   AND cod_contrato  = _serie 
				   AND cod_cobertura = _xnivel 
				   AND p_partic      = _porc_cont_partic 
				   AND cod_ramo      = v_cod_ramo 
				   AND cod_clase     = v_clase 
				   AND anio          = _anio_reas 
				   AND trimestre     = _trim_reas 
				   AND borderaux     = _borderaux; 

			    if _cantidad > 0 then

					UPDATE reacoest 
					   SET siniestro     = siniestro + _siniestro 
					 WHERE cod_coasegur	 = _cod_coasegur 
					   AND cod_contrato  = _serie 
					   AND cod_cobertura = _xnivel 
					   AND p_partic      = _porc_cont_partic 
					   AND cod_ramo      = v_cod_ramo 
					   AND cod_clase     = v_clase 
					   AND anio          = _anio_reas 
					   AND trimestre     = _trim_reas 
					   AND borderaux     = _borderaux; 
				else
				    INSERT INTO reacoest
					VALUES (_cod_coasegur,
					        v_cod_ramo,
							_serie,
							_xnivel,
							0, 
							0, 
							0, 
							0,
							_siniestro,
							0,
							0,
							_porc_cont_partic,
					        v_clase,
							_anio_reas,
							_trim_reas,
							_borderaux);

			  	end if
		END FOREACH	

END FOREACH
--Traspaso de Cartera
FOREACH
     SELECT cod_coasegur,
			cod_clase,
			cod_contrato,
			cod_cobertura,
			p_partic,
			cod_ramo,
			sum(prima),
			sum(comision),
			sum(impuesto),
			sum(prima_neta),
			sum(siniestro),
			sum(resultado),
			sum(participar)			
       INTO _cod_coasegur,
	        v_cod_ramo,
			v_cod_contrato,
			v_cobertura,
			_porc_cont_partic,
			_cod_ramo,
			v_prima, 
			_comision, 
			_impuesto, 
			_por_pagar,
			_siniestro,
			_prima_tot_ret,
			_prima_sus_tot			
       FROM reacoest	
	  where anio      = _anio_reas
		and trimestre = _trim_reas
		and borderaux in(_borderaux)
		and cod_contrato < 2010
		and cod_clase in('001','002','003') --solo para incendio, resp. civil y terremoto
	  group by cod_coasegur,cod_clase,cod_contrato,cod_cobertura,p_partic,cod_ramo
	  order by cod_coasegur,cod_clase,cod_contrato

	select count(*)
	  into _cnt
	  from reacoest
	 WHERE cod_coasegur	 = _cod_coasegur
	   AND cod_contrato  = 2010
	   AND cod_cobertura = v_cobertura
	   AND cod_clase     = v_cod_ramo 
	   and anio          = _anio_reas
	   and trimestre     = _trim_reas
	   and borderaux     = _borderaux
	   and prima         <> 0;

	if _cnt = 0 then
	    INSERT INTO reacoest
		VALUES (_cod_coasegur,
		        _cod_ramo,
				2010,
				v_cobertura,
				v_prima, 
				_comision, 
				_impuesto,
				_por_pagar,
				0,--_siniestro, --
				0,
				0,
				_porc_cont_partic,
		        v_cod_ramo,
				_anio_reas,
				_trim_reas,
				_borderaux);

		UPDATE reacoest
		   SET prima         = 0,
		       comision      = 0,
		       impuesto      = 0,
		       prima_neta    = 0
		 WHERE cod_coasegur	 = _cod_coasegur
		   AND cod_contrato  = v_cod_contrato
		   AND cod_cobertura = v_cobertura
		   AND cod_clase     = v_cod_ramo 
		   and anio          = _anio_reas
		   and trimestre     = _trim_reas
		   and borderaux     = _borderaux
		   and prima         <> 0;

	else

		UPDATE reacoest
		   SET prima         = prima      + v_prima, 
		       comision      = comision   + _comision, 
		       impuesto      = impuesto   + _impuesto, 
		       prima_neta    = prima_neta + _por_pagar 
		 WHERE cod_coasegur	 = _cod_coasegur
		   AND cod_contrato  = 2010
		   AND cod_cobertura = v_cobertura
		   AND cod_clase     = v_cod_ramo 
		   and anio          = _anio_reas
		   and trimestre     = _trim_reas
		   and borderaux     = _borderaux
		   and prima         <> 0;

		UPDATE reacoest
		   SET prima         = 0,
		       comision      = 0,
		       impuesto      = 0,
		       prima_neta    = 0
		 WHERE cod_coasegur	 = _cod_coasegur
		   AND cod_contrato  = v_cod_contrato
		   AND cod_cobertura = v_cobertura
		   AND cod_clase     = v_cod_ramo 
		   and anio          = _anio_reas
		   and trimestre     = _trim_reas
		   and borderaux     = _borderaux
		   and prima         <> 0;
	end if

END FOREACH
------------	 

Update reacoest
   set resultado  = prima_neta - siniestro, 
       participar = (prima_neta - siniestro) * (p_partic/100) 
 where anio       = _anio_reas
   and trimestre  = _trim_reas
   and borderaux  = _borderaux;

-- Filtro por Serie
IF a_serie <> "*" THEN
	LET v_filtros = TRIM(v_filtros) ||" Serie "||TRIM(a_serie);
	LET _tipo = sp_sis04(a_serie); -- Separa los valores del String

END IF

if _borderaux = '01' or _borderaux = '06' then

	update reacoest
	   set borderaux     = '06'
	 where anio          = _anio_reas
	   and trimestre     = _trim_reas
	   and borderaux     = _borderaux
	   and cod_cobertura = 2;

	foreach
		select cod_contrato
		  into _cod_c
		  from temphg
		 where borderaux = _borderaux
		   and trimestre = _trim_reas
		   and anio      = _anio_reas
		   and cod_cobertura = '014'   --Facilidad car

		select facilidad_car
		  into _facilidad_car
		  from reacomae
		 where cod_contrato = _cod_c;

	    if _facilidad_car = 1 then

			update temphg
			   set borderaux = '06'
			 where borderaux = _borderaux
			   and trimestre = _trim_reas
			   and anio      = _anio_reas
			   and cod_cobertura = '014'   --Facilidad car
			   and cod_contrato  = _cod_c;
		end if

	end foreach
	if _borderaux = '06' then
		delete from reacoest
		 where borderaux = _borderaux
		   and trimestre = _trim_reas
		   and anio      = _anio_reas
		   and cod_cobertura <> '2';
	end if

	update reacoest
	   set borderaux     = '09'
	 where anio          = _anio_reas
	   and trimestre     = _trim_reas
	   and borderaux     = _borderaux
	   and cod_clase     = '005'
	   and cod_coasegur  = '042';

end if

if _borderaux = '09' then

	delete from reacoest
	 where borderaux = _borderaux
	   and trimestre = _trim_reas
	   and anio      = _anio_reas
	   and cod_coasegur  <> '042';

end if

if _borderaux = '10' then

	delete from reacoest
	 where borderaux = _borderaux
	   and trimestre = _trim_reas
	   and anio      = _anio_reas
	   and cod_coasegur  <> '063';

end if

if a_serie = '*' then

	FOREACH
	     SELECT cod_coasegur,
				cod_clase,
				cod_contrato,
				cod_cobertura,
				p_partic,
				sum(prima),
				sum(comision),
				sum(impuesto),
				sum(prima_neta),
				sum(siniestro),
				sum(resultado),
				sum(participar)			
	       INTO _cod_coasegur,
		        v_cod_ramo,
				v_cod_contrato,
				v_cobertura,
				_porc_cont_partic,
				v_prima, 
				_comision, 
				_impuesto, 
				_por_pagar,
				_siniestro,
				_prima_tot_ret,
				_prima_sus_tot			
	       FROM reacoest	
		  where anio      = _anio_reas
			and trimestre = _trim_reas
			and borderaux in(_borderaux)
		  group by cod_coasegur,cod_clase,cod_contrato,cod_cobertura,p_partic

	-- Clasificasion - 1-R.C.G.(006), 2-Incendio (001,003)70%,3-Terremoto(001,003)30%,4-Ramos Tecnicos(010,011,014),
	--    5-Fianzas(008,080),6-Acc. Personales(004),7-Vida Ind/Col(016,019)]
	--    modifico: 14/05/2010 solicitado: Omar Wong - Para dividir 7-Vida Individual 8-Colectivo de Vida

				SELECT rearamo.nombre
				  INTO v_desc_ramo
				  FROM rearamo  
				 WHERE rearamo.ramo_reas = v_cod_ramo;

				if v_cod_ramo = '002' then
				   LET v_desc_ramo = 'Automovil';
				end if

				if v_cod_ramo = '001' then
				   LET v_desc_ramo = 'R.C.G.';
				end if

				if v_cod_ramo = '002' then
				   LET v_desc_ramo = 'Incendio';
				end if

				if v_cod_ramo = '003' then
				   LET v_desc_ramo = 'Terremoto';
				end if

				if v_cod_ramo = '004' then
				   LET v_desc_ramo = 'Ramos Tecnicos';
				end if

				if v_cod_ramo = '005' then
				   LET v_desc_ramo = 'Fianzas';
				end if

				if v_cod_ramo = '006' then
				   LET v_desc_ramo = 'Acc. Personales';
				end if

				if v_cod_ramo = '007' then
				   LET v_desc_ramo = 'Vida Indindividual';
				end if

				if v_cod_ramo = '012' then
				   LET v_desc_ramo = 'Colectivo de Vida';
				end if

				if v_cod_ramo = '011' then
				   LET v_desc_ramo = 'Inundación';
				end if

				if _porc_cont_partic = 100 and v_cod_ramo not in ("006","007","008","012") then 
					let v_cobertura = "3";
				end if

				select nombre
				  into v_desc_contrato
				  from emicoase
				 where cod_coasegur = _cod_coasegur;

				if _prima_sus_tot = 0 then
					continue foreach;
				end if

		         RETURN _cod_coasegur,	  --01
				        v_cod_ramo,		  --02
						v_cod_contrato,	  --03
						v_cobertura,	  --04
						v_prima, 		  --05
						_comision, 		  --06
						_impuesto, 		  --07
						_por_pagar,		  --08
						_siniestro,		  --09
						_prima_tot_ret,	  --10
						_prima_sus_tot,	  --11
						_porc_cont_partic,--12
						v_desc_ramo,	  --13
						v_desc_contrato,  --14
						v_descr_cia,	  --15
						v_filtros         --16 filtros
		                WITH RESUME;
	END FOREACH

else
	  if _tipo = "E" then --Excluir serie

		FOREACH
	     SELECT cod_coasegur,
				cod_clase,
				cod_contrato,
				cod_cobertura,
				p_partic,
				sum(prima),
				sum(comision),
				sum(impuesto),
				sum(prima_neta),
				sum(siniestro),
				sum(resultado),
				sum(participar)			
	       INTO _cod_coasegur,
		        v_cod_ramo,
				v_cod_contrato,
				v_cobertura,
				_porc_cont_partic,
				v_prima, 
				_comision, 
				_impuesto, 
				_por_pagar,
				_siniestro,
				_prima_tot_ret,
				_prima_sus_tot			
	       FROM reacoest	
		  where anio      = _anio_reas
			and trimestre = _trim_reas
			and borderaux in(_borderaux)
			and cod_contrato not in (select codigo from tmp_codigos) 
		  group by cod_coasegur,cod_clase,cod_contrato,cod_cobertura,p_partic

	-- Clasificasion - 1-R.C.G.(006), 2-Incendio (001,003)70%,3-Terremoto(001,003)30%,4-Ramos Tecnicos(010,011,014),
	--    5-Fianzas(008,080),6-Acc. Personales(004),7-Vida Ind/Col(016,019)]
	--    modifico: 14/05/2010 solicitado: Omar Wong - Para dividir 7-Vida Individual 8-Colectivo de Vida

				SELECT rearamo.nombre
				  INTO v_desc_ramo
				  FROM rearamo  
				 WHERE rearamo.ramo_reas = v_cod_ramo;

				if v_cod_ramo = '002' then
				   LET v_desc_ramo = 'Automovil';
				end if

				if v_cod_ramo = '001' then
				   LET v_desc_ramo = 'R.C.G.' ;
				end if

				if v_cod_ramo = '002' then
				   LET v_desc_ramo = 'Incendio' ;
				end if

				if v_cod_ramo = '003' then
				   LET v_desc_ramo = 'Terremoto' ;
				end if

				if v_cod_ramo = '004' then
				   LET v_desc_ramo = 'Ramos Tecnicos' ;
				end if

				if v_cod_ramo = '005' then
				   LET v_desc_ramo = 'Fianzas' ;
				end if

				if v_cod_ramo = '006' then
				   LET v_desc_ramo = 'Acc. Personales' ;
				end if

				if v_cod_ramo = '007' then
				   LET v_desc_ramo = 'Vida Individual';
				end if

			   	if v_cod_ramo = '012' then
				   LET v_desc_ramo = 'Colectivo de Vida' ;
				end if

				if v_cod_ramo = '011' then
				   LET v_desc_ramo = 'Inundación';
				end if

				if _porc_cont_partic = 100 and v_cod_ramo not in ("006","007","008","012") then 
					let v_cobertura = "3";
				end if

				select nombre
				  into v_desc_contrato
				  from emicoase
				 where cod_coasegur = _cod_coasegur;

				if _prima_sus_tot = 0 then
					continue foreach;
				end if

		         RETURN _cod_coasegur,	  --01
				        v_cod_ramo,		  --02
						v_cod_contrato,	  --03
						v_cobertura,	  --04
						v_prima, 		  --05
						_comision, 		  --06
						_impuesto, 		  --07
						_por_pagar,		  --08
						_siniestro,		  --09
						_prima_tot_ret,	  --10
						_prima_sus_tot,	  --11
						_porc_cont_partic,--12
						v_desc_ramo,	  --13
						v_desc_contrato,  --14
						v_descr_cia,	  --15
						v_filtros         --16 filtros
		                WITH RESUME;

		END FOREACH

	  else

		FOREACH
	     SELECT cod_coasegur,
				cod_clase,
				cod_contrato,
				cod_cobertura,
				p_partic,
				sum(prima),
				sum(comision),
				sum(impuesto),
				sum(prima_neta),
				sum(siniestro),
				sum(resultado),
				sum(participar)			
	       INTO _cod_coasegur,
		        v_cod_ramo,
				v_cod_contrato,
				v_cobertura,
				_porc_cont_partic,
				v_prima, 
				_comision, 
				_impuesto, 
				_por_pagar,
				_siniestro,
				_prima_tot_ret,
				_prima_sus_tot			
	       FROM reacoest	
		  where anio      = _anio_reas
			and trimestre = _trim_reas
			and borderaux in(_borderaux)
			and cod_contrato in (select codigo from tmp_codigos) 
		  group by cod_coasegur,cod_clase,cod_contrato,cod_cobertura,p_partic

	-- Clasificasion - 1-R.C.G.(006), 2-Incendio (001,003)70%,3-Terremoto(001,003)30%,4-Ramos Tecnicos(010,011,014),
	--    5-Fianzas(008,080),6-Acc. Personales(004),7-Vida Ind/Col(016,019)]
	--    modifico: 14/05/2010 solicitado: Omar Wong - Para dividir 7-Vida Individual 8-Colectivo de Vida

				SELECT rearamo.nombre
				  INTO v_desc_ramo
				  FROM rearamo  
				 WHERE rearamo.ramo_reas = v_cod_ramo;


				if v_cod_ramo = '002' then
				   LET v_desc_ramo = 'Automovil';
				end if

				if v_cod_ramo = '001' then
				   LET v_desc_ramo = 'R.C.G.' ;
				end if

				if v_cod_ramo = '002' then
				   LET v_desc_ramo = 'Incendio' ;
				end if

				if v_cod_ramo = '003' then
				   LET v_desc_ramo = 'Terremoto' ;
				end if

				if v_cod_ramo = '004' then
				   LET v_desc_ramo = 'Ramos Tecnicos' ;
				end if

				if v_cod_ramo = '005' then
				   LET v_desc_ramo = 'Fianzas' ;
				end if

				if v_cod_ramo = '006' then
				   LET v_desc_ramo = 'Acc. Personales' ;
				end if

				if v_cod_ramo = '007' then
				   LET v_desc_ramo = 'Vida Individual';
				end if

			   	if v_cod_ramo = '012' then
				   LET v_desc_ramo = 'Colectivo de Vida' ;
				end if

				if v_cod_ramo = '011' then
				   LET v_desc_ramo = 'Inundación';
				end if

				if _porc_cont_partic = 100 and v_cod_ramo not in ("006","007","008","012") then
					let v_cobertura = "3";
				end if

				select nombre
				  into v_desc_contrato
				  from emicoase
				 where cod_coasegur = _cod_coasegur;

				if _prima_sus_tot = 0 then
					continue foreach;
				end if

				if v_cod_ramo = '011' then
				   let v_cod_ramo = '003';
				end if

		         RETURN _cod_coasegur,	  --01
				        v_cod_ramo,		  --02
						v_cod_contrato,	  --03
						v_cobertura,	  --04
						v_prima, 		  --05
						_comision, 		  --06
						_impuesto, 		  --07
						_por_pagar,		  --08
						_siniestro,		  --09
						_prima_tot_ret,	  --10
						_prima_sus_tot,	  --11
						_porc_cont_partic,--12
						v_desc_ramo,	  --13
						v_desc_contrato,  --14 reaseguradora
						v_descr_cia,	  --15
						v_filtros         --16 filtros
		                WITH RESUME;

		END FOREACH

	  end if

	DROP TABLE tmp_codigos;
end if

DROP TABLE temp_produccion;
DROP TABLE temp_det;
DROP TABLE tmp_priret;
DROP TABLE tmp_sinis;
DROP TABLE temp_devpri;

END

END PROCEDURE 