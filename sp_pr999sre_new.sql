--------------------------------------------
--   DETALLE DE TOTALES DE PRIMAS COBRADAS         --
---  Yinia M. Zamora - octubre 2000       -- YMZM
---  Ref. Power Builder - reemplaza sp_pro308
--- Modificado por Armando Moreno 19/01/2002; la parte de los tipo de contratos
--- Modificado por Henry 10/9/2009 filtros requeridos por Sr. Omar Wong
--- Quitar el filtro de rangos.
--------------------------------------------
drop procedure sp_pr999sre;
create procedure sp_pr999sre(
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
a_subramo		char(255)	default "*")
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
			char(50), -- 	  _name_manzana
			integer;
begin

define v_name_subramo		varchar(50);
define _error_desc			varchar(50);
define _n_contrato			varchar(50);
define v_cedula				varchar(30);
define v_filtros2			char(255);
define v_filtros1			char(255);
define v_filtros			char(255);
define v_desc_cobertura		char(100);
define v_desc_contrato		char(50);
define _nombre_coas			char(50);
define v_descr_cia			char(50);
define v_desc_ramo			char(50);
define _nombre_cob			char(50);
define _nombre_con			char(50);
define _n_aseg				char(50);
define _cuenta				char(25);
define _no_documento		char(20);
define _no_doc				char(20);
define _res_comprobante		char(15);
define _cod_manzana			char(15);
define _cod_contratante		char(10);
define _no_registro			char(10);
define v_no_recibo			char(10);
define _no_poliza			char(10);
define _no_remesa			char(10);
define v_nopoliza			char(10);
define _periodo1			char(8);
define v_cod_contrato		char(5);
define _cod_traspaso		char(5);
define v_noendoso			char(5);
define _no_unidad			char(5);
define _cod_coasegur		char(3);
define v_cod_subramo		char(3);
define _cod_subramo			char(3);
define v_cobertura			char(3);
define _cod_origen			char(3);
define v_cod_tipo			char(3);
define v_cod_ramo			char(3);
define _t_ramo				char(1);
define _tipo				char(1);
define _porc_cont_partic	dec(5,2);
define _porc_proporcion		dec(5,2);
define _porc_comis_ase		dec(5,2);
define _porc_partic_coas	dec(7,4);
define _porc_partic_prima	dec(9,6);
define _prima_tot_ret_sum	dec(16,2);
define _prima_tot_sus_sum	dec(16,2);
define v_prima_suscrita		dec(16,2);
define v_suma_asegurada		dec(16,2);
define v_prima_cobrada		dec(16,2);
define v_rango_inicial		dec(16,2);
define _prima_tot_ret		dec(16,2);
define _porc_impuesto		dec(16,2);
define _porc_comision		dec(16,2);
define _prima_sus_tot		dec(16,2);
define _p_sus_tot_sum		dec(16,2);
define _prima_total			dec(16,2);
define v_rango_final		dec(16,2);
define v_prima_tipo			dec(16,2);
define _sum_fac_car			dec(16,2);
define _monto_reas			dec(16,2);
define _ret_casco			dec(16,2);
define _por_pagar			dec(16,2);
define _p_sus_tot			dec(16,2);
define v_prima_bq			dec(16,2);
define v_prima_ot			dec(16,2);
define v_prima_3			dec(16,2);
define _impuesto			dec(16,2);
define _comision			dec(16,2);
define v_prima_1			dec(16,2);
define v_prima1				dec(16,2);
define v_prima				dec(16,2);
define _tiene_comis_rea		smallint;
define v_tipo_contrato		smallint;
define _facilidad_car		smallint;
define v_porcentaje			smallint;
define _tipo_cont			smallint;
define _no_cambio			smallint;
define _traspaso			smallint;
define _cantidad			smallint;
define _bouquet				smallint;
define _serie				smallint;
define _valor				smallint;
define _flag				smallint;
define _cnt					smallint;
define _sac_notrx			integer;
define _renglon				integer;
define _error				integer;
define _fecha_suscripcion	date;
define _vigencia_inic		date;
define _vigencia_ini		date;
define _vigencia_fin		date;
define _fecha_recibo		date;
define _fecha				date;
define _name_manzana  char(50); 

set isolation to dirty read;

let v_descr_cia  = sp_sis01(a_compania);

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


--set debug file to "sp_pr999sr.trc";
--trace on;

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
	  from tmp_tabla_cob
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
	   SELECT trim(referencia)
		 INTO _name_manzana
		 FROM emiman05
		WHERE cod_manzana = _cod_manzana;
	  end if	
	
	foreach
		select fecha
		  into _fecha_recibo
		  from cobredet
		 where no_recibo = v_no_recibo
		exit foreach;
	end foreach
	
	select trim(nombre)
	  into v_name_subramo
	  from prdsubra
	 where cod_ramo = v_cod_ramo
	   and cod_subramo = v_cod_subramo;

	select count(*)
	  into _cnt
	  from emipouni
	 where no_poliza = _no_poliza;

	return	_no_documento,
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
			v_filtros, 
			v_descr_cia,
			_sum_fac_car,
			v_no_recibo,
			_res_comprobante,
			v_desc_contrato,
			_n_aseg,
			_fecha_suscripcion,
			_fecha_recibo,
			v_cedula,		
			v_name_subramo,
			_ret_casco,
			_cod_manzana,
			_name_manzana, 
			_cnt with resume;
end foreach

--drop table if exists tmp_tabla;

end
end procedure	  