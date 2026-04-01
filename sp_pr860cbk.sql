------------------------------------------------
--      TOTALES DE PRODUCCION POR             --  
--         CONTRATO DE REASEGURO              --
---  Yinia M. Zamora - octubre 2000 - YMZM	  --
---  Ref. Power Builder - d_sp_pro40		  --
--- Modificado por Armando Moreno 19/01/2002; -- la parte de los tipo de contratos
------------------------------------------------
--execute procedure sp_pr860bk('001','001','2012-07','2012-09',"*","*","*","*","001,003,006,008,010,011,012,013,014,021,022;","*","2012,2011,2010,2009,2008;")

drop procedure sp_pr860c;
create procedure sp_pr860c(
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
	a_tipo_bx		char(2)		default "01")
returning	char(3),
			char(3),
			char(5),
			char(3),
			dec(16,2),
			dec(16,2),
			dec(16,2),
			dec(16,2),
			dec(16,2),
			dec(16,2),
			dec(16,2),
			dec(16,2),
			char(50),
			char(50),
			char(50),
			char(255);

define v_filtros2			char(255);
define v_filtros			char(255);
define v_desc_cobertura		char(100);
define v_desc_contrato		char(50);
define _nombre_coas			char(50);
define _nombre_cob			char(50);
define _nombre_con			char(50);
define v_descr_cia			char(50);
define v_desc_ramo			char(50);
define _cuenta				char(25);
define _no_documento		char(20);
define _no_reclamo			char(10);
define _no_requis			char(10);
define v_nopoliza			char(10);
define _anio_reas			char(9);
define v_cod_contrato		char(5);
define _cod_traspaso		char(5);
define _no_unidad			char(5);
define v_noendoso			char(5);
define _cod_c				char(5);
define _cod_coasegur		char(3);
define _cod_subramo			char(3);
define _cod_origen			char(3);
define v_cobertura			char(3);
define v_cod_ramo			char(3);
define _cod_ramo			char(3);
define v_clase				char(3);
define _xnivel				char(3);
define _borderaux			char(2);
define _tipo				char(1);
define _porc_cont_partic	dec(5,2);
define _porc_proporcion		dec(5,2);
define _porc_cont_terr		dec(5,2);
define _porc_comis_ase		dec(5,2);
define _p_c_partic			dec(5,2);
define _porc_partic_coas	dec(7,4);
define _porc_impuesto4		dec(7,4);
define _porc_comision4		dec(7,4);
define _porc_comisiond		dec(7,4);
define _porc_partic_prima	dec(9,6);
define _prima_tot_ret_sum	dec(16,2);
define _prima_tot_sus_sum	dec(16,2);
define v_prima_suscrita		dec(16,2);
define v_prima_cobrada		dec(16,2);
define _tot_prima_neta		dec(16,2);
define _prima_tot_ret		dec(16,2);
define _prima_sus_tot		dec(16,2);
define _porc_impuesto		dec(16,2);
define _porc_comision		dec(16,2);
define _p_sus_tot_sum		dec(16,2);
define _tot_comision		dec(16,2);
define _tot_impuesto		dec(16,2);
define _pagado_neto			dec(16,2);
define _por_pagar70			dec(16,2);
define _por_pagar30			dec(16,2);
define _siniestro70			dec(16,2);
define _siniestro30			dec(16,2);
define _por_pagar10			dec(16,2);
define _siniestro3			dec(16,2);
define _monto_reas			dec(16,2);
define _siniestro4			dec(16,2);
define _comision70			dec(16,2);
define _comision30			dec(16,2);
define _impuesto70			dec(16,2);
define _impuesto30			dec(16,2);
define _comision10			dec(16,2);
define _impuesto10			dec(16,2);
define _siniestro2			dec(16,2);
define _p_sus_tot			dec(16,2);
define _por_pagar			dec(16,2);
define _siniestro			dec(16,2);
define _porc_inun			dec(16,2);
define _porc_terr			dec(16,2);
define v_prima70			dec(16,2);
define v_prima30			dec(16,2);
define v_prima10			dec(16,2);
define _sini_dif			dec(16,2);
define _impuesto			dec(16,2);
define _comision			dec(16,2);
define _sini_inc			dec(16,2);
define _sini_mul			dec(16,2);
define _sini_bk				dec(16,2);
define v_prima1				dec(16,2);
define v_prima				dec(16,2);
define _tiene_comis_rea		smallint;
define v_tipo_contrato		smallint;
define _tiene_comision		smallint;
define _p_c_partic_hay		smallint;
define _facilidad_car		smallint;
define _contrato_xl			smallint;
define _trim_reas			smallint;
define _tipo_cont			smallint;
define _no_cambio			smallint;
define _traspaso			smallint;
define _cantidad			smallint;
define v_existe				smallint;
define _bouquet				smallint;
define _serie1				smallint;
define _tipo2				smallint;
define _nivel				smallint;
define _serie				smallint;
define _flag				smallint;
define nivel				smallint;
define _cnt3				smallint;
define _cnt2				smallint;
define _ano2				smallint;
define _ano					smallint;
define _cnt					smallint;
define _dt_vig_inic			date;
define _fecha				date;

