---------------------------------------------------------------------------------
--      TOTALES DE PRODUCCION POR CONTRATO DE REASEGURO           
-- 		Realizado por Henry Giron 23/11/2009 filtros requeridos por Sr. Omar Wong
-- 		ACTUALIZAR TODOS LOS BORDERAUX POR PERIODO
-- 		PRIMA COBRADA
-- execute PROCEDURE sp_pr127 ("001","001","2010-01","2010-01","*","*","*","*",
-- "001,003;","*","*","*")
---------------------------------------------------------------------------------
DROP PROCEDURE sp_pr127;
CREATE PROCEDURE sp_pr127(
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
RETURNING INTEGER, CHAR(250);

DEFINE v_nopoliza                      	CHAR(10);
DEFINE v_noendoso,v_cod_contrato      	CHAR(5);
DEFINE v_cod_ramo,v_cobertura, v_clase 	CHAR(03);
DEFINE v_desc_ramo, v_desc_contrato    	CHAR(50);
DEFINE v_desc_cobertura	               	CHAR(100);
DEFINE v_filtros,v_filtros1            	CHAR(255);
DEFINE _tipo                           	CHAR(01);
DEFINE v_descr_cia                     	CHAR(50);
DEFINE v_prima,v_prima1,v_prima50      	DEC(16,2);      
DEFINE v_tipo_contrato                 	SMALLINT;
define _porc_impuesto				   	dec(16,2);
define _porc_comision				   	dec(16,2);
define _cuenta						   	char(25);
define _serie 						   	smallint;
define _impuesto						dec(16,2);
define _comision						dec(16,2);
define _por_pagar						dec(16,2);
define _siniestro						dec(16,2);
DEFINE _cod_traspaso	 				CHAR(5);
define _traspaso		 				smallint;
define _tiene_comis_rea				 	smallint;
define _cantidad						smallint;
define _tipo_cont                      	smallint;	
define _porc_cont_partic 				dec(16,2);
DEFINE _porc_comis_ase   				DECIMAL(16,2);
define _monto_reas					 	dec(16,2);
define v_prima_suscrita				 	dec(16,2);
define _cod_coasegur	 				char(3);
define _nombre_coas					 	char(50);
define _nombre_cob					 	char(50);
define _nombre_con					 	char(50);
define _cod_subramo					 	char(3);
define _cod_origen					 	char(3);
define _prima_tot_ret                  	dec(16,2);
define _prima_sus_tot				    dec(16,2);
define _prima_tot_ret_sum              	dec(16,2);
define _prima_tot_sus_sum              	dec(16,2);
define _no_cambio						smallint;
define _no_unidad						char(5);
define v_prima_cobrada           		DEC(16,2);
define _porc_partic_coas				dec(16,4);
define _fecha						    date;
define _porc_partic_prima				dec(16,6);
define _p_sus_tot						DEC(16,2);
define _p_sus_tot_sum					DEC(16,2);
DEFINE _ano                           	SMALLINT;
define _tot_comision 					dec(16,2);
define _tot_impuesto 					dec(16,2);
define _tot_prima_neta				 	dec(16,2);
DEFINE _tiene_comision				 	SMALLINT;
define _p_c_partic					 	dec(16,2);
define _p_c_partic_hay				 	smallint;
define v_existe                        	smallint;
define nivel,_nivel,_seleccionado      	smallint;
define _xnivel                         	char(3);
define v_prima70, v_prima30            	decimal (16,2);
define _comision70, _comision30        	decimal (16,2);
define _impuesto70, _impuesto30        	decimal (16,2);
define _por_pagar70, _por_pagar30      	decimal (16,2);
define _siniestro70, _siniestro30      	decimal (16,2);
define _siniestro50                    	decimal (16,2);
define _porc_impuesto4				 	dec(16,4);
define _porc_comision4,_porc_comisiond 	dec(16,4);
define _p_50_prima					 	dec(16,2);
define _p_50_siniestro				 	dec(16,2);
DEFINE _anio_reas						Char(9);
DEFINE _trim_reas						Smallint;
DEFINE _borderaux						CHAR(2);
define v_prima50_7 						dec(16,4);
define _comision_7 						dec(16,4);
define _impuesto_7 						dec(16,4);
define _por_pagar_7  					dec(16,4);
define _siniestro50_7 					dec(16,4);
define v_prima50_3 						dec(16,4);
define _comision_3 						dec(16,4);
define _impuesto_3 						dec(16,4);
define _por_pagar_3  					dec(16,4);
define _siniestro50_3 					dec(16,4);
define ls_noex                        	char(50);

define _error		integer;
define _error_desc	char(50);

SET ISOLATION TO DIRTY READ;

LET _error = 0;

--begin work;

begin
on exception set _error
--rollback work;
return _error, "Error al Altualizar los borderaux.";
end exception

--CALL sp_rea002(a_periodo2) RETURNING _anio_reas,_trim_reas; 
let v_filtros1 = "";

--set debug file to "sp_pr127.trc";	  	  	  	

     LET _ano =  a_periodo1[1,4];

     LET v_descr_cia  = sp_sis01(a_compania);

     CALL sp_pro307(a_compania,a_agencia,a_periodo1,a_periodo2,a_codsucursal,a_codgrupo,   --crea temp_det
                    a_codagente,a_codusuario,a_codramo,a_reaseguro) RETURNING v_filtros;

    { CALL sp_pro314(a_compania,a_agencia,a_periodo1,a_periodo2,a_codsucursal,a_codgrupo,   --crea temp_det1
                    a_codagente,a_codusuario,a_codramo,a_reaseguro) RETURNING v_filtros;}

	-- Cargar el Incurrido	  crea tmp_sinis
	    LET v_filtros = sp_rec708(	 
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
		        z.prima_neta,
				z.vigencia_inic
           into v_nopoliza,
	     		v_noendoso,
		        v_prima_cobrada,
				_fecha
           from temp_det z
          where z.seleccionado = 1
		  --group by 1,2

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
				let ls_noex = '';
				select count(*)
				  into _cantidad
				  from emireama	
				 where no_poliza = v_nopoliza;

				if _cantidad = 0 then
					LET ls_noex = _fecha||" Pol.: "||v_nopoliza||"-"||v_noendoso;

			         {RETURN "",	  	  --01
					        "",		  --02
							"",	  	  --03
							"",	  	  --04
							0.00, 	  --05
							0.00, 	  --06
							0.00, 	  --07
							0.00,	  --08
							0.00,	  --09
							0.00,	  --10
							0.00,	  --11
							0.00,	  --12
							ls_noex,	  --13
							"No Existe Distribucion de Reaseguro",  	  		  --14
							v_descr_cia,	  --15
							""		   		  --16
			                WITH RESUME;   }

							continue foreach;
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
					   set prima    = prima + v_prima1
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
				               and desc_cob      = v_desc_cobertura
				               and serie         = _serie;

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
				 				   and cod_subramo   = _cod_subramo
				 				   and cod_origen    = _cod_origen
				                   and cod_contrato  = v_cod_contrato
				                   and cod_cobertura = v_cobertura
				                   and desc_cob      = v_desc_cobertura
					               and serie         = _serie;

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
						let _porc_cont_partic = 0;
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
				 				   and cod_subramo   = _cod_subramo
				 				   and cod_origen    = _cod_origen
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
	  		         and no_unidad      = _no_unidad;

						let _porc_cont_partic = 0;

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
							                         0,
							                         _tipo_cont,
							                         0, 
							                         0, 
							                         0,
							                         _nombre_cob,
													_serie,
					                    			1,
							                    	 _porc_comision,
						 	                         _porc_impuesto,
						 	                         _porc_cont_partic,
						 	                         _cod_coasegur,
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
							                 WHERE cod_ramo      = v_cod_ramo
							 				   and cod_subramo   = _cod_subramo
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

--------------------------------------------
-- TRABAJAR LOS SIGUIENTES ACTUALIZACIONES -
-- CARGA DE BOREDERAUX  ---	 POR TRIMESTRE -
--------------------------------------------
-- 01	BOUQUET
-- 02	RUNOFF
-- 03	50%RET MAPFRE
-- 04	FACULTATIVO
-- 05	PROVINCIAL
-- 06	FACILIDAD CAR
-- 07	ALLIED CUOTA PARTE
--------------------------------------------
-- Guarda la informacion en las tablas y valida las condiciones de los borderaux

CALL sp_pr128(a_compania,a_agencia,a_periodo1,a_periodo2,a_codsucursal,a_codgrupo,a_codagente,a_codusuario,a_codramo,a_reaseguro,a_contrato,a_serie) 
RETURNING _error, _error_desc ;

IF _error = 1 THEN
	--rollback work;
	RETURN  _error, "No Genero Actualizaicon de Borderaux";
END IF	

--commit work;	
RETURN _error, "Operacion Exitosa.";


DROP TABLE temp_produccion;
DROP TABLE temp_det;
DROP TABLE tmp_priret;
DROP TABLE tmp_sinis;

END

END PROCEDURE  



