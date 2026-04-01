-- Procedure de Generación del detalle de Pasivo por Cobertura Restante para IFRS XVII
-- Creado    : 01/12/2014 - Autor: Román Gordón
-- execute procedure sp_niif012b('2025-06','2025-06','001,002,003,004,005,006,007,008,009,010,011,012,013,014,015,016,017,018,019,020,021,022,023;')
-- SIS v.2.0 - DEIVID, S.A.

drop procedure sp_niif12c;
create procedure sp_niif12c()
returning 	char(20) as no_documento,--
			varchar(50) as categoria_contable,
			varchar(50) as segm_triangulo,
			varchar(50) as tipo_clasificacion,--
			varchar(50) as ramo;	


define _error_desc			char(50);
define _estatus_recl		varchar(20);
define _desc_clasif		varchar(50);
define _categoria_contable	varchar(50);
define _reasegurador_ret	varchar(50);
define _segm_triangulo		varchar(50);
define _reasegurador		varchar(50);
define _nom_subramo			varchar(50);
define _nom_grupo			varchar(50);
define _tipo_reas			varchar(50);
define _nom_ramo			varchar(50);
define _no_documento		char(20);
define _no_remesa			char(10);
define _nueva_renov			char(10);
define _no_poliza			char(10);
define _cod_cober_reas		char(5);
define _cod_contrato		char(5);
define _no_unidad			char(5);
define _no_endoso			char(5);
define _cod_grupo			char(5);
define _cod_coasegur_ret	char(3);
define _cod_coasegur		char(3);
define _cod_subramo			char(3);
define _cod_ramo			char(3);
define _periodo_end			char(7);
define _periodo				char(7);
define _tipo				char(1);
define _estatus_poliza		smallint;
define _clasificacion		smallint;
define _tipo_contrato		smallint;
define _anio_cobro_desde	smallint;
define _anio_cobro_hasta	smallint;
define _anio_cobro			smallint;
define _mes_periodo			smallint;
define _mes_vig				smallint;
define _fronting			smallint;
define _imp_gob				smallint;
define _cnt_cob				smallint;
define _vigencia_fin_endoso	date;
define _fecha_emision_end	date;
define _fecha_suscripcion	date;
define _fecha_suspension	date;
define _vigencia_endoso		date;
define _cubierto_hasta		date;
define _vigencia_final		date;
define _vigencia_inic		date;
define _fecha_salud			date;
define _fecha_cobro			date;
define _error_isam			integer;
define _renglon				integer;
define _error				integer;
define _impuesto_rea		dec(16,2);
define _impuesto_seg		dec(16,2);
define _comision_agt		dec(16,2);
define _comision_rea		dec(16,2);
define _pagado_bruto_rea	dec(16,2);
define _suma_asegurada		dec(16,2);
define _suma_aseg_rea		dec(16,2);
define _prima_devengada		dec(16,2);
define _monto_pagado		dec(16,2);
define _pagado_bruto		dec(16,2);
define _monto_pag			dec(16,2);
define _porc_coas			dec(9,6);
define _porc_cont_partic	dec(9,6);
define _porc_comis_agt		dec(9,6);
define _porc_comis_rea		dec(9,6);
define _porc_comis_fac		dec(9,6);
define _porc_impuesto_fac	dec(9,6);
define _porc_impuesto_rea	dec(9,6);
define _porc_impuesto_seg	dec(9,6);

set isolation to dirty read;

begin 
on exception set _error, _error_isam, _error_desc
--	if _no_poliza is null then
--		let _no_poliza = '';
--	end if
	
--	if _no_documento is null then
--		let _no_documento = '';
--	end if
	
--	let _error_desc = 'poliza: ' || trim(_no_poliza) || trim(_no_documento) || trim(_error_desc);
--	return _error,
--		   _error_isam,
--		   _error_desc;
end exception


--set debug file to "sp_pro545.trc";
--trace on;

FOREACH
	select distinct emi.no_documento,
		    ram.nombre
	  into _no_documento,
		    _nom_ramo
	  from emipomae emi
	 inner join prdramo ram on ram.cod_ramo = emi.cod_ramo
	 where (cod_grupo in ('00000','1000') or cod_formapag = '091' )
	   and emi.actualizado = 1

	let _categoria_contable = '';
	let _segm_triangulo = '';
	let _desc_clasif = '';
	
	let _no_poliza = sp_sis21(_no_documento);
	
	call sp_niif13(_no_poliza,'','',1)
	returning _error,_error_isam,_error_desc,_desc_clasif,_categoria_contable,_segm_triangulo;
	
	RETURN  _no_documento,
			_categoria_contable,
			_segm_triangulo,
			_desc_clasif,
			_nom_ramo WITH RESUME;
END FOREACH
--return 0,0,'Carga Exitosa';

end
end procedure;