set isolation to dirty read;

begin

--set debug file to "sp_pr860c.trc";
-- trace on;
let _borderaux = a_tipo_bx;   -- bouquet,cuota parte acc pers, vida, facilidad car

select tipo 
  into _tipo2 
  from reacontr 
 where cod_contrato = _borderaux;
 
call sp_rea002(a_periodo2,_tipo2) returning _anio_reas,_trim_reas;
 
let _contrato_xl = 0; 

select * 
  from temphg
  into temp tmp_temphg;

select * 
  from reacoest
  into temp tmp_reacoest;

if _borderaux = '01' then	--es bouquet y facilidad car  
	delete from tmp_reacoest where anio = _anio_reas and trimestre = _trim_reas and borderaux = _borderaux;  -- Elimina borderaux del trimestre
	delete from tmp_temphg   where anio = _anio_reas and trimestre = _trim_reas and borderaux = _borderaux;  -- Elimina borderaux datos

	if a_codramo = '*' then
		let a_codramo = "001,003,006,008,010,011,012,013,014,021,022;";
	end if
else
	delete from tmp_reacoest
	 where anio = _anio_reas 
	   and trimestre = _trim_reas
	   and borderaux = _borderaux;  -- Elimina borderaux del trimestre
	   
	delete from tmp_temphg   
	 where anio = _anio_reas 
	   and trimestre = _trim_reas 
	   and borderaux = _borderaux;  -- Elimina borderaux datos

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

let _ano        = a_periodo1[1,4];
let v_descr_cia = sp_sis01(a_compania);

call sp_che143(a_compania,a_agencia,a_periodo1,a_periodo2,a_codsucursal,a_codgrupo,   --crea tabla temp_det (temporal)
			   a_codagente,a_codusuario,a_codramo,a_reaseguro) 
returning v_filtros;

create temp table temp_produccion
			(cod_ramo			char(3),
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
primary key(cod_ramo, cod_subramo, cod_origen, cod_contrato, cod_cobertura, desc_cob, serie)) with no log; -- prueba
create index idx1_temp_produccion on temp_produccion(cod_ramo);
create index idx2_temp_produccion on temp_produccion(cod_subramo);
create index idx3_temp_produccion on temp_produccion(cod_origen);
create index idx4_temp_produccion on temp_produccion(cod_contrato);
create index idx5_temp_produccion on temp_produccion(cod_cobertura);
create index idx6_temp_produccion on temp_produccion(desc_cob);
create index idx7_temp_produccion on temp_produccion(cod_coasegur);
create index idx8_temp_produccion on temp_produccion(serie);
       
create temp table tmp_priret
			(cod_ramo		char(3),
			prima_sus_tot	dec(16,2),
			prima			dec(16,2),
			prima_sus_t		dec(16,2)) with no log;

let _cod_subramo	= "001";
let _porc_comis_ase	= 0;
let _p_sus_tot_sum	= 0;
let _prima_tot_ret	= 0;
let _prima_sus_tot	= 0;
let _por_pagar10	= 0;
let _comision10		= 0;
let _impuesto10		= 0;
let _p_sus_tot		= 0;
let _tipo_cont		= 0;
let v_prima10		= 0;
let v_prima			= 0;


--set debug file to "sp_pr860c.trc";
--trace on;

