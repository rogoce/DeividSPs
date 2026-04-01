---------------------------------------------------------------------------------
--      TOTALES DE PRODUCCION POR CONTRATO DE REASEGURO           
-- 		Realizado por Henry Giron 23/11/2009 filtros requeridos por Sr. Omar Wong
-- 		ACTUALIZAR TODOS LOS BORDERAUX POR PERIODO
-- 		PRIMA COBRADA
-- execute PROCEDURE sp_pr128 ("001","001","2009-07","2009-09","*","*","*","*",
-- "001,003;","*","*","*")
---------------------------------------------------------------------------------
drop procedure sp_pr129;
create procedure sp_pr129(
a_compania		char(3),
a_agencia		char(3),
a_periodo1		char(7),
a_periodo2		char(7),
a_codsucursal	char(255) default "*",
a_codgrupo		char(255) default "*",
a_codagente		char(255) default "*",
a_codusuario	char(255) default "*",
a_codramo		char(255) default "*",
a_reaseguro		char(255) default "*",
a_contrato		char(255) default "*",
a_serie			char(255) default "*")
returning	integer,
			char(250);

define v_filtros1			char(255);
define v_filtros			char(255);
define v_desc_cobertura		char(100);
define v_desc_contrato		char(50);
define _desc_contrato		char(50);
define _nombre_coas			char(50);
define v_desc_ramo			char(50);
define _nombre_cob			char(50);
define v_descr_cia			char(50);
define _error_desc			char(50);
define _nombre_con			char(50);
define ls_noex				char(50);
define _cuenta				char(25);
define v_nopoliza			char(10);
define _anio_reas			char(9);
define v_cod_contrato		char(5);
define _cod_traspaso		char(5);
define v_noendoso			char(5);
define _no_unidad			char(5);
define _cod_coasegur		char(3);
define _cod_subramo			char(3);
define _cod_origen			char(3);
define v_cobertura			char(3);
define v_cod_ramo			char(3);
define v_clase				char(3);
define _xnivel				char(3);
define _borderaux			char(2);
define _tipo				char(1);
define _prima_tot_ret_sum	dec(16,2);
define _prima_tot_sus_sum	dec(16,2);
define _porc_cont_partic	dec(16,2);
define v_prima_suscrita		dec(16,2);
define _porc_comis_ase		dec(16,2);
define v_prima_cobrada		dec(16,2);
define _p_50_siniestro		dec(16,2);
define _tot_prima_neta		dec(16,2);
define _porc_impuesto		dec(16,2);
define _porc_comision		dec(16,2);
define _prima_tot_ret		dec(16,2);
define _prima_sus_tot		dec(16,2);
define _p_sus_tot_sum		dec(16,2);
define _p_sus_tot			dec(16,2);
define _siniestro			dec(16,2);
define _por_pagar			dec(16,2);
define _comision			dec(16,2);
define v_prima50			dec(16,2);      
define _impuesto			dec(16,2);
define v_prima1				dec(16,2);      
define v_prima				dec(16,2);      
define _monto_reas			dec(16,2);
define _p_50_prima			dec(16,2);
define v_prima70			dec(16,2);
define v_prima30			dec(16,2);
define _comision70			dec(16,2);
define _comision30			dec(16,2);
define _impuesto70			dec(16,2);
define _impuesto30			dec(16,2);
define _por_pagar70			dec(16,2);
define _por_pagar30			dec(16,2);
define _siniestro70			dec(16,2);
define _siniestro30			dec(16,2);
define _siniestro50			dec(16,2);
define _tot_comision		dec(16,2);
define _tot_impuesto		dec(16,2);
define _p_c_partic			dec(16,2);
define _porc_partic_coas	dec(16,4);
define _porc_impuesto4		dec(16,4);
define _porc_comisiond		dec(16,4);
define _porc_comision4		dec(16,4);
define _siniestro50_7		dec(16,4);
define _siniestro50_3		dec(16,4);
define _por_pagar_7			dec(16,4);
define _por_pagar_3			dec(16,4);
define v_prima50_7			dec(16,4);
define v_prima50_3			dec(16,4);
define _comision_7			dec(16,4);
define _comision_3			dec(16,4);
define _impuesto_7			dec(16,4);
define _impuesto_3			dec(16,4);
define _porc_partic_prima	dec(16,6);
define _tiene_comis_rea		smallint;
define _tiene_comision		smallint;
define _p_c_partic_hay		smallint;
define v_tipo_contrato		smallint;
define _seleccionado		smallint;
define _tipo_cont			smallint;
define _no_cambio			smallint;
define _trim_reas			smallint;
define _cantidad			smallint;
define _traspaso			smallint;
define v_existe				smallint;
define _nivel				smallint;
define _serie				smallint;
define nivel				smallint;
define _ano					smallint;	
define _error				integer;
define _fecha				date;
--set debug file to "sp_pr128.trc";	  	  	  	
--trace on;

set isolation to dirty read;
let _error 	   = 0;
let v_filtros1 = '';
let v_filtros  = '';

--begin work;

begin
on exception set _error
--rollback work;
return _error, "Error al Actualizar los borderaux.";
end exception

call sp_rea002(a_periodo2) returning _anio_reas,_trim_reas; 

let _ano        =  a_periodo1[1,4];
let v_descr_cia = sp_sis01(a_compania);

