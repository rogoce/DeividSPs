---------------------------------------------------------------------------------
--      TOTALES DE PRODUCCION POR CONTRATO DE REASEGURO  
-- 		Realizado por Henry Giron 23/11/2009 filtros requeridos por Sr. Omar Wong
-- 		FACULTATIVO  
-- 		PRIMA SUSCRITA
-- execute PROCEDURE sp_pr123 ("001","001","2009-07","2009-09","*","*","*","*","*","*","*","*")
---  Modificado por Román Gordón 11/10/2013 ; Proceso de Devolución de Prima
-- "001,003,002,010,011,012,013,014;","*","*","*",0)
---------------------------------------------------------------------------------
drop procedure sp_pr123h;
create procedure sp_pr123h(
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
define _por_pagar_partic	dec(16,2);
define _siniestro_partic	dec(16,2);


drop table if exists tmp_produccion_ps;
drop table if exists temp_det;
drop table if exists tmp_sinis;
drop table if exists tmp_dist716;
drop table if exists temp_devpri;

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

drop table if exists temp_imformef;
create temp table temp_imformef(
cod_coasegur		char(3),
cod_ramo			char(3),
cod_contrato		char(5),
cobertura			char(3),
prima				dec(16,2),
comision			dec(16,2),
impuesto			dec(16,2),
por_pagar			dec(16,2),
siniestro			dec(16,2),
prima_tot_ret		dec(16,2),
prima_sus_tot		dec(16,2),
porc_cont_partic	dec(16,2),
desc_ramo			char(50),
desc_contrato		char(50),
por_pagar_partic	dec(16,2),
siniestro_partic	dec(16,2)) with no log;

-- ****Inclusion de siniestros		   
drop table if exists tmp_temphgf;
create temp table tmp_temphgf (
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

set isolation to dirty read; 	

let _borderaux = "04";	   -- facultativo

let v_desc_contrato = '';

select tipo 
  into _tipo2 
  from reacontr 
 where cod_contrato = _borderaux;
 
call sp_rea002(a_periodo2,_tipo2) returning _anio_reas,_trim_reas; 

--DELETE FROM reacoret where anio = _anio_reas and trimestre = _trim_reas and borderaux = _borderaux;   -- Elimina borderaux del trimestre
--DELETE FROM tmp_temphgf1;

delete from tmp_reacoest
 where anio = _anio_reas
   and trimestre = _trim_reas
   and borderaux = _borderaux;   -- elimina borderaux del trimestre
   
delete from tmp_temphgf 
 where anio = _anio_reas 
   and trimestre = _trim_reas
   and borderaux = _borderaux;     -- elimina borderaux datos;
 	

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

create temp table tmp_produccion_ps(
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
primary key(cod_ramo, cod_subramo, cod_origen, cod_contrato, cod_cobertura, desc_cob,serie)) with no log;

create index idx1_tmp_produccion_ps on tmp_produccion_ps(cod_ramo);
create index idx2_tmp_produccion_ps on tmp_produccion_ps(cod_subramo);
create index idx3_tmp_produccion_ps on tmp_produccion_ps(cod_origen);
create index idx4_tmp_produccion_ps on tmp_produccion_ps(cod_contrato);
create index idx5_tmp_produccion_ps on tmp_produccion_ps(cod_cobertura);
create index idx6_tmp_produccion_ps on tmp_produccion_ps(desc_cob);
create index idx7_tmp_produccion_ps on tmp_produccion_ps(cod_coasegur);
create index idx8_tmp_produccion_ps on tmp_produccion_ps(serie);

create temp table tmp_dist716(
	no_reclamo      char(10),
	cod_coasegur	char(3),
	porcentaje		dec(5,2),
	monto_reas		dec(16,2),
	cod_ramo        char(3),
	serie           smallint,
	seleccionado    smallint  default 1 not null,
primary key (no_reclamo,cod_coasegur)) with no log;

create index xie01_tmp_dist716 on tmp_dist716(no_reclamo);
create index xie02_tmp_dist716 on tmp_dist716(cod_coasegur);

let v_descr_cia			= sp_sis01(a_compania);
let v_desc_cobertura	= "";
let v_filtros1			= "";
let _p_50_siniestro		= 100;
let _p_50_prima			= 100;
let _pagado_neto		= 0;
let _prima_fac			= 0;
let _tipo_cont			= 0;
let v_prima				= 0;
let _sini				= 0;

--set debug file to "sp_pr123.trc";	 																						 

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
			  from tmp_produccion_ps
			 where cod_ramo      = v_cod_ramo
			   and cod_subramo   = _cod_subramo
			   and cod_origen    = _cod_origen
			   and cod_contrato  = v_cod_contrato
			   and cod_cobertura = v_cobertura
			   and desc_cob      = v_desc_cobertura
			   and serie         = _serie;
			--					           and cod_coasegur  = _cod_coasegur;

			if _cantidad = 0 then
				insert into tmp_produccion_ps
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
						_tiene_comis_rea);
			else
				update tmp_produccion_ps
				   set prima     = prima     + _monto_reas,
					   comision  = comision  + _comision,
					   impuesto  = impuesto  + _impuesto,
					   por_pagar = por_pagar + _por_pagar
				 where cod_ramo  = v_cod_ramo
				   and cod_subramo	= _cod_subramo
				   and cod_origen    = _cod_origen
				   and cod_contrato  = v_cod_contrato
				   and cod_cobertura = v_cobertura
				   and desc_cob      = v_desc_cobertura
				   and serie         = _serie;
				   --and cod_coasegur  = _cod_coasegur;
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
		update tmp_produccion_ps
		   set seleccionado = 0
		 where seleccionado = 1
		   and cod_contrato not in(select codigo from tmp_codigos);
	else
		update tmp_produccion_ps
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
		update tmp_produccion_ps
		   set seleccionado = 0
		 where seleccionado = 1
		   and serie not in(select codigo from tmp_codigos);
	else
		update tmp_produccion_ps
		   set seleccionado = 0
		 where seleccionado = 1
		   and serie in(select codigo from tmp_codigos);
	end if
	drop table tmp_codigos;
end if

let v_filtros = trim(v_filtros1)||" "|| trim(v_filtros);
--set debug file to "sp_pr123.trc";
--trace on;
-- Carga Temporal contrato por ramos.
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
	       _porc_comision,
	       _porc_impuesto,
	       _porc_cont_partic,
	       _cod_coasegur
      from tmp_produccion_ps
	 where seleccionado = 1

	{
	-----Proceso de Devolución de Prima
	select prima
	  into _prima_devuelta
	  from temp_devpri
	 where cod_ramo			= v_cod_ramo
	   and cod_subramo		= _cod_subramo
	   and cod_origen		= _cod_origen
	   and cod_contrato		= v_cod_contrato
	   and cod_cobertura	= v_cobertura
	   and desc_cob			= v_desc_cobertura
	   and serie			= _serie1;
	
	if _prima_devuelta is null then
		let _prima_devuelta = 0.00;
	end if
	
	
	let _monto_reas = _monto_reas - _prima_devuelta;
	
	delete from temp_devpri
	 where cod_ramo			= v_cod_ramo
	   and cod_subramo		= _cod_subramo
	   and cod_origen		= _cod_origen
	   and cod_contrato		= v_cod_contrato
	   and cod_cobertura	= v_cobertura
	   and desc_cob			= v_desc_cobertura
	   and serie			= _serie1;
	-----------------------------------------------------------------------------------
	}   
	let _p_c_partic = 0;
	let _p_c_partic_hay = 0;

	select traspaso,
		   tiene_comision
	  into _traspaso,
		   _tiene_comision
	  from reacocob
	 where cod_contrato   = v_cod_contrato
	   and cod_cober_reas = v_cobertura;

	select tipo_contrato,
		   serie
	  into v_tipo_contrato,
		   _serie
	  from reacomae
	 where cod_contrato = v_cod_contrato;

	let _seleccionado = 0;

	if v_tipo_contrato = 3 then   --facultativos
		let _seleccionado = 1;
	end if
	
	if _comision is null then
		let _comision = 0;
	end if	  

	if _impuesto is null then
		let _impuesto = 0;
	end if
    if v_desc_contrato is null then
		let v_desc_contrato = '';
    end if
	insert into tmp_temphgf
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
			_seleccionado,
			_anio_reas,
			_trim_reas,
			_borderaux);