foreach
	select z.no_poliza,
		   z.no_endoso,
		   z.prima,
		   z.vigencia_inic,
		   z.no_factura
	  into v_nopoliza,
		   v_noendoso,
		   v_prima_cobrada,
		   _fecha,
		   _no_requis
	  from temp_det z
	 where z.seleccionado = 1
	   --and no_factura = "507767"

	select cod_ramo,
		   cod_origen,
		   no_documento
	  into v_cod_ramo,
		   _cod_origen,
		   _no_documento
	  from emipomae
	 where no_poliza = v_nopoliza;

	--let v_nopoliza    = v_nopoliza;
	--let _no_documento = _no_documento;

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

	foreach
		select cod_contrato,
			   porc_partic_prima,
			   porc_proporcion,
			   cod_cober_reas
		  into v_cod_contrato,
			   _porc_partic_prima,
			   _porc_proporcion,
			   v_cobertura
		  from chqreaco
		 where no_requis = _no_requis
		   and no_poliza = v_nopoliza
		
		{select cod_contrato,
			   porc_partic_prima
		  into v_cod_contrato,
			   _porc_partic_prima
		  from emireaco
		 where no_poliza      = v_nopoliza
		   and no_unidad      = _no_unidad
		   and no_cambio      = _no_cambio
		   and cod_cober_reas = v_cobertura}

		select traspaso,tiene_comision
		  into _traspaso,_tiene_comision
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
				   and serie = _serie ;

				if _cantidad = 0 then
					INSERT INTO temp_produccion
					VALUES(	v_cod_ramo,
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
							_serie);
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
					let _cantidad	= 0;

					select count(*)
					  into _cantidad
					  from temp_produccion
					 where cod_ramo      = v_cod_ramo
					   and cod_subramo   = _cod_subramo
					   and cod_origen    = _cod_origen
					   and cod_contrato  = v_cod_contrato
					   and cod_cobertura = v_cobertura
					   and desc_cob      = v_desc_cobertura
					   and serie         = _serie;
					
					let _cantidad = 0; --prueba
					
					if _cantidad = 0 then
						insert into temp_produccion
							  values(v_cod_ramo,
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
									 _serie);
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
						   and serie         = _serie;
					end if
				end foreach
			end if
		end if
--end foreach
	end foreach
end foreach

-- Carga Temporal contrato por ramos.
let _ano2 =  a_periodo2[1,4];

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

	let _p_c_partic     = 0;
	let _p_c_partic_hay = 0;
	let _bouquet        = 0;

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
		CONTINUE FOREACH;
	end if

	if _bouquet = 1 and _serie >= 2008 and _cod_coasegur in ('050','063','076','042','036','089') then	   -- Condiciones del Borderaux Bouquet
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
	values	(_cod_coasegur,
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

-- trace on;
-- Carga reacoprs
-- Clasificasion - 1-R.C.G.(006), 2-Incendio (001,003)70%, 3-Terremoto(001,003)30%, 4-Ramos Tecnicos(010,011,014),
--    5-Fianzas(008,080), 6-Acc. Personales(004), 7-Vida Ind/Col(016,019)]

