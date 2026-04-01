-- Reporte de MarkUp de Cartera de Coopertivas
-- Creado: 03/08/2023	- Autor: Henry Giron

drop procedure sp_pro870;

create procedure sp_pro870(
a_compania		char(3),
a_agencia		char(3),
a_periodo_desde	char(7),
a_periodo_hasta	char(7))
	returning 	char(10) as NroPoliza,
				char(20) as Poliza,
				char(10) as CodContratante,
				varchar(100) as Contratante,
				char(10) as CodAsegurado,
				varchar(100) as Asegurado,
				date as Vigencia_Inicial,
				date as Vigencia_Final,
				varchar(50) as Estatus_Poliza,
				char(1) as nueva_renov,
				char(5) as CodGrupo,
				varchar(50) as Grupo,
				char(3) as CodRamo,
				varchar(50) as Ramo,
				char(3) as CodSubramo,
				varchar(50) as Subramo,
				smallint as NroPagos,
				char(5) as CodCorredor,
				varchar(100) as Corredor,
				dec(5,2) as Porc_Partic_Agt,
				dec(5,2) as Porc_Comision,
				dec(16,2) as Prima_Neta,
				dec(16,2) as Prima_Suscrita,
				dec(16,2) as Suma_Asegurada,
				dec(16,2) as Monto_Cobrado,
				dec(16,2) as Monto_Neto_Cobrado,
				char(5) as CodProducto,
				varchar(50) as Producto,
				char(2) as ProductoMarkUp,
				char(10) as Remesa,
				integer as Renglon,
				char(7) as PeriodoCobro,
				date as FechaCobro,
				varchar(50)	as	Tipo_Auto,
				varchar(50)	as	Motivo_No_Renovacion,
				varchar(50)	as	compania_nombre	;
								
define _no_poliza			char(10);
define _no_documento		char(20);
define _cod_contratante		char(10);
define _nom_contratante		varchar(100);
define _cod_asegurado		char(10);
define _nom_asegurado		varchar(100);
define _vigencia_inic		date;
define _vigencia_final		date;
define _estatus_poliza		varchar(50); --smallint;
define _nueva_renov			char(1);
define _cod_grupo			char(5);
define _nom_grupo			varchar(50);
define _n_tipoauto			varchar(50);
define _motiv_no_renov		varchar(50);
define _cod_ramo			char(3);
define _ramo				varchar(50);
define _cod_subramo			char(3);
define _subramo				varchar(50);
define _no_pagos			smallint;
define _cod_agente			char(5);
define _nom_agente			varchar(100);
define _porc_partic_agt		dec(5,2);
define _porc_comis_agt		dec(5,2);
define _prima_neta_pol		dec(16,2);
define _prima_susc_pol		dec(16,2);
define _suma_asegurada		dec(16,2);
define _prima_cob_dev		dec(16,2);
define _mto_cob_neto_pol	dec(16,2);
define _cod_producto		char(5);
define _producto			varchar(50);
define _producto_markup		char(2);
define _no_remesa			char(10);
define _renglon				integer;
define _periodo_cob			char(7);
define _fecha_cob			date;

Define _error				integer;
Define _error_desc			char(100);
define _compania_nombre 	varchar(50);

on exception set _error
    --rollback work;
	return " "," "," "," "," ","Error al Ingresar los Registro",null,null,""," "," "," "," "," "," "," ",0," "," ",0,0,0,0,0,0,0," "," ",''," ",_error," ",null,"","","";
end exception  

LET _compania_nombre = sp_sis01('001');
call sp_markup_serafin(a_compania,a_agencia,a_periodo_desde,a_periodo_hasta) returning _error,_error_desc;

if _error <> 0 then
	return " "," "," "," "," ","Error al Ingresar los Registro",null,null,""," "," "," "," "," "," "," ",0," "," ",0,0,0,0,0,0,0," "," ",''," ",_error," ",null,"","","";
end if  

set isolation to dirty read;
--set debug file to "sp_pro870.trc";
--trace on;

foreach
select no_poliza,
		no_documento,
		cod_contratante,
		nom_contratante,
		cod_asegurado,
		nom_asegurado,
		vigencia_inic,
		vigencia_final,
		upper((case when estatus_poliza = '1' then "Vigentes" when estatus_poliza = '2' then "Canceladas" when estatus_poliza = '3' then "Vencidas" when estatus_poliza = '4' then "Anulada" else "Todas" end)) estatus_poliza,
		nueva_renov,
		cod_grupo,
		nom_grupo,
		cod_ramo,
		ramo,
		cod_subramo,
		subramo,
		no_pagos,
		cod_agente,
		nom_agente,
		porc_partic_agt,
		porc_comis_agt,
		prima_neta_pol,
		prima_susc_pol,
		suma_asegurada,
		prima_cob_dev,
		mto_cob_neto_pol,
		cod_producto,
		producto,
		upper((case when producto_markup = '0' then "NO" else "SI" end)) producto_markup,
		no_remesa,
		renglon,
		periodo_cob,
		fecha_cob,
		n_tipoauto,
		motiv_no_renov
	into _no_poliza,
		_no_documento,
		_cod_contratante,
		_nom_contratante,
		_cod_asegurado,
		_nom_asegurado,
		_vigencia_inic,
		_vigencia_final,
		_estatus_poliza,
		_nueva_renov,
		_cod_grupo,
		_nom_grupo,
		_cod_ramo,
		_ramo,
		_cod_subramo,
		_subramo,
		_no_pagos,
		_cod_agente,
		_nom_agente,
		_porc_partic_agt,
		_porc_comis_agt,
		_prima_neta_pol,
		_prima_susc_pol,
		_suma_asegurada,
		_prima_cob_dev,
		_mto_cob_neto_pol,
		_cod_producto,
		_producto,
		_producto_markup,
		_no_remesa,
		_renglon,
		_periodo_cob,
		_fecha_cob,
		_n_tipoauto,
		_motiv_no_renov
	from tmp_analisis_cartera		

	
		return _no_poliza,
				_no_documento,
				_cod_contratante,
				_nom_contratante,
				_cod_asegurado,
				_nom_asegurado,
				_vigencia_inic,
				_vigencia_final,
				_estatus_poliza,
				_nueva_renov,
				_cod_grupo,
				_nom_grupo,
				_cod_ramo,
				_ramo,
				_cod_subramo,
				_subramo,
				_no_pagos,
				_cod_agente,
				_nom_agente,
				_porc_partic_agt,
				_porc_comis_agt,
				_prima_neta_pol,
				_prima_susc_pol,
				_suma_asegurada,
				_prima_cob_dev,
				_mto_cob_neto_pol,
				_cod_producto,
				_producto,
				_producto_markup,
				_no_remesa,
				_renglon,
				_periodo_cob,
				_fecha_cob,
                _n_tipoauto,
				_motiv_no_renov,
				_compania_nombre				
			with resume;
end foreach


end procedure	
                                                                                                                                                                                                                                          
