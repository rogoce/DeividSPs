--------------------------------------------
-- 	CONTABLE DE detalle de PRIMA SUSCRITA - PRODUCCION
--------------------------------------------
DROP PROCEDURE sp_rea029;
CREATE PROCEDURE sp_rea029(a_compania CHAR(03),a_agencia CHAR(03),a_periodo1 CHAR(07),a_periodo2 CHAR(07),a_codsucursal CHAR(255) DEFAULT "*",a_codgrupo CHAR(255) DEFAULT "*",a_codagente CHAR(255) DEFAULT "*",a_codusuario CHAR(255) DEFAULT "*",a_codramo CHAR(255) DEFAULT "*",a_reaseguro CHAR(255) DEFAULT "*",a_contrato CHAR(255) DEFAULT "*",a_serie CHAR(255) DEFAULT "*",a_subramo CHAR(255) DEFAULT "*"	)
RETURNING CHAR(25),	 -- Cuenta
		  CHAR(50),	 -- Nombre Cuenta
		  DEC(16,2), -- Debito
		  DEC(16,2), -- Credito
		  CHAR(50),	 -- Compania
		  smallint,  -- Nivel
		  CHAR(5),	 -- Auxiliar
		  DEC(16,2), -- Db_aux
		  DEC(16,2), -- Cr_aux
		  CHAR(50),	 -- name_reas
		  CHAR(10),	 -- name_reas
		  char(50),
		  char(255);

   BEGIN
		DEFINE v_nopoliza                      CHAR(10);
		DEFINE v_noendoso,v_cod_contrato       CHAR(5);
		DEFINE v_cod_ramo,v_cobertura          CHAR(03);
		DEFINE v_desc_ramo, v_desc_contrato    CHAR(50);
		DEFINE v_desc_cobertura	             CHAR(100);
		DEFINE v_filtros,v_filtros1,v_filtros2 CHAR(255);
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
		define _vigencia_ini					 date;
		define _vigencia_fin					 date;
		define _porc_partic_prima				 dec(9,6);
		define _p_sus_tot						 DEC(16,2);
		define _p_sus_tot_sum					 DEC(16,2);
		define v_prima_tipo					 DEC(16,2);
		define v_prima_1 						 DEC(16,2);
		define v_prima_3 						 DEC(16,2);
		define v_prima_bq						 DEC(16,2);
		define v_prima_Ot						 DEC(16,2);
		define _bouquet						 smallint;
		DEFINE v_rango_inicial	             DEC(16,2);
		DEFINE v_rango_final	                 DEC(16,2);
		DEFINE v_suma_asegurada 				 DECIMAL(16,2);
		DEFINE v_cod_tipo						 CHAR(3);
		DEFINE v_porcentaje					 smallint;
		DEFINE _t_ramo						 CHAR(1);
		DEFINE _flag , _cnt					 smallint;
		define _sum_fac_car 				     dec(16,2);
		define _no_documento					 char(20);
		DEFINE v_no_recibo                     CHAR(10);
		define _no_registro					 char(10);
		define _sac_notrx                      integer;
		define _res_comprobante				 char(15);
		define _n_contrato                     varchar(50);

		DEFINE i_cuenta			char(12);
		DEFINE i_comprobante	CHAR(15);
		DEFINE i_fechatrx		DATE;
		DEFINE i_no_registro    char(10);
		DEFINE i_notrx			INTEGER;
		DEFINE i_auxiliar		CHAR(5);
		DEFINE i_debito			DEC(15,2);
		DEFINE i_credito		DEC(15,2);
		DEFINE i_origen			CHAR(15);
		DEFINE i_no_documento	CHAR(20);
		DEFINE i_no_poliza		CHAR(10);
		DEFINE i_no_endoso		CHAR(5);
		DEFINE i_no_remesa		CHAR(10);
		DEFINE i_renglon		smallint;
		DEFINE i_no_tranrec		CHAR(10);
		DEFINE i_mostrar        CHAR(10);
		DEFINE i_tipo           CHAR(15);
		DEFINE i_no_factura     CHAR(10);

		DEFINE i_neto           DEC(15,2);
		DEFINE d_factura		CHAR(10);
		DEFINE d_poliza			CHAR(10);
		DEFINE d_endoso			CHAR(5);
		DEFINE d_debito			DEC(15,2);
		DEFINE d_credito		DEC(15,2);
		DEFINE d_renglon		smallint;
		DEFINE v_tipo_mov		CHAR(3);
		DEFINE v_nombre 		CHAR(50);
		DEFINE v_prima_bruta	DEC(16,2);
		DEFINE v_prima_neta		DEC(16,2);
		DEFINE v_impuesto		DEC(16,2);	   		   
		DEFINE v_documento		CHAR(20);
		define _cia_nom		    char(50);

		DEFINE v_nombre_cuenta   CHAR(50);
		DEFINE _no_poliza		 CHAR(10);
		DEFINE _no_endoso		 CHAR(5);
		define _error			integer;
		define _error_desc		char(50);

		define r_cod_auxiliar   char(5);
		define r_debito         DEC(16,2);
		define r_credito		DEC(16,2);
		define r_desc_rea		char(50);
		define _no_factura      char(10);
		define _no_remesa       char(10);
		define _auxiliar_nom    char(50);
		--define r_desc_rea     char(50);

	  	  	  	
     SET ISOLATION TO DIRTY READ;
     LET v_descr_cia = sp_sis01(a_compania);

	 CALL sp_pro34(a_compania,a_agencia,a_periodo1,a_periodo2,a_codsucursal,a_codgrupo,
		               a_codagente,a_codusuario,a_codramo,a_reaseguro) RETURNING v_filtros;


   {	CREATE TEMP TABLE tmp_ramos
	           (cod_ramo         CHAR(3),
			    cod_sub_tipo     CHAR(3),
				porcentaje       SMALLINT default 100,
            PRIMARY KEY(cod_ramo, cod_sub_tipo)) WITH NO LOG; }			
			    							    

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
				serie 			 SMALLINT,
				seleccionado     SMALLINT DEFAULT 1,
				no_poliza		 CHAR(10),
				cod_coasegur 	 CHAR(3),
				no_recibo        CHAR(10),
            PRIMARY KEY(cod_ramo, cod_subramo, cod_origen, cod_contrato, cod_cobertura, desc_cob, no_poliza)) WITH NO LOG;

