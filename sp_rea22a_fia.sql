--      TOTALES DE PRODUCCION POR         --
--         CONTRATO DE REASEGURO          --
---  Yinia M. Zamora - octubre 2000       -- YMZM
---  Ref. Power Builder - reemplaza sp_pro308
--- Modificado por Armando Moreno 19/01/2002; la parte de los tipo de contratos
--- Modificado por Henry 10/9/2009 filtros requeridos por Sr. Omar Wong
--------------------------------------------
---- Copia del sp_pr999 Federico Coronado ramo incendio
--execute procedure sp_rea22a_fia('001','001','2016-07','2017-03','*','*','*','*','*','*','*','*','*','09')
drop procedure sp_rea22a_fia;
create procedure sp_rea22a_fia(
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
define _cod_contratante		char(10);
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

--SET DEBUG FILE TO 'sp_rea22a.trc'; 
--trace on;

set isolation to dirty read;

let v_descr_cia  = sp_sis01(a_compania);
let v_acumulada = '0.00';
let v_acumulado = '0.00';
let _cant_pol = 0;
let _terremoto = 0;

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
	
if _borderaux = '01' then	--es bouquet y facilidad car	  
	if a_codramo = '*' then
		let a_codramo = '001,003,006,008,010,011,012,013,014,021,022;';
	end if
else
	if _borderaux = '06' then
		if a_codramo = '*' then
			let a_codramo = '014;';
		end if
	elif _borderaux = '08' then
		if a_codramo = '*' then
			let a_codramo = '004,016,019;';
		end if
	elif _borderaux = '09' then
		if a_codramo = '*' then
			let a_codramo = '008;';
		end if
	elif _borderaux = '10' then
		if a_codramo = '*' then
			let a_codramo = '002;';
		end if
	end if
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

/*Temporal para guardar los numeros de documentos.*/
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


foreach
	select cod_ramo,
		   p_cobrada,
		   p_retenida,
		   p_bouquet,
		   p_facultativo,
		   p_otros,
		   p_fac_car
	  into v_cod_ramo,
		   v_prima,
		   v_prima_1,
		   v_prima_bq,
		   v_prima_3,
		   v_prima_ot,
		   _sum_fac_car
	  from tmp_tabla

	select count(*)
	  into _cnt_unidad
	  from emipouni
	 where no_poliza    = _no_poliza_vigente;
	
	let v_prima = v_prima / _cnt_unidad;
	let v_prima_1 = v_prima_1 / _cnt_unidad; 
	let v_prima_bq = v_prima_bq / _cnt_unidad;
	let v_prima_3 = v_prima_3 / _cnt_unidad; 
	let v_prima_ot = v_prima_ot / _cnt_unidad;
	let _sum_fac_car = _sum_fac_car / _cnt_unidad;

	foreach
		select suma_asegurada,
			   no_unidad
		  into v_suma_asegurada,
			   _no_unidad
		  from emipouni
		 where no_poliza    = _no_poliza_vigente

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
		end if

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
				let v_desc_ramo = Trim(v_desc_ramo)||'-INCENDIO';
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
						  p_bouquet      = p_bouquet      + v_prima_bq * v_porcentaje/100,	
						  p_facultativo  = p_facultativo  + v_prima_3 * v_porcentaje/100,
						  p_otros		 = p_otros        + v_prima_ot * v_porcentaje/100,
						  p_fac_car		 = p_fac_car      + _sum_fac_car * v_porcentaje/100,
						  p_suma_asegurada = p_suma_asegurada + _cv_suma_asegurada * v_porcentaje/100
					where cod_contratante = _cod_contratante
					  and cod_ramo        = v_cod_tipo  
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
						p_filtro,
						p_suma_asegurada,
						no_documento,
						cod_contratante)
				values(	v_cod_tipo, 
						v_desc_ramo, 
						v_rango_inicial, 
						v_rango_final, 
						_cant_pol, 
						v_prima * v_porcentaje/100,  
						v_prima_1 * v_porcentaje/100, 
						v_prima_bq * v_porcentaje/100, 
						v_prima_3 * v_porcentaje/100, 
						v_prima_ot * v_porcentaje/100,
						_sum_fac_car * v_porcentaje/100,
						v_filtros,
						_cv_suma_asegurada * v_porcentaje/100,
						_no_documento,
						_cod_contratante);
			end 
			
			select count(*)
			  into _cnt_documento
			  from tmp_no_documento
			 where no_documento   = _no_documento
			   and suma_asegurada = v_suma_asegurada
			   and no_unidad      = _no_unidad;
			   
			if _cnt_documento = 0 then
				insert into tmp_no_documento(no_documento, suma_asegurada,no_unidad)
				values(_no_documento,v_suma_asegurada,_no_unidad);
			end if
			--let v_prima   = 0; 
		end foreach
		let _flag1 = _flag1 + 1;
	end foreach --unidades
	let _flag2 = _flag2 + 1;
end foreach -- contratos
let v_prima   = 0; 	

drop table if exists temp_produccion;
drop table if exists temp_det;
drop table if exists temp_devpri;
drop table if exists tmp_ramos;
drop table if exists temp_fact;
drop table if exists tmp_no_documento;

return 1;
end

end procedure;