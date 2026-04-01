--      TOTALES DE PRODUCCION POR         --
--         CONTRATO DE REASEGURO          --
---  Yinia M. Zamora - octubre 2000       -- YMZM
---  Ref. Power Builder - reemplaza sp_pro308
--- Modificado por Armando Moreno 19/01/2002; la parte de los tipo de contratos
--- Modificado por Henry 10/9/2009 filtros requeridos por Sr. Omar Wong
--------------------------------------------
---- Copia del sp_pr999 Federico Coronado ramo incendio
--execute procedure sp_rea22a('001','001','2017-07','2018-03',"*","*","*","*","014;","*","*","2013,2012,2011,2010,2009,2008;","*","01")
drop procedure sp_rea22a;
create procedure sp_rea22a(
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
a_contrato		char(255)	default "*",
a_serie			char(255)	default "*",
a_subramo		char(255)	default "*",
a_tipo_bx		char(2)		default "01")
returning smallint;

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
define _no_remesa			char(10);
define v_nopoliza			char(10);
define _no_poliza_vigente   char(10);
define _anio_reas			char(9);
define _periodo1			char(8);
define v_cod_contrato		char(5);
define _cod_traspaso		char(5);
define _no_unidad			char(5);
define v_noendoso			char(5);
define _cod_coasegur		char(3);
define _cod_subramo			char(3);
define _cod_origen			char(3);
define v_cobertura			char(3);
define v_cod_tipo2			char(3);
define v_cod_tipo			char(3);
define v_cod_ramo			char(3);
define _borderaux			char(2);
define _t_ramo				char(1);
define _tipo				char(1);
define _prima_tot_ret_sum	dec(16,2);
define _prima_tot_sus_sum	dec(16,2);
define v_prima_suscrita		dec(16,2);
define v_suma_asegurada		dec(16,1);
define v_prima_cobrada		dec(16,2);
define v_rango_inicial		dec(16,2);
define _prima_tot_ret		dec(16,2);
define _prima_sus_tot		dec(16,2);
define _porc_impuesto		dec(16,2);
define _porc_comision		dec(16,2);
define _p_sus_tot_sum		dec(16,2);
define v_facultativo		dec(16,2);
define v_rango_final		dec(16,2);
define v_prima_tipo			dec(16,2);
define _sum_fac_car			dec(16,2);
define _monto_reas			dec(16,2);
define v_acumulada			dec(16,2);
define v_acumulado			dec(16,2);
define v_prima_bq			dec(16,2);
define _por_pagar			dec(16,2);
define _p_sus_tot			dec(16,2);
define v_prima_34			dec(16,2);
define v_retenida			dec(16,2);
define v_prima_ot			dec(16,2);
define v_fac_car			dec(16,2);
define v_prima_1			dec(16,2);
define v_prima_3			dec(16,2);
define v_cobrada			dec(16,2);
define v_bouquet			dec(16,2);
define _impuesto			dec(16,2);
define _comision			dec(16,2);
define v_prima1				dec(16,2);
define v_otros				dec(16,2);
define v_prima				dec(16,2);
define _porc_partic_prima	dec(9,6);
define _porc_partic_coas	dec(7,4);
define _porc_cont_partic	dec(5,2);
define _porc_proporcion		dec(5,2);
define _porc_comis_ase		dec(5,2);
define _tiene_comis_rea		smallint;
define v_tipo_contrato		smallint;
define _facilidad_car		smallint;
define v_porcentaje			smallint;
define _trim_reas			smallint;
define v_contador			smallint;
define _tipo_cont			smallint;
define _no_cambio			smallint;
define _cantidad			smallint;
define _traspaso			smallint;
define _bouquet				smallint;
define _serie				smallint;
define _tipo2				smallint;
define _flag				smallint;
define _cnt					smallint;
define _cnt_documento		smallint;
define _cant_pol			integer;
define _renglon				integer;
define _error				integer;
define _fecha				date;	
define _suma_asegurada      dec(16,2);
define _no_documento		char(20);
define _terremoto           smallint;
define _flag2               integer;
define _cv_suma_asegurada   dec(16,2);

