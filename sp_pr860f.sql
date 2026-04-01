------------------------------------------------
--      TOTALES DE PRODUCCION POR             --  
--         CONTRATO DE REASEGURO              --
---  Yinia M. Zamora - octubre 2000 - YMZM	  --
---  Ref. Power Builder - d_sp_pro40		  --
--- Modificado por Armando Moreno 19/01/2002; -- la parte de los tipo de contratos
------------------------------------------------
--execute procedure sp_pr860f('001','001','2019-08','2019-08',"*","*","*","*","001,003,006,008,010,011,012,013,014,021,022;","*","2019,2018,2017,2016,2015,2014,2013,2012,2011,2010,2009,2008;",'01','*')

drop procedure sp_pr860f;

create procedure sp_pr860f(
a_compania		char(03),
a_agencia		char(03),
a_periodo1		char(07),
a_periodo2		char(07),
a_codsucursal	char(255)	default "*",
a_codgrupo		char(255)	default "*",
a_codagente		char(255)	default "*",
a_codusuario	char(255)	default "*",
a_codramo		char(255)	default "*",
a_reaseguro		char(255)	default "*",
a_serie			char(255)	default "*",
a_tipo_bx		char(2)		default "01",
a_contrato      char(255)   default '*')

returning	integer,
			char(255);	
begin
define _error_desc			char(255);
define v_filtros1			char(255);
define v_filtros2			char(255);
define v_filtros			char(255);
define v_desc_cobertura		char(100);
define v_desc_contrato		char(50);
define _nombre_coas			char(50);
define _nombre_cob			char(50);
define _nombre_con			char(50);
define v_desc_ramo			char(50);
define v_descr_cia			char(50);
define _cuenta				char(25);
define _no_doc				char(20);
define v_nopoliza			char(10);
define _no_remesa			char(10);
define _periodo1			char(7);
define v_cod_contrato		char(5);
define _cod_traspaso		char(5);
define _no_unidad			char(5);
define v_noendoso			char(5);
define _cod_coasegur		char(3);
define _cod_subramo			char(3);
define _cod_origen			char(3);
define v_cobertura			char(3);
define v_cod_ramo			char(3);
define v_cod_tipo			char(3);
define _n_cober				char(1);
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
define _prima_sus_tot		dec(16,2);
define _p_sus_tot_sum		dec(16,2);
define _porc_impuesto		dec(16,2);
define _porc_comision		dec(16,2);
define v_rango_final		dec(16,2);
define v_prima_tipo			dec(16,2);
define _sum_fac_car			dec(16,2);
define _prima_total			dec(16,2);
define _monto_reas			dec(16,2);
define _p_sus_tot			dec(16,2);
define _ret_casco			dec(16,2);
define v_prima_bq			dec(16,2);
define v_prima_ot			dec(16,2);
define _por_pagar			dec(16,2);
define _impuesto			dec(16,2);
define _comision			dec(16,2);
define v_prima_1			dec(16,2);
define v_prima_3			dec(16,2);
define v_prima1				dec(16,2);
define v_prima				dec(16,2);
define _tiene_comis_rea		smallint;
define v_tipo_contrato		smallint;
define _facilidad_car		smallint;
define v_porcentaje			smallint;
define _tipo_cont			smallint;
define _no_cambio			smallint;
define _traspaso			smallint;
define _bouquet				smallint;
define _serie				smallint;
define _flag				smallint;
define _cantidad			integer;
define _renglon				integer;
define _error				integer;
define _cnt					integer;
define _fecha				date;
define _no_documento		char(20);
define _vigencia_inic		date;
define _vigencia_ini		date;
define _vigencia_fin		date;
define _fecha_recibo		date;
define v_no_recibo			char(10);
define _no_registro			char(10);
define _sac_notrx			integer;
define _res_comprobante		char(15);
define _no_poliza			char(10);
define _cod_contratante		char(10);
define _fecha_suscripcion	date;
define v_cod_subramo		char(3);
define _n_aseg				char(50);
define v_cedula				varchar(30);
define _cod_manzana			char(15);
define v_name_subramo		varchar(50);
define _name_manzana		varchar(50);
define _tipo2	   smallint;

