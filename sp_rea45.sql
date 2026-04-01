--------------------------------------------
--   DETALLE DE TOTALES DE PRIMAS COBRADAS  - ESPECIAL CASCO       --
---  Yinia M. Zamora - octubre 2000       -- YMZM
---  Ref. Power Builder - reemplaza sp_pro308
--- Modificado por Armando Moreno 19/01/2002; la parte de los tipo de contratos
--- Modificado por Henry 10/9/2009 filtros requeridos por Sr. Omar Wong
--- Quitar el filtro de rangos.
-- execute procedure sp_rea45('001','001','2017-02','2017-02',"*","*","*","*","001,003;","*","*","2016;","*")
--------------------------------------------
drop procedure sp_rea45;
create procedure sp_rea45(
a_compania		char(3),
a_agencia		char(3),
a_periodo1		char(7),
a_periodo2		char(7),
a_codsucursal	char(255)	default "*",
a_codgrupo		char(255)	default "*",
a_codagente		char(255)	default "*",
a_codusuario	char(255)	default "*",
a_codramo		char(255)	default "*",
a_reaseguro		char(255)	default "*",
a_contrato		char(255)	default "*",
a_serie			char(255)	default "*",
a_subramo		char(255)	default "*",
a_segregar      char(255)   default "*")
returning	char(20),
			date,
			date,
			dec(16,2),
			char(3),
			char(50),
			smallint,
			dec(16,2),
			dec(16,2),
			dec(16,2),
			dec(16,2),
			dec(16,2),
			char(255),
			char(50),
			dec(16,2),
			char(10),
			char(15),
			varchar(50),
			char(50),
			date,
			date,
			varchar(30),  -- ruc
			varchar(50),
			dec(16,2),
			char(15),
			varchar(50),
			integer,
			char(3),
			char(100),
			dec(16,2);  

define v_name_subramo,_name_manzana,_error_desc,_n_contrato		varchar(50);
define v_cedula				 									varchar(30);
define v_filtros,v_filtros2,v_filtros1,vx_filtros				char(255);
define v_desc_cobertura,_n_segregar								char(100);
define v_desc_contrato,_nombre_coas,v_descr_cia,v_desc_ramo		char(50);
define _nombre_cob,_nombre_con,_n_aseg,vx_desc_ramo				char(50);
define _cuenta													char(25);
define _no_documento,_no_doc,vx_no_documento					char(20);
define _res_comprobante,_cod_manzana							char(15);
define _cod_contratante,_no_registro,v_no_recibo,_no_poliza		char(10);
define _no_remesa,v_nopoliza,vx_no_recibo						char(10);
define _periodo1												char(8);
define v_cod_contrato,_cod_traspaso,v_noendoso,_no_unidad		char(5);
define _cod_coasegur,v_cod_subramo,_cod_subramo,v_cobertura		char(3);
define _cod_origen,v_cod_tipo,v_cod_ramo,_cod_segregar			char(3);
define _t_ramo,_tipo											char(1);
define _porc_cont_partic,_porc_proporcion,_porc_comis_ase		dec(5,2);
define _porc_partic_coas										dec(7,4);
define _porc_partic_prima										dec(9,6);
define _prima_tot_ret_sum,_prima_tot_sus_sum,v_prima_suscrita	dec(16,2);
define v_suma_asegurada,v_prima_cobrada,v_rango_inicial			dec(16,2);
define _prima_tot_ret,_porc_impuesto,_porc_comision,_monto_reas dec(16,2);
define _prima_sus_tot,_p_sus_tot_sum,_prima_total,v_rango_final dec(16,2);
define v_prima_tipo,_sum_fac_car,_ret_casco,_por_pagar			dec(16,2);
define _p_sus_tot,v_prima_bq,v_prima_ot,v_prima_3,_impuesto		dec(16,2);
define _comision,v_prima_1,v_prima1,v_prima,_suma_asegurada_cob	dec(16,2);
define _tiene_comis_rea,v_tipo_contratom,_facilidad_car			smallint;
define v_porcentaje,_tipo_cont,_no_cambio,_traspaso,_cantidad   smallint;
define _bouquet,_serie,_valor,_flag,_cnt,vx_cantidad			smallint;
define _error_isam,_sac_notrx,_renglon,_error,vx_cant			integer;
define _fecha_suscripcion,_vigencia_inic,_vigencia_ini			date;
define _vigencia_fin,_vigencia_final,_fecha_recibo,_fecha		date;
define _porc_cobertura      									dec(5,2);
define vx_vigencia_ini,vx_vigencia_fin							date;
define vx_suma_asegurada,vx_ret_casco							dec(16,2);
define vx_cod_ramo												char(3);
define vx_prima,vx_prima_bq,vx_prima_1,vx_prima_3,vx_fac_car	dec(16,2);
define vx_prima_ot												dec(16,2);
define vx_res_comprobante,vx_cod_manzana						char(15);
define vx_n_contrato,vx_descr_cia,vx_name_subramo,vx_name_manzana varchar(50);
define vx_asegurado	char(50);
define vx_fecha_suscripcion,vx_fecha_recibo						date;
define vx_cedula												varchar(30);  
DEFINE _ld_ps_casco,_ld_ps_rctercero,_ld_ps_acc_pers,_ld_ps_gts_med dec(16,2);

