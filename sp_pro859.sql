--------------------------------------------
--      TOTALES DE PRODUCCION POR         --
--         CONTRATO DE REASEGURO          --
---  Yinia M. Zamora - octubre 2000 - YMZM
---  Ref. Power Builder - d_sp_pro40
--- Modificado por Armando Moreno 19/01/2002; la parte de los tipo de contratos
--------------------------------------------
DROP PROCEDURE sp_pro859;

CREATE PROCEDURE sp_pro859(a_compania CHAR(03), a_agencia CHAR(03),	a_periodo1 CHAR(07), a_periodo2 CHAR(07), a_codsucursal CHAR(255) DEFAULT "*", a_codgrupo CHAR(255) DEFAULT "*", a_codagente CHAR(255) DEFAULT "*",	a_codusuario CHAR(255) DEFAULT "*",	a_codramo CHAR(255) DEFAULT "*",	a_reaseguro CHAR(255) DEFAULT "*")
RETURNING CHAR(03),VARCHAR(50),CHAR(03),CHAR(50),CHAR(50),CHAR(100),DECIMAL(16,2),CHAR(50),CHAR(255),dec(16,2),dec(16,2),dec(16,2),dec(16,2),dec(16,2),dec(16,2),dec(16,2),dec(16,2),dec(16,2),smallint;

   BEGIN
      DEFINE v_nopoliza                      CHAR(10);
      DEFINE v_noendoso,v_cod_contrato       CHAR(5);
      DEFINE v_cod_ramo,v_cobertura          CHAR(03);
      DEFINE v_desc_ramo, v_desc_contrato    CHAR(50);
      DEFINE v_desc_cobertura	             CHAR(100);
      DEFINE v_filtros                       CHAR(255);
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
	  DEFINE _ano                            SMALLINT;
	  define _tot_comision 					 dec(16,2);
	  define _tot_impuesto 					 dec(16,2);
	  define _tot_prima_neta				 dec(16,2);


     SET ISOLATION TO DIRTY READ;

     LET _ano =  a_periodo1[1,4];

     LET v_descr_cia  = sp_sis01(a_compania);

     CALL sp_pro307(a_compania,a_agencia,a_periodo1,a_periodo2,a_codsucursal,a_codgrupo,
                   a_codagente,a_codusuario,a_codramo,a_reaseguro) RETURNING v_filtros;

     CALL sp_pro314(a_compania,a_agencia,a_periodo1,a_periodo2,a_codsucursal,a_codgrupo,
                   a_codagente,a_codusuario,a_codramo,a_reaseguro) RETURNING v_filtros;


     CREATE TEMP TABLE tmp_priret
               (cod_ramo         CHAR(3),
			    cod_contrato     CHAR(3),
			    prima_sus_tot    DEC(16,2),
				prima            DEC(16,2),
				prima_sus_t      DEC(16,2)) WITH NO LOG;
				
   --set debug file to "sp_pro859.trc";


      LET v_prima        = 0;
	  let _cod_subramo   = "001";
	  let _prima_tot_ret = 0;
	  let _prima_sus_tot = 0;
	  let _p_sus_tot     = 0;
	  let _p_sus_tot_sum = 0;
	  let _tipo_cont     = 0;

DELETE FROM reacoest;
DELETE FROM temphg;

FOREACH
	     select z.no_poliza,
				z.no_endoso,
		        sum(z.prima_neta),
				min(z.vigencia_inic)
           into v_nopoliza,
	     		v_noendoso,
		        v_prima_cobrada,
				_fecha
           from temp_det z
          where z.seleccionado = 1
		  group by 1,2

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
                    --trace on;

					 select count(*)
					   into _cantidad
					   from tmp_priret
					  where cod_ramo = v_cod_ramo
					    and cod_contrato = "99999";

					 if _cantidad = 0 then

						 INSERT INTO tmp_priret
				              VALUES(v_cod_ramo, "99999",v_prima_cobrada,0,0);
					 else

						update tmp_priret
						   set prima_sus_tot = prima_sus_tot + v_prima_cobrada
					     where cod_ramo = v_cod_ramo
					       and cod_contrato = "99999";

					 end if
					 --trace off;

			         RETURN "",
					        "",
			                "",
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
							_tipo_cont
			                WITH RESUME;

				else

					select min(no_cambio)
					  into _no_cambio
					  from emireama	
					 where no_poliza = v_nopoliza;

				end if

		 else

				select min(no_cambio)
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

                if _ano <> _serie then
					CONTINUE FOREACH;
				end if

                if v_tipo_contrato <> 5 AND v_tipo_contrato <> 7 then
					CONTINUE FOREACH;
				end if

				if _traspaso = 1 then
					let v_cod_contrato = _cod_traspaso;
				end if

				let _tipo_cont = 0;

	            IF v_tipo_contrato = 3 THEN

					let _tipo_cont = 2;

	            elif v_tipo_contrato = 1 then --retencion

   {				   let v_prima1 = v_prima_cobrada * _porc_partic_prima / 100;

					update tmp_priret
					   set prima = prima + v_prima1
				     where cod_ramo = v_cod_ramo;
	}
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

