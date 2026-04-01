
--execute procedure sp_pr860_t_am('001','001','2023-01','2023-01',"*","*","*","*","008;","*","2024,2023,2022,2021,2020,2019,2018,2017,2016,2015,2014,2013,2012,2011,2010,2009,2008;",'09')
drop procedure sp_pr860_t_am;
create procedure sp_pr860_t_am(a_compania char(03),a_agencia char(03),a_periodo1 char(07),a_periodo2 char(07),a_codsucursal char(255)	default "*",a_codgrupo char(255) default "*",
							a_codagente	char(255)	default "*",a_codusuario char(255)	default "*",a_codramo char(255)	default "*",a_reaseguro	char(255)	default "*",
						    a_serie	char(255)	default "*",a_tipo_bx char(2) default "01",a_contrato char(255)   default '*')
returning char(10),smallint,char(10),dec(16,2),dec(16,2);

begin
define _nom_contrato		varchar(100);
define _error_desc			char(255);
define v_filtros2			char(255);
define v_filtros			char(255);
define v_desc_cobertura		char(100);
define v_desc_contrato,_nombre_coas,v_desc_ramo,v_descr_cia		char(50);
define _nombre_cob,_nombre_con			char(50);
define _cuenta				char(25);
define _no_documento		char(20);
define _no_reclamo			char(10);
define v_nopoliza			char(10);
define _no_remesa			char(10);
define _anio_reas			char(9);
define _periodo1			char(8);
define v_cod_contrato		char(5);
define _cod_contrato		char(5);
define _cod_traspaso		char(5);
define _no_unidad			char(5);
define v_noendoso			char(5);
define _cod_c				char(5);
define _cod_coasegur,_cod_subramo,v_cobertura ,_cod_origen   char(3);
define v_cod_ramo,_cod_ramo,_xnivel,v_clase			char(3);
define _borderaux			char(2);
define _tipo				char(1);
define _porc_cont_partic,_porc_proporcion,_porc_cont_terr,_porc_comis_ase,_p_c_partic	dec(5,2);
define _porc_partic_coas,_porc_partic_coas_ancon,_porc_impuesto4,_porc_comisiond,_porc_comision4	dec(7,4);
define _porc_partic_prima	dec(9,6);
define _prima_tot_ret_sum	dec(16,2);
define _prima_tot_sus_sum	dec(16,2);
define v_prima_suscrita		dec(16,2);
define _prima_devuelta		dec(16,2);
define v_prima_cobrada		dec(16,2);
define _tot_prima_neta		dec(16,2);
define _prima_sus_tot		dec(16,2);
define _prima_tot_ret		dec(16,2);
define _p_sus_tot_sum		dec(16,2);
define _porc_impuesto		dec(16,2);
define _porc_comision		dec(16,2);
define _tot_comision		dec(16,2);
define _tot_impuesto		dec(16,2);
define _por_pagar70			dec(16,2);
define _por_pagar30			dec(16,2);
define _siniestro70			dec(16,2);
define _siniestro30			dec(16,2);
define _por_pagar10			dec(16,2);
define _pagado_neto			dec(16,2);
define _siniestro4			dec(16,2);
define _comision70			dec(16,2);
define _comision30			dec(16,2);
define _impuesto70			dec(16,2);
define _impuesto30			dec(16,2);
define _impuesto10			dec(16,2);
define _comision10			dec(16,2);
define _siniestro2			dec(16,2);
define _siniestro3			dec(16,2);
define _p_sus_tot			dec(16,2);
define _porc_inun			dec(16,2);
define _porc_terr			dec(16,2);
define _porc_inc			dec(16,2);
define v_prima70			dec(16,2);
define v_prima30			dec(16,2);
define v_prima10			dec(16,2);
define _sini_dif			dec(16,2);
define _sini_inc			dec(16,2);
define _sini_mul			dec(16,2);
define _sini_bk				dec(16,2);
define v_prima				dec(16,2);
define v_prima1				dec(16,2);
define _impuesto			dec(16,2);
define _comision			dec(16,2);
define _por_pagar			dec(16,2);
define _siniestro			dec(16,2);
define _monto_reas,_db,_cr			dec(16,2);
define _tiene_comis_rea		smallint;
define v_tipo_contrato		smallint;
define _tiene_comision		smallint;
define _p_c_partic_hay		smallint;
define _facilidad_car		smallint;
define _contrato_xl			smallint;
define _relac_inund			smallint;
define _no_cambio			smallint;
define _tipo_cont			smallint;
define _trim_reas			smallint;
define _traspaso			smallint;
define _cantidad			smallint;
define v_existe				smallint;
define _bouquet				smallint;
define _serie1				smallint;
define _serie				smallint;
define _nivel				smallint;
define _ano2				smallint;
define nivel				smallint;
define _flag				smallint;
define _cnt3				smallint;
define _cnt2				smallint;
define _cnt					smallint;
define _tipo2				smallint;
define _ano					smallint;
define _renglon				integer;
define _error				integer;
define _no_reg              char(10);
define _vigencia_inic,_dt_vig_inic,_fecha		date;

