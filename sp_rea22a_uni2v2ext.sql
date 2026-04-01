drop procedure sp_rea22a_uni2v2ext;
create procedure sp_rea22a_uni2v2ext(a_periodo2 varchar(7))
returning	integer,
			char(255);
define v_name_subramo		varchar(50);
define _name_manzana		varchar(50);
define _error_desc			varchar(50);
define _n_contrato			varchar(50);
define v_cedula				varchar(30);
define v_filtros2			char(255);
define v_filtros1			char(255);
define v_filtros			char(255);
define v_desc_cobertura		char(100);
define v_desc_contrato		char(50);
define _nombre_coas			char(50);
define v_descr_cia			char(50);
define v_desc_ramo			char(50);
define _nombre_cob			char(50);
define _nombre_con			char(50);
define _n_aseg				char(50);
define _cuenta				char(25);
define _no_documento		char(20);
define _no_doc				char(20);
define _res_comprobante		char(15);
define _cod_manzana			char(15);
define _cod_contratante		char(10);
define _no_registro			char(10);
define v_no_recibo			char(10);
define _no_poliza			char(10);
define _no_remesa			char(10);
define v_nopoliza			char(10);
define _periodo1			char(8);
define v_cod_contrato		char(5);
define _cod_traspaso		char(5);
define v_noendoso			char(5);
define _no_unidad			char(5);
define _cod_coasegur		char(3);
define v_cod_subramo		char(3);
define _cod_subramo			char(3);
define v_cobertura			char(3);
define _cod_origen			char(3);
define v_cod_tipo			char(3);
define v_cod_ramo			char(3);
define _t_ramo				char(1);
define _tipo				char(1);
define _porc_cont_partic	dec(5,2);
define _porc_proporcion		dec(5,2);
define _porc_comis_ase		dec(5,2);
define _porc_partic_coas	dec(7,4);
define _porc_partic_prima	dec(9,6);
define _prima_tot_ret_sum	dec(16,2);
define _prima_tot_sus_sum	dec(16,2);
define v_prima_suscrita		dec(16,2);
define v_suma_asegurada		dec(16,2);
define v_prima_cobrada		dec(16,2);
define v_rango_inicial		dec(16,2);
define _prima_tot_ret		dec(16,2);
define _porc_impuesto		dec(16,2);
define _porc_comision		dec(16,2);
define _prima_sus_tot		dec(16,2);
define _p_sus_tot_sum		dec(16,2);
define _prima_total			dec(16,2);
define v_rango_final		dec(16,2);
define v_prima_tipo			dec(16,2);
define _sum_fac_car			dec(16,2);
define _monto_reas			dec(16,2);
define _ret_casco			dec(16,2);
define _por_pagar			dec(16,2);
define _p_sus_tot			dec(16,2);
define v_prima_bq			dec(16,2);
define v_prima_ot			dec(16,2);
define v_prima_3			dec(16,2);
define _impuesto			dec(16,2);
define _comision			dec(16,2);
define v_prima_1			dec(16,2);
define v_prima1				dec(16,2);
define v_prima				dec(16,2);
define _porc_partic_coas_ancon  dec(7,4);
define _tiene_comis_rea		integer;
define v_tipo_contrato		integer;
define _facilidad_car		integer;
define v_porcentaje			integer;
define _tipo_cont			integer;
define _no_cambio			integer;
define _traspaso			integer;
define _cantidad			integer;
define _bouquet				integer;
define _serie				integer;
define _valor				integer;
define _flag				integer;
define _cnt					integer;
define _error_isam			integer;
define _sac_notrx			integer;
define _renglon				integer;
define _error				integer;
define _fecha_suscripcion	date;
define _vigencia_inic		date;
define _vigencia_final		date;
define _vigencia_ini		date;
define _vigencia_fin		date;
define _fecha_recibo		date;
define _fecha				date;	
define _fecha_hasta         date;

