------------------------------------------------
--      TOTALES DE PRODUCCION POR             --
--         CONTRATO DE REASEGURO              --
---  Yinia M. Zamora - octubre 2000 - YMZM	  --
---  Ref. Power Builder - d_sp_pro40		  --
--- Modificado por Armando Moreno 19/01/2002; -- la parte de los tipo de contratos
------------------------------------------------
DROP PROCEDURE sp_pr992;
CREATE PROCEDURE sp_pr992(a_compania CHAR(03),a_agencia CHAR(03),a_periodo1 CHAR(07),a_periodo2 CHAR(07),a_codsucursal CHAR(255) DEFAULT "*",a_codgrupo  CHAR(255) DEFAULT "*",a_codagente CHAR(255) DEFAULT "*",a_codusuario CHAR(255) DEFAULT "*",a_codramo  CHAR(255) DEFAULT "*",a_reaseguro   CHAR(255) DEFAULT "*"	)
RETURNING CHAR(3),CHAR(3),CHAR(5),CHAR(3),DECIMAL(16,2),DECIMAL(16,2),DECIMAL(16,2),DECIMAL(16,2),DECIMAL(16,2),DECIMAL(16,2),DECIMAL(16,2),DECIMAL(16,2),CHAR(50),CHAR(50), CHAR(50);
   BEGIN
      DEFINE v_nopoliza                      CHAR(10);
      DEFINE v_noendoso,v_cod_contrato       CHAR(5);
      DEFINE v_cod_ramo,v_cobertura, v_clase CHAR(03);
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
	  define _siniestro						 dec(16,2);

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
	  DEFINE _tiene_comision				 SMALLINT;
	  define _p_c_partic					 dec(5,2);
	  define _p_c_partic_hay				 smallint;
	  define v_existe                        smallint;

	   define nivel,_nivel                   smallint;
	   define _xnivel                        char(3);
	   define v_prima70, v_prima30           decimal (16,2);
	   define _comision70, _comision30       decimal (16,2);
	   define _impuesto70, _impuesto30       decimal (16,2);
	   define _por_pagar70, _por_pagar30     decimal (16,2);
	   define _siniestro70, _siniestro30     decimal (16,2);

	  define _porc_impuesto4				 dec(7,4);
	  define _porc_comision4				 dec(7,4);


     SET ISOLATION TO DIRTY READ;

	 DELETE FROM reacoest;
	 DELETE FROM temphg;

--     set debug file to "sp_pr992.trc";	  	  	  	

     LET _ano =  a_periodo1[1,4];

     LET v_descr_cia  = sp_sis01(a_compania);

     CALL sp_pro307(a_compania,a_agencia,a_periodo1,a_periodo2,a_codsucursal,a_codgrupo,
                   a_codagente,a_codusuario,a_codramo,a_reaseguro) RETURNING v_filtros;

     CALL sp_pro314(a_compania,a_agencia,a_periodo1,a_periodo2,a_codsucursal,a_codgrupo,
                   a_codagente,a_codusuario,a_codramo,a_reaseguro) RETURNING v_filtros;

	-- Cargar el Incurrido
		LET v_filtros = sp_rec61(
		a_compania,
		a_agencia,
		a_periodo1,
		a_periodo2,
		a_codsucursal,
		'*', 
		'*',    ---a_ramo,
		'*', 
		'*', 
		'*', 
		'*',
		'*'    ---a_contrato
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
            PRIMARY KEY(cod_ramo, cod_subramo, cod_origen, cod_contrato, cod_cobertura, desc_cob)) WITH NO LOG;

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

      LET v_prima        = 0;
	  let _cod_subramo   = "001";
	  let _prima_tot_ret = 0;
	  let _prima_sus_tot = 0;
	  let _p_sus_tot     = 0;
	  let _p_sus_tot_sum = 0;
	  let _tipo_cont     = 0;

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
					                    0,
					                    0,
					                    0,
					                    '999',
					                    _tiene_comis_rea);
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
				 	                         _porc_comision,
				 	                         _porc_impuesto,
				 	                         _porc_cont_partic,
				 	                         _cod_coasegur,
				 	                         _tiene_comis_rea);
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

				 		end foreach

				  end if
			  end if

         END FOREACH

END FOREACH

