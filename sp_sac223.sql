-- Cuadre entre los contratos de reaseguro y la contabilidad

-- Creado    : 04/02/2010 - Autor: Demetrio Hurtado Almanza 

-- SIS v.2.0 -- -- DEIVID, S.A.

drop procedure sp_sac223;

create procedure "informix".sp_sac223(
a_periodo1	char(7),
a_periodo2	char(7)
) returning char(10),
            dec(16,2),
            dec(16,2),
            char(5),
            char(50),
            char(3),
            char(50);

define _tipo_registro		smallint;
define _cant_reaseguro  	smallint;  
define _orden				smallint;
define _traspaso			smallint;
define _tipo_contrato   	smallint;
define _tiene_comis_rea		smallint;
define _bouquet			 	smallint;
define _renglon				smallint;
define _tipo_comp       	smallint;
define _es_terremoto       	smallint;
define _cantidad	       	smallint;
define _no_cambio	       	smallint;
define _tipo_transaccion	smallint;

define _debito          	dec(16,2);
define _credito         	dec(16,2);
define _prima_suscrita		dec(16,2);
define _prima_neta			dec(16,2);
define _monto				dec(16,2);
define _monto2				dec(16,2);
define _monto3				dec(16,2);
define _fac_comision		dec(16,2);
define _fac_impuesto		dec(16,2);
define _monto_reas		 	dec(16,2);
define _prima			 	dec(16,2);
define _coas_por_pagar	 	dec(16,2);
define _suma_comision	 	dec(16,2);
define _suma_impuesto	 	dec(16,2);

define _porc_partic_prima	dec(9,6);

define _porc_partic_coas    dec(7,4);

define _factor_impuesto		dec(5,2);
define _porc_comis_agt  	dec(5,2);
define _porc_cont_partic	dec(5,2);
define _porc_comis_ase   	dec(5,2);

define _tipo_mov         	char(1);  

define _cod_ramo        	char(3);
define _cod_subramo     	char(3);
define _cod_cober_reas  	char(3);
define _cod_coasegur		char(3);
define _cod_origen_aseg		char(3);
define _centro_costo		char(3);
define _cod_lider			char(3);
define _cod_tipotran		char(3);

define _cod_contrato		char(5);
define _no_unidad			char(5);
define _cod_traspaso		char(5);
define _cod_auxiliar		char(5);
define _aux_bouquet		 	char(5);
define _no_endoso			char(5);
define _cod_cobertura	  	char(5);

define _periodo				char(7);
define _periodo2			char(7);

define _no_registro			char(10);
define _no_poliza			char(10);
define _no_remesa			char(10);
define _no_tranrec			char(10);
define _no_factura			char(10);
define _no_reclamo			char(10);

define _cuenta          	char(25);

define _nombre_aux			char(50);
define _nombre_ramo			char(50);

define _fecha				date;
define _fecha_anulado		date;

define _error				integer;
define _error_isam			integer;
define _error_desc			char(50);

------------------------------------------------------------------------------
--                          Tipos de Comprobantes
------------------------------------------------------------------------------
-- 1.	Comprobante de Reaseguro Cajas y Comprobantes

-- 2.	Comprobante de Reaseguro Reclamos Pagos
-- 3.	Comprobante de Reaseguro Reclamos Salvamentos
-- 4.	Comprobante de Reaseguro Reclamos Recuperos
-- 5.	Comprobante de Reaseguro Reclamos Deducibles

-- 10.	Comprobante de Reaseguro Produccion Incendio
-- 11.	Comprobante de Reaseguro Produccion Automovil
-- 12.	Comprobante de Reaseguro Produccion Fianzas
-- 13.	Comprobante de Reaseguro Produccion Personas
-- 14.	Comprobante de Reaseguro Produccion Patrimoniales
 
------------------------------------------------------------------------------

--set debug file to "sp_par296.trc";
--trace on;

set isolation to dirty read;

begin 
on exception set _error, _error_isam, _error_desc
	drop table tmp_reas;
	drop table tmp_comp;
	return _error, 0, 0, "", _error_desc, "", "";
end exception

create temp table tmp_reas(
no_unidad		char(5),
cod_cober_reas	char(3),
cod_contrato	char(5),
prima_tot		dec(16,2),
prima_rea		dec(16,2),
es_terremoto   	smallint,
bouquet			smallint,
orden			smallint
) with no log;

