--      TOTALES DE PRODUCCION POR         --
--         CONTRATO DE REASEGURO          --
---  Yinia M. Zamora - octubre 2000       -- YMZM
---  Ref. Power Builder - reemplaza sp_pro308
--- Modificado por Armando Moreno 19/01/2002; la parte de los tipo de contratos
--- Modificado por Henry 10/9/2009 filtros requeridos por Sr. Omar Wong
--------------------------------------------
---- Copia del sp_pr999 Federico Coronado ramo incendio
--execute procedure sp_rea22e_uni('001','001','2016-05','2016-05',"*","*","*","*","002,020,023;","*","*","2015,2014,2013,2012,2011,2010,2009,2008;")
drop procedure sp_rea22e_uni;
create procedure sp_rea22e_uni(
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
a_serie			char(255)	default "*")
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
define v_suma_asegurada		dec(16,2);
define _cv_suma_asegurada   dec(16,2);
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
define v_prima_tipo2		dec(16,2);
define _sum_fac_car			dec(16,2);
define _monto_reas2			dec(16,2);
define _monto_reas			dec(16,2);
define v_acumulada			dec(16,2);
define v_acumulado			dec(16,2);
define v_prima_bq			dec(16,2);
define _por_pagar			dec(16,2);
define _p_sus_tot			dec(16,2);
define v_prima_34			dec(16,2);
define v_retenida			dec(16,2);
define _cont_casco			dec(16,2);
define _cont_cob_rc			dec(16,2);
define _ret_casco			dec(16,2);
define _cob_rc				dec(16,2);
define v_prima_ot			dec(16,2);
define v_fac_car			dec(16,2);
define v_prima_1			dec(16,2);
define v_prima_3			dec(16,2);
define v_cobrada			dec(16,2);
define v_bouquet			dec(16,2);
define _impuesto			dec(16,2);
define _comision			dec(16,2);
define v_prima1				dec(16,2);
define v_prima2				dec(16,2);
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
define _cant_pol			integer;
define _renglon				integer;
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

--SET DEBUG FILE TO "sp_rea22a.trc"; 
--trace on;

set isolation to dirty read;

let v_descr_cia  = sp_sis01(a_compania);
let v_acumulada = '0.00';
let v_acumulado = '0.00';
let _cant_pol = 0;
let _terremoto = 0;

	 --////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
let _borderaux = '01';   -- BOUQUET,CUOTA PARTE ACC PERS, VIDA, FACILIDAD CAR
let _periodo1 = a_periodo1;

if a_periodo2 = '2013-09' then
	let _periodo1 = '2008-01';
end if
	
if a_periodo2 >= '2013-07' then
	-- Cargar los valores de devolucion de primas	  Crea tabla temp_det  (temporal)
	call sp_rea22d(a_compania,a_agencia,_periodo1,a_periodo2,a_codsucursal,a_codgrupo,a_codagente,a_codusuario,
					a_codramo,a_reaseguro,a_serie,_borderaux) 
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
 
CALL sp_pro34(a_compania,a_agencia,a_periodo1,a_periodo2,a_codsucursal,a_codgrupo,a_codagente,a_codusuario,a_codramo,a_reaseguro) RETURNING v_filtros;

create temp table tmp_ramos(
cod_ramo		char(3),
cod_sub_tipo	char(3),
porcentaje		smallint default 100,
primary key(cod_ramo, cod_sub_tipo)) with no log;

create temp table temp_produccion(
cod_ramo		char(3),
cod_contrato	char(5),
desc_contrato	char(50),
cod_cobertura	char(3),
no_poliza		char(10),
no_unidad		char(5),
suma_asegurada	dec(16,2),
prima			dec(16,2),
prima_otros		dec(16,2),
tipo			smallint default 0,
desc_cob		char(100),
serie			smallint,
seleccionado	smallint default 1,
primary key(no_poliza,no_unidad,cod_ramo,cod_contrato, cod_cobertura,desc_cob)) with no log;
create index idx1_temp_produccion on temp_produccion(cod_ramo);
create index idx4_temp_produccion on temp_produccion(cod_contrato);
create index idx5_temp_produccion on temp_produccion(cod_cobertura);
create index idx6_temp_produccion on temp_produccion(desc_cob);
create index idx7_temp_produccion on temp_produccion(no_poliza);
create index idx8_temp_produccion on temp_produccion(serie);
create index idx9_temp_produccion on temp_produccion(no_unidad);

/*Temporal para guardar los numeros de documentos.*/
create temp table tmp_no_documento(
no_documento		char(20),
suma_asegurada      dec(16,2),
no_unidad           char(5),
primary key(no_documento,suma_asegurada,no_unidad)) with no log;

