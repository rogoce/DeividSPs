----------------------------------------------------------
--Proceso de Pre-Renovaciones
--Creado    : 02/02/2016 - Autor: Román Gordón
----------------------------------------------------------
--execute procedure sp_pro382('001','001','2016-02','2016-02')

drop procedure sp_pro382;
create procedure sp_pro382(
a_compania			char(3),
a_agencia			char(3),
a_periodo1			char(7),
a_periodo2			char(7))
returning	char(21)		as Poliza, 					--_no_documento,
			char(5)			as Unidad,					--_no_unidad,
			varchar(50)		as Ramo,					--_nom_ramo,
			varchar(50)		as SubRamo,					--_nom_subramo,
			varchar(100)	as Contratante,				--_nom_cliente,
			varchar(30)		as Cedula,					--_cedula
			varchar(100)	as Asegurado,				--_nom_asegurado,
			varchar(30)		as Cedula_Asegurado,		--_cedula_asegurado,
			char(5)			as Cod_Corredor,			--_cod_agente,
			varchar(50)		as Corredor,				--_nom_agente,
			date			as Vigencia_Inicial,		--_vigencia_inic,
			date			as Vigencia_Final,			--_vigencia_final,
			dec(16,2)		as Prima,					--_prima,
			dec(5,2)		as Porc_Descuento,			--_porc_descuento,
			dec(16,2)		as Descuento,				--_descuento,
			dec(16,2)		as Prima_Neta,				--_prima_neta,
			dec(5,2)		as Porc_Impuesto,			--_porc_impuesto,
			dec(16,2)		as Impuesto,				--_impuesto,
			dec(16,2)		as Prima_Bruta,				--_prima_bruta,
			dec(16,2)		as Suma_Asegurada,			--_suma_asegurada,
			dec(16,2)		as Prima_Bruta_Anterior,	--_prima_bruta_ant,
			dec(16,2)		as Suma_Asegurada_Anterior,	--_suma_aseg_ant,
			varchar(50)		as Producto,				--_nom_producto,
			varchar(50)		as Acreedor,				--_nom_acreedor,
			varchar(30)		as Motor,					--_no_motor,
			varchar(50)		as Tipo_Vehiculo,			--_nom_tipoveh,
			varchar(20)		as Uso_Auto,				--_nom_uso_auto,
			varchar(50)		as Tipo_Auto,				--_tipo_auto,
			smallint		as Ano_Auto,				--_ano_auto,
			smallint		as Ano_Tarifa,				--_ano_tarifa,
			dec(16,2)		as Valor_Auto,				--_valor_auto,
			varchar(50)		as Marca,					--_nom_marca,
			varchar(50)		as Modelo,					--_nom_modelo,
			varchar(50)		as Color,					--_nom_color,
			varchar(30)		as Chasis,					--_no_chasis,
			varchar(30)		as Vin,						--_vin,
			varchar(10)		as Placa,					--_placa,
			varchar(10)		as Placa_Taxi,				--_placa_taxi,
			varchar(10)		as Auto_Nuevo,				--_desc_nuevo,
			dec(5,2)		as Porc_desc_RC,			--_porc_desc_rc,
			dec(5,2)		as Porc_desc_Tabla,			--_porc_desc_tabla,
			dec(5,2)		as Porc_desc_Modelo,		--_porc_desc_modelo,
			dec(5,2)		as Porc_desc_Flota,			--_porc_desc_flota,
			dec(5,2)		as Porc_desc_Sinis,			--_porc_desc_sinis,
			dec(16,2)		as Prima_Lesiones,			--_lesiones_corp_prima,
			varchar(30)		as Lesiones_Limites,		--_lesiones_corp_limite,
			varchar(30)		as Lesiones_Desc_Limites,	--_lesiones_corp_desc_limite,
			varchar(30)		as Lesiones_Deducible,		--_lesiones_corp_deducible,
			dec(16,2)		as Danos_Prima,				--_danos_prima,
			varchar(30)		as Danos_Limites,			--_danos_limite,
			varchar(30)		as Danos_Desc_Limites,		--_danos_desc_limite,
			varchar(30)		as Danos_Deducible,			--_danos_deducible,
			dec(16,2)		as Gastos_Med_Prima,		--_gastos_med_prima,
			varchar(30)		as Gastos_Med_Limites,		--_gastos_med_limite,
			varchar(30)		as Gastos_Med_Desc_Limites,	--_gastos_med_desc_limite,
			varchar(30)		as Gastos_Med_Deducible,	--_gastos_med_deducible,
			dec(16,2)		as Compresivo_Prima,		--_comprensivo_prima,
			varchar(30)		as Comprensivo_Limites,			--_comprensivo_limite,
			varchar(30)		as Comprensivo_Desc_Limites,	--_comprensivo_desc_limite,
			varchar(30)		as Comprensivo_Deducible,		--_comprensivo_deducible,
			dec(16,2)		as Colision_Prima,				--_colision_prima,
			varchar(30)		as Colision_Limites,			--_colision_limite,
			varchar(30)		as Colision_Desc_Limites,		--_colision_desc_limite,
			varchar(30)		as Colision_Deducible,			--_colision_deducible,
			dec(16,2)		as Incendio_Prima,				--_incendio_prima,
			varchar(30)		as Incencio_Limites,			--_incendio_limite,
			varchar(30)		as Incendio_Desc_Limites,		--_incendio_desc_limite,
			varchar(30)		as Incendio_Deducible,			--_incendio_deducible,
			dec(16,2)		as Asistencia_Vial_Prima,			--_asistencia_vial_prima,
			varchar(30)		as Asistencia_Vial_Limites,			--_asistencia_vial_limite,
			varchar(30)		as Asistencia_Vial_Desc_Limites,	--_asistencia_vial_desc_limite,
			varchar(30)		as Asistencia_Vial_Deducible,		--_asistencia_vial_deducible,
			dec(16,2)		as Robo_Prima,					--_robo_prima,
			varchar(30)		as Robo_Limites,				--_robo_limite,
			varchar(30)		as Robo_Desc_Limites,			--_robo_desc_limite,
			varchar(30)		as Robo_Deducible,				--_robo_deducible,
			dec(16,2)		as Muerte_Prima,				--_muerte_prima,
			varchar(30)		as Muerte_Limites,				--_muerte_limite,
			varchar(30)		as Muerte_Desc_Limites,			--_muerte_desc_limite,
			varchar(30)		as Muerte_Deducible,			--_muerte_deducible,
			dec(16,2)		as Invalidez_Prima,				--_invalidez_prima,
			varchar(30)		as Invalidez_Limites,			--_invalidez_deducible,
			varchar(30)		as Invalidez_Desc_Limites,		--_invalidez_desc_limite,
			varchar(30)		as Invalidez_Deducible,			--_invalidez_deducible,
			dec(16,2)		as Ancon_Plus_Prima,			--_ancon_plus_prima,
			varchar(30)		as Ancon_Plus_Limites,			--_ancon_plus_limite,
			varchar(30)		as Ancon_Plus_Desc_Limites,		--_ancon_plus_desc_limite,
			varchar(30)		as Ancon_Plus_Deducible,		--_ancon_plus_deducible;
			dec(16,2)		as Naviera_Prima,				--_naviera_prima,
			varchar(30)		as Naviera_Limites,				--_naviera_limite,
			varchar(30)		as Naviera_Desc_Limites,		--_naviera_desc_limite,
			varchar(30)		as Naviera_Deducible,			--_naviera_deducible;
			dec(16,2)		as Perdida_Total_Prima,			--_perdida_total_prima,
			varchar(30)		as Perdida_Total_Limites,		--_perdida_total_limite,
			varchar(30)		as Perdida_Total_Desc_Limites,	--_perdida_total_desc_limite,
			varchar(30)		as Perdida_Totals_Deducible,	--_perdida_total__deducible;
			dec(16,2)		as Rotura_Prima,				--_rotura_prima,
			varchar(30)		as Rotura_Limites,				--_rotura_limite,
			varchar(30)		as Rotura_Desc_Limites,			--_rotura_desc_limite,
			varchar(30)		as Rotura_Deducible,			--_rotura_deducible;
			dec(16,2)		as Transporte_Prima,			--_transporte_plus_prima,
			varchar(30)		as Transporte_Limites,			--_transporte_limite,
			varchar(30)		as Transporte_Desc_Limites,		--_transporte_desc_limite,
			varchar(30)		as Transporte_Deducible;		--_transporte_deducible;

