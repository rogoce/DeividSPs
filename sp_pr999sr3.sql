--------------------------------------------
--      TOTALES DE PRODUCCION POR         --
--         CONTRATO DE REASEGURO          --
---  Yinia M. Zamora - octubre 2000       -- YMZM
---  Ref. Power Builder - reemplaza sp_pro308
--- Modificado por Armando Moreno 19/01/2002; la parte de los tipo de contratos
--- Modificado por Henry 10/9/2009 filtros requeridos por Sr. Omar Wong
--- Quitar el filtro de rangos.
--------------------------------------------
--execute procedure sp_pr999sr('001','001','2013-07','2013-09',"*","*","*","*","002;","*","*","2013;","*")

DROP PROCEDURE sp_pr999sr3;
CREATE PROCEDURE sp_pr999sr3(a_compania CHAR(03),a_agencia CHAR(03),a_periodo1 CHAR(07),a_periodo2 CHAR(07),a_codsucursal CHAR(255) DEFAULT "*",a_codgrupo CHAR(255) DEFAULT "*",a_codagente CHAR(255) DEFAULT "*",a_codusuario CHAR(255) DEFAULT "*",a_codramo CHAR(255) DEFAULT "*",a_reaseguro CHAR(255) DEFAULT "*",a_contrato CHAR(255) DEFAULT "*",a_serie CHAR(255) DEFAULT "*",a_subramo CHAR(255) DEFAULT "*"	)
RETURNING CHAR(3),CHAR(50),SMALLINT,DEC(16,2),DEC(16,2),DEC(16,2),DEC(16,2),DEC(16,2),CHAR(255),CHAR(50),DEC(16,2),DEC(16,2);
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
	  define _porc_partic_prima				 dec(9,6);
	  define _p_sus_tot						 DEC(16,2);
	  define _p_sus_tot_sum					 DEC(16,2);
	  define v_prima_tipo					 DEC(16,2);
	  define v_prima_1 						 DEC(16,2);
	  define v_prima_3 						 DEC(16,2);
	  define v_prima_bq						 DEC(16,2);
	  define v_prima_Ot,_ret_casco			 DEC(16,2);
	  define _bouquet						 smallint;
	  DEFINE v_rango_inicial	             DEC(16,2);
	  DEFINE v_rango_final	                 DEC(16,2);
	  DEFINE v_suma_asegurada 				 DECIMAL(16,2);
	  DEFINE v_cod_tipo						 CHAR(3);
	  DEFINE v_porcentaje					 smallint;
	  DEFINE _t_ramo						 CHAR(1);
	  DEFINE _flag , _cnt					 smallint;
	  define _sum_fac_car 				     dec(16,2);
	  define _facilidad_car,_valor           smallint;
	  define _no_doc                         char(20);
	  define _no_remesa						 char(10);
	  define _renglon						 integer;
	  define _porc_proporcion     			 dec(5,2);
	  	  	  	
     SET ISOLATION TO DIRTY READ;

     LET v_descr_cia  = sp_sis01(a_compania);

     let _valor = 0;

     CALL sp_pro307(a_compania,a_agencia,a_periodo1,a_periodo2,a_codsucursal,a_codgrupo,
                   a_codagente,a_codusuario,a_codramo,a_reaseguro) RETURNING v_filtros;

	CREATE TEMP TABLE tmp_ramos
	           (cod_ramo         CHAR(3),
			    cod_sub_tipo     CHAR(3),
				porcentaje       SMALLINT default 100,
            PRIMARY KEY(cod_ramo, cod_sub_tipo)) WITH NO LOG;			
			    							    

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

CREATE TEMP TABLE tmp_tabla(
		cod_ramo		 CHAR(3),
		desc_ramo		 CHAR(50),
        cant_polizas     SMALLINT,
        p_cobrada        DEC(16,2),
        p_retenida       DEC(16,2),
		p_bouquet        DEC(16,2),
		p_facultativo    DEC(16,2),
		p_otros		     DEC(16,2),
		p_fac_car	     DEC(16,2),
        p_ret_casco      DEC(16,2),
        PRIMARY KEY (cod_ramo)) WITH NO LOG;

