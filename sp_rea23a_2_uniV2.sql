---- Copia del sp_pr999 Federico Coronado ramo incendio
--execute procedure sp_rea23a_uni2v2('001','001','2017-07','2018-03','*','*','*','*','017;','*','*','2017,2016,2015,2014,2013,2012,2011,2010,2009,2008;','001,004;','01')
drop procedure sp_rea23a_uni2v2;
create procedure sp_rea23a_uni2v2(
a_compania		char(03),
a_agencia		char(03),
a_periodo1		char(07),
a_periodo2		char(07),
a_codsucursal	char(255)	default '*',
a_codgrupo		char(255)	default '*',
a_codagente		char(255)	default '*',
a_codusuario	char(255)	default '*',
a_codramo		char(255)	default '*',
a_reaseguro		char(255)	default '*',
a_contrato		char(255)	default '*',
a_serie			char(255)	default '*',
a_subramo		char(255)	default '*',
a_tipo_bx		char(2)		default '01')
returning smallint;


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
define _anio_reas			char(9);
define _periodo1			char(8);
define v_cod_contrato		char(5);
define _cod_traspaso		char(5);
define _no_unidad			char(5);
define v_unidad				char(5);
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
define v_suma_asegurada		dec(16,2);
define _cv_suma_asegurada   dec(16,2);
define _saldo_contrato		dec(16,2);
define v_prima_cobrada		dec(16,2);
define v_rango_inicial		dec(16,2);
define _prima_tot_ret		dec(16,2);
define _prima_sus_tot		dec(16,2);
define _porc_impuesto		dec(16,2);
define _porc_comision		dec(16,2);
define _p_sus_tot_sum		dec(16,2);
define _saldo_reaseg		dec(16,2);
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
define _porc_ter          	dec(16,2);
define _porc_partic_prima	dec(9,6);
define _porc_inc          	dec(9,6);
define _porc_partic_suma	dec(9,6);
define _porc_cober_reas		dec(9,6);
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
define _cnt_existe			smallint;
define _cnt_terr			smallint;
define _no_cambio			smallint;
define _cantidad_uni		smallint;
define _cantidad			smallint;
define _flag_prima			smallint;
define _cnt_reas			smallint;
define _traspaso			smallint;
define _bouquet				smallint;
define _serie				smallint;
define _tipo2				smallint;
define _flag				smallint;
define _cnt					smallint;
define _cant_pol			integer;
define _renglon				integer;
define my_sessionid			integer;
define _error				integer;
define _fecha				date;	
define _suma_asegurada      dec(16,2);
define _no_documento		char(20);
define _terremoto           smallint;
define _cnt_unidad          integer;
define _cnt_documento       smallint;
define _flag2               integer;
define _flag1               integer;
define _no_poliza_vigente   char(10);
define _cod_grupo			char(5);

define _xu_p_cobrada		dec(16,2);
define _xu_p_retenida		dec(16,2);
define _xu_p_bouquet		dec(16,2);
define _xu_p_facultativo	dec(16,2);
define _xu_p_otros			dec(16,2);
define _xu_p_fac_car		dec(16,2);
define _vigencia_inic	    date;
define _vigencia_final	    date;
define _cod_asegurado       char(10); 		 
define _xu_asegurado        varchar(100); 
define _xu_grupo            varchar(100); 	
define _xu_contrato         varchar(100); 	
define _xu_cobertura        varchar(100); 	
define _xu_nombre_ramo      varchar(100); 	
define _xu_nombre_subramo   varchar(100); 
define _porc_coas       dec(7,4);	

define _suma_retencion, _prima_retencion, _prima_cob_retencion    dec(16,2);
define _suma_contratos,	_prima_contratos, _prima_cob_contratos    dec(16,2);
define _suma_facultativos, _prima_facultativos, _prima_cob_facultativos dec(16,2);
define _cod_contrato					 	   char(5);
define _tipo_contrato, _es_terremoto	 	   smallint;
define _suma, _prima 		  			 	   dec(16,2);
define _cod_cober_reas                         char(3);
define _cod_tipoprod	                       char(3);


let _suma_facultativos = 0; 
let _suma_retencion   = 0;
let _suma_contratos   = 0;

let _prima_cob_facultativos = 0; 
let _prima_cob_retencion   = 0;
let _prima_cob_contratos   = 0;

 Drop table if exists tmphg_contratos;
CREATE TEMP TABLE tmphg_contratos
            (no_poliza          CHAR(10),	
			 no_documento       CHAR(20),			 
			 no_unidad          CHAR(5),	
			 tipo_contrato      smallint,
			 cod_cober_reas     CHAR(3),	
			 cod_contrato       CHAR(5),						
             suma_retencion     DEC(16,2),
             suma_contratos     DEC(16,2),
             suma_facultativos  DEC(16,2)
             );
		
--SET DEBUG FILE TO 'sp_rea22a.trc'; 
--trace on;

set isolation to dirty read;

let v_descr_cia  = sp_sis01(a_compania);
let v_acumulada = '0.00';
let v_acumulado = '0.00';
let _cant_pol = 0;
let _terremoto = 0;			
let _xu_p_cobrada      = 0;   	
let _xu_p_retenida     = 0;
let _xu_p_bouquet      = 0;
let _xu_p_facultativo  = 0;
let _xu_p_otros		   = 0;
let _xu_p_fac_car	   = 0;	
let _xu_asegurado      = '';
let _xu_grupo          = '';
let _xu_contrato       = '';
let _xu_cobertura       = '';		   			   			   
let _xu_nombre_ramo = ''; 			   			   			   
let _xu_nombre_subramo = '';  


let _cod_coasegur = sp_sis02(a_compania,a_agencia);

--////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
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

