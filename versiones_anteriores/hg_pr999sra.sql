--------------------------------------------
--      TOTALES DE PRODUCCION POR         --
--         CONTRATO DE REASEGURO          --
---  Yinia M. Zamora - octubre 2000       -- YMZM
---  Ref. Power Builder - reemplaza sp_pro308
--- Modificado por Armando Moreno 19/01/2002; la parte de los tipo de contratos
--- Modificado por Henry 10/9/2009 filtros requeridos por Sr. Omar Wong
--- Quitar el filtro de rangos.
--------------------------------------------
--execute procedure sp_pr999sra('001','001','2013-07','2013-09',"*","*","*","*","002;","*","*","2013;","*")

drop procedure sp_pr999sra;
create procedure sp_pr999sra(
a_compania		char(03),
a_agencia		char(03),
a_periodo1		char(07),
a_periodo2		char(07),
a_codsucursal	char(255) default "*",
a_codgrupo		char(255) default "*",
a_codagente		char(255) default "*",
a_codusuario	char(255) default "*",
a_codramo		char(255) default "*",
a_reaseguro		char(255) default "*",
a_contrato		char(255) default "*",
a_serie			char(255) default "*",
a_subramo		char(255) default "*")
returning	char(3),
			char(50),
			integer,
			dec(16,2),
			dec(16,2),
			dec(16,2),
			dec(16,2),
			dec(16,2),
			char(255),
			char(50),
			dec(16,2),
			dec(16,2),
			dec(16,2);

begin
define _error_desc			char(255);
define v_filtros2			char(255);
define v_filtros1			char(255);
define v_filtros			char(255);
define v_desc_cobertura		char(100);
define v_desc_contrato		char(50);
define _nombre_coas			char(50);
define _nombre_cob			char(50);
define _nombre_con			char(50);
define v_descr_cia			char(50);
define v_desc_ramo			char(50);
define _cuenta				char(25);
define _no_doc				char(20);
define _no_remesa			char(10);
define v_nopoliza			char(10);
define _periodo1			char(7);
define v_cod_contrato		char(5);
define _cod_traspaso		char(5);
define _no_unidad			char(5);
define v_noendoso			char(5);
define _cod_coasegur		char(3);
define _cod_subramo			char(3);
define v_cobertura2			char(3);
define _cod_origen			char(3);
define v_cobertura			char(3);
define v_cod_ramo			char(3);
define v_cod_tipo			char(3);
define _t_ramo				char(1);
define _tipo				char(1);
define _porc_cont_partic	dec(5,2);
define _porc_proporcion		dec(5,2);
define _porc_comis_ase		dec(5,2);
define _porc_partic_coas	dec(7,4);
define _porc_partic_prima	dec(9,6);
define _prima_tot_ret_sum	dec(16,2);
define _prima_tot_sus_sum	dec(16,2);
define v_suma_asegurada		dec(16,2);
define v_prima_suscrita		dec(16,2);
define v_rango_inicial		dec(16,2);
define v_prima_cobrada		dec(16,2);
define _porc_impuesto		dec(16,2);
define _prima_tot_ret		dec(16,2);
define _prima_sus_tot		dec(16,2);
define _porc_comision		dec(16,2);
define _p_sus_tot_sum		dec(16,2);
define _prima_net_cob		dec(16,2);
define v_prima_casco		dec(16,2);
define _prima_total			dec(16,2);
define v_prima_tipo			dec(16,2);
define _sum_fac_car			dec(16,2);
define _monto_reas			dec(16,2);
define _cob_otros			dec(16,2);
define _por_pagar			dec(16,2);
define v_prima_ot			dec(16,2);
define _p_sus_tot			dec(16,2);
define v_prima_bq			dec(16,2);
define _impuesto			dec(16,2);
define _comision			dec(16,2);
define v_prima_1			dec(16,2);
define v_prima_3			dec(16,2);
define v_prima2				dec(16,2);
define v_prima1				dec(16,2);
define v_prima				dec(16,2);
define _ret_casco			dec(16,2);
define v_rango_final		dec(16,2);
define _tiene_comis_rea		integer;
define v_tipo_contrato		integer;
define _facilidad_car		integer;
define v_porcentaje			integer;
define _no_cambio			integer;
define _tipo_cont			integer;
define _traspaso			integer;
define _cantidad			integer;
define _bouquet				integer;
define _serie				integer;
define _error				integer;
define _flag				integer;
define _cnt					integer;
define _valor				integer;
define _renglon				integer;
define _fecha				date;