CREATE INDEX idx1_temp_produccion ON temp_produccion(cod_ramo);
CREATE INDEX idx2_temp_produccion ON temp_produccion(cod_subramo);
CREATE INDEX idx3_temp_produccion ON temp_produccion(cod_origen);
CREATE INDEX idx4_temp_produccion ON temp_produccion(cod_contrato);
CREATE INDEX idx5_temp_produccion ON temp_produccion(cod_cobertura);
CREATE INDEX idx6_temp_produccion ON temp_produccion(desc_cob);
CREATE INDEX idx7_temp_produccion ON temp_produccion(no_poliza);
CREATE INDEX idx8_temp_produccion ON temp_produccion(serie);
CREATE INDEX idx9_temp_produccion ON temp_produccion(cod_coasegur);

CREATE TEMP TABLE tmp_aux213c(
		res1_notrx		  integer,	
		res1_linea	      integer,		  
		res1_cuenta       char(12),	 	
		res1_auxiliar     char(5),	 		
		res1_debito       decimal(15,2),	
		res1_credito      decimal(15,2),	
		res1_noregistro   integer, 
		res1_comprobante  char(15),
		res1_remesa       char(10),
		res1_desc_rea     char(50), 
		res1_no_documento char(20),
		res1_no_poliza    char(10),
		PRIMARY KEY(res1_notrx,res1_noregistro,res1_linea,res1_cuenta,res1_auxiliar,res1_remesa)) WITH NO LOG;

