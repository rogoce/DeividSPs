-- Generacion de Registros Contables de Reaseguro

-- Creado    : 04/02/2010 - Autor: Demetrio Hurtado Almanza 

-- SIS v.2.0 -- -- DEIVID, S.A.

drop procedure sp_par296;
create procedure sp_par296(a_no_registro char(10))
returning integer,
		  char(100);

define _tipo_transaccion	smallint;
define _tiene_comis_rea		smallint;
define _cant_reaseguro  	smallint;  
define _tipo_contrato   	smallint;
define _tipo_registro		smallint;
define _es_terremoto       	smallint;
define _cnt_existe,_cnt   	smallint;
define _tipo_comp       	smallint;
define _no_cambio	       	smallint;
define _traspaso			smallint;
define _cantidad	       	smallint;
define _bouquet			 	smallint;
define _renglon				smallint;
define _orden				smallint;

define _prima_suscrita		dec(16,2);
define _monto_reas_cob	 	dec(16,2);
define _coas_por_pagar	 	dec(16,2);
define _suma_comision	 	dec(16,2);
define _suma_impuesto	 	dec(16,2);
define _fac_comision		dec(16,2);
define _fac_impuesto		dec(16,2);
define _prima_neta			dec(16,2);
define _monto_reas		 	dec(16,2);
define _prima_tot		 	dec(16,2);
define _porc_ter          	dec(16,2);
define _porc_inc          	dec(16,2);
define _credito         	dec(16,2);
define _debito          	dec(16,2);
define _monto2				dec(16,2);
define _monto3				dec(16,2);
define _monto				dec(16,2);
define _prima			 	dec(16,2);

define _porc_partic_prima	dec(9,6);

define _porc_partic_coas    dec(7,4);

define _factor_impuesto		dec(5,2);
define _porc_comis_agt  	dec(5,2);
define _porc_cont_partic	dec(5,2);
define _porc_comis_ase   	dec(5,2);
define _porc_proporcion   	dec(5,2);

define _tipo_mov         	char(1);  

define _cod_ramo        	char(3);
define _cod_subramo     	char(3);
define _cod_cober_reas  	char(3);
define _cod_coasegur		char(3);
define _cod_origen_aseg		char(3);
define _centro_costo		char(3);
define _cod_lider			char(3);
define _cod_tipotran		char(3);
define _cod_endomov		char(3);

define _cod_contrato		char(5);
define _no_unidad			char(5);
define _cod_traspaso		char(5);
define _cod_auxiliar		char(5);
define _aux_bouquet		 	char(5);
define _no_endoso			char(5);
define _cod_cobertura	  	char(5);

define _periodo				char(7);
define _periodo2			char(7);

define _no_poliza			char(10);
define _no_remesa			char(10);
define _no_tranrec			char(10);
define _no_factura			char(10);
define _no_reclamo			char(10);

define _no_documento		char(20);

define _cuenta          	char(25);

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

-- 10.Comprobante de Reaseguro Produccion Incendio
-- 11.Comprobante de Reaseguro Produccion Automovil
-- 12.Comprobante de Reaseguro Produccion Fianzas
-- 13.Comprobante de Reaseguro Produccion Personas
-- 14.Comprobante de Reaseguro Produccion Patrimoniales

-- 15	Comprobante de Reaseguro Cheques Pagados  Devolucion Primas
-- 16	Comprobante de Reaseguro Cheques Anulados Devolucion Primas
 
------------------------------------------------------------------------------
--if a_no_registro = '11465866' then
--	set debug file to "sp_par296.trc";
--	trace on;
--end if

set isolation to dirty read;

begin 
on exception set _error, _error_isam, _error_desc
	drop table tmp_reas;
	return _error, _error_desc;
end exception

drop table if exists tmp_reas;
create temp table tmp_reas(
no_unidad			char(5),
cod_cober_reas		char(3),
cod_contrato		char(5),
prima_tot			dec(16,2),
prima_rea			dec(16,2),
es_terremoto   		smallint,
bouquet				smallint,
orden				smallint,
porc_partic_prima	dec(9,6)) with no log;

create index idx_tmp_reas_1 on tmp_reas(no_unidad, cod_contrato, es_terremoto);
create index idx_tmp_reas_2 on tmp_reas(no_unidad, cod_contrato, cod_cober_reas);
create index idx_tmp_reas_3 on tmp_reas(bouquet);