--SET DEBUG FILE TO "sp_rea45.trc"; 
--trace on;

drop table if exists tmp_casco_rea;
create temp table tmp_casco_rea(						
	no_documento	    char(20),				
	vigencia_ini	    date,				
	vigencia_fin	    date,				
	suma_asegurada	    dec(16,2),				
	cod_ramo	        char(3),				
	desc_ramo	        char(50),				
	cantidad	        smallint,				
	prima	            dec(16,2),				
	prima_1	            dec(16,2),				
	prima_bq	        dec(16,2),				
	prima_3	            dec(16,2),				
	prima_ot	        dec(16,2),				
	filtros	            char(255),				
	descr_cia	        char(50),				
	fac_car	            dec(16,2),				
	no_recibo	        char(10),				
	res_comprobante	    char(15),				
	n_contrato	        varchar(50),				
	asegurado	        char(50),				
	fecha_suscripcion	date,				
	fecha_recibo	    date,				
	cedula	            varchar(30),  				
	name_subramo	    varchar(50),				
	ret_casco	        dec(16,2),				
	cod_manzana	        char(15),				
	name_manzana	    varchar(50),				
	cant	            integer,				
	cod_segregar        char(3),					
	n_segregar          varchar(100),					
	seleccionado        smallint default 1,
	suma_asegurada_cob  dec(16,2)) with no log;	

set isolation to dirty read;

drop table if exists temp_produccion;
drop table if exists temp_det;
drop table if exists tmp_tabla;
drop table if exists tmp_ramos;
drop table if exists temp_devpri;

begin
on exception set _error, _error_isam, _error_desc 
	return	_no_documento,
			'01/01/1900',
			'01/01/1900',
			0.00,
			'',   
			v_nopoliza,  
			_error,  
			0.00,
			0.00,
			0.00,
			0.00,
			0.00,
			'',
			'',
			0.00,
			'',
			'',
			'',
			'',
			'01/01/1900',
			'01/01/1900',
			'',
			'',
			0.00,
			'',
			_error_desc,
			_error_isam,'','',0.00;
end exception

let _no_documento = '';
let v_nopoliza = '';
let v_descr_cia  = sp_sis01(a_compania);
let _porc_proporcion = 0;
let _suma_asegurada_cob = 0;

let _periodo1 = a_periodo1;

