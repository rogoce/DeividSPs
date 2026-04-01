---------------------------------------------------------------------------------
--      TOTALES DE PRODUCCION POR CONTRATO DE REASEGURO  
-- 		Realizado por Henry Giron 23/11/2009 filtros requeridos por Sr. Omar Wong
-- 		FACULTATIVO  
-- 		PRIMA SUSCRITA
-- execute PROCEDURE sp_pr123 ("001","001","2009-07","2009-09","*","*","*","*","*","*","*","*")
---  Modificado por Román Gordón 11/10/2013 ; Proceso de Devolución de Prima
-- "001,003,002,010,011,012,013,014;","*","*","*",0)
---------------------------------------------------------------------------------
drop procedure sp_pr123a;
create procedure sp_pr123a(
	a_compania    char(03),
	a_agencia     char(03),
	a_periodo1    char(07),
	a_periodo2    char(07),
	a_codsucursal char(255) default "*",
	a_codgrupo    char(255) default "*",
	a_codagente   char(255) default "*",
	a_codusuario  char(255) default "*",
	a_codramo     char(255) default "*",
	a_reaseguro   char(255) default "*",
	a_contrato    char(255) default "*",
	a_serie       char(255) default "*",
	a_fronting    smallint  default 0)
returning	integer,
			char(255);	

begin
define v_filtros1			char(255);
define v_filtros			char(255);
define v_desc_cobertura		char(100);
define v_desc_contrato		char(50);
define _nombre_coas			char(50);
define v_descr_cia			char(50);
define v_desc_ramo			char(50);
define _nombre_cob			char(50);
define _nombre_con			char(50);
define _error_desc			char(50);
define _cuenta				char(25);
define _transaccion			char(10);
define _no_reclamo			char(10);
define _no_tranrec			char(10);
define v_nopoliza			char(10);
define _anio_reas			char(9);
define v_cod_contrato		char(5);
define _cod_traspaso		char(5);
define _cod_contrato		char(5);					  
define v_noendoso			char(5);
define _no_unidad			char(5);
define _cod_cober_reas		char(3);
define _cod_coasegur		char(3);
define _cod_subramo			char(3);
define v_cobertura			char(3);
define _cod_origen			char(3);
define v_cod_ramo			char(3);
define v_clase				char(3);
define _xnivel				char(3);
define _cod_r				char(3);
define _borderaux			char(2);
define _tipo				char(1);
define _porcentaje			dec(5,2);
define _porc_impuesto4		dec(16,4);
define _porc_comision4		dec(16,4);
define _porc_comision		dec(16,4);
define _porc_impuesto		dec(16,4);
define _prima_tot_ret_sum	dec(16,2);
define _prima_tot_sus_sum	dec(16,2);
define _porc_cont_partic	dec(16,2);
define _porc_comis_ase		dec(16,2);
define _p_50_siniestro		dec(16,2);
define _prima_devuelta		dec(16,2);
define _prima_tot_ret		dec(16,2);
define _prima_sus_tot		dec(16,2);
define _part_res_dist		dec(16,2);
define _pagado_neto			dec(16,2);
define _por_pagar70			dec(16,2);
define _por_pagar30			dec(16,2);
define _siniestro70			dec(16,2);
define _siniestro30			dec(16,2);
define _siniestro50			dec(16,2);
define _comision70			dec(16,2);
define _comision30			dec(16,2);
define _impuesto70			dec(16,2);
define _impuesto30			dec(16,2);
define _p_c_partic			dec(16,2);
define _monto_reas			dec(16,2);
define _p_50_prima			dec(16,2);
define _prima_fac			dec(16,2);
define _siniestro			dec(16,2);
define _por_pagar			dec(16,2);
define v_prima70			dec(16,2);
define v_prima30			dec(16,2);
define v_prima50			dec(16,2);
define _impuesto			dec(16,2);
define _comision			dec(16,2);
define v_prima1				dec(16,2);
define v_prima				dec(16,2);
define _sini				dec(16,2);
define _tiene_comis_rea		smallint;
define v_tipo_contrato		smallint;
define _p_c_partic_hay		smallint;
define _tiene_comision		smallint;
define _seleccionado		smallint;
define _trim_reas			smallint;
define _tipo_cont			smallint;
define _traspaso			smallint;
define _cantidad			smallint;
define _fronting			smallint;
define v_existe				smallint;
define _renglon				smallint;
define _serie1				smallint;
define _serie				smallint;
define _nivel				smallint;
define nivel				smallint;
define _tipo2				smallint;
define _cnt					smallint;
define _error				integer;