end foreach

foreach
	select serie,
		   cod_coasegur,
		   tipo_contrato,
		   porc_cont_partic,
		   porc_comision,
		   porc_impuesto,
		   cod_ramo,
		   cod_contrato,
		   cod_cobertura,
		   sum(prima),
		   comision,
		   impuesto
	  into _serie,
		   _cod_coasegur,
		   v_tipo_contrato,
		   _porc_cont_partic,
		   _porc_comision,
		   _porc_impuesto,
		   v_cod_ramo,
		   v_cod_contrato,
		   v_cobertura,
		   v_prima,
		   _comision,
		   _impuesto
     from tmp_temphgf
    where seleccionado = 1
	  and anio      = _anio_reas
	  and trimestre = _trim_reas
	  and borderaux = _borderaux 
    group by serie,cod_coasegur,tipo_contrato,porc_cont_partic,porc_comision,porc_impuesto,cod_ramo,cod_contrato,cod_cobertura,comision,impuesto
  
	if v_prima = 0 and _comision = 0 and _impuesto = 0 then
		continue foreach;
	end if
	 { 	SELECT sum(t.pagado_neto)
		  INTO _siniestro	
		  FROM tmp_sinis t, reacomae r
		 where t.cod_ramo      = v_cod_ramo	
	       and r.cod_contrato  = t.cod_contrato 
		   and r.serie         = _serie 
		   and t.seleccionado  = 1 
		   and t.tipo_contrato in('3');

		if _siniestro is null then
		   let _siniestro = 0;
	    end if 

		foreach

			SELECT transaccion
			  INTO _transaccion	
			  FROM tmp_sinis t, reacomae r
			 where t.cod_ramo      = v_cod_ramo	
		       and r.cod_contrato  = t.cod_contrato 
			   and r.serie         = _serie 
			   and t.seleccionado  = 1 
			   and t.tipo_contrato in('3')

		    select no_tranrec
			  into _no_tranrec
		      from rectrmae
			 where transaccion = _transaccion;
			
		    select count(*)
			  into _cnt
		      from rectrref
			 where cod_contrato = v_cod_contrato
			   and cod_coasegur = _cod_coasegur
			   and no_tranrec   = _no_tranrec;

			if _cnt > 0 then
				exit foreach;
			else
			   let _siniestro = 0;
			end if

		end foreach	}

	let v_clase = v_cod_ramo;
	let _xnivel = '003';
		
	let _p_50_prima     = 100;
	let _p_50_siniestro = 100;

	--let _siniestro50 =  (_siniestro * _p_50_siniestro)/100;
	let v_prima50 =  (v_prima * _p_50_prima)/100;
	let _por_pagar = v_prima50 - _comision - _impuesto ;

	begin
	on exception in(-239)
		update tmp_reacoest
		   set prima         = prima + v_prima50, 
			   comision      = comision + _comision, 
			   impuesto      = impuesto + _impuesto, 
			   prima_neta    = prima_neta + _por_pagar
