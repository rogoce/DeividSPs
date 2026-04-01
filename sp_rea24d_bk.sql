-- Procedimiento que carga la provisión de Reaseguro.
-- 24/02/2016 - Autor: Román Gordón.
-- execute procedure sp_rea24d('001','001','2018-06',1)

drop procedure sp_rea24d;
create procedure sp_rea24d(a_compania char(3), a_sucursal char(3), a_periodo char(7), a_flag smallint)
returning	integer,		--1
			varchar(100);	--2

define _nombre_contratante	varchar(100);
define _nombre_reas			varchar(50);
define _error_desc			varchar(50);
define _descr_cia			varchar(50);
define _nombre				varchar(50);
define _doc_poliza			char(20);
define _cod_contratante		char(10);
define _no_poliza_ant		char(10);
define _no_poliza			char(10);
define _periodo				char(7);
define _cod_contrato		char(5);
define _no_unidad			char(5);
define _cod_cober_reas		char(3);
define _cod_tipoprod1		char(3);
define _cod_tipoprod2		char(3);
define _cod_coasegur		char(3);
define _cod_tipoprod		char(3);
define _cod_ramo			char(3);
define _porc_comision1		dec(5,2);
define _porc_comision2		dec(5,2);
define _porc_imp_ant		dec(5,2);
define _porc_imp_act		dec(5,2);
define _porc_impuesto		dec(5,2);
define _porc_especial		dec(5,2);
define _porc_com_reas		dec(5,2);
define _porc_com_ant		dec(5,2);
define _porc_com_act		dec(5,2);
define _porc_comision		dec(5,2);
define _porc_partic_coas	dec(7,4);
define _porc_partic_prima	dec(12,6);
define _porc_coasegur_ant	dec(9,6);
define _porc_coasegur_act	dec(9,6);
define _porc_reas_ant		dec(9,6);
define _porc_reas_act		dec(9,6);
define _porc_uni_ant		dec(9,6);
define _porc_uni_act		dec(12,6);
define _porc_partic_suma	dec(12,6);
define _porc_cont_partic	dec(9,6);
define _porc_partic_reas	dec(9,6);
define _porc_cober_reas		dec(9,6);
define _porc_inc          	dec(9,6);
define _saldo_contrato		dec(16,2);
define _saldo_reaseg		dec(16,2);
define _prima_bruta			dec(16,2);
define _saldo_acum			dec(16,2);
define _saldo_ant			dec(16,2);
define _saldo_act			dec(16,2);
define _porc_ter          	dec(16,2);
define _saldo_contrato_ac	dec(16,2);
define _dif_saldos			dec(16,2);
define _saldo_cobmoros		dec(16,2);
define v_saldo_coas			dec(16,2);
define _comision			dec(16,2);
define v_saldo_b			dec(16,2);
define _imp_ant				dec(16,2);
define _imp_act				dec(16,2);
define _impuesto			dec(16,2);
define _com_ant				dec(16,2);
define _com_act				dec(16,2);
define _com_reas			dec(16,2);
define _imp_reas			dec(16,2);
define v_saldo				dec(16,2);
define _por_vencer			dec(16,2);
define _corriente			dec(16,2);
define _monto_30			dec(16,2);
define _monto_60			dec(16,2);
define _monto_90			dec(16,2);
define _monto_120			dec(16,2);
define _monto_150			dec(16,2);
define _monto_180			dec(16,2);
define _exigible			dec(16,2);
define _es_terremoto		integer;
define _error_isam			integer;
define _error				integer;
define _no_cambio_orig		smallint;
define _ult_no_cambio		smallint;
define _tipo_contrato		smallint;
define _cnt_no_unidad		smallint;
define _cantidad_uni		smallint;
define _cnt_emireaco		smallint;
define _contrato_xl			smallint;
define _flag_prima			smallint;
define _cnt_reaseg			smallint;
define _cnt_existe			smallint;
define _cnt_verif			smallint;
define _no_cambio			smallint;
define _tiene_com			smallint;
define _continuar			smallint;
define _cantidad			smallint;
define _cnt_reas			smallint;
define _cnt_terr			smallint;
define _bouquet				smallint;
define _serie				smallint;
define _mes,_cnt			smallint;
define _ano,_ct				smallint;
define _vigencia_final		date;
define _vigencia_inic		date;
define _fecha				date;

