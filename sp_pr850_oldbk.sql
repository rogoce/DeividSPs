-----------------------------------------------------------
--   TOTALES DE PRODUCCION POR CONTRATO DE REASEGURO     --	   
---  Realizado por: HENRY GIRON  01/10/2009
---  Ref. Power Builder - d_sp_pro40_crit      d_prod_sp_pr850_dw1
---  Modificado por Armando Moreno 19/01/2002;  la parte de los tipo de contratos
--   execute procedure sp_pr850("001","001","2009-07","2009-09","*","*","*","*","*","*")
-----------------------------------------------------------
DROP PROCEDURE sp_pr850;
CREATE PROCEDURE sp_pr850(a_compania CHAR(03),a_agencia CHAR(03),a_periodo1 CHAR(07),a_periodo2 CHAR(07),a_codsucursal CHAR(255) DEFAULT "*",a_codgrupo  CHAR(255) DEFAULT "*",a_codagente CHAR(255) DEFAULT "*",a_codusuario CHAR(255) DEFAULT "*",a_codramo  CHAR(255) DEFAULT "*",a_reaseguro   CHAR(255) DEFAULT "*"	)
RETURNING CHAR(3),CHAR(3),CHAR(5),CHAR(3),DECIMAL(16,2),DECIMAL(16,2),DECIMAL(16,2),DECIMAL(16,2),DECIMAL(16,2),DECIMAL(16,2),DECIMAL(16,2),DECIMAL(16,2),CHAR(50),CHAR(50), CHAR(50),CHAR(255);
   BEGIN
		DEFINE v_nopoliza                      	CHAR(10);
		DEFINE v_noendoso,v_cod_contrato       	CHAR(5);
		DEFINE v_cod_ramo,v_cobertura, v_clase 	CHAR(03);
		DEFINE v_desc_ramo, v_desc_contrato    	CHAR(50);
		DEFINE v_desc_cobertura	             	CHAR(100);
		DEFINE v_filtros,v_filtros1,v_filtros2 	CHAR(255);
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
		define _porc_cont_terr                  dec(5,2);
		define _porc_cont_inc                   dec(5,2);		
		DEFINE _porc_comis_ase   				DECIMAL(5,2);
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
		define v_prima_cobrada           		DEC(16,2);
		define _porc_partic_coas				dec(7,4);
		define _fecha						    date;
		define _porc_partic_prima				dec(9,6);
		define _p_sus_tot						DEC(16,2);
		define _p_sus_tot_sum					DEC(16,2);
		DEFINE _ano, _ano2                     	SMALLINT;
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
		define _impuesto70, _impuesto30,_valor       	dec(16,2);
		define _por_pagar70, _por_pagar30     	dec(16,2);
		define _siniestro70, _siniestro30     	dec(16,2);
		define _porc_impuesto4				 	dec(7,4);
		define _porc_comision4				 	dec(7,4);
		DEFINE _anio_reas						Char(9);
		DEFINE _trim_reas						Smallint;
		DEFINE _borderaux						CHAR(2);
	    DEFINE _bouquet,_contrato_xl		    Smallint;
		DEFINE _serie1,_tipo2,_cnt				SMALLINT;
		DEFINE _dt_vig_inic         			date;
		define _cod_ramo						char(3);

		SET ISOLATION TO DIRTY READ;
		LET _borderaux = "01";	    -- BOUQUET -- Prima suscrita
		select tipo into _tipo2 from reacontr where cod_contrato = _borderaux;
		CALL sp_rea002(a_periodo2,_tipo2) RETURNING _anio_reas,_trim_reas; 

		DELETE FROM reacoprs where anio = _anio_reas and trimestre = _trim_reas and borderaux = _borderaux;   -- Elimina borderaux del trimestre
		DELETE FROM temphg1 where anio = _anio_reas and trimestre = _trim_reas and borderaux = _borderaux;    -- Elimina borderaux datos;

		LET _ano =  a_periodo1[1,4];

		LET v_descr_cia  = sp_sis01(a_compania);

		CALL sp_pro34(a_compania,a_agencia,a_periodo1,a_periodo2,a_codsucursal,a_codgrupo,
		               a_codagente,a_codusuario,a_codramo,a_reaseguro) RETURNING v_filtros;

		LET v_filtros2 = sp_rec708(
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
            PRIMARY KEY(cod_ramo, cod_subramo, cod_origen, cod_contrato, cod_cobertura, desc_cob, serie)) WITH NO LOG;

