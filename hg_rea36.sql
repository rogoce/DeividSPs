DROP PROCEDURE hg_rea36;
create procedure hg_rea36(
a_compania		char(3),
a_agencia		char(3),
a_periodo1		char(7),
a_periodo2		char(7),
a_fecha_desde	date,
a_fecha_hasta	date,
a_codsucursal	char(255)	default '*',
a_codgrupo		char(255)	default '*',
a_codagente		char(255)	default '*',
a_codusuario	char(255)	default '*',
a_codramo		char(255)	default '*',
a_reaseguro		char(255)	default '*',
a_contrato		char(255)	default '*',
a_serie			char(255)	default '*',
a_subramo		char(255)	default '*',
a_por_fecha		smallint	default 0)
returning	char(15)	as cod_manzana,
			varchar(50)	as nombre_manzana,
			varchar(50)	as Ramo,
			varchar(50)	as Subramo,
			varchar(50)	as Contrato,
			smallint	as Serie,
			char(18)	as Poliza,
			char(10)	as Factura,
			date	as Fecha_Emision,
			date	as Vigencia_inic,
			date	as Vigencia_final,
			varchar(50)	as asegurado,
			char(5)	as Unidad,
			dec(16,2)	as Suma_asegurada,
			dec(16,2)	as s_a_ret,
			dec(9,4)	as porc_s_a_ret,
			dec(16,2)	as s_a_cont,
			dec(9,4)	as porc_s_a_cont,
			dec(16,2)	as s_a_fac,
			dec(9,4)	as porc_s_a_fac,
			dec(16,2)	as Prima_suscrita,
			dec(16,2)	as Retencion_otros,
			dec(16,2)	as Retencion_RC,
			dec(16,2)	as Retencion_Casco,
			dec(9,4)	as Porc_retencion,
			dec(16,2)	as Contrato_otros,
			dec(16,2)	as Contrato_RC,
			dec(16,2)	as Contrato_Casco,
			dec(9,4)	as Porc_contrato,
			dec(16,2)	as Facultativo,
			dec(9,4)	as Porc_facult,
			dec(16,2)	as Otros_cont,
			dec(9,4)	as Porc_otros,
			dec(16,2)	as Facilidad_Car,
			dec(9,4)	as Porc_fac_car,
			varchar(50)	as Tipo_Endoso,
			char(5)     as Cod_Grupo,
			varchar(50) as Grupo,
			varchar(150)	as Filtros;


define _error_desc			varchar(100);
define _nom_contrato		varchar(50);
define _nom_endomov			varchar(50);
define _nom_subramo			varchar(50);
define _nom_ramo			varchar(50);
define _no_documento		char(18);
define _no_factura			char(10);
define _res_comprobante		char(8);
define _no_unidad			char(5);
define _res_origen,_cod_tipoprod			char(3);
define _porc_retencion		dec(9,4);
define _porc_contrato		dec(9,4);
define _porc_fac_car		dec(9,4);
define _porc_facult			dec(9,4);
define _porc_otros			dec(9,4);
define _prima_suscrita		dec(16,2);
define _suma_asegurada		dec(16,2);
define _facultativo			dec(16,2);
define _cont_casco			dec(16,2);
define _cont_otros			dec(16,2);
define _otros_cont			dec(16,2);
define _ret_casco			dec(16,2);
define _ret_otros			dec(16,2);
define _fac_car				dec(16,2);
define _cont_rc				dec(16,2);
define _ret_rc				dec(16,2);
define _serie				smallint;
define _error_isam			integer;
define _res_notrx			integer;
define _error				integer;
define _vigencia_final		date;
define _fecha_emision		date;
define _vigencia_inic		date;

define  _xsuma_asegurada	dec(16,2);
define 	_xcod_manzana	    char(15);
define 	_xreferencia	    varchar(50);
define  _xcod_asegurado,_no_poliza	    char(10);
define 	_asegurado	        varchar(50);
define 	_s_a_ret	        dec(16,2);
define 	_porc_s_a_ret	    dec(9,4);
define 	_s_a_cont	        dec(16,2);
define 	_porc_s_a_cont	    dec(9,4);
define 	_s_a_fac	        dec(16,2);
define 	_porc_s_a_fac	    dec(9,4);
define  _porc_partic_coas	dec(7,4);
define  _cod_grupo          char(5);
define  _grupo              varchar(50);



