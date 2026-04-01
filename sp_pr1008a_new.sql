--------------------------------------------
--      TOTALES DE PRODUCCION POR         --
--         CONTRATO DE REASEGURO          --
---  Yinia M. Zamora - octubre 2000       -- YMZM
---  Ref. Power Builder - reemplaza sp_pro308
--- Modificado por Armando Moreno 19/01/2002; la parte de los tipo de contratos
--- Modificado por Henry 10/9/2009 filtros requeridos por Sr. Omar Wong
--- Quitar el filtro de rangos.
-- execute procedure sp_pr1008a('001','001','2016-06','2016-06','*','*','*','*','002,020,023;','*','*','2015,2014,2013,2012,2011,2010,2009,2008;','*')
--------------------------------------------
drop procedure sp_pr1008a;
create procedure sp_pr1008a(
a_compania		char(3),
a_agencia		char(3),
a_periodo1		char(7),
a_periodo2		char(7),
a_codsucursal	char(255)	default '*',
a_codgrupo		char(255)	default '*',
a_codagente		char(255)	default '*',
a_codusuario	char(255)	default '*',
a_codramo		char(255)	default '*',
a_reaseguro		char(255)	default '*',
a_contrato		char(255)	default '*',
a_serie			char(255)	default '*',
a_subramo		char(255)	default '*')
returning	char(20)		as poliza,
			date			as vigencia_inicial,
			date			as vigencia_final,
			dec(16,2)		as suma_asegurada,
			char(3)			as cod_ramo,
			char(50)		as ramo,
			smallint		as cant_polizas,
			dec(16,2)		as prima_suscrita,
			dec(16,2)		as retencion_rc,
			dec(16,2)		as prima_bouquet,
			dec(16,2)		as prima_facultativo,
			dec(16,2)		as prima_otros,
			char(255)		as filtros,
			char(50)		as compania,
			dec(16,2)		as prima_fac_car,
			char(10)		as factura,
			char(15)		as res_comprobante,
			varchar(50)		as contrato,
			char(50)		as cliente,
			date			as fecha_suscripcion,
			varchar(30)		as cedula,  -- ruc
			varchar(50)		as subramo,  -- subramo
			dec(16,2)		as retencion_casco,
			char(15)		as manzana,
			dec(16,2)		as retencion_otros,
			dec(16,2)		as contrato_otro,
			dec(16,2)		as contrato_casco;
begin

define v_name_subramo		varchar(50);
define _error_desc			varchar(50);
define _n_contrato			varchar(50);
define v_cedula				varchar(30);
define v_filtros2			char(255);
define v_filtros1			char(255);
define v_filtros			char(255);
define v_desc_cobertura		char(100);
define v_desc_contrato		char(50);
define _nombre_coas			char(50);
define v_desc_ramo			char(50);
define v_descr_cia			char(50);
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
define v_nopoliza			char(10);
define v_cod_contrato		char(5);
define _cod_traspaso		char(5);
define v_noendoso			char(5);
define _no_unidad			char(5);
define _cod_coasegur		char(3);
define v_cod_subramo		char(3);
define _cod_tipoprod		char(3);
define _cod_subramo			char(3);
define v_cobertura2			char(3);
define v_cobertura			char(3);
define _cod_origen			char(3);
define v_cod_ramo			char(3);
define v_cod_tipo			char(3);
define _tipo				char(1);
define _t_ramo				char(1);
define _porc_cont_partic	dec(5,2);
define _porc_comis_ase		dec(5,2);
define _porc_partic_prima	dec(7,4);
define _porc_partic_coas	dec(7,4);
define _prima_tot_ret_sum	dec(16,2);
define _prima_tot_sus_sum	dec(16,2);
define v_suma_asegurada		dec(16,2);
define v_prima_suscrita		dec(16,2);
define v_prima_cobrada		dec(16,2);
define _cont_cob_otros 		dec(16,2);
define v_rango_inicial		dec(16,2);
define _porc_impuesto		dec(16,2);
define _porc_comision		dec(16,2);
define _p_sus_tot_sum		dec(16,2);
define _prima_tot_ret		dec(16,2);
define _prima_sus_tot		dec(16,2);
define v_rango_final		dec(16,2);
define v_prima_casco		dec(16,2);
define v_prima_tipo			dec(16,2);
define _prima_total			dec(16,2);
define _monto_reas			dec(16,2);
define _cont_casco			dec(16,2);
define _por_pagar			dec(16,2);
define _p_sus_tot			dec(16,2);
define v_prima_bq			dec(16,2);
define v_prima_ot			dec(16,2);
define _cob_otros			dec(16,2);
define _impuesto			dec(16,2);
define _comision			dec(16,2);
define v_prima_3			dec(16,2);
define v_prima_1			dec(16,2);
define v_prima2				dec(16,2);
define v_prima1				dec(16,2);
define v_prima				dec(16,2);
define _ret_casco			dec(16,2);
define _sum_fac_car			dec(16,2);
define _tiene_comis_rea		smallint;
define v_tipo_contrato		smallint;
define _facilidad_car		smallint;
define v_porcentaje			smallint;
define _no_cambio			smallint;
define _tipo_cont			smallint;
define _traspaso			smallint;
define _cantidad			smallint;
define _bouquet				smallint;
define _error				smallint;
define _serie				smallint;
define _flag				smallint;
define _cnt					smallint;
define _sac_notrx			integer;
define _fecha_suscripcion	date;
define _vigencia_inic		date;
define _vigencia_ini		date;
define _vigencia_fin		date;
define _fecha_recibo		date;
define _fecha				date;