if a_codramo = '*' then
	if _borderaux = '01' then	--es bouquet y facilidad car	  
		let a_codramo = '001,003,006,008,010,011,012,013,014,021,022;';
	elif _borderaux = '06' then
		let a_codramo = '014;';
	elif _borderaux = '08' then
		let a_codramo = '004,016,019;';
	elif _borderaux = '09' then
		let a_codramo = '008;';
	elif _borderaux = '10' then
		let a_codramo = '002;';
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
 
 CALL sp_pro307(a_compania,a_agencia,a_periodo1,a_periodo2,a_codsucursal,a_codgrupo,a_codagente,a_codusuario,a_codramo,a_reaseguro) RETURNING v_filtros;
create temp table tmp_ramos(
cod_ramo		char(3),
cod_sub_tipo	char(3),
porcentaje		smallint default 100,
primary key(cod_ramo, cod_sub_tipo)) with no log;

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
no_unidad		 char(5),
cod_coasegur 	 char(3),
primary key(cod_ramo, cod_subramo, cod_origen, cod_contrato, cod_cobertura, desc_cob, no_poliza,no_unidad)) with no log;
create index idx1_temp_produccion on temp_produccion(cod_ramo);
create index idx2_temp_produccion on temp_produccion(cod_subramo);
create index idx3_temp_produccion on temp_produccion(cod_origen);
create index idx4_temp_produccion on temp_produccion(cod_contrato);
create index idx5_temp_produccion on temp_produccion(cod_cobertura);
create index idx6_temp_produccion on temp_produccion(desc_cob);
create index idx7_temp_produccion on temp_produccion(no_poliza);
create index idx8_temp_produccion on temp_produccion(serie);
create index idx9_temp_produccion on temp_produccion(cod_coasegur);

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

/*Temporal para guardar los numeros de documentos.*/  ---tmp_doc_rea
create temp table tmp_no_documento(
no_documento		char(20),
suma_asegurada      dec(16,2),
no_unidad           char(5),
primary key(no_documento,suma_asegurada,no_unidad)) with no log;


let _cod_subramo = '001';
let _porc_comis_ase = 0;
let _prima_tot_ret = 0;
let _prima_sus_tot = 0;
let _p_sus_tot_sum = 0;
let _sum_fac_car = 0;
let _p_sus_tot = 0;
let _tipo_cont = 0;
let v_filtros2 = '';
let v_filtros1 = '';
let v_prima = 0;

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

let my_sessionid = DBINFO('sessionid');