let _prima_tot_ret = 0;
let _prima_sus_tot = 0;
let _p_sus_tot_sum = 0;
let _sum_fac_car = 0;
let _p_sus_tot = 0;
let _tipo_cont = 0;
let v_filtros2 = "";
let v_filtros1 = "";
let v_prima = 0;

foreach
	select distinct no_poliza,
		   no_endoso,
		   no_documento
	  into v_nopoliza,
		   v_noendoso,
		   _no_doc
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

	select cod_ramo
	  into v_cod_ramo
	  from emipomae
	 where no_poliza = v_nopoliza;

	{select porc_partic_coas
	  into _porc_partic_coas 
	  from emicoama
	 where no_poliza    = v_nopoliza
	   and cod_coasegur = "036"; 			

	if _porc_partic_coas is null then}
		let _porc_partic_coas = 100;
	--end if

	{select count(*)
	  into _cnt_unidad
	  from emipouni
	 where no_poliza = v_nopoliza
	   and no_unidad = _no_unidad;

	if _cnt_unidad is null then
		let _cnt_unidad = 0;
	end if

	if _cnt_unidad = 0 then
		
	end if}
	drop table if exists tmp_reas;
	call sp_sis122(v_nopoliza, v_noendoso) returning _error,_error_desc;
	
	foreach
		select cod_cober_reas,
    		   cod_contrato,
	    	   prima_rea,
			   no_unidad,
			   porc_partic_prima
          into v_cobertura,
      	   	   v_cod_contrato,
      	   	   v_prima1,
			   _no_unidad,
			   _porc_partic_prima
          from tmp_reas
         where prima_rea <> 0

		let v_prima1 = v_prima1 * _porc_partic_coas / 100;
		let v_prima2 = 0.00;

		if v_cobertura in ('002','033') then
			select sum(c.prima_neta) * (_porc_partic_coas/100) 
			  into v_prima2
			  from endedcob c, prdcober p
			 where c.cod_cobertura = p.cod_cobertura
			   and no_poliza = v_nopoliza
			   and no_endoso = v_noendoso
			   and no_unidad = _no_unidad
			   and p.cod_cober_reas = v_cobertura
			   and c.cod_cobertura not in ('00102','00107','00113','00117','01299','01302','01304','01305');

			if v_prima2 is null then
				let v_prima2 = 0.00;
			end if

			let v_prima2 = v_prima2 * (_porc_partic_prima/100);
		end if

		let v_prima1 = v_prima1 - v_prima2;

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

		let v_prima  = v_prima1;

		select nombre,
			   serie
		  into v_desc_contrato,
			   _serie
		  from reacomae
		 where cod_contrato = v_cod_contrato;

		let _nombre_con = trim(v_desc_contrato) || " (" || v_cod_contrato || ")" || "  A: " || _serie;

		select nombre
		  into v_desc_ramo
		  from prdramo
		 where cod_ramo = v_cod_ramo;

		select nombre
		  into _nombre_cob
		  from reacobre
		 where cod_cober_reas = v_cobertura;

		select count(*)
		  into _cantidad
		  from temp_produccion
		 where cod_ramo      = v_cod_ramo
		   and cod_contrato  = v_cod_contrato
		   and cod_cobertura = v_cobertura
		   and desc_cob      = _nombre_cob
		   and no_poliza     = v_nopoliza
		   and no_unidad     = _no_unidad;

		if _cantidad = 0 then
			insert into temp_produccion(
					cod_ramo,
			        cod_contrato,
			        desc_contrato,
			        cod_cobertura,
			        no_poliza,
			        no_unidad,	
			        prima,
			        prima_otros,
			        tipo,
			        desc_cob,
					serie,
					seleccionado)
			values(	v_cod_ramo,
					v_cod_contrato,
					v_desc_contrato,
					v_cobertura,
					v_nopoliza,
					_no_unidad,
					v_prima1,
					v_prima2,
					_tipo_cont,
					_nombre_cob,
					_serie,
					1);
		else						   
			update temp_produccion
			   set prima         = prima + v_prima1,
				   prima_otros   = prima_otros  + v_prima2
			 where cod_ramo      = v_cod_ramo
			   and cod_contrato  = v_cod_contrato
			   and cod_cobertura = v_cobertura
			   and desc_cob      = _nombre_cob
			   and no_poliza     = v_nopoliza
			   and no_unidad     = _no_unidad;
		end if
	end foreach
end foreach