-----------------------------------------------
-- CARGA DE BOREDERAUX PCOBRADA - POR TRIMESTRE	 - TOTALES
-----------------------------------------------
-- 01	BOUQUET
-- 02	RUNOFF
-- 03	50%RET MAPFRE
-- 04	FACULTATIVO
-- 05	PROVINCIAL
-- 06	FASCILIDAD CAR
-- 07	ALLIED CUOTA PARTE
-----------------------------------------------
-- 01	BOUQUET

FOREACH 
	select cod_contrato
	  into _borderaux
	  from reacontr
	 where activo = 1
	 order by 1

	if _borderaux = '01' then	--Bouquet

		FOREACH
			select serie,cod_ramo,cod_contrato,cod_cobertura,sum(prima) 
		      into _serie,v_cod_ramo,v_cod_contrato,v_cobertura,v_prima 
		      from temphg
		     where serie > 2007 
		       and cod_coasegur in ('050','063','089','076','042','036')
			   and anio      = _anio_reas
			   and trimestre = _trim_reas
			   and borderaux = _borderaux 
			 group by serie,cod_ramo,cod_contrato,cod_cobertura

			FOREACH 
				select distinct cod_coasegur,porc_cont_partic,porc_comision,porc_impuesto
				  into _cod_coasegur,_porc_cont_partic,_porc_comision,_porc_impuesto
				  from temphg
				 Where serie        = _serie 
				   and cod_coasegur in ('050','063','089','076','042','036')
				   and cod_ramo      = v_cod_ramo  
				   and cod_contrato  = v_cod_contrato
				   and cod_cobertura = v_cobertura
				   and anio          = _anio_reas
				   and trimestre     = _trim_reas
				   and borderaux     = _borderaux 

				SELECT sum(t.pagado_neto)  -- sum(reserva_neto) 
				  INTO _siniestro	
				  FROM tmp_sinis t, reacomae r
				 where t.cod_ramo     = v_cod_ramo	
				   and r.cod_contrato = t.cod_contrato
				   and t.cod_contrato = v_cod_contrato
				   and r.serie        = _serie and t.seleccionado = 1 and t.tipo_contrato not in ('3','1');

				if _siniestro is null then
				   let _siniestro = 0;
				end if

				if v_cod_ramo = '006' then 
					 let v_clase = '001';
				end if

				if v_cod_ramo = '001' or v_cod_ramo = '003' then 
					 let v_clase = '002';
				end if					

				if v_cod_ramo = '010' or v_cod_ramo = '011' or v_cod_ramo = '012' or v_cod_ramo = '013'  or v_cod_ramo = '014' then 
					 let v_clase = '004';
				end if

				if v_cod_ramo = '008' or v_cod_ramo = '080' then 
					 let v_clase = '005';
				end if
				if v_cod_ramo = '004' then 
					 let v_clase = '006';
				end if
				if v_cod_ramo = '019' then 
					 let v_clase = '007';
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

				LET _comision  = v_prima * _porc_comision4;
				LET _impuesto  = v_prima * _porc_impuesto4;
			
				LET _por_pagar = v_prima - _comision - _impuesto;

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

					LET _impuesto70  = _impuesto  * 0.70 ;
					LET _impuesto30  = _impuesto  * 0.30 ;
					LET _por_pagar70 = _por_pagar * 0.70 ;
					LET _por_pagar30 = _por_pagar * 0.30 ;
					LET _siniestro70 = _siniestro * 1 ;
					LET _siniestro30 = _siniestro * 0 ;	 
					LET _comision70  = v_prima70  * _porc_comision4 * 1 ;
					LET _comision30  = v_prima30  * _porc_comision4 * 1 ;

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


						LET _comision70 = v_prima70 * _porc_comision4 * 1;			
					end if 	  

					if 	_cod_coasegur = '063' then
						LET _comision30 = v_prima30 * 0.225 ;
					else
						LET _comision30 = v_prima30 * 0.20 ;
					end if

					LET _por_pagar70 = v_prima70 - _comision70 - _impuesto70;
					LET _por_pagar30 = v_prima30 - _comision30 - _impuesto30;

					if _cod_coasegur = '036' then
						LET _comision 	    = 0; 
						LET _impuesto 	    = 0; 
						LET _por_pagar	    = v_prima; 
						LET _comision70 	= 0; 
						LET _impuesto70 	= 0; 
						LET _por_pagar70	= v_prima70; 
						LET _comision30 	= 0; 
						LET _impuesto30 	= 0; 
						LET _por_pagar30	= v_prima30; 
					end if

						BEGIN
						ON EXCEPTION IN(-239)
							UPDATE reacoest
							   SET prima         = prima      + v_prima70, 
								   comision      = comision   + _comision70, 
								   impuesto      = impuesto   + _impuesto70, 
								   prima_neta    = prima_neta + _por_pagar70, 
								   siniestro     = siniestro  + _siniestro70 
							 WHERE cod_coasegur	 = _cod_coasegur
							   AND cod_contrato  = _serie
							   AND cod_cobertura = _xnivel
							   AND p_partic      = _porc_cont_partic
							   AND cod_ramo  	 = v_cod_ramo 
							   and cod_clase 	 = '002'
							   and anio      	 = _anio_reas
							   and trimestre 	 = _trim_reas
							   and borderaux 	 = _borderaux;


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
							UPDATE reacoest
							   SET prima         = prima      + v_prima30, 
								   comision      = comision   + _comision30, 
								   impuesto      = impuesto   + _impuesto30, 
								   prima_neta    = prima_neta + _por_pagar30, 
								   siniestro     = siniestro  + _siniestro30 
							 WHERE cod_coasegur	 = _cod_coasegur
							   AND cod_contrato  = _serie
							   AND cod_cobertura = _xnivel
							   AND p_partic      = _porc_cont_partic
							   AND cod_ramo      = v_cod_ramo 
							   AND cod_clase     = '003' 
							   and anio          = _anio_reas
							   and trimestre     = _trim_reas
							   and borderaux     = _borderaux;


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

					if _cod_coasegur = '036' then
						LET _comision 	    = 0; 
						LET _impuesto 	    = 0; 
						LET _por_pagar	    = v_prima; 
						LET _comision70 	= 0; 
						LET _impuesto70 	= 0; 
						LET _por_pagar70	= v_prima70; 
						LET _comision30 	= 0; 
						LET _impuesto30 	= 0; 
						LET _por_pagar30	= v_prima30; 
					end if

					BEGIN
					ON EXCEPTION IN(-239)
						UPDATE reacoest
						   SET prima         = prima         + v_prima, 
							   comision      = comision      + _comision, 
							   impuesto      = impuesto      + _impuesto, 
							   prima_neta    = prima_neta    + _por_pagar, 
							   siniestro     = siniestro     + _siniestro 
						 WHERE cod_coasegur	 = _cod_coasegur
						   AND cod_contrato  = _serie
						   AND cod_cobertura = _xnivel
						   AND p_partic 	 = _porc_cont_partic
						   AND cod_ramo 	 =  v_cod_ramo
						   AND cod_clase	 = v_clase 
						   and anio      	 = _anio_reas
						   and trimestre 	 = _trim_reas
						   and borderaux 	 = _borderaux;

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

		Update reacoest
		   set resultado  = prima_neta - siniestro, 
		       participar = (prima_neta - siniestro) * (p_partic/100) 
		 where anio       = _anio_reas
		   and trimestre  = _trim_reas
		   and borderaux  = _borderaux;
	end if

