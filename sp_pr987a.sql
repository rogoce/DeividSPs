--------------------------------------------
--      TOTALES DE PRODUCCION POR         --
--         CONTRATO DE REASEGURO          --
---  Yinia M. Zamora - octubre 2000 - YMZM
---  Ref. Power Builder - reemplaza sp_pro308
--- Modificado por Armando Moreno 19/01/2002; la parte de los tipo de contratos
--- Modificado por Henry 10/9/2009 filtros requeridos por Sr. Omar Wong
--- Solo Excedente Facilidad CAR
--------------------------------------------
DROP PROCEDURE sp_pr987a;

CREATE PROCEDURE sp_pr987a(
		a_compania    CHAR(03),
		a_agencia     CHAR(03),
		a_periodo1    CHAR(07),
		a_periodo2    CHAR(07),
		a_codsucursal CHAR(255) DEFAULT "*",
		a_codgrupo    CHAR(255) DEFAULT "*",
		a_codagente   CHAR(255) DEFAULT "*",
		a_codusuario  CHAR(255) DEFAULT "*",
		a_codramo     CHAR(255) DEFAULT "*",
		a_reaseguro   CHAR(255) DEFAULT "*",
		a_contrato    CHAR(255) DEFAULT "*",
		a_serie       CHAR(255) DEFAULT "*"
		)
RETURNING CHAR(03),CHAR(50),CHAR(50),CHAR(100),DECIMAL(16,2),CHAR(50),CHAR(255),dec(16,2),dec(16,2),dec(16,2),dec(16,2),dec(16,2),dec(16,2),dec(16,2),dec(16,2),dec(16,2),smallint,CHAR(5),smallint,CHAR(10),CHAR(20),CHAR(50),CHAR(50);

   BEGIN
      DEFINE v_nopoliza                      CHAR(10);
      DEFINE v_noendoso,v_cod_contrato       CHAR(5);
      DEFINE v_cod_ramo,v_cobertura          CHAR(03);
      DEFINE v_desc_ramo, v_desc_contrato    CHAR(50);
      DEFINE v_desc_cobertura	             CHAR(100);
      DEFINE v_filtros,v_filtros1            CHAR(255);
      DEFINE _tipo                           CHAR(01);
      DEFINE v_descr_cia                     CHAR(50);
      DEFINE v_prima                		 DEC(16,2);
      DEFINE v_prima1                		 DEC(16,2);
      DEFINE v_tipo_contrato                 SMALLINT;

	  define _porc_impuesto					 dec(16,2);
	  define _porc_comision					 dec(16,2);
	  define _cuenta						 char(25);
	  define _serie 						 smallint;
	  define _impuesto						 dec(16,2);
	  define _comision						 dec(16,2);
	  define _por_pagar						 dec(16,2);

	  DEFINE _cod_traspaso	 				 CHAR(5);
	  define _traspaso		 				 smallint;
	  define _tiene_comis_rea				 smallint;
	  define _cantidad						 smallint;
	  define _tipo_cont                      smallint;
	  	
	  define _porc_cont_partic 				 dec(5,2);
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
	  define _no_cambio						 smallint;
	  define _no_unidad						 char(5);
      define v_prima_cobrada           		 DEC(16,2);
	  define _porc_partic_coas				 dec(7,4);
	  define _fecha						     date;
	  define _porc_partic_prima				 dec(9,6);
	  define _p_sus_tot						 DEC(16,2);
	  define _p_sus_tot_sum					 DEC(16,2);
      DEFINE _documento                      CHAR(20);
      DEFINE _contratante                    CHAR(10);
      DEFINE _factura                        CHAR(10);
	  DEFINE v_descclte				         CHAR(50);
	  DEFINE v_descrea           			 CHAR(50);
	  define _facilidad_car					 smallint;

	  	  	  	
     SET ISOLATION TO DIRTY READ;

     LET v_descr_cia  = sp_sis01(a_compania);

     CREATE TEMP TABLE temp_sp_pr987
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
				serie 			 SMALLINT,
				seleccionado     SMALLINT DEFAULT 1,
				no_factura       CHAR(10),
				no_documento     CHAR(20),
				contratante      CHAR(10),
				cod_coasegur	 CHAR(3),
            PRIMARY KEY(cod_ramo, cod_subramo, cod_origen, cod_contrato, cod_cobertura, desc_cob, no_factura, no_documento, contratante, cod_coasegur  )) WITH NO LOG;

