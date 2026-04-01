-- Procedimiento para procesar los valores en las tablas de DEIVID y emitir las polizas de ducruet
-- Creado    : 28/07/2022 - Autor: Román  Gordón

-- SIS v.2.0 - DEIVID, S.A.

drop procedure sp_avisos_serafin;

create procedure "informix".sp_avisos_serafin() 
returning	smallint,varchar(200);


define _error_title			varchar(200);
define _error_desc			varchar(200);
define _nom_cliente			varchar(50);
define _deducible_incendio	varchar(50);
define _deducible_robo		varchar(50);
define _asegurado			varchar(50);
define _email				varchar(50);
define _poliza_ant			varchar(30);
define _cedula				varchar(30);
define _no_documento		varchar(20);
define _no_chasis			varchar(30);
define _tel1			varchar(30);
define _uso_auto			char(30);
define _ruc					char(30);
define _poliza_maestra_auto	char(20);
define _poliza_maestra_tran	char(20);
define _cod_producto		char(10);
define _cod_cliente			char(10);
define _no_poliza_mae		char(10);
define _no_poliza			char(10);
define _estatus				char(10);
define _tipo				char(10);
define _periodo				char(7);
define _asiento				char(7);
define _tomo				char(7);
define _placa				char(6);
define _no_unidad			char(5);
define _no_aviso			char(5);
define _cod_marca			char(5);
define _cod_compania		char(3);
define _cod_sucursal		char(3);
define _cod_impuesto		char(3);
define _cod_subramo			char(3);
define _cod_tipoveh			char(3);
define _cod_ramo			char(3);
define _provincia			char(2);
define _inicial				char(2);
define _tipo_persona		char(1);
define _null				char(1);
define _limite_lesiones1	dec(16,2);
define _limite_lesiones2	dec(16,2);
define _tarifa_colision		dec(16,2);
define _suma_asegurada		dec(16,2);
define _limite_dpa1			dec(16,2);
define _limite_dpa2			dec(16,2);
define _prima_asistencia	dec(16,2);
define _prima_extraterr		dec(16,2);
define _prima_lesiones		dec(16,2);
define _prima_colision		dec(16,2);
define _prima_incendio		dec(16,2);
define _prima_naviera		dec(16,2);
define _prima_muerte		dec(16,2);
define _prima_bruta			dec(16,2);
define _prima_robo			dec(16,2);
define _prima_dpa			dec(16,2);
define _impuesto			dec(16,2);
define _subtotal			dec(16,2);
define _prima				dec(16,2);
define _factor_impuesto		dec(5,2);
define _porc_comision		dec(5,2);
define _vigencia_final		date;
define _vigencia_inic		date;
define _fecha_hoy			date;
define _error_isam			smallint;
define _renglon				smallint;
define _ano_actual			smallint;
define _ano_tarifa			smallint;
define _auto_nuevo			smallint;
define _serie				smallint;
define li_return			smallint;
define _ramo_sis			smallint;
define _ano_auto			smallint;
define _tipo_doc			smallint;
define _cnt_auto			smallint;
define _existe				smallint;
define _error				smallint;

	begin
	on exception set _error,_error_isam,_error_desc
		return _error,_error_desc;         
	end exception

	set isolation to dirty read;
	--set debug file to "sp_emite01.trc"; 
	--trace on;

 	foreach
	select can.no_aviso,
		   can.renglon,
		   can.no_documento,
		   cli.cod_cliente,
		   cli.cedula,
		   cli.nombre,
		   cli.telefono1
	  into _no_aviso,
		   _renglon,
		   _no_documento,
		   _cod_cliente,
		   _cedula,
		   _nom_cliente,
		   _tel1
	  from avisocanc can
	 inner join emipomae emi on emi.no_poliza = can.no_poliza
	 inner join emipouni uni on uni.no_poliza = emi.no_poliza
	 inner join cliclien cli on cli.cod_cliente = uni.cod_asegurado
	 inner join parmailcomp com on com.no_remesa = can.no_aviso and com.renglon = can.renglon
	 inner join parmailsend cor on cor.secuencia = com.mail_secuencia
	 where no_aviso in ('02370','02369')
	   and can.cedula = '3-NT-1-690' and estatus <> 'Y'

	update avisocanc
	   set cedula = _cedula,
		   nombre_cliente = _nom_cliente,
		   tel1_cli = _tel1,
		   cod_contratante = _cod_cliente,
		   email_cli = 'gerencia@serafinnino.com.pa',
		   clase = 1
	 where no_aviso = _no_aviso
	   and renglon = _renglon;
	   
	call sp_par316('00010','gerencia@serafinnino.com.pa',_no_aviso,_renglon) returning _error_isam,_error_desc; 
	
	if _error_isam <> 0 then
		return _error_isam, _error_desc;
	end if
	
	return _renglon,
			"Actualización Exitosa"
			with resume;

	end foreach
	return 0,"Actualización Exitosa";
	end
end procedure