CREATE INDEX idx1_temp_produccion ON temp_produccion(cod_ramo);
CREATE INDEX idx2_temp_produccion ON temp_produccion(cod_subramo);
CREATE INDEX idx3_temp_produccion ON temp_produccion(cod_origen);
CREATE INDEX idx4_temp_produccion ON temp_produccion(cod_contrato);
CREATE INDEX idx5_temp_produccion ON temp_produccion(cod_cobertura);
CREATE INDEX idx6_temp_produccion ON temp_produccion(desc_cob);
CREATE INDEX idx7_temp_produccion ON temp_produccion(cod_coasegur);
CREATE INDEX idx8_temp_produccion ON temp_produccion(serie);

LET v_prima        = 0;
LET v_descr_cia    = sp_sis01(a_compania);
let _tipo_cont     = 0;
let v_desc_cobertura = "";
let _porc_comis_ase = 0.00;

--set debug file to "sp_pr850.trc";
	 																						 
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

	  {	select count(*)
		  into _cnt
		  from rearucon r, rearumae e
		 where r.cod_ruta = e.cod_ruta
		   and r.cod_contrato = v_cod_contrato
		   and e.activo = 1;

		 if _cnt > 0 then
		 else
			continue foreach;
		 end if	}

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
			                    _tiene_comis_rea
			                    ,""
			                    );	 
			 	end if

		  else
				let _porc_comis_ase = 0.00;
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

                    if _porc_comis_ase is null then
						let _porc_comis_ase = 0;
					end if
		 				
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
		                and serie = _serie ;

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
		                   and desc_cob      = v_desc_cobertura
		                   and serie         = _serie;

		 			end if
		 			--let v_prima1 = 0;
		 		end foreach

		  end if

		 elif _tipo_cont = 1 then	  --Retencion

	 			let _cod_coasegur = '036'; --ancon
				let _porc_comis_ase = 0.00;


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
		           and desc_cob      = v_desc_cobertura
		           and serie = _serie;

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
		                  and desc_cob      = v_desc_cobertura
		                  and serie = _serie ;

		 		end if

		 elif _tipo_cont = 2 then  --facultativos

		  select count(*)
		    into _cantidad
		    from emifafac
		   where no_poliza      = v_nopoliza
		     and no_endoso      = v_noendoso
	         and cod_contrato   = v_cod_contrato
		     and cod_cober_reas = v_cobertura
		     and no_unidad      = _no_unidad ;

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
			           and desc_cob      = _nombre_cob	
			           and serie = _serie ;
--				               and no_unidad     = _no_unidad ;

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

                    if _porc_comis_ase is null then
						let _porc_comis_ase = 0;
					end if
			 			
			 		select nombre
			 		  into _nombre_coas
			 		  from emicoase
			 		 where cod_coasegur = _cod_coasegur;

			 		let v_desc_cobertura = trim(_nombre_cob) || "  " || trim(_cuenta) || "  " || trim(_nombre_coas) ;
			 		let v_desc_contrato  = trim(v_desc_contrato) || "  I:" || _porc_impuesto || "  C:" || _porc_comis_ase ;

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
			           and serie  = _serie ;

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
			                  and serie = _serie;

			 		end if

		        end foreach

		  end if	

		 end if

 END FOREACH

END FOREACH
-- trace on;
-- Carga Temporal contrato por ramos.
LET _ano2 =  a_periodo2[1,4];
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
		   cod_coasegur,
		   serie
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
	       _cod_coasegur,
	       _serie				
	from temp_produccion
   where seleccionado = 1

		let  _p_c_partic = 0;
		let  _p_c_partic_hay = 0;

		select traspaso,tiene_comision,bouquet
		  into _traspaso,_tiene_comision,_bouquet
		  from reacocob
		 where cod_contrato   = v_cod_contrato
	       and cod_cober_reas = v_cobertura;

		Select tipo_contrato, serie
	      Into v_tipo_contrato,_serie
		  From reacomae
		 Where cod_contrato = v_cod_contrato;

--	    let _serie = _serie1;

		if _bouquet <> 1 then
			CONTINUE FOREACH;
		end if

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
				 _borderaux);

END FOREACH

-- trace on;
-- Carga reacoprs
-- Clasificasion - 1-R.C.G.(006), 2-Incendio (001,003)70%, 3-Terremoto(001,003)30%, 4-Ramos Tecnicos(010,011,012,013,014),
--    5-Fianzas(008,080), 6-Acc. Personales(004), 7-Vida Ind/Col(016,019)]
--    Where serie > 2007 and cod_coasegur in ('050','063','076','042') 	 -- ('050','063','076','042','036','089')