foreach
	select serie,
		   cod_ramo,
		   cod_contrato,
		   cod_cobertura,
		   sum(prima) 
	  into _serie,
		   v_cod_ramo,
		   v_cod_contrato,
		   v_cobertura,
		   v_prima 
	  from tmp_temphg
	 where cod_coasegur in ('050','063','076','042','036','089') 
	   and anio      = _anio_reas
	   and trimestre = _trim_reas
	   and borderaux = _borderaux 
	 group by serie,cod_ramo,cod_contrato,cod_cobertura

	foreach 
		select distinct cod_coasegur,
			   porc_cont_partic,
			   porc_comision,
			   porc_impuesto
		  into _cod_coasegur,
			   _porc_cont_partic,
			   _porc_comision,
			   _porc_impuesto
		  from tmp_temphg
		 Where serie         = _serie
		   and cod_coasegur in  ('050','063','076','042','036','089')
		   and cod_ramo      = v_cod_ramo  
		   and cod_contrato  = v_cod_contrato
		   and cod_cobertura = v_cobertura
		   and anio          = _anio_reas
		   and trimestre     = _trim_reas
		   and borderaux     = _borderaux 

		let _siniestro = 0;

		if _siniestro is null then
		   let _siniestro = 0;
		end if

		if v_cod_ramo = '006' then --Resp. Civil
			let v_clase = '001';  --R.C.G
		end if

		if v_cod_ramo = '001' or v_cod_ramo = '003' then --Inc, Multi
			let v_clase = '002'; --incendio
		end if					

		if v_cod_ramo = '010' or v_cod_ramo = '011' or v_cod_ramo = '012' or v_cod_ramo = '013' or v_cod_ramo = '014' or v_cod_ramo = '022' then
			let v_clase = '004'; --Ramos Tecnicos
		end if

		if v_cod_ramo = '008' or v_cod_ramo = '080' then --Fianzas
			let v_clase = '005';						 --Fianzas
		end if

		if v_cod_ramo = '004' then --Acc. Personales
			let v_clase = '006';  --Acc. Personales
		end if

		if v_cod_ramo = '019' then --Vida Ind.
			let v_clase = '007';  						 --Vida Ind./Colectivo
		end if			
		
		if v_cod_ramo = '016' then --Col. de Vida
			 let v_clase = '012';  						 --Colectivo
		end if
		
		if v_cod_ramo = '002' then --Automovil
			let v_clase = '013';
		end if

		--contrato XL
		select contrato_xl
		  into _contrato_xl
		  from reacoase
		 where cod_contrato   = v_cod_contrato
		   and cod_cober_reas = v_cobertura
		   and cod_coasegur   = _cod_coasegur;

		if _contrato_xl = 1 then
			let _porc_cont_partic = 0;
		end if

		if _porc_comision is null or _porc_comision = 0 then
		   let _porc_comision4 = 0;
		else
		   let _porc_comision4 = _porc_comision/100;
		end if

		if _porc_impuesto is null or _porc_impuesto = 0 then
		   let _porc_impuesto4 = 0;
		else
		   let _porc_impuesto4 = _porc_impuesto/100;
		end if

		let _comision  = v_prima * _porc_comision4;
		let _impuesto  = v_prima * _porc_impuesto4;
		let _por_pagar = v_prima - _comision - _impuesto;

		if _porc_cont_partic < 100 then 
		   let _xnivel = '1';
		else
		   let _xnivel = '2';
		end if			  

		let _porc_terr = 0.30;
		let _porc_inun = 0.00;

		if v_clase = '002' then
			let _comision70 = 0;
			let _comision30 = 0;
			let _comision10 = 0;
			let v_prima10   = 0;

			if _borderaux = '01' and _cod_coasegur = '042' and _serie >= 2012 then
			  let _porc_terr = 0.20;
			  let _porc_inun = 0.10;
			end if

			let v_prima70 = v_prima * 0.70;
			let v_prima30 =	v_prima * _porc_terr;
			let v_prima10 = v_prima * _porc_inun;

			let _impuesto70  = _impuesto * 0.70;
			let _impuesto30  = _impuesto * _porc_terr;
			let _impuesto10  = _impuesto * _porc_inun;
			let _por_pagar70 = _por_pagar * 0.70;
			let _por_pagar30 = _por_pagar * _porc_terr;
			let _por_pagar10 = _por_pagar * _porc_inun;
			let _siniestro70 = _siniestro * 1;
			let _siniestro30 = _siniestro * 0;	 
			let _comision70  = v_prima70 * _porc_comision4 * 1;
			let _comision30  = v_prima30 * _porc_comision4 * 1;
			let _comision10  = v_prima10 * _porc_comision4 * 1;

			if v_cobertura = '021' or v_cobertura = '022' then
				foreach
					select distinct porc_comision
					  into _porc_comision4
					  from reacoase
					 where cod_contrato   = v_cod_contrato
					   and cod_cober_reas in ('001','003')
					   and cod_coasegur = _cod_coasegur
					exit foreach;
				end foreach
				
				let _comision70 = v_prima70 * _porc_comision4 * 1;
			end if

			if 	_cod_coasegur = '063' then
				let _comision30 = v_prima30 * 0.225;
			else
				let _comision30 = v_prima30 * 0.20;
				let _comision10 = v_prima10 * 0.20;
			end if

			let _por_pagar70 = v_prima70 - _comision70 - _impuesto70;
			let _por_pagar30 = v_prima30 - _comision30 - _impuesto30;
			let _por_pagar10 = v_prima10 - _comision10 - _impuesto10;

			if _cod_coasegur = '036' then
				let _comision 	    = 0; 
				let _impuesto 	    = 0; 
				let _por_pagar	    = v_prima; 
				let _comision70 	= 0; 
				let _impuesto70 	= 0; 
				let _por_pagar70	= v_prima70; 
				let _comision30 	= 0; 
				let _impuesto30 	= 0; 
				let _por_pagar30	= v_prima30; 
			end if

			begin
				on exception in(-239)
					update tmp_reacoest
					   set prima      = prima      + v_prima70, 
						   comision   = comision   + _comision70, 
						   impuesto   = impuesto   + _impuesto70, 
						   prima_neta = prima_neta + _por_pagar70, 
						   siniestro  = siniestro  + _siniestro70 
					 where cod_coasegur	 = _cod_coasegur
					   and cod_contrato  = _serie
					   and cod_cobertura = _xnivel
					   and p_partic      = _porc_cont_partic
					   and cod_ramo      = v_cod_ramo 
					   and cod_clase     = '002'
					   and anio          = _anio_reas
					   and trimestre     = _trim_reas
					   and borderaux     = _borderaux;

			end exception 	

			insert into tmp_reacoest
			values (_cod_coasegur,
						v_cod_ramo,
						_serie,
						_xnivel,
						v_prima70, 
						_comision70, 
						_impuesto70, 
						_por_pagar70,
						_siniestro70,
						0,
						0,
						_porc_cont_partic,
						'002',
						_anio_reas,
						_trim_reas,
						_borderaux);
			end
			
			let _porc_cont_terr = 0;

			foreach
				select distinct porc_cont_partic
				  into _porc_cont_terr
				  from reacoase
				 where cod_contrato = v_cod_contrato 
				   and cod_cober_reas in  ('021','022')
				   and cod_coasegur  = _cod_coasegur
				 order by 1 desc
				exit foreach;
			end foreach

			if _porc_cont_terr is null or _porc_cont_terr = 0 then
			else
				begin
					on exception in(-239)
						update tmp_reacoest
						   set prima         = prima      + v_prima30, 
							   comision      = comision   + _comision30, 
							   impuesto      = impuesto   + _impuesto30, 
							   prima_neta    = prima_neta + _por_pagar30, 
							   siniestro     = siniestro  + _siniestro30 
						 where cod_coasegur	 = _cod_coasegur
						   and cod_contrato  = _serie
						   and cod_cobertura = _xnivel
						   and p_partic      = _porc_cont_terr --_porc_cont_partic
						   and cod_ramo      = v_cod_ramo 
						   and cod_clase     = '003' 
						   and anio          = _anio_reas
						   and trimestre     = _trim_reas
						   and borderaux     = _borderaux;

					end exception 	

					insert into tmp_reacoest
					values (_cod_coasegur,
							v_cod_ramo,
							_serie,
							_xnivel,
							v_prima30, 
							_comision30, 
							_impuesto30, 
							_por_pagar30,
							_siniestro30,
							0,
							0,
							_porc_cont_terr, --_porc_cont_partic,
							'003',
							_anio_reas,
							_trim_reas,
							_borderaux);
				end
				
				if _borderaux = '01' and _cod_coasegur = '042' and _serie >= 2012 then
					begin
						on exception in(-239)
							update tmp_reacoest
							   set prima         = prima      + v_prima10, 
								   comision      = comision   + _comision10, 
								   impuesto      = impuesto   + _impuesto10, 
								   prima_neta    = prima_neta + _por_pagar10, 
								   siniestro     = siniestro  + _siniestro30 
							 where cod_coasegur	 = _cod_coasegur
							   and cod_contrato  = _serie
							   and cod_cobertura = _xnivel
							   and p_partic      = _porc_cont_terr --_porc_cont_partic
							   and cod_ramo      = v_cod_ramo 
							   and cod_clase     = '011' 
							   and anio          = _anio_reas
							   and trimestre     = _trim_reas
							   and borderaux     = _borderaux;

						end exception 	

						insert into tmp_reacoest
						values (_cod_coasegur,
								v_cod_ramo,
								_serie,
								_xnivel,
								v_prima10, 
								_comision10, 
								_impuesto10, 
								_por_pagar10,
								_siniestro30,
								0,
								0,
								_porc_cont_terr, --_porc_cont_partic,
								'011',
								_anio_reas,
								_trim_reas,
								_borderaux);
					end
				end if
			end if
		else	 
			if _cod_coasegur = '036' then
				let _comision 	    = 0; 
				let _impuesto 	    = 0; 
				let _por_pagar	    = v_prima; 
				let _comision70 	= 0; 
				let _impuesto70 	= 0; 
				let _por_pagar70	= 0;--v_prima70; 
				let _comision30 	= 0; 
				let _impuesto30 	= 0; 
				let _por_pagar30	= 0;--v_prima30; 
			end if

			select count(*)
			  into _cnt
			  from tmp_reacoest
			 where cod_coasegur	 = _cod_coasegur
			   and cod_contrato  = _serie
			   and cod_cobertura = _xnivel
			   and p_partic      = _porc_cont_partic
			   and cod_ramo      = v_cod_ramo
			   and cod_clase     = v_clase 
			   and anio          = _anio_reas
			   and trimestre     = _trim_reas
			   and borderaux     = _borderaux; 

			if _cnt > 0 then
				update tmp_reacoest
				   set prima         = prima      + v_prima, 
					   comision      = comision   + _comision, 
					   impuesto      = impuesto   + _impuesto, 
					   prima_neta    = prima_neta + _por_pagar, 
					   siniestro     = siniestro  + _siniestro 
				 where cod_coasegur	 = _cod_coasegur
				   and cod_contrato  = _serie
				   and cod_cobertura = _xnivel
				   and p_partic      = _porc_cont_partic
				   and cod_ramo      = v_cod_ramo
				   and cod_clase     = v_clase 
				   and anio          = _anio_reas
				   and trimestre     = _trim_reas
				   and borderaux     = _borderaux;
			else
				insert into tmp_reacoest
				values (_cod_coasegur,
						v_cod_ramo,
						_serie,
						_xnivel,
						v_prima, 
						_comision, 
						_impuesto, 
						_por_pagar,
						_siniestro,
						0,
						0,
						_porc_cont_partic,
						v_clase,
						_anio_reas,
						_trim_reas,
						_borderaux);
			end if
		end if
	end foreach