-- 02	RUNOFF

	if _borderaux = '02' then

		FOREACH
		   select serie,cod_ramo, sum(prima)
		     into _serie,v_cod_ramo, v_prima
		     from temphg
		    Where serie <= 2007 and cod_coasegur in ( "030","051","072","042","063") 
		      and anio      = _anio_reas
			  and trimestre = _trim_reas
			  and borderaux = _borderaux 
		    group by cod_ramo,serie


		   select sum(t.pagado_neto)  -- sum(reserva_neto) 	
			 into _siniestro	
			 from tmp_sinis t, reacomae r
		    where t.cod_ramo = v_cod_ramo	
			  and r.cod_contrato = t.cod_contrato
			  and r.serie = _serie 
			  and t.seleccionado = 1 
			  and t.tipo_contrato not in ('3','1') ;  

		   if _siniestro is null then
		      let _siniestro = 0  ;
		   end if
		   if v_cod_ramo = '006' then 
		   	 let v_clase = '001' ;
		   end if
		   if v_cod_ramo = '001' or v_cod_ramo = '003' then 
		   	 let v_clase = '002' ;
		   end if					
		   if v_cod_ramo = '010' or v_cod_ramo = '011' or v_cod_ramo = '013'  or v_cod_ramo = '014' then 
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
		   end if

		   FOREACH 
					select distinct cod_coasegur,porc_cont_partic,porc_comision,porc_impuesto
					  into _cod_coasegur,_porc_cont_partic,_porc_comision,_porc_impuesto
					  from temphg
					 Where serie <= 2007  and cod_coasegur in ( "030","051","072","042","063")  and cod_ramo = v_cod_ramo
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

						if v_clase = '002' then

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
								   SET prima         = prima      + v_prima70, 
									   comision      = comision   + _comision70, 
									   impuesto      = impuesto   + _impuesto70, 
									   prima_neta    = prima_neta + _por_pagar70, 
									   siniestro     = siniestro  + _siniestro70 
								 WHERE cod_coasegur	 = _cod_coasegur
								   AND cod_contrato  = _serie
								   AND cod_cobertura = _xnivel
								   AND p_partic      = _porc_cont_partic
								   AND cod_ramo      = v_cod_ramo 
								   and cod_clase     = '002'
								   and anio          = _anio_reas
								   and trimestre     = _trim_reas
								   and borderaux     = _borderaux;


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
								UPDATE reacoest
								   SET prima        = prima      + v_prima30, 
									   comision     = comision   + _comision30, 
									   impuesto     = impuesto   + _impuesto30, 
									   prima_neta   = prima_neta + _por_pagar30, 
									   siniestro    = siniestro  + _siniestro30 
								 WHERE cod_coasegur	= _cod_coasegur
								 AND cod_contrato   = _serie
								 AND cod_cobertura  = _xnivel
								 AND p_partic       = _porc_cont_partic
								 AND cod_ramo       = v_cod_ramo 
								 AND cod_clase      = '003' 
								 and anio           = _anio_reas
								 and trimestre      = _trim_reas
								 and borderaux      = _borderaux;

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
								UPDATE reacoest
								   SET prima         = prima      + v_prima, 
									   comision      = comision   + _comision, 
									   impuesto      = impuesto   + _impuesto, 
									   prima_neta    = prima_neta + _por_pagar, 
									   siniestro     = siniestro  + _siniestro 
								 WHERE cod_coasegur	 = _cod_coasegur
								   AND cod_contrato  = _serie
								   AND cod_cobertura = _xnivel
								   AND p_partic      = _porc_cont_partic
								   AND cod_ramo      =  v_cod_ramo
								   AND cod_clase     = v_clase 
								   and anio          = _anio_reas
								   and trimestre     = _trim_reas
								   and borderaux     = _borderaux;

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

		Update reacoest
		   set resultado  = prima_neta - siniestro, 
		       participar = (prima_neta - siniestro) * (p_partic/100) 
		 where anio       = _anio_reas
		   and trimestre  = _trim_reas
		   and borderaux  = _borderaux;
	end if