drop table if exists tmp_unidad;

create temp table tmp_unidad(
no_unidad		char(5),
prima_tot		dec(16,2)	default 0.00,
primary key (no_unidad)) with no log;

delete from sac999:reacompasiau where no_registro = a_no_registro;
delete from sac999:reacompasie	where no_registro = a_no_registro;

select par_ase_lider
  into _cod_lider
  from parparam
 where cod_compania = "001";

select tipo_registro,
	   no_poliza,	
	   no_endoso,	
	   no_remesa,	
	   renglon,		
	   no_tranrec,
	   fecha,	
	   periodo
  into _tipo_registro,
	   _no_poliza,	
	   _no_endoso,	
	   _no_remesa,	
	   _renglon,		
	   _no_tranrec,
	   _fecha_anulado,	
	   _periodo
  from sac999:reacomp
 where no_registro = a_no_registro;

-- Fecha de la Transaccion

let _periodo2 = sp_sis39(_fecha_anulado);

if _periodo = _periodo2 then
	let _fecha = _fecha_anulado;
elif _periodo > _periodo2 then
	let _fecha = MDY(_periodo[6,7], 1, _periodo[1,4]);
elif _periodo < _periodo2 then
	let _fecha = sp_sis36(_periodo);
end if

if _tipo_registro = 1 then -- Produccion

	select prima_suscrita,
	       no_factura,
		   cod_endomov
	  into _prima_suscrita,
	       _no_factura,
		   _cod_endomov
	  from endedmae
	 where no_poliza = _no_poliza
	   and no_endoso = _no_endoso;

	-- Centro de Costo

	call sp_sac93(_no_poliza, 1) returning _error, _error_desc, _centro_costo;

	if _error <> 0 then
		drop table tmp_reas;
		let _error_desc = "Error en sp_sac93" || " Poliza " || _no_poliza || " Endoso " || _no_endoso;
		return _error, _error_desc;
	end if

	select cod_ramo,
	       cod_subramo
	  into _cod_ramo,
	       _cod_subramo
	  from emipomae
	 where no_poliza = _no_poliza;

	-- Tipo de Comprobante

	if _cod_ramo in ("001", "003") then		
		let _tipo_comp = 10;				-- Incendio
	elif _cod_ramo in ("002", "020", "023") then	
		let _tipo_comp = 11;				-- Autos
	elif _cod_ramo in ("008") then			
		let _tipo_comp = 12;				-- Fianzas
	elif _cod_ramo in ("004", "016", "018", "019") then	
		let _tipo_comp = 13;				-- Personas
	else
		let _tipo_comp = 14;				-- Patrimoniales
	end if

	select count(*)
	  into _cant_reaseguro
	  from emifacon
	 where no_poliza = _no_poliza
	   and no_endoso = _no_endoso;

	if _cant_reaseguro = 0     and
	   _prima_suscrita <> 0.00 Then

		drop table tmp_reas;
		return 1, "No Existe Distribucion de Reaseguro Para Factura: " || _no_factura;

	end if

	delete from tmp_reas;
	delete from tmp_unidad;

	if _cod_ramo in ("001", "003") and _cod_endomov != '017' and _no_poliza != '3201009' then 

		foreach
			select cod_contrato,
				   cod_cober_reas,
				   sum(prima),
				   no_unidad,
				   porc_partic_prima
			  into _cod_contrato,
				   _cod_cober_reas,
				   _prima,
				   _no_unidad,
				   _porc_partic_prima
			  from emifacon
			 where no_poliza = _no_poliza
			   and no_endoso = _no_endoso
			 group by no_unidad, cod_contrato, cod_cober_reas,porc_partic_prima


			select bouquet
			  into _bouquet
			  from reacocob
			 where cod_contrato   = _cod_contrato
			   and cod_cober_reas = _cod_cober_reas;

			select es_terremoto
			  into _es_terremoto
			  from reacobre
			 where cod_cober_reas = _cod_cober_reas;

			begin
				on exception in(-239,-268)
					update tmp_unidad
					   set prima_tot = prima_tot + _prima
					 where no_unidad = _no_unidad;
				end exception
				
				insert into tmp_unidad(no_unidad,prima_tot)
				values(	_no_unidad,_prima);
			end

			insert into tmp_reas
			values (_no_unidad, _cod_cober_reas, _cod_contrato, _prima, 0.00, _es_terremoto, _bouquet, 1,_porc_partic_prima);
		end foreach

		-- Cuando el Contrato Es Bouquet
		let _bouquet = 1;

		if _cod_ramo = '001' then
			let _porc_inc = .70;
			let _porc_ter = .30;		
		else
			let _porc_inc = .90;
			let _porc_ter = .10;
		end if

		foreach
			select distinct no_unidad,
				   cod_contrato,
				   porc_partic_prima
			  into _no_unidad,
				   _cod_contrato,
				   _porc_partic_prima
			  from tmp_reas
			 where bouquet = 1
			 order by no_unidad, cod_contrato,porc_partic_prima

			select prima_tot
			  into _prima_tot
			  from tmp_unidad
			 where no_unidad = _no_unidad;

			select count(*)
			  into _cnt_existe
			  from reacocob c, reacobre r
			 where c.cod_cober_reas = r.cod_cober_reas
			   and c.cod_contrato = _cod_contrato
			   and r.cod_ramo = _cod_ramo
			   and es_terremoto = 1;

			if _cnt_existe is null then
				let _cnt_existe = 0;
			end if

			if _cnt_existe > 0 then
				let _porc_inc = .70;
				let _porc_ter = .30; 
			end if

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
				   and nombre not like '%INU%'
				   and es_terremoto = 0;

				insert into tmp_reas
				values (_no_unidad, _cod_cober_reas, _cod_contrato, 0.00, 0.00, _es_terremoto, _bouquet, 1,_porc_partic_prima);

			end if

			update tmp_reas
			   set prima_rea    = prima_rea + (_prima_tot * _porc_inc) * (_porc_partic_prima/100)
			 where no_unidad    = _no_unidad
			   and cod_contrato = _cod_contrato
			   and porc_partic_prima = _porc_partic_prima
			   and es_terremoto = 0;

			select count(*)
			  into _cantidad
			  from tmp_reas
			 where no_unidad    = _no_unidad
			   and cod_contrato = _cod_contrato
			   and es_terremoto = 1;

			if _cantidad = 0 and _cnt_existe > 0 then

				select cod_cober_reas,
				       es_terremoto
				  into _cod_cober_reas,
				       _es_terremoto
				  from reacobre
				 where cod_ramo     = _cod_ramo
				   and es_terremoto = 1;

				insert into tmp_reas
				values (_no_unidad, _cod_cober_reas, _cod_contrato, 0.00, 0.00, _es_terremoto, _bouquet, 1,_porc_partic_prima);

			end if

			update tmp_reas
			   set prima_rea    = prima_rea + (_prima_tot * _porc_ter) * (_porc_partic_prima/100)
			 where no_unidad    = _no_unidad
			   and cod_contrato = _cod_contrato
			   and porc_partic_prima = _porc_partic_prima
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
			  into _prima
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
				orden,
				porc_partic_prima
		   into _cod_contrato,
		        _prima,
				_cod_cober_reas,
				_no_unidad,
				_orden,
				_porc_partic_prima
		   from emifacon
		  where no_poliza = _no_poliza
		    and no_endoso = _no_endoso

			insert into tmp_reas
			values (_no_unidad, _cod_cober_reas, _cod_contrato, _prima, _prima, 0, 0, _orden,_porc_partic_prima);

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