set isolation to dirty read;

drop table if exists temp_produccion;
drop table if exists temp_det;
drop table if exists tmp_priret;
drop table if exists tmp_sinis;
drop table if exists temp_inundacion;
drop table if exists temp_devpri;
drop table if exists tmp_codigos;

let _borderaux = a_tipo_bx;   -- bouquet,cuota parte acc pers, vida, facilidad car
let _periodo1 = a_periodo1;

select tipo
  into _tipo2
  from reacontr
 where cod_contrato = _borderaux;

call sp_rea002(a_periodo2,_tipo2) returning _anio_reas,_trim_reas;

let _contrato_xl = 0;
let _porc_proporcion = 0;

if _borderaux = '01' then	--es bouquet y facilidad car
	delete from reacoest
	 where anio = _anio_reas
	   and trimestre = _trim_reas
	   and borderaux = _borderaux;  -- Elimina borderaux del trimestre

	delete from temphg
	 where anio = _anio_reas
	   and trimestre = _trim_reas
	   and borderaux = _borderaux;  -- Elimina borderaux datos

	if a_codramo = '*' then
		let a_codramo = "001,003,006,008,010,011,012,013,014,021,022;";
	end if
else
	delete from reacoest
	 where anio = _anio_reas
	   and trimestre = _trim_reas
	   and borderaux = _borderaux;  -- elimina borderaux del trimestre

	delete from temphg
	 where anio = _anio_reas
	   and trimestre = _trim_reas
	   and borderaux = _borderaux;  -- elimina borderaux datos

	if _borderaux = '06' then
		if a_codramo = '*' then
			let a_codramo = "014;";
		end if
	elif _borderaux = '08' then
		if a_codramo = '*' then
			let a_codramo = "004,016,019;";
		end if
	elif _borderaux = '09' then
		if a_codramo = '*' then
			let a_codramo = "008;";
		end if
	elif _borderaux = '10' then
		if a_codramo = '*' then
			let a_codramo = "002,023,020;";
		end if
	end if
end if

let _ano        = a_periodo1[1,4];
let v_descr_cia = sp_sis01(a_compania);

if a_periodo2 >= '2013-07' then

	if _periodo1 <= '2013-09' then
		let _periodo1 = '2008-01';
	end if
	-- Cargar los valores de devolucion de primas	  Crea tabla temp_det  (temporal)
	call sp_pr860c1(a_compania,a_agencia,_periodo1,a_periodo2,a_codsucursal,a_codgrupo,a_codagente,a_codusuario,
					a_codramo,a_reaseguro,a_serie,_borderaux)
	returning _error,_error_desc;

	if _error = 1 then
		drop table temp_produccion;
		return "",0,"",0,0;
	end if

	select *
	  from temp_produccion
	  into temp temp_devpri;
	drop table temp_produccion;
end if

-- Carga lo cobrado desde cobredet
call sp_pro307(a_compania,a_agencia,a_periodo1,a_periodo2,a_codsucursal,a_codgrupo,   --crea tabla temp_det (temporal)
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
cod_ramo			char(3),
cod_subramo			char(3),
cod_origen			char(3),
cod_contrato		char(5),
desc_contrato		char(50),
cod_cobertura		char(3),
prima				dec(16,2),
tipo				smallint default 0,
comision			dec(16,2),
impuesto			dec(16,2),
por_pagar			dec(16,2),
desc_cob			char(100),
porc_comision		dec(16,2),
porc_impuesto		dec(16,2),
porc_cont_partic	dec(16,2),
cod_coasegur		char(3),
tiene_comision		smallint,
serie				smallint,
seleccionado		smallint default 1,
no_remesa           char(10),
renglon             smallint) with no log;
--primary key(cod_ramo, cod_subramo, cod_origen, cod_contrato, cod_cobertura, desc_cob, serie)) with no log;

create index idx1_temp_produccion on temp_produccion(cod_ramo);
create index idx2_temp_produccion on temp_produccion(cod_subramo);
create index idx3_temp_produccion on temp_produccion(cod_origen);
create index idx4_temp_produccion on temp_produccion(cod_contrato);
create index idx5_temp_produccion on temp_produccion(cod_cobertura);
create index idx6_temp_produccion on temp_produccion(desc_cob);
create index idx7_temp_produccion on temp_produccion(cod_coasegur);
create index idx8_temp_produccion on temp_produccion(serie);

create temp table tmp_priret(
cod_ramo		char(3),
prima_sus_tot	dec(16,2),
prima			dec(16,2),
prima_sus_t		dec(16,2)) with no log;

create temp table temp_inundacion(
serie				smallint,
cod_ramo			char(3),
siniestros_pagados	dec(16,2),
relac_inundacion	smallint,
primary key(serie,cod_ramo,relac_inundacion)) with no log;

--set debug file to "sp_pr860.trc";
--trace on;


