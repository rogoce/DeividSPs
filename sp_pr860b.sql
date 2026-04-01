------------------------------------------------
--      TOTALES DE PRODUCCION POR             --
--         CONTRATO DE REASEGURO              --
---  Yinia M. Zamora - octubre 2000 - YMZM	  --
---  Ref. Power Builder - d_sp_pro40		  --
--- Modificado por Armando Moreno 19/01/2002; -- la parte de los tipo de contratos
------------------------------------------------
DROP PROCEDURE sp_pr860b;
CREATE PROCEDURE sp_pr860b(a_compania CHAR(03),a_agencia CHAR(03),a_periodo1 CHAR(07),a_periodo2 CHAR(07),a_codsucursal CHAR(255) DEFAULT "*",a_codgrupo  CHAR(255) DEFAULT "*",a_codagente CHAR(255) DEFAULT "*",a_codusuario CHAR(255) DEFAULT "*",a_codramo  CHAR(255) DEFAULT "*",a_reaseguro   CHAR(255) DEFAULT "*"	)
RETURNING CHAR(3),CHAR(3),CHAR(5),CHAR(3),DECIMAL(16,2),DECIMAL(16,2),DECIMAL(16,2),DECIMAL(16,2),DECIMAL(16,2),DECIMAL(16,2),DECIMAL(16,2),DECIMAL(16,2),CHAR(50),CHAR(50), CHAR(50);
--RETURNING smallint;


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
	  DEFINE _ano,_ano2 				     SMALLINT;
	  define _tot_comision 					 dec(16,2);
	  define _tot_impuesto 					 dec(16,2);
	  define _tot_prima_neta				 dec(16,2);
	  DEFINE _tiene_comision				 SMALLINT;
	  define _p_c_partic					 dec(5,2);
	  define _p_c_partic_hay				 smallint;
	  define v_existe                        smallint;

	  define nivel,_nivel                    smallint;
	  define _xnivel                         char(3);
	  define v_prima70, v_prima30            decimal (16,2);
	  define _comision70, _comision30        decimal (16,2);
	  define _impuesto70, _impuesto30        decimal (16,2);
	  define _por_pagar70, _por_pagar30      decimal (16,2);
	  define _siniestro70, _siniestro30      decimal (16,2);

	  define _porc_impuesto4				 dec(7,4);
	  define _porc_comision4,_porc_comisiond dec(7,4);

	  DEFINE _anio_reas						 Char(9);
	  DEFINE _trim_reas						 Smallint;
	  DEFINE _borderaux						 CHAR(2);
	  DEFINE _bouquet						 Smallint;
	  define _no_documento					 char(20);
	  DEFINE _flag , _cnt,_tipo2				 smallint;

--	 DROP TABLE tmp_produccion1;
--	 DROP TABLE tmp_priret;


     SET ISOLATION TO DIRTY READ;
	 LET _borderaux = "01";	    -- BOUQUET
     select tipo into _tipo2 from reacontr where cod_contrato = _borderaux;
	 CALL sp_rea002(a_periodo2,_tipo2) RETURNING _anio_reas,_trim_reas; 

--	 DELETE FROM reacoest where anio = _anio_reas and trimestre = _trim_reas and borderaux = _borderaux ;   -- Elimina borderaux del trimestre
--	 DELETE FROM temphg where anio = _anio_reas and trimestre = _trim_reas and borderaux = _borderaux ;     -- Elimina borderaux datos
	 DELETE FROM reacoret where anio = _anio_reas and trimestre = _trim_reas and borderaux = _borderaux ;   -- Elimina borderaux del trimestre
	 DELETE FROM temphg1 where anio = _anio_reas and trimestre = _trim_reas and borderaux = _borderaux ;     -- Elimina borderaux datos

     LET _ano =  a_periodo1[1,4];

     LET v_descr_cia  = sp_sis01(a_compania);