let _siniestro = 0;

FOREACH
  select serie,cod_ramo,cod_contrato,cod_cobertura,sum(prima) 
    into _serie,v_cod_ramo,v_cod_contrato,v_cobertura,v_prima 
    from temphg1
   Where cod_coasegur in ('050','063','076','042','036','089')
	 and anio      = _anio_reas
	 and trimestre = _trim_reas
	 and borderaux = _borderaux 
   group by serie,cod_ramo,cod_contrato,cod_cobertura

			FOREACH 
				select distinct cod_coasegur,porc_cont_partic,porc_comision,porc_impuesto
				  into  _cod_coasegur,_porc_cont_partic,_porc_comision,_porc_impuesto
				  from temphg1
				 Where serie          = _serie
				   and cod_coasegur   in ('050','063','076','042','036','089')
				   and cod_ramo       = v_cod_ramo  
				   and cod_contrato   = v_cod_contrato
				   and cod_cobertura  = v_cobertura
				   and anio           = _anio_reas
				   and trimestre      = _trim_reas
				   and borderaux      = _borderaux 

					if _siniestro is null then
					   let _siniestro = 0;
				    end if
					if v_cod_ramo = '006' then 
						 let v_clase = '001' ;
					end if
					if v_cod_ramo = '001' or v_cod_ramo = '003' then 
						 let v_clase = '002' ;
					end if					
					if v_cod_ramo = '010' or v_cod_ramo = '012' or v_cod_ramo = '011' or v_cod_ramo = '013'  or v_cod_ramo = '014' or v_cod_ramo = '021'  or v_cod_ramo = '022' then 
						 let v_clase = '004' ;
					end if
					if v_cod_ramo = '008' or v_cod_ramo = '080' then 
						 let v_clase = '005' ;
					end if
					if v_cod_ramo = '004' then 
						 let v_clase = '006' ;
					end if
					if v_cod_ramo = '019' or v_cod_ramo = '016' then 
						 let v_clase = '007' ;
					end if
					if v_cod_ramo = '002' then
						 let v_clase = '013' ;
					end if

					--contrato XL
					select contrato_xl
					  into _contrato_xl
					  from reacoase
					 where cod_contrato   = v_cod_contrato
					   and cod_cober_reas = v_cobertura
					   and cod_coasegur   = _cod_coasegur;

					if _contrato_xl = 1 then
						let _porc_cont_partic = 0;
					else
					end if

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

			  		if v_clase = '002' then

						LET _comision70 = 0;
						LET _comision30 = 0;

					   	LET v_prima70 = v_prima * 0.70 ;
						LET v_prima30 =	v_prima * 0.30 ;

						LET _impuesto70 = _impuesto * 0.70 ;
						LET _impuesto30 = _impuesto * 0.30 ;
						LET _por_pagar70 = _por_pagar * 0.70 ;
						LET _por_pagar30 = _por_pagar * 0.30 ;
						LET _siniestro70 = (_siniestro/2) * 1 ;
						LET _siniestro30 = _siniestro * 0 ;	 

						LET _comision70 = v_prima70 * _porc_comision4 * 1 ;
						LET _comision30 = v_prima30 * _porc_comision4 * 1 ;

						if v_cobertura = '021' or v_cobertura = '022' then

							FOREACH
								select distinct porc_comision
								  into _porc_comision4
								  from reacoase
								 where cod_contrato   = v_cod_contrato
								   and cod_cober_reas in ('001','003')
								   and cod_coasegur   = _cod_coasegur
								EXIT FOREACH;
							END FOREACH

							LET _comision70 = v_prima70 * _porc_comision4 * 1 ;
						end if 	  

						if 	_cod_coasegur = '042' then
							LET _comision70 = v_prima70 * 0.48 ;
							if 	v_cod_contrato in ("00602") then
								LET _comision70 = v_prima70 * 0.40 ;
							end if
						elif _cod_coasegur = '076' then
							LET _comision70 = v_prima70 * 0.48 ;
						elif _cod_coasegur = '063' then
							LET _comision70 = v_prima70 * 0.42 ;
						elif _cod_coasegur = '050' then
							LET _comision70 = v_prima70 * 0.43 ;
						end if

						if 	_cod_coasegur = '063' then
							LET _comision30 = v_prima30 * 0.225;
						else
							LET _comision30 = v_prima30 * 0.20 ;
						end if

						LET _por_pagar70 = v_prima70 - _comision70 - _impuesto70 ;
						LET _por_pagar30 = v_prima30 - _comision30 - _impuesto30 ;

						let _porc_cont_inc = 0;

					  foreach
						  SELECT distinct porc_cont_partic
						    INTO _porc_cont_inc
						    FROM reacoase
						   WHERE ( cod_contrato  = v_cod_contrato )
						     AND ( cod_cober_reas in('001','003'))
						     and ( cod_coasegur  = _cod_coasegur)
						   order by 1 desc
							 exit foreach;
					  end foreach

						if _porc_cont_inc is null or _porc_cont_inc = 0 then
						else
							BEGIN
							ON EXCEPTION IN(-239)
								UPDATE reacoprs
								   SET prima         = prima + v_prima70, 
									   comision      = comision + _comision70, 
									   impuesto      = impuesto + _impuesto70, 
									   prima_neta    = prima_neta + _por_pagar70, 
									   siniestro     = siniestro + _siniestro70 
								 WHERE cod_coasegur	 = _cod_coasegur
								   AND cod_contrato  = _serie
								   AND cod_cobertura = _xnivel
								   AND p_partic      = _porc_cont_inc --_porc_cont_partic
								   AND cod_ramo      = v_cod_ramo 
								   and cod_clase     = '002'
								   and anio          = _anio_reas
								   and trimestre     = _trim_reas
								   and borderaux     = _borderaux;

							END EXCEPTION 	

						    INSERT INTO reacoprs
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
									_porc_cont_inc, --_porc_cont_partic,
									'002',
									_anio_reas,
									_trim_reas,
									_borderaux);
							END
						end if

						let _porc_cont_terr = 0;

						foreach
							  SELECT distinct porc_cont_partic
							    INTO _porc_cont_terr
							    FROM reacoase
							   WHERE ( cod_contrato = v_cod_contrato )
							     AND ( cod_cober_reas in('021','022'))
							     and ( cod_coasegur = _cod_coasegur)
	 						   order by 1 desc
							 exit foreach;
						end foreach

						if _porc_cont_terr is null or _porc_cont_terr = 0 then
						else
							BEGIN
							ON EXCEPTION IN(-239)
								UPDATE reacoprs
								   SET prima = prima + v_prima30, 
									   comision = comision + _comision30, 
									   impuesto = impuesto + _impuesto30, 
									   prima_neta = prima_neta + _por_pagar30, 
									   siniestro = siniestro + _siniestro30 
								 WHERE cod_coasegur	= _cod_coasegur
								   AND cod_contrato = _serie
								   AND cod_cobertura  = _xnivel
								   AND p_partic = _porc_cont_terr  --_porc_cont_partic
								   AND cod_ramo = v_cod_ramo 
								   AND cod_clase = '003' 
								   and anio      = _anio_reas
								   and trimestre = _trim_reas
								   and borderaux = _borderaux;

							END EXCEPTION 	

						    INSERT INTO reacoprs
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
									_porc_cont_terr,  --_porc_cont_partic,
									'003',
									_anio_reas,
									_trim_reas,
									_borderaux);
							END  
						end if

					else	 

					   	BEGIN
						ON EXCEPTION IN(-239)
							UPDATE reacoprs
							   SET prima = prima + v_prima, 
								   comision = comision + _comision, 
								   impuesto = impuesto + _impuesto, 
								   prima_neta = prima_neta + _por_pagar, 
								   siniestro = siniestro + _siniestro 
							 WHERE cod_coasegur	= _cod_coasegur
							   AND cod_contrato = _serie
							   AND cod_cobertura = _xnivel
							   AND p_partic  = _porc_cont_partic
							   AND cod_ramo  =  v_cod_ramo
							   AND cod_clase = v_clase 
							   and anio      = _anio_reas
							   and trimestre = _trim_reas
							   and borderaux = _borderaux;

						END EXCEPTION 	

					    INSERT INTO reacoprs
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
								_borderaux);
					  	END
			 		end if

			END FOREACH