set isolation to dirty read;

let v_descr_cia  = sp_sis01(a_compania);
let _valor = 0;
let _periodo1 = a_periodo1;

drop table if exists temp_devpri;
drop table if exists temp_produccion;
drop table if exists temp_det;
drop table if exists tmp_tabla;
drop table if exists tmp_ramos;

if a_periodo2 >= '2013-07' then		--Proceso de Devolución de Prima
	if _periodo1 <= '2013-09' then
		let _periodo1 = '2008-01';
	end if
	
	-- Cargar los valores de devolucion de primas	  Crea tabla temp_det  (temporal)
	call sp_pr860e1(a_compania,a_agencia,_periodo1,a_periodo2,a_codsucursal,a_codgrupo,a_codagente,a_codusuario,
					a_codramo,a_reaseguro,a_contrato,a_serie,a_subramo)
	returning _error,_error_desc;
	
	if _error = 1 then
		drop table temp_produccion;
		return	"",
				"",
				0,
				0.00,
				0.00,
				0.00,
				0.00,
				0.00,
				"No Existe Distribucion de Reaseguro",
				'',
				0.00,
				0.00,
				0.00;
	end if

	create temp table temp_devpri(
	cod_ramo         char(3),
	cod_subramo		 char(3),
	cod_origen		 char(3),
	cod_contrato     char(5),
	desc_contrato    char(50),
	cod_cobertura    char(3),
	prima            dec(16,2),
	tipo             smallint default 0,
	comision         dec(16,2),
	impuesto         dec(16,2),
	por_pagar        dec(16,2),
	desc_cob         char(100),
	serie 			 smallint,
	seleccionado     smallint default 1,
	no_poliza		 char(10),
	cod_coasegur 	 char(3),
	no_recibo        char(10),
	primary key(cod_ramo, cod_subramo, cod_origen, cod_contrato, cod_cobertura, desc_cob, no_poliza)) with no log;

	create index idx1_temp_devpri on temp_devpri(cod_ramo);
	create index idx2_temp_devpri on temp_devpri(cod_subramo);
	create index idx3_temp_devpri on temp_devpri(cod_origen);
	create index idx4_temp_devpri on temp_devpri(cod_contrato);
	create index idx5_temp_devpri on temp_devpri(cod_cobertura);
	create index idx6_temp_devpri on temp_devpri(desc_cob);
	create index idx7_temp_devpri on temp_devpri(no_poliza);
	create index idx8_temp_devpri on temp_devpri(serie);
	create index idx9_temp_devpri on temp_devpri(cod_coasegur);

	insert into temp_devpri
	select * from temp_produccion;

	drop table temp_produccion;
end if

call sp_pro307(	a_compania,a_agencia,a_periodo1,a_periodo2,a_codsucursal,a_codgrupo,
				a_codagente,a_codusuario,a_codramo,a_reaseguro) returning v_filtros;

create temp table tmp_ramos(
cod_ramo		char(3),
cod_sub_tipo	char(3),
porcentaje		smallint default 100,
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
primary key(cod_ramo, cod_subramo, cod_origen, cod_contrato, cod_cobertura, desc_cob, no_poliza)) with no log;

create index idx1_temp_produccion on temp_produccion(cod_ramo);
create index idx2_temp_produccion on temp_produccion(cod_subramo);
create index idx3_temp_produccion on temp_produccion(cod_origen);
create index idx4_temp_produccion on temp_produccion(cod_contrato);
create index idx5_temp_produccion on temp_produccion(cod_cobertura);
create index idx6_temp_produccion on temp_produccion(desc_cob);
create index idx7_temp_produccion on temp_produccion(no_poliza);
create index idx8_temp_produccion on temp_produccion(serie);
create index idx9_temp_produccion on temp_produccion(cod_coasegur);

create temp table tmp_tabla(
cod_ramo		char(3),
desc_ramo		char(50),
cant_polizas	integer,
p_cobrada		dec(16,2),
p_retenida		dec(16,2),
p_bouquet		dec(16,2),
p_facultativo	dec(16,2),
p_otros			dec(16,2),
p_fac_car		dec(16,2),
p_ret_casco		dec(16,2),
p_ret_otros		dec(16,2),
primary key (cod_ramo)) with no log;