create index idx_tmp_reas_1 on tmp_reas(no_unidad, cod_contrato, es_terremoto);
create index idx_tmp_reas_2 on tmp_reas(no_unidad, cod_contrato, cod_cober_reas);
create index idx_tmp_reas_3 on tmp_reas(bouquet);

create temp table tmp_comp(
no_registro		char(10),
cod_auxiliar	char(5),
monto_cal		dec(16,2),
monto_sac		dec(16,2)
) with no log;

select par_ase_lider
  into _cod_lider
  from parparam
 where cod_compania = "001";

foreach
 select tipo_registro,
	    no_poliza,	
	    no_endoso,	
	    no_remesa,	
	    renglon,		
	    no_tranrec,
	    fecha,	
	    periodo,
		no_registro
   into _tipo_registro,
	    _no_poliza,	
	    _no_endoso,	
	    _no_remesa,	
	    _renglon,		
	    _no_tranrec,
	    _fecha_anulado,	
	    _periodo,
		_no_registro
   from sac999:reacomp
  where periodo >= a_periodo1
    and periodo <= a_periodo2
	and tipo_registro = 2
--	and no_registro = "1185518"
--	and no_remesa     = "558709"
--	and renglon       = 1

	if _tipo_registro = 1 then -- Produccion

		select prima_suscrita,
		       no_factura
		  into _prima_suscrita,
		       _no_factura
		  from endedmae
		 where no_poliza = _no_poliza
		   and no_endoso = _no_endoso;

		select cod_ramo,
		       cod_subramo
		  into _cod_ramo,
		       _cod_subramo
		  from emipomae
		 where no_poliza = _no_poliza;

		select count(*)
		  into _cant_reaseguro
		  from emifacon
		 where no_poliza = _no_poliza
		   and no_endoso = _no_endoso;

		if _cant_reaseguro = 0     and
		   _prima_suscrita <> 0.00 Then

			drop table tmp_reas;
			drop table tmp_comp;
			return 1, 0, 0, "", "No Existe Distribucion de Reaseguro Para Factura: " || _no_factura, "", "";

		end if

		delete from tmp_reas;

		if _cod_ramo in ("001", "003") then

			foreach
			 select cod_contrato,
			        cod_cober_reas,
					sum(prima),
					no_unidad
			   into	_cod_contrato,
			        _cod_cober_reas,
					_prima,
					_no_unidad
			   from emifacon
			  where no_poliza = _no_poliza
			    and no_endoso = _no_endoso
			  group by no_unidad, cod_contrato, cod_cober_reas

				select bouquet
				  into _bouquet
				  from reacocob
				 where cod_contrato   = _cod_contrato
				   and cod_cober_reas = _cod_cober_reas;

				select es_terremoto
				  into _es_terremoto
				  from reacobre
				 where cod_cober_reas = _cod_cober_reas;

				insert into tmp_reas
				values (_no_unidad, _cod_cober_reas, _cod_contrato, _prima, 0.00, _es_terremoto, _bouquet, 1);

			end foreach
					  
			-- Cuando el Contrato Es Bouquet

			let _bouquet = 1;

			foreach
			 select no_unidad,
			        cod_contrato,
			        sum(prima_tot)
			   into _no_unidad,
			        _cod_contrato,
			        _prima
			   from tmp_reas
			  where bouquet = 1
			  group by no_unidad, cod_contrato
			  order by no_unidad, cod_contrato

				select count(*)
				  into _cantidad
				  from tmp_reas
				 where no_unidad    = _no_unidad
				   and cod_contrato = _cod_contrato
				   and es_terremoto = 0;

				if _cantidad = 0 then

					select cod_cober_reas,
					       es_terremoto
					  into _cod_cober_reas,
					       _es_terremoto
					  from reacobre
					 where cod_ramo     = _cod_ramo
					   and es_terremoto = 0;

					insert into tmp_reas
					values (_no_unidad, _cod_cober_reas, _cod_contrato, 0.00, 0.00, _es_terremoto, _bouquet, 1);

				end if

				update tmp_reas
				   set prima_rea    = _prima * .70
				 where no_unidad    = _no_unidad
				   and cod_contrato = _cod_contrato
				   and es_terremoto = 0;

				select count(*)
				  into _cantidad
				  from tmp_reas
				 where no_unidad    = _no_unidad
				   and cod_contrato = _cod_contrato
				   and es_terremoto = 1;

				if _cantidad = 0 then

					select cod_cober_reas,
					       es_terremoto
					  into _cod_cober_reas,
					       _es_terremoto
					  from reacobre
					 where cod_ramo     = _cod_ramo
					   and es_terremoto = 1;

					insert into tmp_reas
					values (_no_unidad, _cod_cober_reas, _cod_contrato, 0.00, 0.00, _es_terremoto, _bouquet, 1);

				end if

				update tmp_reas
				   set prima_rea    = _prima * .30
				 where no_unidad    = _no_unidad
				   and cod_contrato = _cod_contrato
				   and es_terremoto = 1;

			end foreach

			-- Cuando el Contrato No Es Bouquet

			foreach
			 select no_unidad,
			        cod_cober_reas,
			        cod_contrato
			   into _no_unidad,
			        _cod_cober_reas,
			        _cod_contrato
			   from tmp_reas
			  where bouquet = 0

				select prima
				  into	_prima
				  from emifacon
				 where no_poliza      = _no_poliza
				   and no_endoso      = _no_endoso
				   and no_unidad      = _no_unidad
				   and cod_cober_reas = _cod_cober_reas
				   and cod_contrato   = _cod_contrato;

				update tmp_reas
				   set prima_rea      = _prima
				 where no_unidad      = _no_unidad
				   and cod_contrato   = _cod_contrato
				   and cod_cober_reas = _cod_cober_reas;

			end foreach

		else
		
			foreach
			 select cod_contrato,
			        prima,
					cod_cober_reas,
					no_unidad,
					orden
			   into _cod_contrato,
			        _prima,
					_cod_cober_reas,
					_no_unidad,
					_orden
			   from emifacon
			  where no_poliza = _no_poliza
			    and no_endoso = _no_endoso

				insert into tmp_reas
				values (_no_unidad, _cod_cober_reas, _cod_contrato, _prima, _prima, 0, 0, _orden);

			end foreach

		end if
				
		-- Generacion del Asiento

		foreach
		 select cod_contrato,
		        prima_rea,
				cod_cober_reas,
				no_unidad,
				orden
		   into _cod_contrato,
		        _monto,
				_cod_cober_reas,
				_no_unidad,
				_orden
		   from tmp_reas

			select traspaso
			  into _traspaso
			  from reacocob
			 where cod_contrato   = _cod_contrato
			   and cod_cober_reas = _cod_cober_reas;

			select tipo_contrato,
			       porc_impuesto,
				   cod_traspaso
		      into _tipo_contrato,
			       _factor_impuesto,
				   _cod_traspaso
			  from reacomae
			 where cod_contrato = _cod_contrato;

			if _traspaso = 1 then

				let _cod_contrato = _cod_traspaso;

				select tipo_contrato,
				       porc_impuesto
				  into _tipo_contrato,
				       _factor_impuesto
				  from reacomae
				 where cod_contrato = _cod_contrato;

			end if

			if _tipo_contrato = 1 Then -- Retencion

				continue foreach;

			elif _tipo_contrato = 3 Then -- Contratos Facultativos

				foreach
				 select prima,
				        porc_impuesto,
						porc_comis_fac,
						cod_coasegur,
						monto_comision,
						monto_impuesto
				   into _monto,
						_factor_impuesto,
				   		_porc_comis_agt,
						_cod_coasegur,
						_fac_comision,
						_fac_impuesto
				   from emifafac
				  where no_poliza      = _no_poliza
				    and no_endoso      = _no_endoso
					and no_unidad      = _no_unidad
					and cod_cober_reas = _cod_cober_reas

					select cod_origen
					  into _cod_origen_aseg
					  from emicoase
					 where cod_coasegur = _cod_coasegur;

					-- Reaseguro Cedido

					let _monto3 = _monto;

					if _monto <> 0.00 then

						let _debito  = 0.00;
						let _credito = 0.00;

						if _monto > 0.00 then
							let _debito  = _monto;
						else
							let _credito = _monto * -1;
						end if

						let _cuenta = sp_sis15("PGRCSD", "05", _cod_origen_aseg, _cod_ramo, _cod_subramo);   

					end if

					-- Comision Ganada

					let _monto2 = _fac_comision;

					if _monto2 <> 0.00 then

						let _monto3  = _monto3 - _monto2;

						let _monto2	 = _monto2 * -1;
						let _debito  = 0.00;
						let _credito = 0.00;

						if _monto2 > 0.00 then
							let _debito  = _monto2;
						else
							let _credito = _monto2 * -1;
						end if

						let _cuenta = sp_sis15("PICGRCSD", "05", _cod_origen_aseg, _cod_ramo, _cod_subramo);   
						   
					end if

					-- Impuesto Recuperado

					let _monto2 = _fac_impuesto;

					if _monto2 <> 0.00 then

						let _monto3  = _monto3 - _monto2;

						let _monto2	 = _monto2 * -1;
						let _debito  = 0.00;
						let _credito = 0.00;

						if _monto2 > 0.00 then
							let _debito  = _monto2;
						else
							let _credito = _monto2 * -1;
						end if

						let _cuenta = sp_sis15("PIIRRCSD", "05", _cod_origen_aseg, _cod_ramo, _cod_subramo);   

					end if

					-- Reaseguro por Pagar

					if _monto3 <> 0.00 then

						let _monto3	 = _monto3 * -1;
						let _debito  = 0.00;
						let _credito = 0.00;

						if _monto3 > 0.00 then
							let _debito  = _monto3;
						else
							let _credito = _monto3 * -1;
						end if

						let _cuenta = sp_sis15("PPRXP", "05", _cod_origen_aseg, _cod_ramo, _cod_subramo);   

						call sp_sac65(_cod_coasegur) returning _error, _error_desc, _cod_auxiliar;

						if _error <> 0 then
							return _error, 0, 0, "", _error_desc, "", "";
						end if
						
					end if

				end foreach

			else -- Otros Contratos

				Select porc_impuesto,
				       porc_comision,
					   cod_coasegur,
					   tiene_comision,
					   bouquet
				  Into _factor_impuesto,
					   _porc_comis_agt,
					   _cod_coasegur,
					   _tiene_comis_rea,
					   _bouquet
				  From reacocob
				 Where cod_contrato   = _cod_contrato
				   And cod_cober_reas = _cod_cober_reas;
				
				foreach
				 select cod_coasegur,
				        porc_cont_partic,
						porc_comision
				   into _cod_coasegur,
				        _porc_cont_partic,
						_porc_comis_ase
				   from reacoase
			      where cod_contrato   = _cod_contrato
			        and cod_cober_reas = _cod_cober_reas
					and cod_coasegur   <> "036"  -- No Incluye Ancon     
					
					-- La comision se calcula por reasegurador

					if _tiene_comis_rea = 2 then 
						let _porc_comis_agt = _porc_comis_ase;
					end if

					select cod_origen,
						   aux_bouquet
					  into _cod_origen_aseg,
						   _aux_bouquet
					  from emicoase
					 where cod_coasegur = _cod_coasegur;

					-- Reaseguro Cedido
					
					let _monto_reas = _monto * _porc_cont_partic / 100;
					let _monto3     = _monto_reas;

					If _monto_reas <> 0.00 Then

						Let _debito  = 0.00;
						Let _credito = 0.00;

						if _monto > 0.00 then
							Let _debito  = _monto_reas;
						else
							Let _credito = _monto_reas * -1;
						end if

						let _cuenta = sp_sis15("PGRCSD", "05", _cod_origen_aseg, _cod_ramo, _cod_subramo);   

					End If

					-- Comision Ganada

					Let _monto2 = _monto_reas * _porc_comis_agt / 100;

					If _monto2 <> 0.00 Then

						Let _monto3  = _monto3 - _monto2;

						let _monto2	 = _monto2 * -1;
						Let _debito  = 0.00;
					
						Let _credito = 0.00;

						if _monto2 > 0.00 then
							Let _debito  = _monto2;
						else
							Let _credito = _monto2 * -1;
						end if

						let _cuenta = sp_sis15("PICGRCSD", "05", _cod_origen_aseg, _cod_ramo, _cod_subramo);   

					End If

					-- Impuesto Recuperado

					Let _monto2 = _monto_reas * _factor_impuesto / 100;

					If _monto2 <> 0.00 Then

						Let _monto3  = _monto3 - _monto2;

						let _monto2	 = _monto2 * -1;
						Let _debito  = 0.00;
						Let _credito = 0.00;

						if _monto2 > 0.00 then
							Let _debito  = _monto2;
						else
							Let _credito = _monto2 * -1;
						end if

						let _cuenta = sp_sis15("PIIRRCSD", "05", _cod_origen_aseg, _cod_ramo, _cod_subramo);   

					End If

					-- Reaseguro por Pagar

					if _monto3 <> 0.00 Then

						let _monto3	 = _monto3 * -1;
						Let _debito  = 0.00;
						Let _credito = 0.00;

						if _monto3 > 0.00 then
							Let _debito  = _monto3;
						else
							Let _credito = _monto3 * -1;
						end if

				
						if _bouquet = 1 then

							let _cuenta       = sp_sis15("PPPRXPB", '03');
							let _cod_auxiliar = _aux_bouquet;   

						else

							let _cuenta = sp_sis15("PPRXP", "05", _cod_origen_aseg, _cod_ramo, _cod_subramo);   
							call sp_sac65(_cod_coasegur) returning _error, _error_desc, _cod_auxiliar;

							if _error <> 0 then
								return _error, 0, 0, "", _error_desc, "", "";
							end if

						end if

					end if

				end foreach
						   					
			End If

		End Foreach

	elif _tipo_registro = 2 then -- Cobros

		let _tipo_comp = 1;

		select cod_ramo,
		       cod_subramo
		  into _cod_ramo,
		       _cod_subramo
		  from emipomae
		 where no_poliza = _no_poliza;

		-- Centro de Costo

		call sp_sac93(_no_poliza, 1) returning _error, _error_desc, _centro_costo;

		if _error <> 0 then
			drop table tmp_reas;
			let _error_desc = "Error en sp_sac93" || " Poliza " || _no_poliza;
			return _error, 0, 0, "", _error_desc, "", "";
		end if

		select prima_neta,
		       tipo_mov,
			   fecha
		  into _prima_neta,
		       _tipo_mov,
			   _fecha
		  from cobredet
		 where no_remesa = _no_remesa
		   and renglon   = _renglon;

		select porc_partic_coas
		  into _porc_partic_coas
		  from emicoama
		 where no_poliza    = _no_poliza
		   and cod_coasegur = _cod_lider;
		
		if _porc_partic_coas is null then
			let _porc_partic_coas = 100;
		end if

		let _prima_suscrita = _prima_neta * _porc_partic_coas / 100;