-- Carga Temporal contrato por ramos.
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
		cod_coasegur
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
         _cod_coasegur				
	from temp_produccion

		let  _p_c_partic = 0;
		let  _p_c_partic_hay = 0;

		select traspaso,tiene_comision
		into _traspaso,_tiene_comision
		from reacocob
		where cod_contrato   = v_cod_contrato
		and cod_cober_reas = v_cobertura;

		Select tipo_contrato, serie
		Into v_tipo_contrato,_serie
		From reacomae
		Where cod_contrato = v_cod_contrato;

        if _serie < 2007  then 
			CONTINUE FOREACH;
		end if

        if (_cod_coasegur <> "050" and _cod_coasegur <> "063" and _cod_coasegur <> "076"  and _cod_coasegur <> "042")  then
			CONTINUE FOREACH;
		end if

		if v_cod_ramo = "001" and v_tipo_contrato <> 7 then 
			CONTINUE FOREACH;
		end if

		if v_cod_ramo = "006" and v_tipo_contrato <> 5 then 
			CONTINUE FOREACH;
		end if

		if (v_cod_ramo = "010" or v_cod_ramo = "011" or v_cod_ramo = "013"  or v_cod_ramo = "014")  and v_tipo_contrato <> 7 then 
			CONTINUE FOREACH;
		end if
		if (v_cod_ramo = "008" or v_cod_ramo = "080")  and v_tipo_contrato <> 7 then 
			CONTINUE FOREACH;
		end if
		if (v_cod_ramo = "004" or v_cod_ramo = "016" or v_cod_ramo = "019")  and v_tipo_contrato <> 5 then 
			CONTINUE FOREACH;
		end if

		if v_cod_contrato = "00585" or v_cod_contrato = "00584" then 
			CONTINUE FOREACH;
		end if

		LET nivel = 1;

		if _porc_cont_partic = 100 then
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
		         nivel); 					

END FOREACH

--trace on;
-- Carga reacoest
-- Clasificasion - 1-R.C.G.(006), 2-Incendio (001,003)70%, 3-Terremoto(001,003)30%, 4-Ramos Tecnicos(010,011,014),
--    5-Fianzas(008,080), 6-Acc. Personales(004), 7-Vida Ind/Col(016,019)]


FOREACH
   select serie,cod_ramo, sum(prima)
   into _serie,v_cod_ramo, v_prima
   from temphg
   Where serie > 2007 and cod_coasegur in ('050','063','076','042') 
   group by cod_ramo,serie


			SELECT sum(t.pagado_neto)  -- sum(reserva_neto) 	
			INTO _siniestro	
			FROM tmp_sinis t, reacomae r
			where t.cod_ramo = v_cod_ramo	
			and   r.cod_contrato = t.cod_contrato
			and   r.serie = _serie and t.seleccionado = 1 and t.tipo_contrato not in ('3','1') ; 
 

			if _siniestro is null then
			   let _siniestro = 0  ;
		    end if

			if v_cod_ramo = '006' then 
				 let v_clase = '1' ;
			end if

			if v_cod_ramo = '001' or v_cod_ramo = '003' then 
				 let v_clase = '2' ;
			end if					

			if v_cod_ramo = '010' or v_cod_ramo = '011' or v_cod_ramo = '013'  or v_cod_ramo = '014' then 
				 let v_clase = '4' ;
			end if

			if v_cod_ramo = '008' or v_cod_ramo = '080' then 
				 let v_clase = '5' ;
			end if
			if v_cod_ramo = '004' then 
				 let v_clase = '6' ;
			end if
			if v_cod_ramo = '016' or v_cod_ramo = '019' then 
				 let v_clase = '7' ;
			end if

			FOREACH 
				select distinct cod_coasegur,porc_cont_partic,porc_comision,porc_impuesto
				into  _cod_coasegur,_porc_cont_partic,_porc_comision,_porc_impuesto
				from temphg
				Where serie > 2007  and cod_coasegur in ('050','063','076','042')  and cod_ramo = v_cod_ramo

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

					LET _comision  = v_prima * _porc_comision4 ;
					LET _impuesto  = v_prima * _porc_impuesto4 ;
				
					LET _por_pagar = v_prima - _comision - _impuesto ;

					if _porc_cont_partic < 100 then 
					   let _xnivel = '1';
  				    else
					   let _xnivel = '2';
				    end if

					if v_clase = '2' then

						LET v_prima70 = v_prima * 0.70 ;
						LET v_prima30 =	v_prima * 0.30 ;

						LET _comision70 = v_prima70 * _porc_comision4 * 1 ;

						if 	_cod_coasegur = '063' then
							LET _comision30 = v_prima30 * 0.225 ;
						else
							LET _comision30 = v_prima30 * 0.20 ;
						end if

						LET _impuesto70 = _impuesto * 0.70 ;
						LET _impuesto30 = _impuesto * 0.30 ;
						LET _por_pagar70 = _por_pagar * 0.70 ;
						LET _por_pagar30 = _por_pagar * 0.30 ;
						LET _siniestro70 = _siniestro * 1 ;
						LET _siniestro30 = _siniestro * 0 ;	 

						LET _por_pagar70 = v_prima70 - _comision70 - _impuesto70 ;
						LET _por_pagar30 = v_prima30 - _comision30 - _impuesto30 ;

						BEGIN
						ON EXCEPTION IN(-239)
							UPDATE reacoest
							   SET prima = prima + v_prima70, 
							   comision = comision + _comision70, 
							   impuesto = impuesto + _impuesto70, 
							   prima_neta = prima_neta + _por_pagar70, 
							   siniestro = siniestro + _siniestro70 
							 WHERE cod_coasegur	= _cod_coasegur
							 AND cod_contrato = _serie
							 AND cod_cobertura  = _xnivel
							 AND p_partic = _porc_cont_partic
							 AND cod_ramo = '2' ;
						END EXCEPTION 	

					    INSERT INTO reacoest(
								cod_coasegur,
								cod_ramo,
								cod_contrato,
								cod_cobertura,
								prima,
								comision,
								impuesto,
								prima_neta,
								siniestro,
								resultado,
								participar,
								p_partic,
								cod_clase,
								anio,
								trimestre,
								borderaux)
						VALUES (_cod_coasegur,
						        '2',
								_serie,
								_xnivel,
								v_prima70, 
								_comision70, 
								_impuesto70, 
								_por_pagar70,
								_siniestro70,
								0,
								0,
								_porc_cont_partic) ;
						END

						BEGIN
						ON EXCEPTION IN(-239)
							UPDATE reacoest
							   SET prima = prima + v_prima30, 
							   comision = comision + _comision30, 
							   impuesto = impuesto + _impuesto30, 
							   prima_neta = prima_neta + _por_pagar30, 
							   siniestro = siniestro + _siniestro30 
							 WHERE cod_coasegur	= _cod_coasegur
							 AND cod_contrato = _serie
							 AND cod_cobertura  = _xnivel
							 AND p_partic = _porc_cont_partic
							 AND cod_ramo = '3' ;
						END EXCEPTION 	

					    INSERT INTO reacoest
						VALUES (_cod_coasegur,
						        '3',
								_serie,
								_xnivel,
								v_prima30, 
								_comision30, 
								_impuesto30, 
								_por_pagar30,
								_siniestro30,
								0,
								0,
								_porc_cont_partic) ;
						END

					else

					   	BEGIN
						ON EXCEPTION IN(-239)
							UPDATE reacoest
							   SET prima = prima + v_prima, 
							   comision = comision + _comision, 
							   impuesto = impuesto + _impuesto, 
							   prima_neta = prima_neta + _por_pagar, 
							   siniestro = siniestro + _siniestro 
							 WHERE cod_coasegur	= _cod_coasegur
							 AND cod_contrato = _serie
							 AND cod_cobertura  = _xnivel
							 AND p_partic = _porc_cont_partic
							 AND cod_ramo = v_clase ;
						END EXCEPTION 	

					    INSERT INTO reacoest
						VALUES (_cod_coasegur,
						        v_clase,
								_serie,
								_xnivel,
								v_prima, 
								_comision, 
								_impuesto, 
								_por_pagar,
								_siniestro,
								0,
								0,
								_porc_cont_partic) ;

					  	END
					end if
			END FOREACH
