--------------------------------------------
--      TOTALES DE PRODUCCION POR         --
--         CONTRATO DE REASEGURO          --
---  Yinia M. Zamora - octubre 2000 - YMZM
---  Ref. Power Builder - d_sp_pro40
--- Modificado por Armando Moreno 19/01/2002; la parte de los tipo de contratos
--------------------------------------------
DROP PROCEDURE sp_pro40;

CREATE PROCEDURE sp_pro40(
		a_compania    CHAR(03),
		a_agencia     CHAR(03),
		a_periodo1    CHAR(07),
		a_periodo2    CHAR(07),
		a_codsucursal CHAR(255) DEFAULT "*",
		a_codgrupo    CHAR(255) DEFAULT "*",
		a_codagente   CHAR(255) DEFAULT "*",
		a_codusuario  CHAR(255) DEFAULT "*",
		a_codramo     CHAR(255) DEFAULT "*",
		a_reaseguro   CHAR(255) DEFAULT "*"
		)
RETURNING CHAR(03),CHAR(50),CHAR(50),CHAR(100),DECIMAL(16,2),CHAR(50),CHAR(255),dec(16,2),dec(16,2),dec(16,2),dec(16,2),dec(16,2),dec(16,2),dec(16,2),smallint;

   BEGIN
      DEFINE v_nopoliza                      CHAR(10);
      DEFINE v_noendoso,v_cod_contrato       CHAR(5);
      DEFINE v_cod_ramo,v_cobertura          CHAR(03);
      DEFINE v_desc_ramo, v_desc_contrato    CHAR(50);
      DEFINE v_desc_cobertura	             CHAR(100);
      DEFINE v_filtros                       CHAR(255);
      DEFINE _tipo                           CHAR(01);
      DEFINE v_descr_cia                     CHAR(50);
      DEFINE v_prima,v_prima1                DEC(16,2);
      DEFINE v_tipo_contrato                 SMALLINT;

	  define _porc_impuesto					 dec(16,2);
	  define _porc_comision					 dec(16,2);
	  define _cuenta						 char(25);
	  define _serie 						 smallint;
	  define _impuesto						 dec(16,2);
	  define _comision						 dec(16,2);
	  define _por_pagar						 dec(16,2);
	  define _prima_tot_ret                  dec(16,2);
	  define _prima_sus_tot					 dec(16,2);
	  define _prima_tot_ret_sum              dec(16,2);
	  define _prima_tot_sus_sum              dec(16,2);

	  DEFINE _cod_traspaso	 				 CHAR(5);
	  define _traspaso		 				 smallint;
	  define _tiene_comis_rea				 smallint;
	  define _cantidad						 smallint;
	  	
	  define _porc_cont_partic 				 dec(5,2);
	  DEFINE _porc_comis_ase   				 DECIMAL(5,2);
	  define _monto_reas					 dec(16,2);
	  define _cod_coasegur	 				 char(3);
	  define _nombre_coas					 char(50);
	  define _nombre_cob					 char(50);
	  define _nombre_con					 char(50);
	  define _cod_subramo					 char(3);
	  define _cod_origen					 char(3);
	  define _cod_r                          char(3);
	  define _tipo_cont                      smallint;
	  	
     CALL sp_pro34(a_compania,a_agencia,a_periodo1,a_periodo2,a_codsucursal,a_codgrupo,
                   a_codagente,a_codusuario,a_codramo,a_reaseguro) RETURNING v_filtros;

     CREATE TEMP TABLE temp_produccion
               (cod_ramo         CHAR(3),
			    cod_subramo		 char(3),
				cod_origen		 char(3),
                cod_contrato     CHAR(5),
				desc_contrato    CHAR(50),
                cod_cobertura    CHAR(3),
				prima            DEC(16,2),
				tipo             smallint default 0,
            PRIMARY KEY(cod_ramo, cod_subramo, cod_origen, cod_contrato, cod_cobertura)) WITH NO LOG;

     CREATE TEMP TABLE tmp_priret
               (cod_ramo         CHAR(3),
			    prima_sus_tot    DEC(16,2),
				prima            DEC(16,2)) WITH NO LOG;

      LET v_prima        = 0;
	  let _prima_tot_ret = 0;
	  let _prima_sus_tot = 0;
      LET v_descr_cia    = sp_sis01(a_compania);
	  let _tipo_cont = 0;
    
      SET ISOLATION TO DIRTY READ;

      FOREACH WITH HOLD
	     SELECT z.no_poliza,
	     		z.no_endoso
           INTO v_nopoliza,
           		v_noendoso
           FROM temp_det z
          WHERE z.seleccionado = 1
		  group by 1, 2

		 select cod_ramo,
		        cod_subramo,
			    cod_origen
		   into v_cod_ramo,
		        _cod_subramo,
		        _cod_origen
		   from emipomae
		  where no_poliza = v_nopoliza;

		 select count(*)
		   into _cantidad
		   from tmp_priret
		  where cod_ramo = v_cod_ramo;

		 if _cantidad = 0 then

		 	 select sum(prima)
			   into _prima_sus_tot
			   from temp_det
			  where cod_ramo     = v_cod_ramo
			    and seleccionado = 1;

			 INSERT INTO tmp_priret
	              VALUES(v_cod_ramo,_prima_sus_tot,0);
		 end if

         FOREACH
		    SELECT cod_cober_reas,
		    	   cod_contrato,
		    	   prima
              INTO v_cobertura,
              	   v_cod_contrato,
              	   v_prima1
              FROM emifacon
             WHERE no_poliza = v_nopoliza
               AND no_endoso = v_noendoso
               AND prima <> 0

				select traspaso
				  into _traspaso
				  from reacocob
				 where cod_contrato   = v_cod_contrato
				   and cod_cober_reas = v_cobertura;

				Select cod_traspaso
			      Into _cod_traspaso
				  From reacomae
				 Where cod_contrato = v_cod_contrato;

				if _traspaso = 1 then
					let v_cod_contrato = _cod_traspaso;
				end if

	            SELECT tipo_contrato,
				       serie
	              INTO v_tipo_contrato,
				       _serie
	              FROM reacomae
	             WHERE cod_contrato = v_cod_contrato;

				let _tipo_cont = 0;

	            IF v_tipo_contrato = 3 THEN   --facultativos

	               --CONTINUE FOREACH;
				   let _tipo_cont = 2;
	               let v_prima    = v_prima1;

	            elif v_tipo_contrato = 1 then --retencion

				 let _tipo_cont = 1;

				 select count(*)
				   into _cantidad
				   from tmp_priret
				  where cod_ramo = v_cod_ramo;

				 if _cantidad = 0 then

				 	 select sum(prima_sus_tot)
					   into _prima_sus_tot
					   from temp_det
					  where cod_ramo     = v_cod_ramo
					    and seleccionado = 1;

					 INSERT INTO tmp_priret
			              VALUES(v_cod_ramo,0,v_prima1);
				 else
					 update tmp_priret
					    set prima = prima + v_prima1
				      where cod_ramo = v_cod_ramo;

				 end if

	             LET v_prima = v_prima1;
	                --CONTINUE FOREACH;
				else
	               LET v_prima = v_prima1;
	            END IF

				let _cod_subramo = "001";

				select count(*)
				  into _cantidad
				  from temp_produccion
				 where cod_ramo      = v_cod_ramo
				   and cod_subramo   = _cod_subramo
				   and cod_origen    = _cod_origen
	               and cod_contrato  = v_cod_contrato
	               and cod_cobertura = v_cobertura;

				if _cantidad = 0 then

		            SELECT nombre
		              INTO v_desc_contrato
		              FROM reacomae
		             WHERE cod_contrato = v_cod_contrato;

					let v_desc_contrato = trim(v_desc_contrato) || " (" || v_cod_contrato || ")" || "  A: " || _serie;
			
					INSERT INTO temp_produccion
		                  VALUES(v_cod_ramo,
						         _cod_subramo,
								 _cod_origen,
		                         v_cod_contrato,
								 v_desc_contrato,
		                         v_cobertura,
		                         v_prima,
		                         _tipo_cont);
				else

	               UPDATE temp_produccion
	                  SET prima         = prima + v_prima
	                WHERE cod_ramo      = v_cod_ramo
					  and cod_subramo	= _cod_subramo
					  and cod_origen    = _cod_origen
	                  AND cod_contrato  = v_cod_contrato
	                  AND cod_cobertura = v_cobertura;

				end if

			   LET v_prima1 = 0;

         END FOREACH

      END FOREACH

	  let _prima_tot_ret_sum = 0;
	  let _prima_tot_sus_sum = 0;
      FOREACH
	         SELECT cod_ramo,
			        cod_subramo,
					cod_origen,
					cod_contrato,
	         		desc_contrato,
	         		cod_cobertura,
					tipo,
	         		SUM(prima)
	           INTO v_cod_ramo,
			        _cod_subramo,
					_cod_origen,
			        v_cod_contrato,
	           		_nombre_con,
	           		v_cobertura,
					_tipo_cont,
	           		v_prima
	           FROM temp_produccion
	       GROUP BY cod_ramo, cod_subramo, cod_origen, cod_cobertura, desc_contrato, cod_contrato, tipo
		   ORDER BY cod_ramo, cod_subramo, cod_origen, cod_cobertura, desc_contrato, cod_contrato, tipo

	         SELECT sum(prima),
			        sum(prima_sus_tot)
	           INTO _prima_tot_ret,
					_prima_sus_tot
	           FROM tmp_priret
			  where cod_ramo = v_cod_ramo;

	         SELECT sum(prima),
			        sum(prima_sus_tot)
	           INTO _prima_tot_ret_sum,
				    _prima_tot_sus_sum
	           FROM tmp_priret;

			Select porc_impuesto,
			       porc_comision,
				   tiene_comision
			  Into _porc_impuesto,
				   _porc_comision,
				   _tiene_comis_rea
			  From reacocob
			 Where cod_contrato   = v_cod_contrato
			   And cod_cober_reas = v_cobertura;

			 let _cuenta = sp_sis15("PPRXP", "05", _cod_origen, v_cod_ramo, _cod_subramo);

	         SELECT nombre
	           INTO v_desc_ramo
	           FROM prdramo
	          WHERE cod_ramo = v_cod_ramo;

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

			         RETURN v_cod_ramo,
			         		v_desc_ramo,
			         		v_desc_contrato,
			                v_desc_cobertura,
			                v_prima,
			                v_descr_cia,
			                v_filtros, 
							0.00,
							0.00, 
							0.00,
							0.00,
							0.00,
							0.00,
							0.00,
							_tipo_cont
			                WITH RESUME;
				 end if

			 elif _tipo_cont = 1 then	  --Retencion

				 if _cantidad = 0 then

					    let _porc_impuesto = 0;
						let _porc_comision = 0;
						let v_desc_cobertura = trim(_nombre_cob) || "  " || trim(_cuenta) || "  " || 'ASEGURADORA ANCON';
						let v_desc_contrato  = trim(_nombre_con) || "  I:" || _porc_impuesto || "  C:" || _porc_comision;

						let _monto_reas = v_prima;
						let _impuesto   = _monto_reas * _porc_impuesto / 100;
						let _comision   = _monto_reas * _porc_comision / 100;
						let _por_pagar  = _monto_reas - _impuesto - _comision;

								
					        RETURN v_cod_ramo,
					         	   v_desc_ramo,
					         	   v_desc_contrato,
					               v_desc_cobertura,
					               _monto_reas,
					               v_descr_cia,
					               v_filtros, 
								   _comision,
								   _impuesto, 
								   _por_pagar,
								   _prima_tot_ret,
								   _prima_sus_tot,
								   _prima_tot_ret_sum,
								   _prima_tot_sus_sum,
								   _tipo_cont
					               WITH RESUME;
				 end if

			 elif _tipo_cont = 2 then  --facultativos

				 select count(*)
				   into _cantidad
				   from emifafac
			      where cod_contrato   = v_cod_contrato
			        and cod_cober_reas = v_cobertura;

				 if _cantidad = 0 then     --Otros contratos

				   	let v_desc_contrato  = "******* NO EXISTE REGISTRO DE COMPANIAS " || v_cod_contrato;

				    RETURN v_cod_ramo,
				           v_desc_ramo,
				           v_desc_contrato,
				           v_desc_cobertura,
				           v_prima,
				           v_descr_cia,
				           v_filtros, 
						   0.00,
						   0.00, 
						   0.00,
						   0.00,
						   0.00,
						   0.00,
						   0.00,
						   _tipo_cont
				           WITH RESUME;
				 end if

			 end if

			if _tipo_cont = 0 OR _tipo_cont = 1 then

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

					let v_desc_cobertura = trim(_nombre_cob) || "  " || trim(_cuenta) || "  " || trim(_nombre_coas);
					let v_desc_contrato  = trim(_nombre_con) || "  I:" || _porc_impuesto || "  C:" || _porc_comision;

					let _monto_reas = v_prima     * _porc_cont_partic / 100;
					let _impuesto   = _monto_reas * _porc_impuesto / 100;
					let _comision   = _monto_reas * _porc_comision / 100;
					let _por_pagar  = _monto_reas - _impuesto - _comision;

					
			        RETURN v_cod_ramo,
			         	   v_desc_ramo,
			         	   v_desc_contrato,
			               v_desc_cobertura,
			               _monto_reas,
			               v_descr_cia,
			               v_filtros, 
						   _comision,
						   _impuesto, 
						   _por_pagar,
						   _prima_tot_ret,
						   _prima_sus_tot,
						   _prima_tot_ret_sum,
						   _prima_tot_sus_sum,
						   _tipo_cont
			               WITH RESUME;

				end foreach

			end if

			if _tipo_cont = 2 then

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
				     where cod_contrato   = v_cod_contrato
				       and cod_cober_reas = v_cobertura
						
					select nombre
					  into _nombre_coas
					  from emicoase
					 where cod_coasegur = _cod_coasegur;

					let v_desc_cobertura = trim(_nombre_cob) || "  " || trim(_cuenta) || "  " || trim(_nombre_coas);
					let v_desc_contrato  = trim(_nombre_con) || "  I:" || _porc_impuesto || "  C:" || _porc_comision;

					let _monto_reas = v_prima     * _porc_cont_partic / 100;
					let _impuesto   = _monto_reas * _porc_impuesto / 100;
					let _comision   = _monto_reas * _porc_comision / 100;
					let _por_pagar  = _monto_reas - _impuesto - _comision;

					
			        RETURN v_cod_ramo,
			         	   v_desc_ramo,
			         	   v_desc_contrato,
			               v_desc_cobertura,
			               _monto_reas,
			               v_descr_cia,
			               v_filtros, 
						   _comision,
						   _impuesto, 
						   _por_pagar,
						   _prima_tot_ret,
						   _prima_sus_tot,
						   _prima_tot_ret_sum,
						   _prima_tot_sus_sum,
						   _tipo_cont
			               WITH RESUME;

				end foreach

			end if

      END FOREACH

      DROP TABLE temp_produccion;
      DROP TABLE temp_det;
	  DROP TABLE tmp_priret;

   END

END PROCEDURE