end foreach		

--evento inundacion para tomar la participacion de la swiss re

--evento inundacion para tomar la participacion de la swiss re en terremoto

Update tmp_reacoest
   set resultado  = prima_neta, 
       participar = (prima_neta ) * (p_partic/100) 
 where anio       = _anio_reas
   and trimestre  = _trim_reas
   and borderaux  = _borderaux;
   
-- filtro por serie
if a_serie <> "*" then
	let v_filtros = trim(v_filtros) ||" Serie "||TRIM(a_serie);
	let _tipo = sp_sis04(a_serie); -- separa los valores del string
end if

if _borderaux = '01' or _borderaux = '06' then
	update tmp_reacoest
	   set borderaux     = '06'
	 where anio          = _anio_reas
	   and trimestre     = _trim_reas
	   and borderaux     = _borderaux
	   and cod_cobertura = 2;

	foreach
		select cod_contrato
		  into _cod_c
		  from tmp_temphg
		 where borderaux = _borderaux
		   and trimestre = _trim_reas
		   and anio      = _anio_reas
		   and cod_cobertura = '014'   --Facilidad car

		select facilidad_car
		  into _facilidad_car
		  from reacomae
		 where cod_contrato = _cod_c;

	    if _facilidad_car = 1 then
			update tmp_temphg
			   set borderaux = '06'
			 where borderaux = _borderaux
			   and trimestre = _trim_reas
			   and anio      = _anio_reas
			   and cod_cobertura = '014'   --Facilidad car
			   and cod_contrato  = _cod_c;
		end if
	end foreach
	
	if _borderaux = '06' then
		delete from tmp_reacoest
		 where borderaux = _borderaux
		   and trimestre = _trim_reas
		   and anio      = _anio_reas
		   and cod_cobertura <> '2';
	end if

	update tmp_reacoest
	   set borderaux     = '09'
	 where anio          = _anio_reas
	   and trimestre     = _trim_reas
	   and borderaux     = _borderaux
	   and cod_clase     = '005'
	   and cod_coasegur  = '042';