{	select *
	  from temp_det
	  into temp tmp_det1; }

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
	from tmp_produccion1

		let  _p_c_partic = 0;
		let  _p_c_partic_hay = 0;
		let _bouquet = 0;

		select traspaso,tiene_comision
		  into _traspaso,_tiene_comision
		  from reacocob
		 where cod_contrato   = v_cod_contrato
		   and cod_cober_reas = v_cobertura;

		Select tipo_contrato, serie
		  Into v_tipo_contrato,_serie
	      From reacomae
		 Where cod_contrato = v_cod_contrato;

		select bouquet
		  into _bouquet
		  from reacocob
		 where cod_contrato   = v_cod_contrato
		   and cod_cober_reas = v_cobertura;

		    if _bouquet <> 1 then
			   CONTINUE FOREACH;
		   end if

			IF _bouquet = 1 AND _serie >= 2008 and _cod_coasegur in ('050','063','076','042') THEN	   -- Condiciones del Borderaux Bouquet
				LET _flag = 0;
				LET _cnt = 0;

				select count(*) 
			      into _cnt
			      from reacomae  
			     where upper(nombre) like ('%FACILIDA%')  -- Condicion Ramos tecnicos
			       and cod_contrato   = v_cod_contrato;

					if _cnt = 0 then
	 	   	            LET _flag = 1;
					end if
		   END IF
		   LET nivel = 1;

			if _porc_cont_partic = 100 or _flag = 1 then
			   LET nivel = 2;
	 	  else
			   LET nivel = 1;
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
-- Clasificasion - 1-R.C.G.(006), 2-Incendio (001,003)70%, 3-Terremoto(001,003)30%, 4-Ramos Tecnicos(010,011,014),
--    5-Fianzas(008,080), 6-Acc. Personales(004), 7-Vida Ind/Col(016,019)]

FOREACH
   select serie,cod_ramo,cod_contrato,cod_cobertura,sum(prima) 
     into _serie,v_cod_ramo,v_cod_contrato,v_cobertura,v_prima 
     from temphg1
    Where cod_coasegur in ('050','063','076','042') 
	  and anio      = _anio_reas
	  and trimestre = _trim_reas
	  and borderaux = _borderaux 
    group by serie,cod_ramo,cod_contrato,cod_cobertura

  			FOREACH 
				select distinct cod_coasegur,porc_cont_partic,porc_comision,porc_impuesto
				  into  _cod_coasegur,_porc_cont_partic,_porc_comision,_porc_impuesto
				  from temphg1
				 Where serie = _serie
				   and cod_coasegur in ('050','063','076','042')
				   and cod_ramo      = v_cod_ramo  
				   and cod_contrato  = v_cod_contrato
				   and cod_cobertura = v_cobertura
				   and anio          = _anio_reas
				   and trimestre     = _trim_reas
				   and borderaux     = _borderaux 

				  {	SELECT sum(t.pagado_neto)  -- sum(reserva_neto) 
					  INTO _siniestro	
					  FROM tmp_sinis t, reacomae r
					 where t.cod_ramo     = v_cod_ramo	
					   and r.cod_contrato = t.cod_contrato
					   and t.cod_contrato = v_cod_contrato
					   and r.serie        = _serie
					   and t.seleccionado = 1
					   and t.tipo_contrato not in ('3','1');

					if _siniestro is null then
					   let _siniestro = 0  ;
				    end if	}
					let _siniestro = 0  ;

					if v_cod_ramo = '006' then 
						 let v_clase = '001' ;
					end if

					if v_cod_ramo = '001' or v_cod_ramo = '003' then 
						 let v_clase = '002' ;
					end if					

					if v_cod_ramo = '010' or v_cod_ramo = '012' or v_cod_ramo = '011' or v_cod_ramo = '013' or v_cod_ramo = '014' then 
						 let v_clase = '004' ;
					end if

					if v_cod_ramo = '008' or v_cod_ramo = '080' then 
						 let v_clase = '005' ;
					end if
					if v_cod_ramo = '004' then 
						 let v_clase = '006' ;
					end if
					if v_cod_ramo = '019' then 
						 let v_clase = '007' ;
					end if

					if v_cod_ramo = '016' then 
						 let v_clase = '008' ;
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
						LET _siniestro70 = _siniestro * 1 ;
						LET _siniestro30 = _siniestro * 0 ;	 
						LET _comision70 = v_prima70 * _porc_comision4 * 1 ;
						LET _comision30 = v_prima30 * _porc_comision4 * 1 ;

						if v_cobertura = '021' or v_cobertura = '022' then

							FOREACH
								select distinct porc_comision
								into  _porc_comision4
								from reacoase
								where cod_contrato   = v_cod_contrato
								and cod_cober_reas in ('001','003')
								and cod_coasegur = _cod_coasegur
								EXIT FOREACH;
							END FOREACH

							LET _comision70 = v_prima70 * _porc_comision4 * 1 ;

						end if
						 	  
						if 	_cod_coasegur = '042' then
							LET _comision70 = v_prima70 * 0.48 ;
						elif _cod_coasegur = '076' then
							LET _comision70 = v_prima70 * 0.48 ;
						elif _cod_coasegur = '063' then
							LET _comision70 = v_prima70 * 0.42 ;
						elif _cod_coasegur = '050' then
							LET _comision70 = v_prima70 * 0.43 ;
						end if

						if 	_cod_coasegur = '063' then
							LET _comision30 = v_prima30 * 0.225 ;
						else
							LET _comision30 = v_prima30 * 0.20 ;
						end if

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
								 and cod_clase = '002'
								 and anio      = _anio_reas
								 and trimestre = _trim_reas
								 and borderaux = _borderaux; 

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
									'002',
									_anio_reas,
									_trim_reas,
									_borderaux);
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
								 and borderaux = _borderaux; 

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
									_borderaux);
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
							 and borderaux = _borderaux; 

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
								_borderaux);

					  	END
			 		end if

			END FOREACH