define _borderaux			char(2);
define _anio_reas			char(9);
define _trim_reas			smallint;
define _serie1				smallint;
define _tiene_comision		smallint;
define nivel				smallint;

define _nivel				smallint;
define _pagado_neto			dec(16,2);
define _cod_ramo			char(3);
define _relac_inund			smallint;
define _siniestro2			dec(16,2);
define _sini_bk				dec(16,2);
define _cnt3				smallint;
define _siniestro			dec(16,2);
define _xnivel				char(3);
define v_clase				char(3);
define _sini_dif			dec(16,2);
define _sini_inc			dec(16,2);
define _sini_mul			dec(16,2);
define _contrato_xl			smallint;


set isolation to dirty read;

drop table if exists temp_produccion;
drop table if exists temp_det;
drop table if exists tmp_priret;
drop table if exists temp_inundacion;
drop table if exists temp_inundacion;
drop table if exists temp_devpri;
drop table if exists temp_devpri_det;
drop table if exists tmp_codigos;

create temp table temp_inundacion(
serie				smallint,
cod_ramo			char(3),
siniestros_pagados	dec(16,2),
relac_inundacion	smallint,
primary key(serie,cod_ramo,relac_inundacion)) with no log;


let _res_comprobante = "";
let v_descr_cia  = sp_sis01(a_compania);
let _periodo1 = a_periodo1;

if a_periodo2 >= '2013-07' then		--Proceso de Devolucion de Prima
	if _periodo1 <= '2013-09' then
		let _periodo1 = '2008-01';
	end if
	-- Cargar los valores de devolucion de primas	  Crea tabla temp_det  (temporal)
	call sp_pr860c1p(a_compania,a_agencia,_periodo1,a_periodo2,a_codsucursal,a_codgrupo,a_codagente,a_codusuario,
					a_codramo,a_reaseguro,a_contrato,a_serie,"*")
	returning _error,_error_desc;
	
	if _error = 1 then
		drop table temp_produccion;
		return	_error,_error_desc;
	end if
	
	select * 
	  from temp_produccion
	  into temp temp_devpri;
	  
	select * 
	  from temp_det
	  into temp temp_devpri_det;	  
	
	drop table temp_produccion;
end if

call sp_pro307(a_compania,a_agencia,a_periodo1,a_periodo2,a_codsucursal,a_codgrupo,
			   a_codagente,a_codusuario,a_codramo,a_reaseguro) returning v_filtros;

-- cargar el incurrido	  crea tabla tmp_sinis  (temporal)
let v_filtros2 = sp_rec708bk1(
a_compania,
a_agencia,
a_periodo1,
a_periodo2,
a_codsucursal,
'*', 
a_codramo, --'*',    ---a_ramo,
'*', 
'*', 
'*', 
'*',
a_contrato);		

create temp table temp_produccion(
	cod_ramo		char(3),
	cod_subramo		char(3),
	cod_origen		char(3),
	cod_contrato	char(5),
	desc_contrato	char(50),
	cod_cobertura	char(3),
	prima			dec(16,2),
	tipo			smallint default 0,
	comision		dec(16,2),
	impuesto		dec(16,2),
	por_pagar		dec(16,2),
	desc_cob		char(100),
	serie			smallint,
	seleccionado	smallint default 1,
	no_poliza		char(10),
	cod_coasegur	char(3),	
	porc_comision	dec(16,2), 
	porc_impuesto	dec(16,2), 
	porc_cont_partic dec(16,2), 	
    no_recibo        char(10),	
    porc_proporcion	 dec(16,2), 	
	no_remesa        char(10),
	renglon          integer,
	cuenta           char(25),
	tipo_registro    smallint default 0, 
primary key(cod_ramo, cod_subramo, cod_origen, cod_contrato, cod_cobertura, desc_cob, no_poliza, serie)) with no log;
create index idx1_temp_produccion on temp_produccion(cod_subramo,cod_origen,cod_contrato,cod_cobertura,desc_cob);
create index idx2_temp_produccion on temp_produccion(cod_ramo,no_poliza,serie,seleccionado);
create index idx3_temp_produccion on temp_produccion(seleccionado);