end if

if _borderaux = '09' then
	delete from tmp_reacoest
	 where borderaux = _borderaux
	   and trimestre = _trim_reas
	   and anio      = _anio_reas
	   and cod_coasegur  <> '042';
end if

if a_serie = '*' then
	foreach
		select cod_coasegur,
			   cod_clase,
			   cod_contrato,
			   cod_cobertura,
			   p_partic,
			   sum(prima),
			   sum(comision),
			   sum(impuesto),
			   sum(prima_neta),
			   sum(siniestro),
			   sum(resultado),
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
			   _prima_tot_ret,
			   _prima_sus_tot			
		  from tmp_reacoest	
		 where anio      = _anio_reas
		   and trimestre = _trim_reas
		   and borderaux in(_borderaux)
		 group by cod_coasegur,cod_clase,cod_contrato,cod_cobertura,p_partic

	-- Clasificasion - 1-R.C.G.(006), 2-Incendio (001,003)70%,3-Terremoto(001,003)30%,4-Ramos Tecnicos(010,011,014),
	--    5-Fianzas(008,080),6-Acc. Personales(004),7-Vida Ind/Col(016,019)]
	--    modifico: 14/05/2010 solicitado: Omar Wong - Para dividir 7-Vida Individual 8-Colectivo de Vida

		select rearamo.nombre
		  into v_desc_ramo
		  from rearamo  
		 where rearamo.ramo_reas = v_cod_ramo;

		if v_cod_ramo = '001' then
		   let v_desc_ramo = 'R.C.G.';
		end if

		if v_cod_ramo = '002' then
		   let v_desc_ramo = 'Incendio';
		end if

		if v_cod_ramo = '003' then
		   let v_desc_ramo = 'Terremoto';
		end if

		if v_cod_ramo = '004' then
		   let v_desc_ramo = 'Ramos Tecnicos';
		end if

		if v_cod_ramo = '005' then
		   let v_desc_ramo = 'Fianzas';
		end if

		if v_cod_ramo = '006' then
		   let v_desc_ramo = 'Acc. Personales';
		end if

		if v_cod_ramo = '007' then
		   let v_desc_ramo = 'Vida Indindividual';
		end if

		if v_cod_ramo = '012' then
		   let v_desc_ramo = 'Colectivo de Vida';
		end if

		if v_cod_ramo = '011' then
		   let v_desc_ramo = 'Inundación';
		end if

		if _porc_cont_partic = 100 and v_cod_ramo not in ("006","007","008","012") then 
			let v_cobertura = "3";
		end if

		select nombre
		  into v_desc_contrato
		  from emicoase
		 where cod_coasegur = _cod_coasegur;

		if _prima_sus_tot = 0 then
			continue foreach;
		end if

		return	_cod_coasegur,	  --01
				v_cod_ramo,		  --02
				v_cod_contrato,	  --03
				v_cobertura,	  --04
				v_prima, 		  --05
				_comision, 		  --06
				_impuesto, 		  --07
				_por_pagar,		  --08
				_siniestro,		  --09
				_prima_tot_ret,	  --10
				_prima_sus_tot,	  --11
				_porc_cont_partic,--12
				v_desc_ramo,	  --13
				v_desc_contrato,  --14
				v_descr_cia,	  --15
				v_filtros         --16 filtros
				with resume;
	end foreach