--SET DEBUG FILE TO "sp_rea22a.trc"; 
--trace on;

set isolation to dirty read;

let v_descr_cia  = sp_sis01(a_compania);
let v_acumulada = '0.00';
let v_acumulado = '0.00';
let _cant_pol = 0;
let _terremoto = 0;

let _borderaux = a_tipo_bx;   -- BOUQUET,CUOTA PARTE ACC PERS, VIDA, FACILIDAD CAR
let _periodo1 = a_periodo1;

select tipo 
  into _tipo2 
  from reacontr 
 where cod_contrato = _borderaux;

call sp_rea002(a_periodo2,_tipo2) returning _anio_reas,_trim_reas;

if a_periodo2 = '2013-09' then
	let _periodo1 = '2008-01';
end if
	
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
			let a_codramo = "002;";
		end if
	end if
end if
 
 if a_periodo2 >= '2013-07' then
	-- Cargar los valores de devolucion de primas	  Crea tabla temp_det  (temporal)
	call sp_rea22d(a_compania,a_agencia,_periodo1,a_periodo2,a_codsucursal,a_codgrupo,a_codagente,a_codusuario,
					a_codramo,a_reaseguro,a_serie,_borderaux,a_subramo) 
	returning _error,_error_desc;
	
	if _error = 1 then
		drop table temp_produccion;
		RETURN	2;
	end if
	
	select * 
	  from temp_produccion
	  into temp temp_devpri;
	
	drop table temp_produccion;
end if
 
 --//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
 
 CALL sp_pro307(a_compania,a_agencia,a_periodo1,a_periodo2,a_codsucursal,a_codgrupo,
			   a_codagente,a_codusuario,a_codramo,a_reaseguro) RETURNING v_filtros;

{ CALL sp_pro314(a_compania,a_agencia,a_periodo1,a_periodo2,a_codsucursal,a_codgrupo,
			   a_codagente,a_codusuario,a_codramo,a_reaseguro) RETURNING v_filtros;}

create temp table tmp_ramos(
cod_ramo		char(3),
cod_sub_tipo	char(3),
porcentaje		smallint default 100,
primary key(cod_ramo, cod_sub_tipo)) with no log;

/*Temporal para guardar los numeros de documentos.*/
create temp table tmp_no_documento(
no_documento		char(20),
suma_asegurada      dec(16,2),
primary key(no_documento,suma_asegurada)) with no log;
/*
create temp table tmp_documento(
no_documento		char(20),
suma_asegurada      dec(16,2)) with no log;*/
/**/

