--------------------------------------------
--Carga Generica de Prima Cobrada para Reaseguro
--22/07/2016 - Autor: Román Gordón.
--execute procedure sp_rea27('001','001','2016-07','2016-07','*','*','*','*','002,020,023;','*','*','2015,2014,2013,2012,2011,2010,2009,2008;','*')
--------------------------------------------
drop procedure sp_rea27;
create procedure sp_rea27(
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
returning	smallint		as cod_error,
			varchar(255)	as error_desc;

begin

define _error_desc			varchar(50);
define v_filtros2			char(255);
define v_filtros1			char(255);
define v_filtros			char(255);
define v_desc_contrato		char(50);
define v_desc_ramo			char(50);
define _no_documento		char(20);
define _res_comprobante		char(15);
define _no_registro			char(10);
define v_no_recibo			char(10);
define _no_poliza			char(10);
define _no_remesa			char(10);
define _no_poliza			char(10);
define _periodo1			char(8);
define v_cod_contrato		char(5);
define _cod_traspaso		char(5);
define _cod_cober_reas		char(3);
define v_cod_tipo			char(3);
define _cod_ramo			char(3);
define _t_ramo				char(1);
define _tipo				char(1);
define _porc_proporcion		dec(5,2);
define _porc_partic_coas	dec(7,4);
define _porc_partic_prima	dec(9,6);
define _suma_asegurada		dec(16,2);
define _prima_cobrada		dec(16,2);
define _prima_net_cob		dec(16,2);
define _prima_total			dec(16,2);
define v_prima_tipo			dec(16,2);
define _sum_fac_car			dec(16,2);
define _monto_reas			dec(16,2);
define _ret_otros			dec(16,2);
define _ret_casco			dec(16,2);
define v_prima_bq			dec(16,2);
define v_prima_ot			dec(16,2);
define _bq_casco			dec(16,2);
define _bq_otros			dec(16,2);
define v_prima_3			dec(16,2);
define v_prima_1			dec(16,2);
define v_prima1				dec(16,2);
define v_prima2				dec(16,2);
define v_prima				dec(16,2);
define v_tipo_contrato		smallint;
define _facilidad_car		smallint;
define _tipo_cont			smallint;
define _ramo_sis			smallint;
define _traspaso			smallint;
define _bouquet				smallint;
define _serie				smallint;
define _flag				smallint;
define _cnt					smallint;
define _sac_notrx			integer;
define _renglon				integer;
define _error				integer;
define _vigencia_inic		date;
define _vigencia_fin		date;

set isolation to dirty read;

let _porc_proporcion = 0;
let _periodo1 = a_periodo1;

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
		return	_error,_error_desc;
	end if

	create temp table temp_devpri(
	cod_ramo         char(3),
	cod_contrato     char(5),
	cod_cobertura    char(3),
	prima            dec(16,2),
	tipo             smallint default 0,
	serie 			 smallint,
	seleccionado     smallint default 1,
	no_poliza		 char(10),
	primary key(cod_ramo, cod_contrato, cod_cobertura, no_poliza)) with no log;

	create index idx1_temp_devpri on temp_devpri(cod_ramo);
	create index idx4_temp_devpri on temp_devpri(cod_contrato);
	create index idx5_temp_devpri on temp_devpri(cod_cobertura);
	create index idx7_temp_devpri on temp_devpri(no_poliza);
	create index idx8_temp_devpri on temp_devpri(serie);

	insert into temp_devpri
	select cod_ramo,cod_contrato,cod_cobertura,prima,tipo,serie,seleccionado,no_poliza from temp_produccion;

	drop table if exists temp_produccion;
end if

call sp_pro307(a_compania,a_agencia,a_periodo1,a_periodo2,a_codsucursal,a_codgrupo,a_codagente,a_codusuario,a_codramo,a_reaseguro)
returning v_filtros;

create temp table tmp_ramos(
cod_ramo		char(3),
cod_sub_tipo	char(3),
porcentaje		smallint default 100,
primary key(cod_ramo, cod_sub_tipo)) with no log;			

create temp table temp_produccion(
cod_ramo		char(3),
cod_contrato	char(5),
cod_cobertura	char(3),
prima			dec(16,2),
prima_otros		dec(16,2),
tipo			smallint default 0,
serie			smallint,
seleccionado	smallint default 1,
no_poliza		char(10),
primary key(cod_ramo, cod_contrato, cod_cobertura, no_poliza)) with no log;

create temp table tmp_tabla(
no_documento		char(20),
vigencia_ini		date,
vigencia_fin		date,
suma_asegurada		dec(16,2),		
cod_ramo			char(3),
desc_ramo			char(50),
cant_polizas		smallint,
p_cobrada			dec(16,2),
p_retenida			dec(16,2),
p_retenida_otros	dec(16,2),
p_bouquet			dec(16,2),
p_bouquet_otros		dec(16,2),
p_bouquet_casco		dec(16,2),
p_facultativo		dec(16,2),
p_otros				dec(16,2),
p_fac_car			dec(16,2),
no_recibo			char(10),
res_comprobante		char(15),
n_contrato			varchar(50),
p_ret_casco			dec(16,2),
primary key (no_documento,vigencia_ini,vigencia_fin,cod_ramo)) with no log;

let _sum_fac_car = 0;
let _tipo_cont = 0;
let _sac_notrx = 0;
let _ret_casco = 0;
let v_prima	= 0;
let _cnt = 0;
let v_no_recibo = '';
let v_filtros1 = '';
let v_filtros2 = '';

if a_subramo <> '*' then
	let v_filtros2 = trim(v_filtros2) ||' Sub Ramo '||trim(a_subramo);
	let _tipo = sp_sis04(a_subramo); -- separa los valores del string

	if _tipo <> 'E' then -- incluir los registros
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

--set debug file to 'sp_rea27.trc';
--trace on;

foreach
	select no_poliza,
		   prima_neta,
		   vigencia_inic,
		   no_factura,
		   no_documento,
		   no_remesa,
		   renglon
	  into _no_poliza,
		   _prima_cobrada,
		   v_no_recibo,
		   _no_documento,
		   _no_remesa,
		   _renglon
	  from temp_det
	 where seleccionado = 1
		
	select count(*)
	  into _cnt
	  from reaexpol
	 where no_documento = _no_documento
	   and activo = 1;

	if _cnt = 1 then --Estas polizas del Bco Hipotecario no las toman en cuenta.
		continue foreach;
	end if

	select cod_ramo
	  into _cod_ramo
	  from emipomae
	 where no_poliza = _no_poliza;

	select porc_partic_coas
	  into _porc_partic_coas
	  from emicoama
	 where no_poliza    = _no_poliza
	   and cod_coasegur = '036'; 			

	if _porc_partic_coas is null then
		let _porc_partic_coas = 100;
	end if

	let _prima_cobrada = _prima_cobrada * _porc_partic_coas / 100;
	
	let _prima_net_cob = 0.00;

	if _cod_ramo in ('002','020','023') then

		select sum(prima_neta)
		  into _prima_net_cob
		  from emipocob
		 where no_poliza = _no_poliza;
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
			   _cod_cober_reas
		  from tmp_reas

		let v_prima2 = 0.00;

		if _cod_cober_reas in ('002','033','025','035') then --Cálculo de las primas diferentes a RC dentro de la cobertura de reaseguro RC (Exclusivamente Auto)
			if _prima_net_cob = 0 then
				let v_prima2 = 0.00;
			else
				select sum(c.prima_neta) * (_porc_partic_coas/100) 
				  into v_prima2
				  from emipocob c, prdcober p
				 where c.cod_cobertura = p.cod_cobertura
				   and no_poliza = _no_poliza
				   and p.cod_cober_reas = _cod_cober_reas
				   and p.causa_siniestro not in (1,7,8); --Coberturas del tipo RC

				if v_prima2 is null then
					let v_prima2 = 0.00;
				end if

				let v_prima2 = _prima_cobrada * (v_prima2 / _prima_net_cob);
			end if
		end if

		let v_prima1 = _prima_cobrada * (_porc_partic_prima / 100) * (_porc_proporcion / 100);
		let v_prima1 = v_prima1 - v_prima2;
		let v_prima  = v_prima1;

		select traspaso
		  into _traspaso
		  from reacocob
		 where cod_contrato   = v_cod_contrato
		   and cod_cober_reas = _cod_cober_reas;

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
			let _tipo_cont = 1;
		end if

		select serie
		  into _serie
		  from reacomae
		 where cod_contrato = v_cod_contrato;

		select nombre
		  into v_desc_ramo
		  from prdramo
		 where cod_ramo = _cod_ramo;

		begin
			on exception in(-239)
				update temp_produccion
				   set prima         = prima + v_prima1,
					   prima_otros   = prima_otros  + v_prima2
				 where cod_ramo      = _cod_ramo
				   and cod_contrato  = v_cod_contrato
				   and cod_cobertura = _cod_cober_reas
				   and no_poliza     = _no_poliza;
			end exception

			insert into temp_produccion(
					cod_ramo,
			        cod_contrato,
			        cod_cobertura,
			        no_poliza,
			        prima,
			        prima_otros,
			        tipo,
					serie,
					seleccionado)
			values(	_cod_ramo,
					v_cod_contrato,
					_cod_cober_reas,
					_no_poliza,
					v_prima1,
					v_prima2,
					_tipo_cont,
					_serie,
					1);
		end
	end foreach
end foreach
--trace off;

--Proceso de Devolución de Primas
if a_periodo2 > '2013-07' then
	foreach 
		select cod_ramo,
			   cod_contrato,
			   cod_cobertura,
			   prima,
			   tipo,
			   serie,
			   no_poliza
		  into _cod_ramo, 
			   v_cod_contrato,
			   _cod_cober_reas,
			   _monto_reas,	   
			   _tipo_cont,		
			   _serie,
			   _no_poliza
		  from temp_devpri
		 where seleccionado = 1
		
		let _monto_reas = _monto_reas * -1;

		begin
			on exception in(-239)
				update temp_produccion
				   set prima         = prima + _monto_reas
					   --prima_otros   = prima_otros  + v_prima2
				 where cod_ramo      = _cod_ramo
				   and cod_contrato  = v_cod_contrato
				   and cod_cobertura = _cod_cober_reas
				   and no_poliza     = _no_poliza;
			end exception

			insert into temp_produccion(
					cod_ramo,
			        cod_contrato,
			        cod_cobertura,
			        no_poliza,
			        prima,
			        prima_otros,
			        tipo,
					serie,
					seleccionado)
			values(	_cod_ramo,
					v_cod_contrato,
					_cod_cober_reas,
					_no_poliza,
					_monto_reas,
					0.00,
					_tipo_cont,
					_serie,
					1);
		end
	end foreach
end if

--Filtro por Contrato
if a_contrato <> '*' then
	let v_filtros1 = trim(v_filtros1) ||' Contrato '||TRIM(a_contrato);
	let _tipo = sp_sis04(a_contrato); -- separa los valores del string

	if _tipo <> 'E' then -- incluir los registros
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
if a_serie <> '*' then
	let v_filtros1 = trim(v_filtros1) ||' Serie '||trim(a_serie);
	let _tipo = sp_sis04(a_serie); -- separa los valores del string

	if _tipo <> 'E' then -- incluir los registros
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

let v_filtros = trim(v_filtros1)||' '|| trim(v_filtros)||' '|| trim(v_filtros2);

--- tabla de ramos:
foreach
	select distinct cod_ramo
	  into _cod_ramo
	  from temp_produccion
	 where seleccionado = 1

	if _cod_ramo in ('001', '003') then
		if _cod_ramo in ('001') then
			let _t_ramo = '1';
		elif _cod_ramo in ('003') then
			let _t_ramo = '3';
		end if

		begin
			on exception in(-239)
			end exception

		    let v_cod_tipo = 'IN'||_t_ramo;

			insert into tmp_ramos (cod_ramo,cod_sub_tipo,porcentaje)
			values (_cod_ramo,v_cod_tipo,100);
			--values (_cod_ramo,v_cod_tipo,70);

		    let v_cod_tipo = 'TE'||_t_ramo;

			insert into tmp_ramos (cod_ramo,cod_sub_tipo,porcentaje)
			values (_cod_ramo,v_cod_tipo,100);
			--values (_cod_ramo,v_cod_tipo,30);
		end
	else
		insert into tmp_ramos (cod_ramo,cod_sub_tipo,porcentaje) 
		values (_cod_ramo,_cod_ramo,100); 
	end if
end foreach

foreach
	select distinct cod_ramo,		  --se busca por polizas
		   no_poliza
	  into _cod_ramo,
		   _no_poliza
	  from temp_produccion
	 where seleccionado = 1
	 group by cod_ramo, no_poliza
	 order by cod_ramo, no_poliza

	if v_prima is null then
		let v_prima = 0.00;
	end if

	select suma_asegurada,
		   no_documento,
		   vigencia_inic,
		   vigencia_final
	  into _suma_asegurada,
		   _no_documento,
		   _vigencia_inic,
		   _vigencia_fin
	  from emipomae
	 where no_poliza = _no_poliza
	   and cod_compania = '001'
	   and actualizado  = 1;

	select ramo_sis
	  into _ramo_sis
	  from prdramo
	 where cod_ramo = _cod_ramo;

	let v_prima_tipo = 0;

	foreach					 -- se desglosa por tipo, buscar primero si es bouquet
		select cod_contrato,
			   cod_cobertura,
			   tipo,
			   serie,
			   sum(prima),
			   sum(prima_otros)
		  into v_cod_contrato,
		       _cod_cober_reas,
			   _tipo_cont,
			   _serie,
			   v_prima_tipo,
			   v_prima2
		  from temp_produccion
		 where cod_ramo = _cod_ramo
		   and no_poliza = _no_poliza 
		   and seleccionado = 1
		 group by cod_contrato,cod_cobertura,tipo,serie 
		 order by cod_contrato,cod_cobertura,tipo,serie  

		let _sum_fac_car = 0;
		let v_prima_ot = 0;
		let _ret_casco = 0;
		let _ret_otros = 0;
		let v_prima_bq = 0;
		let _bq_otros = 0;
		let _bq_casco = 0;
		let v_prima_1 = 0;
		let v_prima_3 = 0;
		let _flag = 0;
		let _cnt  = 0;

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
		   and cod_cober_reas = _cod_cober_reas;

		let _facilidad_car = 0;

		select facilidad_car
		  into _facilidad_car
		  from reacomae
		 where cod_contrato = v_cod_contrato;

		if _bouquet = 1 and _serie >= 2008 then --and _cod_coasegur in ('050','063','076','042','036','089') then
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
				if _ramo_sis = 1 then --Auto
					if _cod_cober_reas in ('002','033','025','035') then
						let v_prima_bq = v_prima_bq + v_prima_tipo;
						let _bq_otros = _bq_otros + v_prima2;
					else
						let _bq_casco = _bq_casco + v_prima_tipo + v_prima2;
					end if
				else
					let _bq_otros = _bq_otros + v_prima_tipo;
				end if
				--let v_prima_bq = v_prima_bq + v_prima_tipo ;
			end if
		else
			if _tipo_cont = 2 or _tipo_cont = 1 then
				if _tipo_cont = 1 then		--	retencion
					if _ramo_sis = 1 then --Auto
						if _cod_cober_reas in ('002','033','025','035') then
							let v_prima_1 = v_prima_1 + v_prima_tipo;
							let _ret_otros = _ret_otros + v_prima2;
						else
							let _ret_casco = _ret_casco + v_prima_tipo + v_prima2;
						end if
					else
						let _ret_otros = _ret_otros + v_prima_tipo;
					end if
				elif _tipo_cont = 2 then		--  facultativos
					let v_prima_3 = v_prima_3 + v_prima_tipo;
				end if
			else
				if _facilidad_car = 1 then
					let _sum_fac_car = _sum_fac_car + v_prima_tipo;
				else
				   let v_prima_ot = v_prima_ot + v_prima_tipo ;		
				end if
			end if
		end if

		let v_prima_tipo = 0;
		let v_prima2 = 0;

		let _prima_total = v_prima_1 + v_prima_bq + v_prima_3 + v_prima_ot + _sum_fac_car + _ret_casco + _ret_otros + _bq_otros + _bq_casco;

		select nombre
		  into v_desc_contrato
		  from reacomae
		 where cod_contrato = v_cod_contrato;

		foreach
			select cod_sub_tipo
			  into v_cod_tipo
			  from tmp_ramos
			 where cod_ramo = _cod_ramo					

			select nombre
			  into v_desc_ramo
			  from prdramo
			 where cod_ramo = _cod_ramo;

			if v_cod_tipo[1,2] = 'IN' then
				if _cod_cober_reas in ('021','022') then
					continue foreach;
				end if
				let v_desc_ramo = trim(v_desc_ramo)||'-INCENDIO';

			elif v_cod_tipo[1,2] = 'TE' then
				if _cod_cober_reas in ('001','003') then
					continue foreach;
				end if
				
				let v_desc_ramo = trim(v_desc_ramo)||'-TERREMOTO';
			end if
			
			begin
				on exception in(-239)
					update tmp_tabla
					   set cant_polizas = cant_polizas + 1,
						   p_cobrada = p_cobrada + _prima_total,
						   p_retenida = p_retenida + v_prima_1,
						   p_retenida_otros = p_retenida_otros + _ret_otros,
						   p_ret_casco = p_ret_casco + _ret_casco,
						   p_bouquet = p_bouquet + v_prima_bq,
						   p_bouquet_otros = p_bouquet_otros + _bq_otros,
						   p_bouquet_casco = p_bouquet_casco + _bq_casco,
						   p_facultativo = p_facultativo  + v_prima_3,
						   p_otros = p_otros + v_prima_ot,
						   p_fac_car = p_fac_car + _sum_fac_car
					 where no_documento = _no_documento
					   and cod_ramo = v_cod_tipo
					   and vigencia_ini = _vigencia_inic
					   and vigencia_fin = _vigencia_fin;
				end exception
			
				insert into tmp_tabla(
						no_documento,
						vigencia_ini,
						vigencia_fin,
						suma_asegurada,
						cod_ramo,							
						desc_ramo,							
						cant_polizas, 					
						p_cobrada,    					
						p_retenida,   					
						p_retenida_otros,   					
						p_ret_casco,   					
						p_bouquet,    					
						p_bouquet_otros,    					
						p_bouquet_casco,    					
						p_facultativo,					
						p_otros,
						p_fac_car,
						no_recibo,
						n_contrato)
				values(	_no_documento, 
						_vigencia_inic, 
						_vigencia_fin, 
						_suma_asegurada, 
						v_cod_tipo, 
						v_desc_ramo, 
						1, 
						_prima_total,
						v_prima_1,
						_ret_otros,
						_ret_casco, 
						v_prima_bq,
						_bq_otros,
						_bq_casco,
						v_prima_3,
						v_prima_ot,
						_sum_fac_car,
						null,
						v_desc_contrato);
			end
		end foreach
	end foreach	
	let v_prima = 0; 
end foreach

drop table if exists temp_devpri;
drop table if exists temp_produccion;
drop table if exists temp_det;
drop table if exists tmp_ramos;
--drop table if exists tmp_tabla;

return 0,'Generación Exitosa';
end
end procedure;