CREATE INDEX idx1_temp_sp_pr987 ON temp_sp_pr987(cod_ramo);
CREATE INDEX idx2_temp_sp_pr987 ON temp_sp_pr987(cod_subramo);
CREATE INDEX idx3_temp_sp_pr987 ON temp_sp_pr987(cod_origen);
CREATE INDEX idx4_temp_sp_pr987 ON temp_sp_pr987(cod_contrato);
CREATE INDEX idx5_temp_sp_pr987 ON temp_sp_pr987(cod_cobertura);
CREATE INDEX idx6_temp_sp_pr987 ON temp_sp_pr987(desc_cob);
CREATE INDEX idx7_temp_sp_pr987 ON temp_sp_pr987(serie);
CREATE INDEX idx8_temp_sp_pr987 ON temp_sp_pr987(no_factura);
CREATE INDEX idx9_temp_sp_pr987 ON temp_sp_pr987(no_documento);
CREATE INDEX idx10_temp_sp_pr987 ON temp_sp_pr987(contratante);
CREATE INDEX idx11_temp_sp_pr987 ON temp_sp_pr987(cod_coasegur);


     CREATE TEMP TABLE tmp_priret
               (cod_ramo         CHAR(3),
			    prima_sus_tot    DEC(16,2),
				prima            DEC(16,2),
				prima_sus_t      DEC(16,2)) WITH NO LOG;

      LET v_prima         = 0;
	  LET _cod_subramo    = "001";
	  LET _prima_tot_ret  = 0;
	  LET _prima_sus_tot  = 0;
	  LET _p_sus_tot      = 0;
	  LET _p_sus_tot_sum  = 0;
	  LET _tipo_cont      = 0;
	  LET v_filtros1      = "";
	  LET _tipo_cont      = 0;
	  LET v_prima_cobrada = 0;
	  LET v_descr_cia     = "";
	  LET v_filtros	      = "";
	  LET _factura        = "";
	  LET v_descclte      = "";
	  LET v_descrea       = "";
	  let _facilidad_car  = 0;

--RETURN "","No Esta en Uso este Reporte. Gracias.","","",v_prima_cobrada,v_descr_cia,v_filtros,0.00,0.00,0.00,0.00,0.00,0.00,0.00,0.00,0.00,_tipo_cont,"",1;

     CALL sp_pro307(a_compania,a_agencia,a_periodo1,a_periodo2,a_codsucursal,a_codgrupo,
                   a_codagente,a_codusuario,a_codramo,a_reaseguro) RETURNING v_filtros;

     CALL sp_pro314(a_compania,a_agencia,a_periodo1,a_periodo2,a_codsucursal,a_codgrupo,
                   a_codagente,a_codusuario,a_codramo,a_reaseguro) RETURNING v_filtros;

FOREACH
	     select z.no_poliza,
				z.no_endoso,
				z.no_factura,
		        sum(z.prima_neta),
				min(z.vigencia_inic)
           into v_nopoliza,
	     		v_noendoso,
				_factura,
		        v_prima_cobrada,
				_fecha
           from temp_det z
          where z.seleccionado = 1