create temp table tmp_priret(
cod_ramo		char(3),
prima_sus_tot	dec(16,2),
prima			dec(16,2),
prima_sus_t		dec(16,2)) with no log;
{
create temp table tmp_tabla(
no_documento	char(20),
vigencia_ini	date,
vigencia_fin	date,
suma_asegurada	dec(16,2),		
cod_ramo		char(3),
desc_ramo		char(50),
cant_polizas	smallint,
p_cobrada		dec(16,2),
p_retenida		dec(16,2),
p_bouquet		dec(16,2),
p_facultativo	dec(16,2),
p_otros			dec(16,2),
p_fac_car		dec(16,2),
no_recibo		char(10),
res_comprobante	char(15),
n_contrato		varchar(50),
p_ret_casco		dec(16,2),
no_poliza		char(10),
cod_coasegur	char(3),	
primary key (no_documento,vigencia_ini,vigencia_fin,cod_ramo,no_poliza,cod_coasegur)) with no log;
  }
let _cod_subramo = "001";
let v_filtros1 = "";
let v_filtros2 = "";
let _n_cober = "";
let _porc_comis_ase = 0;
let _p_sus_tot_sum = 0;
let _prima_sus_tot = 0;
let _prima_tot_ret = 0;
let _sum_fac_car = 0;
let _p_sus_tot = 0;
let _tipo_cont = 0;
let v_prima = 0;
let _cnt = 0;

foreach
	select no_poliza,
		   no_endoso,
		   prima_neta,	   -- sum(prima_neta),
		   vigencia_inic,	   -- min(vigencia_inic)
		   no_documento,
		   no_factura,
		   no_remesa,
		   renglon
	  into v_nopoliza,
		   v_noendoso,
		   v_prima_cobrada,
		   _fecha,
		   _no_doc,
		   v_no_recibo,
		   _no_remesa,
		   _renglon
	  from temp_det
	 where seleccionado = 1	

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
		insert into tmp_priret
		values(v_cod_ramo,v_prima_cobrada,0,0);
	else
		update tmp_priret
		   set prima_sus_tot = prima_sus_tot + v_prima_cobrada
		 where cod_ramo = v_cod_ramo;
	end if
	
	drop table if exists tmp_reas;
	call sp_sis122a(_no_remesa,_renglon) returning _error,_error_desc;

	foreach		
		select cod_contrato,
			   porc_partic_prima,
			   porc_proporcion,
			   cod_cober_reas
		  into v_cod_contrato,
			   _porc_partic_prima,
			   _porc_proporcion,
			   v_cobertura
		  from tmp_reas

			let _porc_comision = 0;
			let _porc_impuesto = 0;

		select traspaso
		  into _traspaso
		  from reacocob
		 where cod_contrato   = v_cod_contrato
		   and cod_cober_reas = v_cobertura;

		select cod_traspaso,
			   tipo_contrato,
			   serie
		  into _cod_traspaso,
			   v_tipo_contrato,
			   _serie
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

			update tmp_priret
			   set prima    = prima + v_prima1
			 where cod_ramo = v_cod_ramo;

			let _tipo_cont = 1;
		end if

		let v_prima1 = v_prima_cobrada * (_porc_partic_prima / 100) * (_porc_proporcion / 100);
		let v_prima  = v_prima1;
		
		if v_prima is null then
			let v_prima = 0.00;
		end if		

		select nombre,
			   serie
		  into v_desc_contrato,
			   _serie
		  from reacomae
		 where cod_contrato = v_cod_contrato;

		let _nombre_con = trim(v_desc_contrato) || " (" || v_cod_contrato || ")" || "  A: " || _serie;
		let _cuenta     = sp_sis15("PPRXP", "05", _cod_origen, v_cod_ramo, _cod_subramo);

		select nombre
		  into v_desc_ramo
		  from prdramo
		 where cod_ramo = v_cod_ramo;

		select porc_impuesto,
			   porc_comision,
			   tiene_comision
		  into _porc_impuesto,
			   _porc_comision,
			   _tiene_comis_rea
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
				   and desc_cob      = _nombre_cob
				   and serie         = _serie
				   and no_poliza     = v_nopoliza;

				if _cantidad = 0 then
					if _nombre_cob is null then
						let _nombre_cob = '';
					end if
					
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
							'999',
							_porc_comision,
			                _porc_impuesto,
							_porc_partic_prima,
							v_no_recibo,
							_porc_proporcion,
							_no_remesa,
							_renglon,
							_cuenta,
							2);
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
					   and serie         = _serie
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
								_cod_coasegur,
								_porc_comision,
			                    _porc_impuesto,
								_porc_cont_partic,
								v_no_recibo,
								_porc_proporcion,
								_no_remesa,
								_renglon,
								_cuenta,
								2);
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
						   and serie         = _serie
						   and no_poliza     = v_nopoliza;
					end if
				end foreach
			end if
		end if			
	end foreach