CREATE INDEX idx1_tmp_aux213c ON tmp_aux213c(res1_notrx);
CREATE INDEX idx2_tmp_aux213c ON tmp_aux213c(res1_noregistro);
CREATE INDEX idx3_tmp_aux213c ON tmp_aux213c(res1_linea);
CREATE INDEX idx4_tmp_aux213c ON tmp_aux213c(res1_cuenta);
CREATE INDEX idx5_tmp_aux213c ON tmp_aux213c(res1_auxiliar);
CREATE INDEX idx6_tmp_aux213c ON tmp_aux213c(res1_remesa);
CREATE INDEX idx7_tmp_aux213c ON tmp_aux213c(res1_no_documento);
CREATE INDEX idx8_tmp_aux213c ON tmp_aux213c(res1_no_poliza);

CREATE TEMP TABLE tmp_sac213c(
		cuenta			char(12),
		comprobante		char(15),
		fechatrx		date,
		no_registro		CHAR(10),
		auxiliar     	char(5),
		debito			DEC(15,2)   default 0,
		credito			DEC(15,2)   default 0,
		origen          char(15),
		no_documento	char(20),
		no_poliza       char(10),
		no_endoso       char(5),
		no_remesa		char(10),
		renglon			smallint,
		no_tranrec		char(10),
		notrx           integer,
		mostrar			char(10),
		tipo            char(15),
		no_factura      char(10),
		auxiliar_nom	char(50)
		) WITH NO LOG; 	

      LET v_prima         = 0;
	  let _cod_subramo    = "001";
	  let _prima_tot_ret  = 0;
	  let _prima_sus_tot  = 0;
	  let _p_sus_tot      = 0;
	  let _p_sus_tot_sum  = 0;
	  let _tipo_cont      = 0;
	  LET v_filtros1      = "";
	  LET v_filtros2      = "";
	  let _porc_comis_ase = 0;
	  LET _sum_fac_car    = 0;
	  LET v_no_recibo     = "";
	  let _sac_notrx      = 0;
	  let _n_contrato     = NULL;


IF a_subramo <> "*" THEN
	LET v_filtros2 = TRIM(v_filtros2) ||" Sub Ramo "||TRIM(a_subramo);
	LET _tipo = sp_sis04(a_subramo); -- Separa los valores del String

	IF _tipo <> "E" THEN -- Incluir los Registros
		UPDATE temp_det
		       SET seleccionado = 0
		     WHERE seleccionado = 1
		       AND cod_subramo NOT IN(SELECT codigo FROM tmp_codigos);
	ELSE
		UPDATE temp_det
		       SET seleccionado = 0
		     WHERE seleccionado = 1
		       AND cod_subramo IN(SELECT codigo FROM tmp_codigos);
		END IF
	DROP TABLE tmp_codigos;
END IF

--set debug file to "sp_rea029.trc";
--trace on;

FOREACH
	     select z.no_poliza,
				z.no_endoso,
		        z.prima_neta,	   -- sum(z.prima_neta),
				z.vigencia_inic,   -- min(z.vigencia_inic)
				z.no_factura
           into v_nopoliza,
	     		v_noendoso,
		        v_prima_cobrada,
				_fecha,
				v_no_recibo
           from temp_det z
          where z.seleccionado = 1