set isolation to dirty read; 	
let v_desc_contrato = '';
drop table if exists tmp_producion_ps;
drop table if exists temp_det;
drop table if exists tmp_sinis;
 	
call sp_pro34(a_compania,a_agencia,a_periodo1,a_periodo2,a_codsucursal,a_codgrupo,
				a_codagente,a_codusuario,a_codramo,a_reaseguro) returning v_filtros;

let v_filtros = sp_rec708(
	a_compania,
	a_agencia,
	a_periodo1,
	a_periodo2,
	a_codsucursal,
	'*', 
	a_codramo, --'*'
	'*', 
	'*', 
	'*', 
	'*',
	'*'    ---a_contrato
	);

create temp table tmp_producion_ps(
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
	serie				smallint,	
	seleccionado		smallint default 1,	
	porc_comision		dec(16,2), 
	porc_impuesto		dec(16,2), 
	porc_cont_partic	dec(16,2), 
	cod_coasegur		char(3),
	tiene_comision		smallint,
	no_poliza		    char(10),
	no_endoso           char(5),
primary key(cod_ramo, cod_subramo, cod_origen, cod_contrato, cod_cobertura, desc_cob,no_poliza,cod_coasegur,serie)) with no log;

create index idx1_tmp_producion_ps on tmp_producion_ps(cod_ramo);
create index idx2_tmp_producion_ps on tmp_producion_ps(cod_subramo);
create index idx3_tmp_producion_ps on tmp_producion_ps(cod_origen);
create index idx4_tmp_producion_ps on tmp_producion_ps(cod_contrato);
create index idx5_tmp_producion_ps on tmp_producion_ps(cod_cobertura);
create index idx6_tmp_producion_ps on tmp_producion_ps(desc_cob);
create index idx7_tmp_producion_ps on tmp_producion_ps(cod_coasegur);
create index idx8_tmp_producion_ps on tmp_producion_ps(serie);
create index idx9_tmp_producion_ps on tmp_producion_ps(no_poliza);

let v_descr_cia			= sp_sis01(a_compania);
let v_desc_cobertura	= "";
let v_filtros1			= "";
let _pagado_neto		= 0;
let _prima_fac			= 0;
let _tipo_cont			= 0;
let v_prima				= 0;
let _sini				= 0;
--set debug file to "sp_pr123a.trc";	 																						 