--set debug file to 'sp_rea36.trc';
--trace on;

begin
on exception set _error,_error_isam,_error_desc
    --rollback work;
	return	'',
			'',
			'',
			'',
			_error_desc,
			_error,
			'',
			'',
			null,
			null,
			null,
			'',
			'',
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
			0.00,
			0.00,
			0.00,
			0.00,
			0.00,
			'',
			'',
			'',
			'';

end exception  

set isolation to dirty read;

call sp_rea27a(a_compania,a_agencia,a_periodo1,a_periodo2,a_fecha_desde,a_fecha_hasta,a_codsucursal,a_codgrupo,a_codagente,a_codusuario,a_codramo,a_reaseguro,a_contrato,a_serie,a_subramo,a_por_fecha)
returning _error,_error_desc;

if _error <> 0 then
	return	'',
			'',
			'',
			'',
			_error_desc,
			_error,
			'',
			'',
			null,
			null,
			null,
			'',
			'',
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
			0.00,
			0.00,
			0.00,
			0.00,
			0.00,
			'',
			'',
			'',
			'';
end if

let	_xcod_manzana =	'';
let	_xreferencia =	'';
let	_xcod_asegurado =	'';
let	_asegurado =	'';
let	_s_a_ret = 0;
let	_porc_s_a_ret = 0;
let	_s_a_cont = 0;
let	_porc_s_a_cont = 0;
let	_s_a_fac = 0;
let	_porc_s_a_fac = 0;
let	_xsuma_asegurada = 0;