END FOREACH	 	
	
Update reacoret
  set resultado  = prima_neta - siniestro, 
      participar = (prima_neta - siniestro) * (p_partic/100) 
     where anio = _anio_reas
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
       FROM reacoret	
	  where anio = _anio_reas
		and trimestre = _trim_reas
		and borderaux = _borderaux 
	  group by cod_coasegur,cod_clase,cod_contrato,cod_cobertura,p_partic

-- Clasificasion - 1-R.C.G.(006), 2-Incendio (001,003)70%,3-Terremoto(001,003)30%,4-Ramos Tecnicos(010,011,014),
--    5-Fianzas(008,080),6-Acc. Personales(004),7-Vida Ind/Col(016,019)]
--    modifico: 14/05/2010 solicitado: Omar Wong - Para dividir 7-Vida Individual 8-Colectivo de Vida

			SELECT rearamo.nombre
			  INTO v_desc_ramo
			  FROM rearamo  
			 WHERE rearamo.ramo_reas = v_cod_ramo ;

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
			   LET v_desc_ramo = 'Vida Indindividual' ;
			end if

			if v_cod_ramo = '008' then
			   LET v_desc_ramo = 'Colectivo de Vida' ;
			end if

			if _porc_cont_partic = 100 and v_cod_ramo not in ("006","007","008") then 
				let v_cobertura = "3";
			end if

			select nombre
			into v_desc_contrato
			from emicoase
			where cod_coasegur = _cod_coasegur	;

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
					v_descr_cia		  --15
	                WITH RESUME;


END FOREACH	  

{DROP TABLE tmp_produccion1;
DROP TABLE temp_det;
DROP TABLE temp_det1;
DROP TABLE tmp_priret;	   
--DROP TABLE tmp_sinis;
RETURN 0 WITH RESUME;  }

END

END PROCEDURE  







 