end foreach
--trace off;

let _prima_tot_ret_sum = 0;
let _prima_tot_sus_sum = 0;
let _p_sus_tot_sum     = 0;

if a_periodo2 > '2013-07' then
	foreach
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
			   serie,
			   no_poliza,
			   cod_coasegur,
			   porc_comision,
			   porc_impuesto,
			   porc_cont_partic,
			   no_recibo
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
			   _serie,
			   v_nopoliza,
			   _cod_coasegur,
			   _porc_comision,
			   _porc_impuesto,
			   _porc_cont_partic,
			   v_no_recibo
		  from temp_devpri
		 where seleccionado = 1
		
		if _monto_reas is null then
			let _monto_reas = 0.00;
		end if
		
		if _por_pagar is null then
			let _por_pagar = 0.00;
		end if
		
		if _impuesto is null then
			let _impuesto = 0.00;
		end if
		
		if _comision is null then
			let _comision = 0.00;
		end if
		
		let _monto_reas = _monto_reas * -1;
		let _comision = _comision * -1;
		let _impuesto = _impuesto * -1;
		let _por_pagar = _por_pagar * -1;
		
		let _cuenta     = sp_sis15("PPRXP", "05", _cod_origen, v_cod_ramo, _cod_subramo);
		
		select count(*)
		  into _cantidad
		  from temp_produccion
		 where cod_ramo      = v_cod_ramo
		   and cod_subramo   = _cod_subramo
		   and cod_origen    = _cod_origen
		   and cod_contrato  = v_cod_contrato
		   and cod_cobertura = v_cobertura
		   and desc_cob      = v_desc_cobertura
		   and serie         = _serie
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
					_cod_coasegur,
					_porc_comision,
			        _porc_impuesto,
					_porc_cont_partic,
					v_no_recibo	,0,
							'*',
							0,
							_cuenta,
							4);
		else
			update temp_produccion
			   set prima		= prima     + _monto_reas,
				   comision		= comision  + _comision,
				   impuesto		= impuesto  + _impuesto,
				   por_pagar	= por_pagar + _por_pagar
			 where cod_ramo  		= v_cod_ramo
			   and cod_subramo		= _cod_subramo
			   and cod_origen		= _cod_origen
			   and cod_contrato		= v_cod_contrato
			   and cod_cobertura	= v_cobertura
			   and desc_cob			= v_desc_cobertura
			   and serie            = _serie
			   and no_poliza		= v_nopoliza;
		end if
	end foreach