else
	if _tipo = "E" then --Excluir serie
		foreach
			select cod_coasegur,
				   cod_clase,
				   cod_contrato,
				   cod_cobertura,
				   p_partic,
				   sum(prima),
				   sum(comision),
				   sum(impuesto),
				   sum(prima_neta),
				   sum(siniestro),
				   sum(resultado),
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
				   _prima_tot_ret,
				   _prima_sus_tot			
			  from tmp_reacoest	
			 where anio      = _anio_reas
			   and trimestre = _trim_reas
			   and borderaux in(_borderaux)
			   and cod_contrato not in (select codigo from tmp_codigos) 
			 group by cod_coasegur,cod_clase,cod_contrato,cod_cobertura,p_partic

	-- Clasificasion - 1-R.C.G.(006), 2-Incendio (001,003)70%,3-Terremoto(001,003)30%,4-Ramos Tecnicos(010,011,014),
	--    5-Fianzas(008,080),6-Acc. Personales(004),7-Vida Ind/Col(016,019)]
	--    modifico: 14/05/2010 solicitado: Omar Wong - Para dividir 7-Vida Individual 8-Colectivo de Vida

			select rearamo.nombre
			  into v_desc_ramo
			  from rearamo  
			 where rearamo.ramo_reas = v_cod_ramo ;

			if v_cod_ramo = '001' then
			   let v_desc_ramo = 'R.C.G.' ;
			end if

			if v_cod_ramo = '002' then
			   let v_desc_ramo = 'Incendio' ;
			end if

			if v_cod_ramo = '003' then
			   let v_desc_ramo = 'Terremoto' ;
			end if

			if v_cod_ramo = '004' then
			   let v_desc_ramo = 'Ramos Tecnicos' ;
			end if

			if v_cod_ramo = '005' then
			   let v_desc_ramo = 'Fianzas' ;
			end if

			if v_cod_ramo = '006' then
			   let v_desc_ramo = 'Acc. Personales' ;
			end if

			if v_cod_ramo = '007' then
			   let v_desc_ramo = 'Vida Individual';
			end if

			if v_cod_ramo = '012' then
			   let v_desc_ramo = 'Colectivo de Vida' ;
			end if

			if v_cod_ramo = '011' then
			   let v_desc_ramo = 'Inundación';
			end if

			if _porc_cont_partic = 100 and v_cod_ramo not in ("006","007","008","012") then 
				let v_cobertura = "3";
			end if

			select nombre
			  into v_desc_contrato
			  from emicoase
			 where cod_coasegur = _cod_coasegur;

			if _prima_sus_tot = 0 then
				continue foreach;
			end if

			return _cod_coasegur,		--01
				   v_cod_ramo,			--02
				   v_cod_contrato,		--03
				   v_cobertura,			--04
				   v_prima,				--05
					_comision,			--06
					_impuesto,			--07
					_por_pagar,			--08
					_siniestro,			--09
					_prima_tot_ret,		--10
					_prima_sus_tot,		--11
					_porc_cont_partic,	--12
					v_desc_ramo,		--13
					v_desc_contrato,	--14
					v_descr_cia,		--15
					v_filtros			--16 filtros
					with resume;
		end foreach
	else
		foreach
			select cod_coasegur,
				   cod_clase,
				   cod_contrato,
				   cod_cobertura,
				   p_partic,
				   sum(prima),
				   sum(comision),
				   sum(impuesto),
				   sum(prima_neta),
				   sum(siniestro),
				   sum(resultado),
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
				   _prima_tot_ret,
				   _prima_sus_tot			
			  from tmp_reacoest	
			 where anio      = _anio_reas
			   and trimestre = _trim_reas
			   and borderaux in(_borderaux)
			   and cod_contrato in (select codigo from tmp_codigos) 
			 group by cod_coasegur,cod_clase,cod_contrato,cod_cobertura,p_partic

	-- Clasificasion - 1-R.C.G.(006), 2-Incendio (001,003)70%,3-Terremoto(001,003)30%,4-Ramos Tecnicos(010,011,014),
	--    5-Fianzas(008,080),6-Acc. Personales(004),7-Vida Ind/Col(016,019)]
	--    modifico: 14/05/2010 solicitado: Omar Wong - Para dividir 7-Vida Individual 8-Colectivo de Vida

			select rearamo.nombre
			  into v_desc_ramo
			  from rearamo  
			 where rearamo.ramo_reas = v_cod_ramo ;

			if v_cod_ramo = '001' then
			   let v_desc_ramo = 'R.C.G.' ;
			end if

			if v_cod_ramo = '002' then
			   let v_desc_ramo = 'Incendio' ;
			end if

			if v_cod_ramo = '003' then
			   let v_desc_ramo = 'Terremoto' ;
			end if

			if v_cod_ramo = '004' then
			   let v_desc_ramo = 'Ramos Tecnicos' ;
			end if

			if v_cod_ramo = '005' then
			   let v_desc_ramo = 'Fianzas' ;
			end if

			if v_cod_ramo = '006' then
			   let v_desc_ramo = 'Acc. Personales' ;
			end if

			if v_cod_ramo = '007' then
			   let v_desc_ramo = 'Vida Individual';
			end if

			if v_cod_ramo = '012' then
			   let v_desc_ramo = 'Colectivo de Vida' ;
			end if

			if v_cod_ramo = '011' then
			   let v_desc_ramo = 'Inundación';
			end if

			if _porc_cont_partic = 100 and v_cod_ramo not in ("006","007","008","012") then
				let v_cobertura = "3";
			end if

			select nombre
			  into v_desc_contrato
			  from emicoase
			 where cod_coasegur = _cod_coasegur;

			if _prima_sus_tot = 0 then
				continue foreach;
			end if

			if v_cod_ramo = '011' then
			   let v_cod_ramo = '003';
			end if

			return _cod_coasegur,		--01
				   v_cod_ramo,			--02
				   v_cod_contrato,		--03
				   v_cobertura,	  		--04
				   v_prima,				--05
				   _comision,			--06
				   _impuesto,			--07
				   _por_pagar,			--08
				   _siniestro,			--09
				   _prima_tot_ret,		--10
				   _prima_sus_tot,		--11
				   _porc_cont_partic,	--12
				   v_desc_ramo,			--13
				   v_desc_contrato,		--14 reaseguradora
				   v_descr_cia,			--15
				   v_filtros			--16 filtros
			with resume;
		end foreach
	end if
	drop table tmp_codigos;
end if

drop table temp_produccion;
drop table temp_det;
drop table tmp_priret;
drop table tmp_reacoest;
drop table tmp_temphg;

end
end procedure 