--				and orden		   = _orden   se quito por que generaba error para los facultativos 22/04/2010 Armando/Demetrio
				
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

					call sp_par297(a_no_registro, _cuenta, _debito, _credito, _tipo_comp, _periodo, _centro_costo, _fecha);

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
					call sp_par297(a_no_registro, _cuenta, _debito, _credito, _tipo_comp, _periodo, _centro_costo, _fecha);

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
					call sp_par297(a_no_registro, _cuenta, _debito, _credito, _tipo_comp, _periodo, _centro_costo, _fecha);

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
					call sp_par297(a_no_registro, _cuenta, _debito, _credito, _tipo_comp, _periodo, _centro_costo, _fecha);

					call sp_sac65(_cod_coasegur) returning _error, _error_desc, _cod_auxiliar;

					if _error <> 0 then
						return _error, _error_desc;
					end if
					
					call sp_par298(a_no_registro, _cuenta, _debito, _credito, _tipo_comp, _cod_auxiliar, _periodo, _centro_costo, _fecha);

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
				and contrato_xl    = 0

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
					call sp_par297(a_no_registro, _cuenta, _debito, _credito, _tipo_comp, _periodo, _centro_costo, _fecha);

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
					call sp_par297(a_no_registro, _cuenta, _debito, _credito, _tipo_comp, _periodo, _centro_costo, _fecha);

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
					call sp_par297(a_no_registro, _cuenta, _debito, _credito, _tipo_comp, _periodo, _centro_costo, _fecha);

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
						
						if _cod_ramo in ('002','020','023','018') then -- Nuevo Contrato Auto 2024 Román 02/05/2024.													
							let _cuenta = sp_sis15("PPRXP", "05", _cod_origen_aseg, _cod_ramo, _cod_subramo);   
						elif _cod_ramo = '019' then
							select count(*)
							  into _cnt
							  from emifacon e, reacomae r
							 where e.cod_contrato = r.cod_contrato
							   and e.no_poliza = _no_poliza
							   and r.serie >= 2024;
							if _cnt is null then
								let _cnt = 0;
							end if
							if _cnt > 0 then	--serie 2024 o superior para vida no va a cuenta de provision. AMM 11/03/2025
								let _cuenta = sp_sis15("PPRXP", "05", _cod_origen_aseg, _cod_ramo, _cod_subramo);   
							end if
						end if
					else
						
						let _cuenta = sp_sis15("PPRXP", "05", _cod_origen_aseg, _cod_ramo, _cod_subramo);   
						call sp_sac65(_cod_coasegur) returning _error, _error_desc, _cod_auxiliar;

						if _error <> 0 then
							return _error, _error_desc;
						end if

					end if

					call sp_par297(a_no_registro, _cuenta, _debito, _credito, _tipo_comp, _periodo, _centro_costo, _fecha);
					call sp_par298(a_no_registro, _cuenta, _debito, _credito, _tipo_comp, _cod_auxiliar, _periodo, _centro_costo, _fecha);

				end if

			end foreach

		End If

	End Foreach

