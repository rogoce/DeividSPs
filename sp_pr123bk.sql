---------------------------------------------------------------------------------
--      TOTALES DE PRODUCCION POR CONTRATO DE REASEGURO  
-- 		Realizado por Henry Giron 23/11/2009 filtros requeridos por Sr. Omar Wong
-- 		FACULTATIVO  
-- 		PRIMA SUSCRITA
-- execute PROCEDURE sp_pr123 ("001","001","2009-07","2009-09","*","*","*","*","*","*","*","*")
-- "001,003,002,010,011,012,013,014;","*","*","*",0)
---------------------------------------------------------------------------------
DROP PROCEDURE sp_pr123bk;
CREATE PROCEDURE sp_pr123bk(
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
		a_serie       CHAR(255) DEFAULT "*",
		a_fronting    SMALLINT  DEFAULT 0
		)
RETURNING CHAR(3),CHAR(3),CHAR(5),CHAR(3),DECIMAL(16,2),DECIMAL(16,2),DECIMAL(16,2),DECIMAL(16,2),DECIMAL(16,2),DECIMAL(16,2),DECIMAL(16,2),DECIMAL(16,2),CHAR(50),CHAR(50), CHAR(50), CHAR(255);

BEGIN
		DEFINE v_nopoliza                      CHAR(10);
		DEFINE v_noendoso,v_cod_contrato       CHAR(5);
		DEFINE v_cod_ramo,v_cobertura, v_clase CHAR(03);
		DEFINE v_desc_ramo, v_desc_contrato    CHAR(50);
		DEFINE v_desc_cobertura	               CHAR(100);
		DEFINE v_filtros,v_filtros1            CHAR(255);
		DEFINE _tipo                           CHAR(01);
		DEFINE v_descr_cia                     CHAR(50);
		DEFINE v_prima,v_prima1,v_prima50      DEC(16,2);
		DEFINE v_tipo_contrato                 SMALLINT;
		define _porc_impuesto				   dec(16,4);
		define _porc_comision				   dec(16,4);
		define _cuenta						   char(25);
		define _serie 						   smallint;
		define _impuesto					   dec(16,2);
		define _comision					   dec(16,2);
		define _por_pagar					   dec(16,2);
		DEFINE _cod_traspaso	 			   CHAR(5);					  
		define _traspaso		 			   smallint;
		define _tiene_comis_rea				   smallint;
		define _cantidad					   smallint;
		define _porc_cont_partic 			   dec(16,2);
		DEFINE _porc_comis_ase   			   DECIMAL(16,2);
		define _monto_reas					   dec(16,2);
		define _cod_coasegur	 			   char(3);
		define _nombre_coas					   char(50);
		define _nombre_cob					   char(50);
		define _nombre_con					   char(50);
		define _cod_subramo					   char(3);
		define _cod_origen					   char(3);
		define _cod_r                          char(3);
		define _tipo_cont                      smallint;
		define _no_unidad					   char(5);
		define _p_c_partic					   dec(16,2);
		define _p_c_partic_hay				   smallint;
		define v_existe                        smallint;
		define _prima_tot_ret                  dec(16,2);
		define _prima_sus_tot				   dec(16,2);
		define _prima_tot_ret_sum              dec(16,2);
		define _prima_tot_sus_sum              dec(16,2);
		define nivel,_nivel,_seleccionado      smallint;
		define _xnivel                         char(3);
		define v_prima70, v_prima30            decimal (16,2);
		define _comision70, _comision30        decimal (16,2);
		define _impuesto70, _impuesto30        decimal (16,2);
		define _por_pagar70, _por_pagar30      decimal (16,2);
		define _siniestro70, _siniestro30      decimal (16,2);
		define _siniestro50,_siniestro         decimal (16,2);
		define _porc_impuesto4				   dec(16,4);
		define _porc_comision4				   dec(16,4);
		DEFINE _tiene_comision				   smallint;
		define _p_50_prima					   dec(16,2);
		define _p_50_siniestro,_prima_fac      dec(16,2);
	   	define _anio_reas					   char(9);
		DEFINE _trim_reas,_tipo2,_renglon	   smallint;
		DEFINE _borderaux					   CHAR(2);
	    DEFINE _fronting,_cnt					   smallint;
		DEFINE _part_res_dist,_pagado_neto	   DECIMAL(16,2);
		DEFINE _porcentaje		  			   DEC(5,2);
		DEFINE _transaccion,_no_reclamo,_no_tranrec   char(10);
		define _cod_contrato                   char(5);
		define _sini						   dec(16,2);

		SET ISOLATION TO DIRTY READ; 	

		LET _borderaux = "04";	   -- FACULTATIVO
		select tipo into _tipo2 from reacontr where cod_contrato = _borderaux;
		CALL sp_rea002(a_periodo2,_tipo2) RETURNING _anio_reas,_trim_reas; 