set isolation to dirty read;

let v_descr_cia  = sp_sis01(a_compania);
let _cod_subramo = "001";
let v_filtros = "";
let v_name_subramo = "";
let v_no_recibo = "";
let v_filtros1 = "";
let v_filtros2 = "";
let v_cedula = "";
let _porc_comis_ase = 0;
let _prima_tot_ret = 0;
let _prima_sus_tot = 0;
let _p_sus_tot_sum = 0;
let _sum_fac_car = 0;
let _p_sus_tot = 0;
let _tipo_cont = 0;
let _sac_notrx = 0;
let v_prima = 0;
let _cnt = 0;
let _n_contrato = null;
let _res_comprobante = "";

drop table if exists temp_produccion;
drop table if exists temp_det;
drop table if exists tmp_tabla;
drop table if exists tmp_ramos;


let _ret_casco = 0;
call sp_pro34(a_compania,a_agencia,a_periodo1,a_periodo2,a_codsucursal,a_codgrupo,a_codagente,a_codusuario,a_codramo,a_reaseguro) returning v_filtros;


create temp table tmp_ramos(
cod_ramo         char(3),
cod_sub_tipo     char(3),
porcentaje       smallint default 100,
primary key(cod_ramo, cod_sub_tipo)) with no log;			

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
no_recibo		char(10),
cob_otros		dec(16,2),
primary key(cod_ramo, cod_subramo, cod_origen, cod_contrato, cod_cobertura, desc_cob, serie, no_poliza)) with no log;

create index idx1_temp_produccion on temp_produccion(cod_subramo);
create index idx2_temp_produccion on temp_produccion(cod_contrato);
create index idx3_temp_produccion on temp_produccion(cod_ramo,no_poliza);
create index idx4_temp_produccion on temp_produccion(serie);
create index idx5_temp_produccion on temp_produccion(seleccionado);

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
ret_casco		dec(16,2),
ret_otros		dec(16,2),
cont_otros		dec(16,2),
cont_casco		dec(16,2),
primary key (no_documento,vigencia_ini,vigencia_fin,cod_ramo)) with no log;
create index idx1_tmp_tabla on tmp_tabla(cod_ramo);
create index idx2_tmp_tabla on tmp_tabla(no_documento,cod_ramo);

let _cod_subramo = "001";
let v_name_subramo = "";
let v_no_recibo = "";
let v_filtros1 = "";
let v_filtros2 = "";
let v_cedula = "";
let _porc_comis_ase = 0;
let _prima_tot_ret = 0;
let _prima_sus_tot = 0;
let _p_sus_tot_sum = 0;
let _sum_fac_car = 0;
let _p_sus_tot = 0;
let _tipo_cont = 0;
let _sac_notrx = 0;
let v_prima = 0;
let _cnt = 0;
let _n_contrato = null;