--		  group by 1,2

		 select cod_ramo,
		 	    cod_origen
		   into v_cod_ramo,
		   	    _cod_origen
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
				    { RETURN "",
				     		'01/01/1900',
							'01/01/1900',
							0.00,
				     		"",  
							"Error de Data",  
							0, 
				     		0,  
				     		0,  
				     		0,  
				     		0,  
				     		0, 
				     		v_filtros, 
				     		v_descr_cia,
							0,
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

				let _tipo_cont = 0;

	            IF v_tipo_contrato = 3 THEN

					let _tipo_cont = 2;

	            elif v_tipo_contrato = 1 then --retencion

				   let v_prima1 = v_prima_cobrada * _porc_partic_prima / 100;

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
					     and no_poliza     = v_nopoliza;

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
										_serie,
					                    1,
					                    v_nopoliza,
					                    '999',
					                    v_no_recibo);
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
				 			  from temp_produccion
				 			 where cod_ramo      = v_cod_ramo
				 			   and cod_subramo   = _cod_subramo
				 			   and cod_origen    = _cod_origen
				               and cod_contrato  = v_cod_contrato
				               and cod_cobertura = v_cobertura
				               and desc_cob      = v_desc_cobertura
						       and no_poliza     = v_nopoliza;

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
										     _serie,
					                         1,
					                         v_nopoliza,
					                         _cod_coasegur,
					                         v_no_recibo);
				 			else
				 			   
				                UPDATE temp_produccion
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
				                   and no_poliza     = v_nopoliza;

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
				 		  from temp_produccion
				 		 where cod_ramo      = v_cod_ramo
				 		   and cod_subramo   = _cod_subramo
				 		   and cod_origen    = _cod_origen
			               and cod_contrato  = v_cod_contrato
			               and cod_cobertura = v_cobertura
			               and desc_cob      = v_desc_cobertura
					       and no_poliza     = v_nopoliza;


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
										  _serie,
					                      1,
					                      v_nopoliza,
					                      _cod_coasegur,
					                      v_no_recibo);
				 		else
				 		   
				               UPDATE temp_produccion
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
					              and no_poliza     = v_nopoliza;

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
							 	  from temp_produccion
							 	 where cod_ramo      = v_cod_ramo
							 	   and cod_subramo   = _cod_subramo
							 	   and cod_origen    = _cod_origen
							           and cod_contrato  = v_cod_contrato
							           and cod_cobertura = v_cobertura
							           and desc_cob      = _nombre_cob
								       and no_poliza     = v_nopoliza;

							   	if _cantidad = 0 then

							 		INSERT INTO temp_produccion
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
					                    			v_nopoliza,
					                    			'999',
					                    			v_no_recibo);
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
							 		  from temp_produccion
							 		 where cod_ramo      = v_cod_ramo
							 		   and cod_subramo   = _cod_subramo
							 		   and cod_origen    = _cod_origen
							           and cod_contrato  = v_cod_contrato
							           and cod_cobertura = v_cobertura
							           and desc_cob      = v_desc_cobertura
								       and no_poliza     = v_nopoliza;

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
													  _serie,
								                      1,
								                      v_nopoliza,
								                      _cod_coasegur,
								                      v_no_recibo);
							 		else

							               UPDATE temp_produccion
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
										      and no_poliza     = v_nopoliza;

							 		end if

						        end foreach

						  end if	

				  end if

         END FOREACH

END FOREACH
--trace off;

  let _prima_tot_ret_sum = 0;
  let _prima_tot_sus_sum = 0;
  let _p_sus_tot_sum     = 0;

-- Adicionar filtro contrato y serie
-- Filtro por Contrato

IF a_contrato <> "*" THEN
	LET v_filtros1 = TRIM(v_filtros1) ||" Contrato "||TRIM(a_contrato);
	LET _tipo = sp_sis04(a_contrato); -- Separa los valores del String

	IF _tipo <> "E" THEN -- Incluir los Registros
		UPDATE temp_produccion
		       SET seleccionado = 0
		     WHERE seleccionado = 1
		       AND cod_contrato NOT IN(SELECT codigo FROM tmp_codigos);
	ELSE
		UPDATE temp_produccion
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
		UPDATE temp_produccion
		       SET seleccionado = 0
		     WHERE seleccionado = 1
		       AND serie NOT IN(SELECT codigo FROM tmp_codigos);
	ELSE
		UPDATE temp_produccion
		       SET seleccionado = 0
		     WHERE seleccionado = 1
		       AND serie IN(SELECT codigo FROM tmp_codigos);
		END IF
	DROP TABLE tmp_codigos;
END IF
LET v_filtros = TRIM(v_filtros1)||" "|| TRIM(v_filtros)||" "|| TRIM(v_filtros2);