--				   siniestro     = siniestro + _siniestro 
		 where cod_coasegur	 = _cod_coasegur
		   and cod_contrato  = _serie
		   and cod_cobertura = _xnivel
		   and cod_ramo      = v_cod_ramo
		   and cod_clase     = v_clase 
		   and anio          = _anio_reas
		   and trimestre     = _trim_reas
		   and borderaux     = _borderaux;
	end exception 	

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
			borderaux)
	values(	_cod_coasegur,
			v_cod_ramo,
			_serie,
			_xnivel,
			v_prima50, 
			_comision, 
			_impuesto, 
			_por_pagar,
			0,	 --_siniestro
			0,
			0,
			0,
			v_clase,
			_anio_reas,
			_trim_reas,
			_borderaux);
	end
end foreach

foreach
	select transaccion,
		   pagado_neto,
		   no_reclamo,
		   cod_ramo,
		   cod_contrato
	  into _transaccion,
		   _pagado_neto,
		   _no_reclamo,
		   v_cod_ramo,
		   _cod_contrato
	  from tmp_sinis 
	 where seleccionado  = 1
	   and tipo_contrato in('3')

	foreach
		select no_tranrec
		  into _no_tranrec
		  from rectrmae
		 where transaccion = _transaccion
		exit foreach;
	end foreach

	select p.cod_cober_reas
	  into _cod_cober_reas
	  from recrccob r, prdcober p
	 where r.cod_cobertura = p.cod_cobertura
	   and r.no_reclamo    = _no_reclamo;
	
	select serie
	  into _serie
	  from reacomae
	 where cod_contrato = _cod_contrato;

	foreach
		select orden
		  into _renglon
		  from rectrrea
		 where no_tranrec    = _no_tranrec
		   and tipo_contrato = 3
		   and cod_cober_reas = _cod_cober_reas

		foreach
			select cod_coasegur,
				   porc_partic_reas
			  into _cod_coasegur,
				   _porcentaje
			  from rectrref
			 where no_tranrec = _no_tranrec
			   and cod_cober_reas = _cod_cober_reas
			   and orden      = _renglon

			if _porcentaje is null then
				let _porcentaje = 0.00;
			end if

			if _porcentaje <> 0 then
				let _part_res_dist = _pagado_neto * _porcentaje / 100;
			else
				let _part_res_dist = 0;
			end if	

			begin
				on exception in(-239)
					update tmp_dist716
					   set monto_reas   = monto_reas + _part_res_dist
					 where no_reclamo   = _no_reclamo 
					   and cod_coasegur = _cod_coasegur;
				end exception

				insert into tmp_dist716(
					no_reclamo,
					cod_coasegur,
					porcentaje,
					monto_reas,
					cod_ramo,
					serie)
				values(
					_no_reclamo,
					_cod_coasegur,
					_porcentaje,
					_part_res_dist,
					v_cod_ramo,
					_serie);
			end 	
		end foreach
	end foreach
end foreach