create temp table temp_produccion(
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
create index idx10_temp_produccion on temp_produccion(seleccionado);
create index idx11_temp_produccion on temp_produccion(cod_ramo,no_poliza,seleccionado);
create index idx12_temp_produccion on temp_produccion(cod_ramo,no_poliza);

create temp table temp_fact(
no_poliza		char(10),
no_endoso		char(5),
no_factura		char(10),
seleccionado	smallint  default 1,
suma_asegurada	dec(16,2),	
sum_ret			dec(16,2) default 0,
sum_cont		dec(16,2) default 0,
sum_fac			dec(16,2) default 0,
sum_fac_car		dec(16,2) default 0,
primary key (no_poliza,no_endoso,no_factura)) with no log;

   {  CREATE TEMP TABLE tmp_priret
               (cod_ramo         CHAR(3),
			    prima_sus_tot    DEC(16,2),
				prima            DEC(16,2),
				prima_sus_t      DEC(16,2)) WITH NO LOG;	}

let _cod_subramo = "001";
let _porc_comis_ase = 0;
let _prima_tot_ret = 0;
let _prima_sus_tot = 0;
let _p_sus_tot_sum = 0;
let _sum_fac_car = 0;
let _p_sus_tot = 0;
let _tipo_cont = 0;
let v_filtros2 = "";
let v_filtros1 = "";
let v_prima = 0;

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

foreach
	select no_poliza,
		   no_endoso,
		   prima_neta,   -- sum(z.prima_neta),
		   vigencia_inic, -- min(z.vigencia_inic)
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
--		  group by 1,2

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
			let _tipo_cont = 1;
		end if

		let v_prima1 = v_prima_cobrada * (_porc_partic_prima / 100) * (_porc_proporcion / 100);
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
								_cod_coasegur);
					else						   
						UPDATE temp_produccion
						   SET prima         = prima + _monto_reas,
							   comision      = comision  + _comision,
							   impuesto      = impuesto  + _impuesto,
							   por_pagar     = por_pagar + _por_pagar
						 WHERE cod_ramo      = v_cod_ramo
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
						_cod_coasegur);
			else			   
				update temp_produccion
				   set prima			= prima     + _monto_reas,
					   comision			= comision  + _comision,
					   impuesto 		= impuesto  + _impuesto,
					   por_pagar     	= por_pagar + _por_pagar
				 where cod_ramo      = v_cod_ramo
				   and cod_subramo   = _cod_subramo
				   and cod_origen    = _cod_origen
				   and cod_contrato  = v_cod_contrato
				   and cod_cobertura = v_cobertura
				   and desc_cob      = v_desc_cobertura
				   and no_poliza     = v_nopoliza;
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
							'999');
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
					  -- and no_unidad      = _no_unidad
						
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
								_cod_coasegur);
					else
						update temp_produccion
						   set prima    		= prima     + _monto_reas,
							   comision  		= comision  + _comision,
							   impuesto  		= impuesto  + _impuesto,
							   por_pagar 		= por_pagar + _por_pagar
						 where cod_ramo  	 = v_cod_ramo
						   and cod_subramo	 = _cod_subramo
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
end foreach
-- Devolucion de Prima
if a_periodo2 >= '2013-07' then
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
			   cod_coasegur,
			   serie,
			   no_poliza
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
			   _cod_coasegur,
			   _serie,
			   v_nopoliza
		  from temp_devpri
		 where seleccionado = 1
		
		let _monto_reas = _monto_reas * -1;
		let _comision	= _comision * -1;
		let _impuesto	= _impuesto * -1; 		  
		let _por_pagar	= _por_pagar  * -1;
		
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
		   and no_poliza = v_nopoliza;

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
					_cod_coasegur
					);
		else	   
			update temp_produccion
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
			   and serie         = _serie
			   and no_poliza     = v_nopoliza;
		end if
	end foreach
end if
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
let v_filtros = trim(v_filtros1)||" "|| trim(v_filtros);

-- tabla de ramos:
foreach
	select distinct cod_ramo
	  into v_cod_ramo
	  from temp_produccion
	 where seleccionado = 1

	if v_cod_ramo in ("001", "003") then
		if v_cod_ramo in ("001") then
			let _t_ramo = "1";
		elif v_cod_ramo in ("003") then
			let _t_ramo = "3";
		end if

		begin
			on exception in(-239)
			end exception

		    --let v_cod_tipo = "in"||_t_ramo;
			let v_cod_tipo = v_cod_ramo;
			
			insert into tmp_ramos (cod_ramo,cod_sub_tipo,porcentaje)
			values (v_cod_ramo,v_cod_tipo,100);
			--values (v_cod_ramo,v_cod_tipo,70);

		end
     else
		insert into tmp_ramos (cod_ramo,cod_sub_tipo,porcentaje)
		values (v_cod_ramo,v_cod_ramo,100);
     end if	   	
end foreach