CREATE TEMP TABLE tmp_tabla2(
		no_remesa		 CHAR(10),
		renglon 		 SMALLINT
		) WITH NO LOG;

      LET v_prima        = 0;
	  let _cod_subramo   = "001";
	  let _prima_tot_ret = 0;
	  let _prima_sus_tot = 0;
	  let _p_sus_tot     = 0;
	  let _p_sus_tot_sum = 0;
	  let _tipo_cont     = 0;
	  LET v_filtros1     = "";
	  LET v_filtros2     = "";
	  let _porc_comis_ase = 0;
	  LET _sum_fac_car    = 0;
	  let _cnt            = 0;
	  let _ret_casco      = 0;

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

--set debug file to "sp_pr999sr.trc";
--trace on;

FOREACH
	     select z.no_poliza,
				z.no_endoso,
		        z.prima_neta,	   -- sum(z.prima_neta),
				z.vigencia_inic,	   -- min(z.vigencia_inic)
				z.no_documento,
				z.no_remesa,
				z.renglon
           into v_nopoliza,
	     		v_noendoso,
		        v_prima_cobrada,
				_fecha,
				_no_doc,
				_no_remesa,
				_renglon
           from temp_det z
          where z.seleccionado = 1

		 select count(*)
		   into _cnt
		   from reaexpol
		  where no_documento = _no_doc
		    and activo       = 1;

		 if _cnt = 1 then                         --"0110-00406-01" or _no_doc = "0110-00407-01" or _no_doc = "0109-00700-01" then --Estas polizas del Bco Hipotecario no las toman en cuenta.
			continue foreach;
		 end if

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


{		 if v_cod_ramo = '002' then

		    let _valor = sp_pr999sr1(v_nopoliza,_no_unidad,_no_cambio,v_prima_cobrada,'*');

		 else}

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

	            IF v_tipo_contrato = 3 THEN	 --facult.

					let _tipo_cont = 2;

	            elif v_tipo_contrato = 1 then --retencion

				 	let _tipo_cont = 1;

	            END IF

			   if _porc_proporcion is null then
					let _porc_proporcion = 100;
					insert into tmp_tabla2(no_remesa,renglon) values(_no_remesa,_renglon);
			   end if
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
					     and no_poliza     = v_nopoliza;

					 	if _cantidad = 0 then
							if _nombre_cob is null then
								let _nombre_cob = '';
							end if
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
					                    '*');
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
					                         _cod_coasegur,'*');
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
					                      _cod_coasegur,'*');
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
				     and cod_cober_reas = v_cobertura;
	  		         --and no_unidad      = _no_unidad;

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
									if _nombre_cob is null then
										let _nombre_cob = '';
									end if
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
					                    			'999','*');
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
	  		                           --and no_unidad      = _no_unidad
							 			
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
								                      _cod_coasegur,'*');
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

--- tabla de ramos:

FOREACH
 SELECT Distinct cod_ramo
   INTO v_cod_ramo
   FROM temp_produccion
  WHERE seleccionado = 1

     IF v_cod_ramo in ("001", "003") THEN
	     IF v_cod_ramo in ("001") THEN
			LET _t_ramo = "1";
		 END IF
	     IF v_cod_ramo in ("003") THEN
			LET _t_ramo = "3";
		 END IF

		BEGIN
			ON EXCEPTION IN(-239)
			END EXCEPTION

		    let v_cod_tipo = "IN"||_t_ramo;

			INSERT INTO tmp_ramos (cod_ramo,cod_sub_tipo,porcentaje)
			VALUES (v_cod_ramo,v_cod_tipo,70);

		    let v_cod_tipo = "TE"||_t_ramo;

			INSERT INTO tmp_ramos (cod_ramo,cod_sub_tipo,porcentaje)
			VALUES (v_cod_ramo,v_cod_tipo,30);
		END
     ELSE
		INSERT INTO tmp_ramos (cod_ramo,cod_sub_tipo,porcentaje)
		VALUES (v_cod_ramo,v_cod_ramo,100);
     END IF	   	

