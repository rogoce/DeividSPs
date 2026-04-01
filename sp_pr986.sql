--------------------------------------------
--      TOTALES DE PRODUCCION POR         --
--         CONTRATO DE REASEGURO          --
---  Yinia M. Zamora - octubre 2000 - YMZM
---  Ref. Power Builder - reemplaza d_sp_pro40 filtro por serie - contrato
--- Modificado por Armando Moreno 19/01/2002; la parte de los tipo de contratos
--- Modificado por Henry 10/9/2009 filtros requeridos por Sr. Omar Wong
--------------------------------------------
DROP PROCEDURE sp_pr986;

CREATE PROCEDURE sp_pr986(
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
RETURNING CHAR(03),CHAR(50),CHAR(50),CHAR(100),DECIMAL(16,2),CHAR(50),CHAR(255),dec(16,2),dec(16,2),dec(16,2),smallint,CHAR(5),smallint;

BEGIN
      DEFINE v_nopoliza                      CHAR(10);
      DEFINE v_noendoso,v_cod_contrato       CHAR(5);
      DEFINE v_cod_ramo,v_cobertura          CHAR(03);
      DEFINE v_desc_ramo, v_desc_contrato    CHAR(50);
      DEFINE v_desc_cobertura	             CHAR(100);
      DEFINE v_filtros,v_filtros1            CHAR(255);
      DEFINE _tipo                           CHAR(01);
      DEFINE v_descr_cia                     CHAR(50);
      DEFINE v_prima,v_prima1                DEC(16,2);
      DEFINE v_tipo_contrato                 SMALLINT;

	  define _porc_impuesto					 dec(16,2);
	  define _porc_comision					 dec(16,2);
	  define _cuenta						 char(25);
	  define _serie 						 smallint;
	  define _impuesto,v_prima_suscrita1	 dec(16,2);
	  define _comision						 dec(16,2);
	  define _por_pagar						 dec(16,2);

	  DEFINE _cod_traspaso	 				 CHAR(5);					  
	  define _traspaso		 				 smallint;
	  define _tiene_comis_rea				 smallint;
	  define _cantidad						 smallint;
	  	
	  define _porc_cont_partic 				 dec(7,4);
	  define v_porc_partic_prima1			 dec(7,4);
	  DEFINE _porc_comis_ase   				 DECIMAL(7,4);    --DECIMAL(5,2);
	  define _monto_reas					 dec(16,2);
	  define _cod_coasegur	 				 char(3);
	  define _nombre_coas					 char(50);
	  define _nombre_cob					 char(50);
	  define _nombre_con					 char(50);
	  define _cod_subramo					 char(3);
	  define _cod_origen					 char(3);
	  define _cod_r                          char(3);
	  define _tipo_cont                      smallint;
	  define _no_unidad						 char(5);
	  	
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
				comision         DEC(16,2),
				impuesto         DEC(16,2),
				por_pagar        DEC(16,2),
				desc_cob         CHAR(100),
				serie 			 SMALLINT,
				seleccionado     SMALLINT DEFAULT 1,
            PRIMARY KEY(cod_ramo, cod_subramo, cod_origen, cod_contrato, cod_cobertura, desc_cob)) WITH NO LOG;

CREATE INDEX idx1_temp_produccion ON temp_produccion(cod_ramo);
CREATE INDEX idx2_temp_produccion ON temp_produccion(cod_subramo);
CREATE INDEX idx3_temp_produccion ON temp_produccion(cod_origen);
CREATE INDEX idx4_temp_produccion ON temp_produccion(cod_contrato);
CREATE INDEX idx5_temp_produccion ON temp_produccion(cod_cobertura);
CREATE INDEX idx6_temp_produccion ON temp_produccion(desc_cob);
CREATE INDEX idx7_temp_produccion ON temp_produccion(serie);

      LET v_prima        = 0;
	  LET v_prima_suscrita1 = 0;
	  LET v_porc_partic_prima1 = 0;

      LET v_descr_cia    = sp_sis01(a_compania);
	  let _tipo_cont     = 0;
	  let v_desc_cobertura = "";
	  LET v_filtros1 = "";
	  let _porc_comis_ase = 0;

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

         FOREACH
		    	SELECT e.cod_cober_reas,
		    		   e.cod_contrato,
			    	   e.prima,
					   e.no_unidad,
					   r.prima_suscrita,
					   e.porc_partic_prima
	              INTO v_cobertura,
              	   	   v_cod_contrato,
              	   	   v_prima1,
					   _no_unidad,
					   v_prima_suscrita1,
					   v_porc_partic_prima1
	              FROM emifacon	e, endeduni r
				 where e.no_poliza = r.no_poliza
				   and e.no_endoso = r.no_endoso
				   and e.no_unidad = r.no_unidad
	               and e.no_poliza = v_nopoliza
	               AND e.no_endoso = v_noendoso
	               AND e.prima <> 0

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

				let _tipo_cont = 0;			  --otros contratos

	            IF v_tipo_contrato = 3 THEN   --facultativos

					let _tipo_cont = 2;
							 
	            elif v_tipo_contrato = 1 then --retencion

					let _tipo_cont = 1;

	            end if

                let v_prima = v_prima1;

				let _cod_subramo = "001";

		        SELECT nombre
		          INTO v_desc_contrato
		          FROM reacomae
		         WHERE cod_contrato = v_cod_contrato;

				let v_desc_contrato = trim(v_desc_contrato) || " (" || v_cod_contrato || ")" || "  A: " || _serie;

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

					  select count(*)
					    into _cantidad
					    from temp_produccion
					   where cod_ramo      = v_cod_ramo
					     and cod_subramo   = _cod_subramo
					     and cod_origen    = _cod_origen
					     and cod_contrato  = v_cod_contrato
					     and cod_cobertura = v_cobertura
					     and desc_cob      = _nombre_cob;

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
					                    1);
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

				 			let _monto_reas = v_prima     * _porc_cont_partic / 100;   -- al parecer la diferencia es en redondeo.