let _cod_subramo = "001";
let _porc_comis_ase = 0;
let _prima_tot_ret = 0;
let _prima_sus_tot = 0;
let _p_sus_tot_sum = 0;
let _por_pagar10 = 0;
let _comision10 = 0;
let _impuesto10 = 0;
let _p_sus_tot = 0;
let _tipo_cont = 0;
let v_prima10 = 0;
let v_prima = 0;

foreach --Primas cobradas
	select no_poliza,
		   no_endoso,
		   prima_neta,
		   vigencia_inic,
		   no_remesa,
		   renglon
	  into v_nopoliza,
		   v_noendoso,
		   v_prima_cobrada,
		   _fecha,
		   _no_remesa,
		   _renglon
	  from temp_det
	 where seleccionado = 1
	 --and no_remesa = '1994499'
	 --and renglon = 72

	let _prima_devuelta = 0.00;
	let _porc_partic_coas_ancon = 0.00;	

	select cod_ramo,
		   cod_origen,
		   no_documento,
		   vigencia_inic
	  into v_cod_ramo,
		   _cod_origen,
		   _no_documento,
		   _vigencia_inic
	  from emipomae
	 where no_poliza = v_nopoliza;

	let v_nopoliza    = v_nopoliza;
	let _no_documento = _no_documento;

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
		
		select traspaso,
			   tiene_comision
		  into _traspaso,
			   _tiene_comision
		  from reacocob
		 where cod_contrato = v_cod_contrato
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
				 where cod_ramo = v_cod_ramo
				   and cod_subramo = _cod_subramo
				   and cod_origen = _cod_origen
				   and cod_contrato = v_cod_contrato
				   and cod_cobertura = v_cobertura
				   and desc_cob = _nombre_cob
				   and serie = _serie;

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
							0,
							0,
							0,
							'999',
							_tiene_comis_rea,
							_serie,1,"",0);
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

					let _cantidad = 0;

					{select count(*)
					  into _cantidad
					  from temp_produccion
					 where cod_ramo      = v_cod_ramo
					   and cod_subramo   = _cod_subramo
					   and cod_origen    = _cod_origen
					   and cod_contrato  = v_cod_contrato
					   and cod_cobertura = v_cobertura
					   and desc_cob      = v_desc_cobertura
					   and serie         = _serie;

					if _cantidad = 0 then}
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
								_porc_comision,
								_porc_impuesto,
								_porc_cont_partic,
								_cod_coasegur,
								_tiene_comis_rea,
								_serie,1,_no_remesa,_renglon);
					--else
						{update temp_produccion
						   set prima         = prima     + _monto_reas,
							   comision      = comision  + _comision,
							   impuesto      = impuesto  + _impuesto,
							   por_pagar     = por_pagar + _por_pagar
						 where cod_ramo      = v_cod_ramo
						   and cod_subramo   = _cod_subramo
						   and cod_origen    = _cod_origen
						   and cod_contrato  = v_cod_contrato
						   and cod_cobertura = v_cobertura
						   and desc_cob      = v_desc_cobertura
						   and serie         = _serie;}
					--end if
				end foreach
			end if
		end if
	end foreach
end foreach
{foreach
	select no_remesa,
	       renglon,
		   sum(por_pagar)
	  into _no_remesa,
	       _renglon,
		   _por_pagar
	  from temp_produccion
	 where seleccionado = 1
	   and cod_coasegur = '063'
	   and serie = 2023
	 group by no_remesa, renglon
	
	select no_registro
	  into _no_reg
	  from sac999:reacomp
	 where no_remesa = _no_remesa
	   and renglon   = _renglon;
	
	select debito,
	       credito
	  into _db,
           _cr
      from sac999:reacompasiau
	 where no_registro = _no_reg
	   and cod_auxiliar = 'BQ063'
	   and cuenta[1,3] = '231';
	
	if abs(_db) <> 0 then
		if abs(_por_pagar) <> abs(_db) then
			return _no_remesa,_renglon,_no_reg,_db,_por_pagar with resume;
		end if
	end if
	if abs(_cr) <> 0 then
		if abs(_por_pagar) <> abs(_cr) then
			return _no_remesa,_renglon,_no_reg,_cr,_por_pagar with resume;
		end if
	end if
end foreach}
foreach
	select no_remesa,
	       renglon,
		   no_registro
	  into _no_remesa,
	       _renglon,
		   _no_reg
	  from sac999:reacomp
     where tipo_registro = 2
       and periodo between '2024-07' and '2024-09'
       and sac_asientos = 2
	   and no_documento[1,2] in('01','03')
	   
	select count(*)
	  into _cnt
	  from sac999:reacompasiau
	 where no_registro = _no_reg; 
	 
	if _cnt is null then
		let _cnt = 0;
	end if
	
	if _cnt = 0 then
		continue foreach;
	end if
	
	select count(*)
	  into _cnt
	  from temp_produccion
	 where seleccionado = 1
	   and no_remesa = _no_remesa
	   and renglon   = _renglon;

	if _cnt is null then
		let _cnt = 0;
	end if
	if _cnt = 0 then
		return _no_remesa,_renglon,_no_reg,0,0 with resume;
	end if	

end foreach

return "",0,"",0,0;
end
end procedure
																																							