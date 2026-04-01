-----------------------------------------------------------
--   TOTALES DE PRODUCCION POR CONTRATO DE REASEGURO     --
---  Realizado por: HERHY GIRON  01/10/2009
---  Ref. Power Builder - d_sp_pro40_crit      d_prod_sp_pr850_dw1
---  Modificado por Armando Moreno 19/01/2002;  la parte de los tipo de contratos
--   execute procedure sp_pr850("001","001","2009-07","2009-09","*","*","*","*","*","*")  sp_pr850
-----------------------------------------------------------
DROP PROCEDURE sp_pr126;
CREATE PROCEDURE sp_pr126(a_compania CHAR(03),a_agencia CHAR(03),a_periodo1 CHAR(07),a_periodo2 CHAR(07),a_codsucursal CHAR(255) DEFAULT "*",a_codgrupo  CHAR(255) DEFAULT "*",a_codagente CHAR(255) DEFAULT "*",a_codusuario CHAR(255) DEFAULT "*",a_codramo  CHAR(255) DEFAULT "*",a_reaseguro   CHAR(255) DEFAULT "*"	)
RETURNING CHAR(3),CHAR(3),CHAR(5),CHAR(3),DECIMAL(16,2),DECIMAL(16,2),DECIMAL(16,2),DECIMAL(16,2),DECIMAL(16,2),DECIMAL(16,2),DECIMAL(16,2),DECIMAL(16,2),CHAR(50),CHAR(50), CHAR(50);
   BEGIN 
		DEFINE v_nopoliza                      	CHAR(10);
		DEFINE v_noendoso,v_cod_contrato       	CHAR(5);
		DEFINE v_cod_ramo,v_cobertura, v_clase 	CHAR(03);
		DEFINE v_desc_ramo, v_desc_contrato    	CHAR(50);
		DEFINE v_desc_cobertura	             	CHAR(100);
		DEFINE v_filtros,v_filtros1            	CHAR(255);
		DEFINE _tipo                           	CHAR(01);
		DEFINE v_descr_cia                     	CHAR(50);
		DEFINE v_prima                		 	DEC(16,2);
		DEFINE v_prima1                		 	DEC(16,2);
		DEFINE v_tipo_contrato                 	SMALLINT;

		define _porc_impuesto					dec(16,2);
		define _porc_comision					dec(16,2);
		define _cuenta						 	char(25);
		define _serie 						 	smallint;
		define _impuesto						dec(16,2);
		define _comision						dec(16,2);
		define _por_pagar						dec(16,2);
		define _siniestro						dec(16,2);

		DEFINE _cod_traspaso	 				CHAR(5);
		define _traspaso		 				smallint;
		define _tiene_comis_rea				 	smallint;
		define _cantidad						smallint;
		define _tipo_cont                      	smallint;
			
		define _porc_cont_partic 				dec(5,2);
		DEFINE _porc_comis_ase   				dec(5,2);
		define _monto_reas					 	dec(16,2);
		define v_prima_suscrita				 	dec(16,2);
		define _cod_coasegur	 				char(3);
		define _nombre_coas					 	char(50);
		define _nombre_cob					 	char(50);
		define _nombre_con					 	char(50);
		define _cod_subramo					 	char(3);
		define _cod_origen						char(3);
		define _prima_tot_ret                  	dec(16,2);
		define _prima_sus_tot					dec(16,2);
		define _prima_tot_ret_sum              	dec(16,2);
		define _prima_tot_sus_sum              	dec(16,2);
		define _no_cambio						smallint;
		define _no_unidad						char(5);
		define v_prima_cobrada           		dec(16,2);
		define _porc_partic_coas				dec(7,4);
		define _fecha						    date;
		define _porc_partic_prima				dec(9,6);
		define _p_sus_tot						DEC(16,2);
		define _p_sus_tot_sum					DEC(16,2);
		DEFINE _ano                           	SMALLINT;
		define _tot_comision 					dec(16,2);
		define _tot_impuesto 					dec(16,2);
		define _tot_prima_neta					dec(16,2);
		DEFINE _tiene_comision					SMALLINT;
		define _p_c_partic					 	dec(5,2);
		define _p_c_partic_hay				 	smallint;
		define v_existe                       	smallint;

		define nivel,_nivel                   	smallint;
		define _xnivel                        	char(3);
		define v_prima70, v_prima30           	dec(16,2);
		define _comision70, _comision30       	dec(16,2);
		define _impuesto70, _impuesto30       	dec(16,2);
		define _por_pagar70, _por_pagar30     	dec(16,2);
		define _siniestro70, _siniestro30     	dec(16,2);

		define _porc_impuesto4				 	dec(7,4);
		define _porc_comision4				 	dec(7,4);

		DEFINE _anio_reas						Char(9);
		DEFINE _trim_reas						Smallint;
		DEFINE _borderaux						CHAR(2);
		define _ramo_sis,_tipo2					Smallint;

		SET ISOLATION TO DIRTY READ;
		LET _borderaux = "02";	    -- Run Off -- Prima suscrita
		select tipo into _tipo2 from reatrim where cod_contrato = _borderaux;
		CALL sp_rea002(a_periodo2,_tipo2) RETURNING _anio_reas,_trim_reas; 