let v_filtros = trim(v_filtros)||" "|| trim(v_filtros2);
--************************************************************************************************++++++++++++++++++++++++++
foreach
	select cod_ramo,		  --se busca por polizas
		   no_poliza,
		   sum(prima)
	  into v_cod_ramo,
		   v_nopoliza,
		   v_prima
	  from temp_produccion
	 where seleccionado = 1
     group by cod_ramo, no_poliza
     order by cod_ramo, no_poliza

	select no_documento
	  into _no_documento
	  from emipomae
	 where no_poliza    = v_nopoliza
	   and cod_compania = "001"
	   and actualizado  = 1;
	   
	let _no_poliza_vigente = sp_sis21(_no_documento);   

	let v_prima_tipo = 0;
		
	select suma_asegurada
	  into v_suma_asegurada
	  from emipomae
	 where actualizado = 1
       and no_poliza   = _no_poliza_vigente;

	let _flag2     = 0;	

	foreach					 -- se desglosa por tipo, buscar primero si es bouquet
		select cod_contrato,
			   cod_cobertura,
			   tipo,
			   cod_coasegur,
			   serie,
			   sum(prima)
		  into v_cod_contrato,
		       v_cobertura,
			   _tipo_cont,
			   _cod_coasegur,
			   _serie,
			   v_prima_tipo
		  from temp_produccion
		 where cod_ramo  = v_cod_ramo
		   and no_poliza = v_nopoliza 
		   and seleccionado = 1
		 group by cod_contrato,cod_cobertura,tipo,cod_coasegur,serie 
		 order by cod_contrato,cod_cobertura,tipo,cod_coasegur,serie  

		let _flag = 0;
		let _cnt = 0;
		let _sum_fac_car = 0;
		let v_prima_bq = 0;
		let v_prima_ot = 0;
		let v_prima_1  = 0;
		let v_prima_3  = 0;
		let _cv_suma_asegurada = 0;	

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

		if _bouquet = 1 and _serie >= 2008 then --and _cod_coasegur in ('050','063','076','042','036','089') then	   -- condiciones del borderaux bouquet
			if _facilidad_car = 0 then
				let _cnt = 0;
			end if

			if _cnt = 0 then
				let _flag = 1;
			end if
		end if

		if _flag = 1 then
			if _facilidad_car = 1 then 
			--if v_cod_contrato = "00574" or v_cod_contrato = "00584" or v_cod_contrato = "00594" or v_cod_contrato = "00604" then
				let _sum_fac_car = _sum_fac_car + v_prima_tipo;
			else
				let v_prima_bq = v_prima_bq + v_prima_tipo ;
			end if
		else
			if _tipo_cont = 2 or _tipo_cont = 1 then
				if _tipo_cont = 1 then		--	retencion
					let v_prima_1 = v_prima_1 + v_prima_tipo ;
				end if
				if _tipo_cont = 2 then		--  facultativos
					let v_prima_3 = v_prima_3 + v_prima_tipo ;
				end if
			else
				if _facilidad_car = 1 then 	
					let _sum_fac_car = _sum_fac_car + v_prima_tipo;
				else
					let v_prima_ot = v_prima_ot + v_prima_tipo ;		
				end if
			end if
		end if
		
		select count(*)
		  into _terremoto
		  from reacobre
		 where cod_ramo   = v_cod_ramo
		   and cod_cober_reas = v_cobertura
		   and es_terremoto = 1;

		if _terremoto = 0 then
			let v_prima = v_prima_tipo;		
		else
			let v_prima = 0;    -- Sin prima de cobertura terremoto Henry:11/05/2016
		end if		

		let v_prima_tipo = 0;
		
		if _flag2 = 0 then
			 let _cv_suma_asegurada = v_suma_asegurada;
		else
			let _cv_suma_asegurada = 0;
		end if
		
	--end foreach

		select parinfra.rango1, 
			   parinfra.rango2
		  into v_rango_inicial,
			   v_rango_final
		  from parinfra
		 where parinfra.cod_ramo = v_cod_ramo
		   and parinfra.rango1 <= v_suma_asegurada	   -- prima   -- se quito el argumento de prima cobrada, solicitud inicial.
		   and parinfra.rango2 >= v_suma_asegurada;

		if v_rango_inicial is null then
			let v_rango_inicial = 0;	

			select rango2
			  into v_rango_final
			  from parinfra
			 where cod_ramo = v_cod_ramo
			   and parinfra.rango1 = v_rango_inicial;
		end if;

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

			if v_cod_tipo in ('001','003') then
				if v_cobertura in ('021','022') then
					continue foreach;
				end if
				
				let v_desc_ramo = Trim(v_desc_ramo)||"-INCENDIO";
			end if
			begin
				on exception in(-239)
					select count(*)
					  into _cnt
					  from tmp_no_documento
					 where no_documento = _no_documento
					   and suma_asegurada >= v_rango_inicial
					   and suma_asegurada <= v_rango_final;
					 
					if _cnt > 0 then
						let _cant_pol = 0;
						let _cv_suma_asegurada = 0;						
					else
						let _cant_pol = 1;
						let _cv_suma_asegurada = v_suma_asegurada;
					end if
				   update tmp_tabla_rea
					  set cant_polizas   = cant_polizas   + _cant_pol,
						  p_cobrada      = p_cobrada      + v_prima * v_porcentaje/100,   	
						  p_retenida     = p_retenida     + v_prima_1 * v_porcentaje/100,	
						  p_bouquet      = p_bouquet      + v_prima_bq * v_porcentaje/100,	
						  p_facultativo  = p_facultativo  + v_prima_3 * v_porcentaje/100,
						  p_otros		 = p_otros        + v_prima_ot * v_porcentaje/100,
						  p_fac_car		 = p_fac_car      + _sum_fac_car * v_porcentaje/100,
						  p_acumulada    = 0.00,
						  cant_polizas1  = 0.00, 					
						  p_cobrada1      = 0.00,    					
						  p_retenida1     = 0.00,   					
						  p_bouquet1      = 0.00,    					
						  p_facultativo1  = 0.00,					
						  p_otros1        = 0.00,
						  p_fac_car1      = 0.00,
						  p_acumulada1    = 0.00,
						  p_suma_asegurada = p_suma_asegurada + _cv_suma_asegurada * v_porcentaje/100
					where cod_ramo        = v_cod_tipo  
					  and rango_inicial   = v_rango_inicial  
					  and rango_final     = v_rango_final;
					  
				end exception
				insert into tmp_tabla_rea(
						cod_ramo,							
						desc_ramo,							
						rango_inicial,					
						rango_final,  					
						cant_polizas, 					
						p_cobrada,    					
						p_retenida,   					
						p_bouquet,    					
						p_facultativo,					
						p_otros,
						p_fac_car,
						p_acumulada,
						cant_polizas1, 					
						p_cobrada1,    					
						p_retenida1,   					
						p_bouquet1,    					
						p_facultativo1,					
						p_otros1,
						p_fac_car1,
						p_acumulada1,
						cant_polizas2,
						p_cobrada2,
						p_retenida2,
						p_bouquet2,
						p_facultativo2,
						p_otros2,
						p_fac_car2,
						p_acumulada2,
						p_filtro,
						p_suma_asegurada,
						no_documento)
				values(	v_cod_tipo, 
						v_desc_ramo, 
						v_rango_inicial, 
						v_rango_final, 
						1, 
						v_prima * v_porcentaje/100,  
						v_prima_1 * v_porcentaje/100, 
						v_prima_bq * v_porcentaje/100, 
						v_prima_3 * v_porcentaje/100, 
						v_prima_ot * v_porcentaje/100,
						_sum_fac_car * v_porcentaje/100,
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
						0.00,
						0.00,
						0.00,
						0.00,
						v_filtros,
						_cv_suma_asegurada * v_porcentaje/100,
						_no_documento
						);
			end 
			let v_prima   = 0; 
			
				select count(*)
				  into _cnt_documento
				  from tmp_no_documento
				 where no_documento   = _no_documento
				   and suma_asegurada = v_suma_asegurada;
				   
				if _cnt_documento = 0 then
					insert into tmp_no_documento(no_documento, suma_asegurada)values(_no_documento,v_suma_asegurada);
				end if
		end foreach
		let _flag2 = _flag2 + 1;
	end foreach
	let v_prima   = 0; 