let v_nombre = " ";
let i_comprobante = " ";

select cia_nom
  into _cia_nom
  from sigman02
 where cia_bda_codigo = "sac";

select *
  from sac:cglconcepto
  into temp tmp_cglconcepto;

select *
  from sac:cglcuentas 
  into temp tmp_cglcuentas;	

select *
  from sac:cglterceros 
  into temp tmp_cglterceros;	

{SELECT ter_descripcion 
  INTO _auxiliar_nom 
  FROM sac:cglterceros
 WHERE ter_codigo = "BQ";	}
let _auxiliar_nom = "";


{FOREACH
	select f.no_poliza,f.no_endoso,r.no_factura
	 into  i_no_poliza,i_no_endoso,i_no_factura
	 from  deivid:temp_produccion f
	where f.seleccionado = 1 }

FOREACH
 SELECT t.no_poliza,
        t.no_endoso,
		f.no_factura
   INTO i_no_poliza,
        i_no_endoso,
		i_no_factura
   FROM endedmae f,temp_det t
  WHERE f.no_poliza  = t.no_poliza
    AND f.no_endoso  = t.no_endoso
    AND f.actualizado = 1
	and t.seleccionado = 1


		FOREACH	
				select b.cuenta,
				c.fecha,
				b.no_registro,
				b.debito,
				b.credito,
				decode(c.tipo_registro,"1","PRODUCCION","2","COBROS","3","RECLAMOS"),
				c.no_documento,
				c.no_poliza,
				c.no_endoso,
				c.no_remesa,
				c.renglon,
				c.no_tranrec,
				b.sac_notrx
				into i_cuenta,
					 i_fechatrx,
					 i_no_registro,
					 i_debito,
					 i_credito,
					 i_origen,
					 i_no_documento,
					 i_no_poliza,
					 i_no_endoso,
					 i_no_remesa,
					 i_renglon,
					 i_no_tranrec,
					 i_notrx
				from sac999:reacompasie b, sac999:reacomp c
					where b.no_registro = c.no_registro
					and c.tipo_registro = "1"
					and c.no_poliza = i_no_poliza
				    and c.no_endoso = i_no_endoso

					LET i_mostrar = "";

					LET i_mostrar = "";
					if trim(i_origen) =  "PRODUCCION"  then
						LET i_tipo = 'No. Factura';
						LET i_mostrar = i_no_factura;
				    end if

					LET i_auxiliar = '';
					let i_renglon = 0;

					INSERT INTO tmp_sac213c (
					cuenta,
					comprobante,
					fechatrx,
					no_registro,
					auxiliar,
					debito,
					credito,
					origen,
					no_documento,
					no_poliza,
					no_endoso,
					no_remesa,
					renglon,
					no_tranrec,
					notrx,
					mostrar,
					tipo,
					no_factura,
					auxiliar_nom
					 )
					VALUES (
					i_cuenta,
					i_comprobante,		
					i_fechatrx,
					i_no_registro,
					i_auxiliar,
					i_debito,
					i_credito,
					i_origen,
					i_no_documento,
					i_no_poliza,
					i_no_endoso,
					i_no_factura,
					i_renglon,
					i_no_tranrec,
					i_notrx,
					i_mostrar,
					i_tipo,
					i_no_factura,
					_auxiliar_nom
					);

				   	FOREACH
						select a.cod_auxiliar,
						      t.ter_descripcion,
						      sum(a.debito),
						      sum(a.credito)
						 into r_cod_auxiliar,
							  r_desc_rea,
							  r_debito,
							  r_credito	
						 from sac999:reacompasiau a ,tmp_cglterceros t	 
						where a.no_registro  = i_no_registro
						  and a.cod_auxiliar = t.ter_codigo
						  and a.cuenta       = i_cuenta 
						group by 1,2
						order by 1,2

							if i_renglon is null then
							   let i_renglon = 0;
							end if


					   	BEGIN
						ON EXCEPTION IN(-239)
						  UPDATE tmp_aux213c
						     SET res1_debito    = res1_debito + r_debito, 
							     res1_credito   = res1_credito + r_credito
						   WHERE res1_notrx     = i_notrx
							 AND res1_cuenta    = i_cuenta 
							 AND res1_auxiliar	= r_cod_auxiliar
							 AND res1_remesa    = i_no_factura; 
						END EXCEPTION 	


							INSERT INTO tmp_aux213c(
							res1_notrx,
							res1_linea,	    
							res1_cuenta,    
							res1_auxiliar,   
							res1_debito,     
							res1_credito,    
							res1_noregistro, 
							res1_comprobante,
							res1_remesa,
							res1_desc_rea,
							res1_no_documento, 
							res1_no_poliza    
							)																	
							VALUES(	
							i_notrx, 
							i_renglon, 
							i_cuenta, 
							r_cod_auxiliar, 
							r_debito, 
							r_credito,    
							i_no_registro, 
							i_comprobante,
							i_no_factura,
							r_desc_rea,
							i_no_documento,
							i_no_poliza										
							 );  
					   END 
					END FOREACH	 							   
		END FOREACH