end if


	foreach
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
			   serie,
			   no_poliza,
			   cod_coasegur,
			   porc_comision,
			   porc_impuesto,
			   porc_cont_partic,
			   no_recibo
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
			   _serie,
			   v_nopoliza,
			   _cod_coasegur,
			   _porc_comision,
			   _porc_impuesto,
			   _porc_cont_partic,
			   v_no_recibo
		  from temp_devpri
		 where seleccionado = 1
		
		if _monto_reas is null then
			let _monto_reas = 0.00;
		end if
		
		if _por_pagar is null then
			let _por_pagar = 0.00;
		end if
		
		if _impuesto is null then
			let _impuesto = 0.00;
		end if
		
		if _comision is null then
			let _comision = 0.00;
		end if
		
		let _monto_reas = _monto_reas * -1;
		let _comision = _comision * -1;
		let _impuesto = _impuesto * -1;
		let _por_pagar = _por_pagar * -1;
		
		let _cuenta     = sp_sis15("PPRXP", "05", _cod_origen, v_cod_ramo, _cod_subramo);
		
		select count(*)
		  into _cantidad
		  from temp_produccion
		 where cod_ramo      = v_cod_ramo
		   and cod_subramo   = _cod_subramo
		   and cod_origen    = _cod_origen
		   and cod_contrato  = v_cod_contrato
		   and cod_cobertura = v_cobertura
		   and desc_cob      = v_desc_cobertura
		   and serie         = _serie
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
					_cod_coasegur,
					_porc_comision,
			        _porc_impuesto,
					_porc_cont_partic,
					v_no_recibo	,0,
							'*',
							0,
							_cuenta,
							3);
		else
			update temp_produccion
			   set prima		= prima     + _monto_reas,
				   comision		= comision  + _comision,
				   impuesto		= impuesto  + _impuesto,
				   por_pagar	= por_pagar + _por_pagar
			 where cod_ramo  		= v_cod_ramo
			   and cod_subramo		= _cod_subramo
			   and cod_origen		= _cod_origen
			   and cod_contrato		= v_cod_contrato
			   and cod_cobertura	= v_cobertura
			   and desc_cob			= v_desc_cobertura
			   and serie            = _serie
			   and no_poliza		= v_nopoliza;
		end if
	end foreach
	

-- Adicionar filtro contrato y serie
-- Filtro por Contrato
if a_contrato <> "*" then
	let v_filtros1 = trim(v_filtros1) ||" Contrato "||trim(a_contrato);
	let _tipo = sp_sis04(a_contrato); -- separa los valores del string

	if _tipo <> "E" then -- incluir los registros
		update temp_produccion
		       set seleccionado = 0
		     where seleccionado = 1
		       and cod_contrato not in(select codigo from tmp_codigos);
	else
		update temp_produccion
		       set seleccionado = 0
		     where seleccionado = 1
		       and cod_contrato in(select codigo from tmp_codigos);
		end if
	drop table tmp_codigos;
end if

-- Filtro por Serie
if a_serie <> "*" then
	let v_filtros1 = trim(v_filtros1) ||" Serie "||trim(a_serie);
	let _tipo = sp_sis04(a_serie); -- separa los valores del string

	if _tipo <> "E" then -- incluir los registros
		update temp_produccion
		       set seleccionado = 0
		     where seleccionado = 1
		       and serie not in(select codigo from tmp_codigos);
	else
		update temp_produccion
		       set seleccionado = 0
		     where seleccionado = 1
		       and serie in(select codigo from tmp_codigos);
		end if
	drop table tmp_codigos;
end if
let v_filtros = trim(v_filtros1)||" "|| trim(v_filtros)||" "|| trim(v_filtros2);