end foreach

select count(distinct cod_ramo)
  into _cnt
  from tmp_tabla_rea
 where cod_ramo in('001','003');

if _cnt = 2 then
	foreach
		select rango_inicial,
			   sum(p_retenida),
			   sum(p_bouquet),
			   sum(p_facultativo),
			   sum(p_otros), 
			   sum(p_fac_car), 
			   sum(p_cobrada),
			   sum(cant_polizas),
			   sum(p_suma_asegurada)
		  into v_rango_inicial,
			   v_retenida,
			   v_bouquet,
			   v_facultativo,
			   v_otros,
			   v_fac_car,
			   v_cobrada,
			   _cant_pol,
			   _suma_asegurada
		  from tmp_tabla_rea
		 where cod_ramo in('001','003')
		 group by rango_inicial
		 order by rango_inicial

		select count(*)
		  into _cnt
		  from tmp_tabla_rea
		 where cod_ramo      = '001'
		   and rango_inicial = v_rango_inicial;  

		if _cnt > 0 then
			update tmp_tabla_rea
			   set p_retenida    	= v_retenida,
				   p_bouquet	 	= v_bouquet, 
				   p_facultativo 	= v_facultativo,
				   p_otros		 	= v_otros, 
				   p_fac_car	 	= v_fac_car, 
				   p_cobrada	 	= v_cobrada,
				   cant_polizas  	= _cant_pol,
				   p_suma_asegurada = _suma_asegurada
			 WHERE cod_ramo      = '001'  
			   AND rango_inicial = v_rango_inicial;  
		else
			update tmp_tabla_rea
			   set p_retenida    = v_retenida,
				   p_bouquet	 = v_bouquet, 
				   p_facultativo = v_facultativo,
				   p_otros		 = v_otros, 
				   p_fac_car	 = v_fac_car, 
				   p_cobrada	 = v_cobrada,
				   cant_polizas  = _cant_pol,
				   p_suma_asegurada = _suma_asegurada,
				   cod_ramo      = '001'
			 WHERE cod_ramo      = '003'  
			   AND rango_inicial = v_rango_inicial;  

		end if

		delete from tmp_tabla_rea
		 where cod_ramo = '003'
		   and rango_inicial = v_rango_inicial;  
	end foreach