let _cod_subramo = "001";
let v_filtros1 = "";
let v_filtros2 = "";
let _porc_comis_ase	= 0;
let _prima_tot_ret = 0;
let _prima_sus_tot = 0;
let _p_sus_tot_sum = 0;
let _sum_fac_car = 0;
let _ret_casco = 0;
let _p_sus_tot = 0;
let _tipo_cont = 0;
let v_prima = 0;
let _cnt = 0;

if a_subramo <> "*" then
	let v_filtros2 = trim(v_filtros2) ||" Sub Ramo "||trim(a_subramo);
	Let _tipo = sp_sis04(a_subramo); -- separa los valores del string

	if _tipo <> "E" THEN -- Incluir los Registros
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
		   no_endoso,
		   prima_neta,	   -- sum(z.prima_neta),
		   vigencia_inic,	   -- min(z.vigencia_inic)
		   no_documento,
		   no_remesa,
		   renglon
	  into v_nopoliza,
		   v_noendoso,
		   v_prima_cobrada,
		   _fecha,
		   _no_doc,
		   _no_remesa,
		   _renglon
	  from temp_det
	 where seleccionado = 1
	  -- and no_poliza = '0001906143'
	   --and no_documento = '0215-00691-01'

	--begin work;

	select count(*)
	  into _cnt
	  from reaexpol
	 where no_documento = _no_doc
	   and activo       = 1;

	if _cnt = 1 then                         --"0110-00406-01" or _no_doc = "0110-00407-01" or _no_doc = "0109-00700-01" then --Estas polizas del Bco Hipotecario no las toman en cuenta.
		continue foreach;
	end if

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
	let _prima_net_cob = 0.00;
	
	if v_cod_ramo in ('002','023') then

		select sum(prima_neta)
		  into _prima_net_cob
		  from emipocob
		 where no_poliza = v_nopoliza;
		   --and c.cod_cober_reas = '002';
		   
		if _prima_net_cob is null then
			let _prima_net_cob = 0;
		end if
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

		{select cod_contrato,
			   porc_partic_prima,
			   porc_proporcion,
			   cod_cober_reas
		  into v_cod_contrato,
			   _porc_partic_prima,
			   _porc_proporcion,
			   v_cobertura
		  from cobreaco
		 where no_remesa = _no_remesa
		   and renglon   = _renglon}

		let v_prima_casco = 0.00;
		let v_prima2 = 0.00;

		if v_cobertura in ('002','033') then
			if _prima_net_cob = 0 then
				let v_prima_casco = 0.00;
				let v_prima2 = 0.00;
			else
				select sum(c.prima_neta) * (_porc_partic_coas/100) 
				  into v_prima2
				  from emipocob c, prdcober p
				 where c.cod_cobertura = p.cod_cobertura
				   and no_poliza = v_nopoliza
				   and p.cod_cober_reas = v_cobertura
				   and c.cod_cobertura not in ('00102','00107','00113','00117','01299','01302','01304','01305');

				if v_prima2 is null then
					let v_prima2 = 0.00;
					
					select sum(c.prima_neta) * (_porc_partic_coas/100) 
					  into v_prima2
					  from emipocob c, prdcober p
					 where c.cod_cobertura = p.cod_cobertura
					   and no_poliza = v_nopoliza
					   and p.cod_cober_reas = '033'
					   and c.cod_cobertura not in ('00102','00107','00113','00117','01299','01302','01304','01305');
					   
					if v_prima2 is null then
						let v_prima2 = 0.00;
					end if
				end if

				let v_prima2 = v_prima_cobrada * (v_prima2 / _prima_net_cob);
			end if
		end if

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

		if v_tipo_contrato = 3 then	 --facult.
			let _tipo_cont = 2;
		elif v_tipo_contrato = 1 then --retencion
			let _tipo_cont = 1;
		end if

		let v_prima1 = v_prima_cobrada * (_porc_partic_prima / 100) * (_porc_proporcion / 100);		
		let v_prima1 = v_prima1 - v_prima2;
		--let v_prima2 = v_prima2 * (_porc_partic_prima / 100) * (_porc_proporcion / 100);
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
							'*',
							v_prima2);
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
						values( v_cod_ramo,
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
								'*',
								v_prima2);
					else					   
						update temp_produccion
						   set prima = prima + _monto_reas,
							   comision = comision + _comision,
							   impuesto = impuesto + _impuesto,
							   por_pagar = por_pagar + _por_pagar,
							   cob_otros = cob_otros + v_prima2
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

			let v_desc_cobertura = "";
			let v_desc_cobertura = trim(_nombre_cob) || "  " || trim(_cuenta) || "  " || trim(_nombre_coas);
			let v_desc_contrato  = trim(v_desc_contrato) || "  I:" || _porc_impuesto || "  C:" || _porc_comision;

			let _porc_impuesto = 0;
			let _porc_comision = 0;
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
						_cod_coasegur,
						'*',
						v_prima2);
			else			   
				update temp_produccion
				   set prima         = prima     + _monto_reas,
					   comision      = comision  + _comision,
					   impuesto      = impuesto  + _impuesto,
					   por_pagar     = por_pagar + _por_pagar,
					   cob_otros = cob_otros + v_prima2
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
			 where no_poliza      = v_nopoliza
			   and no_endoso      = v_noendoso
			   and cod_contrato   = v_cod_contrato
			   and cod_cober_reas = v_cobertura;
			 --and no_unidad      = _no_unidad;

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
							0,
							_tipo_cont,
							0, 
							0, 
							0,
							_nombre_cob,
							_serie,
							1,
							v_nopoliza,
							'999',
							'*',
							v_prima2);
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
								_cod_coasegur,
								'*',
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
						   and no_poliza     = v_nopoliza;
					end if
				end foreach
			end if
		end if
	end foreach
	
	--commit work;