if a_periodo2 >= '2013-07' then		--Proceso de DevoluciÃ³n de Prima
	if _periodo1 <= '2013-09' then
		let _periodo1 = '2008-01';
	end if
	
	-- Cargar los valores de devolucion de primas	  Crea tabla temp_det  (temporal)
	call sp_pr860e1(a_compania,a_agencia,_periodo1,a_periodo2,a_codsucursal,a_codgrupo,a_codagente,a_codusuario,
					a_codramo,a_reaseguro,a_contrato,a_serie,a_subramo)

	returning _error,_error_desc;
	
	if _error = 1 then
		drop table temp_produccion;
		return	'',
				'01/01/1900',
				'01/01/1900',
				0.00,
				'',  
				'',   
				0,  
				0.00,
				0.00,
				0.00,
				0.00,
				0.00,
				'',
				'',
				0.00,
				'',
				'',
				'',
				'',
				'01/01/1900',
				'01/01/1900',
				'',
				'',
				0.00,
				'',
				'',
				0,'','',0.00;
	end if
	create temp table temp_devpri
		(cod_ramo         char(3),
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

call sp_pro307(a_compania,a_agencia,a_periodo1,a_periodo2,a_codsucursal,a_codgrupo,a_codagente,a_codusuario,a_codramo,a_reaseguro)
returning v_filtros;

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
primary key (no_documento,vigencia_ini,vigencia_fin,cod_ramo)) with no log;

let _porc_comis_ase = 0;
let _prima_tot_ret = 0;
let _prima_sus_tot = 0;
let _p_sus_tot_sum = 0;
let _sum_fac_car = 0;
let _p_sus_tot = 0;
let _tipo_cont = 0;
let _sac_notrx = 0;
let _ret_casco = 0;
let v_prima	= 0;
let _cnt = 0;
let v_name_subramo = "";
let _cod_subramo = "001";
let v_no_recibo = "";
let v_filtros1 = "";
let v_filtros2 = "";
let v_cedula = "";
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

let _res_comprobante = "";

foreach
	select no_poliza,
		   no_endoso,
		   prima_neta,
		   vigencia_inic,
		   no_factura,
		   no_documento,
		   no_remesa,
		   renglon
	  into v_nopoliza,
		   v_noendoso,
		   v_prima_cobrada,
		   _fecha,
		   v_no_recibo,
		   _no_doc,
		   _no_remesa,
		   _renglon
	  from temp_det
	 where seleccionado = 1
	
	select count(*)
	  into _cnt
	  from reaexpol
	 where no_documento = _no_doc
	   and activo       = 1;

	if _cnt = 1 then                         --"0110-00406-01" or _no_doc = "0110-00407-01" or _no_doc = "0109-00700-01" then --Estas polizas del Bco Hipotecario no las toman en cuenta.
		continue foreach;
	end if

	select vigencia_final
	  into _vigencia_final
	  from emipomae
	 where no_poliza = v_nopoliza;

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
			let v_prima1 = v_prima_cobrada * _porc_partic_prima / 100;
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
		let _cuenta = sp_sis15("PPRXP", "05", _cod_origen, v_cod_ramo, _cod_subramo);

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
							'999',
							v_no_recibo);
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
								_cod_coasegur,
								v_no_recibo);
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
						_cod_coasegur,
						v_no_recibo);
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
							'999',
							v_no_recibo);
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
								v_no_recibo);
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

let _prima_tot_ret_sum = 0;
let _prima_tot_sus_sum = 0;
let _p_sus_tot_sum = 0;

-- Adicionar filtro contrato y serie
-- Filtro por Contrato

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
					'*');
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
			   and no_poliza		= v_nopoliza;
		end if
	end foreach
end if

if a_contrato <> "*" then
	let v_filtros1 = trim(v_filtros1) ||" Contrato "||TRIM(a_contrato);
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
		elif v_cod_ramo in ("003") then
			let _t_ramo = "3";
		end if

		begin
			on exception in(-239)
			end exception

		    let v_cod_tipo = "IN"||_t_ramo;

			insert into tmp_ramos (cod_ramo,cod_sub_tipo,porcentaje)
			values (v_cod_ramo,v_cod_tipo,100);

		    let v_cod_tipo = "TE"||_t_ramo;

			insert into tmp_ramos (cod_ramo,cod_sub_tipo,porcentaje)
			values (v_cod_ramo,v_cod_tipo,100);
		end
	else
		insert into tmp_ramos (cod_ramo,cod_sub_tipo,porcentaje) 
		values (v_cod_ramo,v_cod_ramo,100); 
	end if
end foreach