---------------------------------------------------------------------------------------------------------------------------
		 select count(*)
		   into _cantidad
		   from emireama	
		  where no_poliza       = _no_poliza
		    and vigencia_inic  <= _fecha
		    and vigencia_final >= _fecha;

		 if _cantidad = 0 then

				select count(*)
				  into _cantidad
				  from emireama	
				 where no_poliza = _no_poliza;

				if _cantidad = 0 then

					return _no_poliza, _prima_neta, 0, "", "No Existe Distribucion de Reaseguro", "", "" with resume;

				else

					select max(no_cambio)
					  into _no_cambio
					  from emireama	
					 where no_poliza = _no_poliza;

				end if

		 else

				select max(no_cambio)
				  into _no_cambio
				  from emireama	
				 where no_poliza      = _no_poliza
				   and vigencia_inic  <= _fecha
				   and vigencia_final >= _fecha;

		 end if

		 select min(no_unidad)
		   into _no_unidad
		   from emireama
		  where no_poliza = _no_poliza
		    and no_cambio = _no_cambio; 			    	

		 select min(cod_cober_reas)
		   into _cod_cober_reas
		   from emireama
		  where no_poliza = _no_poliza
		    and no_unidad = _no_unidad
		    and no_cambio = _no_cambio;

		{
		select max(no_cambio)
		  into _no_cambio
		  from emireaco
		 where no_poliza = _no_poliza;

		select min(no_unidad)
		  into _no_unidad
		  from emireaco
		 where no_poliza = _no_poliza
		   and no_cambio = _no_cambio;
		   
		select min(cod_cober_reas)
		  into _cod_cober_reas
		  from emireaco
		 where no_poliza = _no_poliza
		   and no_unidad = _no_unidad
		   and no_cambio = _no_cambio;
		}