END FOREACH

FOREACH
     SELECT cod_ramo,		  --SE BUSCA POR POLIZAS
			no_poliza,
	        SUM(prima)
       INTO v_cod_ramo,
			v_nopoliza,
           	v_prima
       FROM temp_produccion
	  where seleccionado = 1
   GROUP BY cod_ramo, no_poliza
   ORDER BY cod_ramo, no_poliza

		 SELECT suma_asegurada
		   INTO v_suma_asegurada
           FROM emipomae 
          WHERE no_poliza    = v_nopoliza
            AND cod_compania = "001"
            AND actualizado  = 1;

 	   	   LET v_prima_tipo  = 0;
 	   	   LET v_prima_1     = 0;
 	   	   LET v_prima_3     = 0;
 	   	   LET v_prima_bq    = 0;
 	   	   LET v_prima_Ot    = 0;
		   LET _sum_fac_car  = 0;
 		   let _ret_casco    = 0;

       FOREACH					 -- SE DESGLOSA POR TIPO, BUSCAR PRIMERO SI ES BOUQUET
			SELECT cod_contrato,
				   cod_cobertura,
				   tipo,
				   cod_coasegur,
				   serie,
				   SUM(prima)
			  INTO v_cod_contrato,
			       v_cobertura,
				   _tipo_cont,
				   _cod_coasegur,
				   _serie,
				   v_prima_tipo
			  FROM temp_produccion
			 WHERE cod_ramo     = v_cod_ramo
			   AND no_poliza    = v_nopoliza 
			   and seleccionado = 1
			 GROUP BY cod_contrato,cod_cobertura,tipo,cod_coasegur,serie 
			 ORDER BY cod_contrato,cod_cobertura,tipo,cod_coasegur,serie  

				   LET _flag = 0;
				   LET _cnt  = 0;

				SELECT bouquet
				  INTO _bouquet
				  FROM reacocob
				 WHERE cod_contrato   = v_cod_contrato
				   AND cod_cober_reas = v_cobertura;

			   	let _facilidad_car = 0;

				select facilidad_car
				  into _facilidad_car
				  from reacomae
				 where cod_contrato = v_cod_contrato;

					IF _bouquet = 1 AND _serie >= 2008 and _cod_coasegur in ('050','063','076','042','036','089') THEN	   -- Condiciones del Borderaux Bouquet	  '050','063','076','042'

						if _facilidad_car = 0 then
							let _cnt = 0;
						end if
						if _cnt = 0 then
			 	   	         LET _flag = 1;
						end if

				    END IF

					IF _flag = 1 THEN
						if _facilidad_car = 1 then
							let _sum_fac_car = _sum_fac_car + v_prima_tipo;
						else
			 	   	   		LET v_prima_bq = v_prima_bq + v_prima_tipo;
						end if
				    ELSE
					   IF _tipo_cont = 2 or _tipo_cont = 1 THEN
						   IF _tipo_cont = 1 THEN		--	RETENCION
							  if v_cod_ramo = '002' then
							  		if v_cobertura = '002' then
						 	   	      let v_prima_1 = v_prima_1 + v_prima_tipo;
									else
									  let _ret_casco = _ret_casco + v_prima_tipo;
									end if
							  else
					 	   	      LET v_prima_1 = v_prima_1 + v_prima_tipo;
							  end if
						   END IF
						   IF _tipo_cont = 2 THEN		--  FACULTATIVOS
				 	   	      LET v_prima_3 = v_prima_3 + v_prima_tipo ;					   
						   END IF
					   ELSE
						if _facilidad_car = 1 then
							let _sum_fac_car = _sum_fac_car + v_prima_tipo;
						else
			 	   	        let v_prima_Ot = v_prima_Ot + v_prima_tipo ;		
						end if	
					   END IF
				    END IF

			       LET v_prima_tipo = 0;

	   END FOREACH


		   FOREACH
			 SELECT cod_sub_tipo, porcentaje
			   INTO v_cod_tipo, v_porcentaje
			   FROM tmp_ramos
			  WHERE cod_ramo = v_cod_ramo					

					SELECT nombre
					  INTO v_desc_ramo
					  FROM prdramo
					 WHERE cod_ramo = v_cod_ramo;

					 if v_cod_tipo[1,2] = "IN" then
						LET v_desc_ramo = Trim(v_desc_ramo)||"-INCENDIO";
					 elif v_cod_tipo[1,2] = "TE" then
						LET v_desc_ramo = Trim(v_desc_ramo)||"-TERREMOTO";
					end if

			     BEGIN
			        ON EXCEPTION IN(-239)
			           UPDATE tmp_tabla
			              SET cant_polizas   = cant_polizas   + 1,
				 		      p_cobrada      = p_cobrada      + v_prima * v_porcentaje/100,   		
						 	  p_retenida     = p_retenida     + v_prima_1 * v_porcentaje/100,
						 	  p_bouquet      = p_bouquet      + v_prima_bq * v_porcentaje/100,	
						 	  p_facultativo  = p_facultativo  + v_prima_3 * v_porcentaje/100,
						 	  p_otros		 = p_otros        + v_prima_Ot * v_porcentaje/100,
						 	  p_fac_car		 = p_fac_car      + _sum_fac_car * v_porcentaje/100,
						 	  p_ret_casco    = p_ret_casco    + _ret_casco * v_porcentaje/100	
			            WHERE cod_ramo       = v_cod_tipo;  

			           END EXCEPTION

			          INSERT INTO tmp_tabla
							(cod_ramo,							
							 desc_ramo,							
							 cant_polizas, 					
							 p_cobrada,    					
							 p_retenida,   					
							 p_bouquet,    					
							 p_facultativo,					
							 p_otros,
							 p_fac_car,
							 p_ret_casco	
							)
					  VALUES(v_cod_tipo, 
							 v_desc_ramo, 
							 1, 
							 v_prima      * v_porcentaje/100, 
							 v_prima_1    * v_porcentaje/100, 
							 v_prima_bq   * v_porcentaje/100, 
							 v_prima_3    * v_porcentaje/100, 
							 v_prima_Ot   * v_porcentaje/100,
							 _sum_fac_car * v_porcentaje/100,
							 _ret_casco   * v_porcentaje/100 							  							  							  
							 );				 
			       END

		   END FOREACH

	       LET v_prima   = 0; 

END FOREACH

FOREACH
	 SELECT cod_ramo,		
			desc_ramo,		
			cant_polizas, 
			p_cobrada,    
			p_retenida,   
			p_bouquet,    
			p_facultativo,
			p_otros,
			p_fac_car,
			p_ret_casco					
  	   INTO v_cod_ramo, 
			v_desc_ramo, 
			_cantidad, 
			v_prima, 
			v_prima_1, 
			v_prima_bq, 
			v_prima_3, 
			v_prima_Ot,
			_sum_fac_car,
			_ret_casco
	   FROM tmp_tabla 
	  ORDER BY cod_ramo

     RETURN v_cod_ramo,  
			v_desc_ramo,   
     		_cantidad,  
     		v_prima,  
     		v_prima_1,  
     		v_prima_bq,  
     		v_prima_3,  
     		v_prima_Ot, 
     		v_filtros, 
     		v_descr_cia,
     		_sum_fac_car,
     		_ret_casco      		 	          
       WITH RESUME;

END FOREACH

DROP TABLE temp_produccion;
DROP TABLE temp_det;
DROP TABLE tmp_tabla;
DROP TABLE tmp_ramos;

END

END PROCEDURE


		  