END FOREACH		


Update reacoest
  set resultado = prima_neta - siniestro, 
      participar = (prima_neta - siniestro) * (p_partic/100) ;


--trace off;
FOREACH
     SELECT cod_coasegur,
			cod_ramo,
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
         FROM  reacoest	
		 group by cod_coasegur,	cod_ramo,cod_contrato,cod_cobertura,p_partic

{            SELECT nombre
              INTO v_desc_ramo
              FROM prdramo
             WHERE cod_ramo = v_cod_ramo;}

-- Clasificasion - 1-R.C.G.(006), 2-Incendio (001,003)70%,3-Terremoto(001,003)30%,4-Ramos Tecnicos(010,011,014),
--    5-Fianzas(008,080),6-Acc. Personales(004),7-Vida Ind/Col(016,019)]

			if v_cod_ramo = '1' then
			   LET v_desc_ramo = 'R.C.G.' ;
			end if
			if v_cod_ramo = '2' then
			   LET v_desc_ramo = 'Incendio' ;
			end if
			if v_cod_ramo = '3' then
			   LET v_desc_ramo = 'Terremoto' ;
			end if
			if v_cod_ramo = '4' then
			   LET v_desc_ramo = 'Ramos Tecnicos' ;
			end if
			if v_cod_ramo = '5' then
			   LET v_desc_ramo = 'Fianzas' ;
			end if
			if v_cod_ramo = '6' then
			   LET v_desc_ramo = 'Acc. Personales' ;
			end if
			if v_cod_ramo = '7' then
			   LET v_desc_ramo = 'Vida Ind/Col' ;
			end if
			select nombre
			into v_desc_contrato
			from emicoase
			where cod_coasegur = _cod_coasegur	;


	         RETURN  _cod_coasegur,	  --01
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
					v_descr_cia		  --15
	                WITH RESUME;


END FOREACH

DROP TABLE temp_produccion;
DROP TABLE temp_det;
DROP TABLE temp_det1;
DROP TABLE tmp_priret;
DROP TABLE tmp_sinis;

END

END PROCEDURE  