foreach
	select cod_ramo,
		   no_poliza,
		   sum(prima)
	  into v_cod_ramo,
		   v_nopoliza,
		   v_prima
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
	  into v_suma_asegurada,
		   _no_documento,
		   _vigencia_ini,
		   _vigencia_fin
	  from emipomae
	 where no_poliza = v_nopoliza
	   and cod_compania = "001"
	   and actualizado  = 1;

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
	
	foreach
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
	end if

	let v_prima_tipo = 0;

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
		 where cod_ramo = v_cod_ramo
		   and no_poliza = v_nopoliza 
		   and seleccionado = 1
		 group by cod_contrato,cod_cobertura,tipo,cod_coasegur,serie 
		 order by cod_contrato,cod_cobertura,tipo,cod_coasegur,serie  

		let _flag = 0;
		let _cnt  = 0;
		
		let _sum_fac_car = 0;
		let v_prima_bq = 0;
		let v_prima_ot = 0;
		let _ret_casco = 0;
		let v_prima_1 = 0;
		let v_prima_3 = 0;

		if v_prima_tipo is null then
			let v_prima_tipo = 0.00;
		end if

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
				let v_prima_bq = v_prima_bq + v_prima_tipo ;
			end if
		else
			if _tipo_cont = 2 or _tipo_cont = 1 then
				if _tipo_cont = 1 then		--	retencion
					if v_cod_ramo in ('002','023') then
						if v_cobertura in ('002','033') then
							let v_prima_1 = v_prima_1 + v_prima_tipo;
						else
							let _ret_casco = _ret_casco + v_prima_tipo;
						end if
					else
						let v_prima_1 = v_prima_1 + v_prima_tipo;
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
		let _prima_total = v_prima_1 + v_prima_bq + v_prima_3 + v_prima_ot + _sum_fac_car + _ret_casco;

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
				if v_cobertura in ('021','022') then
					continue foreach;
				end if
				let v_desc_ramo = trim(v_desc_ramo)||"-INCENDIO";
			elif v_cod_tipo[1,2] = "TE" then
				if v_cobertura in ('001','003') then
					continue foreach;
				end if
				
				let v_desc_ramo = trim(v_desc_ramo)||"-TERREMOTO";
				
			end if
			
			begin
				on exception in(-239)
					update tmp_tabla
					   set cant_polizas = cant_polizas   + 1,
						   p_cobrada = p_cobrada + _prima_total * v_porcentaje/100,   		
						   p_retenida = p_retenida + v_prima_1 * v_porcentaje/100,	
						   p_bouquet = p_bouquet + v_prima_bq * v_porcentaje/100,
						   p_facultativo = p_facultativo  + v_prima_3 * v_porcentaje/100,
						   p_otros = p_otros + v_prima_ot * v_porcentaje/100,
						   p_fac_car = p_fac_car + _sum_fac_car * v_porcentaje/100,
						   p_ret_casco = p_ret_casco + _ret_casco * v_porcentaje/100
					 where no_documento	 = _no_documento
					   and cod_ramo       = v_cod_tipo
					   and vigencia_ini = _vigencia_ini
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
						p_bouquet,    					
						p_facultativo,					
						p_otros,
						p_fac_car,
						no_recibo,
						res_comprobante,
						n_contrato,
						p_ret_casco)
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
						_ret_casco * v_porcentaje/100);
			end
		end foreach
	end foreach
	let v_prima = 0; 
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
		   p_ret_casco 
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
		   _ret_casco
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

	select nombre,
		   trim(cedula)
	  into _n_aseg,
		   v_cedula
	  from cliclien
	 where cod_cliente = _cod_contratante;

	foreach
		select cod_manzana
		  into _cod_manzana
		  from emipouni
		 where no_poliza = _no_poliza
		exit foreach;
	end foreach
	
	let _name_manzana = "";	 
	if _cod_manzana is not null then
		select trim(referencia)
		  into _name_manzana
		  from emiman05
		 where cod_manzana = _cod_manzana;
	end if
	
	let _fecha_recibo = null;

	if v_no_recibo <> '*' then
		foreach
			select fecha
			  into _fecha_recibo
			  from cobredet
			 where no_recibo = v_no_recibo
			exit foreach;
		end foreach
	end if

	
	select trim(nombre)
	  into v_name_subramo
	  from prdsubra
	 where cod_ramo = v_cod_ramo
	   and cod_subramo = v_cod_subramo;

	select count(*)
	  into _cnt
	  from emipouni
	 where no_poliza = _no_poliza;
	 
	let _cod_segregar = '';
	let _n_segregar = '';
	let _porc_cobertura = 0.00;
	
	let vx_no_documento = _no_documento;
	let vx_vigencia_ini = _vigencia_ini;
	let vx_vigencia_fin = _vigencia_fin;
	let vx_suma_asegurada = v_suma_asegurada;
	let vx_cod_ramo = v_cod_ramo;  
	let vx_desc_ramo = v_desc_ramo;   
	let vx_cantidad = _cantidad;  
	let vx_prima = v_prima;  
	let vx_prima_1 = v_prima_1;  
	let vx_prima_bq = v_prima_bq;  
	let vx_prima_3 = v_prima_3;  
	let vx_prima_ot = v_prima_ot; 
	let vx_filtros = v_filtros; 
	let vx_descr_cia = v_descr_cia;
	let vx_fac_car = _sum_fac_car;
	let vx_no_recibo = v_no_recibo;
	let vx_res_comprobante = _res_comprobante;
	let vx_n_contrato = v_desc_contrato;
	let vx_asegurado = _n_aseg;
	let vx_fecha_suscripcion = _fecha_suscripcion;
	let vx_fecha_recibo = _fecha_recibo;
	let vx_cedula = v_cedula;
	let vx_name_subramo = v_name_subramo;
	let vx_ret_casco = _ret_casco;
	let vx_cod_manzana = _cod_manzana;
	let vx_name_manzana = _name_manzana;
	let vx_cant = _cnt;
	