--/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
-- Devolucion de Prima
{if a_periodo2 >= '2013-07' then
	foreach 
		select cod_ramo,
			   cod_contrato,
			   desc_contrato,
			   cod_cobertura,
			   desc_cob,
			   prima,
			   tipo,
			   serie,
			   no_poliza
		  into v_cod_ramo, 
			   v_cod_contrato,
			   v_desc_contrato,
			   v_cobertura,
			   v_desc_cobertura,
			   _monto_reas,	   
			   _tipo_cont,		
			   _serie,
			   v_nopoliza
		  from temp_devpri
		 where seleccionado = 1
		
		let _monto_reas = _monto_reas * -1;

		foreach
			select no_unidad
			  into _no_unidad
			  from temp_produccion
			 where no_poliza = v_nopoliza
			exit foreach;
		end foreach

		select count(*)
		  into _cantidad
		  from temp_produccion
		 where cod_ramo      = v_cod_ramo
		   and cod_contrato  = v_cod_contrato
		   and cod_cobertura = v_cobertura
		   and desc_cob      = v_desc_cobertura
		   and serie         = _serie
		   and no_poliza = v_nopoliza
		   and no_unidad = _no_unidad;

		if _cantidad = 0 then
			insert into temp_produccion(
					cod_ramo,
			        cod_contrato,
			        desc_contrato,
			        cod_cobertura,
			        no_poliza,
			        no_unidad,	
			        prima,
			        prima_otros,
			        tipo,
			        desc_cob,
					serie,
					seleccionado)
			values(	v_cod_ramo,														
					v_cod_contrato,
					v_desc_contrato,
					v_cobertura,
					v_nopoliza,
					_no_unidad,
					_monto_reas,
					0.00,
					_tipo_cont,
					v_desc_cobertura,
					_serie,
					1);
		else	   
			update temp_produccion
			   set prima         = prima + _monto_reas
			 where cod_ramo      = v_cod_ramo
			   and cod_contrato  = v_cod_contrato
			   and cod_cobertura = v_cobertura
			   and desc_cob      = v_desc_cobertura
			   and serie         = _serie
			   and no_poliza     = v_nopoliza
			   and no_unidad     = _no_unidad;
		end if
	end foreach
end if}
--/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

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
	select distinct cod_ramo,		  --se busca por polizas
		   no_poliza,
		   no_unidad
	  into v_cod_ramo,
		   v_nopoliza,
		   _no_unidad
	  from temp_produccion
	 where seleccionado = 1

	let _flag2 = 0;
	let _flag1 = 0;
	let _cant_pol = 0;
	
	select no_documento
	  into _no_documento
	  from emipomae
	 where no_poliza = v_nopoliza;

	foreach					 -- se desglosa por tipo, buscar primero si es bouquet
		select cod_contrato,
			   cod_cobertura,
			   tipo,
			   serie,
			   sum(prima),
			   sum(prima_otros)
		  into v_cod_contrato,
			   v_cobertura,
			   _tipo_cont,
			   _serie,
			   v_prima_tipo,
			   v_prima_tipo2
		  from temp_produccion
		 where cod_ramo  = v_cod_ramo
		   and no_poliza = v_nopoliza 
		   and no_unidad = _no_unidad 
		   and seleccionado = 1
		 group by cod_contrato,cod_cobertura,tipo,serie 
		 order by cod_contrato,cod_cobertura,tipo,serie  
		 
		let _cv_suma_asegurada = 0;
		let _sum_fac_car = 0;
		let _cont_cob_rc = 0;
		let _cont_casco = 0;
		let _ret_casco = 0;
		let v_prima_bq = 0;
		let v_prima_ot = 0;
		let v_prima_1 = 0;
		let v_prima_3 = 0;
		let _cob_rc = 0;
		let _flag = 0;
		let _cnt = 0;

		select bouquet
		  into _bouquet
		  from reacocob
		 where cod_contrato   = v_cod_contrato
		   and cod_cober_reas = v_cobertura;

		let _facilidad_car = 0;
		
		if v_prima_tipo2 is null then
			let v_prima_tipo2 = 0.00;
		end if

		if v_prima_tipo is null then
			let v_prima_tipo = 0.00;
		end if

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
				let _sum_fac_car = _sum_fac_car + v_prima_tipo;
			else
				if v_cod_ramo in ('002','020','023') then
					if v_cobertura in ('025','002','033') then
						let _cont_cob_rc = _cont_cob_rc + v_prima_tipo; --bqt_rc
						let v_prima_bq = v_prima_bq + v_prima_tipo2; --bqt_otros
					else
						let _cont_casco = _cont_casco + v_prima_tipo; --bqt_casco
					end if
				else
					let v_prima_bq = v_prima_bq + v_prima_tipo + v_prima_tipo2;
				end if
			end if
		else
			if _tipo_cont = 2 or _tipo_cont = 1 then
				if _tipo_cont = 1 then		--	retencion

					if v_cod_ramo in ('002','020','023') then
						if v_cobertura in ('025','002','033') then
							let v_prima_1 = v_prima_1 + v_prima_tipo2; --ret_otros
							let _cob_rc = _cob_rc + v_prima_tipo; --ret_rc
						else
							let _ret_casco = _ret_casco + v_prima_tipo;
						end if
					else
						let v_prima_1 = v_prima_1 + v_prima_tipo;
					end if
				end if
				if _tipo_cont = 2 then		--  facultativos
					let v_prima_3 = v_prima_3 + v_prima_tipo ;
				end if
			else
				if _facilidad_car = 1 then 	
				--if v_cod_contrato = "00574" or v_cod_contrato = "00584" or v_cod_contrato = "00594" or v_cod_contrato = "00604" then
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
			let v_prima = v_prima_tipo + v_prima_tipo2;		
		else
			let v_prima = 0;    -- Sin prima de cobertura terremoto Henry:11/05/2016
		end if		

		let v_prima_tipo = 0;
	--end foreach
		select count(*)
		  into _cnt_unidad
		  from emipouni
		 where no_poliza    = v_nopoliza;
		
		let _cnt_unidad = 1;
		let v_prima 		= v_prima / _cnt_unidad;
		let v_prima_1 		= v_prima_1 / _cnt_unidad; 
		let _ret_casco 		= _ret_casco / _cnt_unidad; 
		let _cob_rc 		= _cob_rc / _cnt_unidad; 
		let v_prima_bq 		= v_prima_bq / _cnt_unidad;
		let _cont_cob_rc 	= _cont_cob_rc / _cnt_unidad;
		let _cont_casco 	= _cont_casco / _cnt_unidad;
		let v_prima_3  		= v_prima_3 / _cnt_unidad; 
		let v_prima_ot 		= v_prima_ot / _cnt_unidad;
		let _sum_fac_car 	= _sum_fac_car / _cnt_unidad;

		select suma_asegurada
		  into v_suma_asegurada
		  from emipouni
		 where no_poliza    = v_nopoliza
		   and no_unidad    = _no_unidad;

		if v_suma_asegurada is null then
			let v_suma_asegurada = 0.00;
		end if			 

		if _flag2 = 0 then
			 let _cv_suma_asegurada = v_suma_asegurada;	
			 let _cant_pol = 1;					 
		else
			let _cv_suma_asegurada = 0;
			let _cant_pol = 0;
		end if
		
		if _flag1 = 0 then
			--let _cant_pol = _cant_pol + 1;	
		end if
		
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
					 where no_documento 	= _no_documento
					   and suma_asegurada 	>= v_rango_inicial
					   and suma_asegurada 	<= v_rango_final
					   and no_unidad    	= _no_unidad;
					 
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
						  p_retenida_rc     = p_retenida_rc     + _cob_rc * v_porcentaje/100,	
						  p_retenida_casco     = p_retenida_casco     + _ret_casco * v_porcentaje/100,	
						  p_bouquet      = p_bouquet      + v_prima_bq * v_porcentaje/100,	
						  p_bouquet_rc      = p_bouquet_rc      + _cont_cob_rc * v_porcentaje/100,	
						  p_bouquet_casco      = p_bouquet_casco      + _cont_casco * v_porcentaje/100,	
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
						p_retenida_rc,   					
						p_retenida_casco,   					
						p_bouquet,    					
						p_bouquet_rc,    					
						p_bouquet_casco,    					
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
						_cant_pol, 
						v_prima * v_porcentaje/100,  
						v_prima_1 * v_porcentaje/100, 
						_cob_rc * v_porcentaje/100, 
						_ret_casco * v_porcentaje/100, 
						v_prima_bq * v_porcentaje/100, 
						_cont_cob_rc * v_porcentaje/100, 
						_cont_casco * v_porcentaje/100, 
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
				insert into tmp_no_documento(no_documento, suma_asegurada,no_unidad)values(_no_documento,v_suma_asegurada,_no_unidad);
			end if
			--let v_prima   = 0; 
		end foreach
		let _flag1 = _flag1 + 1;
		--end foreach --unidades
	let _flag2 = _flag2 + 1;
	end foreach -- contratos
	let v_prima   = 0; 
	
end foreach -- principal

return 1;
--drop table if exists temp_produccion;
drop table if exists temp_det;
drop table if exists temp_devpri;
drop table if exists tmp_ramos;
drop table if exists temp_fact;
drop table if exists tmp_no_documento;
end

end procedure;