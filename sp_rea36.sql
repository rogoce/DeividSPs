--------------------------------------------
--Reporte de Verificación de Distribución de Reaseguro de Primas Suscritas
--execute procedure sp_rea36('001','001','2016-11','2016-11','01/11/2016','30/11/2016','*','*','*','*','002,020,023;','*','*','2015,2014,2013,2012,2011,2010,2009,2008;','*',1)
--22/07/2016 - Autor: Román Gordón.
--------------------------------------------
drop procedure sp_rea36;
create procedure sp_rea36(
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
returning	varchar(50)		as Contrato,
			smallint		as Serie,
			char(18)		as Poliza,
			char(5)			as Unidad,
			date			as Vigencia_inic,
			date			as Vigencia_final,
			dec(16,2)		as Suma_asegurada,
			varchar(50)		as Ramo,
			varchar(50)		as Subramo,
			dec(16,2)		as Prima_suscrita,
			dec(16,2)		as Retencion_otros,
			dec(16,2)		as Retencion_RC,
			dec(16,2)		as Retencion_Casco,
			dec(9,4)		as Porc_retencion,
			dec(16,2)		as Contrato_otros,
			dec(16,2)		as Contrato_RC,
			dec(16,2)		as Contrato_Casco,
			dec(9,4)		as Porc_contrato,
			dec(16,2)		as Facultativo,
			dec(9,4)		as Porc_facult,
			dec(16,2)		as Otros_cont,
			dec(9,4)		as Porc_otros,
			dec(16,2)		as Facilidad_Car,
			dec(9,4)		as Porc_fac_car,
			char(10)		as Factura,
			varchar(50)		as Tipo_Endoso,
			date			as Fecha_Emision,
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
define _res_origen			char(3);
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

--set debug file to 'sp_rea36.trc';
--trace on;

begin
on exception set _error,_error_isam,_error_desc
    --rollback work;
	return	_error_desc,
			_error,
			'',
			'',
			null,
			null,
			0.00,
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
			'',
			'',
			null,
			'';
end exception  

set isolation to dirty read;

call sp_rea27a(a_compania,a_agencia,a_periodo1,a_periodo2,a_fecha_desde,a_fecha_hasta,a_codsucursal,a_codgrupo,a_codagente,a_codusuario,a_codramo,a_reaseguro,a_contrato,a_serie,a_subramo,a_por_fecha)
returning _error,_error_desc;

if _error <> 0 then
	return	_error_desc,
			_error,
			'',
			'',
			null,
			null,
			0.00,
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
			'',
			'',
			null,
			'';
end if

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

	return	_nom_contrato,
			_serie,
			_no_documento,
			_no_unidad,
			_vigencia_inic,
			_vigencia_final,
			_suma_asegurada,
			_nom_ramo,
			_nom_subramo,
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
			_no_factura,
			_nom_endomov,
			_fecha_emision,
			_error_desc with resume;
end foreach
end
end procedure;