-- ****Inclusion de siniestros		   
drop table if exists tmp_temphg;
create temp table tmp_temphg (
cod_coasegur      CHAR(3), 
cod_ramo          CHAR(3), 
cod_contrato      CHAR(5), 
desc_contrato     CHAR(50), 
cod_cobertura     CHAR(3), 
prima             DECIMAL(16,2), 
tipo              SMALLINT, 
comision          DECIMAL(16,2), 
impuesto          DECIMAL(16,2), 
por_pagar         DECIMAL(16,2), 
desc_cob          CHAR(100), 
porc_comision     DECIMAL(16,2), 
porc_impuesto     DECIMAL(16,2), 
porc_cont_partic  DECIMAL(16,2), 
serie             SMALLINT, 
tipo_contrato     SMALLINT, 
tiene_comision    SMALLINT, 
seleccionado      SMALLINT, 
anio              CHAR(9), 
trimestre         SMALLINT, 
borderaux         CHAR(2)) with no log;
--,primary key(cod_coasegur,cod_ramo,cod_contrato,cod_cobertura,tipo,serie,anio,trimestre,borderaux)) with no log;

drop table if exists tmp_reacoest;
create temp table tmp_reacoest (
cod_coasegur      CHAR(3), 
cod_ramo          CHAR(3), 
cod_contrato      CHAR(5), 
cod_cobertura     CHAR(3), 
prima             DECIMAL(16,2), 
comision          DECIMAL(16,2), 
impuesto          DECIMAL(16,2), 
prima_neta        DECIMAL(16,2), 
siniestro         DECIMAL(16,2), 
resultado         DECIMAL(16,2), 
participar        DECIMAL(16,2), 
p_partic          DECIMAL(16,2), 
cod_clase         CHAR(3), 
anio              CHAR(9), 
trimestre         SMALLINT, 
borderaux         CHAR(2), 
desc_contrato     CHAR(5)) with no log;
-- ,primary key(cod_coasegur,cod_ramo,cod_contrato,cod_cobertura,anio,trimestre,borderaux,desc_contrato)) with no log;


let _borderaux = a_tipo_bx; 

select tipo
  into _tipo2
  from reacontr
 where cod_contrato = _borderaux;

call sp_rea002(a_periodo2,_tipo2) returning _anio_reas,_trim_reas;

delete from tmp_temphg
 where anio      = _anio_reas
   and trimestre = _trim_reas
   and borderaux = _borderaux;  -- Elimina borderaux datos
	   