--		DELETE FROM reacoret where anio = _anio_reas and trimestre = _trim_reas and borderaux = _borderaux;   -- Elimina borderaux del trimestre
--	    DELETE FROM temphg1;

		DELETE FROM reacoest where anio = _anio_reas and trimestre = _trim_reas and borderaux = _borderaux;   -- Elimina borderaux del trimestre
		DELETE FROM temphg where anio = _anio_reas and trimestre = _trim_reas and borderaux = _borderaux;     -- Elimina borderaux datos;
 	
     CALL sp_pro34(a_compania,a_agencia,a_periodo1,a_periodo2,a_codsucursal,a_codgrupo,
                   a_codagente,a_codusuario,a_codramo,a_reaseguro) RETURNING v_filtros;

     LET v_filtros = sp_rec708(
	 a_compania,
	 a_agencia,
	 a_periodo1,
	 a_periodo2,
	 a_codsucursal,
	 '*', 
	 a_codramo, --'*'
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
				serie 			 SMALLINT,
				seleccionado     SMALLINT DEFAULT 1,
				porc_comision 	 DECIMAL(16,2), 
				porc_impuesto 	 DECIMAL(16,2), 
				porc_cont_partic DECIMAL(16,2), 
				cod_coasegur 	 CHAR(3),
				tiene_comision   Smallint,
            PRIMARY KEY(cod_ramo, cod_subramo, cod_origen, cod_contrato, cod_cobertura, desc_cob,serie)) WITH NO LOG;

CREATE INDEX idx1_temp_produccion ON temp_produccion(cod_ramo);
CREATE INDEX idx2_temp_produccion ON temp_produccion(cod_subramo);
CREATE INDEX idx3_temp_produccion ON temp_produccion(cod_origen);
CREATE INDEX idx4_temp_produccion ON temp_produccion(cod_contrato);
CREATE INDEX idx5_temp_produccion ON temp_produccion(cod_cobertura);
CREATE INDEX idx6_temp_produccion ON temp_produccion(desc_cob);
CREATE INDEX idx7_temp_produccion ON temp_produccion(cod_coasegur);
CREATE INDEX idx8_temp_produccion ON temp_produccion(serie);

CREATE TEMP TABLE tmp_dist716(
		no_reclamo      CHAR(10),
		cod_coasegur	CHAR(3),
		porcentaje		DEC(5,2),
		monto_reas		DEC(16,2),
		cod_ramo        char(3),
		serie           smallint,
		seleccionado    SMALLINT  DEFAULT 1 NOT NULL,
		PRIMARY KEY (no_reclamo,cod_coasegur)
		) with no log;
CREATE INDEX xie01_tmp_dist716 ON tmp_dist716(no_reclamo);
CREATE INDEX xie02_tmp_dist716 ON tmp_dist716(cod_coasegur);


      LET v_prima        = 0;
      LET v_descr_cia    = sp_sis01(a_compania);
	  let _tipo_cont     = 0;
	  let v_desc_cobertura = "";
	  LET v_filtros1 = "";
	  LET _p_50_prima = 100;
	  LET _p_50_siniestro = 100;
	  let _pagado_neto = 0;
	  let _prima_fac   = 0;
	  let _sini = 0;