--				 			let _monto_reas = (v_prima_suscrita1 * v_porc_partic_prima1/100) * _porc_cont_partic / 100;							
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
				                and desc_cob      = v_desc_cobertura;

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
					                    	 1 );
				 			else
				 			   
				                UPDATE temp_produccion
				                   SET prima       = prima + _monto_reas,
				                   	   comision    = comision  + _comision,
				 					   impuesto    = impuesto  + _impuesto,
				 					   por_pagar   = por_pagar + _por_pagar
				                 WHERE cod_ramo      = v_cod_ramo
				 				  and cod_subramo    = _cod_subramo
				 				  and cod_origen     = _cod_origen
				                   and cod_contrato  = v_cod_contrato
				                   and cod_cobertura = v_cobertura
				                   and desc_cob      = v_desc_cobertura;

				 			end if
				 			--let v_prima1 = 0;
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

				 		let _monto_reas = v_prima;         -- al parecer la diferencia es en redondeo.
--			 			let _monto_reas = v_prima_suscrita1 * v_porc_partic_prima1/100;	
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
				           and desc_cob      = v_desc_cobertura;

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
					                      1);
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
				                  and desc_cob      = v_desc_cobertura;

				 		end if

				 elif _tipo_cont = 2 then  --facultativos

				  select count(*)
				    into _cantidad
				    from emifafac
				   where no_poliza      = v_nopoliza
				     and no_endoso      = v_noendoso
			         and cod_contrato   = v_cod_contrato
				     and cod_cober_reas = v_cobertura
				     and no_unidad = _no_unidad ;

				  if _cantidad = 0 then

				    	let v_desc_contrato  = "******* NO EXISTE REGISTRO DE COMPANIAS " || v_cod_contrato;

					 	select count(*)
					 	  into _cantidad
					 	  from temp_produccion
					 	 where cod_ramo          = v_cod_ramo
					 	   and cod_subramo       = _cod_subramo
					 	   and cod_origen        = _cod_origen
					           and cod_contrato  = v_cod_contrato
					           and cod_cobertura = v_cobertura
					           and desc_cob      = _nombre_cob;

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
					                    	 1);
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
				               and no_unidad     = _no_unidad 
					 			
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
					           and desc_cob      = v_desc_cobertura;

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
					                    	  1);
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
					                  and desc_cob      = v_desc_cobertura;

					 		end if

				        end foreach

				  end if	

				 end if

         END FOREACH

      END FOREACH

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

LET v_filtros = TRIM(v_filtros1)||" "|| TRIM(v_filtros);

      FOREACH
	        SELECT cod_ramo,
			       cod_subramo,
				   cod_origen,
				   cod_contrato,
	         	   desc_contrato,
	         	   cod_cobertura,
				   tipo,
				   desc_cob,
				   serie,
	         	   SUM(prima),
				   SUM(comision),
				   SUM(impuesto),
				   SUM(por_pagar)
	          INTO v_cod_ramo,
			       _cod_subramo,
				   _cod_origen,
			       v_cod_contrato,
	           	   _nombre_con,
	           	   v_cobertura,
				   _tipo_cont,
				   v_desc_cobertura,
				   _serie,
	           	   v_prima,
				   _comision,
				   _impuesto, 
				   _por_pagar
	          FROM temp_produccion
			  where seleccionado = 1
	      GROUP BY cod_ramo, cod_subramo, cod_origen, cod_cobertura, desc_contrato, cod_contrato, tipo, desc_cob, serie
		  ORDER BY cod_ramo, cod_subramo, cod_origen, cod_cobertura, desc_contrato, cod_contrato, tipo, desc_cob, serie

            SELECT nombre
              INTO v_desc_ramo
              FROM prdramo
             WHERE cod_ramo = v_cod_ramo;
	
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
				   _tipo_cont,
				   v_cod_contrato,
				   _serie
	               WITH RESUME;

      END FOREACH

      DROP TABLE temp_produccion;
      DROP TABLE temp_det;

END
END PROCEDURE