---------------------------------------------------------------------------------------------------------------------------


		delete from tmp_reas;

		foreach
		 select cod_contrato,
		        porc_partic_prima
		   into _cod_contrato,
		        _porc_partic_prima
		   from emireaco
		  where no_poliza      = _no_poliza
		    and no_unidad      = _no_unidad
		    and no_cambio      = _no_cambio
			and cod_cober_reas = _cod_cober_reas

			select bouquet
			  into _bouquet
			  from reacocob
			 where cod_contrato   = _cod_contrato
			   and cod_cober_reas = _cod_cober_reas;

			if _bouquet = 1 then

				select es_terremoto
				  into _es_terremoto
				  from reacobre
				 where cod_cober_reas = _cod_cober_reas;

				let _prima = _prima_suscrita * _porc_partic_prima / 100;

				insert into tmp_reas
				values (_no_unidad, _cod_cober_reas, _cod_contrato, _prima, 0.00, _es_terremoto, _bouquet, 1);

			end if

		end foreach

		if _cod_ramo in ("001", "003") then

			let _bouquet = 1;

			foreach
			 select no_unidad,
			        cod_contrato,
			        sum(prima_tot)
			   into _no_unidad,
			        _cod_contrato,
			        _prima
			   from tmp_reas
			  group by no_unidad, cod_contrato
			  order by no_unidad, cod_contrato

				select count(*)
				  into _cantidad
				  from tmp_reas
				 where no_unidad    = _no_unidad
				   and cod_contrato = _cod_contrato
				   and es_terremoto = 0;

				if _cantidad = 0 then

					select cod_cober_reas,
					       es_terremoto
					  into _cod_cober_reas,
					       _es_terremoto
					  from reacobre
					 where cod_ramo     = _cod_ramo
					   and es_terremoto = 0;

					insert into tmp_reas
					values (_no_unidad, _cod_cober_reas, _cod_contrato, 0.00, 0.00, _es_terremoto, _bouquet, 1);

				end if

				update tmp_reas
				   set prima_rea    = _prima * .70
				 where no_unidad    = _no_unidad
				   and cod_contrato = _cod_contrato
				   and es_terremoto = 0;

				select count(*)
				  into _cantidad
				  from tmp_reas
				 where no_unidad    = _no_unidad
				   and cod_contrato = _cod_contrato
				   and es_terremoto = 1;

				if _cantidad = 0 then

					select cod_cober_reas,
					       es_terremoto
					  into _cod_cober_reas,
					       _es_terremoto
					  from reacobre
					 where cod_ramo     = _cod_ramo
					   and es_terremoto = 1;

					insert into tmp_reas
					values (_no_unidad, _cod_cober_reas, _cod_contrato, 0.00, 0.00, _es_terremoto, _bouquet, 1);

				end if

				update tmp_reas
				   set prima_rea    = _prima * .30
				 where no_unidad    = _no_unidad
				   and cod_contrato = _cod_contrato
				   and es_terremoto = 1;

			end foreach

		else

			update tmp_reas
			   set prima_rea = prima_tot;

		end if

		foreach
		 select cod_contrato,
		        prima_rea,
				cod_cober_reas,
				no_unidad,
				orden
		   into _cod_contrato,
		        _prima,
				_cod_cober_reas,
				_no_unidad,
				_orden
		   from tmp_reas

			select porc_impuesto,
			       porc_comision,
				   cod_coasegur,
				   tiene_comision,
				   bouquet
			  into _factor_impuesto,
				   _porc_comis_agt,
				   _cod_coasegur,
				   _tiene_comis_rea,
				   _bouquet
			  from reacocob
			 where cod_contrato   = _cod_contrato
			   and cod_cober_reas = _cod_cober_reas;

			foreach
			 select cod_coasegur,
			        porc_cont_partic,
					porc_comision
			   into _cod_coasegur,
			        _porc_cont_partic,
					_porc_comis_ase
			   from reacoase
		      where cod_contrato   = _cod_contrato
		        and cod_cober_reas = _cod_cober_reas
				and cod_coasegur   <> "036"  -- No Incluye Ancon     

				-- La comision se calcula por reasegurador

				if _tiene_comis_rea = 2 then 
					let _porc_comis_agt = _porc_comis_ase;
				end if

				select cod_origen,
					   aux_bouquet
				  into _cod_origen_aseg,
					   _cod_auxiliar
				  from emicoase
				 where cod_coasegur = _cod_coasegur;

				-- Reaseguro por Pagar	- Calculos
				
				let _monto_reas    = _prima      * _porc_cont_partic / 100;
				let _suma_comision = _monto_reas * _porc_comis_agt   / 100;
				let _suma_impuesto = _monto_reas * _factor_impuesto  / 100;

				let _monto = _monto_reas - _suma_comision - _suma_impuesto;

				insert into tmp_comp
				values (_no_registro, _cod_auxiliar, _monto, 0);

			end foreach

		end foreach

		-- Reaseguro por Pagar - SAC