elif _tipo_registro = 2 then -- Cobros

	let _tipo_comp = 1;
    let _no_unidad = "00001";

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
		return _error, _error_desc;
	end if

	select prima_neta,
	       tipo_mov
	  into _prima_neta,
	       _tipo_mov
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

	delete from tmp_reas;
	delete from tmp_unidad;

	select sum(porc_proporcion * porc_partic_prima / 100)
	  into _porc_partic_prima
      from cobreaco
	 where no_remesa = _no_remesa
	   and renglon   = _renglon;

	if _porc_partic_prima is null then
		let _porc_partic_prima = 0;
	end if

	if _porc_partic_prima <> 100.00 then
		return 1, "% Proporcion No Suma 100% Remesa: " || _no_remesa || "  " || _renglon || " ";
	end if
		
	foreach
		select cod_contrato,
			   cod_cober_reas,
			   porc_partic_prima,
			   porc_proporcion
		  into _cod_contrato,
			   _cod_cober_reas,
			   _porc_partic_prima,
			   _porc_proporcion
		  from cobreaco
		 where no_remesa = _no_remesa
		   and renglon   = _renglon

		select bouquet
		  into _bouquet
		  from reacocob
		 where cod_contrato   = _cod_contrato
		   and cod_cober_reas = _cod_cober_reas;

		let _prima = _prima_suscrita * (_porc_partic_prima / 100) * (_porc_proporcion / 100);
		   
		if _bouquet = 1 then
			if _porc_proporcion = 0 then		
				return 1, "% Proporcion es cero para la Rem: " || _no_remesa || " Rengl: " || _renglon;				 
			end if

			select es_terremoto
			  into _es_terremoto
			  from reacobre
			 where cod_cober_reas = _cod_cober_reas;
			
			insert into tmp_reas
			values (_no_unidad, _cod_cober_reas, _cod_contrato, _prima, 0.00, _es_terremoto, _bouquet, 1,_porc_partic_prima);
		end if
		
		begin
			on exception in(-239,-268)
				update tmp_unidad
				   set prima_tot = prima_tot + _prima
				 where no_unidad = _no_unidad;
			end exception
			insert into tmp_unidad(no_unidad,prima_tot)
			values(	_no_unidad,_prima);
		end
	end foreach

	if _cod_ramo in ("001", "003") then

		let _bouquet = 1;
		
		if _cod_ramo = '001' then
			let _porc_inc = .70;
			let _porc_ter = .30;		
		else
			let _porc_inc = .90;
			let _porc_ter = .10;
		end if

		foreach
			select distinct no_unidad,
				   cod_contrato,
				   porc_partic_prima
			  into _no_unidad,
				   _cod_contrato,
				   _porc_partic_prima
			  from tmp_reas
			 order by no_unidad,cod_contrato,porc_partic_prima

			select prima_tot
			  into _prima_tot
			  from tmp_unidad
			 where no_unidad = _no_unidad;

			select count(*)
			  into _cnt_existe
			  from reacocob c, reacobre r
			 where c.cod_cober_reas = r.cod_cober_reas
			   and c.cod_contrato = _cod_contrato
			   and r.cod_ramo = _cod_ramo
			   and es_terremoto = 1;

			if _cnt_existe is null then
				let _cnt_existe = 0;
			end if

			--Debe ser 70/30 para serie menores a 2014
			if _cnt_existe > 0 then
				if _cod_ramo = '001' then
					let _porc_inc = .70;
					let _porc_ter = .30;		
				else
					let _porc_inc = .90;
					let _porc_ter = .10;
				end if
			end if

			select count(*)
			  into _cantidad
			  from tmp_reas
			 where no_unidad    = _no_unidad
			   and cod_contrato = _cod_contrato
			   and es_terremoto = 0;

			if _cantidad = 0 then

				select cod_cober_reas,  --Revisar porque está trayendo duplicado Amado 18-08-2025
				       es_terremoto
				  into _cod_cober_reas,
				       _es_terremoto
				  from reacobre
				 where cod_ramo     = _cod_ramo
				   and es_terremoto = 0;

				insert into tmp_reas
				values (_no_unidad, _cod_cober_reas, _cod_contrato, 0.00, 0.00, _es_terremoto, _bouquet, 1,_porc_partic_prima);

			end if

			update tmp_reas
			   set prima_rea    = prima_rea + (_prima_tot * _porc_inc) * (_porc_partic_prima/100)
			 where no_unidad    = _no_unidad
			   and cod_contrato = _cod_contrato
			   and porc_partic_prima = _porc_partic_prima
			   and es_terremoto = 0;

			select count(*)
			  into _cantidad
			  from tmp_reas
			 where no_unidad    = _no_unidad
			   and cod_contrato = _cod_contrato
			   and es_terremoto = 1;

			if _cantidad = 0 and _cnt_existe > 0 then

				select cod_cober_reas,
				       es_terremoto
				  into _cod_cober_reas,
				       _es_terremoto
				  from reacobre
				 where cod_ramo     = _cod_ramo
				   and es_terremoto = 1;

				insert into tmp_reas
				values (_no_unidad, _cod_cober_reas, _cod_contrato, 0.00, 0.00, _es_terremoto, _bouquet, 1,_porc_partic_prima);

			end if

			update tmp_reas
			   set prima_rea    = prima_rea + (_prima_tot * _porc_ter) * (_porc_partic_prima/100)
			 where no_unidad    = _no_unidad
			   and cod_contrato = _cod_contrato
			   and porc_partic_prima = _porc_partic_prima
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
			and contrato_xl    = 0

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

			-- Reaseguro Cedido
			
			let _monto_reas    = _prima      * _porc_cont_partic / 100;
			let _suma_comision = _monto_reas * _porc_comis_agt   / 100;
			let _suma_impuesto = _monto_reas * _factor_impuesto  / 100;

			let _monto = _monto_reas - _suma_comision - _suma_impuesto;

			if _monto <> 0.00 Then

				-- Provision por Reasegurador Bouquet

				let _debito  = 0.00;
				let _credito = 0.00;

				if _monto > 0 then
					let _debito  = _monto;
				else
					let _credito = _monto * -1;
				end if

				let _cuenta = sp_sis15("PPPRXPB", '03');
				call sp_par297(a_no_registro, _cuenta, _debito, _credito, _tipo_comp, _periodo, _centro_costo, _fecha);
				call sp_par298(a_no_registro, _cuenta, _debito, _credito, _tipo_comp, _cod_auxiliar, _periodo, _centro_costo, _fecha);

				-- Reaseguro por Pagar Bouquet

				let _debito  = 0.00;
				let _credito = 0.00;

				if _monto > 0 then
					let _credito = _monto;
				else
					let _debito  = _monto * -1;
				end if

				let _cuenta = sp_sis15("PPRXP", "05", _cod_origen_aseg, _cod_ramo, _cod_subramo);   
				call sp_par297(a_no_registro, _cuenta, _debito, _credito, _tipo_comp, _periodo, _centro_costo, _fecha);
				call sp_par298(a_no_registro, _cuenta, _debito, _credito, _tipo_comp, _cod_auxiliar, _periodo, _centro_costo, _fecha);

			end if

		end foreach

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

	select sum(monto)
	  into _monto_reas_cob
	  from rectrcob
	 where no_tranrec = _no_tranrec;

	if _monto_reas <> _monto_reas_cob then

		drop table tmp_reas;
		return 1, "Sumatoria rectrmae vs rectrcob No Cuadra, no_tranrec = " || _no_tranrec;

	end if

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
			return _error, _error_desc;
		end if

		-- Reaseguro Cedido - Sinestros Pagados

		foreach
		 select cod_cobertura,
		        monto
		   into _cod_cobertura,
		        _monto_reas_cob
		   from rectrcob
		  where no_tranrec = _no_tranrec
		    and monto      <> 0

			select cod_cober_reas
			  into _cod_cober_reas
			  from prdcober
			 where cod_cobertura = _cod_cobertura;

			select count(*)
			  into _cantidad
			  from rectrrea
			 where no_tranrec     = _no_tranrec
			   and cod_cober_reas = _cod_cober_reas;

			if _cantidad = 0 then