--				let _nombre_con = trim(v_desc_contrato) || " (" || v_cod_contrato || ")" || "  A: " || _serie;
--				let _cuenta     = sp_sis15("PPRXP", "05", _cod_origen, v_cod_ramo, _cod_subramo);

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

				 --trace on;
				 select count(*)
				   into _cantidad
				   from tmp_priret
				  where cod_ramo = v_cod_ramo
				    and cod_contrato = v_cod_contrato;

				 if _cantidad = 0 then

					 INSERT INTO tmp_priret
			              VALUES(v_cod_ramo, v_cod_contrato,v_prima,0,0);
				 else

					update tmp_priret
					   set prima_sus_tot = prima_sus_tot + v_prima
				     where cod_ramo = v_cod_ramo
				       and cod_contrato = v_cod_contrato;

				 end if

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
					    from temphg
					   where cod_ramo      = v_cod_ramo
					     and cod_contrato  = v_cod_contrato
					     and cod_cobertura = v_cobertura
					     and desc_cob      = _nombre_cob;

					 	if _cantidad = 0 then

					 		INSERT INTO temphg
					             VALUES("999",
					                    v_cod_ramo,
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
					                    0);
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

 --				 			let v_desc_cobertura = "";
 --				 			let v_desc_cobertura = trim(_nombre_cob) || "  " || trim(_cuenta) || "  " || trim(_nombre_coas);
 				 			let v_desc_cobertura = trim(_nombre_cob);
 --				 			let v_desc_contrato  = trim(v_desc_contrato) || "  I:" || _porc_impuesto || "  C:" || _porc_comision;

				 			let _monto_reas = v_prima     * _porc_cont_partic / 100;
				 			let _impuesto   = _monto_reas * _porc_impuesto / 100;
				 			let _comision   = _monto_reas * _porc_comision / 100;
				 			let _por_pagar  = _monto_reas - _impuesto - _comision;

				 			select count(*)
				 			  into _cantidad
				 			  from temphg
				 			 where cod_ramo      = v_cod_ramo
				               and cod_contrato  = v_cod_contrato
				               and cod_cobertura = v_cobertura
				               and desc_cob      = v_desc_cobertura;

				 			if _cantidad = 0 then

				 				INSERT INTO temphg
				 	                  VALUES(_cod_coasegur,
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
				 	                         _porc_cont_partic);
				 			else
				 			   
				                UPDATE temphg
				                   SET prima       = prima + _monto_reas,
				                   	   comision    = comision  + _comision,
				 					   impuesto    = impuesto  + _impuesto,
				 					   por_pagar   = por_pagar + _por_pagar
				                 WHERE cod_coasegur  = _cod_coasegur
				                   and cod_ramo      = v_cod_ramo
				                   and cod_contrato  = v_cod_contrato
				                   and cod_cobertura = v_cobertura;

				 			end if

				 		end foreach

				  end if
				  --trace off;

  {				 elif _tipo_cont = 1 then	  --Retencion

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
				 		  from temphg
				 		 where cod_ramo      = v_cod_ramo
				 		   and cod_subramo   = _cod_subramo
				 		   and cod_origen    = _cod_origen
			               and cod_contrato  = v_cod_contrato
			               and cod_cobertura = v_cobertura
			               and desc_cob      = v_desc_cobertura;

				 		if _cantidad = 0 then

				 			INSERT INTO temphg
				                   VALUES(_cod_coasegur,
				                         v_cod_ramo,
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
				                          v_desc_cobertura);
				 		else
				 		   
				               UPDATE temphg
				                  SET prima         = prima     + _monto_reas,
				                  	  comision      = comision  + _comision,
				 				      impuesto      = impuesto  + _impuesto,
				 				      por_pagar     = por_pagar + _por_pagar
				                WHERE cod_coasegur	= _cod_coasegur
				                  and cod_ramo      = v_cod_ramo
				 				  and cod_subramo    	= _cod_subramo
				 				  and cod_origen        = _cod_origen
				                  and cod_contrato  = v_cod_contrato
				                  and cod_cobertura = v_cobertura
				                  and desc_cob      = v_desc_cobertura;

				 		end if

				 elif _tipo_cont = 2 then  --facultativos

				  select count(*)
				    into _cantidad
				    from emifafac
				   where no_poliza      = v_nopoliza
				     and no_endoso      = v_noendoso
			         and cod_contrato   = v_cod_contrato
				     and cod_cober_reas = v_cobertura;

						  if _cantidad = 0 then

						    	let v_desc_contrato  = "******* NO EXISTE REGISTRO DE COMPANIAS " || v_cod_contrato;

							 	select count(*)
							 	  into _cantidad
							 	  from temphg
							 	 where cod_ramo      = v_cod_ramo
							 	   and cod_subramo   = _cod_subramo
							 	   and cod_origen    = _cod_origen
							           and cod_contrato  = v_cod_contrato
							           and cod_cobertura = v_cobertura
							           and desc_cob      = _nombre_cob;

							   	if _cantidad = 0 then

							 		INSERT INTO temphg
							                  VALUES("999",
							                      v_cod_ramo,
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
							                         _nombre_cob);
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
							 		  from temphg
							 		 where cod_ramo      = v_cod_ramo
							 		   and cod_subramo   = _cod_subramo
							 		   and cod_origen    = _cod_origen
							           and cod_contrato  = v_cod_contrato
							           and cod_cobertura = v_cobertura
							           and desc_cob      = v_desc_cobertura;

							 		if _cantidad = 0 then

							 			INSERT INTO temphg
							                  VALUES(_cod_coasegur,
							                         v_cod_ramo,
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
							                          v_desc_cobertura);
							 		else

							               UPDATE temphg
							                  SET prima     = prima     + _monto_reas,
								 			      comision  = comision  + _comision,
								 				  impuesto  = impuesto  + _impuesto,
								 				  por_pagar = por_pagar + _por_pagar
							                WHERE cod_coasegur = _cod_coasegur
							                  and cod_ramo  = v_cod_ramo
								 			  and cod_subramo	= _cod_subramo
								 			  and cod_origen    = _cod_origen
							                  and cod_contrato  = v_cod_contrato
							                  and cod_cobertura = v_cobertura
							                  and desc_cob      = v_desc_cobertura;

							 		end if

						        end foreach

						  end if	
						  }
				  end if

         END FOREACH