foreach with hold
	select z.no_poliza,																	 
		   z.no_endoso																		 
	  into v_nopoliza,
		   v_noendoso
	  from temp_det z
	 where z.seleccionado = 1
	 group by 1, 2

	select cod_ramo,
		   cod_subramo,
		   cod_origen
	  into v_cod_ramo,
		   _cod_subramo,
		   _cod_origen
	  from emipomae
	 where no_poliza = v_nopoliza;
		  
	foreach
		select cod_cober_reas,
			   cod_contrato,
			   prima,
			   no_unidad
		  into v_cobertura,
			   v_cod_contrato,
			   v_prima1,
			   _no_unidad
		  from emifacon
		 where no_poliza = v_nopoliza
		   and no_endoso = v_noendoso
	               --and prima <> 0

		if v_nopoliza = "220864" and v_noendoso = "00001" then
			let v_prima1 = 0.00;
		end if

		if a_fronting  = 1 then
			select fronting
			  into _fronting
			  from reacomae
			 where cod_contrato = v_cod_contrato;

			if _fronting = 1 then  -- es fronting
			else
				continue foreach;
			end if
		end if;

		select traspaso
		  into _traspaso
		  from reacocob
		 where cod_contrato   = v_cod_contrato
		   and cod_cober_reas = v_cobertura;

		select cod_traspaso
		  into _cod_traspaso
		  from reacomae
		 where cod_contrato = v_cod_contrato;

		if _traspaso = 1 then
			let v_cod_contrato = _cod_traspaso;
		end if

		select tipo_contrato,
			   serie
		  into v_tipo_contrato,
			   _serie
		  from reacomae
		 where cod_contrato = v_cod_contrato;

		if v_tipo_contrato <> 3 then  -- trabajar solo facultativo
			continue foreach;
		end if	 

		let _tipo_cont = 2;			 
		let v_prima      = v_prima1;
		let _cod_subramo = "001";

		select nombre
		  into v_desc_contrato 
		  from reacomae
		 where cod_contrato = v_cod_contrato;

		let v_desc_contrato = trim(v_desc_contrato) || " (" || v_cod_contrato || ")" || "  A: " || _serie;

		select porc_impuesto,
			   porc_comision,
			   tiene_comision
		  into _porc_impuesto,
			   _porc_comision,
			   _tiene_comis_rea
		  from reacocob
		 where cod_contrato   = v_cod_contrato
		   and cod_cober_reas = v_cobertura;

		let _cuenta = "";

		select nombre
		  into v_desc_ramo
		  from prdramo
		 where cod_ramo = v_cod_ramo;

		select nombre
		  into _nombre_cob
		  from reacobre
		 where cod_cober_reas = v_cobertura;

		let _prima_fac = 0;

		foreach
			select porc_partic_reas,
				   porc_comis_fac,
				   porc_impuesto,
				   cod_coasegur,
				   monto_comision,
				   monto_impuesto,
				   prima
			  into _porc_cont_partic,
				   _porc_comis_ase,
				   _porc_impuesto,
				   _cod_coasegur,
				   _comision,
				   _impuesto,
				   _prima_fac
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
			let v_desc_contrato  = trim(v_desc_contrato) || "  i:" || _porc_impuesto || "  C:" || _porc_comis_ase;

			if _comision is null then
				let _comision = 0;
			end if

			if _impuesto is null then
				let _impuesto = 0;
			end if
			
			let v_prima	= _prima_fac;
			let _monto_reas	= v_prima;
			
			
			{if v_prima = 0 then
				let v_prima	= _prima_fac;
			else
				let v_prima = v_prima1;
			end if}

			if _porc_cont_partic = 0 then
				let _porc_cont_partic = 100;
			end if
			
			--let _monto_reas = v_prima * _porc_cont_partic / 100;
			--let _impuesto   = _monto_reas * _porc_impuesto / 100;
			--let _comision   = _monto_reas * _porc_comis_ase / 100;
			let _por_pagar  = _monto_reas - _impuesto - _comision;

			select count(*)
			  into _cantidad
			  from tmp_producion_ps
			 where cod_ramo      = v_cod_ramo
			   and cod_subramo   = _cod_subramo
			   and cod_origen    = _cod_origen
			   and cod_contrato  = v_cod_contrato
			   and cod_cobertura = v_cobertura
			   and desc_cob      = v_desc_cobertura
			   and serie         = _serie
			   and no_poliza     = v_nopoliza
			   and cod_coasegur  = _cod_coasegur;

			if _cantidad = 0 then
				insert into tmp_producion_ps
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
						_porc_comision,
						_porc_impuesto,
						_porc_cont_partic,
						_cod_coasegur,
						_tiene_comis_rea,
						v_nopoliza,
						v_noendoso);
			else
				update tmp_producion_ps
				   set prima     = prima     + _monto_reas,
					   comision  = comision  + _comision,
					   impuesto  = impuesto  + _impuesto,
					   por_pagar = por_pagar + _por_pagar
				 where cod_ramo  = v_cod_ramo
				   and cod_subramo	 = _cod_subramo
				   and cod_origen    = _cod_origen
				   and cod_contrato  = v_cod_contrato
				   and cod_cobertura = v_cobertura
				   and desc_cob      = v_desc_cobertura
				   and serie         = _serie
				   and no_poliza     = v_nopoliza
				   and cod_coasegur  = _cod_coasegur;
			end if
			let v_prima = v_prima1;
		end foreach
	end foreach
end foreach

-- Adicionar filtro contrato y serie
-- Filtro por Contrato

if a_contrato <> "*" then
	let v_filtros1 = trim(v_filtros1) ||" Contrato "||TRIM(a_contrato);
	let _tipo = sp_sis04(a_contrato); -- separa los valores del string

	if _tipo <> "E" then -- incluir los registros
		update tmp_producion_ps
		   set seleccionado = 0
		 where seleccionado = 1
		   and cod_contrato not in(select codigo from tmp_codigos);
	else
		update tmp_producion_ps
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
		update tmp_producion_ps
		   set seleccionado = 0
		 where seleccionado = 1
		   and serie not in(select codigo from tmp_codigos);
	else
		update tmp_producion_ps
		   set seleccionado = 0
		 where seleccionado = 1
		   and serie in(select codigo from tmp_codigos);
	end if
	drop table tmp_codigos;
end if

let v_filtros = trim(v_filtros1)||" "|| trim(v_filtros);

return 0,'';
--drop table tmp_dist716;
--drop table temp_devpri;

end
end procedure  