--				select count(*)
--				  into _cantidad
--				  from rectrrea
--				 where no_tranrec = _no_tranrec;

--				if _cantidad = 1 then

--					select cod_cober_reas
--					  into _cod_cober_reas
--					  from rectrrea
--					 where no_tranrec = _no_tranrec;

--				else

					return 1, "No hay Distribucion de Reaseguro para la Transaccion: " || _no_tranrec || " " || _cod_cober_reas;

--				end if

			end if
			
			let _monto_reas = _monto_reas_cob;

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
			  where no_tranrec     = _no_tranrec
			    and cod_cober_reas = _cod_cober_reas
			    and tipo_contrato  <> 1

				if _tipo_contrato = 3 then -- Facultativos

					foreach
					 select cod_coasegur,
							porc_partic_reas
					   into	_cod_coasegur,
					        _porc_cont_partic
					   from rectrref
					  where no_tranrec     = _no_tranrec
			            and cod_cober_reas = _cod_cober_reas
					    and orden          = _orden

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

							call sp_par297(a_no_registro, _cuenta, _debito, _credito, _tipo_comp, _periodo, _centro_costo, _fecha);
						
							-- Reaseguro por Pagar

							let _debito  = 0.00;
							let _credito = 0.00;

							if _monto >= 0.00 then
								let _debito  = _monto;
							else
								let _credito = _monto * -1;
							end if

							let _cuenta = sp_sis15("PPRXP", "05", _cod_origen_aseg, _cod_ramo, _cod_subramo);   
							call sp_par297(a_no_registro, _cuenta, _debito, _credito, _tipo_comp, _periodo, _centro_costo, _fecha);
							call sp_par298(a_no_registro, _cuenta, _debito, _credito, _tipo_comp, _cod_auxiliar, _periodo, _centro_costo, _fecha);

						end if
					
					end foreach

				else -- Otros contratos
				
					select traspaso,
					       bouquet
					  into _traspaso,
					       _bouquet
					  from reacocob
					 where cod_contrato   = _cod_contrato
					   and cod_cober_reas = _cod_cober_reas;

					 select count(*)
					   into	_cantidad
					   from reacoase
					  where cod_contrato   = _cod_contrato 
					    and cod_cober_reas = _cod_cober_reas;

					if _cantidad = 0 then
						
						drop table tmp_reas;
						return 1, "No Existe Companias del Contrato: " || _cod_contrato || " Cobertura: " || _cod_cober_reas;

					end if

					foreach
					 select cod_coasegur,
							porc_cont_partic
					   into	_cod_coasegur,
					        _porc_cont_partic
					   from reacoase
					  where cod_contrato   = _cod_contrato 
					    and cod_cober_reas = _cod_cober_reas  
						and contrato_xl    = 0

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

							call sp_par297(a_no_registro, _cuenta, _debito, _credito, _tipo_comp, _periodo, _centro_costo, _fecha);
						
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
							
							if _cod_ramo in ('002','020','023') then -- Nuevo Contrato Auto 2024 Román 02/05/2024.
								let _cod_auxiliar = _aux_bouquet;   
							end if

							let _cuenta = sp_sis15("PPRXP", "05", _cod_origen_aseg, _cod_ramo, _cod_subramo);   
							call sp_par297(a_no_registro, _cuenta, _debito, _credito, _tipo_comp, _periodo, _centro_costo, _fecha);
							call sp_par298(a_no_registro, _cuenta, _debito, _credito, _tipo_comp, _cod_auxiliar, _periodo, _centro_costo, _fecha);

						end if

					end foreach
				
				end if

			end foreach

		end foreach

	end if