foreach
	select no_poliza,
		   no_endoso,
		   no_documento,
		   sum(prima_neta)
	  into v_nopoliza,
		   v_noendoso,
		   _no_doc,
		   v_prima_cobrada
	  from temp_det
	 where seleccionado = 1
	 group by no_poliza,no_endoso,no_documento
	 order by no_poliza,no_documento
	   

	select count(*)
	  into _cnt
	  from reaexpol
	 where no_documento = _no_doc
	   and activo       = 1;

	if _cnt = 1 then                         --'0110-00406-01' or _no_doc = '0110-00407-01' or _no_doc = '0109-00700-01' then --Estas polizas del Bco Hipotecario no las toman en cuenta.
		continue foreach;
	end if
	
	let v_nopoliza = sp_sis21c(_no_doc);

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
	   and cod_coasegur = '036'; 			

	if _porc_partic_coas is null then
		let _porc_partic_coas = 100;
	end if

	let v_prima_cobrada = v_prima_cobrada * _porc_partic_coas / 100;
	
	delete from fic_emireaco where session_id = my_sessionid;

	foreach
		select distinct no_unidad
		  into _no_unidad
		  from emipouni
		 where no_poliza = v_nopoliza

		let _no_cambio = null;

		select max(no_cambio)
		  into _no_cambio
		  from emireaco
		 where no_poliza = v_nopoliza
		   and no_unidad = _no_unidad;

		if _no_cambio is null then
			return 1;
			--continue foreach;
		end if
		
		begin
			on exception in(-239,-268)
			end exception

			insert into fic_emireaco
			select distinct e.*,r.es_terremoto,my_sessionid
			  from emireaco e, reacocob c, reacobre r
			 where e.cod_contrato = c.cod_contrato
			   and e.cod_cober_reas = c.cod_cober_reas
			   and e.cod_cober_reas = r.cod_cober_reas
			   and r.cod_ramo = v_cod_ramo
			   and e.no_poliza = v_nopoliza
			   and e.no_unidad = _no_unidad
			   --and c.bouquet = 1
			   and e.no_cambio >= (select max(no_cambio) from emireaco where no_poliza = v_nopoliza and no_unidad = _no_unidad);
		end
	end foreach

	if v_cod_ramo in ('001', '003') then

		foreach
			select cod_cober_reas
			  into _cod_cober_reas
			  from reacobre
			 where cod_ramo = v_cod_ramo
			   and es_terremoto = 1
			 order by 1
			exit foreach;
		end foreach

		--let _partic_reas_acum = 0.00;
		foreach
			select distinct no_unidad,
				   cod_contrato,
				   no_cambio
			  into _no_unidad,
				   _cod_contrato,
				   _no_cambio
			  from fic_emireaco
			 where no_poliza = v_nopoliza
			   and session_id = my_sessionid
			 order by no_unidad, cod_contrato
		   
			if v_cod_ramo = '001' then
				let _porc_inc = .70;
				let _porc_ter = .30;		
			else
				let _porc_inc = .90;
				let _porc_ter = .10;
			end if

			select count(*)
			  into _cnt_existe
			  from reacocob c, reacobre r
			 where c.cod_cober_reas = r.cod_cober_reas
			   and c.cod_contrato = _cod_contrato
			   and r.cod_ramo = v_cod_ramo
			   and es_terremoto = 1;

			if _cnt_existe is null then			   
				let _cnt_existe = 0;
			end if

			if _cnt_existe > 0 then
				if v_cod_ramo = '001' then
					let _porc_inc = .70;
					let _porc_ter = .30;		
				else
					let _porc_inc = .90;
					let _porc_ter = .10;
				end if
			end if

			select count(*)
			  into _cnt_terr
			  from fic_emireaco
			 where no_poliza = v_nopoliza
			   and no_unidad = _no_unidad
			   and cod_cober_reas = _cod_cober_reas
			   and cod_contrato   = _cod_contrato
			   and no_cambio      = _no_cambio
			   and session_id = my_sessionid;

			if _cnt_terr is null then			   
				let _cnt_terr = 0;
			end if

			if _cnt_terr = 0 and _cnt_existe > 0 then

				let _serie = 0;
				select serie
				  into _serie
				  from reacomae
				 where cod_contrato = _cod_contrato;
			
				if _serie >= 2015 and _serie < 2018 then
					let _porc_partic_prima = 100;
				else
					foreach
						select porc_partic_prima
						  into _porc_partic_prima
						  from emireaco 
						 where no_poliza = v_nopoliza
						   and no_unidad = _no_unidad
						   and cod_contrato = _cod_contrato
						   and no_cambio = _no_cambio
						exit foreach;
					end foreach
				end if

				begin
				on exception in(-239,-268)
				end exception

					insert into fic_emireaco(no_poliza,no_unidad,no_cambio,cod_cober_reas,orden,cod_contrato,porc_partic_prima,porc_partic_suma,es_terremoto,session_id)
					select no_poliza,
						   no_unidad,
						   no_cambio,
						   _cod_cober_reas,
						   orden,
						   _cod_contrato,
						   _porc_partic_prima, --100,--
						   _porc_partic_prima, --100,--
						   1,
						   my_sessionid
					  from emireaco 
					 where no_poliza = v_nopoliza
					   and no_unidad = _no_unidad
					   and cod_contrato = _cod_contrato
					   and no_cambio = _no_cambio;
				end
				--end if
			elif _cnt_terr = 0 and _cnt_existe = 0 then
				--let _porc_inc = 1;
			end if
			
			update fic_emireaco
			   set porc_partic_prima  = porc_partic_prima * _porc_inc
			 where no_poliza = v_nopoliza
			   and no_unidad = _no_unidad
			   and cod_contrato = _cod_contrato
			   and no_cambio = _no_cambio
			   and es_terremoto = 0
			   and session_id = my_sessionid;
			
			update fic_emireaco
			   set porc_partic_prima  = porc_partic_prima * _porc_ter
			 where no_poliza = v_nopoliza
			   and no_unidad = _no_unidad
			   and cod_contrato = _cod_contrato
			   and no_cambio = _no_cambio
			   and es_terremoto = 1
			   and session_id = my_sessionid;
		end foreach
	end if			

	let _saldo_contrato = 0;
	let _cantidad_uni   = 0;
	let _flag_prima   = 0;
	if v_nopoliza = '1246091' then
		delete from fic_emireaco
		 where no_poliza = '1246091'
		   and no_unidad = '00001'
		   and cod_cober_reas = '021'
		   and cod_contrato   = '00688'
		   and session_id = my_sessionid;
	end if
	if v_nopoliza = '1224548' then
		delete from fic_emireaco
		 where no_poliza = '1224548'
		   and no_unidad in('00001','00002')
		   and cod_cober_reas = '021'
		   and cod_contrato   = '00688'
		   and session_id = my_sessionid;
	end if
	if v_nopoliza = '0001229067' then
		delete from fic_emireaco
		 where no_poliza = '0001229067'
		   and no_unidad = '00001'
		   and session_id = my_sessionid;
	end if
	foreach
		select no_unidad
		  into _no_unidad
		  from fic_emireaco
		 where no_poliza = v_nopoliza
		   and session_id = my_sessionid
		 group by no_unidad   

		select sum(r.prima)
		  into _saldo_reaseg
		  from emifacon r, endedmae e
		 where r.no_poliza = e.no_poliza
		   and r.no_endoso = e.no_endoso
		   and r.no_poliza = v_nopoliza
		   and r.no_unidad = _no_unidad
		   and cod_endomov not in ('002','003');

		if _saldo_reaseg is null then 
			let _saldo_reaseg = 0;
		end if

		if _saldo_reaseg <> 0 then
			let _flag_prima = 1;
		end if
		
		let _saldo_contrato = _saldo_contrato + _saldo_reaseg;
		let _cantidad_uni   = _cantidad_uni   + 1;			
	end foreach
	let _saldo_contrato = _saldo_contrato;
	foreach
		select no_unidad
		  into _no_unidad
		  from fic_emireaco
		 where no_poliza = v_nopoliza
		   and session_id = my_sessionid
		 group by no_unidad   

		select sum(r.prima)
		  into _saldo_reaseg
		  from emifacon r, endedmae e
		 where r.no_poliza = e.no_poliza
		   and r.no_endoso = e.no_endoso
		   and r.no_poliza = v_nopoliza
		   and r.no_unidad = _no_unidad
		   and cod_endomov not in ('002','003');

		if _saldo_reaseg is null then 
			let _saldo_reaseg = 0;
		end if

		if (_saldo_contrato = 0 and _flag_prima = 0) or abs(_saldo_contrato) < 1 then
			let _porc_partic_suma = (1 / _cantidad_uni) * 100;               -- Por Unidades
		else
			let _porc_partic_suma = (_saldo_reaseg / _saldo_contrato) * 100; -- Por Prima
		end if

		update fic_emireaco
		   set porc_partic_suma = _porc_partic_suma
		 where no_poliza = v_nopoliza
		   and no_unidad = _no_unidad
		   and session_id = my_sessionid;
	end foreach
    --******AUTOMOVIL*********************************************************************
	if v_cod_ramo in ('002','020','023') then
		foreach
			select no_unidad
			  into _no_unidad
			  from fic_emireaco
			 where no_poliza = v_nopoliza
			   and session_id = my_sessionid
			 group by no_unidad   

			drop table if exists tmp_dist_rea;

			call sp_sis188e(v_nopoliza,_no_unidad) returning _error,_error_desc;
			
			delete from fic_emireaco
			 where no_poliza = v_nopoliza
			   and no_unidad = _no_unidad
			   and cod_cober_reas not in (select distinct cod_cober_reas from tmp_dist_rea)
			   and session_id = my_sessionid;

			if v_nopoliza in('1163298','0001286321') then
				delete from tmp_dist_rea
			     where cod_cober_reas = '031';
			end if

			select sum(porc_cober_reas)
			  into _porc_cober_reas
			  from tmp_dist_rea;
			  
			let v_nopoliza = v_nopoliza;
			let _no_unidad = _no_unidad;
			if round(_porc_cober_reas,4) <> 100 then
				update tmp_dist_rea
				   set porc_cober_reas = round((100/_porc_cober_reas),4) * 100
				 where no_poliza = v_nopoliza
				   and no_unidad = _no_unidad;
			end if

			foreach
				select cod_cober_reas,
					   porc_cober_reas
				  into _cod_cober_reas,
					   _porc_partic_suma
				  from tmp_dist_rea
				 where no_poliza = v_nopoliza
				   and no_unidad = _no_unidad

				update fic_emireaco
				   set porc_partic_prima = porc_partic_prima * (_porc_partic_suma/100)
				 where no_poliza        = v_nopoliza
				   and no_unidad        = _no_unidad
				   and cod_cober_reas   = _cod_cober_reas
				   and session_id = my_sessionid;				
			end foreach			
		end foreach		
	end if
	
	foreach
		select cod_contrato,
			   cod_cober_reas,
			   porc_partic_prima,
			   porc_partic_suma,
			   no_unidad,
			   no_cambio
		  into _cod_contrato,
			   _cod_cober_reas,
			   _porc_partic_prima,
			   _porc_partic_suma,
			   _no_unidad,
			   _no_cambio
		  from fic_emireaco
		 where no_poliza = v_nopoliza
		   and session_id = my_sessionid
		 order by no_poliza,no_cambio,no_unidad,cod_cober_reas

		if _cod_cober_reas not in ('021','022') then
			let _cnt_reas = 0;

			select count(*)
			  into _cnt_reas
			  from emifacon r, endedmae e
			 where r.no_poliza = e.no_poliza
			   and r.no_endoso = e.no_endoso
			   and r.no_poliza = v_nopoliza
			   and r.no_unidad = _no_unidad
			   and cod_cober_reas = _cod_cober_reas
			   and cod_endomov not in ('002','003');

			if _cnt_reas is null then
				let _cnt_reas = 0;
			end if
			select tipo_contrato,
				   serie
			  into _tipo_contrato,
				   _serie
			  from reacomae
			 where cod_contrato = _cod_contrato;
			
			if _cnt_reas = 0 and _tipo_contrato <> 1 then
				continue foreach;
			end if
		end if


		select traspaso
		  into _traspaso
		  from reacocob
		 where cod_contrato   = _cod_contrato
		   and cod_cober_reas = _cod_cober_reas;

		select cod_traspaso,
			   tipo_contrato,
			   serie
		  into _cod_traspaso,
			   v_tipo_contrato,
			   _serie
		  from reacomae
		 where cod_contrato = _cod_contrato;

		if _traspaso = 1 then
			let _cod_contrato = _cod_traspaso;
		end if

		let _tipo_cont = 0;

		if v_tipo_contrato = 3 then
			let _tipo_cont = 2;
		elif v_tipo_contrato = 1 then --retencion
			let _tipo_cont = 1;
		end if

		let v_prima1 = v_prima_cobrada * (_porc_partic_prima / 100) * (_porc_partic_suma / 100);
		let v_prima  = v_prima1;

		select nombre,
			   serie
		  into v_desc_contrato,
			   _serie
		  from reacomae
		 where cod_contrato = _cod_contrato;

		let _nombre_con = trim(v_desc_contrato) || ' (' || _cod_contrato || ')' || '  A: ' || _serie;
		let _cuenta     = sp_sis15('PPRXP', '05', _cod_origen, v_cod_ramo, _cod_subramo);

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
		 where cod_contrato   = _cod_contrato
		   and cod_cober_reas = _cod_cober_reas;

		select nombre
		  into _nombre_cob
		  from reacobre
		 where cod_cober_reas = _cod_cober_reas;

		select count(*)
		  into _cantidad
		  from reacoase
		 where cod_contrato   = _cod_contrato
		   and cod_cober_reas = _cod_cober_reas;

		if _tipo_cont = 0 then
			if _cantidad = 0 then
				let v_desc_contrato  = '******* NO EXISTE REGISTRO DE COMPANIAS ' || _cod_contrato;

				select count(*)
				  into _cantidad
				  from temp_produccion
				 where cod_ramo      = v_cod_ramo
				   and cod_subramo   = _cod_subramo
				   and cod_origen    = _cod_origen
				   and cod_contrato  = _cod_contrato
				   and cod_cobertura = _cod_cober_reas
				   and desc_cob      = _nombre_cob
				   and no_unidad     = _no_unidad
				   and no_poliza     = v_nopoliza;

				if _cantidad = 0 then
					insert into temp_produccion
					values(	v_cod_ramo,
							_cod_subramo,
							_cod_origen,
							_cod_contrato,
							v_desc_contrato,
							_cod_cober_reas,
							v_prima,
							_tipo_cont,
							0, 
							0, 
							0,
							_nombre_cob,
							_serie,
							1,
							v_nopoliza,
							'00001',
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
					 where cod_contrato   = _cod_contrato
					   and cod_cober_reas = _cod_cober_reas
						
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

					let v_desc_cobertura = '';
					let v_desc_cobertura = trim(_nombre_cob) || '  ' || trim(_cuenta) || '  ' || trim(_nombre_coas);
					let v_desc_contrato  = trim(v_desc_contrato) || '  I:' || _porc_impuesto || '  C:' || _porc_comision;

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
					   and cod_contrato  = _cod_contrato
					   and cod_cobertura = _cod_cober_reas
					   and desc_cob      = v_desc_cobertura
					   and no_poliza     = v_nopoliza
					   and no_unidad 	 = _no_unidad;

					if _cantidad = 0 then
						insert into temp_produccion
						values(	v_cod_ramo,
								_cod_subramo,
								_cod_origen,
								_cod_contrato,
								v_desc_contrato,
								_cod_cober_reas,
								_monto_reas,
								_tipo_cont,
								_comision, 
								_impuesto, 
								_por_pagar,
								v_desc_cobertura,
								_serie,
								1,
								v_nopoliza,
								_no_unidad,
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
						   and cod_contrato  = _cod_contrato
						   and cod_cobertura = _cod_cober_reas
						   and desc_cob      = v_desc_cobertura
						   and no_poliza     = v_nopoliza
						   and no_unidad 	 = _no_unidad;
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
			let v_desc_cobertura = '';
			let v_desc_cobertura = trim(_nombre_cob) || '  ' || trim(_cuenta) || '  ' || trim(_nombre_coas);
			let v_desc_contrato  = trim(v_desc_contrato) || '  I:' || _porc_impuesto || '  C:' || _porc_comision;

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
			   and cod_contrato  = _cod_contrato
			   and cod_cobertura = _cod_cober_reas
			   and desc_cob      = v_desc_cobertura
			   and no_poliza     = v_nopoliza
			   and no_unidad 	 = _no_unidad;


			if _cantidad = 0 then

				insert into temp_produccion
				values(	v_cod_ramo,
						_cod_subramo,
						_cod_origen,
						_cod_contrato,
						v_desc_contrato,
						_cod_cober_reas,
						_monto_reas,
						_tipo_cont,
						_comision, 
						_impuesto, 
						_por_pagar,
						v_desc_cobertura,
						_serie,
						1,
						v_nopoliza,
						_no_unidad,
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
				   and cod_contrato  = _cod_contrato
				   and cod_cobertura = _cod_cober_reas
				   and desc_cob      = v_desc_cobertura
				   and no_poliza     = v_nopoliza
				   and no_unidad 	 = _no_unidad;
			end if
		elif _tipo_cont = 2 then  --facultativos

			select count(*)
			  into _cantidad
			  from emifafac
			 where no_poliza      = v_nopoliza
			   and no_endoso      = v_noendoso
			   and cod_contrato   = _cod_contrato
			   and cod_cober_reas = _cod_cober_reas
			   and no_unidad      = _no_unidad;

			if _cantidad = 0 then
				let v_desc_contrato  = '******* NO EXISTE REGISTRO DE COMPANIAS ' || _cod_contrato;

				select count(*)
				  into _cantidad
				  from temp_produccion
				 where cod_ramo      = v_cod_ramo
				   and cod_subramo   = _cod_subramo
				   and cod_origen    = _cod_origen
				   and cod_contrato  = _cod_contrato
				   and cod_cobertura = _cod_cober_reas
				   and desc_cob      = _nombre_cob
				   and no_poliza     = v_nopoliza
				   and no_unidad 	 = _no_unidad;

				if _cantidad = 0 then
					insert into temp_produccion
					values(	v_cod_ramo,
							_cod_subramo,
							_cod_origen,
							_cod_contrato,
							v_desc_contrato,
							_cod_cober_reas,
							0,
							_tipo_cont,
							0, 
							0, 
							0,
							_nombre_cob,
							_serie,
							1,
							v_nopoliza,
							_no_unidad,
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
					   and cod_contrato   = _cod_contrato
					   and cod_cober_reas = _cod_cober_reas
					   and no_unidad      = _no_unidad
						
					select nombre
					  into _nombre_coas
					  from emicoase
					 where cod_coasegur = _cod_coasegur;

					let v_desc_cobertura = trim(_nombre_cob) || '  ' || trim(_cuenta) || '  ' || trim(_nombre_coas);
					let v_desc_contrato  = trim(v_desc_contrato) || '  I:' || _porc_impuesto || '  C:' || _porc_comis_ase;

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
					   and cod_contrato  = _cod_contrato
					   and cod_cobertura = _cod_cober_reas
					   and desc_cob      = v_desc_cobertura
					   and no_poliza     = v_nopoliza
					   and no_unidad 	 = _no_unidad;

					if _cantidad = 0 then
						insert into temp_produccion
						values(	v_cod_ramo,
								_cod_subramo,
								_cod_origen,
								_cod_contrato,
								v_desc_contrato,
								_cod_cober_reas,
								_monto_reas,
								_tipo_cont,
								_comision, 
								_impuesto, 
								_por_pagar,
								v_desc_cobertura,
								_serie,
								1,
								v_nopoliza,
								_no_unidad,
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
						   and cod_contrato  = _cod_contrato
						   and cod_cobertura = _cod_cober_reas
						   and desc_cob      = v_desc_cobertura
						   and no_poliza     = v_nopoliza
						   and no_unidad 	 = _no_unidad;
					end if
				end foreach
			end if
		end if
	end foreach
end foreach


--/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
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
			   _cod_contrato,
			   v_desc_contrato,
			   _cod_cober_reas,	  
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
		--let _tipo_cont	= _tipo_cont * -1;
		let _comision	= _comision * -1;
		let _impuesto	= _impuesto * -1; 		  
		let _por_pagar	= _por_pagar  * -1;
		
		select count(*)
		  into _cantidad
		  from temp_produccion
		 where cod_ramo      = v_cod_ramo
		   and cod_subramo   = _cod_subramo
		   and cod_origen    = _cod_origen
		   and cod_contrato  = _cod_contrato
		   and cod_cobertura = _cod_cober_reas
		   and desc_cob      = v_desc_cobertura
		   and serie         = _serie
		   and no_poliza = v_nopoliza;

		if _cantidad = 0 then
			insert into temp_produccion
			values(	v_cod_ramo,														
					_cod_subramo,
					_cod_origen,
					_cod_contrato,
					v_desc_contrato,
					_cod_cober_reas,
					_monto_reas,
					_tipo_cont,
					_comision,
					_impuesto,
					_por_pagar,
					v_desc_cobertura,
					_serie,
					1,
					v_nopoliza,
					'00001',
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
			   and cod_contrato  = _cod_contrato
			   and cod_cobertura = _cod_cober_reas
			   and desc_cob      = v_desc_cobertura
			   and serie         = _serie
			   and no_poliza     = v_nopoliza
			   and no_unidad     = '00001';
		end if
	end foreach
end if
--/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

let _prima_tot_ret_sum = 0;
let _prima_tot_sus_sum = 0;
let _p_sus_tot_sum     = 0;

-- Adicionar filtro contrato y serie
-- Filtro por Contrato
if a_contrato <> '*' then
	let v_filtros1 = trim(v_filtros1) ||' Contrato '||trim(a_contrato);
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

-- filtro por serie
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
let v_filtros = trim(v_filtros1)||' '|| trim(v_filtros);

-- tabla de ramos:
foreach
	select distinct cod_ramo
	  into v_cod_ramo
	  from temp_produccion
	 where seleccionado = 1

	if v_cod_ramo in ('001', '003') then
		if v_cod_ramo in ('001') then
			let _t_ramo = '1';
		elif v_cod_ramo in ('003') then
			let _t_ramo = '3';
		end if

		begin
			on exception in(-239)
			end exception

		    --let v_cod_tipo = 'in'||_t_ramo;
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

let v_filtros = trim(v_filtros)||' '|| trim(v_filtros2);
--************************************************************************************************++++++++++++++++++++++++++
--SET DEBUG FILE TO 'sp_rea22a.trc'; 
--trace on;
foreach
	select cod_ramo,		  --se busca por polizas
		   no_poliza,
		   sum(prima)
	  into v_cod_ramo,
		   v_nopoliza,
		   v_prima
	  from temp_produccion
	 where seleccionado = 1
	 --and no_poliza in('957371','924877','917343','909983')
     group by cod_ramo, no_poliza
     order by cod_ramo, no_poliza
	
	select no_documento,cod_subramo, cod_grupo,
		   vigencia_inic, vigencia_final, cod_tipoprod
	  into _no_documento, _cod_subramo, _cod_grupo,
	  	   _vigencia_inic,_vigencia_final, _cod_tipoprod
	  from emipomae
	 where actualizado = 1
	   and no_poliza   = v_nopoliza;  
		
	let _no_poliza_vigente = sp_sis21(_no_documento);   -- esta variable trae lo mas actual
	--let _no_poliza_vigente = v_nopoliza;   -- se coloca para que traiga la poliza  generada en el sp_pro03


	let _flag2     = 0;
	let _flag1     = 0;
	let _cant_pol      = 0;

	foreach					 -- se desglosa por tipo, buscar primero si es bouquet
		select cod_contrato,
			   cod_cobertura,
			   tipo,
			   serie,
			   sum(prima),
			   no_unidad
		  into _cod_contrato,
			   _cod_cober_reas,
			   _tipo_cont,
			   _serie,
			   v_prima_tipo,
			   v_unidad
		  from temp_produccion
		 where cod_ramo  = v_cod_ramo
		   and no_poliza = v_nopoliza 
		   and seleccionado = 1
		 group by cod_contrato,cod_cobertura,tipo,serie,no_unidad 
		 order by cod_contrato,cod_cobertura,tipo,serie,no_unidad
		 
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
		 where cod_contrato   = _cod_contrato
		   and cod_cober_reas = _cod_cober_reas;

		let _facilidad_car = 0;

		select facilidad_car
		  into _facilidad_car
		  from reacomae
		 where cod_contrato = _cod_contrato;

		if _bouquet = 1 and _serie >= 2008 then --and _cod_coasegur in ('050','063','076','042','036','089') then	   -- condiciones del borderaux bouquet
		   {	select count(*) 
			  into _cnt
			  from reacomae  
			 where upper(nombre) like ('%facilida%')  -- condicion ramos tecnicos
			   and cod_contrato  = v_cod_contrato;}

			if _facilidad_car = 0 then
				let _cnt = 0;
			end if

			if _cnt = 0 then
				let _flag = 1;
			end if
		end if

		if _flag = 1 then
			if _facilidad_car = 1 then 
			--if v_cod_contrato = '00574' or v_cod_contrato = '00584' or v_cod_contrato = '00594' or v_cod_contrato = '00604' then
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
				--if v_cod_contrato = '00574' or v_cod_contrato = '00584' or v_cod_contrato = '00594' or v_cod_contrato = '00604' then
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
		   and cod_cober_reas = _cod_cober_reas
		   and es_terremoto = 1;

		if _terremoto = 1 then
			let v_prima = v_prima_tipo;		
		else
			let v_prima = 0;    -- Sin prima de cobertura terremoto Henry:11/05/2016
		end if		

		let v_prima_tipo = 0;
	--end foreach
		select count(*)
		  into _cnt_unidad
		  from emipouni
		 where no_poliza    = _no_poliza_vigente;
		 
		   let _xu_grupo = '';   --varchar(100)
		   let _xu_asegurado = '';   --varchar(100)  			   			   
		   let _xu_contrato = '';   --varchar(100)  			   			   			   
		   let _xu_cobertura = '';   --varchar(100)  			   			   			   
		   let _xu_nombre_ramo = '';   --varchar(100)  			   			   			   
		   let _xu_nombre_subramo = '';   --varchar(100)  
			   
			select trim(nombre) --||' - '||trim(_cod_grupo)
			  into _xu_grupo
			  from cligrupo
			 where cod_grupo = _cod_grupo;			
			 
			select trim(nombre) --||' - '||trim(_cod_grupo)			  
			  into _xu_contrato
			  from reacomae
			 where cod_contrato = _cod_contrato;			 
				 
			select nombre
			  into _xu_nombre_ramo
			  from prdramo
			 where cod_ramo = v_cod_ramo;

			select nombre
			  into _xu_nombre_subramo
			  from prdsubra
			 where cod_ramo    = v_cod_ramo
			   and cod_subramo = _cod_subramo;	

			select trim(nombre) --||' - '||trim(v_cobertura)			  
			  into _xu_cobertura
			  from reacobre
			 where cod_ramo = v_cod_ramo
			   and cod_cober_reas = _cod_cober_reas;				   

			if v_cod_ramo in ('001','003') then
				if _cod_cober_reas in ('021','022') then
				   let _xu_nombre_ramo = Trim(_xu_nombre_ramo)||'-TERREMOTO';
                else				
				   let _xu_nombre_ramo = Trim(_xu_nombre_ramo)||'-INCENDIO';
   				end if		
			end if			 		 

-------------------------------------------******************------------------------------------------------------------------------------------		
		 
		foreach
			select suma_asegurada,
				   no_unidad,
				   cod_asegurado
			  into v_suma_asegurada,
				   _no_unidad,
				   _cod_asegurado
			  from emipouni
			 where no_poliza    = _no_poliza_vigente
			   and no_unidad = v_unidad
			 
			let _xu_asegurado = '';   --varchar(100)
			
				SELECT trim(nombre) --||' - '||trim(_cod_asegurado)
				  INTO _xu_asegurado
				  FROM cliclien
				 WHERE cod_cliente = _cod_asegurado;			
			

		
			if v_suma_asegurada is null then
				let v_suma_asegurada = 0.00;
			end if
			
			select porc_partic_coas
			  into _porc_partic_coas 
			  from emicoama
			 where no_poliza    = _no_poliza_vigente
			   and cod_coasegur = '036'; 			

			if _porc_partic_coas is null then
				let _porc_partic_coas = 100;
			end if
			
			let v_suma_asegurada = v_suma_asegurada * _porc_partic_coas/100;
			
			select parinfra.rango1, 
				   parinfra.rango2
			  into v_rango_inicial,
				   v_rango_final
			  from parinfra
			 where parinfra.cod_ramo = v_cod_ramo
			   and parinfra.rango1  <= round(v_suma_asegurada,0)	   -- prima   -- se quito el argumento de prima cobrada, solicitud inicial.
			   and parinfra.rango2  >= round(v_suma_asegurada,0);

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
					if _cod_cober_reas in ('001','003') then
						--let _flag2 = _flag2 - 1;
						--continue foreach;
						let v_prima      = 0;		
						let v_prima_1 	 = 0;	
						let v_prima_bq 	 = 0;
						let v_prima_3  	 = 0;
						let v_prima_ot 	 = 0;
						let _sum_fac_car = 0;	
					end if
					let _xu_nombre_ramo = Trim(v_desc_ramo)||'-TERREMOTO';						
					let v_desc_ramo = Trim(v_desc_ramo)||"-TERREMOTO";		
				end if
				
				begin
					on exception in(-239)
						select count(*)
						  into _cnt
						  from tmp_no_documento
						 where no_documento   = _no_documento
						   and suma_asegurada = v_suma_asegurada
						   and no_unidad      = _no_unidad;
						 
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
						  
					/*	if v_rango_inicial >= 0 and v_rango_final <= 10000 then 						
							insert into tmp_documento(no_documento, suma_asegurada)values(_no_documento,_cv_suma_asegurada * v_porcentaje/100);
						end if	
					*/	 

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
							v_suma_asegurada * v_porcentaje/100,
							_no_documento
							);
				/*	if v_rango_inicial >= 0 and v_rango_final <= 10000 then 						
						insert into tmp_documento(no_documento, suma_asegurada)values(_no_documento,_cv_suma_asegurada * v_porcentaje/100);
					end if	*/	

					
				end 
				
				select count(*)
				  into _cnt_documento
				  from tmp_no_documento
				 where no_documento   = _no_documento
				   and suma_asegurada = v_suma_asegurada
				   and no_unidad      = _no_unidad;
				   
				if _cnt_documento = 0 then
				
					 let _xu_p_cobrada       = 0;   	
					 let _xu_p_retenida      = 0;
					 let _xu_p_bouquet       = 0;
					 let _xu_p_facultativo   = 0;
					 let _xu_p_otros		 = 0;
					 let _xu_p_fac_car		 = 0;	
					 
					 let _suma = v_suma_asegurada;
					 
					let _no_cambio = null;
                    LET _porc_coas = 100;				

					select max(no_cambio)
					  into _no_cambio
					  from emireaco
					 where no_poliza = _no_poliza_vigente
					   and no_unidad = _no_unidad;

					if _no_cambio is null then
						let _no_cambio = 0;
					end if		
				    let _suma = v_suma_asegurada;		
					foreach
						select r.cod_contrato,
							   r.porc_partic_prima,
							   r.cod_cober_reas,
							   c.tipo_contrato
						  into _cod_contrato,
							   _porc_partic_prima,
							   v_cobertura,
							   _tipo_contrato
						  from emireaco r, reacomae c
						 where r.cod_contrato = c.cod_contrato
						   and no_poliza = _no_poliza_vigente
						   and no_unidad = _no_unidad
						   and no_cambio = _no_cambio
						   
						SELECT es_terremoto
						  INTO _es_terremoto
						  FROM reacobre
						 WHERE cod_cober_reas = v_cobertura;			   		 		 

							LET _suma_retencion    = 0;
							LET _suma_facultativos = 0;
							LET _suma_contratos    = 0;							
						
						IF   _tipo_contrato = 1 THEN
							IF _es_terremoto = 0 THEN
								LET _suma_retencion    = 0;
							ELSE
								LET _suma_retencion    = _suma * (_porc_partic_prima/100) * _porc_partic_coas / 100;
							END IF			
						ELIF _tipo_contrato = 3 THEN
							IF _es_terremoto = 0 THEN
								LET _suma_facultativos    = 0;
							ELSE
								LET _suma_facultativos = _suma * (_porc_partic_prima/100) * _porc_partic_coas / 100;
							END IF			
						ELSE
							IF _es_terremoto = 0 THEN
								LET _suma_contratos    = 0;
							ELSE
								LET _suma_contratos    = _suma * (_porc_partic_prima/100) * _porc_partic_coas / 100;
							END IF			
						END IF		
						
						  if _suma_facultativos is null then
							let _suma_facultativos = 0;
						 end if
						  if _suma_retencion is null then
							let _suma_retencion = 0;
						  end if
						 if _suma_contratos is null then
							let _suma_contratos = 0;
						 end if					 

				
				        begin
					    on exception in(-239)							
						end exception
						insert into tmphg_contratos(
								no_poliza,
								no_documento,
								no_unidad,
								tipo_contrato,
								cod_cober_reas,
								cod_contrato,
								suma_retencion,
								suma_contratos,
								suma_facultativos)
						values(	_no_poliza_vigente,
								_no_documento,
								_no_unidad,
								_tipo_contrato,
								v_cobertura,
								_cod_contrato,
								_suma_retencion,
								_suma_contratos,
								_suma_facultativos);					
							end																								
											 
								
					end foreach	
					
					select sum(suma_retencion),
						   sum(suma_contratos),
						   sum(suma_facultativos)      
					  Into _suma_retencion,
					       _suma_contratos,
					       _suma_facultativos
					  From tmphg_contratos			   		   
					 where no_documento = _no_documento
					   and no_unidad = _no_unidad
					   and no_poliza = _no_poliza_vigente;	

						  if _suma_facultativos is null then
							let _suma_facultativos = 0;
						 end if
						  if _suma_retencion is null then
							let _suma_retencion = 0;
						  end if
						 if _suma_contratos is null then
							let _suma_contratos = 0;
						 end if							   
					   
					   let _suma = _suma_retencion +  _suma_contratos +  _suma_facultativos;
		
							 
					insert into tmp_no_documento(no_documento, suma_asegurada,no_unidad)values(_no_documento,v_suma_asegurada,_no_unidad);
					
				     let _xu_p_cobrada      = _xu_p_cobrada      + v_prima * v_porcentaje/100;   	
					 let _xu_p_retenida     = _xu_p_retenida     + v_prima_1 * v_porcentaje/100;
					 let _xu_p_bouquet      = _xu_p_bouquet      + v_prima_bq * v_porcentaje/100;
					 let _xu_p_facultativo  = _xu_p_facultativo  + v_prima_3 * v_porcentaje/100;
					 let _xu_p_otros		 = _xu_p_otros        + v_prima_ot * v_porcentaje/100;
					 let _xu_p_fac_car		 = _xu_p_fac_car      + _sum_fac_car * v_porcentaje/100;					 					 
					 

						 
					insert into tmp_doc_rea1(no_documento, suma_asegurada,no_unidad,p_cobrada,p_retenida,p_bouquet,p_facultativo,p_otros,p_fac_car,no_poliza, 
											cod_ramo, cod_subramo, serie, cod_contrato, cod_cobertura, grupo,vigencia_inic,vigencia_final,asegurado,contrato,
											cobertura,nombre_ramo,nombre_subramo,suma_retencion,suma_contratos,suma_facultativos,periodo1,periodo2)
                         values(_no_documento,v_suma_asegurada,_no_unidad,_xu_p_cobrada, _xu_p_retenida,_xu_p_bouquet, _xu_p_facultativo, _xu_p_otros, _xu_p_fac_car,_no_poliza_vigente,
								v_cod_ramo, _cod_subramo, _serie,  _cod_contrato, v_cobertura, _xu_grupo,_vigencia_inic,_vigencia_final,_xu_asegurado,_xu_contrato,
								_xu_cobertura,_xu_nombre_ramo,_xu_nombre_subramo,_suma_retencion,_suma_contratos,_suma_facultativos,a_periodo1,a_periodo2);					
--					values(_no_documento,v_suma_asegurada,_no_unidad,_xu_p_cobrada, _xu_p_retenida,_xu_p_bouquet, _xu_p_facultativo, _xu_p_otros, _xu_p_fac_car,_no_poliza_vigente,v_cod_ramo, _cod_subramo, _serie,  v_cod_contrato, v_cobertura, _xu_grupo,_vigencia_inic,_vigencia_final,_xu_asegurado,_xu_contrato,_xu_cobertura,_xu_nombre_ramo,_xu_nombre_subramo);					
						
				else
				
					update tmp_doc_rea1
						  set p_cobrada       = p_cobrada      + v_prima * v_porcentaje/100,   	
							  p_retenida      = p_retenida     + v_prima_1 * v_porcentaje/100,	
							  p_bouquet       = p_bouquet      + v_prima_bq * v_porcentaje/100,	
							  p_facultativo   = p_facultativo  + v_prima_3 * v_porcentaje/100,
							  p_otros		  = p_otros        + v_prima_ot * v_porcentaje/100,
							  p_fac_car		  = p_fac_car      + _sum_fac_car * v_porcentaje/100
						 where no_documento   = _no_documento
						   and suma_asegurada = v_suma_asegurada
						   and no_unidad      = _no_unidad;							   						   

					 
				end if				
				--let v_prima   = 0; 
			end foreach
			let _flag1 = _flag1 + 1;
		end foreach --unidades
	let _flag2 = _flag2 + 1;
	end foreach -- contratos
	let v_prima   = 0; 
	
end foreach -- principal

-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

--return 1;

------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
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

--drop table if exists temp_produccion;
drop table if exists temp_det;
drop table if exists temp_devpri;
drop table if exists tmp_ramos;
drop table if exists temp_fact;
drop table if exists tmp_no_documento;
--drop table if exists tmp_doc_rea1;


end procedure;