END FOREACH

let _auxiliar_nom = "";

FOREACH
 SELECT no_factura,
        auxiliar_nom,
        cuenta, 
        SUM(debito), 
        SUM(credito)
   INTO _no_factura,
        _auxiliar_nom,
        i_cuenta, 
        i_debito, 
        i_credito
   FROM tmp_sac213c
  GROUP BY 1,2,3
  ORDER BY 1,2,3

		if i_debito is null then
			let i_debito = 0; 
		end if
		if i_credito is null then
			let i_credito = 0; 
		end if

		{if _error <> 0 then
		 let v_nombre_cuenta = "";
		else}
			 SELECT cta_nombre
			   INTO v_nombre_cuenta
			   FROM tmp_cglcuentas
			  WHERE cta_cuenta = i_cuenta ;
		--end if
		LET r_cod_auxiliar = '';
		LET r_debito = 0;
		LET r_credito = 0;
		LET r_desc_rea = '';

	RETURN i_cuenta,			
		   v_nombre_cuenta,  
		   i_debito,         
		   i_credito,        
		   _cia_nom,
		   1, 
		   r_cod_auxiliar,
		   r_debito,
		   r_credito,
		   r_desc_rea,
		   _no_factura,
		   _auxiliar_nom,
		   v_filtros
		   WITH RESUME;	 		

		FOREACH
		   select a.res1_auxiliar,
			      t.ter_descripcion,
			      sum(a.res1_debito),
			      sum(a.res1_credito)
			 into r_cod_auxiliar,
				  r_desc_rea,
				  r_debito,
				  r_credito
			 from tmp_aux213c a ,tmp_cglterceros t	 	 
			where a.res1_cuenta = i_cuenta 
			  and a.res1_auxiliar = t.ter_codigo
			  and a.res1_remesa = _no_factura
		    group by 1,2
			order by 1,2

			if r_debito is null then
				let r_debito = 0; 
			end if

			if r_credito is null then
				let r_credito = 0; 
			end if

			if r_debito = 0 and r_credito = 0 then
				continue foreach;
			end if

			RETURN i_cuenta,
				   v_nombre_cuenta,
				   0,
				   0,
				   _cia_nom,
				   2,
				   r_cod_auxiliar,
				   r_debito,
				   r_credito,
				   r_desc_rea,
				   _no_factura,
				   _auxiliar_nom,
				   v_filtros
				   WITH RESUME;	 		

		 END FOREACH;

END FOREACH;


DROP TABLE temp_produccion;
DROP TABLE temp_det;
DROP TABLE tmp_sac213c;
DROP TABLE tmp_aux213c;
DROP TABLE tmp_cglcuentas;
DROP TABLE tmp_cglterceros;
DROP TABLE tmp_cglconcepto;


END

END PROCEDURE


		  