--	  set debug file to "sp_pr123.trc";	 																						 

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
		    	SELECT cod_cober_reas,
		    		   cod_contrato,
			    	   prima,
					   no_unidad
	              INTO v_cobertura,
              	   	   v_cod_contrato,
              	   	   v_prima1,
					   _no_unidad
	              FROM emifacon
	             WHERE no_poliza = v_nopoliza
	               AND no_endoso = v_noendoso
	               --AND prima <> 0

				 IF v_nopoliza = "220864" and v_noendoso = "00001" THEN
				   LET v_prima1 = 0.00;
				 END IF

				 IF a_fronting  = 1 THEN
					   SELECT fronting
					     INTO _fronting
						 FROM reacomae
					    WHERE cod_contrato = v_cod_contrato;

						if _fronting = 1 then  -- es fronting
						else
						   continue foreach;
						end if
				 END IF;

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

				if v_tipo_contrato <> 3 then  -- trabajar solo facultativo
					continue foreach;
				end if	 

				let _tipo_cont = 2;
							 
                let v_prima      = v_prima1;
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

				 let _cuenta = "";

			     SELECT nombre
			       INTO v_desc_ramo
			       FROM prdramo
			      WHERE cod_ramo = v_cod_ramo;

			     SELECT nombre
			       INTO _nombre_cob
			       FROM reacobre
			      WHERE cod_cober_reas = v_cobertura;

				  let _prima_fac = 0;

				  foreach

					 		select porc_partic_reas,
					 			   porc_comis_fac,
					 			   porc_impuesto,
					 			   cod_coasegur,
								   monto_comision,
								   monto_impuesto,
								   prima
					 		  into _porc_cont_partic,
					 		   	   _porc_comis_ase,
					 			   _porc_impuesto,
					 			   _cod_coasegur,
								   _comision,
								   _impuesto,
								   _prima_fac
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

							if _comision is null then
								let _comision = 0;
							end if

							if _impuesto is null then
								let _impuesto = 0;
							end if

							if v_prima = 0 then
								let v_prima	= _prima_fac;
							else
				                let v_prima = v_prima1;
							end if

							if _porc_cont_partic = 0 then
								let _porc_cont_partic = 100;
							end if
					 		let _monto_reas = v_prima * _porc_cont_partic / 100;
					 		--let _impuesto   = _monto_reas * _porc_impuesto / 100;
					 		--let _comision   = _monto_reas * _porc_comis_ase / 100;
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
					           and serie         = _serie;
--					           and cod_coasegur  = _cod_coasegur;

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
											 _porc_comision,
				 	                         _porc_impuesto,
				 	                         _porc_cont_partic,
				 	                         _cod_coasegur,
				 	                         _tiene_comis_rea);
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
					                  and serie         = _serie;
--					                  and cod_coasegur  = _cod_coasegur;

					 		end if
			                let v_prima = v_prima1;

				  end foreach

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
	 where seleccionado = 1

		let _p_c_partic = 0;
		let _p_c_partic_hay = 0;

		select traspaso,tiene_comision
		  into _traspaso,_tiene_comision
		  from reacocob
		 where cod_contrato   = v_cod_contrato
		   and cod_cober_reas = v_cobertura;

		Select tipo_contrato, serie
		  Into v_tipo_contrato,_serie
		  From reacomae
		 Where cod_contrato = v_cod_contrato;

		LET _seleccionado = 0;

	    if v_tipo_contrato = 3 then   --facultativos
			LET _seleccionado = 1;
		end if
		
		if _comision is null then
			let _comision = 0;
		end if	  

		if _impuesto is null then
			let _impuesto = 0;
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
		         _seleccionado,
		         _anio_reas,
				 _trim_reas,
				 _borderaux);

END FOREACH