--		DELETE FROM reacoprs where anio = _anio_reas and trimestre = _trim_reas and borderaux = _borderaux;   -- Elimina borderaux del trimestre
--		DELETE FROM temphg1 where anio = _anio_reas and trimestre = _trim_reas and borderaux = _borderaux;    -- Elimina borderaux datos

		DELETE FROM reacoret where anio = _anio_reas and trimestre = _trim_reas and borderaux = _borderaux;   -- Elimina borderaux del trimestre
		DELETE FROM temphg1 where anio = _anio_reas and trimestre = _trim_reas and borderaux = _borderaux;    -- Elimina borderaux datos


		LET _ano =  a_periodo1[1,4];

		LET v_descr_cia  = sp_sis01(a_compania);

		CALL sp_pro34(a_compania,a_agencia,a_periodo1,a_periodo2,a_codsucursal,a_codgrupo,
		               a_codagente,a_codusuario,a_codramo,a_reaseguro) RETURNING v_filtros;

--		LET v_filtros = sp_rec61(
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
            PRIMARY KEY(cod_ramo, cod_subramo, cod_origen, cod_contrato, cod_cobertura, desc_cob)) WITH NO LOG;

CREATE INDEX idx1_temp_produccion ON temp_produccion(cod_ramo);
CREATE INDEX idx2_temp_produccion ON temp_produccion(cod_subramo);
CREATE INDEX idx3_temp_produccion ON temp_produccion(cod_origen);
CREATE INDEX idx4_temp_produccion ON temp_produccion(cod_contrato);
CREATE INDEX idx5_temp_produccion ON temp_produccion(cod_cobertura);
CREATE INDEX idx6_temp_produccion ON temp_produccion(desc_cob);
CREATE INDEX idx7_temp_produccion ON temp_produccion(cod_coasegur);
CREATE INDEX idx8_temp_produccion ON temp_produccion(serie);

LET v_prima        	 = 0;
LET v_descr_cia    	 = sp_sis01(a_compania);
let _tipo_cont     	 = 0;
let v_desc_cobertura = "";

--set debug file to "sp_pr126.trc";
	 																						 
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
			                    1,
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
									 _serie,
			                    	 1 ,
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
				let _porc_cont_partic = 100;
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
			                      1,
			                      _porc_comision,
		 	                         _porc_impuesto,
		 	                         _porc_cont_partic,
		 	                         _cod_coasegur,
		 	                         _tiene_comis_rea);
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
			           and desc_cob      = _nombre_cob	;
-- 		               and no_unidad     = _no_unidad ;

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
			                    	 0,
				                    0,
				                    0,
				                    '999',
				                    _tiene_comis_rea);
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
			                  and desc_cob      = v_desc_cobertura;

			 		end if

		        end foreach

		  end if	

		 end if

 END FOREACH