END FOREACH		

--set debug file to "sp_pr850.trc";
--trace on;

FOREACH
       SELECT r.serie,t.cod_ramo,t.cod_contrato,sum(t.pagado_neto) 
	     INTO _serie,v_cod_ramo,v_cod_contrato,_siniestro 
         FROM tmp_sinis t, reacomae r 
        where r.cod_contrato = t.cod_contrato 
          and t.seleccionado = 1 
          and t.tipo_contrato not in ('3','1') 
          and r.serie >= 2008 
          and t.cod_ramo in ("021","022","001","003","006","010","011","012","013","014","008","080","004","019","016")
     group by r.serie,t.cod_ramo,t.cod_contrato
     order by r.serie,t.cod_ramo,t.cod_contrato

		select count(*)
		  into _cnt
		  from temphg1 
		 where cod_ramo     = v_cod_ramo
		   and cod_contrato = v_cod_contrato
		   and serie        = _serie;

		if _cnt > 0 then

			foreach
				select distinct cod_cobertura
				  into v_cobertura
				  from temphg1 
				 where cod_ramo     = v_cod_ramo
				   and cod_contrato = v_cod_contrato
				   and serie        = _serie
			  exit foreach;
		    end foreach
		else

		   foreach

				select distinct cod_cober_reas
				  into v_cobertura
				  from reacobre
				 where cod_ramo = v_cod_ramo

				exit foreach;

		   end foreach
			
		end if 

		  FOREACH
		   select distinct cod_cober_reas,cod_coasegur,porc_cont_partic
		     into v_cobertura,_cod_coasegur,_porc_cont_partic
		     from reacoase -- reacocob
			where cod_contrato   = v_cod_contrato
			  and cod_cober_reas = v_cobertura

				if v_cod_ramo = '006' then 
					 let v_clase = '001';
				end if

				if v_cod_ramo = '001' or v_cod_ramo = '003' then 
					 let v_clase = '002';
				end if					

				if v_cod_ramo = '010' or v_cod_ramo = '012' or v_cod_ramo = '011' or v_cod_ramo = '013' or v_cod_ramo = '014' or v_cod_ramo = '021' or v_cod_ramo = '022' then 
					 let v_clase = '004';
				end if

				if v_cod_ramo = '008' or v_cod_ramo = '080' then 
					 let v_clase = '005';
				end if
				if v_cod_ramo = '004' then 
					 let v_clase = '006';
				end if
				if v_cod_ramo = '019' or v_cod_ramo = '016' then 
					 let v_clase = '007';
				end if
				if v_cod_ramo = '002' then
					 let v_clase = '013' ;
				end if


				if _porc_cont_partic < 100 then 
				   let _xnivel = '1';
			    else
				   let _xnivel = '2';
			    end if		

			   	BEGIN
				ON EXCEPTION IN(-239) 
					UPDATE reacoprs 
					   SET siniestro = siniestro + _siniestro 
					 WHERE cod_coasegur	= _cod_coasegur 
					   AND cod_contrato = _serie 
					   AND cod_cobertura  = _xnivel 
					   AND p_partic = _porc_cont_partic 
					   AND cod_ramo =  v_cod_ramo 
					   AND cod_clase = v_clase 
					   AND anio      = _anio_reas 
					   AND trimestre = _trim_reas 
					   AND borderaux = _borderaux; 

				END EXCEPTION 	

			    INSERT INTO reacoprs
				VALUES (_cod_coasegur,
				        v_cod_ramo,
						_serie,
						_xnivel,
						0, 
						0, 
						0, 
						0,
						_siniestro,
						0,
						0,
						_porc_cont_partic,
				        v_clase,
						_anio_reas,
						_trim_reas,
						_borderaux);

			  	END

			END FOREACH	