FOREACH

   select serie,cod_coasegur,tipo_contrato,porc_cont_partic,porc_comision,porc_impuesto,cod_ramo,cod_contrato,cod_cobertura,sum(prima),comision,impuesto
     into _serie,_cod_coasegur,v_tipo_contrato,_porc_cont_partic,_porc_comision,_porc_impuesto,v_cod_ramo,v_cod_contrato,v_cobertura,v_prima,_comision,_impuesto
     from temphg
    Where seleccionado = 1
	  and anio      = _anio_reas
	  and trimestre = _trim_reas
	  and borderaux = _borderaux 
    group by serie,cod_coasegur,tipo_contrato,porc_cont_partic,porc_comision,porc_impuesto,cod_ramo,cod_contrato,cod_cobertura,comision,impuesto
  
   if v_prima = 0 and _comision = 0 and _impuesto = 0 then
	continue foreach;
   end if


	 { 	SELECT sum(t.pagado_neto)
		  INTO _siniestro	
		  FROM tmp_sinis t, reacomae r
		 where t.cod_ramo      = v_cod_ramo	
	       and r.cod_contrato  = t.cod_contrato 
		   and r.serie         = _serie 
		   and t.seleccionado  = 1 
		   and t.tipo_contrato in('3');

		if _siniestro is null then
		   let _siniestro = 0;
	    end if 

		foreach

			SELECT transaccion
			  INTO _transaccion	
			  FROM tmp_sinis t, reacomae r
			 where t.cod_ramo      = v_cod_ramo	
		       and r.cod_contrato  = t.cod_contrato 
			   and r.serie         = _serie 
			   and t.seleccionado  = 1 
			   and t.tipo_contrato in('3')

		    select no_tranrec
			  into _no_tranrec
		      from rectrmae
			 where transaccion = _transaccion;
			
		    select count(*)
			  into _cnt
		      from rectrref
			 where cod_contrato = v_cod_contrato
			   and cod_coasegur = _cod_coasegur
			   and no_tranrec   = _no_tranrec;

			if _cnt > 0 then
				exit foreach;
			else
			   let _siniestro = 0;
			end if

		end foreach	}

		let v_clase = v_cod_ramo;
		let _xnivel = '003';
			
		LET _p_50_prima     = 100;
		LET _p_50_siniestro = 100;

		LET v_prima50 =  (v_prima * _p_50_prima)/100;
		--LET _siniestro50 =  (_siniestro * _p_50_siniestro)/100;

		LET _por_pagar = v_prima50 - _comision - _impuesto ;

	   	BEGIN
		ON EXCEPTION IN(-239)
			UPDATE reacoest
			   SET prima         = prima + v_prima50, 
				   comision      = comision + _comision, 
				   impuesto      = impuesto + _impuesto, 
				   prima_neta    = prima_neta + _por_pagar
--				   siniestro     = siniestro + _siniestro 
			 WHERE cod_coasegur	 = _cod_coasegur
			   AND cod_contrato  = _serie
			   AND cod_cobertura = _xnivel
			   AND cod_ramo      = v_cod_ramo
			   and cod_clase     = v_clase 
			   and anio          = _anio_reas
			   and trimestre     = _trim_reas
			   and borderaux     = _borderaux;

		END EXCEPTION 	

	    INSERT INTO reacoest
		VALUES (_cod_coasegur,
		        v_cod_ramo,
				_serie,
				_xnivel,
				v_prima50, 
				_comision, 
				_impuesto, 
				_por_pagar,
				0,	 --_siniestro
				0,
				0,
				0,
				v_clase,
				_anio_reas,
				_trim_reas,
				_borderaux);
	  	END

END FOREACH

foreach	

	  	SELECT t.transaccion,
	  		   t.pagado_neto,
			   t.no_reclamo,
			   t.cod_ramo,
			   t.cod_contrato
		  INTO _transaccion,
		       _pagado_neto,
			   _no_reclamo,
			   v_cod_ramo,
			   _cod_contrato
		  FROM tmp_sinis t, reacomae r
		 where r.cod_contrato  = t.cod_contrato
		   and t.seleccionado  = 1
		   and t.tipo_contrato in('3')

		foreach
	        select no_tranrec
	          into _no_tranrec
	          from rectrmae
	         where transaccion = _transaccion
		exit foreach;
        end foreach 

        select serie
          into _serie
          from reacomae
         where cod_contrato = _cod_contrato;

		foreach
			 select orden
			   into _renglon
			   from rectrrea
			  where no_tranrec    = _no_tranrec
			    and tipo_contrato = 3

			foreach
				select cod_coasegur,porc_partic_reas
				  into _cod_coasegur,_porcentaje
				  from rectrref
				 where no_tranrec = _no_tranrec 
				   and orden      = _renglon

				if _porcentaje is null then
					let _porcentaje = 0.00;
				end if

				if _porcentaje <> 0 then
					LET _part_res_dist = _pagado_neto * _porcentaje / 100;
				else
					LET _part_res_dist = 0;
				end if	

				BEGIN
				ON EXCEPTION IN(-239)
					UPDATE tmp_dist716
					   SET monto_reas   = monto_reas + _part_res_dist
					 WHERE no_reclamo   = _no_reclamo 
					   AND cod_coasegur = _cod_coasegur;
				END EXCEPTION

					INSERT INTO tmp_dist716(
					no_reclamo,
					cod_coasegur,
					porcentaje,
					monto_reas,
					cod_ramo,
					serie)
					VALUES(
					_no_reclamo,
					_cod_coasegur,
					_porcentaje,
					_part_res_dist,
					v_cod_ramo,
					_serie);

				END 	
			end foreach
		end foreach
