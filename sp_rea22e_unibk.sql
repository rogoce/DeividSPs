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
returning	char(3)				as cod_ramo, 
			varchar(50)			as desc_ramo, 
			dec(16,2)			as rango_inicial,
			dec(16,2)			as rango_final, 
			integer 			as cantidad, 
			dec(16,2)			as prima_suscrita, 
			dec(16,2)			as retencion,
			dec(16,2)			as contrato, 
			dec(16,2)			as facultativo, 
			dec(16,2)			as otros_contratos,
			dec(16,2)			as fac_car,
			dec(16,2)			as acumulada,
			varchar(50)			as descr_cia, 
			varchar(255)		as filtros,
			dec(16,2)			as suma_asegurada,
			dec(16,2)			as retencion_otros,
			dec(16,2)			as retencion_rc,
			dec(16,2)			as retencion_casco,
			dec(16,2)			as contrato_otros, 
			dec(16,2)			as contrato_rc, 
			dec(16,2)			as contrato_casco;
			
			
			
begin
define _error_desc			char(255);
define v_filtros1			char(255);
define v_filtros2			char(255);
define v_filtros			char(255);
define v_desc_cobertura		char(100);
define v_desc_contrato		char(50);
define _nombre_cob			char(50);
define _nombre_con			char(50);
define v_desc_ramo			char(50);
define v_descr_cia			char(50);
define _no_doc				char(20);
define v_nopoliza			char(10);
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
define _prima_tot_cont_sum	dec(16,2);
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
define v_suscrita			dec(16,2);
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
define v_tipo_contrato		smallint;
define _facilidad_car		smallint;
define v_porcentaje			smallint;
define _tipo_cont			smallint;
define _traspaso			smallint;
define _bouquet				smallint;
define _serie				smallint;
define _tipo2				smallint;
define _flag				smallint;
define _cnt					smallint;
define _cantidad			integer;
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
let _prima_tot_ret = 0;
let _prima_sus_tot = 0;
let _p_sus_tot_sum = 0;
let _sum_fac_car = 0;
let _p_sus_tot = 0;
let _tipo_cont = 0;
let v_filtros2 = "";
let v_filtros1 = "";
let v_prima = 0;


let v_acumulada = 0;

foreach
	select cod_ramo,
		   desc_ramo,
		   rango_inicial,
		   rango_final,
		   cant_polizas,
		   p_suscrita,
		   p_retenida,
		   p_retenida_otros,
		   p_retenida_rc,
		   p_retenida_casco,
		   p_bouquet,
		   p_bouquet_otros,
		   p_bouquet_rc,
		   p_bouquet_casco,
		   p_facultativo,
		   p_otros,
		   p_fac_car,
		   p_filtro,
		   p_suma_asegurada
	  into v_cod_ramo, 
		   v_desc_ramo,
		   v_rango_inicial,
		   v_rango_final,
		   _cantidad,
		   v_suscrita,
		   _prima_tot_ret_sum,
		   v_retenida,
		   _cob_rc,
		   _ret_casco,
		   _prima_tot_cont_sum,
		   v_bouquet,
		   _cont_cob_rc,
		   _cont_casco,
		   v_facultativo,
		   v_otros,
		   v_fac_car,
		   v_filtros,
		   v_suma_asegurada
	  from tmp_tabla_rea 
	 order by cod_ramo,rango_inicial

	if v_cod_ramo in ('001','003') then
		let v_desc_ramo = 'INCENDIO';
	elif v_cod_ramo in ('010','011','013','014') then
		let v_desc_ramo = 'RAMOS TECNICOS';
	elif v_cod_ramo in ('015','007') then
		let v_desc_ramo = 'RIESGOS VARIOS';
	end if

	let v_acumulada  = v_acumulada  + v_suscrita;

	return	v_cod_ramo, 
			v_desc_ramo, 
			v_rango_inicial,
			v_rango_final, 
			_cantidad, 
			v_suscrita,
			_prima_tot_ret_sum,
			_prima_tot_cont_sum,
			v_facultativo, 
			v_otros,
			v_fac_car,
			v_acumulada,
			v_descr_cia, 
			v_filtros,
			v_suma_asegurada, 
			v_retenida,
			_cob_rc,
			_ret_casco,
			v_bouquet,
			_cont_cob_rc,
			_cont_casco
			with resume;
end foreach

{drop table if exists tmp_tabla_rea;
drop table if exists temp_det;
drop table if exists tmp_ramos;
drop table if exists temp_produccion;
drop table if exists temp_det;
drop table if exists temp_devpri;
drop table if exists tmp_no_documento;}
end

end procedure;