--		    and no_documento = "1409-00124-01"
		  group by 1,2,3

		 select cod_ramo,
		 	    cod_origen,
                 cod_contratante,
                 no_documento
		   into v_cod_ramo,
		   	    _cod_origen,
                _contratante,
                _documento
		   from emipomae
		  where no_poliza = v_nopoliza;

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

					 continue foreach;

			    {     RETURN "",
			         		"No Existe Distribucion de Reaseguro",
			         		"",
			                "",
			                v_prima_cobrada,
			                v_descr_cia,
			                v_filtros, 
							0.00,
							0.00, 
							0.00,
							0.00,
							0.00,
							0.00,
							0.00,
							0.00,
							0.00,
							_tipo_cont,
							"",
							1,
							"",
							"",
							"",
							""
			                WITH RESUME;}

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

		 select min(cod_cober_reas)
		   into v_cobertura
		   from emireama
		  where no_poliza = v_nopoliza
		    and no_unidad = _no_unidad
		    and no_cambio = _no_cambio;

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
				   -- cambiara se le colocara un check de facilidad CAR y otro de Facilidad Incendio

                select facilidad_car
				  into _facilidad_car
				  from reacomae
				 where cod_contrato = v_cod_contrato;

				if _facilidad_car = 0 then  --No es facilidad car
					--if v_cod_contrato <>  "00614" and v_cod_contrato <>  "00584" and v_cod_contrato <>  "00574" and v_cod_contrato <>  "00604" and v_cod_contrato <>  "00594" then  -- Contrato Facicilada CaR
					CONTINUE FOREACH;
				end if

				select traspaso
				  into _traspaso
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