if a_subramo <> "*" then
	let v_filtros2 = trim(v_filtros2) ||" Sub Ramo "||trim(a_subramo);
	let _tipo = sp_sis04(a_subramo); -- separa los valores del string

	if _tipo <> "E" then -- incluir los registros
		update temp_det
		   set seleccionado = 0
		 where seleccionado = 1
		   and cod_subramo not in(select codigo from tmp_codigos);
	else
		update temp_det
		   set seleccionado = 0
		 where seleccionado = 1
		   and cod_subramo in(select codigo from tmp_codigos);
	end if
	drop table tmp_codigos;
end if

--set debug file to "sp_pr999sr.trc";
--trace on;


foreach with hold
	select no_poliza,																	 
		   no_endoso																		 
	  into v_nopoliza,
		   v_noendoso
	  from temp_det
	 where seleccionado = 1
	group by 1, 2

	--begin work;

{   -- SD#2271 CECHAVAR a partir 17-03-2022
	if v_nopoliza in ('500318','137255') then
		--commit work;
		continue foreach;
	end if
}

	foreach
		select no_factura
		  into v_no_recibo
		  from temp_det
		 where seleccionado = 1
		   and no_poliza = v_nopoliza
		   and no_endoso = v_noendoso

		exit foreach;
	end foreach

	select cod_ramo,
		   cod_origen
	  into v_cod_ramo,
		   _cod_origen
	  from emipomae
	 where no_poliza = v_nopoliza;

	{if _vigencia_inic < '01/07/2014' then
		continue foreach;
	end if}

	select cod_tipoprod
	  into _cod_tipoprod
	  from endedmae
	 where no_poliza = v_nopoliza
	   and no_endoso = v_noendoso;

	drop table if exists tmp_reas;
	call sp_sis122(v_nopoliza, v_noendoso) returning _error,_error_desc;

	foreach
		select cod_cober_reas,
			   cod_contrato,
			   prima_rea,
			   no_unidad,
			   porc_partic_prima
		  into v_cobertura,
			   v_cod_contrato,
			   v_prima1,
			   _no_unidad,
			   _porc_partic_prima
		  from tmp_reas
		 where prima_rea <> 0

		{select cod_cober_reas,
			   cod_contrato,
			   prima,
			   no_unidad,
			   porc_partic_prima
		  into v_cobertura,
			   v_cod_contrato,
			   v_prima1,
			   _no_unidad,
			   _porc_partic_prima
		  from emifacon
		 where no_poliza = v_nopoliza
		   and no_endoso = v_noendoso
		   and prima <> 0}

		let _porc_partic_coas = 100;

		if _cod_tipoprod = '001' then
			select porc_partic_coas
			  into _porc_partic_coas
			  from endcoama
			 where no_poliza = v_nopoliza
			   and no_endoso = v_noendoso
			   and cod_coasegur = '036';

			if _porc_partic_coas is null then
				let _porc_partic_coas = 100;
			end if
		end if

		let v_prima2 = 0.00;
		let v_prima_casco = 0.00;

		if v_cobertura in ('002','033') then
			select sum(c.prima_neta) * (_porc_partic_coas/100) 
			  into v_prima2
			  from endedcob c, prdcober p
			 where c.cod_cobertura = p.cod_cobertura
			   and no_poliza = v_nopoliza
			   and no_endoso = v_noendoso
			   and no_unidad = _no_unidad
			   and p.cod_cober_reas = v_cobertura
			   and c.cod_cobertura not in ('00102','00107','00113','00117','01299','01302','01304','01305');

			if v_prima2 is null then
				let v_prima2 = 0.00;
			end if

			let v_prima2 = v_prima2 * (_porc_partic_prima/100);
			
			{if v_cobertura = '002' then
				let v_cobertura2 = '031';
			else
				let v_cobertura2 = '034';
			end if

			select sum(c.prima_neta) * (_porc_partic_coas/100) 
			  into v_prima_casco
			  from endedcob c, prdcober p
			 where c.cod_cobertura = p.cod_cobertura
			   and no_poliza = v_nopoliza
			   and no_endoso = v_noendoso
			   and no_unidad = _no_unidad
			   and p.cod_cober_reas = v_cobertura2;

			if v_prima_casco is null then
				let v_prima_casco = 0.00;
			end if

			let v_prima_casco = v_prima_casco * (_porc_partic_prima/100);}
		end if

		let v_prima1 = v_prima1 - v_prima2 - v_prima_casco;

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
			
			select tipo_contrato,
				   serie
			  into v_tipo_contrato,
				   _serie
			  from reacomae
			 where cod_contrato = v_cod_contrato;
		end if

		let _tipo_cont = 0;

		if v_tipo_contrato = 3 then	  --fac
			let _tipo_cont = 2;
		elif v_tipo_contrato = 1 then --retencion
		   let _tipo_cont = 1;
		end if

		-- let v_prima1 = v_prima_cobrada * _porc_partic_prima / 100;
		let v_prima  = v_prima1;

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
				   and serie      = _serie
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
							'999',
							v_no_recibo,
							v_prima2);
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
					   and serie      = _serie
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
								v_no_recibo,
								v_prima2);
					else					   
						update temp_produccion
						   set prima = prima + _monto_reas,
							   comision = comision + _comision,
							   impuesto = impuesto + _impuesto,
							   por_pagar = por_pagar + _por_pagar,
							   cob_otros = cob_otros + v_prima2
						 where cod_ramo = v_cod_ramo
						   and cod_subramo = _cod_subramo
						   and cod_origen = _cod_origen
						   and cod_contrato = v_cod_contrato
						   and cod_cobertura = v_cobertura
						   and desc_cob = v_desc_cobertura
						   and serie = _serie
						   and no_poliza = v_nopoliza;
					end if
				end foreach
				
				if v_prima_casco <> 0 then

					select nombre
					  into _nombre_cob
					  from reacobre
					 where cod_cober_reas = v_cobertura2;

					let v_desc_cobertura = "";
					let v_desc_cobertura = trim(_nombre_cob) || "  " || trim(_cuenta) || "  " || trim(_nombre_coas);

					select count(*)
					  into _cantidad
					  from temp_produccion
					 where cod_ramo      = v_cod_ramo
					   and cod_subramo   = _cod_subramo
					   and cod_origen    = _cod_origen
					   and cod_contrato  = v_cod_contrato
					   and cod_cobertura = v_cobertura2
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
								v_cobertura2,
								v_prima_casco,
								_tipo_cont,
								_comision, 
								_impuesto, 
								_por_pagar,
								v_desc_cobertura,
								_serie,
								1,
								v_nopoliza,
								_cod_coasegur,
								v_no_recibo,
								0);
					else
						update temp_produccion
						   set prima = prima + v_prima_casco,
							   comision = comision + _comision,
							   impuesto = impuesto + _impuesto,
							   por_pagar = por_pagar + _por_pagar,
							   cob_otros	= cob_otros + 0
						 where cod_ramo = v_cod_ramo
						   and cod_subramo = _cod_subramo
						   and cod_origen = _cod_origen
						   and cod_contrato = v_cod_contrato
						   and cod_cobertura = v_cobertura2
						   and desc_cob = v_desc_cobertura
						   and serie = _serie 
						   and no_poliza = v_nopoliza;
					end if
				end if
			end if
		elif _tipo_cont = 1 then	  --Retencion

			let _cod_coasegur   = '036'; --ancon
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
			   and serie      = _serie
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
						v_no_recibo,
						v_prima2);
			else			   
				update temp_produccion
				  set prima         = prima     + _monto_reas,
					  comision      = comision  + _comision,
					  impuesto      = impuesto  + _impuesto,
					  por_pagar     = por_pagar + _por_pagar,
					  cob_otros     = cob_otros + v_prima2
				where cod_ramo      = v_cod_ramo
				  and cod_subramo   = _cod_subramo
				  and cod_origen    = _cod_origen
				  and cod_contrato  = v_cod_contrato
				  and cod_cobertura = v_cobertura
				  and desc_cob      = v_desc_cobertura
				  and serie      = _serie
				  and no_poliza     = v_nopoliza;
			end if
			
			if v_prima_casco <> 0 then

				select nombre
				  into _nombre_cob
				  from reacobre
				 where cod_cober_reas = v_cobertura2;

				let v_desc_cobertura = "";
				let v_desc_cobertura = trim(_nombre_cob) || "  " || trim(_cuenta) || "  " || trim(_nombre_coas);

				select count(*)
				  into _cantidad
				  from temp_produccion
				 where cod_ramo      = v_cod_ramo
				   and cod_subramo   = _cod_subramo
				   and cod_origen    = _cod_origen
				   and cod_contrato  = v_cod_contrato
				   and cod_cobertura = v_cobertura2
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
							v_cobertura2,
							v_prima_casco,
							_tipo_cont,
							_comision, 
							_impuesto, 
							_por_pagar,
							v_desc_cobertura,
							_serie,
							1,
							v_nopoliza,
							_cod_coasegur,
							v_no_recibo,
							0);
				else
					update temp_produccion
					   set prima = prima + v_prima_casco,
						   comision = comision + _comision,
						   impuesto = impuesto + _impuesto,
						   por_pagar = por_pagar + _por_pagar,
						   cob_otros	= cob_otros + 0
					 where cod_ramo = v_cod_ramo
					   and cod_subramo = _cod_subramo
					   and cod_origen = _cod_origen
					   and cod_contrato = v_cod_contrato
					   and cod_cobertura = v_cobertura2
					   and desc_cob = v_desc_cobertura
					   and serie = _serie 
					   and no_poliza = v_nopoliza;
				end if
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
				   and serie      = _serie
				   and no_poliza     = v_nopoliza;

				if _cantidad = 0 then
					
					if v_cobertura in ('021','022') then
						let _monto_reas = v_prima;
					else
						let _monto_reas = v_prima;
					end if

					INSERT INTO temp_produccion
					VALUES(	v_cod_ramo,
							_cod_subramo,
							_cod_origen,
							v_cod_contrato,
							v_desc_contrato,
							v_cobertura,
							_monto_reas,
							_tipo_cont,
							0, 
							0, 
							0,
							_nombre_cob,
							_serie,
							1,
							v_nopoliza,
							'999',
							v_no_recibo,
							v_prima2);
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
					   and desc_cob      = v_desc_cobertura
					   and serie      = _serie
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
								v_no_recibo,
								v_prima2);
					else
					   update temp_produccion
						  set prima     = prima     + _monto_reas,
							  comision  = comision  + _comision,
							  impuesto  = impuesto  + _impuesto,
							  por_pagar = por_pagar + _por_pagar,
							  cob_otros = cob_otros + v_prima2
						where cod_ramo  = v_cod_ramo
						  and cod_subramo	= _cod_subramo
						  and cod_origen    = _cod_origen
						  and cod_contrato  = v_cod_contrato
						  and cod_cobertura = v_cobertura
						  and desc_cob      = v_desc_cobertura
						  and serie      = _serie
						  and no_poliza     = v_nopoliza;
					end if
				end foreach
			end if	
		end if
	end foreach
	
	--commit work;