set isolation to dirty read;

--set debug file to 'sp_rea24d.trc';
--trace on;

begin
on exception set _error, _error_isam, _error_desc
	begin
		on exception in(-255)
		end exception
		rollback work;
	end 
	return _error, _doc_poliza || trim(_error_desc);
end exception

let _descr_cia = sp_sis01(a_compania);

select cod_tipoprod
  into _cod_tipoprod1
  from emitipro
 where tipo_produccion = 1;	-- sin coaseguro 005

select cod_tipoprod
  into _cod_tipoprod2
  from emitipro
 where tipo_produccion = 2;	-- coaseguro mayoritario 001

let _ano = a_periodo[1,4];
let _mes = a_periodo[6,7];
let _fecha = sp_sis36(a_periodo);

let _fecha = _fecha + 1 units day;

foreach with hold
	select no_documento,
		   saldo_pxc
	  into _doc_poliza,
		   v_saldo
	  from deivid_cob:cobmoros2
	 where periodo = a_periodo
	   and saldo_pxc <> 0
	   and no_documento[1,2] not in('02','20','23','18')	--Se saca ramos de auto de la provision, ROMAN 02/05/2024, se agrega salud 05/12/2024
	   
	begin
		on exception in(-535)

		end exception 	
		begin work;
	end

	if _doc_poliza in ('0221-00468-10','1604-00024-01','1617-00619-09','1618-00023-01','0417-00008-01','0220-00978-01') then
		commit work;
		continue foreach;
	end if

	let _no_poliza = '';
	foreach
		select no_poliza,
			   vigencia_inic
		  into _no_poliza,
			   _vigencia_inic
		  from emipomae
		 where no_documento = _doc_poliza
		   and actualizado = 1
		 order by vigencia_final desc

		if _vigencia_inic < _fecha then
			exit foreach;
		end if
	end foreach
	
	let _cnt_verif = 0;

	select count(*)
	  into _cnt_verif
	  from rea_saldo2
	 where no_documento = _doc_poliza
	   and periodo = a_periodo;

	if _cnt_verif is null then
		let _cnt_verif = 0;
	end if
	
	if _cnt_verif > 0 then
		commit work;
		continue foreach;
	end if

	select cod_tipoprod,
		   cod_ramo,
		   cod_contratante,
		   vigencia_inic,
		   vigencia_final
	  into _cod_tipoprod,
		   _cod_ramo,
		   _cod_contratante,
		   _vigencia_inic,
		   _vigencia_final
	  from emipomae
	 where no_poliza = _no_poliza;
	 
	if _cod_ramo = '019' then --Vida ind. con serie >= 2024 no debe ir a provision. Josue correo 11/03/2025
		select count(*)
		  into _cnt
		  from emifacon e, reacomae r
		 where e.cod_contrato = r.cod_contrato
		   and e.no_poliza = _no_poliza
		   and r.serie >= 2024;
		if _cnt is null then
			let _cnt = 0;
		end if
		if _cnt > 0 then
			continue foreach;
		end if
	end if

	if _cod_tipoprod = _cod_tipoprod2 then --Coas MAY
		select porc_partic_coas
		  into _porc_partic_coas
		  from emicoama
		 where no_poliza = _no_poliza
		   and cod_coasegur = '036'; --> Aseguradora Ancon

		let v_saldo_coas = v_saldo - (v_saldo * _porc_partic_coas / 100);
		let v_saldo      = v_saldo * _porc_partic_coas / 100;
		
		insert into rea_saldo2(
				periodo,
				no_documento,
				cod_contratante,
				vigencia_inic,
				vigencia_final,
				cod_ramo,
				saldo_tot,
				no_poliza,
				no_unidad,
				porc_partic_uni,
				cod_cober_reas,
				porc_partic_reas,
				cod_contrato,
				cod_coasegur,
				porc_partic_cont,
				porc_com_reas,
				comision,
				porc_imp_coas,
				impuesto,
				saldo_actual,
				porc_partic_uni_a,
				porc_partic_reas_a,
				porc_partic_cont_a,
				porc_com_reas_a,
				comision_a,
				porc_imp_coas_a,
				impuesto_a,
				saldo_anterior)
		values(	a_periodo,
				_doc_poliza,
				_cod_contratante,
				_vigencia_inic,
				_vigencia_final,
				_cod_ramo,
				v_saldo_coas,
				_no_poliza,
				'00001',
				0.00,
				'000',
				0.00,
				'00000',
				'',
				0.00,
				0.00,
				0.00,
				0.00,
				0.00,
				0.00,
				0.00,
				0.00,
				0.00,
				0.00,
				0.00,
				0.00,
				0.00,
				0.00);
	elif _cod_tipoprod = '004' then
		let v_saldo = 0.00;
	end if

	let _continuar = 0;
	delete from deivid_tmp:fic_emireaco;

	foreach
		select distinct no_unidad
		  into _no_unidad
		  from emipouni
		 where no_poliza = _no_poliza

		let _no_cambio = null;

		select max(no_cambio)
		  into _no_cambio
		  from emireaco
		 where no_poliza = _no_poliza
		   and no_unidad = _no_unidad;

		if _no_cambio is null then
			return 1,'No Existe emireaco para la Póliza: ' || trim(_no_poliza) || ' y la Unidad: ' || trim(_no_unidad) with resume;
			--continue foreach;
		end if

		insert into deivid_tmp:fic_emireaco
		select distinct e.*,r.es_terremoto
		  from emireaco e, reacocob c, reacobre r
		 where e.cod_contrato = c.cod_contrato
		   and e.cod_cober_reas = c.cod_cober_reas
		   and e.cod_cober_reas = r.cod_cober_reas
		   and r.cod_ramo = _cod_ramo
		   and e.no_poliza = _no_poliza
		   and e.no_unidad = _no_unidad
		   --and c.bouquet = 1
		   and e.no_cambio >= (select max(no_cambio) from emireaco where no_poliza = _no_poliza and no_unidad = _no_unidad);
	end foreach

	if _cod_ramo in ('001', '003') then

		foreach
			select cod_cober_reas
			  into _cod_cober_reas
			  from reacobre
			 where cod_ramo = _cod_ramo
			   and es_terremoto = 1
			 order by 1
			exit foreach;
		end foreach

		--let _partic_reas_acum = 0.00;
		foreach
			select distinct no_unidad,
				   cod_contrato,
				   no_cambio
			  into _no_unidad,
				   _cod_contrato,
				   _no_cambio
			  from deivid_tmp:fic_emireaco
			 where no_poliza = _no_poliza
			 order by no_unidad, cod_contrato
		   
			if _cod_ramo = '001' then
				let _porc_inc = .70;
				let _porc_ter = .30;		
			else
				let _porc_inc = .90;
				let _porc_ter = .10;
			end if

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
				if _cod_ramo = '001' then
					let _porc_inc = .70;
					let _porc_ter = .30;		
				else
					let _porc_inc = .90;
					let _porc_ter = .10;
				end if
			end if

			select count(*)
			  into _cnt_terr
			  from deivid_tmp:fic_emireaco
			 where no_poliza = _no_poliza
			   and no_unidad = _no_unidad
			   and cod_cober_reas = _cod_cober_reas
			   and cod_contrato   = _cod_contrato
			   and no_cambio      = _no_cambio;

			if _cnt_terr is null then			   
				let _cnt_terr = 0;
			end if

			if _cnt_terr = 0 and _cnt_existe > 0 then

				let _serie = 0;
				select serie
				  into _serie
				  from reacomae
				 where cod_contrato = _cod_contrato;
			
				if _serie >= 2015 and _serie < 2018 then
					let _porc_partic_prima = 100;
				else
					foreach
						select porc_partic_prima
						  into _porc_partic_prima
						  from emireaco 
						 where no_poliza = _no_poliza
						   and no_unidad = _no_unidad
						   and cod_contrato = _cod_contrato
						   and no_cambio = _no_cambio
						exit foreach;
					end foreach
				end if
				{select count(*)
				  into _ct
				  from emireaco 
				 where no_poliza    = _no_poliza
				   and no_unidad    = _no_unidad
				   and cod_contrato = _cod_contrato
				   and no_cambio    = _no_cambio;
				if _ct is null then
					let _ct = 0;
				end if
				if _ct > 0 then
				else}
					insert into deivid_tmp:fic_emireaco(no_poliza,no_unidad,no_cambio,cod_cober_reas,orden,cod_contrato,porc_partic_prima,porc_partic_suma,es_terremoto)
					select no_poliza,
						   no_unidad,
						   no_cambio,
						   _cod_cober_reas,
						   orden,
						   _cod_contrato,
						   _porc_partic_prima, --100,--
						   _porc_partic_prima, --100,--
						   1
					  from emireaco 
					 where no_poliza = _no_poliza
					   and no_unidad = _no_unidad
					   and cod_contrato = _cod_contrato
					   and no_cambio = _no_cambio;
				--end if
			elif _cnt_terr = 0 and _cnt_existe = 0 then
				--let _porc_inc = 1;
			end if
			
			update deivid_tmp:fic_emireaco
			   set porc_partic_prima  = porc_partic_prima * _porc_inc
			 where no_poliza = _no_poliza
			   and no_unidad = _no_unidad
			   and cod_contrato = _cod_contrato
			   and no_cambio = _no_cambio
			   and es_terremoto = 0;
			
			update deivid_tmp:fic_emireaco
			   set porc_partic_prima  = porc_partic_prima * _porc_ter
			 where no_poliza = _no_poliza
			   and no_unidad = _no_unidad
			   and cod_contrato = _cod_contrato
			   and no_cambio = _no_cambio
			   and es_terremoto = 1;
		end foreach
	end if			

	let _saldo_contrato = 0;
	let _cantidad_uni   = 0;
	let _flag_prima   = 0;
	
	--'1614-00078-01','1614-00079-01','1614-00080-01') banco hipotecario,
	--se elmina la cobertura de reaseguro 041 para evitar error en proporcion
	if _no_poliza in('1972793','1972794','1972795','2707618','2707620','2707626') then
		delete from deivid_tmp:fic_emireaco
		 where no_poliza = _no_poliza
		   and no_unidad = _no_unidad
		   and cod_cober_reas = '041';
	end if
	
	if _no_poliza = '0001883296' then
		delete from deivid_tmp:fic_emireaco
		 where no_poliza = '0001883296'
		   and no_unidad = '00001'
		   and cod_cober_reas = '040';
	end if
	if _no_poliza = '1224548' then
		delete from deivid_tmp:fic_emireaco
		 where no_poliza = '1224548'
		   and no_unidad in('00001','00002')
		   and cod_cober_reas = '021'
		   and cod_contrato   = '00688';
	end if
	if _no_poliza = '0001229067' then
		delete from deivid_tmp:fic_emireaco
		 where no_poliza = '0001229067'
		   and no_unidad = '00001';
	end if
	foreach
		select no_unidad
		  into _no_unidad
		  from deivid_tmp:fic_emireaco
		 where no_poliza = _no_poliza
		 group by no_unidad   

		select sum(r.prima)
		  into _saldo_reaseg
		  from emifacon r, endedmae e
		 where r.no_poliza = e.no_poliza
		   and r.no_endoso = e.no_endoso
		   and r.no_poliza = _no_poliza
		   and r.no_unidad = _no_unidad
		   and cod_endomov not in ('002','003');

		if _saldo_reaseg is null then 
			let _saldo_reaseg = 0;
		end if

		if _saldo_reaseg <> 0 then
			let _flag_prima = 1;
		end if
		
		let _saldo_contrato = _saldo_contrato + _saldo_reaseg;
		let _cantidad_uni   = _cantidad_uni   + 1;			
	end foreach
	let _saldo_contrato = _saldo_contrato;
	foreach
		select no_unidad
		  into _no_unidad
		  from deivid_tmp:fic_emireaco
		 where no_poliza = _no_poliza
		 group by no_unidad   

		select sum(r.prima)
		  into _saldo_reaseg
		  from emifacon r, endedmae e
		 where r.no_poliza = e.no_poliza
		   and r.no_endoso = e.no_endoso
		   and r.no_poliza = _no_poliza
		   and r.no_unidad = _no_unidad
		   and cod_endomov not in ('002','003');

		if _saldo_reaseg is null then 
			let _saldo_reaseg = 0;
		end if

		if (_saldo_contrato = 0 and _flag_prima = 0) or abs(_saldo_contrato) < 1 then
			let _porc_partic_suma = (1 / _cantidad_uni) * 100;               -- Por Unidades
		else
			let _porc_partic_suma = (_saldo_reaseg / _saldo_contrato) * 100; -- Por Prima
		end if

		update deivid_tmp:fic_emireaco
		   set porc_partic_suma = _porc_partic_suma
		 where no_poliza = _no_poliza
		   and no_unidad = _no_unidad;
	end foreach
    --******AUTOMOVIL*********************************************************************
	if _cod_ramo in ('002','020','023') then
		foreach
			select no_unidad
			  into _no_unidad
			  from deivid_tmp:fic_emireaco
			 where no_poliza = _no_poliza
			 group by no_unidad   

			drop table if exists tmp_dist_rea;

			call sp_sis188e(_no_poliza,_no_unidad) returning _error,_error_desc;
			
			delete from deivid_tmp:fic_emireaco
			 where no_poliza = _no_poliza
			   and no_unidad = _no_unidad
			   and cod_cober_reas not in (select distinct cod_cober_reas from tmp_dist_rea);

			if _no_poliza in('1163298','0001286321') then
				delete from tmp_dist_rea
			     where cod_cober_reas = '031';
			end if

			select sum(porc_cober_reas)
			  into _porc_cober_reas
			  from tmp_dist_rea;
			  
			let _no_poliza = _no_poliza;
			let _no_unidad = _no_unidad;
			if round(_porc_cober_reas,4) <> 100 then
				update tmp_dist_rea
				   set porc_cober_reas = round((100/_porc_cober_reas),4) * 100
				 where no_poliza = _no_poliza
				   and no_unidad = _no_unidad;
			end if

			foreach
				select cod_cober_reas,
					   porc_cober_reas
				  into _cod_cober_reas,
					   _porc_partic_suma
				  from tmp_dist_rea
				 where no_poliza = _no_poliza
				   and no_unidad = _no_unidad

				update deivid_tmp:fic_emireaco
				   set porc_partic_prima = porc_partic_prima * (_porc_partic_suma/100)
				 where no_poliza        = _no_poliza
				   and no_unidad        = _no_unidad
				   and cod_cober_reas   = _cod_cober_reas;				
			end foreach			
		end foreach		
	end if

	foreach
		select cod_contrato,
			   cod_cober_reas,
			   porc_partic_prima,
			   porc_partic_suma,
			   no_unidad,
			   no_cambio
		  into _cod_contrato,
			   _cod_cober_reas,
			   _porc_partic_prima,
			   _porc_partic_suma,
			   _no_unidad,
			   _no_cambio
		  from deivid_tmp:fic_emireaco
		 where no_poliza = _no_poliza
		 order by no_poliza,no_cambio,no_unidad,cod_cober_reas

		if _cod_cober_reas not in ('021','022') then
			let _cnt_reas = 0;

			select count(*)
			  into _cnt_reas
			  from emifacon r, endedmae e
			 where r.no_poliza = e.no_poliza
			   and r.no_endoso = e.no_endoso
			   and r.no_poliza = _no_poliza
			   and r.no_unidad = _no_unidad
			   and cod_cober_reas = _cod_cober_reas
			   and cod_endomov not in ('002','003');

			if _cnt_reas is null then
				let _cnt_reas = 0;
			end if
			select tipo_contrato,
				   serie
			  into _tipo_contrato,
				   _serie
			  from reacomae
			 where cod_contrato = _cod_contrato;
			
			if _cnt_reas = 0 and _tipo_contrato <> 1 then
				continue foreach;
			end if
		end if

		select tipo_contrato,
			   serie
		  into _tipo_contrato,
			   _serie
		  from reacomae
		 where cod_contrato = _cod_contrato;
		 
		if _cod_ramo = '019' then
			if _serie = 2024 then
				continue foreach;
			end if
		end if

		let _saldo_contrato = 0;

		select tiene_comision,
			   porc_comision,
			   porc_impuesto,
			   bouquet
		  into _tiene_com,
			   _porc_comision1,
			   _porc_impuesto,
			   _bouquet
		  from reacocob
		 where cod_contrato   = _cod_contrato
		   and cod_cober_reas = _cod_cober_reas;

		let _saldo_contrato = v_saldo * (_porc_partic_prima / 100) * (_porc_partic_suma / 100);
		let _saldo_reaseg   = 0.00;
		let _es_terremoto   = 0;

		if _tipo_contrato in (1,3) then --Retención y Facultativo
			insert into rea_saldo2(
					periodo,
					no_documento,
					cod_contratante,
					vigencia_inic,
					vigencia_final,
					cod_ramo,
					saldo_tot,
					no_poliza,
					no_unidad,
					porc_partic_uni,
					cod_cober_reas,
					porc_partic_reas,
					cod_contrato,
					cod_coasegur,
					porc_partic_cont,
					porc_com_reas,
					comision,
					porc_imp_coas,
					impuesto,
					saldo_actual,
					porc_partic_uni_a,
					porc_partic_reas_a,
					porc_partic_cont_a,
					porc_com_reas_a,
					comision_a,
					porc_imp_coas_a,
					impuesto_a,
					saldo_anterior)
			values(	a_periodo,
					_doc_poliza,
					_cod_contratante,
					_vigencia_inic,
					_vigencia_final,
					_cod_ramo,
					_saldo_contrato,
					_no_poliza,
					_no_unidad,
					0.00,
					_cod_cober_reas,
					0.00,
					_cod_contrato,
					'',
					0.00,
					0.00,
					0.00,
					0.00,
					0.00,
					0.00,
					0.00,
					0.00,
					0.00,
					0.00,
					0.00,
					0.00,
					0.00,
					0.00);
		else
			foreach
				select cod_coasegur,
					   porc_cont_partic,
					   porc_comision,
					   contrato_xl
				  into _cod_coasegur,
					   _porc_cont_partic,
					   _porc_comision2,
					   _contrato_xl
				  from reacoase
				 where cod_contrato   = _cod_contrato
				   and cod_cober_reas = _cod_cober_reas

				if _tiene_com = 1 then   -- por contrato
					let _porc_comision = _porc_comision1;
				else
					let _porc_comision = _porc_comision2;
				end if

				let _com_reas      = 0.00;
				let _imp_reas      = 0.00;
				let _porc_especial = 1;

				let _saldo_reaseg = (_saldo_contrato * _porc_cont_partic / 100) * _porc_especial;
				let _com_reas     = _saldo_reaseg    * _porc_comision    / 100;
				let _imp_reas     = _saldo_reaseg    * _porc_impuesto    / 100;
				let _saldo_acum   = _saldo_reaseg;
				let _saldo_reaseg = _saldo_reaseg    - _com_reas         - _imp_reas;

				if _saldo_reaseg = 0 then
					continue foreach;
				end if
				
				if _contrato_xl = 1 then
					let _porc_impuesto = 0.00;
					let _saldo_reaseg = 0.00;
					let _com_reas = 0.00;
					let _imp_reas = 0.00;
				end if
				
				--Contrato Run Off no afecta la provisión
				if _serie in (2002,2003,2004,2005,2006,2007) 
				and _cod_ramo in ('001','003','004','005','007','008','010','011','012','013','014','015','017','021','022') then
					let _porc_impuesto = 0.00;
					let _saldo_reaseg = 0.00;
					let _com_reas = 0.00;
					let _imp_reas = 0.00;
				end if
				let _porc_com_reas = _porc_comision;
				
				let _porc_coasegur_ant = 0.00;
				let _porc_coasegur_act = 0.00;
				let _porc_reas_ant = 0.00;
				let _porc_reas_act = 0.00;
				let _porc_uni_ant = 0.00;
				let _porc_uni_act = 0.00;
				let _porc_com_ant = 0.00;
				let _porc_com_act = 0.00;
				let _porc_imp_ant = 0.00;
				let _porc_imp_act = 0.00;
				let _saldo_ant = 0.00;
				let _saldo_act = 0.00;
				let _com_ant = 0.00;
				let _com_act = 0.00;
				let _imp_ant = 0.00;
				let _imp_act = 0.00;

				let _porc_uni_act = _porc_partic_suma;
				let _porc_reas_act = _porc_partic_prima;
				let _porc_coasegur_act = _porc_cont_partic;
				let _porc_com_act = _porc_com_reas;
				let _com_act = _com_reas;
				let _porc_imp_act = _porc_impuesto;
				let _imp_act = _imp_reas;
				let _saldo_act = _saldo_reaseg;

				begin
					on exception in(-239,-268)
						update rea_saldo2
						   set saldo_actual = saldo_actual + _saldo_act,
							   saldo_anterior = saldo_anterior + _saldo_ant,
							   comision_a = comision_a + _com_ant,
							   impuesto_a = impuesto_a + _imp_ant,
							   comision = comision + _com_act,
							   porc_partic_cont_a = (porc_partic_cont_a + _porc_coasegur_ant)/2,
							   porc_partic_cont = (porc_partic_cont + _porc_coasegur_act)/2,
							   porc_partic_reas_a = (porc_partic_reas_a + _porc_reas_ant)/2,
							   porc_partic_uni_a = (porc_partic_uni_a + _porc_uni_ant)/2,
							   porc_partic_reas = (porc_partic_reas + _porc_reas_act)/2,
							   porc_com_reas_a = (porc_com_reas_a + _porc_com_ant)/2,
							   porc_imp_coas_a = (porc_imp_coas_a + _porc_imp_ant)/2,
							   porc_partic_uni = (porc_partic_uni + _porc_uni_act)/2,
							   porc_com_reas = (porc_com_reas + _porc_com_act)/2,
							   porc_imp_coas = (porc_imp_coas + _porc_imp_act)/2,
							   impuesto = impuesto + _imp_act
						 where periodo = a_periodo
						   and no_documento = _doc_poliza
						   and no_unidad = _no_unidad
						   and cod_cober_reas = _cod_cober_reas
						   and cod_contrato = _cod_contrato
						   and cod_coasegur = _cod_coasegur;
					end exception
					let _porc_uni_act = _porc_uni_act;
					let _porc_reas_act = _porc_reas_act;
					let _porc_coasegur_act = _porc_coasegur_act;
					let	_porc_com_act      = _porc_com_act;
					let _com_act           = _com_act;
					let _porc_imp_act      = _porc_imp_act;
					let	_imp_act           = _imp_act;
					let _saldo_act         = _saldo_act;
					let _porc_uni_ant      = _porc_uni_ant;
					let _porc_reas_ant     = _porc_reas_ant;
					let _porc_coasegur_ant = _porc_coasegur_ant;
					let _porc_com_ant      = _porc_com_ant;
					let _com_ant           = _com_ant;
					let _porc_imp_ant      = _porc_imp_ant;
					let _imp_ant           = _imp_ant;
					let _saldo_ant         = _saldo_ant;
					insert into rea_saldo2(
							periodo,
							no_documento,
							cod_contratante,
							vigencia_inic,
							vigencia_final,
							cod_ramo,
							saldo_tot,
							no_poliza,
							no_unidad,
							porc_partic_uni,
							cod_cober_reas,
							porc_partic_reas,
							cod_contrato,
							cod_coasegur,
							porc_partic_cont,
							porc_com_reas,
							comision,
							porc_imp_coas,
							impuesto,
							saldo_actual,
							porc_partic_uni_a,
							porc_partic_reas_a,
							porc_partic_cont_a,
							porc_com_reas_a,
							comision_a,
							porc_imp_coas_a,
							impuesto_a,
							saldo_anterior)
					values(	a_periodo,
							_doc_poliza,
							_cod_contratante,
							_vigencia_inic,
							_vigencia_final,
							_cod_ramo,
							_saldo_acum,
							_no_poliza,
							_no_unidad,
							_porc_uni_act,
							_cod_cober_reas,
							_porc_reas_act,
							_cod_contrato,
							_cod_coasegur,
							_porc_coasegur_act,
							_porc_com_act,
							_com_act,
							_porc_imp_act,
							_imp_act,
							_saldo_act,
							_porc_uni_ant,
							_porc_reas_ant,
							_porc_coasegur_ant,
							_porc_com_ant,
							_com_ant,
							_porc_imp_ant,
							_imp_ant,
							_saldo_ant);
				end 
			end foreach
		end if
	end foreach
	commit work;
end foreach
end

select sum(saldo_pxc)
  into _saldo_cobmoros
  from deivid_cob:cobmoros2
 where periodo = a_periodo
   and no_documento[1,2] not in('02','20','23','18');

select sum(saldo_tot)
  into _saldo_reaseg
  from rea_saldo2
 where periodo = a_periodo;

let _dif_saldos = _saldo_reaseg - _saldo_cobmoros;

return 0, 'Exito. Diferencia entre cobmoros y provisión: ' || _dif_saldos;
end procedure;