define _error_desc					varchar(255);
define _nom_asegurado				varchar(100);
define _nom_cliente					varchar(100);
define _nom_acreedor				varchar(50);
define _nom_producto				varchar(50);
define _nom_subramo					varchar(50);
define _nom_tipoveh					varchar(50);
define _nom_agente					varchar(50);
define _nom_modelo					varchar(50);
define _nom_marca					varchar(50);
define _nom_color					varchar(50);
define _tipo_auto					varchar(50);
define _nom_ramo					varchar(50);
define _asistencia_vial_desc_limite	varchar(30);
define _perdida_total_desc_limite	varchar(30);
define _asistencia_vial_deducible	varchar(30);
define _lesiones_corp_desc_limite	varchar(30);
define _perdida_total_deducible		varchar(30);
define _lesiones_corp_deducible		varchar(30);
define _comprensivo_desc_limite		varchar(30);
define _gastos_med_desc_limite		varchar(30);
define _transporte_desc_limite		varchar(30);
define _asistencia_vial_limite		varchar(30);
define _ancon_plus_desc_limite		varchar(30);
define _comprensivo_deducible		varchar(30);
define _invalidez_desc_limite		varchar(30);
define _perdida_total_limite		varchar(30);
define _lesiones_corp_limite		varchar(30);
define _gastos_med_deducible		varchar(30);
define _transporte_deducible		varchar(30);
define _colision_desc_limite		varchar(30);
define _incendio_desc_limite		varchar(30);
define _ancon_plus_deducible		varchar(30);
define _invalidez_deducible			varchar(30);
define _naviera_desc_limite			varchar(30);
define _comprensivo_limite			varchar(30);
define _colision_deducible			varchar(30);
define _incendio_deducible			varchar(30);
define _rotura_desc_limite			varchar(30);
define _muerte_desc_limite			varchar(30);
define _transporte_limite			varchar(30);
define _danos_desc_limite			varchar(30);
define _gastos_med_limite			varchar(30);
define _ancon_plus_limite			varchar(30);
define _naviera_deducible			varchar(30);
define _rotura_deducible			varchar(30);
define _invalidez_limite			varchar(30);
define _robo_desc_limite			varchar(30);
define _muerte_deducible			varchar(30);
define _cedula_asegurado			varchar(30);
define _danos_deducible				varchar(30);
define _colision_limite				varchar(30);
define _incendio_limite				varchar(30);
define _naviera_limite				varchar(30);
define _robo_deducible				varchar(30);
define _rotura_limite				varchar(30);
define _muerte_limite				varchar(30);
define _danos_limite				varchar(30);
define _robo_limite					varchar(30);
define _cedula						varchar(30);
define _nom_uso_auto				varchar(10);
define _no_chasis					char(30);
define _no_motor					char(30);
define _vin							char(30);
define _no_documento				char(20);
define _no_poliza_maestro			char(10);
define _cod_contratante				char(10);
define _cod_asegurado				char(10);
define _no_poliza_e					char(10);
define _placa_taxi					char(10);
define _no_poliza					char(10);
define _placa						char(10);
define _usuario						char(8);
define _periodo						char(7);
define _cod_producto				char(5);
define _cod_acreedor				char(5);
define _cod_agente					char(5);
define _cod_modelo					char(5);
define _cod_marca					char(5);
define _no_unidad					char(5);
define _cod_tipoauto				char(3);
define _cod_impuesto				char(3);
define _cod_tipoveh					char(3);
define _cod_subramo					char(3);
define _cod_color					char(3);
define _cod_ramo					char(3);
define _desc_nuevo					char(2);
define _uso_auto					char(1);
define _null						char(1);
define _asistencia_vial_prima		dec(16,2);
define _lesiones_corp_prima			dec(16,2);
define _perdida_total_prima			dec(16,2);
define _comprensivo_prima			dec(16,2);
define _transporte_prima			dec(16,2);
define _ancon_plus_prima			dec(16,2);
define _gastos_med_prima			dec(16,2);
define _prima_bruta_ant				dec(16,2);
define _invalidez_prima				dec(16,2);
define _colision_prima				dec(16,2);
define _incendio_prima				dec(16,2);
define _suma_asegurada				dec(16,2);
define _suma_aseg_ant				dec(16,2);
define _naviera_prima				dec(16,2);
define _rotura_prima				dec(16,2);
define _muerte_prima				dec(16,2);
define _danos_prima					dec(16,2);
define _prima_bruta					dec(16,2);
define _robo_prima					dec(16,2);
define _prima_neta					dec(16,2);
define _valor_auto					dec(16,2);
define _descuento					dec(16,2);
define _impuesto					dec(16,2);
define _prima						dec(16,2);
define _porc_desc_modelo			dec(5,2);
define _porc_desc_tabla				dec(5,2);
define _porc_desc_flota				dec(5,2);
define _porc_desc_sinis				dec(5,2);
define _factor_impuesto				dec(5,2);
define _porc_descuento				dec(5,2); 
define _porc_impuesto				dec(5,2); 
define _porc_desc_rc				dec(5,2);
define _cnt_existe					smallint;
define _ano_tarifa					smallint;
define _ano_auto					smallint;
define _nuevo						smallint;
define _error_isam					integer;
define _renglon						integer;
define _error						integer;
define _vigencia_final				date;
define _vigencia_inic				date;

