----------------------------------------------------------
--Proceso de Renovaciones
--Creado    : 25/09/2024 - Autor: Amado Perez
----------------------------------------------------------
--execute procedure sp_pro382('001','001','2016-02','2016-02')

drop procedure sp_pro598;
create procedure sp_pro598(a_periodo1 char(7), a_tipo_ren smallint)
returning	char(21)		as Poliza, 					--_no_documento,
			char(5)			as Unidad,					--_no_unidad,
			varchar(50)		as Ramo,					--_nom_ramo,
			varchar(50)		as SubRamo,					--_nom_subramo,
			varchar(100)	as Contratante,				--_nom_cliente,
			varchar(100)	as Asegurado,				--_nom_asegurado,
			varchar(50)		as Corredor,				--_nom_agente,
			date			as Vigencia_Inicial,		--_vigencia_inic,
			date			as Vigencia_Final,			--_vigencia_final,
			dec(16,2)		as Prima,					--_prima,
			dec(5,2)		as Porc_Descuento,			--_porc_descuento,
			dec(16,2)		as Descuento,				--_descuento,
			dec(16,2)		as Prima_Neta,				--_prima_neta,
			dec(16,2)		as Suma_Asegurada,			--_suma_asegurada,
			dec(16,2)     	as Saldo,
			dec(16,2)		as DiezPorc,
			dec(5,2)		as Incremento,
			dec(16,2)		as Incremento_Neto,
			dec(16,2)      	as Prima_Resultado,
			smallint        as Procesado,
			smallint  		as Actualizado,
			smallint        as Error_Emite,
			varchar(100)   	as Desc_Error;

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
define _saldo                       dec(16,2);
define _diezporc					dec(16,2);
define _incremento					dec(5,2);
define _incremento_neto				dec(16,2);
define _prima_resultado				dec(16,2);
define _procesado            		smallint;
define _actualizado                 smallint;
define _desc_error					varchar(100);


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
		   suma_asegurada,
		   saldo,
		   diezporc,
		   incremento,
		   incremento_neto,
		   prima_resultado,
		   procesado,
		   actualizado,
		   error,
		   desc_error,
		   uso_auto
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
		   _suma_asegurada,
		   _saldo,
		   _diezporc,
		   _incremento,
		   _incremento_neto,
		   _prima_resultado,
		   _procesado,
		   _actualizado,
		   _error,
		   _desc_error,
		   _uso_auto
	  from prdpreren
	 where periodo = a_periodo1 
	   and tipo_ren = a_tipo_ren
	--   and no_documento not in (select no_documento from tmp_renpoliza)
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
	  into _nom_agente
	  from agtagent
	 where cod_agente = _cod_agente;


	return _no_documento,
		   _no_unidad,
		   _nom_ramo,
		   _nom_subramo,
		   _nom_cliente,
		   _nom_asegurado,
		   _nom_agente,
		   _vigencia_inic,
		   _vigencia_final,
		   _prima,
		   _porc_descuento,
		   _descuento,
		   _prima_neta,
		   _suma_asegurada,
		   _saldo,
		   _diezporc,
		   _incremento,
		   _incremento_neto,
		   _prima_resultado,
		   _procesado,
		   _actualizado,
		   _error,
		   _desc_error
		   with resume;	 
end foreach

end
end procedure;