END FOREACH
-- trace on;
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
   Where cod_coasegur in ( "030","051","072","042","034","063")
--     and cod_ramo in ("008")

		let  _p_c_partic = 0;
		let  _p_c_partic_hay = 0;

		select traspaso,tiene_comision
		into _traspaso,_tiene_comision
		from reacocob
		where cod_contrato = v_cod_contrato
		and cod_cober_reas = v_cobertura;

		Select tipo_contrato, serie
		Into v_tipo_contrato,_serie
		From reacomae
		Where cod_contrato = v_cod_contrato;

        if _serie > 2007  then 
			CONTINUE FOREACH;
		end if

        if (_cod_coasegur <> "030" and _cod_coasegur <> "051" and _cod_coasegur <> "072" and _cod_coasegur <> "042" and _cod_coasegur <> "034" and _cod_coasegur <> "063")  then
			CONTINUE FOREACH;
		end if

		if v_cod_ramo = "001" and v_tipo_contrato <> 7 then 
			CONTINUE FOREACH;
		end if

		if v_cod_ramo = "006" and v_tipo_contrato <> 5 then 
			CONTINUE FOREACH;
		end if

		select ramo_sis
		  into _ramo_sis
		  from prdramo
		 where cod_ramo = v_cod_ramo;

		if (_ramo_sis = 99) and (v_tipo_contrato <> 7 and v_tipo_contrato <> 5) then 
			CONTINUE FOREACH;
		end if
		if (v_cod_ramo = "008" or v_cod_ramo = "080")  and (v_tipo_contrato <> 7 and v_tipo_contrato <> 5) then 
			CONTINUE FOREACH;
		end if
		if (v_cod_ramo = "004" or v_cod_ramo = "016" or v_cod_ramo = "019")  and v_tipo_contrato <> 5 then 
			CONTINUE FOREACH;
		end if

		let _cantidad = 0;

		SELECT count(*)
		INTO _cantidad
          FROM reacomae
          where lower(nombre) like ('%facilidad%')	  -- Excluyendo facilidad car e incendio
			and cod_contrato = v_cod_contrato ;

		if _cantidad is null then
		   let _cantidad = 0;
		end if

		if _cantidad <> 0 then 
			CONTINUE FOREACH;
		end if

{		if v_cod_contrato = "00585" or v_cod_contrato = "00584" then 	   -- excluyendo facilidad car e incendio
			CONTINUE FOREACH;
		end if}

		LET nivel = 1;

		if _porc_cont_partic = 100 then
			LET nivel = 2;
 		else
			LET nivel = 1;
		end if

		if v_tipo_contrato = 1 then 
			CONTINUE FOREACH;
		end if

		INSERT INTO temphg1
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
				 _borderaux) ;

END FOREACH

--trace on;
-- Carga reacoprs
-- Clasificasion - 1-R.C.G.(006), 2-Incendio (001,003)70%, 3-Terremoto(001,003)30%, 4-Ramos Tecnicos(010,011,014),
--    5-Fianzas(008,080), 6-Acc. Personales(004), 7-Vida Ind/Col(016,019)]

FOREACH
   select serie,cod_ramo,cod_contrato,sum(prima)
   into _serie,v_cod_ramo,v_cod_contrato,v_prima
   from temphg1
   Where serie <= 2007 and cod_coasegur in ( "030","051","072","042","034","063") 
	and anio      = _anio_reas
	and trimestre = _trim_reas
	and borderaux = _borderaux 
   group by cod_ramo,serie,cod_contrato


			SELECT sum(t.pagado_neto)  -- sum(reserva_neto) 	
			INTO _siniestro	
			FROM tmp_sinis t, reacomae r
			where t.cod_ramo = v_cod_ramo	
			and   r.cod_contrato = t.cod_contrato
			and   r.serie = _serie and t.seleccionado = 1 and t.tipo_contrato not in ('3','1') ;  

			if _siniestro is null then
			   let _siniestro = 0  ;
		    end if