--				if v_tipo_contrato <> 7 then  -- SOLO EXCEDENTE
--					CONTINUE FOREACH;
--				end if


				let _tipo_cont = 0;

	            IF v_tipo_contrato = 3 THEN

					let _tipo_cont = 2;

	            elif v_tipo_contrato = 1 then --retencion

				   let v_prima1 = v_prima_cobrada * _porc_partic_prima / 100;

					update tmp_priret
					   set prima = prima + v_prima1
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
					    from temp_sp_pr987
					   where cod_ramo      = v_cod_ramo
					     and cod_subramo   = _cod_subramo
					     and cod_origen    = _cod_origen
					     and cod_contrato  = v_cod_contrato
					     and cod_cobertura = v_cobertura
					     and desc_cob      = _nombre_cob
					     and no_factura    = _factura
						 and no_documento  = _documento
						 and contratante   = _contratante
						 and cod_coasegur  = _cod_coasegur;

					 	if _cantidad = 0 then

					 		INSERT INTO temp_sp_pr987
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
										_serie,
					                    1,
					                    _factura,
					                    _documento,
					                    _contratante,
					                    _cod_coasegur );
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

				 			select count(*)
				 			  into _cantidad
				 			  from temp_sp_pr987
				 			 where cod_ramo      = v_cod_ramo
				 			   and cod_subramo   = _cod_subramo
				 			   and cod_origen    = _cod_origen
				               and cod_contrato  = v_cod_contrato
				               and cod_cobertura = v_cobertura
				               and desc_cob      = v_desc_cobertura
						       and no_factura    = _factura
							   and no_documento  = _documento
							   and contratante   = _contratante
	   						   and cod_coasegur  = _cod_coasegur;

				 			if _cantidad = 0 then

				 				INSERT INTO temp_sp_pr987
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
										     _serie,
						                     1,
						                     _factura,
						                     _documento,
						                     _contratante,
						                     _cod_coasegur );

				 			else
				 			   
				                UPDATE temp_sp_pr987
				                   SET prima         = prima + _monto_reas,
				                   	   comision      = comision  + _comision,
				 					   impuesto      = impuesto  + _impuesto,
				 					   por_pagar     = por_pagar + _por_pagar
				                 WHERE cod_ramo      = v_cod_ramo
				 				   and cod_subramo   = _cod_subramo
				 				   and cod_origen    = _cod_origen
				                   and cod_contrato  = v_cod_contrato
				                   and cod_cobertura = v_cobertura
				                   and desc_cob      = v_desc_cobertura
							       and no_factura    = _factura
								   and no_documento  = _documento
							       and contratante   = _contratante
	   						       and cod_coasegur  = _cod_coasegur;

				 			end if

				 		end foreach

				  end if

				 elif _tipo_cont = 1 then	  --Retencion

			 			let _cod_coasegur = '036'; --ancon

				 		select nombre
				 		  into _nombre_coas
				 		  from emicoase
				 		 where cod_coasegur = _cod_coasegur;

				 		-- La comision se calcula por reasegurador

				 		if _tiene_comis_rea = 2 then 
				 			let _porc_comision = _porc_comis_ase;
				 		end if

					    let _porc_impuesto = 0;
						let _porc_comision = 0;
				 		let v_desc_cobertura = "";
				 		let v_desc_cobertura = trim(_nombre_cob) || "  " || trim(_cuenta) || "  " || trim(_nombre_coas);
				 		let v_desc_contrato  = trim(v_desc_contrato) || "  I:" || _porc_impuesto || "  C:" || _porc_comision;

				 		let _monto_reas = v_prima;
				 		let _impuesto   = _monto_reas * _porc_impuesto / 100;
				 		let _comision   = _monto_reas * _porc_comision / 100;
				 		let _por_pagar  = _monto_reas - _impuesto - _comision;

				 		select count(*)
				 		  into _cantidad
				 		  from temp_sp_pr987
				 		 where cod_ramo      = v_cod_ramo
				 		   and cod_subramo   = _cod_subramo
				 		   and cod_origen    = _cod_origen
			               and cod_contrato  = v_cod_contrato
			               and cod_cobertura = v_cobertura
			               and desc_cob      = v_desc_cobertura
					       and no_factura    = _factura
						   and no_documento  = _documento
						   and contratante   = _contratante
   						   and cod_coasegur  = _cod_coasegur;

				 		if _cantidad = 0 then

				 			INSERT INTO temp_sp_pr987
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
										  _serie,
					                      1,
					                      _factura,
					                      _documento,
					                      _contratante,
					                      _cod_coasegur );

				 		else
				 		   
				               UPDATE temp_sp_pr987
				                  SET prima         = prima     + _monto_reas,
				                  	  comision      = comision  + _comision,
				 				      impuesto      = impuesto  + _impuesto,
				 				      por_pagar     = por_pagar + _por_pagar
				                WHERE cod_ramo      = v_cod_ramo
				 				  and cod_subramo    	= _cod_subramo
				 				  and cod_origen        = _cod_origen
				                  and cod_contrato  = v_cod_contrato
				                  and cod_cobertura = v_cobertura
				                  and desc_cob      = v_desc_cobertura
							      and no_factura    = _factura
								  and no_documento  = _documento
								  and contratante   = _contratante
		   						  and cod_coasegur  = _cod_coasegur;


				 		end if

				 elif _tipo_cont = 2 then  --facultativos

				  select count(*)
				    into _cantidad
				    from emifafac
				   where no_poliza      = v_nopoliza
				     and no_endoso      = v_noendoso
			         and cod_contrato   = v_cod_contrato
				     and cod_cober_reas = v_cobertura
	  		         and no_unidad      = _no_unidad;

						  if _cantidad = 0 then

						    	let v_desc_contrato  = "******* NO EXISTE REGISTRO DE COMPANIAS " || v_cod_contrato;

							 	select count(*)
							 	  into _cantidad
							 	  from temp_sp_pr987
							 	 where cod_ramo      = v_cod_ramo
							 	   and cod_subramo   = _cod_subramo
							 	   and cod_origen    = _cod_origen
							           and cod_contrato  = v_cod_contrato
							           and cod_cobertura = v_cobertura
							           and desc_cob      = _nombre_cob
								       and no_factura    = _factura
									   and no_documento  = _documento
									   and contratante   = _contratante
			   						   and cod_coasegur  = _cod_coasegur;

							   	if _cantidad = 0 then

							 		INSERT INTO temp_sp_pr987
							                  VALUES(v_cod_ramo,
							 			            _cod_subramo,
							 					    _cod_origen,
							                        v_cod_contrato,
							 					    v_desc_contrato,
							                        v_cobertura,
							                        0,
							                        _tipo_cont,
							                        0, 
							                        0, 
							                        0,
							                        _nombre_cob,
													_serie,
								                    1,
								                    _factura,
								                    _documento,
								                    _contratante,
								                    _cod_coasegur );
							 	end if

						  else

						    	foreach

							 		select porc_partic_reas,
							 			   porc_comis_fac,
							 			   porc_impuesto,
							 			   cod_coasegur
							 		  into _porc_cont_partic,
							 		   	   _porc_comis_ase,
							 			   _porc_impuesto,
							 			   _cod_coasegur
							 		  from emifafac
							 	     where no_poliza      = v_nopoliza
									   and no_endoso      = v_noendoso
							 	       and cod_contrato   = v_cod_contrato
							 	       and cod_cober_reas = v_cobertura
	  		                           and no_unidad      = _no_unidad
							 			
							 		select nombre
							 		  into _nombre_coas
							 		  from emicoase
							 		 where cod_coasegur = _cod_coasegur;

							 		let v_desc_cobertura = trim(_nombre_cob) || "  " || trim(_cuenta) || "  " || trim(_nombre_coas);
							 		let v_desc_contrato  = trim(v_desc_contrato) || "  I:" || _porc_impuesto || "  C:" || _porc_comis_ase;

							 		let _monto_reas = v_prima     * _porc_cont_partic / 100;
							 		let _impuesto   = _monto_reas * _porc_impuesto / 100;
							 		let _comision   = _monto_reas * _porc_comis_ase / 100;
							 		let _por_pagar  = _monto_reas - _impuesto - _comision;

							 		select count(*)
							 		  into _cantidad
							 		  from temp_sp_pr987
							 		 where cod_ramo      = v_cod_ramo
							 		   and cod_subramo   = _cod_subramo
							 		   and cod_origen    = _cod_origen
							           and cod_contrato  = v_cod_contrato
							           and cod_cobertura = v_cobertura
							           and desc_cob      = v_desc_cobertura
								       and no_factura    = _factura
									   and no_documento  = _documento
									   and contratante   = _contratante
			   						   and cod_coasegur  = _cod_coasegur;

							 		if _cantidad = 0 then

							 			INSERT INTO temp_sp_pr987
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
													  _serie,
								                      1,
								                      _factura,
								                      _documento,
								                      _contratante,
								                      _cod_coasegur );

							 		else

							               UPDATE temp_sp_pr987
							                  SET prima     = prima     + _monto_reas,
								 			      comision  = comision  + _comision,
								 				  impuesto  = impuesto  + _impuesto,
								 				  por_pagar = por_pagar + _por_pagar
							                WHERE cod_ramo  = v_cod_ramo
								 			  and cod_subramo	= _cod_subramo
								 			  and cod_origen    = _cod_origen
							                  and cod_contrato  = v_cod_contrato
							                  and cod_cobertura = v_cobertura
							                  and desc_cob      = v_desc_cobertura
										      and no_factura    = _factura
											  and no_documento  = _documento
											  and contratante   = _contratante
					   						  and cod_coasegur  = _cod_coasegur;


							 		end if

						        end foreach

						  end if	

				  end if

         END FOREACH