END FOREACH

  let _prima_tot_ret_sum = 0;
  let _prima_tot_sus_sum = 0;
  let _p_sus_tot_sum     = 0;

 { foreach
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
}
--trace on;
FOREACH
     SELECT cod_coasegur,
            cod_ramo,
			cod_contrato,
     		cod_cobertura,
			tipo,
       	    desc_contrato,
			desc_cob,
			prima,
			comision, 
			impuesto, 
			por_pagar,
			porc_comision,
			porc_impuesto,
			porc_cont_partic
       INTO _cod_coasegur,
            v_cod_ramo,
	        v_cod_contrato,
       		v_cobertura,
			_tipo_cont,
			_nombre_con,
		    v_desc_cobertura,
           	v_prima,
			_comision,
			_impuesto, 
			_por_pagar,
			_porc_comision,
			_porc_impuesto,
			_porc_cont_partic
         FROM temphg
     ORDER BY cod_coasegur, cod_ramo, cod_contrato, desc_contrato, cod_cobertura, tipo, desc_cob
--     GROUP BY cod_coasegur, cod_ramo, cod_contrato, desc_contrato, cod_cobertura, tipo, desc_cob

     SELECT sum(prima),
	        sum(prima_sus_tot),
			sum(prima_sus_t)
       INTO _prima_tot_ret,
			_prima_sus_tot,
			_p_sus_tot
       FROM tmp_priret
	  where cod_ramo = v_cod_ramo
	    AND cod_contrato = v_cod_contrato;

 {    SELECT sum(prima),
	        sum(prima_sus_tot),
			sum(prima_sus_t)
       INTO _prima_tot_ret_sum,
		    _prima_tot_sus_sum,
			_p_sus_tot_sum
       FROM tmp_priret;
 }
	 		select nombre
	 		  into _nombre_coas
	 		  from emicoase
	 		 where cod_coasegur = _cod_coasegur;

            SELECT nombre
              INTO v_desc_ramo
              FROM prdramo
             WHERE cod_ramo = v_cod_ramo;

            LET _tot_comision = _prima_sus_tot * _porc_comision;
            LET _tot_impuesto = _prima_sus_tot * _porc_impuesto;
			LET _tot_prima_neta = _prima_sus_tot - _comision - _impuesto;

            INSERT INTO reacoest
			VALUES (_cod_coasegur,
			        v_cod_ramo,
					v_cod_contrato,
					v_cobertura,
					_prima_sus_tot,
					_tot_comision,
					_tot_impuesto,
					_tot_prima_neta,
					0.00,
					_tot_prima_neta - 0.00,
					(_tot_prima_neta - 0.00) * _porc_cont_partic);


	         RETURN _cod_coasegur,
			        _nombre_coas,
	                v_cod_ramo,
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
					_tipo_cont
	                WITH RESUME;

END FOREACH
--trace off;
--DROP TABLE temphg;
DROP TABLE temp_det;
DROP TABLE temp_det1;
DROP TABLE tmp_priret;

END

END PROCEDURE	