-- 03	50%RET MAPFRE

	if _borderaux = '03' then	 -- 50 % Retencion MAPFRE

			-- Ingresa el cuadro MAFPFRE 50% RETENCION 
			-- CARACTERISTICAS : del 2008 hasta la fecha, reaseguradora ANCON y tipo contrato retencion
			-- and cod_cobertura = '001' -- and cod_ramo = '001' -- and cod_coasegur = '036' 

			LET _cod_coasegur     = '063';  
			LET _porc_cont_partic = 50;

			LET _anio_reas = _anio_reas;
			LET _trim_reas = _trim_reas; 

			FOREACH
			   select serie,tipo_contrato,porc_cont_partic,porc_comision,porc_impuesto,cod_ramo,cod_contrato,cod_cobertura,sum(prima)
			     into _serie,v_tipo_contrato,_porc_cont_partic,_porc_comision,_porc_impuesto,v_cod_ramo,v_cod_contrato,v_cobertura,v_prima
			     from temphg
			    Where serie >= 2008 and seleccionado = 1
			      and anio      = _anio_reas
				  and trimestre = _trim_reas
				  and borderaux = _borderaux 
			    group by serie,tipo_contrato,porc_cont_partic,porc_comision,porc_impuesto,cod_ramo,cod_contrato,cod_cobertura

			   if v_tipo_contrato <> 1 then 
			   		continue foreach;
			   end if

			   select sum(t.pagado_neto)  -- sum(reserva_neto) 	
				 into _siniestro	
				 from tmp_sinis t, reacomae r
				where t.cod_ramo     = v_cod_ramo	
				  and r.cod_contrato = t.cod_contrato
				  and t.cod_contrato = v_cod_contrato
				  and r.serie        = _serie 
				  and t.seleccionado = 1 
				  and t.tipo_contrato in('1'); --and t.doc_poliza <> "0109-00700-01" ;	-- Solicitud 26/11/2008 del Sr. Omar Wong 	BANCO HIPOTECARIO NACIONAL  

			   if _siniestro is null then
			   	   let _siniestro = 0 ;
			   end if

			   let v_clase = v_cod_ramo;

			   LET _p_50_prima     = 50;
			   LET _p_50_siniestro = 50;

			   LET v_prima50 = (v_prima * _p_50_prima)/100;

			   select porc_comision
			     into _porc_comision
			     from reacoase
			    where cod_contrato   = '00595' 	     -- Contrato de 50%RET_MAPFRE, no cambia a partir del 2008. Sr. Omar Wong
			      and cod_cober_reas = v_cobertura;

			   LET _comision = v_prima50 * _porc_comision/100 ;

			   if v_cod_ramo = '001' or v_cod_ramo = '003' then 
				   	  let _impuesto = v_prima50 * 0.02;
				   	  let _xnivel   = '001';
					  if v_cobertura = '021' and v_cod_ramo = '001' then
					   		let v_clase   = 'INT';
					   		let _siniestro = 0  ;
					   		LET _comision  = v_prima50 * 0.225 ;
					   end if
					   if v_cobertura = '001' and v_cod_ramo = '001' then
					   		let v_clase = 'INI';
					   end if
					   if v_cobertura = '022' and v_cod_ramo = '003' then
					   		let v_clase   = 'MUT';
					   		let _siniestro = 0  ;
					   		LET _comision  = v_prima50 * 0.225 ;
					   end if
					   if v_cobertura = '003' and v_cod_ramo = '003' then
					   		let v_clase = 'MUI';
					   end if

					   LET _siniestro50 =  (_siniestro * _p_50_siniestro)/100;							
					   LET _por_pagar = v_prima50 - _comision - _impuesto ;

					   LET v_prima50_7    = 0;
					   LET _comision_7    = 0; 
					   LET _impuesto_7    = 0; 
					   LET _por_pagar_7   = 0;
					   LET _siniestro50_7 = 0;

					   LET v_prima50_3    = 0;
					   LET _comision_3    = 0; 
					   LET _impuesto_3    = 0; 
					   LET _por_pagar_3   = 0;
					   LET _siniestro50_3 = 0;
					   -- 70
					   LET v_prima50_7    = v_prima50  * 0.7;
					   LET _comision_7    = _comision  * 0.7; 
					   LET _impuesto_7    = _impuesto  * 0.7; 
					   LET _por_pagar_7   = _por_pagar * 0.7;
					   LET _siniestro50_7 = _siniestro50;

					   BEGIN
					   ON EXCEPTION IN(-239)
					   	UPDATE reacoest
					   	   SET prima        = prima      + v_prima50_7, 
					   		   comision     = comision   + _comision_7, 
					   		   impuesto     = impuesto   + _impuesto_7, 
					   		   prima_neta   = prima_neta + _por_pagar_7, 
					   		   siniestro    = siniestro  + _siniestro50_7 
					   	 WHERE cod_coasegur	= _cod_coasegur
					   	   AND cod_contrato  = _serie
					   	   AND cod_cobertura = _xnivel		
					   	   AND cod_ramo      = v_cod_ramo
					   	   and cod_clase     = v_clase 
					   	   and anio          = _anio_reas
					   	   and trimestre     = _trim_reas
					   	   and borderaux     = _borderaux;

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
					           v_cod_ramo,
					   		_serie,
					   		_xnivel,
					   		v_prima50_7, 
					   		_comision_7, 
					   		_impuesto_7, 
					   		_por_pagar_7,
					   		_siniestro50_7,
					   		0,
					   		0,
					   		0,
					   		v_clase,
					   		_anio_reas,
					   		_trim_reas,
					   		_borderaux);

					   END
					   -- 30
					   LET v_prima50_3 = v_prima50 * 0.3;

					   if  v_cod_ramo = '001' then
					   		let  v_clase = 'INT';
					   		let _siniestro50_3 = 0  ;
					   		let _comision_3 = v_prima50_3 * 0.225;
					   end if
					   if  v_cod_ramo = '003' then
						   let  v_clase = 'MUT';
						   let _siniestro50_3 = 0  ;
						   let _comision_3 = v_prima50_3 * 0.225;
					   end if
					   let _impuesto_3  =  v_prima50_3 * 0.02; 
					   let _por_pagar_3 = v_prima50_3 - _comision_3 - _impuesto_3;

					   BEGIN
					   ON EXCEPTION IN(-239)
					   	UPDATE reacoest
					   	   SET prima        = prima       + v_prima50_3, 
					   		   comision     = comision    + _comision_3, 
					   		   impuesto     = impuesto    + _impuesto_3, 
					   		   prima_neta   = prima_neta  + _por_pagar_3, 
					   		   siniestro    = siniestro   + _siniestro50_3 
					   	 WHERE cod_coasegur	= _cod_coasegur
					   	   AND cod_contrato   = _serie
					   	   AND cod_cobertura  = _xnivel
					   	   AND cod_ramo       = v_cod_ramo
					   	   and cod_clase      = v_clase 
					   	   and anio           = _anio_reas
					   	   and trimestre      = _trim_reas
					   	   and borderaux      = _borderaux;

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
					           v_cod_ramo,
					   		_serie,
					   		_xnivel,
					   		v_prima50_3, 
					   		_comision_3, 
					   		_impuesto_3, 
					   		_por_pagar_3,
					   		_siniestro50_3,
					   		0,
					   		0,
					   		0,
					   		v_clase,
					   		_anio_reas,
					   		_trim_reas,
					   		_borderaux);
					   END

			   else
					LET _impuesto = v_prima50 * 0.02 ;

		 			let _xnivel      = '002';
					LET _siniestro50 =  (_siniestro * _p_50_siniestro)/100;							
					LET _por_pagar   = v_prima50 - _comision - _impuesto;

				   	BEGIN
					ON EXCEPTION IN(-239)
						UPDATE reacoest
						   SET prima        = prima      + v_prima50, 
							   comision     = comision   + _comision, 
							   impuesto     = impuesto   + _impuesto, 
							   prima_neta   = prima_neta + _por_pagar, 
							   siniestro    = siniestro  + _siniestro50 
						 WHERE cod_coasegur	= _cod_coasegur
						   AND cod_contrato  = _serie
						   AND cod_cobertura = _xnivel
						   AND cod_ramo      = v_cod_ramo
						   and cod_clase     = v_clase 
						   and anio          = _anio_reas
						   and trimestre     = _trim_reas
						   and borderaux     = _borderaux;

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
					        v_cod_ramo,
							_serie,
							_xnivel,
							v_prima50, 
							_comision, 
							_impuesto, 
							_por_pagar,
							_siniestro50,
							0,
							0,
							0,
							v_clase,
							_anio_reas,
							_trim_reas,
							_borderaux);
				  	END
			   end if

			END FOREACH		

			Update reacoest
			   set participar = prima_neta - siniestro,
			  	   p_partic   = prima * 2,
			       resultado  = siniestro * 2 
			 where anio       = _anio_reas
			   and trimestre  = _trim_reas
			   and borderaux  = _borderaux;
	end if