END FOREACH	 

--Traspaso de Cartera
FOREACH
     SELECT cod_coasegur,
			cod_clase,
			cod_contrato,
			cod_cobertura,
			p_partic,
			cod_ramo,
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
			_cod_ramo,
			v_prima, 
			_comision, 
			_impuesto, 
			_por_pagar,
			_siniestro,
			_prima_tot_ret,
			_prima_sus_tot			
       FROM reacoprs	
	  where anio      = _anio_reas
		and trimestre = _trim_reas
		and borderaux in(_borderaux)
		and cod_contrato < 2010
		and cod_clase in('001','002','003') --solo para incendio, resp. civil y terremoto
	  group by cod_coasegur,cod_clase,cod_contrato,cod_cobertura,p_partic,cod_ramo
	  order by cod_coasegur,cod_clase,cod_contrato


	    INSERT INTO reacoprs
		VALUES (_cod_coasegur,
		        _cod_ramo,
				2010,
				v_cobertura,
				v_prima, 
				_comision, 
				_impuesto,
				_por_pagar,
				_siniestro,
				0,
				0,
				_porc_cont_partic,
		        v_cod_ramo,
				_anio_reas,
				_trim_reas,
				_borderaux);

		UPDATE reacoprs
		   SET prima         = 0,
		       comision      = 0,
		       impuesto      = 0,
		       prima_neta    = 0,
			   siniestro     = 0
		 WHERE cod_coasegur	 = _cod_coasegur
		   AND cod_contrato  = v_cod_contrato
		   AND cod_cobertura = v_cobertura
		   AND cod_clase     = v_cod_ramo
		   and cod_ramo      = _cod_ramo
		   and anio          = _anio_reas
		   and trimestre     = _trim_reas
		   and borderaux     = _borderaux;