end if

select count(distinct cod_ramo)
  into _cnt
  from tmp_tabla_rea
 where cod_ramo in('010','011','014','013','022');

if _cnt > 1 then

	foreach
		select distinct cod_ramo
		  into v_cod_tipo
		  from tmp_tabla_rea
		 where cod_ramo in('010','011','014','013','022')

	    exit foreach;
	end foreach

	foreach
		select rango_inicial,
			   sum(p_retenida),
			   sum(p_bouquet),
			   sum(p_facultativo),
			   sum(p_otros),
			   sum(p_fac_car),
			   sum(p_cobrada),
			   sum(cant_polizas),
			   sum(p_suma_asegurada)
		  into v_rango_inicial,
			   v_retenida,
			   v_bouquet,
			   v_facultativo,
			   v_otros,
			   v_fac_car,
			   v_cobrada,
			   _cant_pol,
			   _suma_asegurada
		  from tmp_tabla_rea
		 where cod_ramo in('010','011','014','013','022')
		 group by rango_inicial
		 order by rango_inicial

		select count(*)
		  into _cnt
		  from tmp_tabla_rea
		 where cod_ramo      = v_cod_tipo
		   and rango_inicial = v_rango_inicial;  

		if _cnt > 0 then

			update tmp_tabla_rea
			   set p_retenida    	= v_retenida,
				   p_bouquet	 	= v_bouquet, 
				   p_facultativo 	= v_facultativo,
				   p_otros		 	= v_otros, 
				   p_fac_car	 	= v_fac_car, 
				   p_cobrada	 	= v_cobrada,
				   cant_polizas  	= _cant_pol,
				   p_suma_asegurada = _suma_asegurada
			 where cod_ramo      = v_cod_tipo
			   and rango_inicial = v_rango_inicial;
		else
			foreach
				select distinct cod_ramo
				  into v_cod_tipo2
				  from tmp_tabla_rea
				 where cod_ramo in('010','011','014','013','022')
				   and rango_inicial = v_rango_inicial
				exit foreach;
			end foreach

			update tmp_tabla_rea
			   set p_retenida    = v_retenida,
				   p_bouquet	 = v_bouquet, 
				   p_facultativo = v_facultativo,
				   p_otros		 = v_otros, 
				   p_fac_car	 = v_fac_car, 
				   p_cobrada	 = v_cobrada,
				   cant_polizas  = _cant_pol,
				   cod_ramo      = v_cod_tipo,
				   p_suma_asegurada = _suma_asegurada
			 where cod_ramo      = v_cod_tipo2
			   and rango_inicial = v_rango_inicial;
		end if

		delete from tmp_tabla_rea
		 where cod_ramo not in(v_cod_tipo)
		   and cod_ramo in('010','011','014','013','022')
		   and rango_inicial = v_rango_inicial;  
	end foreach
