--------------------------------------------
--Reporte de Verificación de Distribución de Reaseguro de Primas Suscritas
--execute procedure sp_rea38('001','001','2016-11','2016-11','01/11/2016','30/11/2016','*','*','*','*','002,020,023;','*','*','2015,2014,2013,2012,2011,2010,2009,2008;','*',1)
--22/07/2016 - Autor: Román Gordón.
--------------------------------------------
drop procedure sp_rea38;
create procedure sp_rea38(
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
returning	char(18)		as Poliza,
			char(10)		as Factura,
			char(5)			as Unidad,
			date			as Vigencia_inic,
			date			as Vigencia_final,
			varchar(50)		as Ramo,
			varchar(50)		as Subramo,
			varchar(50)		as Cobertura_Reaseguro,
			varchar(50)		as Contrato,			
			smallint		as Serie,
			varchar(50)		as Reasegurador,
			dec(5,2)		as P_Partic_contrato,
			dec(16,2)		as Prima_Suscrita,
			dec(5,2)		as Porc_Comision,
			dec(16,2)		as Comision,
			dec(5,2)		as Porc_Impuesto,
			dec(16,2)		as Impuesto,
			dec(16,2)		as Por_Pagar,
			varchar(150)	as Filtros;

define _error_desc			varchar(100);
define _nom_cober_reas		varchar(50);
define _nom_contrato		varchar(50);
define _nom_subramo			varchar(50);
define _nombre_coas			varchar(50);
define _nom_ramo			varchar(50);
define _no_documento		char(18);
define _no_factura			char(10);
define _no_poliza			char(10);
define _cod_contrato		char(5);
define _no_endoso			char(5);
define _no_unidad			char(5);
define _cod_cober_reas		char(3);
define _cod_coasegur		char(3);
define _porc_cont_partic	dec(5,2);
define _porc_comis_ase		dec(5,2);
define _porc_impuesto		dec(5,2);
define _porc_comision		dec(5,2);
define _prima_suscrita		dec(16,2);
define _monto_dist			dec(16,2);
define _por_pagar			dec(16,2);
define _impuesto			dec(16,2);
define _comision			dec(16,2);
define _tiene_comis_rea		smallint;		
define _tipo_contrato		smallint;
define _cnt_reas			smallint;		
define _serie				smallint;
define _error_isam			integer;
define _error				integer;
define _vigencia_inic		date;
define _vigencia_final		date;

--set debug file to 'sp_rea38.trc';
--trace on;

begin
on exception set _error,_error_isam,_error_desc
    --rollback work;
	return	'',
			'',
			'',
			null,
			null,
			'',
			'',
			'',
			'',
			_error,
			'',
			0.00,
			0.00,
			0.00,
			0.00,
			0.00,
			0.00,
			0.00,
			_error_desc;
end exception  

set isolation to dirty read;

call sp_rea27a(a_compania,a_agencia,a_periodo1,a_periodo2,a_fecha_desde,a_fecha_hasta,a_codsucursal,a_codgrupo,a_codagente,a_codusuario,a_codramo,a_reaseguro,a_contrato,a_serie,a_subramo,a_por_fecha)
returning _error,_error_desc;

if _error <> 0 then
	return	'',
			'',
			'',
			null,
			null,
			'',
			'',
			'',
			'',
			_error,
			'',
			0.00,
			0.00,
			0.00,
			0.00,
			0.00,
			0.00,
			0.00,
			_error_desc;
end if

foreach
	select no_documento,
		   no_unidad,
		   vigencia_ini,
		   vigencia_fin,
		   desc_ramo,
		   desc_subramo,
		   no_factura,
		   serie,
		   cod_cober_reas,
		   cod_contrato,
		   n_contrato,
		   p_suscrita
	  into _no_documento,
		   _no_unidad,
		   _vigencia_inic,
		   _vigencia_final,
		   _nom_ramo,
		   _nom_subramo,
		   _no_factura,
		   _serie,
		   _cod_cober_reas,
		   _cod_contrato,
		   _nom_contrato,
		   _prima_suscrita
	  from tmp_tabla
	 --group by no_documento,no_unidad,vigencia_ini,vigencia_fin,suma_asegurada,desc_ramo,desc_subramo,no_factura,serie,nom_endomov,cod_contrato
	 order by desc_ramo, desc_subramo, serie, no_documento, no_factura, no_unidad,cod_contrato

	select tipo_contrato
	  into _tipo_contrato
	  from reacomae
	 where cod_contrato = _cod_contrato;

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
	  into _nom_cober_reas
	  from reacobre
	 where cod_cober_reas = _cod_cober_reas;

	if _tipo_contrato in (1) then --retención y facultativo
		return	_no_documento,
				_no_factura,
				_no_unidad,
				_vigencia_inic,
				_vigencia_final,
				_nom_ramo,
				_nom_subramo,
				_nom_cober_reas,
				_nom_contrato,
				_serie,
				'',
				100.00,
				_prima_suscrita,
				0.00,
				0.00,
				0.00,
				0.00,
				0.00,
				_error_desc with resume;

	elif _tipo_contrato = 3 then

		select no_poliza,
			   no_endoso
		  into _no_poliza,
			   _no_endoso
		  from endedmae
		 where no_documento = _no_documento
		   and no_factura = _no_factura;

		foreach
			select cod_coasegur,
				   porc_partic_reas,
				   porc_impuesto,
				   porc_comis_fac
			  into _cod_coasegur,
				   _porc_cont_partic,
				   _porc_impuesto,
				   _porc_comision
			  from emifafac
			 where no_poliza = _no_poliza
			   and no_endoso = _no_endoso
			   and no_unidad = _no_unidad
			   and cod_cober_reas = _cod_cober_reas
			   and cod_contrato = _cod_contrato

			select nombre
			  into _nombre_coas
			  from emicoase
			 where cod_coasegur = _cod_coasegur;

			let _monto_dist = _prima_suscrita * _porc_cont_partic / 100;
			let _impuesto   = _monto_dist * _porc_impuesto / 100;
			let _comision   = _monto_dist * _porc_comision / 100;
			let _por_pagar  = _monto_dist - _impuesto - _comision;

			return	_no_documento,
					_no_factura,
					_no_unidad,
					_vigencia_inic,
					_vigencia_final,
					_nom_ramo,
					_nom_subramo,
					_nom_cober_reas,
					_nom_contrato,
					_serie,
					_nombre_coas,
					_porc_cont_partic,
					_monto_dist,
					_porc_comision,
					_comision,
					_porc_impuesto,
					_impuesto,
					_por_pagar,
					_error_desc with resume;
		end foreach
	else
		select count(*)
		  into _cnt_reas
		  from reacoase
		 where cod_contrato   = _cod_contrato
		   and cod_cober_reas = _cod_cober_reas;

		if _cnt_reas is null then
			let _cnt_reas = 0;
		end if		

		if _cnt_reas = 0 then
			return	_no_documento,
					_no_factura,
					_no_unidad,
					_vigencia_inic,
					_vigencia_final,
					_nom_ramo,
					_nom_subramo,
					_nom_cober_reas,
					_nom_contrato,
					_serie,
					'',
					0.00,
					0.00,
					0.00,
					0.00,
					0.00,
					0.00,
					0.00,
					_error_desc with resume;
		else
			let _porc_comis_ase = 0.00;

			foreach
				select cod_coasegur,
					   porc_cont_partic,
					   porc_comision
				  into _cod_coasegur,
					   _porc_cont_partic,
					   _porc_comis_ase
				  from reacoase
				 where cod_contrato   = _cod_contrato
				   and cod_cober_reas = _cod_cober_reas

				select nombre
				  into _nombre_coas
				  from emicoase
				 where cod_coasegur = _cod_coasegur;

				-- La comision se calcula por reasegurador
				if _tiene_comis_rea = 2 then 
					let _porc_comision = _porc_comis_ase;
				end if

				let _monto_dist = _prima_suscrita * _porc_cont_partic / 100;
				let _impuesto   = _monto_dist * _porc_impuesto / 100;
				let _comision   = _monto_dist * _porc_comision / 100;
				let _por_pagar  = _monto_dist - _impuesto - _comision;

				return	_no_documento,
						_no_factura,
						_no_unidad,
						_vigencia_inic,
						_vigencia_final,
						_nom_ramo,
						_nom_subramo,
						_nom_cober_reas,
						_nom_contrato,
						_serie,
						_nombre_coas,
						_porc_cont_partic,
						_monto_dist,
						_porc_comision,
						_comision,
						_porc_impuesto,
						_impuesto,
						_por_pagar,
						_error_desc with resume;

			end foreach --final reacoase
		end if --final count reacoase
	end if --final tipo contrato
end foreach --final tmp_tabla

end
end procedure;