{   prdcober17 tabla suministrada  *** opcional en las polizas donde no exista cobertura A.P. y G. MDS pasan estos 10% a casco osea 90%
1-	Casco     80%
2-	Terceros. 10%
3-	A.P.       5%
4-	G. MDS.    5%
}
	foreach
		select cod_segregar,
		       nombre,
			   porc_cobertura
		  into _cod_segregar,
			   _n_segregar,
			   _porc_cobertura
		  from prdcober17
		 where cod_ramo = v_cod_ramo
		 order by orden	
		
		--Se coloca en comentario, hasta que se defina bien. 04/06/2021  Armando.
		{
		if trim(vx_no_documento) in ('1710-00008-01','1720-00084-01','1712-00005-01','1712-00005-01','1720-00007-01','1720-00007-01','1720-00043-01','1717-00020-01','1711-00008-01',
		                             '1712-00027-01','1712-00027-01','1718-00013-01','1720-00026-01','1719-00023-01','1718-00020-01','1720-00083-01','1720-00031-01') then      
		    if _cod_segregar in ('001') then	--CASCO
			   let _porc_cobertura = 90;	
		    end if		   
		    if _cod_segregar in ('003','004') then	--AP, GMDS
			   continue foreach;
		    end if		   	   
		end if
	    }
		let _ld_ps_casco        = 0;
		let _ld_ps_rctercero    = 0;
		let _ld_ps_acc_pers     = 0;
		let _ld_ps_gts_med      = 0;		
		let _suma_asegurada_cob = 0;
		
		let v_nopoliza = sp_sis21(vx_no_documento);
	
		foreach
			select no_unidad
			  into _no_unidad
			  from emipouni
			 where no_poliza = v_nopoliza

				if _cod_segregar in ('001') then	--CASCO
					foreach			
						SELECT emipocob.limite_1
						  into _ld_ps_casco
						  FROM prdcober, emipocob
						 WHERE prdcober.cod_cobertura = emipocob.cod_cobertura
						   AND ( emipocob.no_poliza = v_nopoliza ) 
						   AND ( emipocob.no_unidad = _no_unidad)	
						   AND (nombre like ('%CASCO%') 
							or nombre like ('%CASCO Y MAQUINARIA%')
							or emipocob.cod_cobertura in ("00486","00495","00504","00505","00520","00664","00811"))			

						exit foreach;
					end foreach
					if _ld_ps_casco is null then
						let _ld_ps_casco = 0;
					end if			   
					let _suma_asegurada_cob = _ld_ps_casco;
				end if
				if _cod_segregar in ('002') then		   
					foreach			
						SELECT emipocob.limite_1
						  into _ld_ps_rctercero
						  FROM prdcober, emipocob
						 WHERE prdcober.cod_cobertura = emipocob.cod_cobertura
						   AND ( emipocob.no_poliza = v_nopoliza ) 
						   AND ( emipocob.no_unidad = _no_unidad)	
						   AND (nombre like ('%RESPONSABILIDAD CIVIL%') 				   
							or nombre like ('%RESPONSABILIDAD CIVIL A TERCEROS%') 
							or emipocob.cod_cobertura in ("00489","00497","00527","00752","01242"))			

						exit foreach;
					end foreach	 	
					if _ld_ps_rctercero is null then
						let _ld_ps_rctercero = 0;
					end if			   
					let _suma_asegurada_cob = _ld_ps_rctercero;
				end if
				if _cod_segregar in ('003') then	
					foreach			
						SELECT emipocob.limite_1
						  into _ld_ps_acc_pers
						  FROM prdcober, emipocob
						 WHERE prdcober.cod_cobertura = emipocob.cod_cobertura
						   AND ( emipocob.no_poliza = v_nopoliza ) 
						   AND ( emipocob.no_unidad = _no_unidad)	
						   AND (nombre like ('%ACCIDENTES PERSONALES%' )			
							or emipocob.cod_cobertura in ("00493","00512","00513"))
				   
						exit foreach;
					end foreach
					if _ld_ps_acc_pers is null then
						let _ld_ps_acc_pers = 0;
					end if			   
					let _suma_asegurada_cob = _ld_ps_acc_pers;
				end if
				if _cod_segregar in ('004') then	
					foreach			
						SELECT emipocob.limite_1
						  into _ld_ps_gts_med
						  FROM prdcober, emipocob
						 WHERE prdcober.cod_cobertura = emipocob.cod_cobertura
						   AND ( emipocob.no_poliza = v_nopoliza ) 
						   AND ( emipocob.no_unidad = _no_unidad)	
						   AND (nombre like ('%GASTOS MEDICOS%' )			
						    or emipocob.cod_cobertura in ("00494","00522"))

						exit foreach;
					end foreach	 	
					if _ld_ps_gts_med is null then
						let _ld_ps_gts_med = 0;
					end if	
					let _suma_asegurada_cob = _ld_ps_gts_med;				   
				end if				   
		end foreach

		insert into tmp_casco_rea
			   (no_documento,
				vigencia_ini,
				vigencia_fin,
				suma_asegurada,
				cod_ramo,
				desc_ramo,
				cantidad,
				prima,
				prima_1,
				prima_bq,
				prima_3,
				prima_ot,
				filtros,
				descr_cia,
				fac_car,
				no_recibo,
				res_comprobante,
				n_contrato,
				asegurado,
				fecha_suscripcion,
				fecha_recibo,
				cedula,
				name_subramo,
				ret_casco,
				cod_manzana,
				name_manzana,
				cant,
				cod_segregar,
				n_segregar,
				seleccionado,
				suma_asegurada_cob
				)
		values
			   (vx_no_documento,
				vx_vigencia_ini,
				vx_vigencia_fin,
				vx_suma_asegurada,    ---vx_suma_asegurada * _porc_cobertura/100, dijo que no segregara S/A 31/05/2021 OWONG
				vx_cod_ramo,
				vx_desc_ramo,
				vx_cantidad,
				vx_prima    * _porc_cobertura/100,
				vx_prima_1  * _porc_cobertura/100,
				vx_prima_bq * _porc_cobertura/100,
				vx_prima_3  * _porc_cobertura/100,
				vx_prima_ot * _porc_cobertura/100,
				vx_filtros,
				vx_descr_cia,
				vx_fac_car  * _porc_cobertura/100,
				vx_no_recibo,
				vx_res_comprobante,
				vx_n_contrato,
				vx_asegurado,
				vx_fecha_suscripcion,
				vx_fecha_recibo,
				vx_cedula,
				vx_name_subramo,
				vx_ret_casco * _porc_cobertura/100,
				vx_cod_manzana,
				vx_name_manzana,
				vx_cant,
			   _cod_segregar,
			   _n_segregar,1,
			   _suma_asegurada_cob);    --vx_suma_asegurada * _porc_cobertura/100 no aplica en suma asegurada muestre la cobertura de emision
	end foreach		