--		let _cuenta = sp_sis15("PPRXP", "05", _cod_origen_aseg, _cod_ramo, _cod_subramo);   

		foreach
		 select cod_auxiliar,
		        sum(debito - credito)
		   into _cod_auxiliar,
		        _monto
		   from sac999:reacompasiau
		  where no_registro  = _no_registro
		    and cuenta[1,3]  = "231"
		    and tipo_comp    = _tipo_comp
		  group by 1
--		    and cod_auxiliar = _cod_auxiliar;

			insert into tmp_comp
			values (_no_registro, _cod_auxiliar, 0, _monto * -1);

		end foreach

	elif _tipo_registro = 3 then -- Reclamos

		select cod_tipotran,
			   no_reclamo,
			   monto
		  into _cod_tipotran,
			   _no_reclamo,
			   _monto_reas
		  from rectrmae
		 where no_tranrec = _no_tranrec;

		select tipo_transaccion
		  into _tipo_transaccion
		  from rectitra
		 where cod_tipotran = _cod_tipotran;

		if _tipo_transaccion = 4 or
		   _tipo_transaccion = 5 or
		   _tipo_transaccion = 6 or
		   _tipo_transaccion = 7 then

			select no_poliza
			  into _no_poliza	
			  from recrcmae
			 where no_reclamo = _no_reclamo;

			select cod_ramo,
			       cod_subramo
			  into _cod_ramo,
			       _cod_subramo
			  from emipomae
			 where no_poliza = _no_poliza;


			select porc_partic_coas
			  into _porc_partic_coas
			  from reccoas
			 where no_reclamo   = _no_reclamo
			   and cod_coasegur = _cod_lider; 

			if _porc_partic_coas is null then
				let _porc_partic_coas = 100;
			end if

			-- Centro de Costo

			call sp_sac93(_no_poliza, 1) returning _error, _error_desc, _centro_costo;

			if _error <> 0 then
				drop table tmp_reas;
				let _error_desc = "Error en sp_sac93" || " Poliza " || _no_poliza;
				return _error, 0, 0, "", _error_desc, "", "";
			end if

			-- Reaseguro Cedido - Sinestros Pagados

			foreach
			 select cod_contrato,
			        porc_partic_prima,
					tipo_contrato,
					orden
			   into _cod_contrato,
			        _porc_partic_prima,
					_tipo_contrato,
					_orden
			   from rectrrea
			  where no_tranrec    = _no_tranrec
			    and tipo_contrato <> 1

				if _tipo_contrato = 3 then -- Facultativos

					foreach
					 select cod_coasegur,
							porc_partic_reas
					   into	_cod_coasegur,
					        _porc_cont_partic
					   from rectrref
					  where no_tranrec = _no_tranrec
					    and orden      = _orden

						select cod_origen,
							   aux_bouquet,
							   cod_auxiliar
						  into _cod_origen_aseg,
							   _aux_bouquet,
							   _cod_auxiliar
						  from emicoase
						 where cod_coasegur = _cod_coasegur;

						let _monto = _monto_reas / 100 * _porc_partic_coas;
						let _monto = _monto      / 100 * _porc_partic_prima;
						let _monto = _monto      / 100 * _porc_cont_partic;

						if _monto <> 0.00 Then

							-- Participacion de Reaseguradores en Siniestro

							let _debito  = 0.00;
							let _credito = 0.00;

							if _monto >= 0.00 then
								let _credito = _monto;
							else
								let _debito  = _monto * -1;
							end if

							if _tipo_transaccion = 4 then	-- Pago

								let _cuenta    = sp_sis15('RIPDRES', '01', _no_poliza);
								let _tipo_comp = 2;

							elif _tipo_transaccion = 5 then	-- Salvamento

								let _cuenta    = sp_sis15('RIPDRESAL', '01', _no_poliza);
								let _tipo_comp = 3;

							elif _tipo_transaccion = 6 then	-- Recupero

								let _cuenta    = sp_sis15('RIPDREREC', '01', _no_poliza);
								let _tipo_comp = 4;

			   				elif _tipo_transaccion = 7 then	-- Deducible

								let _cuenta    = sp_sis15('RIPDREDED', '01', _no_poliza);
								let _tipo_comp = 5;

							end if

							-- Reaseguro por Pagar

							let _debito  = 0.00;
							let _credito = 0.00;

							if _monto >= 0.00 then
								let _debito  = _monto;
							else
								let _credito = _monto * -1;
							end if

							let _cuenta = sp_sis15("PPRXP", "05", _cod_origen_aseg, _cod_ramo, _cod_subramo);   

						end if
					
					end foreach

				else -- Otros contratos
				
					foreach
					 select cod_cobertura
					   into _cod_cobertura
					   from rectrcob
					  where no_tranrec = _no_tranrec 
						exit foreach;
					end foreach
						
					select cod_cober_reas
					  into _cod_cober_reas
					  from prdcober
					 where cod_cobertura = _cod_cobertura;

					select traspaso,
					       bouquet
					  into _traspaso,
					       _bouquet
					  from reacocob
					 where cod_contrato   = _cod_contrato
					   and cod_cober_reas = _cod_cober_reas;

					{
					if _traspaso = 1 then

						select cod_traspaso
						  into _cod_traspaso
						  from reacomae
						 where cod_contrato = _cod_contrato;

						let _cod_contrato = _cod_traspaso;

					end if
					}

					 select count(*)
					   into	_cantidad
					   from reacoase
					  where cod_contrato   = _cod_contrato 
					    and cod_cober_reas = _cod_cober_reas;

					if _cantidad = 0 then
						
						drop table tmp_reas;
						return 1, 0, 0, "", "No Existe Companias del Contrato: " || _cod_contrato || " Cobertura: " || _cod_cober_reas, "", "";

					end if

					foreach
					 select cod_coasegur,
							porc_cont_partic
					   into	_cod_coasegur,
					        _porc_cont_partic
					   from reacoase
					  where cod_contrato   = _cod_contrato 
					    and cod_cober_reas = _cod_cober_reas  
					    and cod_coasegur   <> "036"  -- No Incluye Ancon     

						select cod_origen,
							   aux_bouquet,
							   cod_auxiliar
						  into _cod_origen_aseg,
							   _aux_bouquet,
							   _cod_auxiliar
						  from emicoase
						 where cod_coasegur = _cod_coasegur;

						let _monto = _monto_reas / 100 * _porc_partic_coas;
						let _monto = _monto      / 100 * _porc_partic_prima;
						let _monto = _monto      / 100 * _porc_cont_partic;

						if _monto <> 0.00 Then

							-- Participacion de Reaseguradores en Siniestro

							let _debito  = 0.00;
							let _credito = 0.00;

							if _monto >= 0.00 then
								let _credito = _monto;
							else
								let _debito  = _monto * -1;
							end if

							if _tipo_transaccion = 4 then	-- Pago

								let _cuenta    = sp_sis15('RIPDRES', '01', _no_poliza);
								let _tipo_comp = 2;

							elif _tipo_transaccion = 5 then	-- Salvamento

								let _cuenta    = sp_sis15('RIPDRESAL', '01', _no_poliza);
								let _tipo_comp = 3;

							elif _tipo_transaccion = 6 then	-- Recupero

								let _cuenta    = sp_sis15('RIPDREREC', '01', _no_poliza);
								let _tipo_comp = 4;

			   				elif _tipo_transaccion = 7 then	-- Deducible

								let _cuenta    = sp_sis15('RIPDREDED', '01', _no_poliza);
								let _tipo_comp = 5;

							end if

							-- Reaseguro por Pagar

							let _debito  = 0.00;
							let _credito = 0.00;

							if _monto >= 0.00 then
								let _debito  = _monto;
							else
								let _credito = _monto * -1;
							end if
							
							if _bouquet = 1 then
								let _cod_auxiliar = _aux_bouquet;
							end if

							let _cuenta = sp_sis15("PPRXP", "05", _cod_origen_aseg, _cod_ramo, _cod_subramo);   

						end if

					end foreach
				
				end if

			end foreach

		end if

	end if

end foreach

foreach
 select	no_registro,
        cod_auxiliar,
		sum(monto_cal),
		sum(monto_sac)
   into	_no_registro,
		_cod_auxiliar,
		_monto,
		_monto2
   from	tmp_comp
  group by 1, 2

	if _monto <> _monto2 then

		select no_poliza
		  into _no_poliza
		  from sac999:reacomp
		 where no_registro = _no_registro;

		select cod_ramo
		  into _cod_ramo
		  from emipomae
		 where no_poliza = _no_poliza;

		if _cod_ramo = "008" and _cod_auxiliar = "BQ042" then

			select ter_descripcion
			  into _nombre_aux
			  from cglterceros
			 where ter_codigo = _cod_auxiliar;

			select nombre
			  into _nombre_ramo
			  from prdramo
			 where cod_ramo = _cod_ramo;

			return _no_registro,
				   _monto,
				   _monto2,
			       _cod_auxiliar,
			       _nombre_aux,
				   _cod_ramo,
				   _nombre_ramo
				   with resume;

		end if

	end if

end foreach

drop table tmp_reas;
drop table tmp_comp;

end

return 0, 0, 0, "", "Actualizacion Exitosa", "", "";

end procedure
