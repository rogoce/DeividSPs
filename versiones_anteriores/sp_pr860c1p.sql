------------------------------------------------
--      TOTALES DE PRODUCCION POR             --  
--         CONTRATO DE REASEGURO              --
---  Yinia M. Zamora - octubre 2000 - YMZM	  --
---  Ref. Power Builder - d_sp_pro40		  --
--- Modificado por Armando Moreno 19/01/2002; -- la parte de los tipo de contratos
------------------------------------------------
--execute procedure sp_pr860c1p('001','001','2013-07','2013-09',"*","*","*","*","001,003,006,008,010,011,012,013,014,021,022;","*","2013,2012,2011,2010,2009,2008;")

drop procedure sp_pr860c1p_t;
create procedure sp_pr860c1p_t(
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
returning	integer,
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
define v_nopoliza			char(10);
define _no_requis			char(10);
define _anio_reas			char(9);
define v_cod_contrato		char(5);
define _cod_contrato		char(5);
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
define _tipo_contrato		smallint;
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
define _no_remesa			char(10);
define _renglon				integer;
define _suma_asegurada		dec(16,2);
define _vigencia_fin		date;
define _no_factura			char(10);

set isolation to dirty read;

begin

--set debug file to "sp_pr860c.trc";
-- trace on;

let _borderaux = a_tipo_bx;   -- bouquet,cuota parte acc pers, vida, facilidad car

drop table if exists tmp_reacoest;
drop table if exists tmp_temphg;

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
			let a_codramo = "002,020,023;";
		end if
	end if
end if

let _ano        = a_periodo1[1,4];
let v_descr_cia = sp_sis01(a_compania);

call sp_che143(a_compania,a_agencia,a_periodo1,a_periodo2,a_codsucursal,a_codgrupo,   --crea tabla temp_det (temporal)
			   a_codagente,a_codusuario,a_codramo,a_reaseguro) 
returning v_filtros;

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
			no_poliza		char(10), 						
			no_documento    char(20),
			no_remesa       char(10),
			renglon         integer,			
primary key( cod_ramo, cod_subramo, cod_origen, cod_contrato, cod_cobertura, desc_cob, serie, no_poliza)) with no log;

create index idx1_temp_produccion on temp_produccion(cod_ramo);
create index idx2_temp_produccion on temp_produccion(cod_subramo);
create index idx3_temp_produccion on temp_produccion(cod_origen);
create index idx4_temp_produccion on temp_produccion(cod_contrato);
create index idx5_temp_produccion on temp_produccion(cod_cobertura);
create index idx6_temp_produccion on temp_produccion(desc_cob);
create index idx7_temp_produccion on temp_produccion(cod_coasegur);
create index idx8_temp_produccion on temp_produccion(serie);
create index idx9_temp_produccion on temp_produccion(no_poliza);

drop table if exists tmp_priret;
create temp table tmp_priret(
cod_ramo		char(3),
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

--set debug file to "sp_pr860c1p.trc";
--trace on;

foreach
	select z.no_poliza,	
           z.no_endoso,	
		   z.prima,
		   z.vigencia_inic,		   
		   z.no_factura,		   	   
		   z.suma_asegurada
	  into v_nopoliza,	
           v_noendoso,	  
		   v_prima_cobrada,
		   _fecha,		   
		   _no_requis,
		   _suma_asegurada
	  from temp_det z
	 where z.seleccionado = 1
	 and z.no_poliza in (select no_poliza from emipomae where no_documento in (select doc_remesa from cobredet where no_remesa =  '1507628'))
	 --  and no_remesa = '1507628'	 
	
	if v_prima_cobrada is null then
		let v_prima_cobrada = 0.00;
	end if
	
	select cod_ramo,
		   cod_origen,
		   no_documento,
		   vigencia_inic,
		   vigencia_final
	  into v_cod_ramo,
		   _cod_origen,
		   _no_documento,
		   _dt_vig_inic,
		   _vigencia_fin
	  from emipomae
	 where no_poliza = v_nopoliza;

{   if _dt_vig_inic < '01/07/2014' then
	  continue foreach;
   end if  	  }

   	if _borderaux = '03' and _dt_vig_inic > '30/06/2014' then
		continue foreach;
	end if

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
		
		if _porc_partic_prima is null then
			let _porc_partic_prima = 0.00;
		end if
		
		if _porc_proporcion is null then
			let _porc_proporcion = 0.00;
		end if
		
		select traspaso,
			   tiene_comision
		  into _traspaso,
			   _tiene_comision
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
				   and serie = _serie 
				   and no_poliza = v_nopoliza;

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
							_serie,
							1,
							v_nopoliza,																				
							_no_documento,
							_no_requis,
							0);
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
					   and serie         = _serie
					   and no_poliza     = v_nopoliza;

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
									 _serie,
									 1,
									 v_nopoliza,																						
									_no_documento,
									_no_requis,
									0);
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
						_porc_comision,
						_porc_impuesto,
						0,
						_cod_coasegur,
						_tiene_comis_rea,
						_serie,
						1,
						v_nopoliza,
						_no_documento,
						_no_requis,
						0);
			else			   
				update temp_produccion
				   set prima		= prima     + _monto_reas,
					   comision		= comision  + _comision,
					   impuesto		= impuesto  + _impuesto,
					   por_pagar	= por_pagar + _por_pagar
				 where cod_ramo			= v_cod_ramo
				   and cod_subramo		= _cod_subramo
				   and cod_origen		= _cod_origen
				   and cod_contrato		= v_cod_contrato
				   and cod_cobertura	= v_cobertura
				   and desc_cob			= v_desc_cobertura
				   and serie         = _serie
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
				   and serie         = _serie
			       and no_poliza     = v_nopoliza;

				if _cantidad = 0 then
					insert into temp_produccion
					values(v_cod_ramo,
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
									 v_desc_cobertura,
									 0,
									 0,
									 0,
									 '999',
									 0,
									 _serie,
									 1,
									 v_nopoliza,
								_no_documento,
								_no_requis,
								0);
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
					 where no_poliza		= v_nopoliza
					   and no_endoso		= v_noendoso
					   and cod_contrato	= v_cod_contrato
					   and cod_cober_reas	= v_cobertura
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
					   and serie         = _serie
			           and no_poliza     = v_nopoliza;

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
									 _serie,
									 1,
									 v_nopoliza,
								_no_documento,
								_no_requis,
								0);
					else
						update temp_produccion
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
						   and serie         = _serie
			               and no_poliza     = v_nopoliza;
					   
					end if
				end foreach
			end if
		end if