foreach
	select no_documento,
		   no_unidad,
		   vigencia_ini,
		   vigencia_fin,
		   suma_asegurada,
		   desc_ramo,
		   desc_subramo,
		   no_factura,
		   serie,
		   nom_endomov,
		   fecha_emision,
		   sum(p_suscrita),
		   sum(p_retenida),
		   sum(p_retenida_otros),
		   sum(p_ret_casco),
		   sum(p_bouquet),
		   sum(p_bouquet_otros),
		   sum(p_bouquet_casco),
		   sum(p_facultativo),
		   sum(p_otros),
		   sum(p_fac_car)
	  into _no_documento,
		   _no_unidad,
		   _vigencia_inic,
		   _vigencia_final,
		   _suma_asegurada,
		   _nom_ramo,
		   _nom_subramo,
		   _no_factura,
		   _serie,
		   _nom_endomov,
		   _fecha_emision,
		   _prima_suscrita,
		   _ret_rc,
		   _ret_otros,
		   _ret_casco,
		   _cont_rc,
		   _cont_otros,
		   _cont_casco,
		   _facultativo,
		   _otros_cont,
		   _fac_car
	  from tmp_tabla
	 group by no_documento,no_unidad,vigencia_ini,vigencia_fin,suma_asegurada,desc_ramo,desc_subramo,no_factura,serie,nom_endomov,fecha_emision
	 order by desc_ramo, desc_subramo, serie, no_documento, no_factura, no_unidad

	let _porc_retencion = 0.00;
	let _porc_contrato = 0.00;
	let _porc_fac_car = 0.00;
	let _porc_facult = 0.00;
	let _porc_otros = 0.00;

	if _prima_suscrita <> 0 then
		let _porc_retencion = ((_ret_rc + _ret_otros + _ret_casco) / _prima_suscrita) * 100;
		let _porc_contrato = ((_cont_rc + _cont_otros + _cont_casco) / _prima_suscrita) * 100;
		let _porc_fac_car = (_fac_car / _prima_suscrita) * 100;
		let _porc_facult = (_facultativo / _prima_suscrita) * 100;
		let _porc_otros = (_otros_cont / _prima_suscrita) * 100;
	end if

	foreach
		select n_contrato
		  into _nom_contrato
		  from tmp_tabla
		 where no_factura = _no_factura
		   and no_unidad = _no_unidad
		   and serie = _serie
		 order by n_contrato asc
		exit foreach;
	end foreach
	
	let _s_a_ret = 0;
	let _s_a_cont = 0;			
	let _s_a_fac = 0;
	let _xsuma_asegurada = 0;
	let _xcod_manzana = '';
	let _xreferencia = '';	
	let _xcod_asegurado = '';
	
	foreach
	   select a.suma_asegurada,
			  a.cod_asegurado,
			  a.cod_manzana
	     into _xsuma_asegurada,
			  _xcod_asegurado,
			  _xcod_manzana
		 from emipouni a, endedmae b
		where b.no_factura = _no_factura
		   and a.no_poliza = b.no_poliza
		  and a.no_unidad = _no_unidad
		  and b.no_documento = _no_documento
		order by a.suma_asegurada desc, a.no_unidad
		exit foreach;
	end foreach
	
	if _xcod_asegurado is null or trim(_xcod_asegurado) = "" then
		select --a.suma_asegurada,
			   a.cod_cliente
			   --a.cod_manzana
		  into --_xsuma_asegurada,
		       _xcod_asegurado
			   --_xcod_manzana
		  from endeduni a, endedmae b
		 where a.no_poliza = b.no_poliza
           and a.no_endoso = b.no_endoso
           and a.no_unidad = _no_unidad
           and b.no_factura = _no_factura
           and b.actualizado = 1;		   		
	end if
	
	SELECT referencia
	  INTO _xreferencia
	  FROM emiman05
	 WHERE cod_manzana = _xcod_manzana;					

	let	_s_a_ret = 0;
	let	_porc_s_a_ret = 0;
	let	_s_a_cont = 0;
	let	_porc_s_a_cont = 0;
	let	_s_a_fac = 0;
	let	_porc_s_a_fac = 0;		
		
	let	_s_a_ret = (_suma_asegurada * _porc_retencion)/100;
	let	_porc_s_a_ret = round(_porc_retencion,2);
	let	_s_a_cont = (_suma_asegurada * _porc_contrato)/100;
	let	_porc_s_a_cont = round(_porc_contrato,2);
	let	_s_a_fac = (_suma_asegurada * _porc_facult)/100;
	let	_porc_s_a_fac = round(_porc_facult,2);
		
	SELECT nombre
	  INTO _asegurado
	  FROM cliclien
	 WHERE cod_cliente = _xcod_asegurado;
		
    let _no_poliza = sp_sis21(_no_documento);
	
	select cod_tipoprod,
           cod_grupo	
	  into _cod_tipoprod,
	       _cod_grupo
	  from emipomae
	 where no_poliza = _no_poliza;
	 
	select nombre
      into _grupo
      from cligrupo
     where cod_grupo = _cod_grupo;	  
	 
	if _cod_tipoprod = '001' then	--Cosas mayoritario
		select porc_partic_coas
		  into _porc_partic_coas
		  from emicoama
		 where no_poliza = _no_poliza
		   and cod_coasegur = '036'; 			

		if _porc_partic_coas is null then
			let _porc_partic_coas = 100;
		end if
		
		let	_s_a_ret = (_s_a_ret * _porc_partic_coas)/100;
		let	_s_a_cont = (_s_a_cont * _porc_partic_coas)/100;
		let	_s_a_fac = (_s_a_fac * _porc_partic_coas)/100;
		let	_suma_asegurada = (_suma_asegurada * _porc_partic_coas)/100;
		
	end if

	return	_xcod_manzana,
			_xreferencia,
			_nom_ramo,
			_nom_subramo,
			_nom_contrato,
			_serie,
			_no_documento,
			_no_factura,
			_fecha_emision,
			_vigencia_inic,
			_vigencia_final,
			_asegurado,
			_no_unidad,
			_suma_asegurada,
			_s_a_ret,
			_porc_s_a_ret,
			_s_a_cont,
			_porc_s_a_cont,
			_s_a_fac,
			_porc_s_a_fac,
			_prima_suscrita,
			_ret_otros,
			_ret_rc,
			_ret_casco,
			_porc_retencion,
			_cont_otros,
			_cont_rc,
			_cont_casco,
			_porc_contrato,
			_facultativo,
			_porc_facult,
			_otros_cont,
			_porc_otros,
			_fac_car,
			_porc_fac_car,
			_nom_endomov,			
            _cod_grupo,
  			_grupo, 
			_error_desc with resume;
end foreach
end
end procedure