-- 04	FACULTATIVO
	if _borderaux = '04' then	 -- FACULTATIVO
		FOREACH
		   select serie,cod_coasegur,tipo_contrato,porc_cont_partic,porc_comision,porc_impuesto,cod_ramo,cod_contrato,cod_cobertura,sum(prima)
		     into _serie,_cod_coasegur,v_tipo_contrato,_porc_cont_partic,_porc_comision,_porc_impuesto,v_cod_ramo,v_cod_contrato,v_cobertura,v_prima
		     from temphg
		    Where seleccionado = 1
			  and anio      = _anio_reas
			  and trimestre = _trim_reas
			  and borderaux = _borderaux 
		    group by serie,cod_coasegur,tipo_contrato,porc_cont_partic,porc_comision,porc_impuesto,cod_ramo,cod_contrato,cod_cobertura 

		   select sum(t.pagado_neto)  -- sum(reserva_neto) 	
		   	 into _siniestro	
			 from tmp_sinis t, reacomae r
			where t.cod_ramo = v_cod_ramo	
			  and r.cod_contrato = t.cod_contrato 
			  and r.serie = _serie and t.seleccionado = 1 and t.tipo_contrato in ('1');  

		   if _siniestro is null then
		      let _siniestro = 0;
		   end if

		   let v_clase         = v_cod_ramo;
		   let _xnivel         = '003';		
		   let _p_50_prima     = 100;
		   let _p_50_siniestro = 100;
		   let v_prima50       = (v_prima * _p_50_prima)/100;
		   let _siniestro50    = (_siniestro * _p_50_siniestro)/100;

		   LET _por_pagar = v_prima50 - _comision - _impuesto;

		   BEGIN
		   ON EXCEPTION IN(-239)
		   	UPDATE reacoest
		   	   SET prima     	 = prima      + v_prima50, 
			   	   comision 	 = comision   + _comision, 
			   	   impuesto 	 = impuesto   + _impuesto, 
			   	   prima_neta    = prima_neta + _por_pagar, 
			   	   siniestro     = siniestro  + _siniestro50 
		   	 WHERE cod_coasegur	 = _cod_coasegur
			   AND cod_contrato  = _serie
			   AND cod_cobertura = _xnivel
			   AND cod_ramo 	 = v_cod_ramo
			   and cod_clase 	 = v_clase 
			   and anio      	 = _anio_reas
			   and trimestre 	 = _trim_reas
			   and borderaux 	 = _borderaux;

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
				        v_cod_ramo,
						_serie,
						_xnivel,
						v_prima50, 
						_comision, 
						_impuesto, 
						_por_pagar,
						_siniestro50,
						0,
						0,
						0,
						v_clase,
						_anio_reas,
						_trim_reas,
						_borderaux);
			  	END

		END FOREACH		

		Update reacoest
		  set participar = prima_neta - siniestro,
		  	  p_partic   = prima ,
		      resultado  = siniestro  
		where anio       = _anio_reas
		  and trimestre  = _trim_reas 
		  and borderaux  = _borderaux;

	end if