foreach
	select cod_coasegur,
		   serie,
		   cod_ramo
	  into _cod_coasegur,
		   _serie,
		   v_cod_ramo
	  from tmp_dist716
	 where porcentaje <> 0
	 group by cod_coasegur,serie,cod_ramo

    select count(*)
	  into _cnt
	  from tmp_reacoest
	 where anio         = _anio_reas
	   and trimestre    = _trim_reas
	   and borderaux    = _borderaux
	   and cod_contrato = _serie
	   and cod_coasegur = _cod_coasegur
	   and cod_ramo     = v_cod_ramo;

    if _cnt = 0 then
		foreach
			select monto_reas,
				   porcentaje,
				   cod_ramo
			  into _siniestro,
				   _porcentaje,
				   v_cod_ramo
			  from tmp_dist716
			 where porcentaje   <> 0
			   and serie        = _serie
			   and cod_coasegur = _cod_coasegur

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
					borderaux)
			values (_cod_coasegur,
					v_cod_ramo,
					_serie,
					'003',
					0, 
					0, 
					0, 
					0,
					_siniestro,
					0,
					0,
					_porcentaje,
					v_cod_ramo,
					_anio_reas,
					_trim_reas,
					_borderaux);
		end foreach
	else
		foreach
			select sum(monto_reas)/_cnt,
			       cod_ramo
			  into _siniestro,
			       v_cod_ramo
			  from tmp_dist716
			 where porcentaje   <> 0
			   and serie        = _serie
			   and cod_coasegur = _cod_coasegur
			 group by cod_ramo

		    select sum(siniestro)
			  into _sini
			  from tmp_reacoest
			 where anio         = _anio_reas
			   and trimestre    = _trim_reas
			   and borderaux    = _borderaux
			   and cod_contrato = _serie
			   and cod_coasegur = _cod_coasegur
			   and cod_ramo     = v_cod_ramo;

			if abs(_sini) > 0 then
			else
				update tmp_reacoest
				   set siniestro  = siniestro + _siniestro
				 where anio       = _anio_reas
				   and trimestre  = _trim_reas
				   and borderaux  = _borderaux
				   and cod_coasegur = _cod_coasegur
				   and cod_contrato = _serie
				   and cod_ramo     = v_cod_ramo;
			end if
		end foreach
	end if
end foreach

update tmp_reacoest
   set participar  = prima_neta - siniestro,
  	   p_partic    = prima,
       resultado   = siniestro  
 where anio      = _anio_reas
   and trimestre = _trim_reas
   and borderaux = _borderaux;

--trace off;
foreach
	select cod_coasegur,
		   cod_ramo,
		   cod_contrato,
		   cod_cobertura,
		   sum(p_partic),
		   sum(prima),
		   sum(comision),
		   sum(impuesto),
		   sum(prima_neta),
		   sum(resultado),
		   sum(siniestro),
		   sum(participar)
	  into _cod_coasegur,
		   v_cod_ramo,
		   v_cod_contrato,
		   v_cobertura,
		   _porc_cont_partic,
		   v_prima,
		   _comision,
		   _impuesto,
		   _por_pagar,
		   _siniestro,
		   _prima_sus_tot,
		   _prima_tot_ret	
	  from tmp_reacoest
	 where anio      = _anio_reas
	   and trimestre = _trim_reas
	   and borderaux = _borderaux 
	 group by cod_coasegur,cod_ramo,cod_contrato,cod_cobertura


	select nombre
	  into v_desc_ramo
	  from prdramo
	 where cod_ramo = v_cod_ramo;

	select nombre
	  into v_desc_contrato
	  from emicoase
	 where cod_coasegur = _cod_coasegur;
	 
	 let _por_pagar_partic = _por_pagar * _porc_cont_partic/100;
	 let _siniestro_partic = _siniestro * _porc_cont_partic/100;		

	begin
		on exception in(-239,-268)
		end exception 	

		insert into temp_imformef(
			cod_coasegur,	  
			cod_ramo,		  
			cod_contrato,	  
			cobertura,	      
			prima, 		      
			comision, 		  
			impuesto, 		  
			por_pagar,		  
			siniestro,		  
			prima_tot_ret,	  
			prima_sus_tot,	  
			porc_cont_partic, 
			desc_ramo,	      
			desc_contrato,      
			por_pagar_partic, 
			siniestro_partic) 
		values (_cod_coasegur,	  
			v_cod_ramo,		  
			v_cod_contrato,	  
			v_cobertura,	  
			v_prima, 		  
			_comision, 		  
			_impuesto, 		  
			_por_pagar,		  
			_siniestro,		  
			_prima_tot_ret,	  
			_prima_sus_tot,	  
			_porc_cont_partic,
			v_desc_ramo,	  
			v_desc_contrato,  
			_por_pagar_partic,
			_siniestro_partic);
	end	 

end foreach

return 0, 'Carga Exitosa';


end
end procedure  