--		   and prima         <> 0;

   {	else

		UPDATE reacoprs
		   SET prima         = prima      + v_prima, 
		       comision      = comision   + _comision, 
		       impuesto      = impuesto   + _impuesto, 
		       prima_neta    = prima_neta + _por_pagar 
		 WHERE cod_coasegur	 = _cod_coasegur
		   AND cod_contrato  = 2010
		   AND cod_cobertura = v_cobertura
		   AND cod_clase     = v_cod_ramo
		   and anio          = _anio_reas
		   and trimestre     = _trim_reas
		   and borderaux     = _borderaux
		   and prima         <> 0;

		UPDATE reacoprs
		   SET prima         = 0,
		       comision      = 0,
		       impuesto      = 0,
		       prima_neta    = 0
		 WHERE cod_coasegur	 = _cod_coasegur
		   AND cod_contrato  = v_cod_contrato
		   AND cod_cobertura = v_cobertura
		   AND cod_clase     = v_cod_ramo
		   and anio          = _anio_reas
		   and trimestre     = _trim_reas
		   and borderaux     = _borderaux
		   and prima         <> 0;
  	end if}

END FOREACH
------------	 

Update reacoprs
   set resultado = prima_neta - siniestro, 
       participar = (prima_neta - siniestro) * (p_partic/100) 
 where anio      = _anio_reas
   and trimestre = _trim_reas
   and borderaux = _borderaux;

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
       FROM reacoprs	
      where anio      = _anio_reas
	    and trimestre = _trim_reas
	    and borderaux = _borderaux 
	  group by cod_coasegur,cod_clase,cod_contrato,cod_cobertura,p_partic


			SELECT rearamo.nombre
			  INTO v_desc_ramo
			  FROM rearamo  
			 WHERE rearamo.ramo_reas = v_cod_ramo;

			if v_cod_ramo = '001' then
			   LET v_desc_ramo = 'R.C.G.' ;
			end if
			if v_cod_ramo = '002' then
			   LET v_desc_ramo = 'Incendio' ;
			end if
			if v_cod_ramo = '003' then
			   LET v_desc_ramo = 'Terremoto' ;
			end if
			if v_cod_ramo = '004' then
			   LET v_desc_ramo = 'Ramos Tecnicos' ;
			end if
			if v_cod_ramo = '005' then
			   LET v_desc_ramo = 'Fianzas' ;
			end if
			if v_cod_ramo = '006' then
			   LET v_desc_ramo = 'Acc. Personales' ;
			end if
			if v_cod_ramo = '007' then
			   LET v_desc_ramo = 'Vida Indindividual/Col.Vida';
			end if
{			if v_cod_ramo = '008' then
			   LET v_desc_ramo = 'Colectivo de Vida' ;
			end if}

			if _porc_cont_partic = 100 and v_cod_ramo not in ("006","007","008") then 
				let v_cobertura = "3";
			end if

			select nombre
			  into v_desc_contrato
			  from emicoase
			 where cod_coasegur = _cod_coasegur;

			let _valor = 0;
			let _valor = v_prima + _comision + _impuesto + _por_pagar + _siniestro;


			if _valor = 0 then
				continue foreach;
			end if

	        RETURN _cod_coasegur,	  --01
			       v_cod_ramo,		  --02
				   v_cod_contrato,	  --03
				   v_cobertura,	      --04
				   v_prima, 		  --05
				   _comision, 		  --06
				   _impuesto, 		  --07
				   _por_pagar,		  --08
				   _siniestro,		  --09
				   _prima_tot_ret,	  --10
				   _prima_sus_tot,	  --11
				   _porc_cont_partic, --12
				   v_desc_ramo,	      --13
				   v_desc_contrato,   --14
				   v_descr_cia,		  --15
				   v_filtros          -- 16 filtros
	               WITH RESUME;

END FOREACH
DROP TABLE temp_produccion;
DROP TABLE temp_det;
DROP TABLE tmp_sinis;

END

END PROCEDURE  				   

   