-- 05	PROVINCIAL
	if _borderaux = '05' then	 -- PROVINCIAL

		-- Ingresa el cuadro PROVINCIAL INCENDIO 
		-- CARACTERISTICAS : del 2007 hasta la fecha, contrato = '00585'
		-- and cod_cobertura = '001' --and cod_ramo = '001' --and cod_coasegur = '036' 
		-- trace on;

		LET _cod_coasegur     = '089';  
		LET _porc_cont_partic = 100;
		LET _porc_comision    = 0;
		LET _porc_impuesto    = 0;

		FOREACH
		   select serie,tipo_contrato,porc_cont_partic,porc_comision,porc_impuesto,cod_ramo,cod_contrato,cod_cobertura,sum(prima)
		     into _serie,v_tipo_contrato,_porc_cont_partic,_porc_comision,_porc_impuesto,v_cod_ramo,v_cod_contrato,v_cobertura,v_prima
		     from temphg
		    where serie >= 2007 and seleccionado = 1
			  and anio      = _anio_reas
			  and trimestre = _trim_reas
			  and borderaux = _borderaux 
		    group by serie,tipo_contrato,porc_cont_partic,porc_comision,porc_impuesto,cod_ramo,cod_contrato,cod_cobertura

		   select sum(t.pagado_neto)  -- sum(reserva_neto) 	
		     into _siniestro	
		     from tmp_sinis t, reacomae r
		    where t.cod_ramo = v_cod_ramo
		      and r.cod_contrato = t.cod_contrato
		      and r.serie = _serie and t.seleccionado = 1 and t.tipo_contrato in ('1')
		      and t.cod_contrato = v_cod_contrato;

		   if _siniestro is null then
		        let _siniestro = 0  ;
		   end if

		   let v_clase = v_cod_ramo;

		   if  v_cod_ramo = '001' or v_cod_ramo = '003' then 
	--			let v_clase = '1';
				let _xnivel = '001';
				if v_cobertura = '021' and v_cod_ramo = '001' then
					let  v_clase = 'INT';
					let _siniestro = 0  ;
				end if
				if v_cobertura = '001' and v_cod_ramo = '001' then
					let  v_clase = 'INI';
				end if
				if v_cobertura = '022' and v_cod_ramo = '003' then
					let  v_clase = 'MUT';
					let _siniestro = 0  ;
				end if
				if v_cobertura = '003' and v_cod_ramo = '003' then
					let  v_clase = 'MUI';
				end if
	 	   else
				 let _xnivel = '002';
	 	   end if
	--			if v_cod_ramo = '010' or v_cod_ramo = '011' or  v_cod_ramo = '012' or v_cod_ramo = '013' or  v_cod_ramo = '014' then 
	--				 let v_clase = '3' ;
	--				 let _xnivel = '002';
	--			end if			
							
			LET _p_50_prima     = 100;
			LET _p_50_siniestro = 100;

			LET v_prima50 =  (v_prima * _p_50_prima)/100;
			LET _siniestro50 =  (_siniestro * _p_50_siniestro)/100;

	{			LET _comision = v_prima50 * 0.42 ;
			LET _impuesto = v_prima50 * 0.02 ;	}
			LET _comision = v_prima50 * _porc_comision /100;
			LET _impuesto = v_prima50 * _porc_impuesto /100;	
			LET _por_pagar = v_prima50 - _comision - _impuesto ;

		   	BEGIN
			ON EXCEPTION IN(-239)
				UPDATE reacoest
				   SET prima        = prima + v_prima50, 
					   comision     = comision + _comision, 
					   impuesto     = impuesto + _impuesto, 
					   prima_neta   = prima_neta + _por_pagar, 
					   siniestro    = siniestro + _siniestro50 
				 WHERE cod_coasegur	= _cod_coasegur
				   AND cod_contrato = _serie
				   AND cod_cobertura = _xnivel
	--			   AND p_partic = _porc_cont_partic
				   AND cod_ramo      = v_cod_ramo
				   and cod_clase     = v_clase 
				   and anio          = _anio_reas
				   and trimestre     = _trim_reas
				   and borderaux     = _borderaux;

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
			        v_cod_ramo,
					_serie,
					_xnivel,
					v_prima50, 
					_comision, 
					_impuesto, 
					_por_pagar,
					_siniestro50,
					0,
					0,
					0,
					v_clase,
					_anio_reas,
					_trim_reas,
					_borderaux);

			  	END

		END FOREACH		

		Update reacoest
		   set participar = prima_neta - siniestro,
		  	   p_partic   = prima * 1,
		       resultado  = siniestro * 1 
		 where anio       = _anio_reas
		   and trimestre  = _trim_reas
		   and borderaux  = _borderaux;
	end if