set isolation to dirty read;

begin
on exception set _error,_error_isam,_error_desc
	--let _error_desc = 'Excepción de DB. Póliza: ' || trim(_no_documento) || _error_desc;
	--return _error,_error_desc;
end exception

--set debug file to "sp_pro382.trc";
--trace on;

foreach
	select no_documento,
		   no_unidad,
		   cod_ramo,
		   cod_subramo,
		   cod_contratante,
		   cod_asegurado,
		   cod_agente,
		   vigencia_inic,
		   vigencia_final,
		   prima,
		   porc_descuento,
		   descuento,
		   prima_neta,
		   porc_impuesto,
		   impuesto,
		   prima_bruta,
		   suma_asegurada,
		   prima_bruta_ant,
		   suma_aseg_ant,
		   cod_producto,
		   cod_acreedor,
		   no_motor,
		   cod_tipoveh,
		   uso_auto,
		   ano_auto,
		   ano_tarifa,
		   cod_color,
		   cod_marca,
		   cod_modelo,
		   valor_auto,
		   no_chasis,
		   porc_desc_rc,
		   porc_desc_tabla,
		   porc_desc_modelo,
		   porc_desc_flota,
		   porc_desc_sinis,
		   vin,
		   placa,
		   placa_taxi,
		   nuevo,
		   lesiones_corp_limite,
		   lesiones_corp_desc_limite,
		   lesiones_corp_prima,
		   lesiones_corp_deducible,
		   danos_limite,
		   danos_desc_limite,
		   danos_prima,
		   danos_deducible,
		   gastos_med_limite,
		   gastos_med_desc_limite,
		   gastos_med_prima,
		   gastos_med_deducible,
		   comprensivo_limite,
		   comprensivo_desc_limite,
		   comprensivo_prima,
		   comprensivo_deducible,
		   colision_limite,
		   colision_desc_limite,
		   colision_prima,
		   colision_deducible,
		   incendio_limite,
		   incendio_desc_limite,
		   incendio_prima,
		   incendio_deducible,
		   asistencia_vial_limite,
		   asistencia_vial_desc_limite,
		   asistencia_vial_prima,
		   asistencia_vial_deducible,
		   robo_limite,
		   robo_desc_limite,
		   robo_prima,
		   robo_deducible,
		   muerte_limite,
		   muerte_desc_limite,
		   muerte_prima,
		   muerte_deducible,
		   invalidez_limite,
		   invalidez_desc_limite,
		   invalidez_prima,
		   invalidez_deducible,
		   ancon_plus_limite,
		   ancon_plus_desc_limite,
		   ancon_plus_prima,
		   ancon_plus_deducible,
		   naviera_limite,
		   naviera_desc_limite,
		   naviera_prima,
		   naviera_deducible,
		   perdida_total_limite,
		   perdida_total_desc_limite,
		   perdida_total_prima,
		   perdida_total_deducible,
		   rotura_limite,
		   rotura_desc_limite,
		   rotura_prima,
		   rotura_deducible,
		   transporte_limite,
		   transporte_desc_limite,
		   transporte_prima,
		   transporte_deducible
	  into _no_documento,
		   _no_unidad,
		   _cod_ramo,
		   _cod_subramo,
		   _cod_contratante,
		   _cod_asegurado,
		   _cod_agente,
		   _vigencia_inic,
		   _vigencia_final,
		   _prima,
		   _porc_descuento,
		   _descuento,
		   _prima_neta,
		   _porc_impuesto,
		   _impuesto,
		   _prima_bruta,
		   _suma_asegurada,
		   _prima_bruta_ant,
		   _suma_aseg_ant,
		   _cod_producto,
		   _cod_acreedor,
		   _no_motor,
		   _cod_tipoveh,
		   _uso_auto,
		   _ano_auto,
		   _ano_tarifa,
		   _cod_color,
		   _cod_marca,
		   _cod_modelo,
		   _valor_auto,
		   _no_chasis,
		   _porc_desc_rc,
		   _porc_desc_tabla,
		   _porc_desc_modelo,
		   _porc_desc_flota,
		   _porc_desc_sinis,
		   _vin,
		   _placa,
		   _placa_taxi,
		   _nuevo,
		   _lesiones_corp_limite,
		   _lesiones_corp_desc_limite,
		   _lesiones_corp_prima,
		   _lesiones_corp_deducible,
		   _danos_limite,
		   _danos_desc_limite,
		   _danos_prima,
		   _danos_deducible,
		   _gastos_med_limite,
		   _gastos_med_desc_limite,
		   _gastos_med_prima,
		   _gastos_med_deducible,
		   _comprensivo_limite,
		   _comprensivo_desc_limite,
		   _comprensivo_prima,
		   _comprensivo_deducible,
		   _colision_limite,
		   _colision_desc_limite,
		   _colision_prima,
		   _colision_deducible,
		   _incendio_limite,
		   _incendio_desc_limite,
		   _incendio_prima,
		   _incendio_deducible,
		   _asistencia_vial_limite,
		   _asistencia_vial_desc_limite,
		   _asistencia_vial_prima,
		   _asistencia_vial_deducible,
		   _robo_limite,
		   _robo_desc_limite,
		   _robo_prima,
		   _robo_deducible,
		   _muerte_limite,
		   _muerte_desc_limite,
		   _muerte_prima,
		   _muerte_deducible,
		   _invalidez_limite,
		   _invalidez_desc_limite,
		   _invalidez_prima,
		   _invalidez_deducible,
		   _ancon_plus_limite,
		   _ancon_plus_desc_limite,
		   _ancon_plus_prima,
		   _ancon_plus_deducible,
		   _naviera_limite,
		   _naviera_desc_limite,
		   _naviera_prima,
		   _naviera_deducible,
		   _perdida_total_limite,
		   _perdida_total_desc_limite,
		   _perdida_total_prima,
		   _perdida_total_deducible,
		   _rotura_limite,
		   _rotura_desc_limite,
		   _rotura_prima,
		   _rotura_deducible,
		   _transporte_limite,
		   _transporte_desc_limite,
		   _transporte_prima,
		   _transporte_deducible
	  from prdpreren
	 where periodo between a_periodo1 and a_periodo2
	   and no_documento not in (select no_documento from tmp_renpoliza)
	 order by cod_ramo,cod_subramo,no_documento,cod_producto

	select nombre
	  into _nom_ramo
	  from prdramo
	 where cod_ramo = _cod_ramo;

	select nombre
	  into _nom_subramo
	  from prdsubra
	 where cod_ramo = _cod_ramo
	   and cod_subramo = _cod_subramo;

	select nombre,
		   cedula
	  into _nom_cliente,
		   _cedula
	  from cliclien
	 where cod_cliente = _cod_contratante;

	select nombre,
		   cedula
	  into _nom_asegurado,
		   _cedula_asegurado
	  from cliclien
	 where cod_cliente = _cod_asegurado;

	select nombre
	  into _nom_producto
	  from prdprod
	 where cod_producto = _cod_producto;

	select nombre
	  into _nom_acreedor
	  from emiacre
	 where cod_acreedor = _cod_acreedor;

	select nombre
	  into _nom_marca
	  from emimarca
	 where cod_marca = _cod_marca;

	select nombre,
		   cod_tipoauto
	  into _nom_modelo,
		   _cod_tipoauto
	  from emimodel
	 where cod_modelo = _cod_modelo;

    select nombre
	  into _tipo_auto
	  from emitiaut
	 where cod_tipoauto = _cod_tipoauto;

	select nombre
	  into _nom_color
	  from emicolor
	 where cod_color = _cod_color;

	select nombre
	  into _nom_tipoveh
	  from emitiveh
	 where cod_tipoveh = _cod_tipoveh;

	select nombre
	  into _nom_agente
	  from agtagent
	 where cod_agente = _cod_agente;

	if _uso_auto = 'P' then
		let _nom_uso_auto = 'PARTICULAR';
	elif _uso_auto = 'C' then
		let _nom_uso_auto = 'COMERCIAL';
	else
		let _nom_uso_auto = _uso_auto;
	end if

	if _nuevo = 1 then
		let _desc_nuevo = 'SI';
	else
		let _desc_nuevo = 'NO';
	end if

	return _no_documento,
		   _no_unidad,
		   _nom_ramo,
		   _nom_subramo,
		   _nom_cliente,
		   _cedula,
		   _nom_asegurado,
		   _cedula_asegurado,
		   _cod_agente,
		   _nom_agente,
		   _vigencia_inic,
		   _vigencia_final,
		   _prima,
		   _porc_descuento,
		   _descuento,
		   _prima_neta,
		   _porc_impuesto,
		   _impuesto,
		   _prima_bruta,
		   _suma_asegurada,
		   _prima_bruta_ant,
		   _suma_aseg_ant,
		   _nom_producto,
		   _nom_acreedor,
		   _no_motor,
		   _nom_tipoveh,
		   _nom_uso_auto,
		   _tipo_auto,
		   _ano_auto,
		   _ano_tarifa,
		   _valor_auto,
		   _nom_marca,
		   _nom_modelo,
		   _nom_color,
		   _no_chasis,
		   _vin,
		   _placa,
		   _placa_taxi,
		   _desc_nuevo,
		   _porc_desc_rc,
		   _porc_desc_tabla,
		   _porc_desc_modelo,
		   _porc_desc_flota,
		   _porc_desc_sinis,
		   _lesiones_corp_prima,
		   _lesiones_corp_limite,
		   _lesiones_corp_desc_limite,
		   _lesiones_corp_deducible,
		   _danos_prima,
		   _danos_limite,
		   _danos_desc_limite,
		   _danos_deducible,
		   _gastos_med_prima,
		   _gastos_med_limite,
		   _gastos_med_desc_limite,
		   _gastos_med_deducible,
		   _comprensivo_prima,
		   _comprensivo_limite,
		   _comprensivo_desc_limite,
		   _comprensivo_deducible,
		   _colision_prima,
		   _colision_limite,
		   _colision_desc_limite,
		   _colision_deducible,
		   _incendio_prima,
		   _incendio_limite,
		   _incendio_desc_limite,
		   _incendio_deducible,
		   _asistencia_vial_prima,
		   _asistencia_vial_limite,
		   _asistencia_vial_desc_limite,
		   _asistencia_vial_deducible,
		   _robo_prima,
		   _robo_limite,
		   _robo_desc_limite,
		   _robo_deducible,
		   _muerte_prima,
		   _muerte_limite,
		   _muerte_desc_limite,
		   _muerte_deducible,
		   _invalidez_prima,
		   _invalidez_limite,
		   _invalidez_desc_limite,
		   _invalidez_deducible,
		   _ancon_plus_prima,
		   _ancon_plus_limite,
		   _ancon_plus_desc_limite,
		   _ancon_plus_deducible,
		   _naviera_prima,
		   _naviera_limite,
		   _naviera_desc_limite,
		   _naviera_deducible,
		   _perdida_total_prima,
		   _perdida_total_limite,
		   _perdida_total_desc_limite,
		   _perdida_total_deducible,
		   _rotura_prima,
		   _rotura_limite,
		   _rotura_desc_limite,
		   _rotura_deducible,
		   _transporte_prima,
		   _transporte_limite,
		   _transporte_desc_limite,
		   _transporte_deducible
		   with resume;	 
end foreach

end
end procedure;