foreach 
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
		   _serie1
	  from temp_produccion
	 where seleccionado = 1 

	let _bouquet        = 0;
	let _flag        = 0;

	select traspaso,
		   tiene_comision,
		   bouquet
	  into _traspaso,
		   _tiene_comision,
		   _bouquet
	  from reacocob
	 where cod_contrato   = v_cod_contrato
	   and cod_cober_reas = v_cobertura;

	select tipo_contrato,
		   serie,
		   facilidad_car
	  into v_tipo_contrato,
		   _serie,
		   _facilidad_car
	  from reacomae
	 where cod_contrato = v_cod_contrato;

	let _serie = _serie1;

	if _bouquet <> 1 then
	   continue foreach;
	end if

	if _bouquet = 1 and _serie >= 2008 then --and _cod_coasegur in ('050','063','076','042','036','089','117','128','134') then	   -- condiciones del borderaux bouquet
		let _flag = 0;
		let _cnt  = 0;

		if _facilidad_car = 0 then
			if _cnt = 0 then
				let _flag = 1;
			end if
		end if
	end if

	let nivel = 1;

	if _porc_cont_partic = 100 or _flag = 1 then
	   let nivel = 2;
	else
	   let nivel = 1;
	end if

	insert into tmp_temphg
	values(	_cod_coasegur,
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
end foreach

--evento inundacion para tomar la participacion de la swiss re
{let _cnt2       = 0;
let _siniestro3 = 0;
let _siniestro4 = 0;
let _sini_inc   = 0;
let _sini_mul   = 0;}

foreach
	select sum(t.pagado_neto),
		   t.cod_ramo,
		   r.serie,
		   p.relac_inundacion
	  into _pagado_neto,
		   _cod_ramo,
		   _serie,
		   _relac_inund
	  from tmp_sinis t, reacomae r, recrccob rc, prdcober p
	 where t.no_reclamo = rc.no_reclamo
	   and rc.cod_cobertura = p.cod_cobertura
	   and r.cod_contrato = t.cod_contrato
	   and t.seleccionado = 1
	   and t.tipo_contrato not in ('3','1')
	   and r.serie >= 2012
	   and t.cod_ramo in('001','003')
	 group by t.cod_ramo,r.serie,p.relac_inundacion
	   
	begin
		on exception in(-239)
			update temp_inundacion
			   set siniestros_pagados = siniestros_pagados + _pagado_neto 
			 where cod_ramo = _cod_ramo
			   and serie  = _serie
			   and relac_inundacion = _relac_inund;
		end exception 	

		insert into temp_inundacion
		values (_serie,_cod_ramo,_pagado_neto,_relac_inund);
	end
end foreach

let _pagado_neto = 0;
let _siniestro2 = 0;
let _sini_bk    = 0;
let _cnt3       = 0;


foreach
	select r.serie,
		   t.cod_ramo,
		   t.cod_contrato,
		   sum(t.pagado_neto) 
	  into _serie,
		   v_cod_ramo,
		   v_cod_contrato,
		   _siniestro 
	  from tmp_sinis t, reacomae r
	 where r.cod_contrato = t.cod_contrato
	   and t.seleccionado = 1
	   and t.tipo_contrato not in ('3','1')
	   and r.serie >= 2008
	   and t.cod_ramo in ("001","003","006","010","011","012","013","014","008","080","004","019","016","021","022","002","023","020")
     group by r.serie,t.cod_ramo,t.cod_contrato
     order by r.serie,t.cod_ramo,t.cod_contrato

	select count(*)
	  into _cnt
	  from tmp_temphg 
	 where cod_ramo     = v_cod_ramo
	   and cod_contrato = v_cod_contrato
	   and serie        = _serie;

	if _cnt > 0 then
		foreach
			select distinct cod_cobertura
			  into v_cobertura
			  from tmp_temphg 
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

	let _sini_bk = _siniestro;

	foreach
		select distinct cod_cober_reas,
			   cod_coasegur,
			   porc_cont_partic
		 into v_cobertura,
			  _cod_coasegur,_porc_cont_partic
		 from reacoase
		where cod_contrato   = v_cod_contrato
		  and cod_cober_reas = v_cobertura

		let _siniestro = _sini_bk;

		if v_cod_ramo in('002','023','020') then 
			 let v_clase = '013' ; --Automovil
		end if

		if v_cod_ramo = '006' then 
			 let v_clase = '001' ; --R.C.G.
		end if

		if v_cod_ramo = '001' or v_cod_ramo = '003' then 
			 let v_clase = '002' ; --INCENDIO
		end if 

		-- if v_cod_ramo = '010' or v_cod_ramo = '011' or v_cod_ramo = '012' or v_cod_ramo = '013' or v_cod_ramo = '014' or v_cod_ramo = '022' then
		if v_cod_ramo in ('010','011','012','013','014','022' )then
			 let v_clase = '004' ; --RAMOS TECNICOS
		end if

		if v_cod_ramo in ('008','080') then 
			 let v_clase = '005' ; --FIANZAS
		end if
		if v_cod_ramo = '004' then 
			 let v_clase = '006' ; --ACCIDENTES PERSONALES
		end if
		if v_cod_ramo = '019' then 
			 let v_clase = '007' ; --VIDA IND. COL DE VIDA
		end if

		if v_cod_ramo = '016' then --Col. de Vida
			 let v_clase = '012';
		end if

		if _borderaux = '01' and _cod_coasegur = '042' and _serie >= 2012 then
			if v_cod_ramo = '001' or v_cod_ramo = '003' then 
			
				let v_clase = '011';
				select abs(siniestros_pagados)
				  into _siniestro
				  from temp_inundacion
				 where cod_ramo = v_cod_ramo
				   and serie = _serie
				   and relac_inundacion = 1;
				   
				if _siniestro is null then
					let _siniestro = 0;
				end if
			end if					
		end if

		if _porc_cont_partic < 100 then 
		   let _xnivel = '1';
		else
		   let _xnivel = '2';
		end if
		if _borderaux = '01' and _cod_coasegur = '042' and _serie = 2011 then
			if v_cod_ramo = '001' and _siniestro2 <> 0 then
				 let _sini_dif = 0;
				 let _sini_dif = _siniestro - _siniestro2;
				 --let _sini_dif = abs(_sini_dif);

				update tmp_reacoest 
				   set siniestro     = siniestro + _sini_dif 
				 where cod_coasegur	 = _cod_coasegur 
				   and cod_contrato  = _serie 
				   and cod_cobertura = _xnivel 
				   and p_partic      = _porc_cont_partic 
				   and cod_ramo      = v_cod_ramo 
				   and cod_clase     = v_clase 
				   and anio          = _anio_reas 
				   and trimestre     = _trim_reas 
				   and borderaux     = _borderaux;

				 let v_clase     = '003';
				 let v_cobertura = '021';

				 select porc_cont_partic
				   into _porc_cont_partic
				   from reacoase
				  where cod_contrato   = v_cod_contrato
					and cod_cober_reas = v_cobertura
					and cod_coasegur   = _cod_coasegur;

				 let _siniestro = _siniestro2;
			end if
		end if

		if _porc_cont_partic < 100 then 
		   let _xnivel = '1';
		else
		   let _xnivel = '2';
		end if

		--contrato XL
		select contrato_xl
		  into _contrato_xl
		  from reacoase
		 where cod_contrato   = v_cod_contrato
		   and cod_cober_reas = v_cobertura
		   and cod_coasegur   = _cod_coasegur;

		if _contrato_xl = 1 then
			if v_clase <> "011" then
				let _porc_cont_partic = 0;
			end if
		else
		end if

		select count(*)
		  into _cantidad
		  from tmp_reacoest
		 where cod_coasegur	 = _cod_coasegur 
		   and cod_contrato  = _serie 
		   and cod_cobertura = _xnivel 
		   and p_partic      = _porc_cont_partic 
		   and cod_ramo      = v_cod_ramo 
		   and cod_clase     = v_clase 
		   and anio          = _anio_reas 
		   and trimestre     = _trim_reas 
		   and borderaux     = _borderaux
		   and desc_contrato = v_desc_contrato; 

		if _cantidad > 0 then

			update tmp_reacoest 
			   set siniestro     = (siniestro + _siniestro) / _cantidad
			 where cod_coasegur	 = _cod_coasegur 
			   and cod_contrato  = _serie 
			   and cod_cobertura = _xnivel 
			   and p_partic      = _porc_cont_partic 
			   and cod_ramo      = v_cod_ramo 
			   and cod_clase     = v_clase 
			   and anio          = _anio_reas 
			   and trimestre     = _trim_reas 
			   and borderaux     = _borderaux
			   and desc_contrato = v_cod_contrato;
		else
			insert into tmp_reacoest(
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
					borderaux,
					desc_contrato)
			values (_cod_coasegur,
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
					_borderaux,
					v_cod_contrato);
		end if
	end foreach
end foreach


return 0,'';
end
end procedure 
                    
                                                                                                                                           