-- 06	FASCILIDAD CAR
	if _borderaux = '06' then	 -- FASCILIDAD CAR

		-- Ingresa el cuadro FACILIDAD CAR MAPFRE
		-- CARACTERISTICAS : del 2007 hasta la fecha, contrato = '00584','00574'
		-- and cod_cobertura = '001' --and cod_ramo = '001' --and cod_coasegur = '036' 
		-- trace on;

		LET _cod_coasegur     = '063';  
		LET _porc_cont_partic = 100 ;
		LET _porc_comision    = 0;
		LET _porc_impuesto    = 0;

		FOREACH
		   select serie,tipo_contrato,porc_cont_partic,porc_comision,porc_impuesto,cod_ramo,cod_contrato,cod_cobertura,sum(prima)
		     into _serie,v_tipo_contrato,_porc_cont_partic,_porc_comision,_porc_impuesto,v_cod_ramo,v_cod_contrato,v_cobertura,v_prima
		     from temphg
		    Where serie >= 2007 and seleccionado = 1
			  and anio      = _anio_reas
			  and trimestre = _trim_reas
			  and borderaux = _borderaux 
		    group by serie,tipo_contrato,porc_cont_partic,porc_comision,porc_impuesto,cod_ramo,cod_contrato,cod_cobertura


					SELECT sum(t.pagado_neto)  -- sum(reserva_neto) 	
					  INTO _siniestro	
					  FROM tmp_sinis t, reacomae r
					 where t.cod_ramo = v_cod_ramo	
				       and r.cod_contrato = t.cod_contrato 
				       and r.serie = _serie and t.seleccionado = 1 and t.tipo_contrato in ('1') 
					   and t.cod_contrato = v_cod_contrato;

					if _siniestro is null then
					   let _siniestro = 0  ;
				    end if

					let v_clase = v_cod_ramo;

					if  v_cod_ramo = '001' or v_cod_ramo = '003' then 
		--				 let v_clase = '1';
						 let _xnivel = '001';
						if v_cobertura = '021' and v_cod_ramo = '001' then
							let  v_clase = 'INT';
							let _siniestro = 0  ;
						end if
						if v_cobertura = '001' and v_cod_ramo = '001' then
							let  v_clase = 'INI';
						end if
						if v_cobertura = '022' and v_cod_ramo = '003' then
							let  v_clase = 'MUT';
							let _siniestro = 0  ;
						end if
						if v_cobertura = '003' and v_cod_ramo = '003' then
							let  v_clase = 'MUI';
						end if
				    else
			 			 let _xnivel = '002';
					end if

					LET _p_50_prima     = 100;
					LET _p_50_siniestro = 100;

					LET v_prima50 =  (v_prima * _p_50_prima)/100;
					LET _siniestro50 =  (_siniestro * _p_50_siniestro)/100;

		{			LET _comision = v_prima50 * 0.42 ;
					LET _impuesto = v_prima50 * 0.02 ;	}
					LET _comision = v_prima50 * _porc_comision /100;
					LET _impuesto = v_prima50 * _porc_impuesto /100;	

					LET _por_pagar = v_prima50 - _comision - _impuesto ;

				   	BEGIN
					ON EXCEPTION IN(-239)
						UPDATE reacoest
						   SET prima         = prima + v_prima50, 
						   	   comision      = comision + _comision, 
						   	   impuesto      = impuesto + _impuesto, 
						   	   prima_neta    = prima_neta + _por_pagar, 
						  	   siniestro     = siniestro + _siniestro50 
						 WHERE cod_coasegur	 = _cod_coasegur
						   AND cod_contrato  = _serie
						   AND cod_cobertura = _xnivel
		--				   AND p_partic      = _porc_cont_partic
						   AND cod_ramo      = v_cod_ramo
						   and cod_clase     = v_clase 
						   and anio          = _anio_reas
						   and trimestre     = _trim_reas
						   and borderaux     = _borderaux;

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
					        v_cod_ramo,
							_serie,
							_xnivel,
							v_prima50, 
							_comision, 
							_impuesto, 
							_por_pagar,
							_siniestro50,
							0,
							0,
							0,
							v_clase,
							_anio_reas,
							_trim_reas,
							_borderaux);

				  	END

		END FOREACH		

		Update reacoest
		   set participar = prima_neta - siniestro,
		  	   p_partic   = prima * 1,
		       resultado  = siniestro * 1 
		 where anio       = _anio_reas
		   and trimestre  = _trim_reas
		   and borderaux  = _borderaux;

	end if