end foreach

-- a_codsegregar   a_segregar
if a_segregar <> "*" then
	let v_filtros = trim(v_filtros) ||" Cobertura: "||trim(a_segregar);
	let _tipo = sp_sis04(a_segregar); -- separa los valores del string

	if _tipo <> "E" then -- incluir los registros
		update tmp_casco_rea
		   set seleccionado = 0
		 where seleccionado = 1
		   and cod_segregar not in(select codigo from tmp_codigos);
	else
		update tmp_casco_rea
		   set seleccionado = 0
		 where seleccionado = 1
		   and cod_segregar in(select codigo from tmp_codigos);
	end if
	drop table tmp_codigos;
end if

-- adicionar condicion de no mostrar polizas sin prima cobrada. Omar 28/05/2021
update tmp_casco_rea
   set seleccionado = 0
 where seleccionado = 1
   and prima = 0;

foreach
	select  no_documento,
			vigencia_ini,
			vigencia_fin,
			suma_asegurada,
			cod_ramo,
			desc_ramo,
			cantidad,
			prima,
			prima_1,
			prima_bq,
			prima_3,
			prima_ot,
			filtros,
			descr_cia,
			fac_car,
			no_recibo,
			res_comprobante,
			n_contrato,
			asegurado,
			fecha_suscripcion,
			fecha_recibo,
			cedula,
			name_subramo,
			ret_casco,
			cod_manzana,
			name_manzana,
			cant,
			cod_segregar,
			n_segregar,
			suma_asegurada_cob
	   into vx_no_documento,
			vx_vigencia_ini,
			vx_vigencia_fin,
			vx_suma_asegurada,
			vx_cod_ramo,
			vx_desc_ramo,
			vx_cantidad,
			vx_prima,
			vx_prima_1,
			vx_prima_bq,
			vx_prima_3,
			vx_prima_ot,
			vx_filtros,
			vx_descr_cia,
			vx_fac_car,
			vx_no_recibo,
			vx_res_comprobante,
			vx_n_contrato,
			vx_asegurado,
			vx_fecha_suscripcion,
			vx_fecha_recibo,
			vx_cedula,
			vx_name_subramo,
			vx_ret_casco,
			vx_cod_manzana,
			vx_name_manzana,
			vx_cant,
			_cod_segregar,
			_n_segregar,
            _suma_asegurada_cob			
	  from tmp_casco_rea 
	 where seleccionado = 1
	 order by cod_segregar,cod_ramo,vigencia_ini

	return	vx_no_documento,
			vx_vigencia_ini,
			vx_vigencia_fin,
			vx_suma_asegurada,
			vx_cod_ramo,
			vx_desc_ramo,
			vx_cantidad,
			vx_prima,
			vx_prima_1,
			vx_prima_bq,
			vx_prima_3,
			vx_prima_ot,
			vx_filtros,
			vx_descr_cia,
			vx_fac_car,
			vx_no_recibo,
			vx_res_comprobante,
			vx_n_contrato,
			vx_asegurado,
			vx_fecha_suscripcion,
			vx_fecha_recibo,
			vx_cedula,
			vx_name_subramo,
			vx_ret_casco,
			vx_cod_manzana,
			vx_name_manzana,
			vx_cant,
			_cod_segregar,
			_n_segregar,
            _suma_asegurada_cob			
			with resume;
end foreach
end
end procedure;