END FOREACH

  let _prima_tot_ret_sum = 0;
  let _prima_tot_sus_sum = 0;
  let _p_sus_tot_sum     = 0;

  foreach
     SELECT sum(prima),
	        cod_ramo
	   into v_prima_suscrita,
	        v_cod_ramo
       FROM temp_det1
      WHERE seleccionado = 1
	  group by 2

   	update tmp_priret
	   set prima_sus_t = v_prima_suscrita
	 where cod_ramo = v_cod_ramo;
  end foreach

-- Adicionar filtro contrato y serie
-- Filtro por Contrato

IF a_contrato <> "*" THEN
	LET v_filtros1 = TRIM(v_filtros1) ||" Contrato "||TRIM(a_contrato);
	LET _tipo = sp_sis04(a_contrato); -- Separa los valores del String

	IF _tipo <> "E" THEN -- Incluir los Registros
		UPDATE temp_sp_pr987
		       SET seleccionado = 0
		     WHERE seleccionado = 1
		       AND cod_contrato NOT IN(SELECT codigo FROM tmp_codigos);
	ELSE
		UPDATE temp_sp_pr987
		       SET seleccionado = 0
		     WHERE seleccionado = 1
		       AND cod_contrato IN(SELECT codigo FROM tmp_codigos);
		END IF
	DROP TABLE tmp_codigos;