end foreach
--trace off;
--begin work;
  let _prima_tot_ret_sum = 0;
  let _prima_tot_sus_sum = 0;
  let _p_sus_tot_sum     = 0;

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

-- filtro por serie

if a_serie <> "*" then
	let v_filtros1 = trim(v_filtros1) ||" Serie "||TRIM(a_serie);
	let _tipo = sp_sis04(a_serie); -- separa los valores del string

	if _tipo <> "E" then -- incluir los registros
		update temp_produccion
		   set seleccionado = 0
		 where seleccionado = 1
		   and serie not in(select codigo from tmp_codigos);

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

--- tabla de ramos:

foreach
	select distinct cod_ramo
	  into v_cod_ramo
	  from temp_produccion
	 where seleccionado = 1

	if v_cod_ramo in ("001", "003") then
		if v_cod_ramo in ("001") then
			let _t_ramo = "1";
		end if

		if v_cod_ramo in ("003") then
			let _t_ramo = "3";
		end if

		begin
			on exception in(-239)
			end exception

		    let v_cod_tipo = "IN"||_t_ramo;

			insert into tmp_ramos (cod_ramo,cod_sub_tipo,porcentaje)
			values (v_cod_ramo,v_cod_tipo,100);--70
			--values (v_cod_ramo,v_cod_tipo,70);--70

		    let v_cod_tipo = "TE"||_t_ramo;

			insert into tmp_ramos (cod_ramo,cod_sub_tipo,porcentaje)
			values (v_cod_ramo,v_cod_tipo,100);	--30
		end
	else
		insert into tmp_ramos (cod_ramo,cod_sub_tipo,porcentaje) 
		values (v_cod_ramo,v_cod_ramo,100); 
	end if