end if

select count(distinct cod_ramo)
  into _cnt
  from tmp_tabla_rea
 where cod_ramo in('015','007');  --RIESGOS VARIOS

if _cnt > 1 then
	foreach
		select distinct cod_ramo
		  into v_cod_tipo
		  from tmp_tabla_rea
		 where cod_ramo in('015','007')

	    exit foreach;
	end foreach

	foreach
		select rango_inicial,
			   sum(p_retenida),
			   sum(p_bouquet),
			   sum(p_facultativo),
			   sum(p_otros),
			   sum(p_fac_car),
			   sum(p_cobrada),
			   sum(cant_polizas),
			   sum(p_suma_asegurada)
		  into v_rango_inicial,
			   v_retenida,
			   v_bouquet,
			   v_facultativo,
			   v_otros,
			   v_fac_car,
			   v_cobrada,
			   _cant_pol,
			   _suma_asegurada
		  from tmp_tabla_rea
		 where cod_ramo in('015','007')
		 group by rango_inicial
		 order by rango_inicial

		select count(*)
		  into _cnt
		  from tmp_tabla_rea
		 where cod_ramo      = v_cod_tipo
		   and rango_inicial = v_rango_inicial;  

		if _cnt > 0 then
			update tmp_tabla_rea
			   set p_retenida    	= v_retenida,
				   p_bouquet	 	= v_bouquet, 
				   p_facultativo 	= v_facultativo,
				   p_otros		 	= v_otros, 
				   p_fac_car	 	= v_fac_car, 
				   p_cobrada	 	= v_cobrada,
				   cant_polizas  	= _cant_pol,
				   p_suma_asegurada = _suma_asegurada
			 where cod_ramo      = v_cod_tipo
			   and rango_inicial = v_rango_inicial;
		else
			foreach
				select distinct cod_ramo
				  into v_cod_tipo2
				  from tmp_tabla_rea
				 where cod_ramo in('015','007')
				   and rango_inicial = v_rango_inicial
				exit foreach;
			end foreach

			update tmp_tabla_rea
			   set p_retenida    	= v_retenida,
				   p_bouquet	 	= v_bouquet, 
				   p_facultativo 	= v_facultativo,
				   p_otros		 	= v_otros, 
				   p_fac_car	 	= v_fac_car, 
				   p_cobrada	 	= v_cobrada,
				   cant_polizas  	= _cant_pol,
				   cod_ramo      	= v_cod_tipo,
				   p_suma_asegurada = _suma_asegurada
			 where cod_ramo      = v_cod_tipo2
			   and rango_inicial = v_rango_inicial;
		end if

		delete from tmp_tabla_rea
		 where cod_ramo not in(v_cod_tipo)
		   and cod_ramo in('015','007')
		   and rango_inicial = v_rango_inicial;
	end foreach
end if

return 1;

drop table if exists temp_produccion;
drop table if exists temp_det;
drop table if exists temp_devpri;
drop table if exists tmp_ramos;
drop table if exists temp_fact;
drop table if exists tmp_no_documento;
end
end procedure;