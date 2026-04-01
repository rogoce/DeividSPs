


DROP PROCEDURE sp_pr999sr1;
CREATE PROCEDURE sp_pr999sr1(v_nopoliza CHAR(10),_no_unidad CHAR(5),_no_cambio integer, v_prima_cobrada decimal(16,2),v_no_recibo char(10) default '*')
RETURNING SMALLINT;

   BEGIN
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
--      define v_prima_cobrada           		 DEC(16,2);
	  define _porc_partic_coas				 dec(7,4);
	  define _fecha						     date;
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
	  define _facilidad_car		             smallint;
	  define _no_doc                         char(20);

	  	  	  	
     SET ISOLATION TO DIRTY READ;

let v_nopoliza = v_nopoliza;
let v_prima_cobrada = v_prima_cobrada;

select cod_origen,
       cod_ramo,
	   cod_subramo
  into _cod_origen,
	   v_cod_ramo,
	   _cod_subramo
  from emipomae
 where no_poliza = v_nopoliza;


FOREACH

			    select cod_contrato,
			    	   porc_partic_prima,
					   cod_cober_reas
	              into v_cod_contrato,
	              	   _porc_partic_prima,
					   v_cobertura
	              from emireaco
				 where no_poliza = v_nopoliza
				   and no_unidad = _no_unidad
				   and no_cambio = _no_cambio

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
					                         _cod_coasegur,v_no_recibo);
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

return 0;

END

END PROCEDURE


		  