END IF

-- Filtro por Serie

IF a_serie <> "*" THEN
	LET v_filtros1 = TRIM(v_filtros1) ||" Serie "||TRIM(a_serie);
	LET _tipo = sp_sis04(a_serie); -- Separa los valores del String

	IF _tipo <> "E" THEN -- Incluir los Registros
		UPDATE temp_sp_pr987
		       SET seleccionado = 0
		     WHERE seleccionado = 1
		       AND serie NOT IN(SELECT codigo FROM tmp_codigos);
	ELSE
		UPDATE temp_sp_pr987
		       SET seleccionado = 0
		     WHERE seleccionado = 1
		       AND serie IN(SELECT codigo FROM tmp_codigos);
		END IF
	DROP TABLE tmp_codigos;
END IF
LET v_filtros = TRIM(v_filtros1)||" "|| TRIM(v_filtros);
LET v_descclte = "";

FOREACH
     SELECT cod_ramo,
	        cod_subramo,
			cod_origen,
			cod_contrato,
     		cod_cobertura,
			tipo,
       	    desc_contrato,
			desc_cob,
			serie,
			no_factura, 
			no_documento, 
			contratante,
			cod_coasegur,
     		SUM(prima),
		    SUM(comision),
		    SUM(impuesto),
		    SUM(por_pagar)
       INTO v_cod_ramo,
	        _cod_subramo,
			_cod_origen,
	        v_cod_contrato,
       		v_cobertura,
			_tipo_cont,
			_nombre_con,
		    v_desc_cobertura,
			_serie,
			_factura, 
			_documento, 
			_contratante,
			_cod_coasegur,
           	v_prima,
			_comision,
			_impuesto, 
			_por_pagar
         FROM temp_sp_pr987
	   where seleccionado = 1
     GROUP BY cod_ramo, cod_subramo, cod_origen, cod_contrato, desc_contrato, cod_cobertura, tipo, desc_cob, serie, no_factura, no_documento, contratante, cod_coasegur
     ORDER BY cod_ramo, cod_subramo, cod_origen, cod_contrato, desc_contrato, cod_cobertura, tipo, desc_cob, serie, no_factura, no_documento, contratante, cod_coasegur

     SELECT sum(prima),
	        sum(prima_sus_tot),
			sum(prima_sus_t)
       INTO _prima_tot_ret,
			_prima_sus_tot,
			_p_sus_tot
       FROM tmp_priret
	  where cod_ramo = v_cod_ramo;

     SELECT sum(prima),
	        sum(prima_sus_tot),
			sum(prima_sus_t)
       INTO _prima_tot_ret_sum,
		    _prima_tot_sus_sum,
			_p_sus_tot_sum
       FROM tmp_priret;

	 SELECT nombre
	   INTO v_desc_ramo
	   FROM prdramo
	  WHERE cod_ramo = v_cod_ramo;

	 SELECT cliclien.nombre
	   INTO v_descclte
	   FROM cliclien
	  WHERE cliclien.cod_cliente = _contratante;

     SELECT emicoase.nombre
       INTO v_descrea
       FROM emicoase
      WHERE emicoase.cod_coasegur = _cod_coasegur;

	         RETURN v_cod_ramo,
	         		v_desc_ramo,
	         		_nombre_con,
	                v_desc_cobertura,
	                v_prima,
	                v_descr_cia,
	                v_filtros, 
					_comision,
					_impuesto, 
					_por_pagar,
					_prima_tot_ret,
					_prima_sus_tot,
					_prima_tot_ret_sum,
					_prima_tot_sus_sum,
					_p_sus_tot,
					_p_sus_tot_sum,
					_tipo_cont,
				    v_cod_contrato,
				    _serie,
					_factura, 
					_documento, 
					v_descclte,
					v_descrea
	               WITH RESUME;
END FOREACH

--DROP TABLE temp_sp_pr987;
--DROP TABLE temp_det;
--DROP TABLE temp_det1;
DROP TABLE tmp_priret;

END

END PROCEDURE




	  
	  
	  
	  
	  
	  
	  