end foreach

let _prima_tot_ret_sum = 0;
let _prima_tot_sus_sum = 0;
let _p_sus_tot_sum     = 0;

--begin work;
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
			   _serie,
			   v_nopoliza,
			   _cod_coasegur
		  from temp_devpri
		 where seleccionado = 1

		let _monto_reas = _monto_reas * -1;
		let _comision = _comision * -1;
		let _impuesto = _impuesto * -1;
		let _por_pagar = _por_pagar * -1;
		let v_prima2 = 0;

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
					_cod_coasegur,
					'*',
					v_prima2);
		else
			update temp_produccion
			   set prima		= prima     + _monto_reas,
				   comision		= comision  + _comision,
				   impuesto		= impuesto  + _impuesto,
				   por_pagar	= por_pagar + _por_pagar,
				   cob_otros = cob_otros + v_prima2
			 where cod_ramo  		= v_cod_ramo
			   and cod_subramo		= _cod_subramo
			   and cod_origen		= _cod_origen
			   and cod_contrato		= v_cod_contrato
			   and cod_cobertura	= v_cobertura
			   and desc_cob			= v_desc_cobertura
			   and no_poliza		= v_nopoliza;
		end if
	end foreach
end if

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
			values (v_cod_ramo,v_cod_tipo,100);
			--values (v_cod_ramo,v_cod_tipo,70);

			let v_cod_tipo = "TE"||_t_ramo;

			insert into tmp_ramos (cod_ramo,cod_sub_tipo,porcentaje)
			values (v_cod_ramo,v_cod_tipo,100);
			--values (v_cod_ramo,v_cod_tipo,30);
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

	let v_prima_tipo  = 0;
	let v_prima2  = 0;
	{let _cob_otros    = 0;
	let v_prima_1     = 0;
	let v_prima_3     = 0;
	let v_prima_bq    = 0;
	let v_prima_ot    = 0;
	let _sum_fac_car  = 0;
	let _ret_casco    = 0;}

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
		 where cod_ramo     = v_cod_ramo
		   and no_poliza    = v_nopoliza 
		   and seleccionado = 1
		 group by cod_contrato,cod_cobertura,tipo,cod_coasegur,serie 
		 order by cod_contrato,cod_cobertura,tipo,cod_coasegur,serie  

		let _flag = 0;
		let _cnt  = 0;

		if v_prima_tipo is null then
			let v_prima_tipo = 0.00;
		end if

		if v_prima2 is null then
			let v_prima2 = 0.00;
		end if
		
		let _cob_otros    = 0;
		let v_prima_1     = 0;
		let v_prima_3     = 0;
		let v_prima_bq    = 0;
		let v_prima_ot    = 0;
		let _sum_fac_car  = 0;
		let _ret_casco    = 0;

		select bouquet
		  into _bouquet
		  from reacocob
		 where cod_contrato   = v_cod_contrato
		   and cod_cober_reas = v_cobertura;

		let _facilidad_car = 0;

		select facilidad_car
		  into _facilidad_car
		  from reacomae
		 where cod_contrato = v_cod_contrato;

		if _bouquet = 1 and _serie >= 2008 then --and _cod_coasegur in ('050','063','076','042','036','089') then	   -- condiciones del borderaux bouquet	  '050','063','076','042'

			if _facilidad_car = 0 then
				let _cnt = 0;
			end if
			if _cnt = 0 then
				 let _flag = 1;
			end if
		end if

		if _flag = 1 then
			if _facilidad_car = 1 then
				let _sum_fac_car = _sum_fac_car + v_prima_tipo;
			else
				let v_prima_bq = v_prima_bq + v_prima_tipo + v_prima2;
			end if
		else
			if _tipo_cont = 2 or _tipo_cont = 1 then
				if _tipo_cont = 1 then		--	retencion
					if v_cod_ramo in ('002','023') then
						if v_cobertura in ('002','033') then
							let v_prima_1 = v_prima_1 + v_prima_tipo;
							let _cob_otros = _cob_otros + v_prima2;
						else
							let _ret_casco = _ret_casco + v_prima_tipo;
						end if
					else
						let v_prima_1 = v_prima_1 + v_prima_tipo;
					end if
				elif _tipo_cont = 2 then		--  facultativos
					let v_prima_3 = v_prima_3 + v_prima_tipo + v_prima2;					   
				end if
			else
				if _facilidad_car = 1 then
					let _sum_fac_car = _sum_fac_car + v_prima_tipo;
				else
					let v_prima_ot = v_prima_ot + v_prima_tipo + v_prima2;		
				end if	
			end if
		end if
		let v_prima_tipo = 0;
		let v_prima2 = 0;
	--end foreach
		let _prima_total = v_prima_1 + v_prima_bq + v_prima_3 + v_prima_ot + _sum_fac_car + _ret_casco + _cob_otros;
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

			{if v_cod_ramo = '003' and _serie >= 2015 then
				if v_cod_tipo[1,2] = "IN" then
					let v_porcentaje = 90;
				elif v_cod_tipo[1,2] = "TE" then
					let v_porcentaje = 10;
				end if
			end if}

			if v_cod_tipo[1,2] = "IN" then
				if v_cobertura in ('021','022') then
					continue foreach;
				end if
				
				let v_desc_ramo = trim(v_desc_ramo)||"-INCENDIO";
			elif v_cod_tipo[1,2] = "TE" then
				if v_cobertura in ('001','003') then
					continue foreach;
				end if
				
				let v_desc_ramo = Trim(v_desc_ramo)||"-TERREMOTO";
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
						  p_fac_car		 = p_fac_car      + _sum_fac_car * v_porcentaje/100,
						  p_ret_casco    = p_ret_casco    + _ret_casco * v_porcentaje/100,
						  p_ret_otros = p_ret_otros + _cob_otros * v_porcentaje/100
					where cod_ramo       = v_cod_tipo;
				end exception

				insert into tmp_tabla(
						cod_ramo,							
						desc_ramo,							
						cant_polizas, 					
						p_cobrada,    					
						p_retenida,   					
						p_bouquet,    					
						p_facultativo,					
						p_otros,
						p_fac_car,
						p_ret_casco,
						p_ret_otros)
				values(	v_cod_tipo, 
						v_desc_ramo, 
						1, 
						_prima_total * v_porcentaje/100,
						v_prima_1    * v_porcentaje/100,
						v_prima_bq   * v_porcentaje/100,
						v_prima_3    * v_porcentaje/100,
						v_prima_ot   * v_porcentaje/100,
						_sum_fac_car * v_porcentaje/100,
						_ret_casco   * v_porcentaje/100,
						_cob_otros   * v_porcentaje/100);
			end
		end foreach

		let _prima_total   = 0;
	end foreach

	let v_prima   = 0;
	--commit work;
end foreach

--begin work;
foreach
	select cod_ramo,
		   desc_ramo,
		   cant_polizas,
		   p_cobrada,
		   p_retenida,
		   p_bouquet,
		   p_facultativo,
		   p_otros,
		   p_fac_car,
		   p_ret_casco,
		   p_ret_otros
	  into v_cod_ramo,
		   v_desc_ramo,
		   _cantidad,
		   v_prima,
		   v_prima_1,
		   v_prima_bq,
		   v_prima_3,
		   v_prima_ot,
		   _sum_fac_car,
		   _ret_casco,
		   _cob_otros
	  from tmp_tabla 
	 order by cod_ramo

	return	v_cod_ramo,  
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
			_ret_casco,
			_cob_otros with resume;
end foreach

drop table if exists temp_devpri;
drop table if exists temp_produccion;
drop table if exists temp_det;
drop table if exists tmp_tabla;
drop table if exists tmp_ramos;

--commit work;
end
end procedure 