end foreach

foreach
	select cod_coasegur,serie,cod_ramo
	  into _cod_coasegur,_serie,v_cod_ramo
	  from tmp_dist716
	 where porcentaje <> 0
	 group by cod_coasegur,serie,cod_ramo

    select count(*)
	  into _cnt
	  from reacoest
	 where anio         = _anio_reas
	   and trimestre    = _trim_reas
	   and borderaux    = _borderaux
	   and cod_contrato = _serie
	   and cod_coasegur = _cod_coasegur
	   and cod_ramo     = v_cod_ramo;

    if _cnt = 0 then

	  foreach
		select monto_reas,
		       porcentaje,
		       cod_ramo
		  into _siniestro,
		       _porcentaje,
			   v_cod_ramo
          from tmp_dist716
		 where porcentaje   <> 0
		   and serie        = _serie
		   and cod_coasegur = _cod_coasegur

	    INSERT INTO reacoest
		VALUES (_cod_coasegur,
		        v_cod_ramo,
				_serie,
				'003',
				0, 
				0, 
				0, 
				0,
				_siniestro,
				0,
				0,
				_porcentaje,
				v_cod_ramo,
				_anio_reas,
				_trim_reas,
				_borderaux);
	  end foreach
	else
		foreach

			select sum(monto_reas),
			       cod_ramo
			  into _siniestro,
			       v_cod_ramo
			  from tmp_dist716
			 where porcentaje   <> 0
			   and serie        = _serie
			   and cod_coasegur = _cod_coasegur
			 group by cod_ramo

		    select sum(siniestro)
			  into _sini
			  from reacoest
			 where anio         = _anio_reas
			   and trimestre    = _trim_reas
			   and borderaux    = _borderaux
			   and cod_contrato = _serie
			   and cod_coasegur = _cod_coasegur
			   and cod_ramo     = v_cod_ramo;

			if abs(_sini) > 0 then
			else

				 Update reacoest
				    set siniestro  = siniestro + _siniestro
				  where anio       = _anio_reas
				    and trimestre  = _trim_reas
				    and borderaux  = _borderaux
				    and cod_coasegur = _cod_coasegur
				    and cod_contrato = _serie
				    and cod_ramo     = v_cod_ramo;
			end if
		end foreach

	end if
end foreach

Update reacoest
   set participar  = prima_neta - siniestro,
  	   p_partic    = prima,
       resultado   = siniestro  
 where anio      = _anio_reas
   and trimestre = _trim_reas
   and borderaux = _borderaux;

--trace off;
FOREACH
     SELECT cod_coasegur,
			cod_clase,
			cod_contrato,
			cod_cobertura,
			sum(p_partic),
			sum(prima),
			sum(comision),
			sum(impuesto),
			sum(prima_neta),
   			sum(resultado),
			sum(siniestro),
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
			_prima_sus_tot,
			_prima_tot_ret	
       FROM reacoest
	  where anio      = _anio_reas
	    and trimestre = _trim_reas
	    and borderaux = _borderaux 
	  group by cod_coasegur,cod_clase,cod_contrato,cod_cobertura


	 SELECT nombre
	   INTO v_desc_ramo
	   FROM prdramo
	  WHERE cod_ramo = v_cod_ramo;

	 select nombre
	   into v_desc_contrato
	   from emicoase
	  where cod_coasegur = _cod_coasegur;

  {	if (v_prima + _comision + _impuesto + _por_pagar + _siniestro) = 0 then
		continue foreach;
	end if}

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
			v_filtros		  --16
            WITH RESUME;

END FOREACH

DROP TABLE temp_produccion;
DROP TABLE temp_det;
DROP TABLE tmp_sinis;
DROP TABLE tmp_dist716;

END
END PROCEDURE  