{			let v_clase = '004' ;
			if v_cod_ramo = '006' then 
				 let v_clase = '001' ;
			end if }

			if v_cod_ramo = '001' or v_cod_ramo = '003' then 
				 let v_clase = '001' ;
			 else
				 let v_clase = v_cod_ramo ;
			end if					


{			select ramo_sis
			  into _ramo_sis
			  from prdramo
			 where cod_ramo = v_cod_ramo;		

			if _ramo_sis = 99 then 
				 let v_clase = '004' ;
			end if

			if v_cod_ramo = '008' or v_cod_ramo = '080' then 
				 let v_clase = '005' ;
			end if
			if v_cod_ramo = '004' then 
				 let v_clase = '006' ;
			end if
			if v_cod_ramo = '016' or v_cod_ramo = '019' then 
				 let v_clase = '007' ;
			end if }


			FOREACH 
				select distinct cod_coasegur,porc_cont_partic,porc_comision,porc_impuesto
				into  _cod_coasegur,_porc_cont_partic,_porc_comision,_porc_impuesto
				from temphg1
		      Where serie <= 2007 and cod_coasegur in ("030","051","072","042","034","063")  and cod_ramo = v_cod_ramo and cod_contrato = v_cod_contrato -- and porc_cont_partic = _porc_cont_partic
				and anio      = _anio_reas
				and trimestre = _trim_reas
				and borderaux = _borderaux 


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

					{FOREACH				   -- para reempplazar por la tabla de rearamo detalle
						select distinct r.ramo_reas,d.porc_reas
						into v_clase,_porc_comisiond
						from rearamo r, rearamdt d
						where r.ramo_reas = d.ramo_reas
						and d.cod_ramo = v_cod_ramo 

						if _porc_comisiond is null or _porc_comisiond = 0 then
					   		LET _porc_comisiond = 100;
						end if

						LET v_prima = v_prima  * (_porc_comisiond/100) ;
						LET _comision = _comision * (_porc_comisiond/100) ;
						LET _impuesto = _comision * (_porc_comisionds/100) ; 
						LET _por_pagar = _comision * (_porc_comisiond/100) ;
						LET _siniestro = _comision * (_porc_comisiond/100) ;

					   	BEGIN
						ON EXCEPTION IN(-239)
							UPDATE reacoret
							   SET prima = prima + v_prima, 
							   comision = comision + _comision, 
							   impuesto = impuesto + _impuesto, 
							   prima_neta = prima_neta + _por_pagar, 
							   siniestro = siniestro + _siniestro 
							 WHERE cod_coasegur	= _cod_coasegur
							 AND cod_contrato = _serie
							 AND cod_cobertura  = _xnivel
							 AND p_partic = _porc_cont_partic
							 AND cod_ramo =  v_cod_ramo
							 AND cod_clase = v_clase 
							 and anio      = _anio_reas
							 and trimestre = _trim_reas
							 and borderaux = _borderaux ;
						END EXCEPTION 	

					    INSERT INTO reacoret
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
								_borderaux) ;
					END FOREACH}
 

					if v_clase = '001' then

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
							UPDATE reacoret
							   SET prima = prima + v_prima70, 
							   comision = comision + _comision70, 
							   impuesto = impuesto + _impuesto70, 
							   prima_neta = prima_neta + _por_pagar70, 
							   siniestro = siniestro + _siniestro70 
							 WHERE cod_coasegur	= _cod_coasegur
							 AND cod_contrato = _serie
							 AND cod_cobertura  = _xnivel
							 AND p_partic = _porc_cont_partic
							 AND cod_ramo = v_cod_ramo 
							 and cod_clase = '001'
							 and anio      = _anio_reas
							 and trimestre = _trim_reas
							 and borderaux = _borderaux ;


						END EXCEPTION 	

					    INSERT INTO reacoret
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
								'001',
								_anio_reas,
								_trim_reas,
								_borderaux) ;
						END

						BEGIN
						ON EXCEPTION IN(-239)
							UPDATE reacoret
							   SET prima = prima + v_prima30, 
							   comision = comision + _comision30, 
							   impuesto = impuesto + _impuesto30, 
							   prima_neta = prima_neta + _por_pagar30, 
							   siniestro = siniestro + _siniestro30 
							 WHERE cod_coasegur	= _cod_coasegur
							 AND cod_contrato = _serie
							 AND cod_cobertura  = _xnivel
							 AND p_partic = _porc_cont_partic
							 AND cod_ramo = v_cod_ramo 
							 AND cod_clase = '003' 
							 and anio      = _anio_reas
							 and trimestre = _trim_reas
							 and borderaux = _borderaux ;


						END EXCEPTION 	

					    INSERT INTO reacoret
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
								_porc_cont_partic,
								'003',
								_anio_reas,
								_trim_reas,
								_borderaux) ;
						END

					else

					   	BEGIN
						ON EXCEPTION IN(-239)
							UPDATE reacoret
							   SET prima = prima + v_prima, 
							   comision = comision + _comision, 
							   impuesto = impuesto + _impuesto, 
							   prima_neta = prima_neta + _por_pagar, 
							   siniestro = siniestro + _siniestro 
							 WHERE cod_coasegur	= _cod_coasegur
							 AND cod_contrato = _serie
							 AND cod_cobertura  = _xnivel
							 AND p_partic = _porc_cont_partic
							 AND cod_ramo =  v_cod_ramo
							 AND cod_clase = v_clase 
							 and anio      = _anio_reas
							 and trimestre = _trim_reas
							 and borderaux = _borderaux ;

						END EXCEPTION 	

					    INSERT INTO reacoret
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
								_borderaux) ;
					  	END
					end if

			END FOREACH