let _fecha_hasta = sp_sis36(a_periodo2);		
/*###############################################################################################*/
/*###############################################################################################*/
let _res_comprobante = "";
foreach
	select no_poliza, no_endoso, prima_neta, vigencia_inic, no_factura, no_documento, no_remesa,  renglon
	  into v_nopoliza, v_noendoso, v_prima_cobrada, _fecha, v_no_recibo, _no_doc, _no_remesa,  _renglon
	  from temp_det where seleccionado = 1  and no_documento in('1614-00078-01','1614-00079-01','1614-00080-01','1614-00081-01','1621-00002-01') 
	
	select count(*)
	  into _cnt
	  from reaexpol
	 where no_documento = _no_doc
	   and activo       = 1;
	   
	if _cnt = 1 then     
		continue foreach;
	end if
	
	let v_nopoliza = sp_sis21c(_no_doc,_fecha_hasta);	

	select cod_ramo, cod_origen, cod_subramo, vigencia_final
	  into v_cod_ramo, _cod_origen, _cod_subramo, _vigencia_final
	  from emipomae
	 where no_poliza = v_nopoliza;
	 
	select max(no_unidad)
	  into _no_unidad
	  from emipouni
	 where no_poliza = v_nopoliza
	   and prima > 0;

	if _no_unidad is null or trim(_no_unidad) = "" then
		let _no_unidad = '00001';
	end if

	select porc_partic_coas
	  into _porc_partic_coas
	  from emicoama
	 where no_poliza    = v_nopoliza
	   and cod_coasegur = "036"; 			

	if _porc_partic_coas is null then
		let _porc_partic_coas = 100;
	else	
		foreach       --SD#5498 OWONG diferencia cuando hay endoso de cambio de coaseguro HGIRON 28/02/2023
		  select a.porc_partic_coas
			into _porc_partic_coas_ancon
			from endcoama a,endedmae b
		   where a.no_poliza = v_nopoliza	
             and b.fecha_emision <= _fecha	
			 and a.cod_coasegur = '036'		 		   
			 and a.no_poliza = b.no_poliza	     
			 and a.no_endoso = b.no_endoso	
			 and b.actualizado = 1
			 order by b.no_endoso desc
			 
			 exit foreach;
		end foreach
		 
		if _porc_partic_coas_ancon is null or _porc_partic_coas_ancon = 0 then
			let _porc_partic_coas_ancon = _porc_partic_coas;		 
		end if		
		let _porc_partic_coas = _porc_partic_coas_ancon; 		 
	end if

	let v_prima_cobrada = v_prima_cobrada * _porc_partic_coas / 100;

	drop table if exists tmp_reas;
	call sp_sis122a(_no_remesa,_renglon) returning _error,_error_desc;

	foreach
		select cod_contrato, porc_partic_prima, porc_proporcion, cod_cober_reas
         into v_cod_contrato,  _porc_partic_prima,  _porc_proporcion,  v_cobertura
		  from tmp_reas

		select traspaso
		  into _traspaso
		  from reacocob
		 where cod_contrato   = v_cod_contrato
		   and cod_cober_reas = v_cobertura;

		select cod_traspaso, tipo_contrato,  serie
		  into _cod_traspaso, v_tipo_contrato, _serie
		  from reacomae
		 where cod_contrato = v_cod_contrato;

		if _traspaso = 1 then
			let v_cod_contrato = _cod_traspaso;
		end if

		let _tipo_cont = 0;

		if v_tipo_contrato = 3 then
			let _tipo_cont = 2;
		elif v_tipo_contrato = 1 then --retencion
			let v_prima1 = v_prima_cobrada * _porc_partic_prima / 100;
			let _tipo_cont = 1;
		end if

		let v_prima1 = v_prima_cobrada * (_porc_partic_prima / 100) * (_porc_proporcion / 100);
		let v_prima  = v_prima1;

		select nombre, serie
		  into v_desc_contrato,
			   _serie
		  from reacomae
		 where cod_contrato = v_cod_contrato;

		let _nombre_con = trim(v_desc_contrato) || " (" || v_cod_contrato || ")" || "  A: " || _serie;
		let _cuenta = sp_sis15("PPRXP", "05", _cod_origen, v_cod_ramo, _cod_subramo);

		select nombre
		  into v_desc_ramo
		  from prdramo
		 where cod_ramo = v_cod_ramo;

		select porc_impuesto,  porc_comision, tiene_comision
  		  into _porc_impuesto,  _porc_comision, _tiene_comis_rea
		  from reacocob
		 where cod_contrato   = v_cod_contrato
		   and cod_cober_reas = v_cobertura;

		select nombre
		  into _nombre_cob
		  from reacobre
		 where cod_cober_reas = v_cobertura;

		select count(*)
		  into _cantidad
		  from reacoase
		 where cod_contrato = v_cod_contrato
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
				   and desc_cob      = _nombre_cob
				   and no_poliza     = v_nopoliza;

				if _cantidad = 0 then
					insert into temp_produccion
					values(	v_cod_ramo,
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
							v_nopoliza,
							_no_unidad,
							'999');
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
					   and no_poliza     = v_nopoliza;

					if _cantidad = 0 then
						insert into temp_produccion
						values(	v_cod_ramo,
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
								v_nopoliza,
								_no_unidad,
								_cod_coasegur);
					else					   
						update temp_produccion
						   set prima         = prima + _monto_reas,
							   comision      = comision  + _comision,
							   impuesto      = impuesto  + _impuesto,
							   por_pagar     = por_pagar + _por_pagar
						 where cod_ramo      = v_cod_ramo
						   and cod_subramo   = _cod_subramo
						   and cod_origen    = _cod_origen
						   and cod_contrato  = v_cod_contrato
						   and cod_cobertura = v_cobertura
						   and desc_cob      = v_desc_cobertura
						   and no_poliza     = v_nopoliza;
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
			   and desc_cob      = v_desc_cobertura
			   and no_poliza     = v_nopoliza;


			if _cantidad = 0 then
				insert into temp_produccion
				values(	v_cod_ramo,
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
						v_nopoliza,
						_no_unidad,
						_cod_coasegur);
			else
				update temp_produccion
				   set prima = prima + _monto_reas,
					   comision = comision + _comision,
					   impuesto = impuesto + _impuesto,
					   por_pagar = por_pagar + _por_pagar
				 where cod_ramo = v_cod_ramo
				   and cod_subramo = _cod_subramo
				   and cod_origen = _cod_origen
				   and cod_contrato = v_cod_contrato
				   and cod_cobertura = v_cobertura
				   and desc_cob = v_desc_cobertura
				   and no_poliza = v_nopoliza;

			end if
		elif _tipo_cont = 2 then  --facultativos
		
			select count(*)
			  into _cantidad
			  from emifafac
			 where no_poliza = v_nopoliza
			   and no_endoso = v_noendoso
			   and cod_contrato = v_cod_contrato
			   and cod_cober_reas = v_cobertura;
			   --and no_unidad      = _no_unidad;

			if _cantidad = 0 then
				let v_desc_contrato  = "******* NO EXISTE REGISTRO DE COMPANIAS " || v_cod_contrato;

				select count(*)
				  into _cantidad
				  from temp_produccion
				 where cod_ramo = v_cod_ramo
				   and cod_subramo = _cod_subramo
				   and cod_origen = _cod_origen
				   and cod_contrato = v_cod_contrato
				   and cod_cobertura = v_cobertura
				   and desc_cob = _nombre_cob
				   and no_poliza = v_nopoliza;

				if _cantidad = 0 then

					insert into temp_produccion
					values(	v_cod_ramo,
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
							v_nopoliza,
							_no_unidad,
							'999');
				end if
			else
				foreach
					select first 1 100, --porc_partic_reas, --SD#6654 29052023 HGIRON Como emifafac no esta por unidad que tome la prima al 100% de la primera que encuentre.
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
					   --and no_unidad      = _no_unidad
						
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
					   and desc_cob      = v_desc_cobertura
					   and no_poliza     = v_nopoliza;

					if _cantidad = 0 then
						insert into temp_produccion
						values(	v_cod_ramo,
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
								v_nopoliza,
								_no_unidad,
								_cod_coasegur);
					else
						update temp_produccion
						   set prima = prima + _monto_reas,
							  comision = comision  + _comision,
							  impuesto = impuesto  + _impuesto,
							  por_pagar = por_pagar + _por_pagar
						where cod_ramo = v_cod_ramo
						  and cod_subramo = _cod_subramo
						  and cod_origen = _cod_origen
						  and cod_contrato = v_cod_contrato
						  and cod_cobertura = v_cobertura
						  and desc_cob = v_desc_cobertura
						  and no_poliza = v_nopoliza;
					end if
				end foreach
			end if
		end if
	end foreach
end foreach

/*###############################################################################################*/
/*###############################################################################################*/
return 0,'';
end procedure 