end foreach
--commit work;

foreach with hold
	select cod_ramo,		  --se busca por polizas
		   no_poliza,
		   sum(prima + cob_otros)
	  into v_cod_ramo,
		   v_nopoliza,
		   v_prima
	  from temp_produccion
	 where seleccionado = 1
	 group by cod_ramo, no_poliza
	 order by cod_ramo, no_poliza

	--begin work;

	if v_prima is null then
		let v_prima = 0.00;
	end if

	select suma_asegurada,
		   no_documento,
		   vigencia_inic,
		   vigencia_final
	  into v_suma_asegurada,
		   _no_documento,
		   _vigencia_ini,
		   _vigencia_fin
	  from emipomae
	 where no_poliza = v_nopoliza;

	if _vigencia_fin is null or _vigencia_fin = '' then
		let _vigencia_fin = _vigencia_ini + 1 units year;
	end if
	
	if _vigencia_ini is null or _vigencia_ini = '' then
		let _vigencia_ini = _vigencia_fin - 1 units year;
	end if
	
	foreach
		select no_recibo
		  into v_no_recibo
		  from temp_produccion
		 where cod_ramo = v_cod_ramo
		   and no_poliza = v_nopoliza
		   and seleccionado = 1
		 order by 1 desc
		exit foreach;
	end foreach

	let _no_registro = null;

	{foreach
		select no_registro
		  into _no_registro
		  from sac999:reacomp
		 where no_poliza = v_nopoliza
		 order by no_endoso desc
		exit foreach;
	end foreach

	if _no_registro is not null then
		let _cnt = 0;

		select count(*)
		  into _cnt
		  from sac999:reacompasie
		 where no_registro = _no_registro;

		if _cnt > 0 then

		   foreach
				select sac_notrx
				  into _sac_notrx
				  from sac999:reacompasie
				 where no_registro = _no_registro
				  exit foreach;
		   end foreach

		   if _sac_notrx is not null then
			  foreach

			   select res_comprobante
				 into _res_comprobante
				 from cglresumen
				where res_notrx = _sac_notrx

			   exit foreach;
			  end foreach
		   end if
		else
		   let _res_comprobante = '';
		end if
	end if}

	let v_prima_tipo  = 0;
	let v_prima2    = 0;	

	foreach					 -- se desglosa por tipo, buscar primero si es bouquet
		select cod_contrato,
			   cod_cobertura,
			   tipo,
			   cod_coasegur,
			   serie,
			   sum(prima),
			   sum(cob_otros)
		  into v_cod_contrato,
		       v_cobertura,
			   _tipo_cont,
			   _cod_coasegur,
			   _serie,
			   v_prima_tipo,
			   v_prima2
		  from temp_produccion
		 where cod_ramo  = v_cod_ramo
		   and no_poliza = v_nopoliza 
		   and seleccionado = 1
		 group by cod_contrato,cod_cobertura,tipo,cod_coasegur,serie 
		 order by cod_contrato,cod_cobertura,tipo,cod_coasegur,serie  

		let _flag = 0;
		let _cnt  = 0;

		let _cont_cob_otros = 0;
		let _sum_fac_car  = 0;
		let v_prima_bq    = 0;
		let v_prima_ot    = 0;
		let _ret_casco    = 0;
		let _cob_otros    = 0;
		let _cont_casco   = 0;
		let v_prima_1     = 0;
		let v_prima_3     = 0;
		
		if v_prima_tipo is null then
			let v_prima_tipo = 0.00;
		end if
		
		if v_prima2 is null then
			let v_prima2 = 0.00;
		end if

		select bouquet
		  into _bouquet
		  from reacocob
		 where cod_contrato   = v_cod_contrato
		   and cod_cober_reas = v_cobertura;

		select facilidad_car
		  into _facilidad_car
		  from reacomae
		 where cod_contrato = v_cod_contrato;

		if _bouquet = 1 and _serie >= 2008 then -- and _cod_coasegur in ('050','063','076','042','036','089') then	   -- condiciones del borderaux bouquet	  '050','063','076','042'
			if _facilidad_car = 0 then
				if _cnt = 0 then
					let _flag = 1;
				end if
			 end if
		end if

		if _flag = 1 then
			if _facilidad_car = 1 then
				let _sum_fac_car = _sum_fac_car + v_prima_tipo + v_prima2;
			else
				--let v_prima_bq = v_prima_bq + v_prima_tipo + v_prima2;
				if v_cod_ramo in ('002','020','023') then
					if v_cobertura in ('025','002','033') then
						let v_prima_bq = v_prima_bq + v_prima_tipo;
						let _cont_cob_otros = _cont_cob_otros + v_prima2;
					else
						let _cont_casco = _cont_casco + v_prima_tipo;
					end if
				else
					let v_prima_bq = v_prima_bq + v_prima_tipo + v_prima2;
				end if
			end if
		else
			if _tipo_cont = 2 or _tipo_cont = 1 then
				if _tipo_cont = 1 then		--	retencion
					if v_cod_ramo in ('002','020','023') then
						if v_cobertura in ('025','002','033') then
							let v_prima_1 = v_prima_1 + v_prima_tipo;
							let _cob_otros = _cob_otros + v_prima2;
						else
							let _ret_casco = _ret_casco + v_prima_tipo;
						end if
					else
						let v_prima_1 = v_prima_1 + v_prima_tipo;
					end if
				end if
				
				if _tipo_cont = 2 then		--  facultativos
					let v_prima_3 = v_prima_3 + v_prima_tipo + v_prima2;
				end if				
			else
				if _facilidad_car = 1 then
					let _sum_fac_car = _sum_fac_car + v_prima_tipo;
				else
				   let v_prima_ot = v_prima_ot + v_prima_tipo +v_prima2 ;		
				end if
			end if
		end if

		let v_prima_tipo = 0;
		let v_prima2 = 0;
	--end foreach

		let _prima_total = v_prima_1 + _ret_casco + v_prima_ot + _sum_fac_car + v_prima_bq + v_prima_3 + _cob_otros + _cont_cob_otros + _cont_casco;
		select nombre
		  into v_desc_contrato
		  from reacomae
		 where cod_contrato = v_cod_contrato;

		foreach
			select cod_sub_tipo,
				   porcentaje
			  into v_cod_tipo,
				   v_porcentaje
			  from tmp_ramos
			 where cod_ramo = v_cod_ramo					

			select nombre
			  into v_desc_ramo
			  from prdramo
			 where cod_ramo = v_cod_ramo;

			if v_cod_tipo[1,2] = "IN" then
				let v_desc_ramo = Trim(v_desc_ramo)||"-INCENDIO";
				if v_cobertura in ('021','022') then
					continue foreach;
				end if
			elif v_cod_tipo[1,2] = "TE" then
				let v_desc_ramo = Trim(v_desc_ramo)||"-TERREMOTO";
				if v_cobertura in ('001','003') then
					continue foreach;
				end if
			end if

			begin
				on exception in(-239)
					update tmp_tabla
					   set cant_polizas   = cant_polizas   + 1,
						   p_cobrada      = p_cobrada      + _prima_total * v_porcentaje/100,
						   p_retenida     = p_retenida     + v_prima_1 * v_porcentaje/100,
						   p_bouquet      = p_bouquet      + v_prima_bq * v_porcentaje/100,
						   p_facultativo  = p_facultativo  + v_prima_3 * v_porcentaje/100,
						   p_otros		 = p_otros        + v_prima_ot * v_porcentaje/100,
						   p_fac_car = p_fac_car      + _sum_fac_car * v_porcentaje/100,
						   ret_casco      = ret_casco      + _ret_casco * v_porcentaje/100,
						   ret_otros      = ret_otros      + _cob_otros * v_porcentaje/100,
						   cont_otros      = cont_otros      + _cont_cob_otros * v_porcentaje/100,
						   cont_casco      = cont_casco      + _cont_casco * v_porcentaje/100
					 where no_documento = _no_documento
					   and cod_ramo = v_cod_tipo
					   and vigencia_ini = _vigencia_ini
					   and vigencia_fin = _vigencia_fin;
				end exception

				insert into tmp_tabla
						(no_documento,
						vigencia_ini,
						vigencia_fin,
						suma_asegurada,
						cod_ramo,							
						desc_ramo,							
						cant_polizas, 					
						p_cobrada,    					
						p_retenida,   					
						p_bouquet,    					
						p_facultativo,					
						p_otros,
						p_fac_car,
						no_recibo,
						res_comprobante,
						n_contrato,
						ret_casco,
						ret_otros,
						cont_otros,
						cont_casco)
				values(	_no_documento, 
						_vigencia_ini, 
						_vigencia_fin, 
						v_suma_asegurada, 
						v_cod_tipo, 
						v_desc_ramo, 
						1, 
						_prima_total * v_porcentaje/100, 
						v_prima_1 * v_porcentaje/100, 
						v_prima_bq * v_porcentaje/100, 
						v_prima_3 * v_porcentaje/100, 
						v_prima_ot * v_porcentaje/100, 
						_sum_fac_car * v_porcentaje/100, 
						v_no_recibo, 
						_res_comprobante, 
						v_desc_contrato,
						_ret_casco	* v_porcentaje/100,				 
						_cob_otros	* v_porcentaje/100,
						_cont_cob_otros * v_porcentaje/100,
						_cont_casco * v_porcentaje/100);				 
			end
		end foreach

		let _prima_total = 0.00;
	end foreach
	let v_prima   = 0;
	--commit work;