END FOREACH		
--trace off;

Update reacoret
  set resultado = prima_neta - siniestro, 
      participar = (prima_neta - siniestro) * (p_partic/100) 
     where anio = _anio_reas
	   and trimestre = _trim_reas
	   and borderaux = _borderaux ;

--trace off;
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
         FROM  reacoret
	     where anio = _anio_reas
		   and trimestre = _trim_reas
		   and borderaux = _borderaux 
		 group by cod_coasegur,	cod_clase,cod_contrato,cod_cobertura,p_partic
		 order by cod_coasegur,	cod_clase,cod_contrato,cod_cobertura,p_partic

			if v_prima = 0 then
				continue foreach;
			end if

            SELECT nombre
              INTO v_desc_ramo
              FROM prdramo
             WHERE cod_ramo = v_cod_ramo;

-- Clasificasion - 1-R.C.G.(006), 2-Incendio (001,003)70%,3-Terremoto(001,003)30%,4-Ramos Tecnicos(010,011,014),
--    5-Fianzas(008,080),6-Acc. Personales(004),7-Vida Ind/Col(016,019)]

{			SELECT rearamo.nombre
			INTO v_desc_ramo
			FROM rearamo  
			WHERE rearamo.ramo_reas = v_cod_ramo ;	 }


{			if v_cod_ramo = '001' then
			   LET v_desc_ramo = 'R.C.G.' ;
			end if				}
			if v_cod_ramo = '001' then
			   LET v_desc_ramo = 'Incendio' ;
			end if
			if v_cod_ramo = '003' then
			   LET v_desc_ramo = 'Terremoto' ;
			end if
 {			if v_cod_ramo = '004' then
			   LET v_desc_ramo = 'Ramos Tecnicos' ;
			end if
			if v_cod_ramo = '005' then
			   LET v_desc_ramo = 'Fianzas' ;
			end if
			if v_cod_ramo = '006' then
			   LET v_desc_ramo = 'Acc. Personales' ;
			end if
			if v_cod_ramo = '007' then
			   LET v_desc_ramo = 'Vida Ind/Col' ;
			end if }
		    LET v_desc_ramo = lower(v_desc_ramo);


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
DROP TABLE tmp_sinis;
END

END PROCEDURE  