-- 07	ALLIED CUOTA PARTE
	if _borderaux = '07' then	 -- ALLIED CUOTA PARTE
		-- Ingresa el cuadro ALLIED
		-- CARACTERISTICAS : >= 2006 hasta la fecha, contrato = "00544","00562","00570","00580"
		-- and cod_cobertura = '001' --and cod_ramo = '001' --and cod_coasegur = '036' 
		-- trace on;

		LET _cod_coasegur     = '063';  
		LET _porc_cont_partic = 100 ;
		LET _porc_comision    = 0;
		LET _porc_impuesto    = 0;

		FOREACH
		   select serie,tipo_contrato,porc_cont_partic,porc_comision,porc_impuesto,cod_ramo,cod_contrato,cod_cobertura,sum(prima)
		     into _serie,v_tipo_contrato,_porc_cont_partic,_porc_comision,_porc_impuesto,v_cod_ramo,v_cod_contrato,v_cobertura,v_prima
		     from temphg
		    Where serie >= 2006 and seleccionado = 1
			  and anio      = _anio_reas
			  and trimestre = _trim_reas
			  and borderaux = _borderaux 
		    group by serie,tipo_contrato,porc_cont_partic,porc_comision,porc_impuesto,cod_ramo,cod_contrato,cod_cobertura

				if v_tipo_contrato <> 1 then 
					continue foreach;
				end if

				SELECT sum(t.pagado_neto)  -- sum(reserva_neto) 	
				  INTO _siniestro	
				  FROM tmp_sinis t, reacomae r
				 where t.cod_ramo = v_cod_ramo	
				   and r.cod_contrato = t.cod_contrato
				   and t.cod_contrato in ("00544","00562","00570","00580")
				   and r.serie = _serie and t.seleccionado = 1 and t.tipo_contrato in ('1') ;  

				if _siniestro is null then
				   let _siniestro = 0  ;
				end if

				let v_clase = v_cod_ramo;

				LET _p_50_prima = 50;
				LET _p_50_siniestro = 50;

				LET v_prima50 =  (v_prima * _p_50_prima)/100;
				LET _siniestro50 =  (_siniestro * _p_50_siniestro)/100;

	{				LET _comision = v_prima50 * 0.42 ;
					LET _impuesto = v_prima50 * 0.02 ;	}
				LET _comision = v_prima50 * _porc_comision /100;
				LET _impuesto = v_prima50 * _porc_impuesto /100;	

				if  v_cod_ramo = '001' or v_cod_ramo = '003' then 
	--				let v_clase = '1';
					let _xnivel = '001';
					if v_cobertura = '021' and v_cod_ramo = '001' then
						let  v_clase = 'INT';
						let _siniestro = 0  ;
						LET _comision = v_prima50 * 0.225;
					end if
					if v_cobertura = '001' and v_cod_ramo = '001' then
						let  v_clase = 'INI';
					end if
					if v_cobertura = '022' and v_cod_ramo = '003' then
						let  v_clase = 'MUT';
						let _siniestro = 0  ;
						LET _comision = v_prima50 * 0.225;
					end if
					if v_cobertura = '003' and v_cod_ramo = '003' then
						let  v_clase = 'MUI';
					end if
			    else
		 			 let _xnivel = '002';
				end if

				LET _por_pagar = v_prima50 - _comision - _impuesto;

		--			if v_cod_ramo = '010' or v_cod_ramo = '011' or  v_cod_ramo = '012' or v_cod_ramo = '013' or  v_cod_ramo = '014' then 
		--				 let v_clase = '3' ;
		--				 let _xnivel = '002';
		--			end if								

				   	BEGIN
					ON EXCEPTION IN(-239)
						UPDATE reacoest
						   SET prima         = prima      + v_prima50, 
						       comision      = comision   + _comision, 
						   	   impuesto      = impuesto   + _impuesto, 
						   	   prima_neta    = prima_neta + _por_pagar, 
						   	   siniestro     = siniestro  + _siniestro50 
						 WHERE cod_coasegur	 = _cod_coasegur
						   AND cod_contrato  = _serie
						   AND cod_cobertura = _xnivel
		--				   AND p_partic = _porc_cont_partic
						   AND cod_ramo      = v_cod_ramo
						   and cod_clase     = v_clase 
						   and anio          = _anio_reas
						   and trimestre     = _trim_reas
						   and borderaux     = _borderaux;

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
					        v_cod_ramo,
							_serie,
							_xnivel,
							v_prima50, 
							_comision, 
							_impuesto, 
							_por_pagar,
							_siniestro50,
							0,
							0,
							0,
							v_clase,
							_anio_reas,
							_trim_reas,
							_borderaux);

				  	END

		END FOREACH		

		Update reacoest
		   set participar = prima_neta - siniestro,
		  	   p_partic   = prima * 2,
		       resultado  = siniestro * 2 
		 where anio       = _anio_reas
		   and trimestre  = _trim_reas
		   and borderaux  = _borderaux;


	end if
END FOREACH

if _error <> 0 then
--	rollback work;
	return _error, _error_desc;
else
--	commit work;
	return 0, "Actualizacion Exitosa ...";
end if

END

END PROCEDURE  	   