end foreach


foreach 
	select no_documento,
		   vigencia_ini,
		   vigencia_fin,
		   suma_asegurada,
		   cod_ramo,
		   desc_ramo,
		   cant_polizas,
		   p_cobrada,
		   p_retenida,
		   p_bouquet,
		   p_facultativo,
		   p_otros,
		   p_fac_car,
		   no_recibo,
		   res_comprobante,
		   n_contrato,
		   ret_casco,
		   ret_otros,
		   cont_otros,
		   cont_casco
	  into _no_documento,
		   _vigencia_ini,
		   _vigencia_fin,
		   v_suma_asegurada,
		   v_cod_ramo,
		   v_desc_ramo,
		   _cantidad,
		   v_prima,
		   v_prima_1,
		   v_prima_bq,
		   v_prima_3,
		   v_prima_ot,
		   _sum_fac_car,
		   v_no_recibo,
		   _res_comprobante,
		   v_desc_contrato,
		   _ret_casco,
		   _cob_otros,
		   _cont_cob_otros,
		   _cont_casco
	  from tmp_tabla 
	 order by cod_ramo
	
	let _no_poliza = sp_sis21(_no_documento);

	select cod_contratante,
		   fecha_suscripcion,
		   cod_subramo
	  into _cod_contratante,
		   _fecha_suscripcion,
		   v_cod_subramo
	  from emipomae
	 where no_poliza = _no_poliza;

	select first 1 cod_manzana
	  into _cod_manzana
	  from emipouni
	 where no_poliza = _no_poliza;

	select nombre,
		   trim(cedula)
	  into _n_aseg,
		   v_cedula
	  from cliclien
	 where cod_cliente = _cod_contratante;

	select trim(nombre)
	  into v_name_subramo
	  from prdsubra
	 where cod_ramo    = v_cod_ramo
	   and cod_subramo = v_cod_subramo ;
	   
	if v_prima = 0 and v_prima_1 = 0 and _cob_otros = 0 and _ret_casco = 0 and v_prima_bq = 0 and v_prima_ot = 0 then
		continue foreach;
	end if	
	return	_no_documento,
			_vigencia_ini,
			_vigencia_fin,
			v_suma_asegurada,
			v_cod_ramo,  
			v_desc_ramo,   
			_cantidad,  
			v_prima,  
			v_prima_1,  
			v_prima_bq,  
			v_prima_3,  
			v_prima_ot, 
			v_filtros, 
			v_descr_cia,
			_sum_fac_car,
			v_no_recibo,
			_res_comprobante,
			v_desc_contrato,
			_n_aseg,
			_fecha_suscripcion,
			v_cedula,		
			v_name_subramo,
			_ret_casco,
			_cod_manzana,
			_cob_otros,
			_cont_cob_otros,
			_cont_casco with resume;
end foreach

drop table temp_produccion;
drop table temp_det;
drop table tmp_tabla;
drop table tmp_ramos;

end
end procedure;