--end foreach
	end foreach
end foreach

if a_serie <> "*" then
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

--Traspaso de Cartera para Primas Devueltas 2008-01 - 2013-06
--set debug file to "sp_pr860c.trc";
-- trace on;
--{
if a_periodo2 = '2013-09' and a_tipo_bx = '01' then
	foreach
		select cod_ramo,
			   cod_subramo,
			   cod_origen,
			   cod_cobertura,
			   desc_cob,
			   tipo,
			   cod_coasegur,
			   porc_comision,
			   porc_impuesto,
			   porc_cont_partic,
			   tiene_comision,
			   max(serie),
			   sum(prima),
			   sum(comision),
			   sum(impuesto),
			   sum(por_pagar)
		  into v_cod_ramo,
			   _cod_subramo,
			   _cod_origen,
			   v_cobertura,
			   v_desc_cobertura,
			   _tipo_cont,
			   _cod_coasegur,
			   _porc_comision,
			   _porc_impuesto,
			   _porc_cont_partic,
			   _tiene_comis_rea,
			   _serie1,
			   _monto_reas,
			   _comision, 		 
			   _impuesto, 		  
			   _por_pagar
		  from temp_produccion
		 where seleccionado = 1
		   and cod_ramo in ('001','003','006')
		 group by cod_ramo,cod_subramo,cod_origen,cod_cobertura,desc_cob,tipo,cod_coasegur,porc_comision,porc_impuesto,porc_cont_partic,tiene_comision
		 order by cod_ramo,cod_subramo,cod_origen,cod_cobertura,desc_cob,tipo,cod_coasegur,porc_comision,porc_impuesto,porc_cont_partic,tiene_comision
		 
		update temp_produccion
		   set prima		= _monto_reas,
			   comision		= _comision,
			   impuesto		= _impuesto,
			   por_pagar	= _por_pagar
		 where cod_ramo			= v_cod_ramo
		   and cod_subramo		= _cod_subramo
		   and cod_origen		= _cod_origen
		   and cod_cobertura	= v_cobertura
		   and desc_cob			= v_desc_cobertura
		   and tipo				= _tipo_cont
		   and cod_coasegur		= _cod_coasegur
		   and porc_comision	= _porc_comision
		   and porc_impuesto	= _porc_impuesto
		   and porc_cont_partic	= _porc_cont_partic
		   and tiene_comision	= _tiene_comis_rea
		   and serie			= _serie1;
		
		update temp_produccion
		   set prima		= 0,
			   comision		= 0,
			   impuesto		= 0,
			   por_pagar	= 0
		 where cod_ramo			= v_cod_ramo
		   and cod_subramo		= _cod_subramo
		   and cod_origen		= _cod_origen
		   and cod_cobertura	= v_cobertura
		   and desc_cob			= v_desc_cobertura
		   and tipo				= _tipo_cont
		   and cod_coasegur		= _cod_coasegur
		   and porc_comision	= _porc_comision
		   and porc_impuesto	= _porc_impuesto
		   and porc_cont_partic	= _porc_cont_partic
		   and tiene_comision	= _tiene_comis_rea
		   and serie			<> _serie1;
		
		delete from temp_produccion
		 where prima			= 0
		   and comision			= 0
		   and impuesto			= 0
		   and por_pagar		= 0
		   and cod_ramo			= v_cod_ramo
		   and cod_subramo		= _cod_subramo
		   and cod_origen		= _cod_origen
		   and cod_cobertura	= v_cobertura
		   and desc_cob			= v_desc_cobertura
		   and tipo				= _tipo_cont
		   and cod_coasegur		= _cod_coasegur
		   and porc_comision	= _porc_comision
		   and porc_impuesto	= _porc_impuesto
		   and porc_cont_partic	= _porc_cont_partic
		   and tiene_comision	= _tiene_comis_rea
		   and serie			<> _serie1;
	end foreach
end if
--}
--drop table temp_produccion;
drop table temp_det;
drop table tmp_priret;
drop table tmp_reacoest;
drop table tmp_temphg;

return 0,'';
end
end procedure 