elif _tipo_registro in (4, 5) then -- Cheques Pagados/Anulados Devolucion Primas

	if _tipo_registro = 4 then
		let _tipo_comp = 15; -- Cheques Pagados
	else
		let _tipo_comp = 16; -- Cheques Anulados
	end if

    let _no_unidad = "00001";

	select cod_ramo,
	       cod_subramo,
		   no_documento
	  into _cod_ramo,
	       _cod_subramo,
		   _no_documento
	  from emipomae
	 where no_poliza = _no_poliza;

	-- Centro de Costo

	call sp_sac93(_no_poliza, 1) returning _error, _error_desc, _centro_costo;

	if _error <> 0 then
		drop table tmp_reas;
		let _error_desc = "Error en sp_sac93" || " Poliza " || _no_poliza;
		return _error, _error_desc;
	end if

	select prima_neta
	  into _prima_neta
	  from chqchpol
	 where no_requis    = _no_remesa
	   and no_documento = _no_documento;

	select porc_partic_coas
	  into _porc_partic_coas
	  from emicoama
	 where no_poliza    = _no_poliza
	   and cod_coasegur = _cod_lider;
	
	if _porc_partic_coas is null then
		let _porc_partic_coas = 100;
	end if

	let _prima_suscrita = _prima_neta * _porc_partic_coas / 100;

	if _tipo_registro = 5 then
		let _prima_suscrita = _prima_suscrita * - 1;
	end if

	delete from tmp_reas;
	delete from tmp_unidad;

	-- Distribucion de Reaseguro del Cheque

	foreach
		select cod_contrato,
			   cod_cober_reas,
			   porc_partic_prima,
			   porc_proporcion
		  into _cod_contrato,
			   _cod_cober_reas,
			   _porc_partic_prima,
			   _porc_proporcion
		  from chqreaco
		 where no_requis      = _no_remesa
		   and no_poliza      = _no_poliza

		select bouquet
		  into _bouquet
		  from reacocob
		 where cod_contrato   = _cod_contrato
		   and cod_cober_reas = _cod_cober_reas;

		let _prima = _prima_suscrita * (_porc_partic_prima / 100) * (_porc_proporcion / 100);

		begin
			on exception in(-239,-268)
				update tmp_unidad
				   set prima_tot = prima_tot + _prima
				 where no_unidad = _no_unidad;
			end exception
			insert into tmp_unidad(no_unidad,prima_tot)
			values(	_no_unidad,_prima);
		end

		if _bouquet = 1 then

			select es_terremoto
			  into _es_terremoto
			  from reacobre
			 where cod_cober_reas = _cod_cober_reas;

			insert into tmp_reas
			values (_no_unidad, _cod_cober_reas, _cod_contrato, _prima, 0.00, _es_terremoto, _bouquet, 1,_porc_partic_prima);

		end if
	end foreach

	if _cod_ramo in ("001", "003") then

		let _bouquet = 1;
		
		if _cod_ramo = '001' then
			let _porc_inc = .70;
			let _porc_ter = .30;		
		else
			let _porc_inc = .90;
			let _porc_ter = .10;
		end if

		foreach
			select distinct no_unidad,
				   cod_contrato,
				   porc_partic_prima
			  into _no_unidad,
				   _cod_contrato,
				   _porc_partic_prima
			  from tmp_reas
			 order by no_unidad, cod_contrato,porc_partic_prima

			select prima_tot
			  into _prima_tot
			  from tmp_unidad
			 where no_unidad = _no_unidad;

			select count(*)
			  into _cnt_existe
			  from reacocob c, reacobre r
			 where c.cod_cober_reas = r.cod_cober_reas
			   and c.cod_contrato = _cod_contrato
			   and r.cod_ramo = _cod_ramo
			   and es_terremoto = 1;

			if _cnt_existe is null then
				let _cnt_existe = 0;
			end if

			if _cnt_existe > 0 then
				let _porc_inc = .70;
				let _porc_ter = .30;
			end if

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
				values (_no_unidad, _cod_cober_reas, _cod_contrato, 0.00, 0.00, _es_terremoto, _bouquet, 1,_porc_partic_prima);

			end if

			update tmp_reas
			   set prima_rea    = prima_rea + (_prima_tot * _porc_inc) * (_porc_partic_prima/100)
			 where no_unidad    = _no_unidad
			   and cod_contrato = _cod_contrato
			   and porc_partic_prima = _porc_partic_prima
			   and es_terremoto = 0;

			select count(*)
			  into _cantidad
			  from tmp_reas
			 where no_unidad    = _no_unidad
			   and cod_contrato = _cod_contrato
			   and es_terremoto = 1;

			if _cantidad = 0 and _cnt_existe > 0 then

				select cod_cober_reas,
				       es_terremoto
				  into _cod_cober_reas,
				       _es_terremoto
				  from reacobre
				 where cod_ramo     = _cod_ramo
				   and es_terremoto = 1;

				insert into tmp_reas
				values (_no_unidad, _cod_cober_reas, _cod_contrato, 0.00, 0.00, _es_terremoto, _bouquet, 1,_porc_partic_prima);

			end if

			update tmp_reas
			   set prima_rea    = prima_rea + (_prima_tot * _porc_ter) * (_porc_partic_prima/100)
			 where no_unidad    = _no_unidad
			   and cod_contrato = _cod_contrato
			   and porc_partic_prima = _porc_partic_prima
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
			and contrato_xl    = 0

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

			-- Reaseguro Cedido
			
			let _monto_reas    = _prima      * _porc_cont_partic / 100;
			let _suma_comision = _monto_reas * _porc_comis_agt   / 100;
			let _suma_impuesto = _monto_reas * _factor_impuesto  / 100;

			let _monto = _monto_reas - _suma_comision - _suma_impuesto;
			
	--	if _cod_ramo in ('002','020','023') then -- Nuevo Contrato Auto 2024 Román 02/05/2024.
	--		let _cod_auxiliar = _aux_bouquet;   
	--	end if


			--{
			if _monto <> 0.00 Then

				-- Provision por Reasegurador Bouquet

				let _debito  = 0.00;
				let _credito = 0.00;

				if _monto > 0 then
					let _credito = _monto;
				else
					let _debito  = _monto * -1;
				end if

				let _cuenta = sp_sis15("PPPRXPB", '03');
				call sp_par297(a_no_registro, _cuenta, _debito, _credito, _tipo_comp, _periodo, _centro_costo, _fecha);
				call sp_par298(a_no_registro, _cuenta, _debito, _credito, _tipo_comp, _cod_auxiliar, _periodo, _centro_costo, _fecha);

				-- Reaseguro por Pagar Bouquet

				let _debito  = 0.00;
				let _credito = 0.00;

				if _monto > 0 then
					let _debito  = _monto;
				else
					let _credito = _monto * -1;
				end if

				let _cuenta = sp_sis15("PPRXP", "05", _cod_origen_aseg, _cod_ramo, _cod_subramo);   
				call sp_par297(a_no_registro, _cuenta, _debito, _credito, _tipo_comp, _periodo, _centro_costo, _fecha);
				call sp_par298(a_no_registro, _cuenta, _debito, _credito, _tipo_comp, _cod_auxiliar, _periodo, _centro_costo, _fecha);

			end if
		end foreach
	end foreach
end if

drop table tmp_reas;
drop table tmp_unidad;

end

return 0, "Actualizacion Exitosa";

end procedure
